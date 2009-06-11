Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7F71F6B005D
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 06:27:41 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5BASVTu003341
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 11 Jun 2009 19:28:31 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 81D5045DE52
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 19:28:31 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 590A245DE4F
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 19:28:31 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3DF871DB8040
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 19:28:31 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E383D1DB803E
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 19:28:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH for mmotm 5/5] fix vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch 
In-Reply-To: <20090611192114.6D4A.A69D9226@jp.fujitsu.com>
References: <20090611192114.6D4A.A69D9226@jp.fujitsu.com>
Message-Id: <20090611192757.6D59.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 11 Jun 2009 19:28:30 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Subject: [PATCH] fix vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch 


+	nr_unmapped_file_pages = zone_page_state(zone, NR_INACTIVE_FILE) +
+				 zone_page_state(zone, NR_ACTIVE_FILE) -
+				 zone_page_state(zone, NR_FILE_MAPPED);

is wrong. it can be underflow because tmpfs pages are not counted NR_*_FILE,
but they are counted NR_FILE_MAPPED.

fixing here.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/vmscan.c |   32 ++++++++++++++++++++------------
 1 file changed, 20 insertions(+), 12 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2333,6 +2333,23 @@ int sysctl_min_unmapped_ratio = 1;
  */
 int sysctl_min_slab_ratio = 5;
 
+static unsigned long zone_unmapped_file_pages(struct zone *zone)
+{
+	long nr_file_pages;
+	long nr_file_mapped;
+	long nr_unmapped_file_pages;
+
+	nr_file_pages = zone_page_state(zone, NR_INACTIVE_FILE) +
+			zone_page_state(zone, NR_ACTIVE_FILE);
+	nr_file_mapped = zone_page_state(zone, NR_FILE_MAPPED) -
+			 zone_page_state(zone,
+					NR_SWAP_BACKED_FILE_MAPPED);
+	nr_unmapped_file_pages = nr_file_pages - nr_file_mapped;
+
+	return nr_unmapped_file_pages > 0 ? nr_unmapped_file_pages : 0;
+}
+
+
 /*
  * Try to free up some pages from this zone through reclaim.
  */
@@ -2355,7 +2372,6 @@ static int __zone_reclaim(struct zone *z
 		.isolate_pages = isolate_pages_global,
 	};
 	unsigned long slab_reclaimable;
-	long nr_unmapped_file_pages;
 
 	disable_swap_token();
 	cond_resched();
@@ -2368,11 +2384,7 @@ static int __zone_reclaim(struct zone *z
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	nr_unmapped_file_pages = zone_page_state(zone, NR_INACTIVE_FILE) +
-				 zone_page_state(zone, NR_ACTIVE_FILE) -
-				 zone_page_state(zone, NR_FILE_MAPPED);
-
-	if (nr_unmapped_file_pages > zone->min_unmapped_pages) {
+	if (zone_unmapped_file_pages(zone) > zone->min_unmapped_pages) {
 		/*
 		 * Free memory by calling shrink zone with increasing
 		 * priorities until we have enough memory freed.
@@ -2419,8 +2431,7 @@ int zone_reclaim(struct zone *zone, gfp_
 {
 	int node_id;
 	int ret;
-	long nr_unmapped_file_pages;
-	long nr_slab_reclaimable;
+	unsigned long nr_slab_reclaimable;
 
 	/*
 	 * Zone reclaim reclaims unmapped file backed pages and
@@ -2432,11 +2443,8 @@ int zone_reclaim(struct zone *zone, gfp_
 	 * if less than a specified percentage of the zone is used by
 	 * unmapped file backed pages.
 	 */
-	nr_unmapped_file_pages = zone_page_state(zone, NR_INACTIVE_FILE) +
-				 zone_page_state(zone, NR_ACTIVE_FILE) -
-				 zone_page_state(zone, NR_FILE_MAPPED);
 	nr_slab_reclaimable = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
-	if (nr_unmapped_file_pages <= zone->min_unmapped_pages &&
+	if (zone_unmapped_file_pages(zone) <= zone->min_unmapped_pages &&
 	    nr_slab_reclaimable <= zone->min_slab_pages)
 		return 0;
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
