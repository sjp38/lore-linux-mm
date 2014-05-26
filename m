Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4961A6B0036
	for <linux-mm@kvack.org>; Mon, 26 May 2014 11:29:51 -0400 (EDT)
Received: by mail-qc0-f178.google.com with SMTP id l6so12412538qcy.9
        for <linux-mm@kvack.org>; Mon, 26 May 2014 08:29:51 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id 69si13514029qgp.59.2014.05.26.08.29.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 May 2014 08:29:50 -0700 (PDT)
Message-Id: <20140526152107.823060865@infradead.org>
Date: Mon, 26 May 2014 16:56:06 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [RFC][PATCH 1/5] mm: Introduce VM_PINNED and interfaces
References: <20140526145605.016140154@infradead.org>
Content-Disposition: inline; filename=peterz-mm-pinned-1.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>

Introduce VM_PINNED and related machinery to solve a number of issues;

Firstly, various subsystems (perf, IB amongst others) 'pin'
significant chunks of memory (through holding page refs or custom
maps), because this memory is unevictable we must test this against
RLIMIT_MEMLOCK.

However, you can also mlock() these ranges, resulting in double
accounting. Patch bc3e53f682 ("mm: distinguish between mlocked and
pinned pages") split the counter into mm_struct::locked_vm and
mm_struct::pinned_vm, but did not add pinned_vm against the
RLIMIT_MEMLOCK test.

This resulted in that RLIMIT_MEMLOCK would under-account, and
effectively it would allow double the amount of memory to be
unevictable.

By introducing VM_PINNED and keeping track of these ranges as VMAs we
have sufficient information to account all pages without over or
under accounting any.

Secondly, due to the long-term pinning of pages things like CMA and
compaction get into trouble, because these pages (esp. for IB) start
their life as normal movable pages, but after the 'pinning' they're
not. This results in CMA and compaction fails.

By having a single common function: mm_mpin(), before the
get_user_pages() call, we can rectify this by migrating the pages to a
more suitable location -- this patch does not do this, but provides
the infrastructure to do so.

Thirdly, because VM_LOCKED does allow unmapping (and therefore page
migration) the -rt people are not pleased and would very much like
something stronger. This provides the required infrastructure (but not
the user interfaces).

Cc: Christoph Lameter <cl@linux.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Roland Dreier <roland@kernel.org>
Cc: Sean Hefty <sean.hefty@intel.com>
Cc: Hal Rosenstock <hal.rosenstock@gmail.com>
Signed-off-by: Peter Zijlstra <peterz@infradead.org>
---
 include/linux/mm.h       |    3 +
 include/linux/mm_types.h |    5 +
 kernel/fork.c            |    2 
 mm/mlock.c               |  133 ++++++++++++++++++++++++++++++++++++++++++-----
 mm/mmap.c                |   18 ++++--
 5 files changed, 141 insertions(+), 20 deletions(-)

--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -113,6 +113,7 @@ extern unsigned int kobjsize(const void
 #define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct page", just pure PFN */
 #define VM_DENYWRITE	0x00000800	/* ETXTBSY on write attempts.. */
 
+#define VM_PINNED	0x00001000
 #define VM_LOCKED	0x00002000
 #define VM_IO           0x00004000	/* Memory mapped I/O or similar */
 
@@ -1808,6 +1809,8 @@ static inline void mm_populate(unsigned
 	/* Ignore errors */
 	(void) __mm_populate(addr, len, 1);
 }
+extern int mm_mpin(unsigned long start, unsigned long end);
+extern int mm_munpin(unsigned long start, unsigned long end);
 #else
 static inline void mm_populate(unsigned long addr, unsigned long len) {}
 #endif
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -469,6 +469,11 @@ static inline cpumask_t *mm_cpumask(stru
 	return mm->cpu_vm_mask_var;
 }
 
+static inline unsigned long mm_locked_pages(struct mm_struct *mm)
+{
+	return mm->pinned_vm + mm->locked_vm;
+}
+
 #if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
 /*
  * Memory barriers to keep this state in sync are graciously provided by
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -410,6 +410,8 @@ static int dup_mmap(struct mm_struct *mm
 		if (anon_vma_fork(tmp, mpnt))
 			goto fail_nomem_anon_vma_fork;
 		tmp->vm_flags &= ~VM_LOCKED;
+		if (tmp->vm_flags & VM_PINNED)
+			mm->pinned_vm += vma_pages(tmp);
 		tmp->vm_next = tmp->vm_prev = NULL;
 		file = tmp->vm_file;
 		if (file) {
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -549,9 +549,8 @@ static int mlock_fixup(struct vm_area_st
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pgoff_t pgoff;
-	int nr_pages;
+	int nr_pages, nr_locked, nr_pinned;
 	int ret = 0;
-	int lock = !!(newflags & VM_LOCKED);
 
 	if (newflags == vma->vm_flags || (vma->vm_flags & VM_SPECIAL) ||
 	    is_vm_hugetlb_page(vma) || vma == get_gate_vma(current->mm))
@@ -582,9 +581,49 @@ static int mlock_fixup(struct vm_area_st
 	 * Keep track of amount of locked VM.
 	 */
 	nr_pages = (end - start) >> PAGE_SHIFT;
-	if (!lock)
-		nr_pages = -nr_pages;
-	mm->locked_vm += nr_pages;
+
+	/*
+	 * We should only account pages once, if VM_PINNED is set pages are
+	 * accounted in mm_struct::pinned_vm, otherwise if VM_LOCKED is set,
+	 * we'll account them in mm_struct::locked_vm.
+	 *
+	 * PL  := vma->vm_flags
+	 * PL' := newflags
+	 * PLd := {pinned,locked}_vm delta
+	 *
+	 * PL->PL' PLd
+	 * -----------
+	 * 00  01  0+
+	 * 00  10  +0
+	 * 01  11  +-
+	 * 01  00  0-
+	 * 10  00  -0
+	 * 10  11  00
+	 * 11  01  -+
+	 * 11  10  00
+	 */
+
+	nr_pinned = nr_locked = 0;
+
+	if ((vma->vm_flags ^ newflags) & VM_PINNED) {
+		if (vma->vm_flags & VM_PINNED)
+			nr_pinned = -nr_pages;
+		else
+			nr_pinned = nr_pages;
+	}
+
+	if (vma->vm_flags & VM_PINNED) {
+		if ((newflags & (VM_PINNED|VM_LOCKED)) == VM_LOCKED)
+			nr_locked = nr_pages;
+	} else {
+		if (vma->vm_flags & VM_LOCKED)
+			nr_locked = -nr_pages;
+		else if (newflags & VM_LOCKED)
+			nr_locked = nr_pages;
+	}
+
+	mm->pinned_vm += nr_pinned;
+	mm->locked_vm += nr_locked;
 
 	/*
 	 * vm_flags is protected by the mmap_sem held in write mode.
@@ -592,7 +631,7 @@ static int mlock_fixup(struct vm_area_st
 	 * set VM_LOCKED, __mlock_vma_pages_range will bring it back.
 	 */
 
-	if (lock)
+	if (((vma->vm_flags ^ newflags) & VM_PINNED) || (newflags & VM_LOCKED))
 		vma->vm_flags = newflags;
 	else
 		munlock_vma_pages_range(vma, start, end);
@@ -602,12 +641,17 @@ static int mlock_fixup(struct vm_area_st
 	return ret;
 }
 
-static int do_mlock(unsigned long start, size_t len, int on)
+#define MLOCK_F_ON	0x01
+#define MLOCK_F_PIN	0x02
+
+static int do_mlock(unsigned long start, size_t len, unsigned int flags)
 {
 	unsigned long nstart, end, tmp;
 	struct vm_area_struct * vma, * prev;
 	int error;
 
+	lockdep_assert_held(&current->mm->mmap_sem);
+
 	VM_BUG_ON(start & ~PAGE_MASK);
 	VM_BUG_ON(len != PAGE_ALIGN(len));
 	end = start + len;
@@ -624,13 +668,18 @@ static int do_mlock(unsigned long start,
 		prev = vma;
 
 	for (nstart = start ; ; ) {
-		vm_flags_t newflags;
+		vm_flags_t newflags = vma->vm_flags;
+		vm_flags_t flag = VM_LOCKED;
 
-		/* Here we know that  vma->vm_start <= nstart < vma->vm_end. */
+		if (flags & MLOCK_F_PIN)
+			flag = VM_PINNED;
 
-		newflags = vma->vm_flags & ~VM_LOCKED;
-		if (on)
-			newflags |= VM_LOCKED;
+		if (flags & MLOCK_F_ON)
+			newflags |= flag;
+		else
+			newflags &= ~flag;
+
+		/* Here we know that  vma->vm_start <= nstart < vma->vm_end. */
 
 		tmp = vma->vm_end;
 		if (tmp > end)
@@ -653,6 +702,62 @@ static int do_mlock(unsigned long start,
 	return error;
 }
 
+/**
+ * mm_mpin - create a pinned vma
+ * @start - vaddr to start the vma
+ * @len - size of the vma
+ *
+ * Creates a pinned vma, where pinning is similar in locked in that the pages
+ * will be unevictable, but stronger in that the pages will be unmappable as
+ * well. Typically this is called before a driver does get_user_pages() on a
+ * chunk of memory on behalf of a user.
+ *
+ * Returns 0 for success, otherwise:
+ * -EPERM - the caller is not privilidged
+ * -ENOMEM - the called exceeded RLIMIT_MEMLOCK
+ * -ENOMEM - failed to allocate sufficient memory
+ */
+int mm_mpin(unsigned long start, size_t len)
+{
+	unsigned long locked, lock_limit;
+
+	if (!can_do_mlock())
+		return -EPERM;
+
+	lock_limit = rlimit(RLIMIT_MEMLOCK);
+	lock_limit >>= PAGE_SHIFT;
+	locked = len >> PAGE_SHIFT;
+	locked += mm_locked_pages(current->mm);
+
+	if (!((locked <= lock_limit) || capable(CAP_IPC_LOCK)))
+		return -ENOMEM;
+
+	/*
+	 * Because we're typically called before a long-term get_user_pages()
+	 * call, this is a good spot to avoid eviction related problems:
+	 *
+	 * TODO; migrate all these pages out from CMA regions.
+	 * TODO; migrate the pages to UNMOVABLE page blocks.
+	 * TODO; linearize these pages to avoid compaction issues.
+	 */
+	return do_mlock(start, len, MLOCK_F_ON | MLOCK_F_PIN);
+
+}
+EXPORT_SYMBOL_GPL(mm_mpin);
+
+/**
+ * mm_munpin - destroys a pinned vma
+ * @start - vaddr of the vma start
+ * @len - size of the vma
+ *
+ * Undoes mm_mpin().
+ */
+int mm_munpin(unsigned long start, size_t len)
+{
+	return do_mlock(start, start + len, MLOCK_F_PIN);
+}
+EXPORT_SYMBOL_GPL(mm_munpin);
+
 /*
  * __mm_populate - populate and/or mlock pages within a range of address space.
  *
@@ -736,11 +841,11 @@ SYSCALL_DEFINE2(mlock, unsigned long, st
 
 	down_write(&current->mm->mmap_sem);
 
-	locked += current->mm->locked_vm;
+	locked += mm_locked_pages(current->mm);
 
 	/* check against resource limits */
 	if ((locked <= lock_limit) || capable(CAP_IPC_LOCK))
-		error = do_mlock(start, len, 1);
+		error = do_mlock(start, len, MLOCK_F_ON);
 
 	up_write(&current->mm->mmap_sem);
 	if (!error)
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1210,7 +1210,7 @@ static inline int mlock_future_check(str
 	/*  mlock MCL_FUTURE? */
 	if (flags & VM_LOCKED) {
 		locked = len >> PAGE_SHIFT;
-		locked += mm->locked_vm;
+		locked += mm_locked_pages(mm);
 		lock_limit = rlimit(RLIMIT_MEMLOCK);
 		lock_limit >>= PAGE_SHIFT;
 		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
@@ -1616,7 +1616,9 @@ unsigned long mmap_region(struct file *f
 	perf_event_mmap(vma);
 
 	vm_stat_account(mm, vm_flags, file, len >> PAGE_SHIFT);
-	if (vm_flags & VM_LOCKED) {
+	if (vm_flags & VM_PINNED) {
+		mm->pinned_vm += (len >> PAGE_SHIFT);
+	} else if (vm_flags & VM_LOCKED) {
 		if (!((vm_flags & VM_SPECIAL) || is_vm_hugetlb_page(vma) ||
 					vma == get_gate_vma(current->mm)))
 			mm->locked_vm += (len >> PAGE_SHIFT);
@@ -2069,7 +2071,7 @@ static int acct_stack_growth(struct vm_a
 	if (vma->vm_flags & VM_LOCKED) {
 		unsigned long locked;
 		unsigned long limit;
-		locked = mm->locked_vm + grow;
+		locked = mm_locked_pages(mm) + grow;
 		limit = ACCESS_ONCE(rlim[RLIMIT_MEMLOCK].rlim_cur);
 		limit >>= PAGE_SHIFT;
 		if (locked > limit && !capable(CAP_IPC_LOCK))
@@ -2538,13 +2540,17 @@ int do_munmap(struct mm_struct *mm, unsi
 	/*
 	 * unlock any mlock()ed ranges before detaching vmas
 	 */
-	if (mm->locked_vm) {
+	if (mm->locked_vm || mm->pinned_vm) {
 		struct vm_area_struct *tmp = vma;
 		while (tmp && tmp->vm_start < end) {
-			if (tmp->vm_flags & VM_LOCKED) {
+			if (tmp->vm_flags & VM_PINNED)
+				mm->pinned_vm -= vma_pages(tmp);
+			else if (tmp->vm_flags & VM_LOCKED)
 				mm->locked_vm -= vma_pages(tmp);
+
+			if (tmp->vm_flags & VM_LOCKED)
 				munlock_vma_pages_all(tmp);
-			}
+
 			tmp = tmp->vm_next;
 		}
 	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
