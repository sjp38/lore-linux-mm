Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B255E6B00F5
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 02:27:16 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9D6REVp021862
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 13 Oct 2010 15:27:14 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B02B45DE57
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 15:27:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E4AF245DE55
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 15:27:13 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C5AC1E08009
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 15:27:13 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 65F34E08005
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 15:27:13 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH 1/3] mm, mem-hotplug: recalculate lowmem_reserve when memory hotplug occur
In-Reply-To: <20101013151723.ADBD.A69D9226@jp.fujitsu.com>
References: <20101013121913.ADB4.A69D9226@jp.fujitsu.com> <20101013151723.ADBD.A69D9226@jp.fujitsu.com>
Message-Id: <20101013152713.ADC0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 13 Oct 2010 15:27:12 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Currently, memory hotplu call setup_per_zone_wmarks() and
calculate_zone_inactive_ratio(), but don't call setup_per_zone_lowmem_reserve.

It mean number of reserved pages aren't updated even if memory hot plug
occur. This patch fixes it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/mm.h  |    3 +--
 mm/memory_hotplug.c |    9 +++++----
 mm/page_alloc.c     |    6 +++---
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6417c21..4607ec7 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1203,8 +1203,7 @@ extern int __meminit __early_pfn_to_nid(unsigned long pfn);
 extern void set_dma_reserve(unsigned long new_dma_reserve);
 extern void memmap_init_zone(unsigned long, int, unsigned long,
 				unsigned long, enum memmap_context);
-extern void setup_per_zone_wmarks(void);
-extern void calculate_zone_inactive_ratio(struct zone *zone);
+extern int __meminit init_per_zone_wmark_min(void);
 extern void mem_init(void);
 extern void __init mmap_init(void);
 extern void show_mem(void);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d8375bb..27d580d 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -437,8 +437,9 @@ int online_pages(unsigned long pfn, unsigned long nr_pages)
 		zone_pcp_update(zone);
 
 	mutex_unlock(&zonelists_mutex);
-	setup_per_zone_wmarks();
-	calculate_zone_inactive_ratio(zone);
+
+	init_per_zone_wmark_min();
+
 	if (onlined_pages) {
 		kswapd_run(zone_to_nid(zone));
 		node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
@@ -872,8 +873,8 @@ repeat:
 	zone->zone_pgdat->node_present_pages -= offlined_pages;
 	totalram_pages -= offlined_pages;
 
-	setup_per_zone_wmarks();
-	calculate_zone_inactive_ratio(zone);
+	init_per_zone_wmark_min();
+
 	if (!node_present_pages(node)) {
 		node_clear_state(node, N_HIGH_MEMORY);
 		kswapd_stop(node);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 01fa206..6846096 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4880,7 +4880,7 @@ static void setup_per_zone_lowmem_reserve(void)
  * Ensures that the watermark[min,low,high] values for each zone are set
  * correctly with respect to min_free_kbytes.
  */
-void setup_per_zone_wmarks(void)
+static void setup_per_zone_wmarks(void)
 {
 	unsigned long pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
 	unsigned long lowmem_pages = 0;
@@ -4956,7 +4956,7 @@ void setup_per_zone_wmarks(void)
  *    1TB     101        10GB
  *   10TB     320        32GB
  */
-void calculate_zone_inactive_ratio(struct zone *zone)
+static void calculate_zone_inactive_ratio(struct zone *zone)
 {
 	unsigned int gb, ratio;
 
@@ -5002,7 +5002,7 @@ static void __init setup_per_zone_inactive_ratio(void)
  * 8192MB:	11584k
  * 16384MB:	16384k
  */
-static int __init init_per_zone_wmark_min(void)
+int __meminit init_per_zone_wmark_min(void)
 {
 	unsigned long lowmem_kbytes;
 
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
