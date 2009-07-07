Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 82FF16B006A
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 03:20:30 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6783PBI001515
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 7 Jul 2009 17:03:26 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8111445DE51
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 17:03:25 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 55C6C45DE57
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 17:03:25 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 338B71DB8040
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 17:03:25 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B2D721DB8043
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 17:03:24 +0900 (JST)
Date: Tue, 7 Jul 2009 17:01:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 4/4] add get user pages nozero
Message-Id: <20090707170141.d6c2bea4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, npiggin@suse.de, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, avi@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

just an experimental. better idea is welcome.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, get_user_pages() can return ZERO_PAGE if mapped. But in some calles,
using ZERO_PAGE is not suitable and avoiding ZERO_PAGE is better.

This patch adds
  - get_user_pages_nozero() (READ fault only)

This function work as usual get_user_pages() but if it finds ZERO_PAGE
in usual mapping (map where vma exists), it purges zero-pte and fault
again. In this page fault, zero page mapping is avoided.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/mm.h       |   19 +++++++++++++++
 include/linux/mm_types.h |    2 +
 kernel/futex.c           |   25 ++++++++++---------
 mm/internal.h            |    1 
 mm/memory.c              |   59 ++++++++++++++++++++++++++++++++++++++++++++---
 mm/mempolicy.c           |    5 +--
 6 files changed, 93 insertions(+), 18 deletions(-)

Index: zeropage-trial/include/linux/mm.h
===================================================================
--- zeropage-trial.orig/include/linux/mm.h
+++ zeropage-trial/include/linux/mm.h
@@ -841,6 +841,21 @@ static inline int page_is_zero(struct pa
 	return page == ZERO_PAGE(0);
 }
 
+/*
+ * These functions are for avoidling zero-page allocation while someone calls
+ * get_user_pages.etc. See mm/memory.c::get_user_pages_nozero().
+ * While mm->avoid_zeromap > 1, new read page fault to not-present memory will
+ * not use ZERO_PAGE.This will not set in usual page faults.
+ */
+static inline void mm_exclude_zeropage(struct mm_struct *mm)
+{
+	atomic_inc(&mm->avoid_zeromap);
+}
+
+static inline void mm_allow_zeropage(struct mm_struct *mm)
+{
+	atomic_dec(&mm->avoid_zeromap);
+}
 
 extern int make_pages_present(unsigned long addr, unsigned long end);
 extern int access_process_vm(struct task_struct *tsk, unsigned long addr, void *buf, int len, int write);
@@ -851,6 +866,9 @@ int get_user_pages(struct task_struct *t
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			struct page **pages);
 
+int get_user_pages_nozero(struct task_struct *tsk, struct mm_struct *mm,
+		  unsigned long start, int nr_pages, struct page **pages);
+
 extern int try_to_release_page(struct page * page, gfp_t gfp_mask);
 extern void do_invalidatepage(struct page *page, unsigned long offset);
 
@@ -1262,6 +1280,7 @@ struct page *follow_page(struct vm_area_
 #define FOLL_TOUCH	0x02	/* mark page accessed */
 #define FOLL_GET	0x04	/* do get_page on page */
 #define FOLL_ANON	0x08	/* give ZERO_PAGE if no pgtable */
+#define FOLL_NOZERO	0x10	/* return NULL even if ZEROPAGE is mapped */
 
 typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
 			void *data);
Index: zeropage-trial/kernel/futex.c
===================================================================
--- zeropage-trial.orig/kernel/futex.c
+++ zeropage-trial/kernel/futex.c
@@ -254,18 +254,19 @@ again:
 			put_page(page);
 			goto again;
 		}
-		/*
-	 	* Finding ZERO PAGE here is obviously user's BUG because
-	 	* futex_wake()etc. is called against never-written page.
-	 	* Considering how futex is used, this kind of bug should not
-	 	* happen i.e. very strange system bug. Then, print out message.
-	 	*/
-		unlock_page(page);
-		put_page(page);
-		printk(KERN_WARNING "futex is called against not-initialized"
-				     "memory %d(%s) at %p", current->pid,
-				     current->comm, (void*)address);
-		return -EINVAL;
+		{
+			struct mm_struct *mm = current->mm;
+			/*
+			 * _VERY_ SLOW PATH: we find zeropage...replace it
+			 * see mm/memory.c
+			 */
+			down_read(&mm->mmap_sem);
+			err = get_user_pages_nozero(current, mm,
+						    address, 1, &page);
+			up_read(&mm->mmap_sem);
+			if (err < 0)
+				return err;
+		}
 	}
 
 	/*
Index: zeropage-trial/mm/internal.h
===================================================================
--- zeropage-trial.orig/mm/internal.h
+++ zeropage-trial/mm/internal.h
@@ -254,6 +254,7 @@ static inline void mminit_validate_memmo
 #define GUP_FLAGS_FORCE                  0x2
 #define GUP_FLAGS_IGNORE_VMA_PERMISSIONS 0x4
 #define GUP_FLAGS_IGNORE_SIGKILL         0x8
+#define GUP_FLAGS_NOZEROPAGE		 0x10
 
 int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		     unsigned long start, int len, int flags,
Index: zeropage-trial/mm/memory.c
===================================================================
--- zeropage-trial.orig/mm/memory.c
+++ zeropage-trial/mm/memory.c
@@ -1159,7 +1159,9 @@ struct page *follow_page(struct vm_area_
 		page = vm_normal_page(vma, address, pte);
 		if (unlikely(!page))
 			goto bad_page;
-	} else
+	} else if (flags & FOLL_NOZERO)
+		goto unlock;
+	else
 		page = ZERO_PAGE(0);
 
 	if (flags & FOLL_GET)
@@ -1234,6 +1236,7 @@ int __get_user_pages(struct task_struct 
 	int force = !!(flags & GUP_FLAGS_FORCE);
 	int ignore = !!(flags & GUP_FLAGS_IGNORE_VMA_PERMISSIONS);
 	int ignore_sigkill = !!(flags & GUP_FLAGS_IGNORE_SIGKILL);
+	int no_zero = !!(flags & GUP_FLAGS_NOZEROPAGE);
 
 	if (nr_pages <= 0)
 		return 0;
@@ -1277,11 +1280,11 @@ int __get_user_pages(struct task_struct 
 				return i ? : -EFAULT;
 			}
 			if (pages) {
-				struct page *page;
+				struct page *page = NULL;
 				if (!pte_zero(*pte))
 					page = vm_normal_page(gate_vma,
 							      start, *pte);
-				else
+				else if (!no_zero)
 					page = ZERO_PAGE(page);
 				pages[i] = page;
 				if (page)
@@ -1329,6 +1332,8 @@ int __get_user_pages(struct task_struct 
 
 			if (write)
 				foll_flags |= FOLL_WRITE;
+			if (no_zero)
+				foll_flags |= FOLL_NOZERO;
 
 			cond_resched();
 			while (!(page = follow_page(vma, start, foll_flags))) {
@@ -1452,6 +1457,26 @@ int get_user_pages(struct task_struct *t
 
 EXPORT_SYMBOL(get_user_pages);
 
+/*
+ * This get_user_pages_nozero() is provided for READ operation of
+ * get_user_pages() and guaranteed not to return ZERO_PAGE. If
+ * get_user_pages(_fast)() returns ZERO_PAGE and the caller don't want that,
+ * he can call this function to allocating new anon pages in that place.
+ * unnecessary flags are omitted.
+ *
+ */
+int get_user_pages_nozero(struct task_struct *tsk, struct mm_struct *mm,
+		  unsigned long start, int nr_pages, struct page **pages)
+{
+	int ret;
+	mm_exclude_zeropage(mm);
+	ret = __get_user_pages(tsk, mm, start, nr_pages,
+				      GUP_FLAGS_NOZEROPAGE, pages, NULL);
+	mm_allow_zeropage(mm);
+	return ret;
+}
+
+
 pte_t *get_locked_pte(struct mm_struct *mm, unsigned long addr,
 			spinlock_t **ptl)
 {
@@ -2657,6 +2682,8 @@ static int do_anon_zeromap(struct mm_str
 	 */
 	if (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP))
 		return ret;
+	if (atomic_read(&mm->avoid_zeromap))
+		return ret;
 
 	entry = mk_pte(ZERO_PAGE(0), vma->vm_page_prot);
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
@@ -2954,6 +2981,19 @@ static int do_nonlinear_fault(struct mm_
 }
 
 /*
+ * Unmap zero page and allow fault here again.
+ */
+void flush_zero_pte(struct mm_struct *mm, struct vm_area_struct *vma,
+		    unsigned long address, pte_t *pte)
+{
+	flush_cache_page(vma, address, zero_page_pfn);
+	ptep_clear_flush_notify(vma, address, pte);
+	update_hiwater_rss(mm);
+	dec_mm_counter(mm, file_rss);
+}
+
+
+/*
  * These routines also need to handle stuff like marking pages dirty
  * and/or accessed for architectures that don't do it in hardware (most
  * RISC architectures).  The early dirtying is also good on the i386.
@@ -2974,6 +3014,19 @@ static inline int handle_pte_fault(struc
 	spinlock_t *ptl;
 
 	entry = *pte;
+	/*
+	 * Read fault to mapped zero page...this is caused by get_user_page()
+	 * artificially. We purge this pte and fall through. This is very
+	 * rare case. If write fault, copy-on-write will handle all.
+	 */
+	if (unlikely(!(flags & FAULT_FLAG_WRITE) && pte_zero(entry))) {
+		ptl = pte_lockptr(mm, pmd);
+		spin_lock(ptl);
+		if (pte_zero(*pte)) /* purge mapped zero page */
+			flush_zero_pte(mm, vma, address, pte);
+		spin_unlock(ptl);
+		entry = *pte;
+	}
 	if (!pte_present(entry)) {
 		if (pte_none(entry)) {
 			if (vma->vm_ops) {
Index: zeropage-trial/include/linux/mm_types.h
===================================================================
--- zeropage-trial.orig/include/linux/mm_types.h
+++ zeropage-trial/include/linux/mm_types.h
@@ -266,6 +266,8 @@ struct mm_struct {
 	spinlock_t		ioctx_lock;
 	struct hlist_head	ioctx_list;
 
+	atomic_t		avoid_zeromap;
+
 #ifdef CONFIG_MM_OWNER
 	/*
 	 * "owner" points to a task that is regarded as the canonical
Index: zeropage-trial/mm/mempolicy.c
===================================================================
--- zeropage-trial.orig/mm/mempolicy.c
+++ zeropage-trial/mm/mempolicy.c
@@ -685,10 +685,9 @@ static int lookup_node(struct mm_struct 
 	int err;
 
 	/*
-	 * This get_user_page() may catch ZERO PAGE. In that case, returned
-	 * value will not be very useful. But we can't return error here.
+	 * get_user_page_nozero() never returns ZERO PAGE.
 	 */
-	err = get_user_pages(current, mm, addr & PAGE_MASK, 1, 0, 0, &p, NULL);
+	err = get_user_pages_nozero(current, mm, addr & PAGE_MASK, 1, &p);
 	if (err >= 0) {
 		err = page_to_nid(p);
 		put_page(p);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
