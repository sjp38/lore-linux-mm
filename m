Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 68B9B6B0068
	for <linux-mm@kvack.org>; Sun, 25 Nov 2012 19:16:58 -0500 (EST)
Date: Sun, 25 Nov 2012 19:16:45 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH] mm,vmscan: only loop back if compaction would fail in all
 zones
Message-ID: <20121125191645.0ebc6d59@annuminas.surriel.com>
In-Reply-To: <20121125224433.GB2799@cmpxchg.org>
References: <20121119202152.4B0E420004E@hpza10.eem.corp.google.com>
	<20121125175728.3db4ac6a@fem.tu-ilmenau.de>
	<20121125132950.11b15e38@annuminas.surriel.com>
	<20121125224433.GB2799@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, akpm@linux-foundation.org, mgorman@suse.de, Valdis.Kletnieks@vt.edu, jirislaby@gmail.com, jslaby@suse.cz, zkabelac@redhat.com, mm-commits@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Sun, 25 Nov 2012 17:44:33 -0500
Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Sun, Nov 25, 2012 at 01:29:50PM -0500, Rik van Riel wrote:

> > Could you try this patch?
> 
> It's not quite enough because it's not reaching the conditions you
> changed, see analysis in https://lkml.org/lkml/2012/11/20/567

Johannes,

does the patch below fix your problem?

I suspect it would, because kswapd should only ever run into this
particular problem when we have a tiny memory zone in a pgdat,
and in that case we will also have a larger zone nearby, where
compaction would just succeed.

---8<---

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
