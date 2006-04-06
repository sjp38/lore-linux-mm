From: Con Kolivas <kernel@kolivas.org>
Subject: [PATCH] mm: limit lowmem_reserve
Date: Thu, 6 Apr 2006 11:10:35 +1000
References: <200604021401.13331.kernel@kolivas.org> <200604031248.13532.kernel@kolivas.org> <200604041235.59876.kernel@kolivas.org>
In-Reply-To: <200604041235.59876.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200604061110.35789.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: ck@vds.kolivas.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It is possible with a low enough lowmem_reserve ratio to make
zone_watermark_ok always fail if the lower_zone is small enough.
Impose a lower limit on the ratio to only allow 1/4 of the lower_zone
size to be set as lowmem_reserve. This limit is hit in ZONE_DMA by changing
the default vmsplit on i386 even without changing the default sysctl values.

Signed-off-by: Con Kolivas <kernel@kolivas.org>

---
 mm/page_alloc.c |   24 +++++++++++++++++++++---
 1 files changed, 21 insertions(+), 3 deletions(-)

Index: linux-2.6.17-rc1-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.17-rc1-mm1.orig/mm/page_alloc.c	2006-04-06 10:32:31.000000000 +1000
+++ linux-2.6.17-rc1-mm1/mm/page_alloc.c	2006-04-06 11:09:17.000000000 +1000
@@ -2566,14 +2566,32 @@ static void setup_per_zone_lowmem_reserv
 			zone->lowmem_reserve[j] = 0;
 
 			for (idx = j-1; idx >= 0; idx--) {
+				unsigned long max_reserve;
+				unsigned long reserve;
 				struct zone *lower_zone;
 
+				lower_zone = pgdat->node_zones + idx;
+				/*
+				 * Put an upper limit on the reserve at 1/4
+				 * the lower_zone size. This prevents large
+				 * zone size differences such as 3G VMSPLIT
+				 * or low sysctl values from making
+				 * zone_watermark_ok always fail. This
+				 * enforces a lower limit on the reserve_ratio
+				 */
+				max_reserve = lower_zone->present_pages / 4;
+
 				if (sysctl_lowmem_reserve_ratio[idx] < 1)
 					sysctl_lowmem_reserve_ratio[idx] = 1;
-
-				lower_zone = pgdat->node_zones + idx;
-				lower_zone->lowmem_reserve[j] = present_pages /
+				reserve = present_pages /
 					sysctl_lowmem_reserve_ratio[idx];
+				if (reserve > max_reserve) {
+					reserve = max_reserve;
+					sysctl_lowmem_reserve_ratio[idx] =
+						present_pages / max_reserve;
+				}
+
+				lower_zone->lowmem_reserve[j] = reserve;
 				present_pages += lower_zone->present_pages;
 			}
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
