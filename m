Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id B99266B0072
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 05:01:07 -0500 (EST)
Date: Mon, 26 Nov 2012 10:01:02 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: 3.7-rc6 soft lockup in kswapd0
Message-ID: <20121126100102.GH8218@suse.de>
References: <20121123085137.GA646@suse.de>
 <20121126035841.5973.qmail@science.horizon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121126035841.5973.qmail@science.horizon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: dave@linux.vnet.ibm.com, jack@suse.cz, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Nov 25, 2012 at 10:58:41PM -0500, George Spelvin wrote:
> Sorry for the delay; was AF(that)K for the weekend.
> 
> > Ok, is there any chance you can capture more of sysrq+m, particularly the
> > bits that say how much free memory there is and many pages of each order
> > that is free? If you can't, it's ok. I ask because my kernel bug dowsing
> > rod is twitching in the direction of the recent free page accounting bug
> > Dave Hansen identified and fixed -- https://lkml.org/lkml/2012/11/21/504
> 
> Okay; as mentioned, I installed that patch and it didn't make any obvious
> difference to the symptoms.
> 
> The hang IP is still either in __zone_watermark_ok or kswapd (address varies).
> 

Ok, can you try this patch from Rik on top as well please? This is in
addition to Dave Hansen's accounting fix.

---8<---
From: Rik van Riel <riel@redhat.com>
Subject: mm,vmscan: only loop back if compaction would fail in all zones

Kswapd frees memory to satisfy two goals:
1) allow allocations to succeed, and
2) balance memory pressure between zones 

Currently, kswapd has an issue where it will loop back to free
more memory if any memory zone in the pgdat has not enough free
memory for compaction.  This can lead to unnecessary overhead,
and even infinite loops in kswapd.

It is better to only loop back to free more memory if all of
the zones in the pgdat have insufficient free memory for
compaction.  That satisfies both of kswapd's goals with less
overhead.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b99ecba..f0d111b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2790,6 +2790,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 	 */
 	if (order) {
 		int zones_need_compaction = 1;
+		int compaction_needs_memory = 1;
 
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
@@ -2801,10 +2802,10 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 			    sc.priority != DEF_PRIORITY)
 				continue;
 
-			/* Would compaction fail due to lack of free memory? */
+			/* Is there enough memory for compaction? */
 			if (COMPACTION_BUILD &&
-			    compaction_suitable(zone, order) == COMPACT_SKIPPED)
-				goto loop_again;
+			    compaction_suitable(zone, order) != COMPACT_SKIPPED)
+				compaction_needs_memory = 0;
 
 			/* Confirm the zone is balanced for order-0 */
 			if (!zone_watermark_ok(zone, 0,
@@ -2822,6 +2823,10 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 			zone_clear_flag(zone, ZONE_CONGESTED);
 		}
 
+		/* None of the zones had enough free memory for compaction. */
+		if (compaction_needs_memory)
+			goto loop_again;
+
 		if (zones_need_compaction)
 			compact_pgdat(pgdat, order);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
