Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9BC776B00A4
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 23:16:31 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n693Ttfk031795
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 9 Jul 2009 12:29:55 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 564FE45DE52
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 12:29:55 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0AAAD45DD76
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 12:29:55 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D894DE18007
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 12:29:54 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 729161DB803F
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 12:29:53 +0900 (JST)
Date: Thu, 9 Jul 2009 12:28:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 2/2] ZERO PAGE by pte_special
Message-Id: <20090709122801.21806c01.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090709122428.8c2d4232.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090709122428.8c2d4232.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, npiggin@suse.de, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, avi@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, torvalds@linux-foundation.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

ZERO_PAGE for anonymous private mapping is useful when an application
requires large continuous memory but write sparsely or some other usages.
It was removed in 2.6.24 but this patch tries to re-add it.
(Because there are some use cases..)

In past, ZERO_PAGE was removed because heavy cache line contention in
ZERO_PAGE's refcounting, this version of ZERO_PAGE avoid to refcnt it.
Then, implementation is changed as following.

  - Use of ZERO_PAGE is limited to PRIVATE mapping. Then, VM_MAYSHARE is
    checked as VM_SHARED.

  - pte_special(), _PAGE_SPECIAL bit in pte is used for indicating ZERO_PAGE.

  - vm_normal_page() eats one more flag as "ignore_zero". If ignore_zero != 0,
    NULL is returned even if ZERO_PAGE is found.

  - __get_user_pages() eats one more flag as GUP_FLAGS_IGNORE_ZERO. If set,
    __get_user_page() returns NULL even if ZERO_PAGE is found.

  - follow_page eats one more flag as FOLL_NOZERO. If set, follow_page()
    returns NULL even if ZERO_PAGE is found.

Usual overheads of this patch is...
  - One if() in do_anonymous_page().
  - 3 if() in __get_user_pages()
  - One argument to vm_normal_page()

Note:
  - no changes to get_user_pages(). ZERO_PAGE can be returned when
    vma is ANONYMOUS && PRIVATE and the access is READ.

Changelog v2->v3
 - totally renewed.
 - use pte_special()
 - added new argument to vm_normal_page().
 - MAYSHARE is checked.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/proc/task_mmu.c |    8 +--
 include/linux/mm.h |    3 -
 mm/fremap.c        |    3 -
 mm/internal.h      |    1 
 mm/memory.c        |  136 +++++++++++++++++++++++++++++++++++++++++------------
 mm/mempolicy.c     |    8 +--
 mm/migrate.c       |    6 +-
 mm/mlock.c         |    2 
 mm/rmap.c          |    6 +-
 9 files changed, 129 insertions(+), 44 deletions(-)

Index: zeropage-trialv3/mm/memory.c
===================================================================
--- zeropage-trialv3.orig/mm/memory.c
+++ zeropage-trialv3/mm/memory.c
@@ -442,6 +442,27 @@ static inline int is_cow_mapping(unsigne
 }
 
 /*
+ * Can we use ZERO_PAGE at fault ? or Can we do the FOLL_ANON optimization ?
+ */
+static inline int use_zero_page(struct vm_area_struct *vma)
+{
+	/*
+	 * We don't want to optimize FOLL_ANON for make_pages_present()
+	 * when it tries to page in a VM_LOCKED region. As to VM_SHARED,
+	 * we want to get the page from the page tables to make sure
+	 * that we serialize and update with any other user of that
+	 * mapping. At doing page fault, VM_MAYSHARE should be also check for
+	 * avoiding possible changes to VM_SHARED.
+	 */
+	if (vma->vm_flags & (VM_LOCKED | VM_SHARED | VM_MAYSHARE))
+		return 0;
+	/*
+	 * And if we have a fault routine, it's not an anonymous region.
+	 */
+	return !vma->vm_ops || !vma->vm_ops->fault;
+}
+
+/*
  * vm_normal_page -- This function gets the "struct page" associated with a pte.
  *
  * "Special" mappings do not wish to be associated with a "struct page" (either
@@ -488,16 +509,33 @@ static inline int is_cow_mapping(unsigne
 #else
 # define HAVE_PTE_SPECIAL 0
 #endif
+
+#ifdef CONFIG_SUPPORT_ANON_ZERO_PAGE
+# define HAVE_ANON_ZERO 1
+#else
+# define HAVE_ANON_ZERO 0
+#endif
 struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
-				pte_t pte)
+			    pte_t pte, int ignore_zero)
 {
 	unsigned long pfn = pte_pfn(pte);
 
 	if (HAVE_PTE_SPECIAL) {
 		if (likely(!pte_special(pte)))
 			goto check_pfn;
-		if (!(vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP)))
-			print_bad_pte(vma, addr, pte, NULL);
+
+		if (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP))
+			return NULL;
+		/*
+		 * ZERO PAGE ? If vma is shared or has page fault handler,
+		 * Using ZERO PAGE is bug.
+		 */
+		if (HAVE_ANON_ZERO && use_zero_page(vma)) {
+			if (ignore_zero)
+				return NULL;
+			return ZERO_PAGE(0);
+		}
+		print_bad_pte(vma, addr, pte, NULL);
 		return NULL;
 	}
 
@@ -591,8 +629,8 @@ copy_one_pte(struct mm_struct *dst_mm, s
 	if (vm_flags & VM_SHARED)
 		pte = pte_mkclean(pte);
 	pte = pte_mkold(pte);
-
-	page = vm_normal_page(vma, addr, pte);
+	/* we can ignore zero page */
+	page = vm_normal_page(vma, addr, pte, 1);
 	if (page) {
 		get_page(page);
 		page_dup_rmap(page, vma, addr);
@@ -783,7 +821,7 @@ static unsigned long zap_pte_range(struc
 		if (pte_present(ptent)) {
 			struct page *page;
 
-			page = vm_normal_page(vma, addr, ptent);
+			page = vm_normal_page(vma, addr, ptent, 1);
 			if (unlikely(details) && page) {
 				/*
 				 * unmap_shared_mapping_pages() wants to
@@ -1141,7 +1179,7 @@ struct page *follow_page(struct vm_area_
 		goto no_page;
 	if ((flags & FOLL_WRITE) && !pte_write(pte))
 		goto unlock;
-	page = vm_normal_page(vma, address, pte);
+	page = vm_normal_page(vma, address, pte, (flags & FOLL_NOZERO));
 	if (unlikely(!page))
 		goto bad_page;
 
@@ -1155,6 +1193,7 @@ struct page *follow_page(struct vm_area_
 		 * pte_mkyoung() would be more correct here, but atomic care
 		 * is needed to avoid losing the dirty bit: it is easier to use
 		 * mark_page_accessed().
+		 * ZERO page may be marked as accessed but no bad side effects.
 		 */
 		mark_page_accessed(page);
 	}
@@ -1186,23 +1225,6 @@ no_page_table:
 	return page;
 }
 
-/* Can we do the FOLL_ANON optimization? */
-static inline int use_zero_page(struct vm_area_struct *vma)
-{
-	/*
-	 * We don't want to optimize FOLL_ANON for make_pages_present()
-	 * when it tries to page in a VM_LOCKED region. As to VM_SHARED,
-	 * we want to get the page from the page tables to make sure
-	 * that we serialize and update with any other user of that
-	 * mapping.
-	 */
-	if (vma->vm_flags & (VM_LOCKED | VM_SHARED))
-		return 0;
-	/*
-	 * And if we have a fault routine, it's not an anonymous region.
-	 */
-	return !vma->vm_ops || !vma->vm_ops->fault;
-}
 
 
 
@@ -1216,6 +1238,7 @@ int __get_user_pages(struct task_struct 
 	int force = !!(flags & GUP_FLAGS_FORCE);
 	int ignore = !!(flags & GUP_FLAGS_IGNORE_VMA_PERMISSIONS);
 	int ignore_sigkill = !!(flags & GUP_FLAGS_IGNORE_SIGKILL);
+	int ignore_zero = !!(flags & GUP_FLAGS_IGNORE_ZERO);
 
 	if (nr_pages <= 0)
 		return 0;
@@ -1259,7 +1282,9 @@ int __get_user_pages(struct task_struct 
 				return i ? : -EFAULT;
 			}
 			if (pages) {
-				struct page *page = vm_normal_page(gate_vma, start, *pte);
+				struct page *page;
+				page = vm_normal_page(gate_vma, start,
+						      *pte, ignore_zero);
 				pages[i] = page;
 				if (page)
 					get_page(page);
@@ -1287,8 +1312,13 @@ int __get_user_pages(struct task_struct 
 		foll_flags = FOLL_TOUCH;
 		if (pages)
 			foll_flags |= FOLL_GET;
-		if (!write && use_zero_page(vma))
-			foll_flags |= FOLL_ANON;
+		if (!write) {
+			if (use_zero_page(vma))
+				foll_flags |= FOLL_ANON;
+			else
+				ignore_zero = 0;
+		} else
+			ignore_zero = 0;
 
 		do {
 			struct page *page;
@@ -1307,9 +1337,17 @@ int __get_user_pages(struct task_struct 
 			if (write)
 				foll_flags |= FOLL_WRITE;
 
+			if (ignore_zero)
+				foll_flags |= FOLL_NOZERO;
+
 			cond_resched();
 			while (!(page = follow_page(vma, start, foll_flags))) {
 				int ret;
+				/*
+				 * When we ignore zero pages, no more ops to do.
+				 */
+				if (ignore_zero)
+					break;
 
 				ret = handle_mm_fault(mm, vma, start,
 					(foll_flags & FOLL_WRITE) ?
@@ -1953,10 +1991,11 @@ static int do_wp_page(struct mm_struct *
 	int page_mkwrite = 0;
 	struct page *dirty_page = NULL;
 
-	old_page = vm_normal_page(vma, address, orig_pte);
+	/* This returns NULL when we find ZERO page */
+	old_page = vm_normal_page(vma, address, orig_pte, 1);
 	if (!old_page) {
 		/*
-		 * VM_MIXEDMAP !pfn_valid() case
+		 * VM_MIXEDMAP !pfn_valid() case or ZERO_PAGE cases.
 		 *
 		 * We should not cow pages in a shared writeable mapping.
 		 * Just mark the pages writable as we can't do any dirty
@@ -2610,6 +2649,41 @@ out_page:
 	return ret;
 }
 
+#ifdef CONFIG_SUPPORT_ANON_ZERO_PAGE
+static bool do_anon_zeromap(struct mm_struct *mm, struct vm_area_struct *vma,
+			   unsigned long address, pmd_t *pmd)
+{
+	spinlock_t *ptl;
+	pte_t entry;
+	pte_t *page_table;
+	bool ret = false;
+
+	if (!use_zero_page(vma))
+		return ret;
+	/*
+	 * We use _PAGE_SPECIAL bit in pte to indicate this page is ZERO PAGE.
+	 */
+	entry = pte_mkspecial(mk_pte(ZERO_PAGE(0), vma->vm_page_prot));
+	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	if (!pte_none(*page_table))
+		goto out_unlock;
+	set_pte_at(mm, address, page_table, entry);
+	/* No need to invalidate - it was non-present before */
+	update_mmu_cache(vma, address, entry);
+	ret = true;
+out_unlock:
+	pte_unmap_unlock(page_table, ptl);
+	return ret;
+}
+#else
+static bool do_anon_zeromap(struct mm_struct *mm, struct vm_area_struct *vma,
+			   unsigned long address, pmd_t *pmd)
+{
+	/* We don't use ZERO PAGE */
+	return false;
+}
+#endif /* CONFIG_SUPPORT_ANON_ZERO_PAGE */
+
 /*
  * We enter with non-exclusive mmap_sem (to exclude vma changes,
  * but allow concurrent faults), and pte mapped but not yet locked.
@@ -2626,6 +2700,10 @@ static int do_anonymous_page(struct mm_s
 	/* Allocate our own private page. */
 	pte_unmap(page_table);
 
+	if (unlikely(!(flags & FAULT_FLAG_WRITE)))
+		if (do_anon_zeromap(mm, vma, address, pmd))
+			return 0;
+
 	if (unlikely(anon_vma_prepare(vma)))
 		goto oom;
 	page = alloc_zeroed_user_highpage_movable(vma, address);
Index: zeropage-trialv3/mm/fremap.c
===================================================================
--- zeropage-trialv3.orig/mm/fremap.c
+++ zeropage-trialv3/mm/fremap.c
@@ -33,7 +33,8 @@ static void zap_pte(struct mm_struct *mm
 
 		flush_cache_page(vma, addr, pte_pfn(pte));
 		pte = ptep_clear_flush(vma, addr, ptep);
-		page = vm_normal_page(vma, addr, pte);
+		/* we can ignore zero page */
+		page = vm_normal_page(vma, addr, pte, 1);
 		if (page) {
 			if (pte_dirty(pte))
 				set_page_dirty(page);
Index: zeropage-trialv3/mm/mempolicy.c
===================================================================
--- zeropage-trialv3.orig/mm/mempolicy.c
+++ zeropage-trialv3/mm/mempolicy.c
@@ -404,13 +404,13 @@ static int check_pte_range(struct vm_are
 
 		if (!pte_present(*pte))
 			continue;
-		page = vm_normal_page(vma, addr, *pte);
+		/* we avoid zero page here */
+		page = vm_normal_page(vma, addr, *pte, 1);
 		if (!page)
 			continue;
 		/*
-		 * The check for PageReserved here is important to avoid
-		 * handling zero pages and other pages that may have been
-		 * marked special by the system.
+		 * The check for PageReserved here is imortant to avoid pages
+		 * that may have been marked special by the system.
 		 *
 		 * If the PageReserved would not be checked here then f.e.
 		 * the location of the zero page could have an influence
Index: zeropage-trialv3/mm/rmap.c
===================================================================
--- zeropage-trialv3.orig/mm/rmap.c
+++ zeropage-trialv3/mm/rmap.c
@@ -943,7 +943,11 @@ static int try_to_unmap_cluster(unsigned
 	for (; address < end; pte++, address += PAGE_SIZE) {
 		if (!pte_present(*pte))
 			continue;
-		page = vm_normal_page(vma, address, *pte);
+		/*
+		 * Because we comes from try_to_unmap_file(), we'll never see
+		 * ZERO_PAGE or ANON.
+		 */
+		page = vm_normal_page(vma, address, *pte, 1);
 		BUG_ON(!page || PageAnon(page));
 
 		if (locked_vma) {
Index: zeropage-trialv3/include/linux/mm.h
===================================================================
--- zeropage-trialv3.orig/include/linux/mm.h
+++ zeropage-trialv3/include/linux/mm.h
@@ -753,7 +753,7 @@ struct zap_details {
 };
 
 struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
-		pte_t pte);
+		pte_t pte, int ignore_zero);
 
 int zap_vma_ptes(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size);
@@ -1242,6 +1242,7 @@ struct page *follow_page(struct vm_area_
 #define FOLL_TOUCH	0x02	/* mark page accessed */
 #define FOLL_GET	0x04	/* do get_page on page */
 #define FOLL_ANON	0x08	/* give ZERO_PAGE if no pgtable */
+#define FOLL_NOZERO	0x10	/* returns NULL if ZERO_PAGE is found */
 
 typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
 			void *data);
Index: zeropage-trialv3/mm/internal.h
===================================================================
--- zeropage-trialv3.orig/mm/internal.h
+++ zeropage-trialv3/mm/internal.h
@@ -254,6 +254,7 @@ static inline void mminit_validate_memmo
 #define GUP_FLAGS_FORCE                  0x2
 #define GUP_FLAGS_IGNORE_VMA_PERMISSIONS 0x4
 #define GUP_FLAGS_IGNORE_SIGKILL         0x8
+#define GUP_FLAGS_IGNORE_ZERO         	 0x10
 
 int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		     unsigned long start, int len, int flags,
Index: zeropage-trialv3/mm/migrate.c
===================================================================
--- zeropage-trialv3.orig/mm/migrate.c
+++ zeropage-trialv3/mm/migrate.c
@@ -834,7 +834,7 @@ static int do_move_page_to_node_array(st
 		if (!vma || !vma_migratable(vma))
 			goto set_status;
 
-		page = follow_page(vma, pp->addr, FOLL_GET);
+		page = follow_page(vma, pp->addr, FOLL_GET | FOLL_NOZERO);
 
 		err = PTR_ERR(page);
 		if (IS_ERR(page))
@@ -991,14 +991,14 @@ static void do_pages_stat_array(struct m
 		if (!vma)
 			goto set_status;
 
-		page = follow_page(vma, addr, 0);
+		page = follow_page(vma, addr, FOLL_NOZERO);
 
 		err = PTR_ERR(page);
 		if (IS_ERR(page))
 			goto set_status;
 
 		err = -ENOENT;
-		/* Use PageReserved to check for zero page */
+		/* if zero page, page is NULL. */
 		if (!page || PageReserved(page))
 			goto set_status;
 
Index: zeropage-trialv3/mm/mlock.c
===================================================================
--- zeropage-trialv3.orig/mm/mlock.c
+++ zeropage-trialv3/mm/mlock.c
@@ -162,7 +162,7 @@ static long __mlock_vma_pages_range(stru
 	struct page *pages[16]; /* 16 gives a reasonable batch */
 	int nr_pages = (end - start) / PAGE_SIZE;
 	int ret = 0;
-	int gup_flags = 0;
+	int gup_flags = GUP_FLAGS_IGNORE_ZERO;
 
 	VM_BUG_ON(start & ~PAGE_MASK);
 	VM_BUG_ON(end   & ~PAGE_MASK);
Index: zeropage-trialv3/fs/proc/task_mmu.c
===================================================================
--- zeropage-trialv3.orig/fs/proc/task_mmu.c
+++ zeropage-trialv3/fs/proc/task_mmu.c
@@ -342,8 +342,8 @@ static int smaps_pte_range(pmd_t *pmd, u
 			continue;
 
 		mss->resident += PAGE_SIZE;
-
-		page = vm_normal_page(vma, addr, ptent);
+		/* we ignore zero page */
+		page = vm_normal_page(vma, addr, ptent, 1);
 		if (!page)
 			continue;
 
@@ -450,8 +450,8 @@ static int clear_refs_pte_range(pmd_t *p
 		ptent = *pte;
 		if (!pte_present(ptent))
 			continue;
-
-		page = vm_normal_page(vma, addr, ptent);
+		/* we ignore zero page */
+		page = vm_normal_page(vma, addr, ptent, 1);
 		if (!page)
 			continue;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
