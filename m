Date: Fri, 18 Jan 2008 15:34:33 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH] a bit improvement of ZONE_DMA page reclaim 
Message-Id: <20080118151822.8FAE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <marcelo@kvack.org>, Rik van Riel <riel@redhat.com>, Daniel Spang <daniel.spang@gmail.com>
List-ID: <linux-mm.kvack.org>

Hi

on X86, ZONE_DMA is very very small.
It is often no used at all. 

Unfortunately, 
when NR_ACTIVE==0, NR_INACTIVE==0, shrink_zone() try to reclaim 1 page.
because

    zone->nr_scan_active +=
        (zone_page_state(zone, NR_ACTIVE) >> priority) + 1;
                                                        ^^^^^

it cause unnecessary spent cpu time.

In addition, to a bad thing
when NR_ACTIVE==0 and NR_INACTIVE==0, zone_is_near_oom always true.
bacause 0 >= 0+0 is true.

the effect of this strange behavior is very small.
but it confuse to the VM newbie developer (= me) ;-)



this patch against: 2.6.24-rc6-mm1

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c       2008-01-18 14:18:27.000000000 +0900
+++ b/mm/vmscan.c       2008-01-18 14:49:06.000000000 +0900
@@ -948,7 +948,7 @@ static inline void note_zone_scanning_pr

 static inline int zone_is_near_oom(struct zone *zone)
 {
-       return zone->pages_scanned >= (zone_page_state(zone, NR_ACTIVE)
+       return zone->pages_scanned > (zone_page_state(zone, NR_ACTIVE)
                                + zone_page_state(zone, NR_INACTIVE))*3;
 }

@@ -1214,18 +1214,29 @@ static unsigned long shrink_zone(int pri
        unsigned long nr_inactive;
        unsigned long nr_to_scan;
        unsigned long nr_reclaimed = 0;
+       unsigned long tmp;
+       unsigned long zone_active;
+       unsigned long zone_inactive;

        if (scan_global_lru(sc)) {
                /*
                 * Add one to nr_to_scan just to make sure that the kernel
                 * will slowly sift through the active list.
                 */
-               zone->nr_scan_active +=
-                       (zone_page_state(zone, NR_ACTIVE) >> priority) + 1;
+               zone_active = zone_page_state(zone, NR_ACTIVE);
+               tmp = (zone_active >> priority) + 1;
+               if (unlikely(tmp > zone_active))
+                       tmp = zone_active;
+               zone->nr_scan_active += tmp;
                nr_active = zone->nr_scan_active;
-               zone->nr_scan_inactive +=
-                       (zone_page_state(zone, NR_INACTIVE) >> priority) + 1;
+
+               zone_inactive = zone_page_state(zone, NR_INACTIVE);
+               tmp = (zone_inactive >> priority) + 1;
+               if (unlikely(tmp > zone_inactive))
+                       tmp = zone_inactive;
+               zone->nr_scan_inactive += tmp;
                nr_inactive = zone->nr_scan_inactive;
+
                if (nr_inactive >= sc->swap_cluster_max)
                        zone->nr_scan_inactive = 0;
                else



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
