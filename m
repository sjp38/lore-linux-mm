Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 68F8D6B026A
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 10:22:54 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id d4-v6so8875396pfn.9
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 07:22:54 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id u16-v6si1438203pgv.409.2018.06.26.07.22.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jun 2018 07:22:52 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 04/18] mm/page_alloc: Handle allocation for encrypted memory
Date: Tue, 26 Jun 2018 17:22:31 +0300
Message-Id: <20180626142245.82850-5-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
References: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For encrypted memory, we need to allocate pages for a specific
encryption KeyID.

There are two cases when we need to allocate a page for encryption:

 - Allocation for an encrypted VMA;

 - Allocation for migration of encrypted page;

The first case can be covered within alloc_page_vma(). We know KeyID
from the VMA.

The second case requires few new page allocation routines that would
allocate the page for a specific KeyID.

An encrypted page has to be cleared after KeyID set. This is handled
in prep_encrypted_page() that will be provided by arch-specific code.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/gfp.h     | 48 ++++++++++++++++++++++++++++++++++++-----
 include/linux/migrate.h | 12 ++++++++---
 mm/compaction.c         |  1 +
 mm/mempolicy.c          | 28 ++++++++++++++++++------
 mm/migrate.c            |  4 ++--
 mm/page_alloc.c         | 47 ++++++++++++++++++++++++++++++++++++++++
 6 files changed, 123 insertions(+), 17 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 66f395737990..347a40558cfc 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -446,16 +446,46 @@ static inline void arch_free_page(struct page *page, int order) { }
 static inline void arch_alloc_page(struct page *page, int order) { }
 #endif
 
+#ifndef prep_encrypted_page
+static inline void prep_encrypted_page(struct page *page, int order,
+		int keyid, bool zero)
+{
+}
+#endif
+
+/*
+ * Encrypted page has to be cleared once keyid is set, not on allocation.
+ */
+static inline bool encrypted_page_needs_zero(int keyid, gfp_t *gfp_mask)
+{
+	if (!keyid)
+		return false;
+
+	if (*gfp_mask & __GFP_ZERO) {
+		*gfp_mask &= ~__GFP_ZERO;
+		return true;
+	}
+
+	return false;
+}
+
 struct page *
 __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
 							nodemask_t *nodemask);
 
+struct page *
+__alloc_pages_nodemask_keyid(gfp_t gfp_mask, unsigned int order,
+		int preferred_nid, nodemask_t *nodemask, int keyid);
+
 static inline struct page *
 __alloc_pages(gfp_t gfp_mask, unsigned int order, int preferred_nid)
 {
 	return __alloc_pages_nodemask(gfp_mask, order, preferred_nid, NULL);
 }
 
+struct page *__alloc_pages_node_keyid(int nid, int keyid,
+		gfp_t gfp_mask, unsigned int order);
+
 /*
  * Allocate pages, preferring the node given as nid. The node must be valid and
  * online. For more general interface, see alloc_pages_node().
@@ -483,6 +513,19 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 	return __alloc_pages_node(nid, gfp_mask, order);
 }
 
+static inline struct page *alloc_pages_node_keyid(int nid, int keyid,
+		gfp_t gfp_mask, unsigned int order)
+{
+	if (nid == NUMA_NO_NODE)
+		nid = numa_mem_id();
+
+	return __alloc_pages_node_keyid(nid, keyid, gfp_mask, order);
+}
+
+extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
+			struct vm_area_struct *vma, unsigned long addr,
+			int node, bool hugepage);
+
 #ifdef CONFIG_NUMA
 extern struct page *alloc_pages_current(gfp_t gfp_mask, unsigned order);
 
@@ -491,14 +534,9 @@ alloc_pages(gfp_t gfp_mask, unsigned int order)
 {
 	return alloc_pages_current(gfp_mask, order);
 }
-extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
-			struct vm_area_struct *vma, unsigned long addr,
-			int node, bool hugepage);
 #else
 #define alloc_pages(gfp_mask, order) \
 		alloc_pages_node(numa_node_id(), gfp_mask, order)
-#define alloc_pages_vma(gfp_mask, order, vma, addr, node, false)\
-	alloc_pages(gfp_mask, order)
 #endif
 #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
 #define alloc_page_vma(gfp_mask, vma, addr)			\
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index f2b4abbca55e..fede9bfa89d9 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -38,9 +38,15 @@ static inline struct page *new_page_nodemask(struct page *page,
 	unsigned int order = 0;
 	struct page *new_page = NULL;
 
-	if (PageHuge(page))
+	if (PageHuge(page)) {
+		/*
+		 * HugeTLB doesn't support encryption. We shouldn't see
+		 * such pages.
+		 */
+		WARN_ON(page_keyid(page));
 		return alloc_huge_page_nodemask(page_hstate(compound_head(page)),
 				preferred_nid, nodemask);
+	}
 
 	if (PageTransHuge(page)) {
 		gfp_mask |= GFP_TRANSHUGE;
@@ -50,8 +56,8 @@ static inline struct page *new_page_nodemask(struct page *page,
 	if (PageHighMem(page) || (zone_idx(page_zone(page)) == ZONE_MOVABLE))
 		gfp_mask |= __GFP_HIGHMEM;
 
-	new_page = __alloc_pages_nodemask(gfp_mask, order,
-				preferred_nid, nodemask);
+	new_page = __alloc_pages_nodemask_keyid(gfp_mask, order,
+				preferred_nid, nodemask, page_keyid(page));
 
 	if (new_page && PageTransHuge(new_page))
 		prep_transhuge_page(new_page);
diff --git a/mm/compaction.c b/mm/compaction.c
index faca45ebe62d..fd51aa32ad96 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1187,6 +1187,7 @@ static struct page *compaction_alloc(struct page *migratepage,
 	list_del(&freepage->lru);
 	cc->nr_freepages--;
 
+	prep_encrypted_page(freepage, 0, page_keyid(migratepage), false);
 	return freepage;
 }
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 9ac49ef17b4e..b0fc42642f8f 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -920,22 +920,28 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
 /* page allocation callback for NUMA node migration */
 struct page *alloc_new_node_page(struct page *page, unsigned long node)
 {
-	if (PageHuge(page))
+	if (PageHuge(page)) {
+		/*
+		 * HugeTLB doesn't support encryption. We shouldn't see
+		 * such pages.
+		 */
+		WARN_ON(page_keyid(page));
 		return alloc_huge_page_node(page_hstate(compound_head(page)),
 					node);
-	else if (PageTransHuge(page)) {
+	} else if (PageTransHuge(page)) {
 		struct page *thp;
 
-		thp = alloc_pages_node(node,
+		thp = alloc_pages_node_keyid(node, page_keyid(page),
 			(GFP_TRANSHUGE | __GFP_THISNODE),
 			HPAGE_PMD_ORDER);
 		if (!thp)
 			return NULL;
 		prep_transhuge_page(thp);
 		return thp;
-	} else
-		return __alloc_pages_node(node, GFP_HIGHUSER_MOVABLE |
-						    __GFP_THISNODE, 0);
+	} else {
+		return __alloc_pages_node_keyid(node, page_keyid(page),
+				GFP_HIGHUSER_MOVABLE | __GFP_THISNODE, 0);
+	}
 }
 
 /*
@@ -2012,9 +2018,16 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 {
 	struct mempolicy *pol;
 	struct page *page;
-	int preferred_nid;
+	bool zero = false;
+	int keyid, preferred_nid;
 	nodemask_t *nmask;
 
+	keyid = vma_keyid(vma);
+	if (keyid && (gfp & __GFP_ZERO)) {
+		zero = true;
+		gfp &= ~__GFP_ZERO;
+	}
+
 	pol = get_vma_policy(vma, addr);
 
 	if (pol->mode == MPOL_INTERLEAVE) {
@@ -2057,6 +2070,7 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 	page = __alloc_pages_nodemask(gfp, order, preferred_nid, nmask);
 	mpol_cond_put(pol);
 out:
+	prep_encrypted_page(page, order, keyid, zero);
 	return page;
 }
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 8c0af0f7cab1..eb8dea219dcb 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1847,7 +1847,7 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
 	int nid = (int) data;
 	struct page *newpage;
 
-	newpage = __alloc_pages_node(nid,
+	newpage = __alloc_pages_node_keyid(nid, page_keyid(page),
 					 (GFP_HIGHUSER_MOVABLE |
 					  __GFP_THISNODE | __GFP_NOMEMALLOC |
 					  __GFP_NORETRY | __GFP_NOWARN) &
@@ -2030,7 +2030,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	if (numamigrate_update_ratelimit(pgdat, HPAGE_PMD_NR))
 		goto out_dropref;
 
-	new_page = alloc_pages_node(node,
+	new_page = alloc_pages_node_keyid(node, page_keyid(page),
 		(GFP_TRANSHUGE_LIGHT | __GFP_THISNODE),
 		HPAGE_PMD_ORDER);
 	if (!new_page)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1521100f1e63..aae5fdb235ac 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3697,6 +3697,39 @@ should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_fla
 }
 #endif /* CONFIG_COMPACTION */
 
+#ifndef CONFIG_NUMA
+struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
+		struct vm_area_struct *vma, unsigned long addr,
+		int node, bool hugepage)
+{
+	struct page *page;
+	bool need_zero;
+	int keyid = vma_keyid(vma);
+
+	need_zero = encrypted_page_needs_zero(keyid, &gfp_mask);
+	page = alloc_pages(gfp_mask, order);
+	prep_encrypted_page(page, order, keyid, need_zero);
+
+	return page;
+}
+#endif
+
+struct page * __alloc_pages_node_keyid(int nid, int keyid,
+		gfp_t gfp_mask, unsigned int order)
+{
+	struct page *page;
+	bool need_zero;
+
+	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
+	VM_WARN_ON(!node_online(nid));
+
+	need_zero = encrypted_page_needs_zero(keyid, &gfp_mask);
+	page = __alloc_pages(gfp_mask, order, nid);
+	prep_encrypted_page(page, order, keyid, need_zero);
+
+	return page;
+}
+
 #ifdef CONFIG_LOCKDEP
 static struct lockdep_map __fs_reclaim_map =
 	STATIC_LOCKDEP_MAP_INIT("fs_reclaim", &__fs_reclaim_map);
@@ -4401,6 +4434,20 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
 }
 EXPORT_SYMBOL(__alloc_pages_nodemask);
 
+struct page *
+__alloc_pages_nodemask_keyid(gfp_t gfp_mask, unsigned int order,
+		int preferred_nid, nodemask_t *nodemask, int keyid)
+{
+	struct page *page;
+	bool need_zero;
+
+	need_zero = encrypted_page_needs_zero(keyid, &gfp_mask);
+	page = __alloc_pages_nodemask(gfp_mask, order, preferred_nid, nodemask);
+	prep_encrypted_page(page, order, keyid, need_zero);
+	return page;
+}
+EXPORT_SYMBOL(__alloc_pages_nodemask_keyid);
+
 /*
  * Common helper functions.
  */
-- 
2.18.0
