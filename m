Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id E86FC6B0254
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 10:29:25 -0400 (EDT)
Received: by ykll84 with SMTP id l84so188189386ykl.0
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 07:29:25 -0700 (PDT)
Received: from m12-16.163.com (m12-16.163.com. [220.181.12.16])
        by mx.google.com with ESMTP id s103si16626448qgs.69.2015.08.26.07.29.23
        for <linux-mm@kvack.org>;
        Wed, 26 Aug 2015 07:29:24 -0700 (PDT)
From: Yaowei Bai <bywxiaobai@163.com>
Subject: [PATCH] mm/page_alloc: remove unused parameter in init_currently_empty_zone()
Date: Wed, 26 Aug 2015 22:26:00 +0800
Message-Id: <1440599160-4156-1-git-send-email-bywxiaobai@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, mhocko@kernel.org, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Commit a2f3aa02576632cdb ("[PATCH] Fix sparsemem on Cell") fixed an oops
experienced on the Cell architecture when init-time functions, early_*(),
are called at runtime by introducing an 'enum memmap_context' parameter
to memmap_init_zone() and init_currently_empty_zone(). This parameter is
intended to be used to tell whether the call of these two functions is
being made on behalf of a hotplug event, or happening at boot-time.
However, init_currently_empty_zone() does not use this parameter at all,
so remove it.

Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
---
 include/linux/mmzone.h | 3 +--
 mm/memory_hotplug.c    | 4 ++--
 mm/page_alloc.c        | 6 ++----
 3 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 754c259..4fdb8e3 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -808,8 +808,7 @@ enum memmap_context {
 	MEMMAP_HOTPLUG,
 };
 extern int init_currently_empty_zone(struct zone *zone, unsigned long start_pfn,
-				     unsigned long size,
-				     enum memmap_context context);
+				     unsigned long size);
 
 extern void lruvec_init(struct lruvec *lruvec);
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 6da82bc..7ae58a5 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -339,8 +339,8 @@ static int __ref ensure_zone_is_initialized(struct zone *zone,
 			unsigned long start_pfn, unsigned long num_pages)
 {
 	if (!zone_is_initialized(zone))
-		return init_currently_empty_zone(zone, start_pfn, num_pages,
-						 MEMMAP_HOTPLUG);
+		return init_currently_empty_zone(zone, start_pfn, num_pages);
+
 	return 0;
 }
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5b5240b..c562d13 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4875,8 +4875,7 @@ static __meminit void zone_pcp_init(struct zone *zone)
 
 int __meminit init_currently_empty_zone(struct zone *zone,
 					unsigned long zone_start_pfn,
-					unsigned long size,
-					enum memmap_context context)
+					unsigned long size)
 {
 	struct pglist_data *pgdat = zone->zone_pgdat;
 	int ret;
@@ -5389,8 +5388,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 
 		set_pageblock_order();
 		setup_usemap(pgdat, zone, zone_start_pfn, size);
-		ret = init_currently_empty_zone(zone, zone_start_pfn,
-						size, MEMMAP_EARLY);
+		ret = init_currently_empty_zone(zone, zone_start_pfn, size);
 		BUG_ON(ret);
 		memmap_init(size, nid, j, zone_start_pfn);
 		zone_start_pfn += size;
-- 
1.9.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
