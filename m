Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B78496B0093
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 06:20:48 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n75AKrrT026359
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 5 Aug 2009 19:20:53 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2EA2245DE7B
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 19:20:53 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E26EE45DE6F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 19:20:52 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AF35FE08003
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 19:20:52 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4776D1DB803E
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 19:20:52 +0900 (JST)
Date: Wed, 5 Aug 2009 19:19:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 2/2] ZERO_PAGE based on pte_special
Message-Id: <20090805191902.0e3bbda5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090805191643.2b11ae78.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090805191643.2b11ae78.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, npiggin@suse.de, hugh.dickins@tiscali.co.uk, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

updated against: mmotm-Jul-30-2009.

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

  - follow_page() eats FOLL_XXX flag. If FOLL_NOZERO is set,
    NULL is returned even if ZERO_PAGE is found.

  - vm_normal_page() returns NULL if ZERO_PAGE is found.

  - __get_user_pages() eats one more flag as GUP_FLAGS_IGNORE_ZERO. If set,
    __get_user_page() returns NULL even if ZERO_PAGE is found.


Changelog v4.1 -> v5
 - removed new arguments to vm_normal_page()
 - follow_page() handles ZERO_PAGE directly.

Changelog v4 -> v4.1
 - removed nexted "if" in get_user_pages() for readability

Changelog v3->v4
 - FOLL_NOZERO is directly passed to vm_normal_page()

Changelog v2->v3
 - totally renewed.
 - use pte_special()
 - added new argument to vm_normal_page().
 - MAYSHARE is checked.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/mm.h |    1 
 mm/internal.h      |    1 
 mm/memory.c        |  123 +++++++++++++++++++++++++++++++++++++++++++----------
 mm/migrate.c       |    6 +-
 mm/mlock.c         |    2 
 5 files changed, 108 insertions(+), 25 deletions(-)

Index: mmotm-2.6.31-Aug4/mm/memory.c
===================================================================
--- mmotm-2.6.31-Aug4.orig/mm/memory.c
+++ mmotm-2.6.31-Aug4/mm/memory.c
@@ -444,6 +444,27 @@ static inline int is_cow_mapping(unsigne
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
@@ -490,6 +511,12 @@ static inline int is_cow_mapping(unsigne
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
 				pte_t pte)
 {
@@ -498,8 +525,16 @@ struct page *vm_normal_page(struct vm_ar
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
+		if (HAVE_ANON_ZERO && use_zero_page(vma))
+			return NULL;
+		print_bad_pte(vma, addr, pte, NULL);
 		return NULL;
 	}
 
@@ -1143,7 +1178,16 @@ struct page *follow_page(struct vm_area_
 		goto no_page;
 	if ((flags & FOLL_WRITE) && !pte_write(pte))
 		goto unlock;
-	page = vm_normal_page(vma, address, pte);
+
+	if (HAVE_ANON_ZERO && pte_special(pte) && use_zero_page(vma)) {
+		/* This page is ZERO_PAGE */
+		if (flags & FOLL_NOZERO)
+			page = NULL;
+		else
+			page = ZERO_PAGE(0);
+	} else
+		page = vm_normal_page(vma, address, pte);
+
 	if (unlikely(!page))
 		goto bad_page;
 
@@ -1188,23 +1232,6 @@ no_page_table:
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
 
 
 
@@ -1218,6 +1245,7 @@ int __get_user_pages(struct task_struct 
 	int force = !!(flags & GUP_FLAGS_FORCE);
 	int ignore = !!(flags & GUP_FLAGS_IGNORE_VMA_PERMISSIONS);
 	int ignore_sigkill = !!(flags & GUP_FLAGS_IGNORE_SIGKILL);
+	int ignore_zero = !!(flags & GUP_FLAGS_IGNORE_ZERO);
 
 	if (nr_pages <= 0)
 		return 0;
@@ -1261,7 +1289,11 @@ int __get_user_pages(struct task_struct 
 				return i ? : -EFAULT;
 			}
 			if (pages) {
-				struct page *page = vm_normal_page(gate_vma, start, *pte);
+				struct page *page;
+				/*
+				 * this is not anon vma...don't care zero page.
+				 */
+				page = vm_normal_page(gate_vma, start, *pte);
 				pages[i] = page;
 				if (page)
 					get_page(page);
@@ -1291,6 +1323,8 @@ int __get_user_pages(struct task_struct 
 			foll_flags |= FOLL_GET;
 		if (!write && use_zero_page(vma))
 			foll_flags |= FOLL_ANON;
+		else
+			ignore_zero = 0;
 
 		do {
 			struct page *page;
@@ -1309,9 +1343,17 @@ int __get_user_pages(struct task_struct 
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
@@ -2617,6 +2659,41 @@ out_page:
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
@@ -2633,6 +2710,10 @@ static int do_anonymous_page(struct mm_s
 	/* Allocate our own private page. */
 	pte_unmap(page_table);
 
+	if (unlikely(!(flags & FAULT_FLAG_WRITE)))
+		if (do_anon_zeromap(mm, vma, address, pmd))
+			return 0;
+
 	if (unlikely(anon_vma_prepare(vma)))
 		goto oom;
 	page = alloc_zeroed_user_highpage_movable(vma, address);
Index: mmotm-2.6.31-Aug4/include/linux/mm.h
===================================================================
--- mmotm-2.6.31-Aug4.orig/include/linux/mm.h
+++ mmotm-2.6.31-Aug4/include/linux/mm.h
@@ -1246,6 +1246,7 @@ struct page *follow_page(struct vm_area_
 #define FOLL_TOUCH	0x02	/* mark page accessed */
 #define FOLL_GET	0x04	/* do get_page on page */
 #define FOLL_ANON	0x08	/* give ZERO_PAGE if no pgtable */
+#define FOLL_NOZERO	0x10	/* returns NULL if ZERO_PAGE is found */
 
 typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
 			void *data);
Index: mmotm-2.6.31-Aug4/mm/internal.h
===================================================================
--- mmotm-2.6.31-Aug4.orig/mm/internal.h
+++ mmotm-2.6.31-Aug4/mm/internal.h
@@ -254,6 +254,7 @@ static inline void mminit_validate_memmo
 #define GUP_FLAGS_FORCE                  0x2
 #define GUP_FLAGS_IGNORE_VMA_PERMISSIONS 0x4
 #define GUP_FLAGS_IGNORE_SIGKILL         0x8
+#define GUP_FLAGS_IGNORE_ZERO         	 0x10
 
 int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		     unsigned long start, int len, int flags,
Index: mmotm-2.6.31-Aug4/mm/migrate.c
===================================================================
--- mmotm-2.6.31-Aug4.orig/mm/migrate.c
+++ mmotm-2.6.31-Aug4/mm/migrate.c
@@ -850,7 +850,7 @@ static int do_move_page_to_node_array(st
 		if (!vma || !vma_migratable(vma))
 			goto set_status;
 
-		page = follow_page(vma, pp->addr, FOLL_GET);
+		page = follow_page(vma, pp->addr, FOLL_GET | FOLL_NOZERO);
 
 		err = PTR_ERR(page);
 		if (IS_ERR(page))
@@ -1007,14 +1007,14 @@ static void do_pages_stat_array(struct m
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
 
Index: mmotm-2.6.31-Aug4/mm/mlock.c
===================================================================
--- mmotm-2.6.31-Aug4.orig/mm/mlock.c
+++ mmotm-2.6.31-Aug4/mm/mlock.c
@@ -162,7 +162,7 @@ static long __mlock_vma_pages_range(stru
 	struct page *pages[16]; /* 16 gives a reasonable batch */
 	int nr_pages = (end - start) / PAGE_SIZE;
 	int ret = 0;
-	int gup_flags = 0;
+	int gup_flags = GUP_FLAGS_IGNORE_ZERO;
 
 	VM_BUG_ON(start & ~PAGE_MASK);
 	VM_BUG_ON(end   & ~PAGE_MASK);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
