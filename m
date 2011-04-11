Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2ED258D003B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 04:00:42 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 65B9A3EE0C0
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 17:00:39 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A4B345DE53
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 17:00:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 238E945DE50
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 17:00:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 170F21DB803F
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 17:00:39 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C5C451DB803B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 17:00:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/3] mm, mem-hotplug: recalculate lowmem_reserve when memory hotplug occur
In-Reply-To: <20110411165957.0352.A69D9226@jp.fujitsu.com>
References: <20110411165957.0352.A69D9226@jp.fujitsu.com>
Message-Id: <20110411170103.035A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 11 Apr 2011 17:00:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>

Currently, memory hotplug call setup_per_zone_wmarks() and
calculate_zone_inactive_ratio(), but don't call setup_per_zone_lowmem_reserve().

It mean number of reserved pages aren't updated even if memory hot plug
occur. This patch fixes it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/mm.h  |    2 +-
 mm/memory_hotplug.c |    9 +++++----
 mm/page_alloc.c     |    4 ++--
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 628b31c..84f1e31 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1357,7 +1357,7 @@ extern void set_dma_reserve(unsigned long new_dma_reserve);
 extern void memmap_init_zone(unsigned long, int, unsigned long,
 				unsigned long, enum memmap_context);
 extern void setup_per_zone_wmarks(void);
-extern void calculate_zone_inactive_ratio(struct zone *zone);
+extern int __meminit init_per_zone_wmark_min(void);
 extern void mem_init(void);
 extern void __init mmap_init(void);
 extern void show_mem(unsigned int flags);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 0419c3d..ba7019e9 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -459,8 +459,9 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
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
@@ -893,8 +894,8 @@ repeat:
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
index 44fae85..ef90a87 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5072,7 +5072,7 @@ void setup_per_zone_wmarks(void)
  *    1TB     101        10GB
  *   10TB     320        32GB
  */
-void __meminit calculate_zone_inactive_ratio(struct zone *zone)
+static void __meminit calculate_zone_inactive_ratio(struct zone *zone)
 {
 	unsigned int gb, ratio;
 
@@ -5118,7 +5118,7 @@ static void __meminit setup_per_zone_inactive_ratio(void)
  * 8192MB:	11584k
  * 16384MB:	16384k
  */
-static int __init init_per_zone_wmark_min(void)
+int __meminit init_per_zone_wmark_min(void)
 {
 	unsigned long lowmem_kbytes;
 
-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
