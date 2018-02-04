Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 810976B0005
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 01:58:27 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id w74so19476279qka.21
        for <linux-mm@kvack.org>; Sat, 03 Feb 2018 22:58:27 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x38si1700126qta.254.2018.02.03.22.58.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Feb 2018 22:58:26 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w146rrAl106578
	for <linux-mm@kvack.org>; Sun, 4 Feb 2018 01:58:25 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2fwun3tmaw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 04 Feb 2018 01:58:25 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Sun, 4 Feb 2018 06:58:23 -0000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH] mm/migrate: Rename various page allocation helper functions
Date: Sun,  4 Feb 2018 12:28:16 +0530
Message-Id: <20180204065816.6885-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, hughd@google.com

Allocation helper functions for migrate_pages() remmain scattered with
similar names making them really confusing. Rename these functions based
on type of the intended migration. Function alloc_misplaced_dst_page()
remains unchanged as its highly specialized. The renamed functions are
listed below. Functionality of migration remains unchanged.

1. alloc_migrate_target -> new_page_alloc
2. new_node_page -> new_page_alloc_othernode
3. new_page -> new_page_alloc_keepnode
4. alloc_new_node_page -> new_page_alloc_node
5. new_page -> new_page_alloc_mempolicy

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
- Just renamed these function as suggested
- Previous RFC discussions (https://patchwork.kernel.org/patch/10191331/)

 include/linux/page-isolation.h |  2 +-
 mm/internal.h                  |  2 +-
 mm/memory-failure.c            | 11 ++++++-----
 mm/memory_hotplug.c            |  5 +++--
 mm/mempolicy.c                 | 15 +++++++++------
 mm/migrate.c                   |  2 +-
 mm/page_alloc.c                |  2 +-
 mm/page_isolation.c            |  2 +-
 8 files changed, 23 insertions(+), 18 deletions(-)

diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 4ae347cbc36d..2e77a88a37fc 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -63,6 +63,6 @@ undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 			bool skip_hwpoisoned_pages);
 
-struct page *alloc_migrate_target(struct page *page, unsigned long private);
+struct page *new_page_alloc(struct page *page, unsigned long private);
 
 #endif
diff --git a/mm/internal.h b/mm/internal.h
index 62d8c34e63d5..ef03f0eed209 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -540,5 +540,5 @@ static inline bool is_migrate_highatomic_page(struct page *page)
 }
 
 void setup_zone_pageset(struct zone *zone);
-extern struct page *alloc_new_node_page(struct page *page, unsigned long node);
+extern struct page *new_page_alloc_node(struct page *page, unsigned long node);
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 264e020ef60c..30789042e3cd 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1499,7 +1499,8 @@ int unpoison_memory(unsigned long pfn)
 }
 EXPORT_SYMBOL(unpoison_memory);
 
-static struct page *new_page(struct page *p, unsigned long private)
+static struct page *new_page_alloc_keepnode(struct page *p,
+					unsigned long private)
 {
 	int nid = page_to_nid(p);
 
@@ -1600,8 +1601,8 @@ static int soft_offline_huge_page(struct page *page, int flags)
 		return -EBUSY;
 	}
 
-	ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
-				MIGRATE_SYNC, MR_MEMORY_FAILURE);
+	ret = migrate_pages(&pagelist, new_page_alloc_keepnode, NULL,
+			MPOL_MF_MOVE_ALL, MIGRATE_SYNC, MR_MEMORY_FAILURE);
 	if (ret) {
 		pr_info("soft offline: %#lx: hugepage migration failed %d, type %lx (%pGp)\n",
 			pfn, ret, page->flags, &page->flags);
@@ -1678,8 +1679,8 @@ static int __soft_offline_page(struct page *page, int flags)
 			inc_node_page_state(page, NR_ISOLATED_ANON +
 						page_is_file_cache(page));
 		list_add(&page->lru, &pagelist);
-		ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
-					MIGRATE_SYNC, MR_MEMORY_FAILURE);
+		ret = migrate_pages(&pagelist, new_page_alloc_keepnode, NULL,
+			MPOL_MF_MOVE_ALL, MIGRATE_SYNC, MR_MEMORY_FAILURE);
 		if (ret) {
 			if (!list_empty(&pagelist))
 				putback_movable_pages(&pagelist);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 6a9bee33ffa7..f1dc28f5057e 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1341,7 +1341,8 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
 	return 0;
 }
 
-static struct page *new_node_page(struct page *page, unsigned long private)
+static struct page *new_page_alloc_othernode(struct page *page,
+					unsigned long private)
 {
 	int nid = page_to_nid(page);
 	nodemask_t nmask = node_states[N_MEMORY];
@@ -1428,7 +1429,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 		}
 
 		/* Allocate a new page from the nearest neighbor node */
-		ret = migrate_pages(&source, new_node_page, NULL, 0,
+		ret = migrate_pages(&source, new_page_alloc_othernode, NULL, 0,
 					MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
 		if (ret)
 			putback_movable_pages(&source);
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index a8b7d59002e8..fd3fd1de9b3d 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -918,7 +918,7 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
 }
 
 /* page allocation callback for NUMA node migration */
-struct page *alloc_new_node_page(struct page *page, unsigned long node)
+struct page *new_page_alloc_node(struct page *page, unsigned long node)
 {
 	if (PageHuge(page))
 		return alloc_huge_page_node(page_hstate(compound_head(page)),
@@ -962,7 +962,7 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
 			flags | MPOL_MF_DISCONTIG_OK, &pagelist);
 
 	if (!list_empty(&pagelist)) {
-		err = migrate_pages(&pagelist, alloc_new_node_page, NULL, dest,
+		err = migrate_pages(&pagelist, new_page_alloc_node, NULL, dest,
 					MIGRATE_SYNC, MR_SYSCALL);
 		if (err)
 			putback_movable_pages(&pagelist);
@@ -1083,7 +1083,8 @@ int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
  * list of pages handed to migrate_pages()--which is how we get here--
  * is in virtual address order.
  */
-static struct page *new_page(struct page *page, unsigned long start)
+static struct page *new_page_alloc_mempolicy(struct page *page,
+					unsigned long start)
 {
 	struct vm_area_struct *vma;
 	unsigned long uninitialized_var(address);
@@ -1128,7 +1129,8 @@ int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
 	return -ENOSYS;
 }
 
-static struct page *new_page(struct page *page, unsigned long start)
+static struct page *new_page_alloc_mempolicy(struct page *page,
+					unsigned long start)
 {
 	return NULL;
 }
@@ -1213,8 +1215,9 @@ static long do_mbind(unsigned long start, unsigned long len,
 
 		if (!list_empty(&pagelist)) {
 			WARN_ON_ONCE(flags & MPOL_MF_LAZY);
-			nr_failed = migrate_pages(&pagelist, new_page, NULL,
-				start, MIGRATE_SYNC, MR_MEMPOLICY_MBIND);
+			nr_failed = migrate_pages(&pagelist,
+				new_page_alloc_mempolicy, NULL, start,
+				MIGRATE_SYNC, MR_MEMPOLICY_MBIND);
 			if (nr_failed)
 				putback_movable_pages(&pagelist);
 		}
diff --git a/mm/migrate.c b/mm/migrate.c
index 5d0dc7b85f90..c39e73fa9223 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1465,7 +1465,7 @@ static int do_move_pages_to_node(struct mm_struct *mm,
 	if (list_empty(pagelist))
 		return 0;
 
-	err = migrate_pages(pagelist, alloc_new_node_page, NULL, node,
+	err = migrate_pages(pagelist, new_page_alloc_node, NULL, node,
 			MIGRATE_SYNC, MR_SYSCALL);
 	if (err)
 		putback_movable_pages(pagelist);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e2b42f603b1a..ea4609275b67 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7622,7 +7622,7 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
 							&cc->migratepages);
 		cc->nr_migratepages -= nr_reclaimed;
 
-		ret = migrate_pages(&cc->migratepages, alloc_migrate_target,
+		ret = migrate_pages(&cc->migratepages, new_page_alloc,
 				    NULL, 0, cc->mode, MR_CMA);
 	}
 	if (ret < 0) {
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 53d801235e22..345c7b1bea99 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -293,7 +293,7 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 	return pfn < end_pfn ? -EBUSY : 0;
 }
 
-struct page *alloc_migrate_target(struct page *page, unsigned long private)
+struct page *new_page_alloc(struct page *page, unsigned long private)
 {
 	return new_page_nodemask(page, numa_node_id(), &node_states[N_MEMORY]);
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
