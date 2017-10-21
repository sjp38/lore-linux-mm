Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id A82AC6B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 21:17:29 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id d67so12168566qkg.3
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 18:17:29 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id z1si1758643qkf.342.2017.10.20.18.17.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 18:17:28 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v1] mm: broken deferred calculation
Date: Fri, 20 Oct 2017 21:17:07 -0400
Message-Id: <20171021011707.15191-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, mhocko@kernel.org, akpm@linux-foundation.org

In reset_deferred_meminit we determine number of pages that must not be
deferred. We initialize pages for at least 2G of memory, but also pages for
reserved memory in this node.

The reserved memory is determined in this function:
memblock_reserved_memory_within(), which operates over physical addresses,
and returns size in bytes. However, reset_deferred_meminit() assumes that
that this function operates with pfns, and returns page count.

The result is that in the best case machine boots slower than expected
due to initializing more pages than needed in single thread, and in the
worst case panics because fewer than needed pages are initialized early.

Fixes: 864b9a393dcb ("mm: consider memblock reservations for deferred memory initialization sizing")

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 include/linux/mmzone.h |  3 ++-
 mm/page_alloc.c        | 27 ++++++++++++++++++---------
 2 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index a6f361931d52..d45ba78c7e42 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -699,7 +699,8 @@ typedef struct pglist_data {
 	 * is the first PFN that needs to be initialised.
 	 */
 	unsigned long first_deferred_pfn;
-	unsigned long static_init_size;
+	/* Number of non-deferred pages */
+	unsigned long static_init_pgcnt;
 #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 97687b38da05..16419cdbbb7a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -289,28 +289,37 @@ EXPORT_SYMBOL(nr_online_nodes);
 int page_group_by_mobility_disabled __read_mostly;
 
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+
+/*
+ * Determine how many pages need to be initialized durig early boot
+ * (non-deferred initialization).
+ * The value of first_deferred_pfn will be set later, once non-deferred pages
+ * are initialized, but for now set it ULONG_MAX.
+ */
 static inline void reset_deferred_meminit(pg_data_t *pgdat)
 {
-	unsigned long max_initialise;
-	unsigned long reserved_lowmem;
+	phys_addr_t start_addr, end_addr;
+	unsigned long max_pgcnt;
+	unsigned long reserved;
 
 	/*
 	 * Initialise at least 2G of a node but also take into account that
 	 * two large system hashes that can take up 1GB for 0.25TB/node.
 	 */
-	max_initialise = max(2UL << (30 - PAGE_SHIFT),
-		(pgdat->node_spanned_pages >> 8));
+	max_pgcnt = max(2UL << (30 - PAGE_SHIFT),
+			(pgdat->node_spanned_pages >> 8));
 
 	/*
 	 * Compensate the all the memblock reservations (e.g. crash kernel)
 	 * from the initial estimation to make sure we will initialize enough
 	 * memory to boot.
 	 */
-	reserved_lowmem = memblock_reserved_memory_within(pgdat->node_start_pfn,
-			pgdat->node_start_pfn + max_initialise);
-	max_initialise += reserved_lowmem;
+	start_addr = PFN_PHYS(pgdat->node_start_pfn);
+	end_addr = PFN_PHYS(pgdat->node_start_pfn + max_pgcnt);
+	reserved = memblock_reserved_memory_within(start_addr, end_addr);
+	max_pgcnt += PHYS_PFN(reserved);
 
-	pgdat->static_init_size = min(max_initialise, pgdat->node_spanned_pages);
+	pgdat->static_init_pgcnt = min(max_pgcnt, pgdat->node_spanned_pages);
 	pgdat->first_deferred_pfn = ULONG_MAX;
 }
 
@@ -337,7 +346,7 @@ static inline bool update_defer_init(pg_data_t *pgdat,
 	if (zone_end < pgdat_end_pfn(pgdat))
 		return true;
 	(*nr_initialised)++;
-	if ((*nr_initialised > pgdat->static_init_size) &&
+	if ((*nr_initialised > pgdat->static_init_pgcnt) &&
 	    (pfn & (PAGES_PER_SECTION - 1)) == 0) {
 		pgdat->first_deferred_pfn = pfn;
 		return false;
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
