Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 505D56B0071
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 09:11:27 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9QDAvk7016442
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 26 Oct 2010 22:10:57 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A02945DE52
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 22:10:57 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D34B145DE50
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 22:10:56 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BBA9A1DB8055
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 22:10:56 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DB021DB804D
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 22:10:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/2] mm, mem-hotplug: recalculate lowmem_reserve when memory hotplug occur
Message-Id: <20101026221017.B7DF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 26 Oct 2010 22:10:55 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Currently, memory hotplug call setup_per_zone_wmarks() and
calculate_zone_inactive_ratio(), but don't call setup_per_zone_lowmem_reserve().

It mean number of reserved pages aren't updated even if memory hot plug
occur. This patch fixes it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/mm.h  |    3 +--
 mm/memory_hotplug.c |    9 +++++----
 mm/page_alloc.c     |    6 +++---
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 721f451..71d1670 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1221,8 +1221,7 @@ extern int __meminit __early_pfn_to_nid(unsigned long pfn);
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
index b48dea2..14ee899 100644
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
