Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A812E6B000C
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 10:39:26 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id z11-v6so6583350pfn.1
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 07:39:26 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id d191-v6si257904pga.192.2018.06.12.07.39.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 07:39:24 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 04/17] mm/page_alloc: Handle allocation for encrypted memory
Date: Tue, 12 Jun 2018 17:39:02 +0300
Message-Id: <20180612143915.68065-5-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For encrypted memory, we need to allocated pages for a specific
encryption KeyID.

There are two cases when we need to allocate a page for encryption:

 - Allocation for an encrypted VMA;

 - Allocation for migration of encrypted page;

The first case can be covered within alloc_page_vma().

The second case requires few new page allocation routines that would
allocate the page for a specific KeyID.

Encrypted page has to be cleared after KeyID set. This is handled by
prep_encrypted_page() that will be provided by arch-specific code.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/alpha/include/asm/page.h |  2 +-
 include/linux/gfp.h           | 38 ++++++++++++++++-----
 include/linux/migrate.h       |  8 +++--
 mm/compaction.c               |  4 +++
 mm/mempolicy.c                | 25 ++++++++++----
 mm/migrate.c                  |  4 +--
 mm/page_alloc.c               | 63 +++++++++++++++++++++++++++++++++++
 7 files changed, 122 insertions(+), 22 deletions(-)

diff --git a/arch/alpha/include/asm/page.h b/arch/alpha/include/asm/page.h
index f3fb2848470a..9a6fbb5269f3 100644
--- a/arch/alpha/include/asm/page.h
+++ b/arch/alpha/include/asm/page.h
@@ -18,7 +18,7 @@ extern void clear_page(void *page);
 #define clear_user_page(page, vaddr, pg)	clear_page(page)
 
 #define __alloc_zeroed_user_highpage(movableflags, vma, vaddr) \
-	alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO | movableflags, vma, vmaddr)
+	alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO | movableflags, vma, vaddr)
 #define __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
 
 extern void copy_page(void * _to, void * _from);
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index fc5ab85278d5..59d607d135e9 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -446,16 +446,30 @@ static inline void arch_free_page(struct page *page, int order) { }
 static inline void arch_alloc_page(struct page *page, int order) { }
 #endif
 
+#ifndef prep_encrypted_page
+static inline void prep_encrypted_page(struct page *page, int order,
+		int keyid, bool zero)
+{
+}
+#endif
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
@@ -483,6 +497,19 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
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
 
@@ -491,24 +518,17 @@ alloc_pages(gfp_t gfp_mask, unsigned int order)
 {
 	return alloc_pages_current(gfp_mask, order);
 }
-extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
-			struct vm_area_struct *vma, unsigned long addr,
-			int node, bool hugepage);
-#define alloc_hugepage_vma(gfp_mask, vma, addr, order)	\
-	alloc_pages_vma(gfp_mask, order, vma, addr, numa_node_id(), true)
 #else
 #define alloc_pages(gfp_mask, order) \
 		alloc_pages_node(numa_node_id(), gfp_mask, order)
-#define alloc_pages_vma(gfp_mask, order, vma, addr, node, false)\
-	alloc_pages(gfp_mask, order)
-#define alloc_hugepage_vma(gfp_mask, vma, addr, order)	\
-	alloc_pages(gfp_mask, order)
 #endif
 #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
 #define alloc_page_vma(gfp_mask, vma, addr)			\
 	alloc_pages_vma(gfp_mask, 0, vma, addr, numa_node_id(), false)
 #define alloc_page_vma_node(gfp_mask, vma, addr, node)		\
 	alloc_pages_vma(gfp_mask, 0, vma, addr, node, false)
+#define alloc_hugepage_vma(gfp_mask, vma, addr, order) \
+	alloc_pages_vma(gfp_mask, order, vma, addr, numa_node_id(), true)
 
 extern unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
 extern unsigned long get_zeroed_page(gfp_t gfp_mask);
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index f2b4abbca55e..6da504bad841 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -38,9 +38,11 @@ static inline struct page *new_page_nodemask(struct page *page,
 	unsigned int order = 0;
 	struct page *new_page = NULL;
 
-	if (PageHuge(page))
+	if (PageHuge(page)) {
+		WARN_ON(page_keyid(page));
 		return alloc_huge_page_nodemask(page_hstate(compound_head(page)),
 				preferred_nid, nodemask);
+	}
 
 	if (PageTransHuge(page)) {
 		gfp_mask |= GFP_TRANSHUGE;
@@ -50,8 +52,8 @@ static inline struct page *new_page_nodemask(struct page *page,
 	if (PageHighMem(page) || (zone_idx(page_zone(page)) == ZONE_MOVABLE))
 		gfp_mask |= __GFP_HIGHMEM;
 
-	new_page = __alloc_pages_nodemask(gfp_mask, order,
-				preferred_nid, nodemask);
+	new_page = __alloc_pages_nodemask_keyid(gfp_mask, order,
+				preferred_nid, nodemask, page_keyid(page));
 
 	if (new_page && PageTransHuge(new_page))
 		prep_transhuge_page(new_page);
diff --git a/mm/compaction.c b/mm/compaction.c
index 29bd1df18b98..55261e634c34 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1170,6 +1170,7 @@ static struct page *compaction_alloc(struct page *migratepage,
 {
 	struct compact_control *cc = (struct compact_control *)data;
 	struct page *freepage;
+	int keyid;
 
 	/*
 	 * Isolate free pages if necessary, and if we are not aborting due to
@@ -1187,6 +1188,9 @@ static struct page *compaction_alloc(struct page *migratepage,
 	list_del(&freepage->lru);
 	cc->nr_freepages--;
 
+	keyid = page_keyid(migratepage);
+	if (keyid)
+		prep_encrypted_page(freepage, 0, keyid, false);
 	return freepage;
 }
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 9ac49ef17b4e..00bccbececea 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -920,22 +920,24 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
 /* page allocation callback for NUMA node migration */
 struct page *alloc_new_node_page(struct page *page, unsigned long node)
 {
-	if (PageHuge(page))
+	if (PageHuge(page)) {
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
@@ -2012,9 +2014,16 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 {
 	struct mempolicy *pol;
 	struct page *page;
-	int preferred_nid;
+	bool zero = false;
+	int keyid, preferred_nid;
 	nodemask_t *nmask;
 
+	keyid = vma_keyid(vma);
+	if (keyid && gfp & __GFP_ZERO) {
+		zero = true;
+		gfp &= ~__GFP_ZERO;
+	}
+
 	pol = get_vma_policy(vma, addr);
 
 	if (pol->mode == MPOL_INTERLEAVE) {
@@ -2057,6 +2066,8 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 	page = __alloc_pages_nodemask(gfp, order, preferred_nid, nmask);
 	mpol_cond_put(pol);
 out:
+	if (page && keyid)
+		prep_encrypted_page(page, order, keyid, zero);
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
index 22320ea27489..472286b0553f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3700,6 +3700,49 @@ should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_fla
 }
 #endif /* CONFIG_COMPACTION */
 
+#ifndef CONFIG_NUMA
+struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
+		struct vm_area_struct *vma, unsigned long addr,
+		int node, bool hugepage)
+{
+	struct page *page;
+	bool zero = false;
+	int keyid = vma_keyid(vma);
+
+	if (keyid && (gfp_mask & __GFP_ZERO)) {
+		zero = true;
+		gfp_mask &= ~__GFP_ZERO;
+	}
+
+	page = alloc_pages(gfp_mask, order);
+	if (page && keyid)
+		prep_encrypted_page(page, order, keyid, zero);
+
+	return page;
+}
+#endif
+
+struct page * __alloc_pages_node_keyid(int nid, int keyid,
+		gfp_t gfp_mask, unsigned int order)
+{
+	struct page *page;
+	bool zero = false;
+
+	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
+	VM_WARN_ON(!node_online(nid));
+
+	if (keyid && (gfp_mask & __GFP_ZERO)) {
+		zero = true;
+		gfp_mask &= ~__GFP_ZERO;
+	}
+
+	page = __alloc_pages(gfp_mask, order, nid);
+	if (page && keyid)
+		prep_encrypted_page(page, order, keyid, zero);
+
+	return page;
+}
+
 #ifdef CONFIG_LOCKDEP
 struct lockdep_map __fs_reclaim_map =
 	STATIC_LOCKDEP_MAP_INIT("fs_reclaim", &__fs_reclaim_map);
@@ -4396,6 +4439,26 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
 }
 EXPORT_SYMBOL(__alloc_pages_nodemask);
 
+struct page *
+__alloc_pages_nodemask_keyid(gfp_t gfp_mask, unsigned int order,
+		int preferred_nid, nodemask_t *nodemask, int keyid)
+{
+	struct page *page;
+	bool zero = false;
+
+	if (keyid && (gfp_mask & __GFP_ZERO)) {
+		zero = true;
+		gfp_mask &= ~__GFP_ZERO;
+	}
+
+	page = __alloc_pages_nodemask(gfp_mask, order,
+			preferred_nid, nodemask);
+	if (page && keyid)
+		prep_encrypted_page(page, order, keyid, zero);
+	return page;
+}
+EXPORT_SYMBOL(__alloc_pages_nodemask_keyid);
+
 /*
  * Common helper functions.
  */
-- 
2.17.1
