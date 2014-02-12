Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 4D42A6B0035
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 16:27:04 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id un15so9833745pbc.32
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 13:27:03 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id x3si23894765pbk.233.2014.02.12.13.26.56
        for <linux-mm@kvack.org>;
        Wed, 12 Feb 2014 13:26:56 -0800 (PST)
Subject: [RFC][PATCH] mm: ksm: add MAP_MERGEABLE mmap() as a KSM shortcut
From: Dave Hansen <dave@sr71.net>
Date: Wed, 12 Feb 2014 13:26:30 -0800
Message-Id: <20140212212630.E5DFB494@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Dave Hansen <dave@sr71.net>, arjan@linux.intel.com, andi.kleen@intel.com


We are starting to see substantial amounts (seconds) of latency
being incurred by users of mmap_sem in the worst case.  It is
very common to see them spike up in to the tens-of-ms range.  Any
acquisition, especially for write, is a potential problem.

The aggravating factor here is that we have been encouraging
folks to be "polite" to the VM and do things like: call
MADV_DONTNEED, unmap when you're done using things, and use KSM.
All of these things take mmap_sem().  JVMs are starting to put
nuggets like this in their generic malloc() functions:

	addr = mmap(foo_bytes, ...);
	madvise(MADV_MERGABLE, addr, foo_bytes);

That means that every single malloc() call does at _least_ two
write acquisitions of mmap_sem.  We can try to batch these things
in userspace more, of course, but this is becoming a very common
pattern.  We should allow a shortcut.

I'm a little concerned that we might be in the middle of
constructing the VMA when we make the decision to set
VM_MERGEABLE and miss one of the "bad" flags.  I've sprinkled a
few VM_BUG_ON()s to watch out for any cases where we've missed
something.  I turned this on for _every_ VMA to test it, and it
hasn't blown up yet.

There are probably some other ways to do this.  We could have
prctl, or some kind of boot option, or even something analogous
to the transparent-huge-page 'always' option (as opposed to
madvise()).  We could even extend madvise() for this kind of
thing.  We could allow MADV_MERGEABLE to be specified for
unmapped areas in _advance_ for when brk() or mmap() is called
on them.

Applying transactional memory to mmap_sem would probably also
help out here a lot.

Cc: arjan@linux.intel.com
Cc: Andi Kleen <andi.kleen@intel.com>

---

 b/Documentation/vm/ksm.txt        |    5 +++-
 b/include/linux/ksm.h             |   13 +++++++++++
 b/include/uapi/asm-generic/mman.h |    1 
 b/mm/ksm.c                        |   43 +++++++++++++++++++++++---------------
 b/mm/mmap.c                       |   13 +++++++++++
 5 files changed, 58 insertions(+), 17 deletions(-)

diff -puN include/uapi/asm-generic/mman.h~mmap-flag-for-ksm include/uapi/asm-generic/mman.h
--- a/include/uapi/asm-generic/mman.h~mmap-flag-for-ksm	2014-02-12 13:13:15.496938731 -0800
+++ b/include/uapi/asm-generic/mman.h	2014-02-12 13:13:15.502939003 -0800
@@ -12,6 +12,7 @@
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
+#define MAP_MERGEABLE	0x80000		/* mark mapping as mergeable by KSM */
 
 /* Bits [26:31] are reserved, see mman-common.h for MAP_HUGETLB usage */
 
diff -puN mm/mmap.c~mmap-flag-for-ksm mm/mmap.c
--- a/mm/mmap.c~mmap-flag-for-ksm	2014-02-12 13:13:15.497938776 -0800
+++ b/mm/mmap.c	2014-02-12 13:20:33.725852533 -0800
@@ -36,6 +36,7 @@
 #include <linux/sched/sysctl.h>
 #include <linux/notifier.h>
 #include <linux/memory.h>
+#include <linux/ksm.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -1361,6 +1362,18 @@ unsigned long do_mmap_pgoff(struct file
 			vm_flags |= VM_NORESERVE;
 	}
 
+	/*
+	 * This *must* happen after all the other vm_flags have
+	 * been set, but before we make the decision about
+	 * whether this vma can be merged with another.
+	 */
+	if ((flags & MAP_MERGEABLE) && ksm_can_handle_vma(vm_flags)) {
+		int err = ksm_enter_if_new(mm);
+		if (err)
+			return err;
+		vm_flags |= VM_MERGEABLE;
+	}
+
 	addr = mmap_region(file, addr, len, vm_flags, pgoff);
 	if (!IS_ERR_VALUE(addr) &&
 	    ((vm_flags & VM_LOCKED) ||
diff -puN mm/ksm.c~mmap-flag-for-ksm mm/ksm.c
--- a/mm/ksm.c~mmap-flag-for-ksm	2014-02-12 13:13:15.498938822 -0800
+++ b/mm/ksm.c	2014-02-12 13:20:33.726852579 -0800
@@ -419,6 +419,7 @@ static struct vm_area_struct *find_merge
 		return NULL;
 	if (!(vma->vm_flags & VM_MERGEABLE) || !vma->anon_vma)
 		return NULL;
+	VM_BUG_ON(!ksm_can_handle_vma(vma->vm_flags));
 	return vma;
 }
 
@@ -785,6 +786,7 @@ static int unmerge_and_remove_all_rmap_i
 				break;
 			if (!(vma->vm_flags & VM_MERGEABLE) || !vma->anon_vma)
 				continue;
+			VM_BUG_ON(!ksm_can_handle_vma(vma->vm_flags));
 			err = unmerge_ksm_pages(vma,
 						vma->vm_start, vma->vm_end);
 			if (err)
@@ -1024,6 +1026,7 @@ static int try_to_merge_one_page(struct
 
 	if (!(vma->vm_flags & VM_MERGEABLE))
 		goto out;
+	VM_BUG_ON(!ksm_can_handle_vma(vma->vm_flags));
 	if (PageTransCompound(page) && page_trans_compound_anon_split(page))
 		goto out;
 	BUG_ON(PageTransCompound(page));
@@ -1607,6 +1610,7 @@ next_mm:
 	for (; vma; vma = vma->vm_next) {
 		if (!(vma->vm_flags & VM_MERGEABLE))
 			continue;
+		VM_BUG_ON(!ksm_can_handle_vma(vma->vm_flags));
 		if (ksm_scan.address < vma->vm_start)
 			ksm_scan.address = vma->vm_start;
 		if (!vma->anon_vma)
@@ -1736,6 +1740,25 @@ static int ksm_scan_thread(void *nothing
 	return 0;
 }
 
+int ksm_can_handle_vma(unsigned long vm_flags)
+{
+	/*
+	 * Be somewhat over-protective for now!
+	 */
+	if (vm_flags & (VM_MERGEABLE | VM_SHARED    | VM_MAYSHARE   |
+			VM_PFNMAP    | VM_IO        | VM_DONTEXPAND |
+			VM_HUGETLB   | VM_NONLINEAR | VM_MIXEDMAP))
+		return 0;		/* just ignore the advice */
+
+#ifdef VM_SAO
+	if (*m_flags & VM_SAO)
+		return 0;
+#endif
+
+	return 1;
+}
+
+
 int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 		unsigned long end, int advice, unsigned long *vm_flags)
 {
@@ -1744,24 +1767,12 @@ int ksm_madvise(struct vm_area_struct *v
 
 	switch (advice) {
 	case MADV_MERGEABLE:
-		/*
-		 * Be somewhat over-protective for now!
-		 */
-		if (*vm_flags & (VM_MERGEABLE | VM_SHARED  | VM_MAYSHARE   |
-				 VM_PFNMAP    | VM_IO      | VM_DONTEXPAND |
-				 VM_HUGETLB | VM_NONLINEAR | VM_MIXEDMAP))
-			return 0;		/* just ignore the advice */
-
-#ifdef VM_SAO
-		if (*vm_flags & VM_SAO)
+		if (!ksm_can_handle_vma(*vm_flags))
 			return 0;
-#endif
 
-		if (!test_bit(MMF_VM_MERGEABLE, &mm->flags)) {
-			err = __ksm_enter(mm);
-			if (err)
-				return err;
-		}
+		err = ksm_enter_if_new(mm);
+		if (err)
+			return err;
 
 		*vm_flags |= VM_MERGEABLE;
 		break;
diff -puN include/linux/ksm.h~mmap-flag-for-ksm include/linux/ksm.h
--- a/include/linux/ksm.h~mmap-flag-for-ksm	2014-02-12 13:13:15.499938868 -0800
+++ b/include/linux/ksm.h	2014-02-12 13:13:15.504939095 -0800
@@ -29,6 +29,13 @@ static inline int ksm_fork(struct mm_str
 	return 0;
 }
 
+static inline int ksm_enter_if_new(struct mm_struct *mm)
+{
+	if (test_bit(!MMF_VM_MERGEABLE, &mm->flags))
+		return __ksm_enter(mm);
+	return 0;
+}
+
 static inline void ksm_exit(struct mm_struct *mm)
 {
 	if (test_bit(MMF_VM_MERGEABLE, &mm->flags))
@@ -75,6 +82,7 @@ struct page *ksm_might_need_to_copy(stru
 
 int rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc);
 void ksm_migrate_page(struct page *newpage, struct page *oldpage);
+int ksm_can_handle_vma(unsigned long vm_flags);
 
 #else  /* !CONFIG_KSM */
 
@@ -91,6 +99,11 @@ static inline int PageKsm(struct page *p
 {
 	return 0;
 }
+
+static inline int ksm_can_handle_vma(unsigned long vm_flags)
+{
+	return 0;
+}
 
 #ifdef CONFIG_MMU
 static inline int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
diff -puN Documentation/vm/ksm.txt~mmap-flag-for-ksm Documentation/vm/ksm.txt
--- a/Documentation/vm/ksm.txt~mmap-flag-for-ksm	2014-02-12 13:13:15.500938913 -0800
+++ b/Documentation/vm/ksm.txt	2014-02-12 13:13:15.504939095 -0800
@@ -22,7 +22,10 @@ are swapped back in: ksmd must rediscove
 
 KSM only operates on those areas of address space which an application
 has advised to be likely candidates for merging, by using the madvise(2)
-system call: int madvise(addr, length, MADV_MERGEABLE).
+system call: int madvise(addr, length, MADV_MERGEABLE).  As a shortcut,
+an application may also specify MAP_MERGEABLE to the mmap() system call.
+This will have the same effect that calling mmap() followed by madvise()
+would have had.
 
 The app may call int madvise(addr, length, MADV_UNMERGEABLE) to cancel
 that advice and restore unshared pages: whereupon KSM unmerges whatever
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
