Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2ED326B005C
	for <linux-mm@kvack.org>; Wed, 20 May 2009 20:23:44 -0400 (EDT)
Received: by mu-out-0910.google.com with SMTP id i10so343411mue.6
        for <linux-mm@kvack.org>; Wed, 20 May 2009 17:24:00 -0700 (PDT)
Date: Thu, 21 May 2009 09:23:37 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH 3/3] reset wmark_min and inactive ratio of zone when hotplug
 happens V2
Message-Id: <20090521092337.bc0f0308.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Changelog since V1 
 o Add Ack-by of Yasunori Goto
 o Modify setup_per_zone_wmarks's comment

This patch solve two problems.

Whenever memory hotplug sucessfully happens, zone->present_pages
have to be changed.

1) Now memory hotplug calls setup_per_zone_wmark_min only when
online_pages called, not offline_pages.

It breaks balance.

2) If zone->present_pages is changed, we also have to change
zone->inactive_ratio. That's because inactive_ratio depends
on zone->present_pages.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Acked-by: Yasunori Goto <y-goto@jp.fujitsu.com>
CC: Rik van Riel <riel@redhat.com>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memory_hotplug.c |    4 ++++
 mm/page_alloc.c     |    2 +-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 037291e..e4412a6 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -423,6 +423,7 @@ int online_pages(unsigned long pfn, unsigned long nr_pages)
 	zone->zone_pgdat->node_present_pages += onlined_pages;
 
 	setup_per_zone_wmarks();
+	calculate_zone_inactive_ratio(zone);
 	if (onlined_pages) {
 		kswapd_run(zone_to_nid(zone));
 		node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
@@ -832,6 +833,9 @@ repeat:
 	totalram_pages -= offlined_pages;
 	num_physpages -= offlined_pages;
 
+	setup_per_zone_wmarks();
+	calculate_zone_inactive_ratio(zone);
+
 	vm_total_pages = nr_free_pagecache_pages();
 	writeback_set_ratelimit();
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f11cfbf..d13f9b5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4472,7 +4472,7 @@ static void setup_per_zone_lowmem_reserve(void)
 
 /**
  * setup_per_zone_wmarks - called when min_free_kbytes changes 
- * or when memory is hot-added
+ * or when memory is hot-{added|removed}
  *
  * Ensures that the watermark[min,low,high] values for each zone are set correctly
  * with respect to min_free_kbytes.
-- 
1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
