Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 31D0F6B2B0B
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 05:13:09 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id s22so2238151pgv.8
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 02:13:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g5sor16891686pgl.1.2018.11.22.02.13.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Nov 2018 02:13:07 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH v2] mm, hotplug: move init_currently_empty_zone() under zone_span_lock protection
Date: Thu, 22 Nov 2018 18:12:41 +0800
Message-Id: <20181122101241.7965-1-richard.weiyang@gmail.com>
In-Reply-To: <20181120014822.27968-1-richard.weiyang@gmail.com>
References: <20181120014822.27968-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, osalvador@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

During online_pages phase, pgdat->nr_zones will be updated in case this
zone is empty.

Currently the online_pages phase is protected by the global lock
mem_hotplug_begin(), which ensures there is no contention during the
update of nr_zones. But this global lock introduces scalability issues.

This patch is a preparation for removing the global lock during
online_pages phase. Also this patch changes the documentation of
node_size_lock to include the protectioin of nr_zones.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
v2:
  * commit log changes
  * modify the code in move_pfn_range_to_zone() instead of in
    init_currently_empty_zone()
  * documentation change

---
 include/linux/mmzone.h | 7 ++++---
 mm/memory_hotplug.c    | 5 ++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 68d7b558924b..1bb749bee284 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -636,9 +636,10 @@ typedef struct pglist_data {
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
