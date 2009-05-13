Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EF2986B00B3
	for <linux-mm@kvack.org>; Tue, 12 May 2009 23:06:26 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4D36U2G004779
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 13 May 2009 12:06:30 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BF57645DE62
	for <linux-mm@kvack.org>; Wed, 13 May 2009 12:06:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 67B3745DE57
	for <linux-mm@kvack.org>; Wed, 13 May 2009 12:06:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 43C881DB804A
	for <linux-mm@kvack.org>; Wed, 13 May 2009 12:06:29 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E13F61DB803B
	for <linux-mm@kvack.org>; Wed, 13 May 2009 12:06:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/4] vmscan: change the number of the unmapped files in zone reclaim
In-Reply-To: <20090513120155.5879.A69D9226@jp.fujitsu.com>
References: <20090513120155.5879.A69D9226@jp.fujitsu.com>
Message-Id: <20090513120606.587C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 13 May 2009 12:06:28 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Subject: [PATCH] vmscan: change the number of the unmapped files in zone reclaim

Documentation/sysctl/vm.txt says

	A percentage of the total pages in each zone.  Zone reclaim will only
	occur if more than this percentage of pages are file backed and unmapped.
	This is to insure that a minimal amount of local pages is still available for
	file I/O even if the node is overallocated.

However, zone_page_state(zone, NR_FILE_PAGES) contain some non file backed pages
(e.g. swapcache, buffer-head)

The right calculation is to use NR_{IN}ACTIVE_FILE.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c |   21 ++++++++++++++-------
 1 file changed, 14 insertions(+), 7 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2397,6 +2397,7 @@ static int __zone_reclaim(struct zone *z
 		.isolate_pages = isolate_pages_global,
 	};
 	unsigned long slab_reclaimable;
+	long nr_unmapped_file_pages;
 
 	disable_swap_token();
 	cond_resched();
@@ -2409,9 +2410,11 @@ static int __zone_reclaim(struct zone *z
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	if (zone_page_state(zone, NR_FILE_PAGES) -
-		zone_page_state(zone, NR_FILE_MAPPED) >
-		zone->min_unmapped_pages) {
+	nr_unmapped_file_pages = zone_page_state(zone, NR_INACTIVE_FILE) +
+				 zone_page_state(zone, NR_ACTIVE_FILE) -
+				 zone_page_state(zone, NR_FILE_MAPPED);
+
+	if (nr_unmapped_file_pages > zone->min_unmapped_pages) {
 		/*
 		 * Free memory by calling shrink zone with increasing
 		 * priorities until we have enough memory freed.
@@ -2458,6 +2461,8 @@ int zone_reclaim(struct zone *zone, gfp_
 {
 	int node_id;
 	int ret;
+	long nr_unmapped_file_pages;
+	long nr_slab_reclaimable;
 
 	/*
 	 * Zone reclaim reclaims unmapped file backed pages and
@@ -2469,10 +2474,12 @@ int zone_reclaim(struct zone *zone, gfp_
 	 * if less than a specified percentage of the zone is used by
 	 * unmapped file backed pages.
 	 */
-	if (zone_page_state(zone, NR_FILE_PAGES) -
-	    zone_page_state(zone, NR_FILE_MAPPED) <= zone->min_unmapped_pages
-	    && zone_page_state(zone, NR_SLAB_RECLAIMABLE)
-			<= zone->min_slab_pages)
+	nr_unmapped_file_pages = zone_page_state(zone, NR_INACTIVE_FILE) +
+				 zone_page_state(zone, NR_ACTIVE_FILE) -
+				 zone_page_state(zone, NR_FILE_MAPPED);
+	nr_slab_reclaimable = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
+	if (nr_unmapped_file_pages <= zone->min_unmapped_pages &&
+	    nr_slab_reclaimable <= zone->min_slab_pages)
 		return 0;
 
 	if (zone_is_all_unreclaimable(zone))


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
