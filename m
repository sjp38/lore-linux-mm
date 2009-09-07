Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E94DA6B00C1
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 17:41:32 -0400 (EDT)
Date: Mon, 7 Sep 2009 22:40:49 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 8/8] mm: FOLL flags for GUP flags
In-Reply-To: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
Message-ID: <Pine.LNX.4.64.0909072239390.15430@sister.anvils>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

__get_user_pages() has been taking its own GUP flags, then processing
them into FOLL flags for follow_page().  Though oddly named, the FOLL
flags are more widely used, so pass them to __get_user_pages() now.
Sorry, VM flags, VM_FAULT flags and FAULT_FLAGs are still distinct.

(The patch to __get_user_pages() looks peculiar, with both gup_flags
and foll_flags: the gup_flags remain constant; but as before there's
an exceptional case, out of scope of the patch, in which foll_flags
per page have FOLL_WRITE masked off.)

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 include/linux/mm.h |    1 
 mm/internal.h      |    6 -----
 mm/memory.c        |   44 ++++++++++++++++++-------------------------
 mm/mlock.c         |    4 +--
 mm/nommu.c         |   16 +++++++--------
 5 files changed, 31 insertions(+), 40 deletions(-)

--- mm7/include/linux/mm.h	2009-09-07 13:16:39.000000000 +0100
+++ mm8/include/linux/mm.h	2009-09-07 13:17:07.000000000 +0100
@@ -1248,6 +1248,7 @@ struct page *follow_page(struct vm_area_
 #define FOLL_TOUCH	0x02	/* mark page accessed */
 #define FOLL_GET	0x04	/* do get_page on page */
 #define FOLL_DUMP	0x08	/* give error on hole if it would be zero */
+#define FOLL_FORCE	0x10	/* get_user_pages read/write w/o permission */
 
 typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
 			void *data);
--- mm7/mm/internal.h	2009-09-07 13:16:39.000000000 +0100
+++ mm8/mm/internal.h	2009-09-07 13:17:07.000000000 +0100
@@ -250,12 +250,8 @@ static inline void mminit_validate_memmo
 }
 #endif /* CONFIG_SPARSEMEM */
 
-#define GUP_FLAGS_WRITE		0x01
-#define GUP_FLAGS_FORCE		0x02
-#define GUP_FLAGS_DUMP		0x04
-
 int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		     unsigned long start, int len, int flags,
+		     unsigned long start, int len, unsigned int foll_flags,
 		     struct page **pages, struct vm_area_struct **vmas);
 
 #define ZONE_RECLAIM_NOSCAN	-2
--- mm7/mm/memory.c	2009-09-07 13:17:01.000000000 +0100
+++ mm8/mm/memory.c	2009-09-07 13:17:07.000000000 +0100
@@ -1209,27 +1209,29 @@ no_page_table:
 }
 
 int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		     unsigned long start, int nr_pages, int flags,
+		     unsigned long start, int nr_pages, unsigned int gup_flags,
 		     struct page **pages, struct vm_area_struct **vmas)
 {
 	int i;
-	unsigned int vm_flags = 0;
-	int write = !!(flags & GUP_FLAGS_WRITE);
-	int force = !!(flags & GUP_FLAGS_FORCE);
+	unsigned long vm_flags;
 
 	if (nr_pages <= 0)
 		return 0;
+
+	VM_BUG_ON(!!pages != !!(gup_flags & FOLL_GET));
+
 	/* 
 	 * Require read or write permissions.
-	 * If 'force' is set, we only require the "MAY" flags.
+	 * If FOLL_FORCE is set, we only require the "MAY" flags.
 	 */
-	vm_flags  = write ? (VM_WRITE | VM_MAYWRITE) : (VM_READ | VM_MAYREAD);
-	vm_flags &= force ? (VM_MAYREAD | VM_MAYWRITE) : (VM_READ | VM_WRITE);
+	vm_flags  = (gup_flags & FOLL_WRITE) ?
+			(VM_WRITE | VM_MAYWRITE) : (VM_READ | VM_MAYREAD);
+	vm_flags &= (gup_flags & FOLL_FORCE) ?
+			(VM_MAYREAD | VM_MAYWRITE) : (VM_READ | VM_WRITE);
 	i = 0;
 
 	do {
 		struct vm_area_struct *vma;
-		unsigned int foll_flags;
 
 		vma = find_extend_vma(mm, start);
 		if (!vma && in_gate_area(tsk, start)) {
@@ -1241,7 +1243,7 @@ int __get_user_pages(struct task_struct
 			pte_t *pte;
 
 			/* user gate pages are read-only */
-			if (write)
+			if (gup_flags & FOLL_WRITE)
 				return i ? : -EFAULT;
 			if (pg > TASK_SIZE)
 				pgd = pgd_offset_k(pg);
@@ -1278,22 +1280,15 @@ int __get_user_pages(struct task_struct
 		    !(vm_flags & vma->vm_flags))
 			return i ? : -EFAULT;
 
-		foll_flags = FOLL_TOUCH;
-		if (pages)
-			foll_flags |= FOLL_GET;
-		if (flags & GUP_FLAGS_DUMP)
-			foll_flags |= FOLL_DUMP;
-		if (write)
-			foll_flags |= FOLL_WRITE;
-
 		if (is_vm_hugetlb_page(vma)) {
 			i = follow_hugetlb_page(mm, vma, pages, vmas,
-					&start, &nr_pages, i, foll_flags);
+					&start, &nr_pages, i, gup_flags);
 			continue;
 		}
 
 		do {
 			struct page *page;
+			unsigned int foll_flags = gup_flags;
 
 			/*
 			 * If we have a pending SIGKILL, don't keep faulting
@@ -1302,9 +1297,6 @@ int __get_user_pages(struct task_struct
 			if (unlikely(fatal_signal_pending(current)))
 				return i ? i : -ERESTARTSYS;
 
-			if (write)
-				foll_flags |= FOLL_WRITE;
-
 			cond_resched();
 			while (!(page = follow_page(vma, start, foll_flags))) {
 				int ret;
@@ -1416,12 +1408,14 @@ int get_user_pages(struct task_struct *t
 		unsigned long start, int nr_pages, int write, int force,
 		struct page **pages, struct vm_area_struct **vmas)
 {
-	int flags = 0;
+	int flags = FOLL_TOUCH;
 
+	if (pages)
+		flags |= FOLL_GET;
 	if (write)
-		flags |= GUP_FLAGS_WRITE;
+		flags |= FOLL_WRITE;
 	if (force)
-		flags |= GUP_FLAGS_FORCE;
+		flags |= FOLL_FORCE;
 
 	return __get_user_pages(tsk, mm, start, nr_pages, flags, pages, vmas);
 }
@@ -1448,7 +1442,7 @@ struct page *get_dump_page(unsigned long
 	struct page *page;
 
 	if (__get_user_pages(current, current->mm, addr, 1,
-			GUP_FLAGS_FORCE | GUP_FLAGS_DUMP, &page, &vma) < 1)
+			FOLL_FORCE | FOLL_DUMP | FOLL_GET, &page, &vma) < 1)
 		return NULL;
 	if (page == ZERO_PAGE(0)) {
 		page_cache_release(page);
--- mm7/mm/mlock.c	2009-09-07 13:16:15.000000000 +0100
+++ mm8/mm/mlock.c	2009-09-07 13:17:07.000000000 +0100
@@ -166,9 +166,9 @@ static long __mlock_vma_pages_range(stru
 	VM_BUG_ON(end   > vma->vm_end);
 	VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
 
-	gup_flags = 0;
+	gup_flags = FOLL_TOUCH | FOLL_GET;
 	if (vma->vm_flags & VM_WRITE)
-		gup_flags = GUP_FLAGS_WRITE;
+		gup_flags |= FOLL_WRITE;
 
 	while (nr_pages > 0) {
 		int i;
--- mm7/mm/nommu.c	2009-09-07 13:16:22.000000000 +0100
+++ mm8/mm/nommu.c	2009-09-07 13:17:07.000000000 +0100
@@ -128,20 +128,20 @@ unsigned int kobjsize(const void *objp)
 }
 
 int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		     unsigned long start, int nr_pages, int flags,
+		     unsigned long start, int nr_pages, int foll_flags,
 		     struct page **pages, struct vm_area_struct **vmas)
 {
 	struct vm_area_struct *vma;
 	unsigned long vm_flags;
 	int i;
-	int write = !!(flags & GUP_FLAGS_WRITE);
-	int force = !!(flags & GUP_FLAGS_FORCE);
 
 	/* calculate required read or write permissions.
-	 * - if 'force' is set, we only require the "MAY" flags.
+	 * If FOLL_FORCE is set, we only require the "MAY" flags.
 	 */
-	vm_flags  = write ? (VM_WRITE | VM_MAYWRITE) : (VM_READ | VM_MAYREAD);
-	vm_flags &= force ? (VM_MAYREAD | VM_MAYWRITE) : (VM_READ | VM_WRITE);
+	vm_flags  = (foll_flags & FOLL_WRITE) ?
+			(VM_WRITE | VM_MAYWRITE) : (VM_READ | VM_MAYREAD);
+	vm_flags &= (foll_flags & FOLL_FORCE) ?
+			(VM_MAYREAD | VM_MAYWRITE) : (VM_READ | VM_WRITE);
 
 	for (i = 0; i < nr_pages; i++) {
 		vma = find_vma(mm, start);
@@ -183,9 +183,9 @@ int get_user_pages(struct task_struct *t
 	int flags = 0;
 
 	if (write)
-		flags |= GUP_FLAGS_WRITE;
+		flags |= FOLL_WRITE;
 	if (force)
-		flags |= GUP_FLAGS_FORCE;
+		flags |= FOLL_FORCE;
 
 	return __get_user_pages(tsk, mm, start, nr_pages, flags, pages, vmas);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
