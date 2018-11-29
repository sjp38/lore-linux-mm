Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id E674C6B535D
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 10:53:38 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id q62so1422642pgq.9
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 07:53:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 37sor3117472ple.23.2018.11.29.07.53.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 29 Nov 2018 07:53:37 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH v3 1/2] mm, sparse: drop pgdat_resize_lock in sparse_add/remove_one_section()
Date: Thu, 29 Nov 2018 23:53:15 +0800
Message-Id: <20181129155316.8174-1-richard.weiyang@gmail.com>
In-Reply-To: <20181128091243.19249-1-richard.weiyang@gmail.com>
References: <20181128091243.19249-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, dave.hansen@intel.com, osalvador@suse.de, david@redhat.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

pgdat_resize_lock is used to protect pgdat's memory region information
like: node_start_pfn, node_present_pages, etc. While in function
sparse_add/remove_one_section(), pgdat_resize_lock is used to protect
initialization/release of one mem_section. This looks not proper.

Based on current implementation, even remove this lock, mem_section
is still away from contention, because it is protected by global
mem_hotpulg_lock.

Following is the current call trace of sparse_add/remove_one_section()

    mem_hotplug_begin()
    arch_add_memory()
       add_pages()
           __add_pages()
               __add_section()
                   sparse_add_one_section()
    mem_hotplug_done()

    mem_hotplug_begin()
    arch_remove_memory()
        __remove_pages()
            __remove_section()
                sparse_remove_one_section()
    mem_hotplug_done()

The comment above the pgdat_resize_lock also mentions "Holding this will
also guarantee that any pfn_valid() stays that way.", which is true with
the current implementation and false after this patch. But current
implementation doesn't meet this comment. There isn't any pfn walkers
to take the lock so this looks like a relict from the past. This patch
also removes this comment.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

---
v3:
   * adjust the changelog with the reason for this change
   * remove a comment for pgdat_resize_lock
   * separate the prototype change of sparse_add_one_section() to
     another one
v2:
   * adjust changelog to show this procedure is serialized by global
     mem_hotplug_lock
---
 include/linux/mmzone.h | 2 --
 mm/sparse.c            | 9 +--------
 2 files changed, 1 insertion(+), 10 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 1bb749bee284..0a66085d7ced 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -638,8 +638,6 @@ typedef struct pglist_data {
 	/*
 	 * Must be held any time you expect node_start_pfn,
 	 * node_present_pages, node_spanned_pages or nr_zones stay constant.
-	 * Holding this will also guarantee that any pfn_valid() stays that
-	 * way.
 	 *
 	 * pgdat_resize_lock() and pgdat_resize_unlock() are provided to
 	 * manipulate node_size_lock without checking for CONFIG_MEMORY_HOTPLUG
diff --git a/mm/sparse.c b/mm/sparse.c
index 33307fc05c4d..5825f276485f 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -669,7 +669,6 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat,
 	struct mem_section *ms;
 	struct page *memmap;
 	unsigned long *usemap;
-	unsigned long flags;
 	int ret;
 
 	/*
@@ -689,8 +688,6 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat,
 		return -ENOMEM;
 	}
 
-	pgdat_resize_lock(pgdat, &flags);
-
 	ms = __pfn_to_section(start_pfn);
 	if (ms->section_mem_map & SECTION_MARKED_PRESENT) {
 		ret = -EEXIST;
@@ -707,7 +704,6 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat,
 	sparse_init_one_section(ms, section_nr, memmap, usemap);
 
 out:
-	pgdat_resize_unlock(pgdat, &flags);
 	if (ret < 0) {
 		kfree(usemap);
 		__kfree_section_memmap(memmap, altmap);
@@ -769,10 +765,8 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
 		unsigned long map_offset, struct vmem_altmap *altmap)
 {
 	struct page *memmap = NULL;
-	unsigned long *usemap = NULL, flags;
-	struct pglist_data *pgdat = zone->zone_pgdat;
+	unsigned long *usemap = NULL;
 
-	pgdat_resize_lock(pgdat, &flags);
 	if (ms->section_mem_map) {
 		usemap = ms->pageblock_flags;
 		memmap = sparse_decode_mem_map(ms->section_mem_map,
@@ -780,7 +774,6 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
 		ms->section_mem_map = 0;
 		ms->pageblock_flags = NULL;
 	}
-	pgdat_resize_unlock(pgdat, &flags);
 
 	clear_hwpoisoned_pages(memmap + map_offset,
 			PAGES_PER_SECTION - map_offset);
-- 
2.15.1
