Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 57F2C6B0070
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 14:20:04 -0500 (EST)
Date: Mon, 3 Dec 2012 14:18:58 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: kswapd craziness in 3.7
Message-ID: <20121203191858.GY24381@cmpxchg.org>
References: <1354049315-12874-1-git-send-email-hannes@cmpxchg.org>
 <20121128094511.GS8218@suse.de>
 <50BCC3E3.40804@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50BCC3E3.40804@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zdenek Kabelac <zkabelac@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, George Spelvin <linux@horizon.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, Thorsten Leemhuis <fedora@leemhuis.info>, Tomas Racek <tracek@redhat.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Josh Boyer <jwboyer@gmail.com>, Valdis.Kletnieks@vt.edu, Jiri Slaby <jslaby@suse.cz>, Bruno Wolff III <bruno@wolff.to>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Szia Zdenek,

On Mon, Dec 03, 2012 at 04:23:15PM +0100, Zdenek Kabelac wrote:
> Ok, bad news - I've been hit by  kswapd0 loop again -
> my kernel git commit cc19528bd3084c3c2d870b31a3578da8c69952f3 again
> shown kswapd0 for couple minutes on CPU.
> 
> It seemed to go instantly away when I've drop caches
> (echo 3 >/proc/sys/vm/drop_cache)
> (After that I've had over 1G free memory)

Any chance you could retry with this patch on top?

Thanks!

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: vmscan: do not keep kswapd looping forever due
 to individual uncompactable zones

When a zone meets its high watermark and is compactable in case of
higher order allocations, it contributes to the percentage of the
node's memory that is considered balanced.

This requirement, that a node be only partially balanced, came about
when kswapd was desparately trying to balance tiny zones when all
bigger zones in the node had plenty of free memory.  Arguably, the
same should apply to compaction: if a significant part of the node is
balanced enough to run compaction, do not get hung up on that tiny
zone that might never get in shape.

When the compaction logic in kswapd is reached, we know that at least
25% of the node's memory is balanced properly for compaction (see
zone_balanced and pgdat_balanced).  Remove the individual zone checks
that restart the kswapd cycle.

Otherwise, we may observe more endless looping in kswapd where the
compaction code loops back to reclaim because of a single zone and
reclaim does nothing because the node is considered balanced overall.

Reported-by: Thorsten Leemhuis <fedora@leemhuis.info>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 16 ----------------
 1 file changed, 16 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3b0aef4..486100f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2806,22 +2806,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 			if (!populated_zone(zone))
 				continue;
 
-			if (zone->all_unreclaimable &&
-			    sc.priority != DEF_PRIORITY)
-				continue;
-
-			/* Would compaction fail due to lack of free memory? */
-			if (COMPACTION_BUILD &&
-			    compaction_suitable(zone, order) == COMPACT_SKIPPED)
-				goto loop_again;
-
-			/* Confirm the zone is balanced for order-0 */
-			if (!zone_watermark_ok(zone, 0,
-					high_wmark_pages(zone), 0, 0)) {
-				order = sc.order = 0;
-				goto loop_again;
-			}
-
 			/* Check if the memory needs to be defragmented. */
 			if (zone_watermark_ok(zone, order,
 				    low_wmark_pages(zone), *classzone_idx, 0))
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
