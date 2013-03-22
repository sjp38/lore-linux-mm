Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id D13F36B003B
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 14:26:03 -0400 (EDT)
Date: Fri, 22 Mar 2013 18:25:56 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 02/10] mm: vmscan: Obey proportional scanning
 requirements for kswapd
Message-ID: <20130322182556.GB32241@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-3-git-send-email-mgorman@suse.de>
 <20130321162518.GB27848@cmpxchg.org>
 <20130321180238.GM1878@suse.de>
 <20130322165349.GI1953@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130322165349.GI1953@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Fri, Mar 22, 2013 at 12:53:49PM -0400, Johannes Weiner wrote:
> On Thu, Mar 21, 2013 at 06:02:38PM +0000, Mel Gorman wrote:
> > On Thu, Mar 21, 2013 at 12:25:18PM -0400, Johannes Weiner wrote:
> > > On Sun, Mar 17, 2013 at 01:04:08PM +0000, Mel Gorman wrote:
> > > > Simplistically, the anon and file LRU lists are scanned proportionally
> > > > depending on the value of vm.swappiness although there are other factors
> > > > taken into account by get_scan_count().  The patch "mm: vmscan: Limit
> > > > the number of pages kswapd reclaims" limits the number of pages kswapd
> > > > reclaims but it breaks this proportional scanning and may evenly shrink
> > > > anon/file LRUs regardless of vm.swappiness.
> > > > 
> > > > This patch preserves the proportional scanning and reclaim. It does mean
> > > > that kswapd will reclaim more than requested but the number of pages will
> > > > be related to the high watermark.
> > > 
> > > Swappiness is about page types, but this implementation compares all
> > > LRUs against each other, and I'm not convinced that this makes sense
> > > as there is no guaranteed balance between the inactive and active
> > > lists.  For example, the active file LRU could get knocked out when
> > > it's almost empty while the inactive file LRU has more easy cache than
> > > the anon lists combined.
> > > 
> > 
> > Ok, I see your point. I think Michal was making the same point but I
> > failed to understand it the first time around.
> > 
> > > Would it be better to compare the sum of file pages with the sum of
> > > anon pages and then knock out the smaller pair?
> > 
> > Yes, it makes more sense but the issue then becomes how can we do that
> > sensibly, The following is straight-forward and roughly in line with your
> > suggestion but it does not preseve the scanning ratio between active and
> > inactive of the remaining LRU lists.
> 
> After thinking more about it, I wonder if subtracting absolute values
> of one LRU goal from the other is right to begin with, because the
> anon/file balance percentage is applied to individual LRU sizes, and
> these sizes are not necessarily comparable.
> 

Good point and in itself it's not 100% clear that it's a good idea. If
swappiness reflected the ratio of anon/file pages that were reflected
then it's very easy to reason about. By our current definition, the rate
at which anon or file pages get reclaimed adjusts as reclaim progresses.

> <Snipped the example>
>

I agree and I see your point.

> So would it make sense to determine the percentage scanned of the type
> that we stop scanning, then scale the original goal of the remaining
> LRUs to that percentage, and scan the remainder?
> 

To preserve existing behaviour, that makes sense. I'm not convinced that
it's necessarily the best idea but altering it would be beyond the scope
of this series and bite off more than I'm willing to chew. This actually
simplifies things a bit and shrink_lruvec turns into the (untested) code
below. It does not do exact proportional scanning but I do not think it's
necessary to either and is a useful enough approximation. It still could
end up reclaiming much more than sc->nr_to_reclaim unfortunately but fixing
it requires reworking how kswapd scans at different priorities.

Is this closer to what you had in mind?

static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
{
	unsigned long nr[NR_LRU_LISTS];
	unsigned long nr_to_scan;
	enum lru_list lru;
	unsigned long nr_reclaimed = 0;
	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
	unsigned long nr_anon_scantarget, nr_file_scantarget;
	struct blk_plug plug;
	bool scan_adjusted = false;

	get_scan_count(lruvec, sc, nr);

	/* Record the original scan target for proportional adjustments later */
	nr_file_scantarget = nr[LRU_INACTIVE_FILE] + nr[LRU_ACTIVE_FILE] + 1;
	nr_anon_scantarget = nr[LRU_INACTIVE_ANON] + nr[LRU_ACTIVE_ANON] + 1;

	blk_start_plug(&plug);
	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
					nr[LRU_INACTIVE_FILE]) {
		unsigned long nr_anon, nr_file, percentage;

		for_each_evictable_lru(lru) {
			if (nr[lru]) {
				nr_to_scan = min(nr[lru], SWAP_CLUSTER_MAX);
				nr[lru] -= nr_to_scan;

				nr_reclaimed += shrink_list(lru, nr_to_scan,
							    lruvec, sc);
			}
		}

		if (nr_reclaimed < nr_to_reclaim || scan_adjusted)
			continue;

		/*
		 * For global direct reclaim, reclaim only the number of pages
		 * requested. Less care is taken to scan proportionally as it
		 * is more important to minimise direct reclaim stall latency
		 * than it is to properly age the LRU lists.
		 */
		if (global_reclaim(sc) && !current_is_kswapd())
			break;

		/*
		 * For kswapd and memcg, reclaim at least the number of pages
		 * requested. Ensure that the anon and file LRUs shrink
		 * proportionally what was requested by get_scan_count(). We
		 * stop reclaiming one LRU and reduce the amount scanning
		 * proportional to the original scan target.
		 */
		nr_file = nr[LRU_INACTIVE_FILE] + nr[LRU_ACTIVE_FILE];
		nr_anon = nr[LRU_INACTIVE_ANON] + nr[LRU_ACTIVE_ANON];

		if (nr_file > nr_anon) {
			lru = LRU_BASE;
			percentage = nr_anon * 100 / nr_anon_scantarget;
		} else {
			lru = LRU_FILE;
			percentage = nr_file * 100 / nr_file_scantarget;
		}

		/* Stop scanning the smaller of the LRU */
		nr[lru] = 0;
		nr[lru + LRU_ACTIVE] = 0;

		/* Reduce scanning of the other LRU proportionally */
		lru = (lru == LRU_FILE) ? LRU_BASE : LRU_FILE;
		nr[lru] = nr[lru] * percentage / 100;;
		nr[lru + LRU_ACTIVE] = nr[lru + LRU_ACTIVE] * percentage / 100;

		scan_adjusted = true;
	}
	blk_finish_plug(&plug);
	sc->nr_reclaimed += nr_reclaimed;

	/*
	 * Even if we did not try to evict anon pages at all, we want to
	 * rebalance the anon lru active/inactive ratio.
	 */
	if (inactive_anon_is_low(lruvec))
		shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
				   sc, LRU_ACTIVE_ANON);

	throttle_vm_writeout(sc->gfp_mask);
}


-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
