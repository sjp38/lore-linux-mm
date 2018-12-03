Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8D54D6B6B04
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 15:50:49 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id h9so7584515pgm.1
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 12:50:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o19sor19517506pll.44.2018.12.03.12.50.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Dec 2018 12:50:47 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH v4] mm, hotplug: move init_currently_empty_zone() under zone_span_lock protection
Date: Tue,  4 Dec 2018 04:50:16 +0800
Message-Id: <20181203205016.14123-1-richard.weiyang@gmail.com>
In-Reply-To: <20181130065847.13714-1-richard.weiyang@gmail.com>
References: <20181130065847.13714-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, osalvador@suse.de, david@redhat.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

During online_pages phase, pgdat->nr_zones will be updated in case this
zone is empty.

Currently the online_pages phase is protected by the global locks
(device_device_hotplug_lock and mem_hotplug_lock), which ensures there
is no contention during the update of nr_zones.

These global locks introduces scalability issues (especially the second
one), which slow down code relying on get_online_mems(). This is also a
preparation for not having to rely on get_online_mems() but instead some
more fine grained locks.

The patch moves init_currently_empty_zone under both zone_span_writelock
and pgdat_resize_lock because both the pgdat state is changed (nr_zones)
and the zone's start_pfn. Also this patch changes the documentation
of node_size_lock to include the protection of nr_zones.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
CC: David Hildenbrand <david@redhat.com>

---
v4:
  * mention the preparation for improving scalability by David's
    comment
v3:
  * slightly modify the last paragraph of changelog based on Michal's
    comment
v2:
  * commit log changes
  * modify the code in move_pfn_range_to_zone() instead of in
    init_currently_empty_zone()
  * pgdat_resize_lock documentation change
---
 include/linux/mmzone.h | 7 ++++---
 mm/memory_hotplug.c    | 5 ++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 3d0c472438d2..37d9c5c3faa6 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -635,9 +635,10 @@ typedef struct pglist_data {
 #endif
 #if defined(CONFIG_MEMORY_HOTPLUG) || defined(CONFIG_DEFERRED_STRUCT_PAGE_INIT)
 	/*
-	 * Must be held any time you expect node_start_pfn, node_present_pages
-	 * or node_spanned_pages stay constant.  Holding this will also
-	 * guarantee that any pfn_valid() stays that way.
+	 * Must be held any time you expect node_start_pfn,
+	 * node_present_pages, node_spanned_pages or nr_zones stay constant.
+	 * Holding this will also guarantee that any pfn_valid() stays that
+	 * way.
 	 *
 	 * pgdat_resize_lock() and pgdat_resize_unlock() are provided to
 	 * manipulate node_size_lock without checking for CONFIG_MEMORY_HOTPLUG
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 61972da38d93..f626e7e5f57b 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -742,14 +742,13 @@ void __ref move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
 	int nid = pgdat->node_id;
 	unsigned long flags;
 
-	if (zone_is_empty(zone))
-		init_currently_empty_zone(zone, start_pfn, nr_pages);
-
 	clear_zone_contiguous(zone);
 
 	/* TODO Huh pgdat is irqsave while zone is not. It used to be like that before */
 	pgdat_resize_lock(pgdat, &flags);
 	zone_span_writelock(zone);
+	if (zone_is_empty(zone))
+		init_currently_empty_zone(zone, start_pfn, nr_pages);
 	resize_zone_range(zone, start_pfn, nr_pages);
 	zone_span_writeunlock(zone);
 	resize_pgdat_range(pgdat, start_pfn, nr_pages);
-- 
2.15.1
