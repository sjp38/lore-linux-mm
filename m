Message-ID: <41130FD2.5070608@yahoo.com.au>
Date: Fri, 06 Aug 2004 14:57:54 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH] 2/4: highmem watermarks
References: <41130FB1.5020001@yahoo.com.au>
In-Reply-To: <41130FB1.5020001@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------080007090302010707080808"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------080007090302010707080808
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

2/4

--------------080007090302010707080808
Content-Type: text/x-patch;
 name="vm-highmem-watermarks.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm-highmem-watermarks.patch"



The pages_high - pages_low and pages_low - pages_min deltas are the asynch
reclaim watermarks. As such, the should be in the same ratios as any other
zone for highmem zones. It is the pages_min - 0 delta which is the PF_MEMALLOC
reserve, and this is the region that isn't very useful for highmem.

This patch ensures highmem systems have similar characteristics as non highmem
ones with the same amount of memory, and also that highmem zones get similar
reclaim pressures to other zones.

Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>


---

 linux-2.6-npiggin/mm/page_alloc.c |   23 ++++++++++++++---------
 1 files changed, 14 insertions(+), 9 deletions(-)

diff -puN mm/page_alloc.c~vm-highmem-watermarks mm/page_alloc.c
--- linux-2.6/mm/page_alloc.c~vm-highmem-watermarks	2004-08-06 14:44:29.000000000 +1000
+++ linux-2.6-npiggin/mm/page_alloc.c	2004-08-06 14:44:29.000000000 +1000
@@ -1882,13 +1882,18 @@ static void setup_per_zone_pages_min(voi
 	}
 
 	for_each_zone(zone) {
+		unsigned long tmp;
 		spin_lock_irqsave(&zone->lru_lock, flags);
+		tmp = (pages_min * zone->present_pages) / lowmem_pages;
 		if (is_highmem(zone)) {
 			/*
-			 * Often, highmem doesn't need to reserve any pages.
-			 * But the pages_min/low/high values are also used for
-			 * batching up page reclaim activity so we need a
-			 * decent value here.
+			 * __GFP_HIGH and PF_MEMALLOC allocations usually don't
+			 * need highmem pages, so cap pages_min to a small
+			 * value here.
+			 *
+			 * The (pages_high-pages_low) and (pages_low-pages_min)
+			 * deltas controls asynch page reclaim, and so should
+			 * not be capped for highmem.
 			 */
 			int min_pages;
 
@@ -1899,15 +1904,15 @@ static void setup_per_zone_pages_min(voi
 				min_pages = 128;
 			zone->pages_min = min_pages;
 		} else {
-			/* if it's a lowmem zone, reserve a number of pages 
+			/*
+			 * If it's a lowmem zone, reserve a number of pages
 			 * proportionate to the zone's size.
 			 */
-			zone->pages_min = (pages_min * zone->present_pages) / 
-			                   lowmem_pages;
+			zone->pages_min = tmp;
 		}
 
-		zone->pages_low = zone->pages_min * 2;
-		zone->pages_high = zone->pages_min * 3;
+		zone->pages_low = zone->pages_min + tmp;
+		zone->pages_high = zone->pages_low + tmp;
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 	}
 }

_

--------------080007090302010707080808--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
