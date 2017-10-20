Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 050D46B0069
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 04:44:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id h28so9309430pfh.16
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 01:44:10 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id f88si483420pfk.57.2017.10.20.01.44.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 01:44:09 -0700 (PDT)
From: changbin.du@intel.com
Subject: [PATCH v2 1/2] mm, thp: introduce dedicated transparent huge page allocation interfaces
Date: Fri, 20 Oct 2017 16:36:27 +0800
Message-Id: <1508488588-23539-2-git-send-email-changbin.du@intel.com>
In-Reply-To: <1508488588-23539-1-git-send-email-changbin.du@intel.com>
References: <1508488588-23539-1-git-send-email-changbin.du@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, corbet@lwn.net, hughd@google.com
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, khandual@linux.vnet.ibm.com, kirill@shutemov.name, Changbin Du <changbin.du@intel.com>

From: Changbin Du <changbin.du@intel.com>

This patch introduced 4 new interfaces to allocate a prepared
transparent huge page. The aim is to remove duplicated code and
simplify transparent huge page allocation. These are similar to
alloc_hugepage_xxx which are for hugetlbfs pages.
  - alloc_transhuge_page_vma
  - alloc_transhuge_page_nodemask
  - alloc_transhuge_page_node
  - alloc_transhuge_page

These interfaces implicitly add __GFP_COMP gfp mask which is
the minimum flags used for huge page allocation. More flags
leave to the callers.

This patch does below changes:
  - define alloc_transhuge_page_xxx interfaces
  - apply them to all existing code
  - declare prep_transhuge_page as static since no others use it
  - remove alloc_hugepage_vma definition since it no longer has users

Signed-off-by: Changbin Du <changbin.du@intel.com>

---
v2:
Anshuman Khandu:
  - Remove redundant 'VM_BUG_ON(!(gfp_mask & __GFP_COMP))'.
Andrew Morton:
  - Fix build error if thp is disabled.
---
 include/linux/gfp.h     |  4 ----
 include/linux/huge_mm.h | 18 ++++++++++++++++--
 include/linux/migrate.h | 14 +++++---------
 mm/huge_memory.c        | 48 +++++++++++++++++++++++++++++++++++++++++-------
 mm/khugepaged.c         | 11 ++---------
 mm/mempolicy.c          | 14 +++-----------
 mm/migrate.c            | 14 ++++----------
 mm/shmem.c              |  6 ++----
 8 files changed, 73 insertions(+), 56 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index f780718..855c72e 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -507,15 +507,11 @@ alloc_pages(gfp_t gfp_mask, unsigned int order)
 extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
 			struct vm_area_struct *vma, unsigned long addr,
 			int node, bool hugepage);
-#define alloc_hugepage_vma(gfp_mask, vma, addr, order)	\
-	alloc_pages_vma(gfp_mask, order, vma, addr, numa_node_id(), true)
 #else
 #define alloc_pages(gfp_mask, order) \
 		alloc_pages_node(numa_node_id(), gfp_mask, order)
 #define alloc_pages_vma(gfp_mask, order, vma, addr, node, false)\
 	alloc_pages(gfp_mask, order)
-#define alloc_hugepage_vma(gfp_mask, vma, addr, order)	\
-	alloc_pages(gfp_mask, order)
 #endif
 #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
 #define alloc_page_vma(gfp_mask, vma, addr)			\
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 14bc21c..184eb38 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -130,9 +130,20 @@ extern unsigned long thp_get_unmapped_area(struct file *filp,
 		unsigned long addr, unsigned long len, unsigned long pgoff,
 		unsigned long flags);
 
-extern void prep_transhuge_page(struct page *page);
 extern void free_transhuge_page(struct page *page);
 
+extern struct page *alloc_transhuge_page_vma(gfp_t gfp_mask,
+		struct vm_area_struct *vma, unsigned long addr);
+extern struct page *alloc_transhuge_page_nodemask(gfp_t gfp_mask,
+		int preferred_nid, nodemask_t *nmask);
+
+static inline struct page *alloc_transhuge_page_node(int nid, gfp_t gfp_mask)
+{
+	return alloc_transhuge_page_nodemask(gfp_mask, nid, NULL);
+}
+
+extern struct page *alloc_transhuge_page(gfp_t gfp_mask);
+
 bool can_split_huge_page(struct page *page, int *pextra_pins);
 int split_huge_page_to_list(struct page *page, struct list_head *list);
 static inline int split_huge_page(struct page *page)
@@ -260,7 +271,10 @@ static inline bool transparent_hugepage_enabled(struct vm_area_struct *vma)
 	return false;
 }
 
-static inline void prep_transhuge_page(struct page *page) {}
+#define alloc_transhuge_page_vma(gfp_mask, vma, addr) NULL
+#define alloc_transhuge_page_nodemask(gfp_mask, preferred_nid, nmask) NULL
+#define alloc_transhuge_page_node(nid, gfp_maskg) NULL
+#define alloc_transhuge_page(gfp_mask) NULL
 
 #define transparent_hugepage_flags 0UL
 
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 643c7ae..70a00f3 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -42,19 +42,15 @@ static inline struct page *new_page_nodemask(struct page *page,
 		return alloc_huge_page_nodemask(page_hstate(compound_head(page)),
 				preferred_nid, nodemask);
 
-	if (thp_migration_supported() && PageTransHuge(page)) {
-		order = HPAGE_PMD_ORDER;
-		gfp_mask |= GFP_TRANSHUGE;
-	}
-
 	if (PageHighMem(page) || (zone_idx(page_zone(page)) == ZONE_MOVABLE))
 		gfp_mask |= __GFP_HIGHMEM;
 
-	new_page = __alloc_pages_nodemask(gfp_mask, order,
+	if (thp_migration_supported() && PageTransHuge(page))
+		return alloc_transhuge_page_nodemask(gfp_mask | GFP_TRANSHUGE,
+				preferred_nid, nodemask);
+	else
+		return __alloc_pages_nodemask(gfp_mask, order,
 				preferred_nid, nodemask);
-
-	if (new_page && PageTransHuge(page))
-		prep_transhuge_page(new_page);
 
 	return new_page;
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 269b5df..2a960fc 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -490,7 +490,7 @@ static inline struct list_head *page_deferred_list(struct page *page)
 	return (struct list_head *)&page[2].mapping;
 }
 
-void prep_transhuge_page(struct page *page)
+static void prep_transhuge_page(struct page *page)
 {
 	/*
 	 * we use page->mapping and page->indexlru in second tail page
@@ -501,6 +501,43 @@ void prep_transhuge_page(struct page *page)
 	set_compound_page_dtor(page, TRANSHUGE_PAGE_DTOR);
 }
 
+struct page *alloc_transhuge_page_vma(gfp_t gfp_mask,
+		struct vm_area_struct *vma, unsigned long addr)
+{
+	struct page *page;
+
+	page = alloc_pages_vma(gfp_mask | __GFP_COMP, HPAGE_PMD_ORDER,
+			       vma, addr, numa_node_id(), true);
+	if (unlikely(!page))
+		return NULL;
+	prep_transhuge_page(page);
+	return page;
+}
+
+struct page *alloc_transhuge_page_nodemask(gfp_t gfp_mask,
+		int preferred_nid, nodemask_t *nmask)
+{
+	struct page *page;
+
+	page = __alloc_pages_nodemask(gfp_mask | __GFP_COMP, HPAGE_PMD_ORDER,
+				      preferred_nid, nmask);
+	if (unlikely(!page))
+		return NULL;
+	prep_transhuge_page(page);
+	return page;
+}
+
+struct page *alloc_transhuge_page(gfp_t gfp_mask)
+{
+	struct page *page;
+
+	page = alloc_pages(gfp_mask | __GFP_COMP, HPAGE_PMD_ORDER);
+	if (unlikely(!page))
+		return NULL;
+	prep_transhuge_page(page);
+	return page;
+}
+
 unsigned long __thp_get_unmapped_area(struct file *filp, unsigned long len,
 		loff_t off, unsigned long flags, unsigned long size)
 {
@@ -719,12 +756,11 @@ int do_huge_pmd_anonymous_page(struct vm_fault *vmf)
 		return ret;
 	}
 	gfp = alloc_hugepage_direct_gfpmask(vma);
-	page = alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PMD_ORDER);
+	page = alloc_transhuge_page_vma(gfp, vma, haddr);
 	if (unlikely(!page)) {
 		count_vm_event(THP_FAULT_FALLBACK);
 		return VM_FAULT_FALLBACK;
 	}
-	prep_transhuge_page(page);
 	return __do_huge_pmd_anonymous_page(vmf, page, gfp);
 }
 
@@ -1288,13 +1324,11 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 	if (transparent_hugepage_enabled(vma) &&
 	    !transparent_hugepage_debug_cow()) {
 		huge_gfp = alloc_hugepage_direct_gfpmask(vma);
-		new_page = alloc_hugepage_vma(huge_gfp, vma, haddr, HPAGE_PMD_ORDER);
+		new_page = alloc_transhuge_page_vma(huge_gfp, vma, haddr);
 	} else
 		new_page = NULL;
 
-	if (likely(new_page)) {
-		prep_transhuge_page(new_page);
-	} else {
+	if (unlikely(!new_page)) {
 		if (!page) {
 			split_huge_pmd(vma, vmf->pmd, vmf->address);
 			ret |= VM_FAULT_FALLBACK;
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index c01f177..d17a694 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -745,14 +745,13 @@ khugepaged_alloc_page(struct page **hpage, gfp_t gfp, int node)
 {
 	VM_BUG_ON_PAGE(*hpage, *hpage);
 
-	*hpage = __alloc_pages_node(node, gfp, HPAGE_PMD_ORDER);
+	*hpage = alloc_transhuge_page_node(node, gfp);
 	if (unlikely(!*hpage)) {
 		count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
 		*hpage = ERR_PTR(-ENOMEM);
 		return NULL;
 	}
 
-	prep_transhuge_page(*hpage);
 	count_vm_event(THP_COLLAPSE_ALLOC);
 	return *hpage;
 }
@@ -764,13 +763,7 @@ static int khugepaged_find_target_node(void)
 
 static inline struct page *alloc_khugepaged_hugepage(void)
 {
-	struct page *page;
-
-	page = alloc_pages(alloc_hugepage_khugepaged_gfpmask(),
-			   HPAGE_PMD_ORDER);
-	if (page)
-		prep_transhuge_page(page);
-	return page;
+	return alloc_transhuge_page(alloc_hugepage_khugepaged_gfpmask());
 }
 
 static struct page *khugepaged_alloc_hugepage(bool *wait)
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index a2af6d5..4c34914 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -949,12 +949,8 @@ static struct page *new_node_page(struct page *page, unsigned long node, int **x
 	else if (thp_migration_supported() && PageTransHuge(page)) {
 		struct page *thp;
 
-		thp = alloc_pages_node(node,
-			(GFP_TRANSHUGE | __GFP_THISNODE),
-			HPAGE_PMD_ORDER);
-		if (!thp)
-			return NULL;
-		prep_transhuge_page(thp);
+		thp = alloc_transhuge_page_node(node,
+			(GFP_TRANSHUGE | __GFP_THISNODE));
 		return thp;
 	} else
 		return __alloc_pages_node(node, GFP_HIGHUSER_MOVABLE |
@@ -1125,11 +1121,7 @@ static struct page *new_page(struct page *page, unsigned long start, int **x)
 	} else if (thp_migration_supported() && PageTransHuge(page)) {
 		struct page *thp;
 
-		thp = alloc_hugepage_vma(GFP_TRANSHUGE, vma, address,
-					 HPAGE_PMD_ORDER);
-		if (!thp)
-			return NULL;
-		prep_transhuge_page(thp);
+		thp = alloc_transhuge_page_vma(GFP_TRANSHUGE, vma, address);
 		return thp;
 	}
 	/*
diff --git a/mm/migrate.c b/mm/migrate.c
index e00814c..97c7150 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1472,12 +1472,8 @@ static struct page *new_page_node(struct page *p, unsigned long private,
 	else if (thp_migration_supported() && PageTransHuge(p)) {
 		struct page *thp;
 
-		thp = alloc_pages_node(pm->node,
-			(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM,
-			HPAGE_PMD_ORDER);
-		if (!thp)
-			return NULL;
-		prep_transhuge_page(thp);
+		thp = alloc_transhuge_page_node(pm->node,
+			(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM);
 		return thp;
 	} else
 		return __alloc_pages_node(pm->node,
@@ -2017,12 +2013,10 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	if (numamigrate_update_ratelimit(pgdat, HPAGE_PMD_NR))
 		goto out_dropref;
 
-	new_page = alloc_pages_node(node,
-		(GFP_TRANSHUGE_LIGHT | __GFP_THISNODE),
-		HPAGE_PMD_ORDER);
+	new_page = alloc_transhuge_page_node(node,
+			(GFP_TRANSHUGE_LIGHT | __GFP_THISNODE));
 	if (!new_page)
 		goto out_fail;
-	prep_transhuge_page(new_page);
 
 	isolated = numamigrate_isolate_page(pgdat, page);
 	if (!isolated) {
diff --git a/mm/shmem.c b/mm/shmem.c
index 07a1d22..52468f7 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1444,11 +1444,9 @@ static struct page *shmem_alloc_hugepage(gfp_t gfp,
 	rcu_read_unlock();
 
 	shmem_pseudo_vma_init(&pvma, info, hindex);
-	page = alloc_pages_vma(gfp | __GFP_COMP | __GFP_NORETRY | __GFP_NOWARN,
-			HPAGE_PMD_ORDER, &pvma, 0, numa_node_id(), true);
+	gfp |= __GFP_COMP | __GFP_NORETRY | __GFP_NOWARN;
+	page = alloc_transhuge_page_vma(gfp, &pvma, 0);
 	shmem_pseudo_vma_destroy(&pvma);
-	if (page)
-		prep_transhuge_page(page);
 	return page;
 }
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
