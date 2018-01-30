Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5BEB96B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 00:06:52 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id z15so4615668qti.16
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 21:06:52 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n8si3537888qte.288.2018.01.29.21.06.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jan 2018 21:06:50 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0U56Kc0146837
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 00:06:49 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fte2409x6-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 00:06:49 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 30 Jan 2018 05:06:47 -0000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC] mm/migrate: Consolidate page allocation helper functions
Date: Tue, 30 Jan 2018 10:36:42 +0530
Message-Id: <20180130050642.19834-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, mhocko@suse.com

Allocation helper functions for migrate_pages() remmain scattered with
similar names making them really confusing. Rename these functions based
on the context for the migration and move them all into common migration
header. Functionality remains unchanged.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
- Based on earlier discussion (https://lkml.org/lkml/2018/1/3/128)
- Wondering if we can still further factorize these helpers functions

 include/linux/migrate.h        | 112 ++++++++++++++++++++++++++++++++++++++++-
 include/linux/page-isolation.h |   2 -
 mm/internal.h                  |   1 -
 mm/memory-failure.c            |  11 +---
 mm/memory_hotplug.c            |  19 +------
 mm/mempolicy.c                 |  69 +------------------------
 mm/migrate.c                   |  19 +------
 mm/page_alloc.c                |   2 +-
 mm/page_isolation.c            |   4 --
 9 files changed, 119 insertions(+), 120 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 0c6fe904bc97..a732598fcf83 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -3,6 +3,7 @@
 #define _LINUX_MIGRATE_H
 
 #include <linux/mm.h>
+#include <linux/rmap.h>
 #include <linux/mempolicy.h>
 #include <linux/migrate_mode.h>
 #include <linux/hugetlb.h>
@@ -31,6 +32,84 @@ enum migrate_reason {
 /* In mm/debug.c; also keep sync with include/trace/events/migrate.h */
 extern char *migrate_reason_names[MR_TYPES];
 
+#ifdef CONFIG_MIGRATION
+/*
+ * Allocate a new page for page migration based on vma policy.
+ * Start by assuming the page is mapped by the same vma as contains @start.
+ * Search forward from there, if not.  N.B., this assumes that the
+ * list of pages handed to migrate_pages()--which is how we get here--
+ * is in virtual address order.
+ */
+static inline struct page *new_page_alloc_mbind(struct page *page, unsigned long start)
+{
+	struct vm_area_struct *vma;
+	unsigned long uninitialized_var(address);
+
+	vma = find_vma(current->mm, start);
+	while (vma) {
+		address = page_address_in_vma(page, vma);
+		if (address != -EFAULT)
+			break;
+		vma = vma->vm_next;
+	}
+
+	if (PageHuge(page)) {
+		return alloc_huge_page_vma(page_hstate(compound_head(page)),
+				vma, address);
+	} else if (PageTransHuge(page)) {
+		struct page *thp;
+
+		thp = alloc_hugepage_vma(GFP_TRANSHUGE, vma, address,
+					 HPAGE_PMD_ORDER);
+		if (!thp)
+			return NULL;
+		prep_transhuge_page(thp);
+		return thp;
+	}
+	/*
+	 * if !vma, alloc_page_vma() will use task or system default policy
+	 */
+	return alloc_page_vma(GFP_HIGHUSER_MOVABLE | __GFP_RETRY_MAYFAIL,
+			vma, address);
+}
+
+/* page allocation callback for NUMA node migration */
+static inline struct page *new_page_alloc_syscall(struct page *page, unsigned long node)
+{
+	if (PageHuge(page))
+		return alloc_huge_page_node(page_hstate(compound_head(page)),
+					node);
+	else if (PageTransHuge(page)) {
+		struct page *thp;
+
+		thp = alloc_pages_node(node,
+			(GFP_TRANSHUGE | __GFP_THISNODE),
+			HPAGE_PMD_ORDER);
+		if (!thp)
+			return NULL;
+		prep_transhuge_page(thp);
+		return thp;
+	} else
+		return __alloc_pages_node(node, GFP_HIGHUSER_MOVABLE |
+						    __GFP_THISNODE, 0);
+}
+
+
+static inline struct page *new_page_alloc_misplaced(struct page *page,
+					   unsigned long data)
+{
+	int nid = (int) data;
+	struct page *newpage;
+
+	newpage = __alloc_pages_node(nid,
+					 (GFP_HIGHUSER_MOVABLE |
+					  __GFP_THISNODE | __GFP_NOMEMALLOC |
+					  __GFP_NORETRY | __GFP_NOWARN) &
+					 ~__GFP_RECLAIM, 0);
+
+	return newpage;
+}
+
 static inline struct page *new_page_nodemask(struct page *page,
 				int preferred_nid, nodemask_t *nodemask)
 {
@@ -59,7 +138,34 @@ static inline struct page *new_page_nodemask(struct page *page,
 	return new_page;
 }
 
-#ifdef CONFIG_MIGRATION
+static inline struct page *new_page_alloc_failure(struct page *p, unsigned long private)
+{
+	int nid = page_to_nid(p);
+
+	return new_page_nodemask(p, nid, &node_states[N_MEMORY]);
+}
+
+/*
+ * Try to allocate from a different node but reuse this node if there
+ * are no other online nodes to be used (e.g. we are offlining a part
+ * of the only existing node).
+ */
+static inline struct page *new_page_alloc_hotplug(struct page *page, unsigned long private)
+{
+	int nid = page_to_nid(page);
+	nodemask_t nmask = node_states[N_MEMORY];
+
+	node_clear(nid, nmask);
+	if (nodes_empty(nmask))
+		node_set(nid, nmask);
+
+	return new_page_nodemask(page, nid, &nmask);
+}
+
+static inline struct page *new_page_alloc_contig(struct page *page, unsigned long private)
+{
+	return new_page_nodemask(page, numa_node_id(), &node_states[N_MEMORY]);
+}
 
 extern void putback_movable_pages(struct list_head *l);
 extern int migrate_page(struct address_space *mapping,
@@ -81,6 +187,10 @@ extern int migrate_page_move_mapping(struct address_space *mapping,
 		struct buffer_head *head, enum migrate_mode mode,
 		int extra_count);
 #else
+static inline struct page *new_page_alloc_mbind(struct page *page, unsigned long start)
+{
+	return NULL;
+}
 
 static inline void putback_movable_pages(struct list_head *l) {}
 static inline int migrate_pages(struct list_head *l, new_page_t new,
diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 4ae347cbc36d..8e816995ba04 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -63,6 +63,4 @@ undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 			bool skip_hwpoisoned_pages);
 
-struct page *alloc_migrate_target(struct page *page, unsigned long private);
-
 #endif
diff --git a/mm/internal.h b/mm/internal.h
index 62d8c34e63d5..3e5dc95dc259 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -540,5 +540,4 @@ static inline bool is_migrate_highatomic_page(struct page *page)
 }
 
 void setup_zone_pageset(struct zone *zone);
-extern struct page *alloc_new_node_page(struct page *page, unsigned long node);
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index d530ac1db680..adab1a57f3c3 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1483,13 +1483,6 @@ int unpoison_memory(unsigned long pfn)
 }
 EXPORT_SYMBOL(unpoison_memory);
 
-static struct page *new_page(struct page *p, unsigned long private)
-{
-	int nid = page_to_nid(p);
-
-	return new_page_nodemask(p, nid, &node_states[N_MEMORY]);
-}
-
 /*
  * Safely get reference count of an arbitrary page.
  * Returns 0 for a free page, -EIO for a zero refcount page
@@ -1584,7 +1577,7 @@ static int soft_offline_huge_page(struct page *page, int flags)
 		return -EBUSY;
 	}
 
-	ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
+	ret = migrate_pages(&pagelist, new_page_alloc_failure, NULL, MPOL_MF_MOVE_ALL,
 				MIGRATE_SYNC, MR_MEMORY_FAILURE);
 	if (ret) {
 		pr_info("soft offline: %#lx: hugepage migration failed %d, type %lx (%pGp)\n",
@@ -1662,7 +1655,7 @@ static int __soft_offline_page(struct page *page, int flags)
 			inc_node_page_state(page, NR_ISOLATED_ANON +
 						page_is_file_cache(page));
 		list_add(&page->lru, &pagelist);
-		ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
+		ret = migrate_pages(&pagelist, new_page_alloc_failure, NULL, MPOL_MF_MOVE_ALL,
 					MIGRATE_SYNC, MR_MEMORY_FAILURE);
 		if (ret) {
 			if (!list_empty(&pagelist))
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 25060b0184e9..d3e4263acdd6 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1344,23 +1344,6 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
 	return 0;
 }
 
-static struct page *new_node_page(struct page *page, unsigned long private)
-{
-	int nid = page_to_nid(page);
-	nodemask_t nmask = node_states[N_MEMORY];
-
-	/*
-	 * try to allocate from a different node but reuse this node if there
-	 * are no other online nodes to be used (e.g. we are offlining a part
-	 * of the only existing node)
-	 */
-	node_clear(nid, nmask);
-	if (nodes_empty(nmask))
-		node_set(nid, nmask);
-
-	return new_page_nodemask(page, nid, &nmask);
-}
-
 #define NR_OFFLINE_AT_ONCE_PAGES	(256)
 static int
 do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
@@ -1431,7 +1414,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 		}
 
 		/* Allocate a new page from the nearest neighbor node */
-		ret = migrate_pages(&source, new_node_page, NULL, 0,
+		ret = migrate_pages(&source, new_page_alloc_hotplug, NULL, 0,
 					MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
 		if (ret)
 			putback_movable_pages(&source);
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index a8b7d59002e8..0344a412c5e5 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -917,27 +917,6 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
 	}
 }
 
-/* page allocation callback for NUMA node migration */
-struct page *alloc_new_node_page(struct page *page, unsigned long node)
-{
-	if (PageHuge(page))
-		return alloc_huge_page_node(page_hstate(compound_head(page)),
-					node);
-	else if (PageTransHuge(page)) {
-		struct page *thp;
-
-		thp = alloc_pages_node(node,
-			(GFP_TRANSHUGE | __GFP_THISNODE),
-			HPAGE_PMD_ORDER);
-		if (!thp)
-			return NULL;
-		prep_transhuge_page(thp);
-		return thp;
-	} else
-		return __alloc_pages_node(node, GFP_HIGHUSER_MOVABLE |
-						    __GFP_THISNODE, 0);
-}
-
 /*
  * Migrate pages from one node to a target node.
  * Returns error or the number of pages not migrated.
@@ -962,7 +941,7 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
 			flags | MPOL_MF_DISCONTIG_OK, &pagelist);
 
 	if (!list_empty(&pagelist)) {
-		err = migrate_pages(&pagelist, alloc_new_node_page, NULL, dest,
+		err = migrate_pages(&pagelist, new_page_alloc_syscall, NULL, dest,
 					MIGRATE_SYNC, MR_SYSCALL);
 		if (err)
 			putback_movable_pages(&pagelist);
@@ -1076,45 +1055,6 @@ int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
 
 }
 
-/*
- * Allocate a new page for page migration based on vma policy.
- * Start by assuming the page is mapped by the same vma as contains @start.
- * Search forward from there, if not.  N.B., this assumes that the
- * list of pages handed to migrate_pages()--which is how we get here--
- * is in virtual address order.
- */
-static struct page *new_page(struct page *page, unsigned long start)
-{
-	struct vm_area_struct *vma;
-	unsigned long uninitialized_var(address);
-
-	vma = find_vma(current->mm, start);
-	while (vma) {
-		address = page_address_in_vma(page, vma);
-		if (address != -EFAULT)
-			break;
-		vma = vma->vm_next;
-	}
-
-	if (PageHuge(page)) {
-		return alloc_huge_page_vma(page_hstate(compound_head(page)),
-				vma, address);
-	} else if (PageTransHuge(page)) {
-		struct page *thp;
-
-		thp = alloc_hugepage_vma(GFP_TRANSHUGE, vma, address,
-					 HPAGE_PMD_ORDER);
-		if (!thp)
-			return NULL;
-		prep_transhuge_page(thp);
-		return thp;
-	}
-	/*
-	 * if !vma, alloc_page_vma() will use task or system default policy
-	 */
-	return alloc_page_vma(GFP_HIGHUSER_MOVABLE | __GFP_RETRY_MAYFAIL,
-			vma, address);
-}
 #else
 
 static void migrate_page_add(struct page *page, struct list_head *pagelist,
@@ -1127,11 +1067,6 @@ int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
 {
 	return -ENOSYS;
 }
-
-static struct page *new_page(struct page *page, unsigned long start)
-{
-	return NULL;
-}
 #endif
 
 static long do_mbind(unsigned long start, unsigned long len,
@@ -1213,7 +1148,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 
 		if (!list_empty(&pagelist)) {
 			WARN_ON_ONCE(flags & MPOL_MF_LAZY);
-			nr_failed = migrate_pages(&pagelist, new_page, NULL,
+			nr_failed = migrate_pages(&pagelist, new_page_alloc_mbind, NULL,
 				start, MIGRATE_SYNC, MR_MEMPOLICY_MBIND);
 			if (nr_failed)
 				putback_movable_pages(&pagelist);
diff --git a/mm/migrate.c b/mm/migrate.c
index 5d0dc7b85f90..8685fb384139 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1465,7 +1465,7 @@ static int do_move_pages_to_node(struct mm_struct *mm,
 	if (list_empty(pagelist))
 		return 0;
 
-	err = migrate_pages(pagelist, alloc_new_node_page, NULL, node,
+	err = migrate_pages(pagelist, new_page_alloc_syscall, NULL, node,
 			MIGRATE_SYNC, MR_SYSCALL);
 	if (err)
 		putback_movable_pages(pagelist);
@@ -1796,21 +1796,6 @@ static bool migrate_balanced_pgdat(struct pglist_data *pgdat,
 	return false;
 }
 
-static struct page *alloc_misplaced_dst_page(struct page *page,
-					   unsigned long data)
-{
-	int nid = (int) data;
-	struct page *newpage;
-
-	newpage = __alloc_pages_node(nid,
-					 (GFP_HIGHUSER_MOVABLE |
-					  __GFP_THISNODE | __GFP_NOMEMALLOC |
-					  __GFP_NORETRY | __GFP_NOWARN) &
-					 ~__GFP_RECLAIM, 0);
-
-	return newpage;
-}
-
 /*
  * page migration rate limiting control.
  * Do not migrate more than @pages_to_migrate in a @migrate_interval_millisecs
@@ -1929,7 +1914,7 @@ int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
 		goto out;
 
 	list_add(&page->lru, &migratepages);
-	nr_remaining = migrate_pages(&migratepages, alloc_misplaced_dst_page,
+	nr_remaining = migrate_pages(&migratepages, new_page_alloc_misplaced,
 				     NULL, node, MIGRATE_ASYNC,
 				     MR_NUMA_MISPLACED);
 	if (nr_remaining) {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6129f989223a..242565855d05 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7621,7 +7621,7 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
 							&cc->migratepages);
 		cc->nr_migratepages -= nr_reclaimed;
 
-		ret = migrate_pages(&cc->migratepages, alloc_migrate_target,
+		ret = migrate_pages(&cc->migratepages, new_page_alloc_contig,
 				    NULL, 0, cc->mode, MR_CMA);
 	}
 	if (ret < 0) {
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 53d801235e22..276e180272f0 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -293,7 +293,3 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 	return pfn < end_pfn ? -EBUSY : 0;
 }
 
-struct page *alloc_migrate_target(struct page *page, unsigned long private)
-{
-	return new_page_nodemask(page, numa_node_id(), &node_states[N_MEMORY]);
-}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
