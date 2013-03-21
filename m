Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 6EBFD6B0002
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 14:02:44 -0400 (EDT)
Date: Thu, 21 Mar 2013 18:02:38 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 02/10] mm: vmscan: Obey proportional scanning
 requirements for kswapd
Message-ID: <20130321180238.GM1878@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-3-git-send-email-mgorman@suse.de>
 <20130321162518.GB27848@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130321162518.GB27848@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Thu, Mar 21, 2013 at 12:25:18PM -0400, Johannes Weiner wrote:
> On Sun, Mar 17, 2013 at 01:04:08PM +0000, Mel Gorman wrote:
> > Simplistically, the anon and file LRU lists are scanned proportionally
> > depending on the value of vm.swappiness although there are other factors
> > taken into account by get_scan_count().  The patch "mm: vmscan: Limit
> > the number of pages kswapd reclaims" limits the number of pages kswapd
> > reclaims but it breaks this proportional scanning and may evenly shrink
> > anon/file LRUs regardless of vm.swappiness.
> > 
> > This patch preserves the proportional scanning and reclaim. It does mean
> > that kswapd will reclaim more than requested but the number of pages will
> > be related to the high watermark.
> 
> Swappiness is about page types, but this implementation compares all
> LRUs against each other, and I'm not convinced that this makes sense
> as there is no guaranteed balance between the inactive and active
> lists.  For example, the active file LRU could get knocked out when
> it's almost empty while the inactive file LRU has more easy cache than
> the anon lists combined.
> 

Ok, I see your point. I think Michal was making the same point but I
failed to understand it the first time around.

> Would it be better to compare the sum of file pages with the sum of
> anon pages and then knock out the smaller pair?

Yes, it makes more sense but the issue then becomes how can we do that
sensibly, The following is straight-forward and roughly in line with your
suggestion but it does not preseve the scanning ratio between active and
inactive of the remaining LRU lists.

                /*
                 * For kswapd and memcg, reclaim at least the number of pages
                 * requested. Ensure that the anon and file LRUs shrink
                 * proportionally what was requested by get_scan_count(). We
                 * stop reclaiming one LRU and reduce the amount scanning
                 * required on the other.
                 */
                nr_file = nr[LRU_INACTIVE_FILE] + nr[LRU_ACTIVE_FILE];
                nr_anon = nr[LRU_INACTIVE_ANON] + nr[LRU_ACTIVE_ANON];

                if (nr_file > nr_anon) {
                        nr[LRU_INACTIVE_FILE] -= min(nr_anon, nr[LRU_INACTIVE_FILE]);
                        nr[LRU_ACTIVE_FILE]   -= min(nr_anon, nr[LRU_ACTIVE_FILE]);
                        nr[LRU_INACTIVE_ANON] = nr[LRU_ACTIVE_ANON] = 0;
                } else {
                        nr[LRU_INACTIVE_ANON] -= min(nr_file, nr[LRU_INACTIVE_ANON]);
                        nr[LRU_ACTIVE_ANON]   -= min(nr_file, nr[LRU_ACTIVE_ANON]);
                        nr[LRU_INACTIVE_FILE] = nr[LRU_ACTIVE_FILE] = 0;
                }
                scan_adjusted = true;

Preserving the ratio gets complicated and to avoid excessive branching,
it ends up looking like the following untested code.

		/*
		 * For kswapd and memcg, reclaim at least the number of pages
		 * requested. Ensure that the anon and file LRUs shrink
		 * proportionally what was requested by get_scan_count(). We
		 * stop reclaiming one LRU and reduce the amount scanning
		 * required on the other preserving the ratio between the
		 * active/inactive lists.
		 *
		 * Start by preparing to shrink the larger of the LRUs by
		 * the size of the smaller list.
		 */
		nr_file = nr[LRU_INACTIVE_FILE] + nr[LRU_ACTIVE_FILE];
		nr_anon = nr[LRU_INACTIVE_ANON] + nr[LRU_ACTIVE_ANON];
		nr_shrink = (nr_file > nr_anon) ? nr_anon : nr_file;
		lru = (nr_file > nr_anon) ? LRU_FILE : 0;

		/* Work out the ratio of the inactive/active list */
		top = min(nr[LRU_ACTIVE + lru], nr[lru]);
		bottom = max(nr[LRU_ACTIVE + lru], nr[lru]);
		percentage = top * 100 / bottom;
		nr_fraction = nr_shrink * percentage / 100;
		nr_remaining = nr_anon - nr_fraction;

		/* Reduce the remaining pages to scan proportionally */
		if (nr[LRU_ACTIVE + lru] > nr[lru]) {
			nr[LRU_ACTIVE + lru] -= min(nr_remaining, nr[LRU_ACTIVE + lru]);
			nr[lru] -= min(nr_fraction,  nr[lru]);
		} else {
			nr[LRU_ACTIVE + lru] -= min(nr_fraction, nr[LRU_ACTIVE + lru]);
			nr[lru] -= min(nr_remaining,  nr[lru]);
		}

		/* Stop scanning the smaller LRU */
		lru = (lru == LRU_FILE) ? LRU_BASE : LRU_FILE;
		nr[LRU_ACTIVE + lru] = 0;
		nr[lru] = 0;

Is this what you had in mind or had you something simplier in mind?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
