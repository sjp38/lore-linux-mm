Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id D42896B0265
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 07:36:59 -0500 (EST)
Received: by wmec201 with SMTP id c201so24569521wme.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 04:36:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w9si26422220wjf.245.2015.11.24.04.36.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Nov 2015 04:36:44 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 2/9] mm, page_owner: print symbolic migratetype of both page and pageblock
Date: Tue, 24 Nov 2015 13:36:14 +0100
Message-Id: <1448368581-6923-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1448368581-6923-1-git-send-email-vbabka@suse.cz>
References: <1448368581-6923-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>

The information in /sys/kernel/debug/page_owner includes the migratetype of
the pageblock the page belongs to. This is also checked against the page's
migratetype (as declared by gfp_flags during its allocation), and the page is
reported as Fallback if its migratetype differs from the pageblock's one.

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

Example page_owner entry after the patch:

Page allocated via order 0, mask 0x2420848
PFN 512 type Reclaimable Block 1 type Reclaimable Flags   R  LA
 [<ffffffff81164e8a>] __alloc_pages_nodemask+0x15a/0xa30
 [<ffffffff811ab808>] alloc_pages_current+0x88/0x120
 [<ffffffff8115bc36>] __page_cache_alloc+0xe6/0x120
 [<ffffffff8115c226>] pagecache_get_page+0x56/0x200
 [<ffffffff81205892>] __getblk_slow+0xd2/0x2b0
 [<ffffffff81205ab0>] __getblk_gfp+0x40/0x50
 [<ffffffff81206ad7>] __breadahead+0x17/0x50
 [<ffffffffa0437b27>] __ext4_get_inode_loc+0x397/0x3e0 [ext4]

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/mmzone.h |  3 +++
 mm/page_alloc.c        | 13 +++++++++++++
 mm/page_owner.c        |  6 +++---
 mm/vmstat.c            | 13 -------------
 4 files changed, 19 insertions(+), 16 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 3b6fb71..2bfad18 100644
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
index 35ab351..61a023a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -229,6 +229,19 @@ static char * const zone_names[MAX_NR_ZONES] = {
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
index 983c3a1..f35826e 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -110,11 +110,11 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 	pageblock_mt = get_pfnblock_migratetype(page, pfn);
 	page_mt  = gfpflags_to_migratetype(page_ext->gfp_mask);
 	ret += snprintf(kbuf + ret, count - ret,
-			"PFN %lu Block %lu type %d %s Flags %s%s%s%s%s%s%s%s%s%s%s%s\n",
+			"PFN %lu type %s Block %lu type %s Flags %s%s%s%s%s%s%s%s%s%s%s%s\n",
 			pfn,
+			migratetype_names[page_mt],
 			pfn >> pageblock_order,
-			pageblock_mt,
-			pageblock_mt != page_mt ? "Fallback" : "        ",
+			migratetype_names[pageblock_mt],
 			PageLocked(page)	? "K" : " ",
 			PageError(page)		? "E" : " ",
 			PageReferenced(page)	? "R" : " ",
diff --git a/mm/vmstat.c b/mm/vmstat.c
index f7ebad2..53b722b 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -921,19 +921,6 @@ static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
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
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
