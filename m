Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3758B6B0288
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:36 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id q185so15492520qke.0
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:36 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u22si636119qte.74.2018.04.04.12.19.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:34 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 78/79] mm/ksm: rename PAGE_MAPPING_KSM to PAGE_MAPPING_RONLY
Date: Wed,  4 Apr 2018 15:18:30 -0400
Message-Id: <20180404191831.5378-41-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

This just rename all KSM specific helper to generic page read only
name. No functional change.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/proc/page.c             |  2 +-
 include/linux/page-flags.h | 30 +++++++++++++++++-------------
 mm/ksm.c                   | 12 ++++++------
 mm/memory-failure.c        |  2 +-
 mm/memory.c                |  2 +-
 mm/migrate.c               |  6 +++---
 mm/mprotect.c              |  2 +-
 mm/page_idle.c             |  2 +-
 mm/rmap.c                  | 10 +++++-----
 mm/swapfile.c              |  2 +-
 10 files changed, 37 insertions(+), 33 deletions(-)

diff --git a/fs/proc/page.c b/fs/proc/page.c
index 1491918a33c3..00cc037758ef 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -110,7 +110,7 @@ u64 stable_page_flags(struct page *page)
 		u |= 1 << KPF_MMAP;
 	if (PageAnon(page))
 		u |= 1 << KPF_ANON;
-	if (PageKsm(page))
+	if (PageReadOnly(page))
 		u |= 1 << KPF_KSM;
 
 	/*
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 50c2b8786831..0338fb5dde8d 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -374,12 +374,12 @@ PAGEFLAG(Idle, idle, PF_ANY)
  * page->mapping points to its anon_vma, not to a struct address_space;
  * with the PAGE_MAPPING_ANON bit set to distinguish it.  See rmap.h.
  *
- * On an anonymous page in a VM_MERGEABLE area, if CONFIG_KSM is enabled,
+ * On an anonymous page in a VM_MERGEABLE area, if CONFIG_RONLY is enabled,
  * the PAGE_MAPPING_MOVABLE bit may be set along with the PAGE_MAPPING_ANON
  * bit; and then page->mapping points, not to an anon_vma, but to a private
- * structure which KSM associates with that merged page.  See ksm.h.
+ * structure which RONLY associates with that merged page.  See page-ronly.h.
  *
- * PAGE_MAPPING_KSM without PAGE_MAPPING_ANON is used for non-lru movable
+ * PAGE_MAPPING_RONLY without PAGE_MAPPING_ANON is used for non-lru movable
  * page and then page->mapping points a struct address_space.
  *
  * Please note that, confusingly, "page_mapping" refers to the inode
@@ -388,7 +388,7 @@ PAGEFLAG(Idle, idle, PF_ANY)
  */
 #define PAGE_MAPPING_ANON	0x1
 #define PAGE_MAPPING_MOVABLE	0x2
-#define PAGE_MAPPING_KSM	(PAGE_MAPPING_ANON | PAGE_MAPPING_MOVABLE)
+#define PAGE_MAPPING_RONLY	(PAGE_MAPPING_ANON | PAGE_MAPPING_MOVABLE)
 #define PAGE_MAPPING_FLAGS	(PAGE_MAPPING_ANON | PAGE_MAPPING_MOVABLE)
 
 static __always_inline int PageMappingFlags(struct page *page)
@@ -408,21 +408,25 @@ static __always_inline int __PageMovable(struct page *page)
 				PAGE_MAPPING_MOVABLE;
 }
 
-#ifdef CONFIG_KSM
-/*
- * A KSM page is one of those write-protected "shared pages" or "merged pages"
- * which KSM maps into multiple mms, wherever identical anonymous page content
- * is found in VM_MERGEABLE vmas.  It's a PageAnon page, pointing not to any
- * anon_vma, but to that page's node of the stable tree.
+#ifdef CONFIG_PAGE_RONLY
+/* PageReadOnly() - Returns true if page is read only, false otherwise.
+ *
+ * @page: Page under test.
+ *
+ * A read only page is one of those write-protected. Currently only KSM does
+ * write protect a page as "shared pages" or "merged pages"  which KSM maps
+ * into multiple mms, wherever identical anonymous page content is found in
+ * VM_MERGEABLE vmas.  It's a PageAnon page, pointing not to any anon_vma,
+ * but to that page's node of the stable tree.
  */
-static __always_inline int PageKsm(struct page *page)
+static __always_inline int PageReadOnly(struct page *page)
 {
 	page = compound_head(page);
 	return ((unsigned long)page->mapping & PAGE_MAPPING_FLAGS) ==
-				PAGE_MAPPING_KSM;
+				PAGE_MAPPING_RONLY;
 }
 #else
-TESTPAGEFLAG_FALSE(Ksm)
+TESTPAGEFLAG_FALSE(ReadOnly)
 #endif
 
 u64 stable_page_flags(struct page *page);
diff --git a/mm/ksm.c b/mm/ksm.c
index f9bd1251c288..6085068fb8b3 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -318,13 +318,13 @@ static void __init ksm_slab_free(void)
 
 static inline struct stable_node *page_stable_node(struct page *page)
 {
-	return PageKsm(page) ? page_rmapping(page) : NULL;
+	return PageReadOnly(page) ? page_rmapping(page) : NULL;
 }
 
 static inline void set_page_stable_node(struct page *page,
 					struct stable_node *stable_node)
 {
-	page->mapping = (void *)((unsigned long)stable_node | PAGE_MAPPING_KSM);
+	page->mapping = (void *)((unsigned long)stable_node | PAGE_MAPPING_RONLY);
 }
 
 static __always_inline bool is_stable_node_chain(struct stable_node *chain)
@@ -470,7 +470,7 @@ static int break_ksm(struct vm_area_struct *vma, unsigned long addr)
 				FOLL_GET | FOLL_MIGRATION | FOLL_REMOTE);
 		if (IS_ERR_OR_NULL(page))
 			break;
-		if (PageKsm(page))
+		if (PageReadOnly(page))
 			ret = handle_mm_fault(vma, addr,
 					FAULT_FLAG_WRITE | FAULT_FLAG_REMOTE);
 		else
@@ -684,7 +684,7 @@ static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
 	unsigned long kpfn;
 
 	expected_mapping = (void *)((unsigned long)stable_node |
-					PAGE_MAPPING_KSM);
+					PAGE_MAPPING_RONLY);
 again:
 	kpfn = READ_ONCE(stable_node->kpfn); /* Address dependency. */
 	page = pfn_to_page(kpfn);
@@ -2490,7 +2490,7 @@ struct page *ksm_might_need_to_copy(struct page *page,
 	struct anon_vma *anon_vma = page_anon_vma(page);
 	struct page *new_page;
 
-	if (PageKsm(page)) {
+	if (PageReadOnly(page)) {
 		if (page_stable_node(page) &&
 		    !(ksm_run & KSM_RUN_UNMERGE))
 			return page;	/* no need to copy it */
@@ -2521,7 +2521,7 @@ void rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc)
 	struct rmap_item *rmap_item;
 	int search_new_forks = 0;
 
-	VM_BUG_ON_PAGE(!PageKsm(page), page);
+	VM_BUG_ON_PAGE(!PageReadOnly(page), page);
 
 	/*
 	 * Rely on the page lock to protect against concurrent modifications
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 8291b75f42c8..18efefc20e67 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -947,7 +947,7 @@ static bool hwpoison_user_mappings(struct page *p, unsigned long pfn,
 	if (!page_mapped(hpage))
 		return true;
 
-	if (PageKsm(p)) {
+	if (PageReadOnly(p)) {
 		pr_err("Memory failure: %#lx: can't handle KSM pages.\n", pfn);
 		return false;
 	}
diff --git a/mm/memory.c b/mm/memory.c
index fbd80bb7a50a..b565db41400f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2733,7 +2733,7 @@ static int do_wp_page(struct vm_fault *vmf)
 	 * Take out anonymous pages first, anonymous shared vmas are
 	 * not dirty accountable.
 	 */
-	if (PageAnon(vmf->page) && !PageKsm(vmf->page)) {
+	if (PageAnon(vmf->page) && !PageReadOnly(vmf->page)) {
 		int total_map_swapcount;
 		if (!trylock_page(vmf->page)) {
 			get_page(vmf->page);
diff --git a/mm/migrate.c b/mm/migrate.c
index e4b20ac6cf36..b73b31f6d2fd 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -214,7 +214,7 @@ static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 
 	VM_BUG_ON_PAGE(PageTail(page), page);
 	while (page_vma_mapped_walk(&pvmw)) {
-		if (PageKsm(page))
+		if (PageReadOnly(page))
 			new = page;
 		else
 			new = page - pvmw.page->index +
@@ -1038,7 +1038,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	 * because that implies that the anon page is no longer mapped
 	 * (and cannot be remapped so long as we hold the page lock).
 	 */
-	if (PageAnon(page) && !PageKsm(page))
+	if (PageAnon(page) && !PageReadOnly(page))
 		anon_vma = page_get_anon_vma(page);
 
 	/*
@@ -1077,7 +1077,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		}
 	} else if (page_mapped(page)) {
 		/* Establish migration ptes */
-		VM_BUG_ON_PAGE(PageAnon(page) && !PageKsm(page) && !anon_vma,
+		VM_BUG_ON_PAGE(PageAnon(page) && !PageReadOnly(page) && !anon_vma,
 				page);
 		try_to_unmap(page,
 			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
diff --git a/mm/mprotect.c b/mm/mprotect.c
index e3309fcf586b..ab2f2e4961d8 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -81,7 +81,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 				struct page *page;
 
 				page = vm_normal_page(vma, addr, oldpte);
-				if (!page || PageKsm(page))
+				if (!page || PageReadOnly(page))
 					continue;
 
 				/* Also skip shared copy-on-write pages */
diff --git a/mm/page_idle.c b/mm/page_idle.c
index 0a49374e6931..7e5258e4d2ad 100644
--- a/mm/page_idle.c
+++ b/mm/page_idle.c
@@ -104,7 +104,7 @@ static void page_idle_clear_pte_refs(struct page *page)
 	    !page_rmapping(page))
 		return;
 
-	need_lock = !PageAnon(page) || PageKsm(page);
+	need_lock = !PageAnon(page) || PageReadOnly(page);
 	if (need_lock && !trylock_page(page))
 		return;
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 822a3a0cd51c..70d37f77e7a4 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -855,7 +855,7 @@ int page_referenced(struct page *page,
 	if (!page_rmapping(page))
 		return 0;
 
-	if (!is_locked && (!PageAnon(page) || PageKsm(page))) {
+	if (!is_locked && (!PageAnon(page) || PageReadOnly(page))) {
 		we_locked = trylock_page(page);
 		if (!we_locked)
 			return 1;
@@ -1122,7 +1122,7 @@ void do_page_add_anon_rmap(struct page *page,
 			__inc_node_page_state(page, NR_ANON_THPS);
 		__mod_node_page_state(page_pgdat(page), NR_ANON_MAPPED, nr);
 	}
-	if (unlikely(PageKsm(page)))
+	if (unlikely(PageReadOnly(page)))
 		return;
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
@@ -1660,7 +1660,7 @@ bool try_to_unmap(struct page *page, enum ttu_flags flags)
 	 * temporary VMAs until after exec() completes.
 	 */
 	if ((flags & (TTU_MIGRATION|TTU_SPLIT_FREEZE))
-	    && !PageKsm(page) && PageAnon(page))
+	    && !PageReadOnly(page) && PageAnon(page))
 		rwc.invalid_vma = invalid_migration_vma;
 
 	if (flags & TTU_RMAP_LOCKED)
@@ -1842,7 +1842,7 @@ static void rmap_walk_file(struct page *page, struct rmap_walk_control *rwc,
 
 void rmap_walk(struct page *page, struct rmap_walk_control *rwc)
 {
-	if (unlikely(PageKsm(page)))
+	if (unlikely(PageReadOnly(page)))
 		rmap_walk_ksm(page, rwc);
 	else if (PageAnon(page))
 		rmap_walk_anon(page, rwc, false);
@@ -1854,7 +1854,7 @@ void rmap_walk(struct page *page, struct rmap_walk_control *rwc)
 void rmap_walk_locked(struct page *page, struct rmap_walk_control *rwc)
 {
 	/* no ksm support for now */
-	VM_BUG_ON_PAGE(PageKsm(page), page);
+	VM_BUG_ON_PAGE(PageReadOnly(page), page);
 	if (PageAnon(page))
 		rmap_walk_anon(page, rwc, true);
 	else
diff --git a/mm/swapfile.c b/mm/swapfile.c
index c429c19e5d5d..83c73cca9e21 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1552,7 +1552,7 @@ bool reuse_swap_page(struct page *page, int *total_map_swapcount)
 	int count, total_mapcount, total_swapcount;
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
-	if (unlikely(PageKsm(page)))
+	if (unlikely(PageReadOnly(page)))
 		return false;
 	count = page_trans_huge_map_swapcount(page, &total_mapcount,
 					      &total_swapcount);
-- 
2.14.3
