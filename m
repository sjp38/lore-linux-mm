Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9F11E6B005A
	for <linux-mm@kvack.org>; Wed, 20 May 2009 03:19:53 -0400 (EDT)
Received: by pxi37 with SMTP id 37so306565pxi.12
        for <linux-mm@kvack.org>; Wed, 20 May 2009 00:20:10 -0700 (PDT)
Date: Wed, 20 May 2009 16:20:01 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH 3/3] reset wmark_min and inactive ratio of zone when hotplug
 happens
Message-Id: <20090520162001.3f3bbe5c.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

This patch solve two problems.

Whenever memory hotplug sucessfully happens, zone->present_pages
have to be changed.

1) Now, memory hotplug calls setup_per_zone_wmark_min only when
online_pages called, not offline_pages.

It breaks balance.

2) If zone->present_pages is changed, we also have to change
zone->inactive_ratio. That's because inactive_ratio depends
on zone->present_pages.

CC: Mel Gorman <mel@csn.ul.ie>
CC: Rik van Riel <riel@redhat.com>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/memory_hotplug.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 40bf385..1611010 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -423,6 +423,7 @@ int online_pages(unsigned long pfn, unsigned long nr_pages)
 	zone->zone_pgdat->node_present_pages += onlined_pages;
 
 	setup_per_zone_wmark_min();
+	calculate_per_zone_inactive_ratio(zone);
 	if (onlined_pages) {
 		kswapd_run(zone_to_nid(zone));
 		node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
@@ -832,6 +833,9 @@ repeat:
 	totalram_pages -= offlined_pages;
 	num_physpages -= offlined_pages;
 
+	setup_per_zone_wmark_min();
+	calculate_per_zone_inactive_ratio(zone);
+
 	vm_total_pages = nr_free_pagecache_pages();
 	writeback_set_ratelimit();
 
-- 
1.5.4.3



-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
