Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 620EB6B0258
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 07:46:39 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id l65so102516853wmf.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 04:46:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n81si4207550wma.24.2016.01.26.04.46.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 04:46:26 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v4 09/14] mm, page_owner: print migratetype of page and pageblock, symbolic flags
Date: Tue, 26 Jan 2016 13:45:48 +0100
Message-Id: <1453812353-26744-10-git-send-email-vbabka@suse.cz>
In-Reply-To: <1453812353-26744-1-git-send-email-vbabka@suse.cz>
References: <1453812353-26744-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>

The information in /sys/kernel/debug/page_owner includes the migratetype of
the pageblock the page belongs to. This is also checked against the page's
migratetype (as declared by gfp_flags during its allocation), and the page is
reported as Fallback if its migratetype differs from the pageblock's one.
t
This is somewhat misleading because in fact fallback allocation is not the only
reason why these two can differ. It also doesn't direcly provide the page's
migratetype, although it's possible to derive that from the gfp_flags.

It's arguably better to print both page and pageblock's migratetype and leave
the interpretation to the consumer than to suggest fallback allocation as the
only possible reason. While at it, we can print the migratetypes as string
the same way as /proc/pagetypeinfo does, as some of the numeric values depend
on kernel configuration. For that, this patch moves the migratetype_names
array from #ifdef CONFIG_PROC_FS part of mm/vmstat.c to mm/page_alloc.c and
exports it.

With the new format strings for flags, we can now also provide symbolic page
and gfp flags in the /sys/kernel/debug/page_owner file. This replaces the
positional printing of page flags as single letters, which might have looked
nicer, but was limited to a subset of flags, and required the user to remember
the letters.

Example page_owner entry after the patch:

Page allocated via order 0, mask 0x24213ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD|__GFP_NOWARN|__GFP_NORETRY)
PFN 520 type Movable Block 1 type Movable Flags 0xfffff8001006c(referenced|uptodate|lru|active|mappedtodisk)
 [<ffffffff811682c4>] __alloc_pages_nodemask+0x134/0x230
 [<ffffffff811b4058>] alloc_pages_current+0x88/0x120
 [<ffffffff8115e386>] __page_cache_alloc+0xe6/0x120
 [<ffffffff8116ba6c>] __do_page_cache_readahead+0xdc/0x240
 [<ffffffff8116bd05>] ondemand_readahead+0x135/0x260
 [<ffffffff8116bfb1>] page_cache_sync_readahead+0x31/0x50
 [<ffffffff81160523>] generic_file_read_iter+0x453/0x760
 [<ffffffff811e0d57>] __vfs_read+0xa7/0xd0

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mmzone.h |  3 +++
 mm/page_alloc.c        | 13 +++++++++++++
 mm/page_owner.c        | 24 +++++++-----------------
 mm/vmstat.c            | 13 -------------
 4 files changed, 23 insertions(+), 30 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 7b6c2cfee390..9fc23ab550a7 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -63,6 +63,9 @@ enum {
 	MIGRATE_TYPES
 };
 
+/* In mm/page_alloc.c; keep in sync also with show_migration_types() there */
+extern char * const migratetype_names[MIGRATE_TYPES];
+
 #ifdef CONFIG_CMA
 #  define is_migrate_cma(migratetype) unlikely((migratetype) == MIGRATE_CMA)
 #else
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f89f51aae9a6..d1f385a37b5c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -223,6 +223,19 @@ static char * const zone_names[MAX_NR_ZONES] = {
 #endif
 };
 
+char * const migratetype_names[MIGRATE_TYPES] = {
+	"Unmovable",
+	"Movable",
+	"Reclaimable",
+	"HighAtomic",
+#ifdef CONFIG_CMA
+	"CMA",
+#endif
+#ifdef CONFIG_MEMORY_ISOLATION
+	"Isolate",
+#endif
+};
+
 compound_page_dtor * const compound_page_dtors[] = {
 	NULL,
 	free_compound_page,
diff --git a/mm/page_owner.c b/mm/page_owner.c
index 983c3a10fa07..7a37a30d941b 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -100,8 +100,9 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 		return -ENOMEM;
 
 	ret = snprintf(kbuf, count,
-			"Page allocated via order %u, mask 0x%x\n",
-			page_ext->order, page_ext->gfp_mask);
+			"Page allocated via order %u, mask %#x(%pGg)\n",
+			page_ext->order, page_ext->gfp_mask,
+			&page_ext->gfp_mask);
 
 	if (ret >= count)
 		goto err;
@@ -110,23 +111,12 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 	pageblock_mt = get_pfnblock_migratetype(page, pfn);
 	page_mt  = gfpflags_to_migratetype(page_ext->gfp_mask);
 	ret += snprintf(kbuf + ret, count - ret,
-			"PFN %lu Block %lu type %d %s Flags %s%s%s%s%s%s%s%s%s%s%s%s\n",
+			"PFN %lu type %s Block %lu type %s Flags %#lx(%pGp)\n",
 			pfn,
+			migratetype_names[page_mt],
 			pfn >> pageblock_order,
-			pageblock_mt,
-			pageblock_mt != page_mt ? "Fallback" : "        ",
-			PageLocked(page)	? "K" : " ",
-			PageError(page)		? "E" : " ",
-			PageReferenced(page)	? "R" : " ",
-			PageUptodate(page)	? "U" : " ",
-			PageDirty(page)		? "D" : " ",
-			PageLRU(page)		? "L" : " ",
-			PageActive(page)	? "A" : " ",
-			PageSlab(page)		? "S" : " ",
-			PageWriteback(page)	? "W" : " ",
-			PageCompound(page)	? "C" : " ",
-			PageSwapCache(page)	? "B" : " ",
-			PageMappedToDisk(page)	? "M" : " ");
+			migratetype_names[pageblock_mt],
+			page->flags, &page->flags);
 
 	if (ret >= count)
 		goto err;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 40b2c74ddf16..5841dd20054f 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -924,19 +924,6 @@ static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
 #endif
 
 #ifdef CONFIG_PROC_FS
-static char * const migratetype_names[MIGRATE_TYPES] = {
-	"Unmovable",
-	"Movable",
-	"Reclaimable",
-	"HighAtomic",
-#ifdef CONFIG_CMA
-	"CMA",
-#endif
-#ifdef CONFIG_MEMORY_ISOLATION
-	"Isolate",
-#endif
-};
-
 static void frag_show_print(struct seq_file *m, pg_data_t *pgdat,
 						struct zone *zone)
 {
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
