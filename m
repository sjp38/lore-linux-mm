Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 1C9596B004D
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 15:09:17 -0400 (EDT)
Date: Fri, 22 Mar 2013 15:09:02 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 02/10] mm: vmscan: Obey proportional scanning
 requirements for kswapd
Message-ID: <20130322190902.GA4611@cmpxchg.org>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-3-git-send-email-mgorman@suse.de>
 <20130321162518.GB27848@cmpxchg.org>
 <20130321180238.GM1878@suse.de>
 <20130322165349.GI1953@cmpxchg.org>
 <20130322182556.GB32241@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130322182556.GB32241@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Fri, Mar 22, 2013 at 06:25:56PM +0000, Mel Gorman wrote:
> On Fri, Mar 22, 2013 at 12:53:49PM -0400, Johannes Weiner wrote:
> > So would it make sense to determine the percentage scanned of the type
> > that we stop scanning, then scale the original goal of the remaining
> > LRUs to that percentage, and scan the remainder?
> 
> To preserve existing behaviour, that makes sense. I'm not convinced that
> it's necessarily the best idea but altering it would be beyond the scope
> of this series and bite off more than I'm willing to chew. This actually
> simplifies things a bit and shrink_lruvec turns into the (untested) code
> below. It does not do exact proportional scanning but I do not think it's
> necessary to either and is a useful enough approximation. It still could
> end up reclaiming much more than sc->nr_to_reclaim unfortunately but fixing
> it requires reworking how kswapd scans at different priorities.

In which way does it not do exact proportional scanning?  I commented
on one issue below, but maybe you were referring to something else.

Yes, it's a little unfortunate that we escalate to a gigantic scan
window first, and then have to contort ourselves in the process of
backing off gracefully after we reclaimed a few pages...

> Is this closer to what you had in mind?
> 
> static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
> {
> 	unsigned long nr[NR_LRU_LISTS];
> 	unsigned long nr_to_scan;
> 	enum lru_list lru;
> 	unsigned long nr_reclaimed = 0;
> 	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
> 	unsigned long nr_anon_scantarget, nr_file_scantarget;
> 	struct blk_plug plug;
> 	bool scan_adjusted = false;
> 
> 	get_scan_count(lruvec, sc, nr);
> 
> 	/* Record the original scan target for proportional adjustments later */
> 	nr_file_scantarget = nr[LRU_INACTIVE_FILE] + nr[LRU_ACTIVE_FILE] + 1;
> 	nr_anon_scantarget = nr[LRU_INACTIVE_ANON] + nr[LRU_ACTIVE_ANON] + 1;
> 
> 	blk_start_plug(&plug);
> 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
> 					nr[LRU_INACTIVE_FILE]) {
> 		unsigned long nr_anon, nr_file, percentage;
> 
> 		for_each_evictable_lru(lru) {
> 			if (nr[lru]) {
> 				nr_to_scan = min(nr[lru], SWAP_CLUSTER_MAX);
> 				nr[lru] -= nr_to_scan;
> 
> 				nr_reclaimed += shrink_list(lru, nr_to_scan,
> 							    lruvec, sc);
> 			}
> 		}
> 
> 		if (nr_reclaimed < nr_to_reclaim || scan_adjusted)
> 			continue;
> 
> 		/*
> 		 * For global direct reclaim, reclaim only the number of pages
> 		 * requested. Less care is taken to scan proportionally as it
> 		 * is more important to minimise direct reclaim stall latency
> 		 * than it is to properly age the LRU lists.
> 		 */
> 		if (global_reclaim(sc) && !current_is_kswapd())
> 			break;
> 
> 		/*
> 		 * For kswapd and memcg, reclaim at least the number of pages
> 		 * requested. Ensure that the anon and file LRUs shrink
> 		 * proportionally what was requested by get_scan_count(). We
> 		 * stop reclaiming one LRU and reduce the amount scanning
> 		 * proportional to the original scan target.
> 		 */
> 		nr_file = nr[LRU_INACTIVE_FILE] + nr[LRU_ACTIVE_FILE];
> 		nr_anon = nr[LRU_INACTIVE_ANON] + nr[LRU_ACTIVE_ANON];
> 
> 		if (nr_file > nr_anon) {
> 			lru = LRU_BASE;
> 			percentage = nr_anon * 100 / nr_anon_scantarget;
> 		} else {
> 			lru = LRU_FILE;
> 			percentage = nr_file * 100 / nr_file_scantarget;
> 		}
> 
> 		/* Stop scanning the smaller of the LRU */
> 		nr[lru] = 0;
> 		nr[lru + LRU_ACTIVE] = 0;
> 
> 		/* Reduce scanning of the other LRU proportionally */
> 		lru = (lru == LRU_FILE) ? LRU_BASE : LRU_FILE;
> 		nr[lru] = nr[lru] * percentage / 100;;
> 		nr[lru + LRU_ACTIVE] = nr[lru + LRU_ACTIVE] * percentage / 100;

The percentage is taken from the original goal but then applied to the
remainder of scan goal for the LRUs we continue scanning.  The more
pages that have already been scanned, the more inaccurate this gets.
Is that what you had in mind with useful enough approximation?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
