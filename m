Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4E9086B0254
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 13:03:55 -0400 (EDT)
Received: by qkei195 with SMTP id i195so144400188qke.3
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 10:03:55 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175])
        by mx.google.com with ESMTP id d4si25623044qka.106.2015.07.07.10.03.51
        for <linux-mm@kvack.org>;
        Tue, 07 Jul 2015 10:03:51 -0700 (PDT)
From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH V3 3/5] mm: mlock: Introduce VM_LOCKONFAULT and add mlock flags to enable it
Date: Tue,  7 Jul 2015 13:03:41 -0400
Message-Id: <1436288623-13007-4-git-send-email-emunson@akamai.com>
In-Reply-To: <1436288623-13007-1-git-send-email-emunson@akamai.com>
References: <1436288623-13007-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric B Munson <emunson@akamai.com>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

The cost of faulting in all memory to be locked can be very high when
working with large mappings.  If only portions of the mapping will be
used this can incur a high penalty for locking.

For the example of a large file, this is the usage pattern for a large
statical language model (probably applies to other statical or graphical
models as well).  For the security example, any application transacting
in data that cannot be swapped out (credit card data, medical records,
etc).

This patch introduces the ability to request that pages are not
pre-faulted, but are placed on the unevictable LRU when they are finally
faulted in.  This can be done area at a time via the
mlock2(MLOCK_ONFAULT) or the mlockall(MCL_ONFAULT) system calls.  These
calls can be undone via munlock2(MLOCK_ONFAULT) or
munlockall2(MCL_ONFAULT).

To keep accounting checks out of the page fault path, users are billed
for the entire mapping lock as if MLOCK_LOCKED was used.

Signed-off-by: Eric B Munson <emunson@akamai.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-alpha@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mips@linux-mips.org
Cc: linux-parisc@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: sparclinux@vger.kernel.org
Cc: linux-xtensa@linux-xtensa.org
Cc: linux-mm@kvack.org
Cc: linux-arch@vger.kernel.org
Cc: linux-api@vger.kernel.org
---
 arch/alpha/include/uapi/asm/mman.h   |  2 +
 arch/mips/include/uapi/asm/mman.h    |  2 +
 arch/parisc/include/uapi/asm/mman.h  |  2 +
 arch/powerpc/include/uapi/asm/mman.h |  2 +
 arch/sparc/include/uapi/asm/mman.h   |  2 +
 arch/tile/include/uapi/asm/mman.h    |  3 ++
 arch/xtensa/include/uapi/asm/mman.h  |  2 +
 fs/proc/task_mmu.c                   |  1 +
 include/linux/mm.h                   |  1 +
 include/uapi/asm-generic/mman.h      |  2 +
 mm/mlock.c                           | 72 ++++++++++++++++++++++++++----------
 mm/mmap.c                            |  4 +-
 mm/swap.c                            |  3 +-
 13 files changed, 75 insertions(+), 23 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/mman.h b/arch/alpha/include/uapi/asm/mman.h
index ec72436..77ae8db 100644
--- a/arch/alpha/include/uapi/asm/mman.h
+++ b/arch/alpha/include/uapi/asm/mman.h
@@ -37,8 +37,10 @@
 
 #define MCL_CURRENT	 8192		/* lock all currently mapped pages */
 #define MCL_FUTURE	16384		/* lock all additions to address space */
+#define MCL_ONFAULT	32768		/* lock all pages that are faulted in */
 
 #define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+#define MLOCK_ONFAULT	0x02		/* Lock pages in range after they are faulted in, do not prefault */
 
 #define MADV_NORMAL	0		/* no further special treatment */
 #define MADV_RANDOM	1		/* expect random page references */
diff --git a/arch/mips/include/uapi/asm/mman.h b/arch/mips/include/uapi/asm/mman.h
index 67c1cdf..71ed81d 100644
--- a/arch/mips/include/uapi/asm/mman.h
+++ b/arch/mips/include/uapi/asm/mman.h
@@ -61,11 +61,13 @@
  */
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
+#define MCL_ONFAULT	4		/* lock all pages that are faulted in */
 
 /*
  * Flags for mlock
  */
 #define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+#define MLOCK_ONFAULT	0x02		/* Lock pages in range after they are faulted in, do not prefault */
 
 #define MADV_NORMAL	0		/* no further special treatment */
 #define MADV_RANDOM	1		/* expect random page references */
diff --git a/arch/parisc/include/uapi/asm/mman.h b/arch/parisc/include/uapi/asm/mman.h
index daab994..c0871ce 100644
--- a/arch/parisc/include/uapi/asm/mman.h
+++ b/arch/parisc/include/uapi/asm/mman.h
@@ -31,8 +31,10 @@
 
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
+#define MCL_ONFAULT	4		/* lock all pages that are faulted in */
 
 #define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+#define MLOCK_ONFAULT	0x02		/* Lock pages in range after they are faulted in, do not prefault */
 
 #define MADV_NORMAL     0               /* no further special treatment */
 #define MADV_RANDOM     1               /* expect random page references */
diff --git a/arch/powerpc/include/uapi/asm/mman.h b/arch/powerpc/include/uapi/asm/mman.h
index 189e85f..f93f7eb 100644
--- a/arch/powerpc/include/uapi/asm/mman.h
+++ b/arch/powerpc/include/uapi/asm/mman.h
@@ -22,8 +22,10 @@
 
 #define MCL_CURRENT     0x2000          /* lock all currently mapped pages */
 #define MCL_FUTURE      0x4000          /* lock all additions to address space */
+#define MCL_ONFAULT	0x8000		/* lock all pages that are faulted in */
 
 #define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+#define MLOCK_ONFAULT	0x02		/* Lock pages in range after they are faulted in, do not prefault */
 
 #define MAP_POPULATE	0x8000		/* populate (prefault) pagetables */
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
diff --git a/arch/sparc/include/uapi/asm/mman.h b/arch/sparc/include/uapi/asm/mman.h
index 13d51be..8cd2ebc 100644
--- a/arch/sparc/include/uapi/asm/mman.h
+++ b/arch/sparc/include/uapi/asm/mman.h
@@ -17,8 +17,10 @@
 
 #define MCL_CURRENT     0x2000          /* lock all currently mapped pages */
 #define MCL_FUTURE      0x4000          /* lock all additions to address space */
+#define MCL_ONFAULT	0x8000		/* lock all pages that are faulted in */
 
 #define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+#define MLOCK_ONFAULT	0x02		/* Lock pages in range after they are faulted in, do not prefault */
 
 #define MAP_POPULATE	0x8000		/* populate (prefault) pagetables */
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
diff --git a/arch/tile/include/uapi/asm/mman.h b/arch/tile/include/uapi/asm/mman.h
index f69ce48..acdd013 100644
--- a/arch/tile/include/uapi/asm/mman.h
+++ b/arch/tile/include/uapi/asm/mman.h
@@ -36,11 +36,14 @@
  */
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
+#define MCL_ONFAULT	4		/* lock all pages that are faulted in */
+
 
 /*
  * Flags for mlock
  */
 #define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+#define MLOCK_ONFAULT	0x02		/* Lock pages in range after they are faulted in, do not prefault */
 
 
 #endif /* _ASM_TILE_MMAN_H */
diff --git a/arch/xtensa/include/uapi/asm/mman.h b/arch/xtensa/include/uapi/asm/mman.h
index 11f354f..5725a15 100644
--- a/arch/xtensa/include/uapi/asm/mman.h
+++ b/arch/xtensa/include/uapi/asm/mman.h
@@ -74,11 +74,13 @@
  */
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
+#define MCL_ONFAULT	4		/* lock all pages that are faulted in */
 
 /*
  * Flags for mlock
  */
 #define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+#define MLOCK_ONFAULT	0x02		/* Lock pages in range after they are faulted in, do not prefault */
 
 #define MADV_NORMAL	0		/* no further special treatment */
 #define MADV_RANDOM	1		/* expect random page references */
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index ca1e091..38d69fc 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -579,6 +579,7 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
 #ifdef CONFIG_X86_INTEL_MPX
 		[ilog2(VM_MPX)]		= "mp",
 #endif
+		[ilog2(VM_LOCKONFAULT)]	= "lf",
 		[ilog2(VM_LOCKED)]	= "lo",
 		[ilog2(VM_IO)]		= "io",
 		[ilog2(VM_SEQ_READ)]	= "sr",
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 2e872f9..ae40c7d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -127,6 +127,7 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct page", just pure PFN */
 #define VM_DENYWRITE	0x00000800	/* ETXTBSY on write attempts.. */
 
+#define VM_LOCKONFAULT	0x00001000	/* Lock the pages covered when they are faulted in */
 #define VM_LOCKED	0x00002000
 #define VM_IO           0x00004000	/* Memory mapped I/O or similar */
 
diff --git a/include/uapi/asm-generic/mman.h b/include/uapi/asm-generic/mman.h
index 242436b..555aab0 100644
--- a/include/uapi/asm-generic/mman.h
+++ b/include/uapi/asm-generic/mman.h
@@ -17,7 +17,9 @@
 
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
+#define MCL_ONFAULT	4		/* lock all pages that are faulted in */
 
 #define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+#define MLOCK_ONFAULT	0x02		/* Lock pages in range after they are faulted in, do not prefault */
 
 #endif /* __ASM_GENERIC_MMAN_H */
diff --git a/mm/mlock.c b/mm/mlock.c
index d6e61d6..d9414d6 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -502,11 +502,12 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	pgoff_t pgoff;
 	int nr_pages;
 	int ret = 0;
-	int lock = !!(newflags & VM_LOCKED);
+	int lock = !!(newflags & (VM_LOCKED | VM_LOCKONFAULT));
 
 	if (newflags == vma->vm_flags || (vma->vm_flags & VM_SPECIAL) ||
 	    is_vm_hugetlb_page(vma) || vma == get_gate_vma(current->mm))
-		goto out;	/* don't set VM_LOCKED,  don't count */
+		/* don't set VM_LOCKED or VM_LOCKONFAULT and don't count */
+		goto out;
 
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
 	*prev = vma_merge(mm, *prev, start, end, newflags, vma->anon_vma,
@@ -581,10 +582,12 @@ static int apply_vma_flags(unsigned long start, size_t len,
 		/* Here we know that  vma->vm_start <= nstart < vma->vm_end. */
 
 		newflags = vma->vm_flags;
-		if (add_flags)
+		if (add_flags) {
+			newflags &= ~(VM_LOCKED | VM_LOCKONFAULT);
 			newflags |= flags;
-		else
+		} else {
 			newflags &= ~flags;
+		}
 
 		tmp = vma->vm_end;
 		if (tmp > end)
@@ -637,9 +640,12 @@ static int do_mlock(unsigned long start, size_t len, vm_flags_t flags)
 	if (error)
 		return error;
 
-	error = __mm_populate(start, len, 0);
-	if (error)
-		return __mlock_posix_error_return(error);
+	if (flags & VM_LOCKED) {
+		error = __mm_populate(start, len, 0);
+		if (error)
+			return __mlock_posix_error_return(error);
+	}
+
 	return 0;
 }
 
@@ -650,10 +656,14 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
 
 SYSCALL_DEFINE3(mlock2, unsigned long, start, size_t, len, int, flags)
 {
-	if (!flags || flags & ~MLOCK_LOCKED)
+	if (!flags || (flags & ~(MLOCK_LOCKED | MLOCK_ONFAULT)) ||
+	    flags == (MLOCK_LOCKED | MLOCK_ONFAULT))
 		return -EINVAL;
 
-	return do_mlock(start, len, VM_LOCKED);
+	if (flags & MLOCK_LOCKED)
+		return do_mlock(start, len, VM_LOCKED);
+
+	return do_mlock(start, len, VM_LOCKONFAULT);
 }
 
 static int do_munlock(unsigned long start, size_t len, vm_flags_t flags)
@@ -677,26 +687,41 @@ SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
 
 SYSCALL_DEFINE3(munlock2, unsigned long, start, size_t, len, int, flags)
 {
-	if (!flags || flags & ~MLOCK_LOCKED)
+	vm_flags_t to_clear = 0;
+
+	if (!flags || flags & ~(MLOCK_LOCKED | MLOCK_ONFAULT))
 		return -EINVAL;
-	return do_munlock(start, len, VM_LOCKED);
+
+	if (flags & MLOCK_LOCKED)
+		to_clear |= VM_LOCKED;
+	if (flags & MLOCK_ONFAULT)
+		to_clear |= VM_LOCKONFAULT;
+
+	return do_munlock(start, len, to_clear);
 }
 
 static int do_mlockall(int flags)
 {
 	struct vm_area_struct * vma, * prev = NULL;
+	vm_flags_t to_add;
 
 	if (flags & MCL_FUTURE)
 		current->mm->def_flags |= VM_LOCKED;
 	if (flags == MCL_FUTURE)
 		goto out;
 
+	if (flags & MCL_ONFAULT) {
+		current->mm->def_flags |= VM_LOCKONFAULT;
+		to_add = VM_LOCKONFAULT;
+	} else {
+		to_add = VM_LOCKED;
+	}
+
 	for (vma = current->mm->mmap; vma ; vma = prev->vm_next) {
 		vm_flags_t newflags;
 
-		newflags = vma->vm_flags & ~VM_LOCKED;
-		if (flags & MCL_CURRENT)
-			newflags |= VM_LOCKED;
+		newflags = vma->vm_flags & ~(VM_LOCKED | VM_LOCKONFAULT);
+		newflags |= to_add;
 
 		/* Ignore errors */
 		mlock_fixup(vma, &prev, vma->vm_start, vma->vm_end, newflags);
@@ -711,7 +736,8 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 	unsigned long lock_limit;
 	int ret = -EINVAL;
 
-	if (!flags || (flags & ~(MCL_CURRENT | MCL_FUTURE)))
+	if (!flags || (flags & ~(MCL_CURRENT | MCL_FUTURE | MCL_ONFAULT)) ||
+	    (flags & (MCL_FUTURE | MCL_ONFAULT)) == (MCL_FUTURE | MCL_ONFAULT))
 		goto out;
 
 	ret = -EPERM;
@@ -740,18 +766,24 @@ out:
 static int do_munlockall(int flags)
 {
 	struct vm_area_struct * vma, * prev = NULL;
+	vm_flags_t to_clear = 0;
 
 	if (flags & MCL_FUTURE)
 		current->mm->def_flags &= ~VM_LOCKED;
+	if (flags & MCL_ONFAULT)
+		current->mm->def_flags &= ~VM_LOCKONFAULT;
 	if (flags == MCL_FUTURE)
 		goto out;
 
+	if (flags & MCL_CURRENT)
+		to_clear |= VM_LOCKED;
+	if (flags & MCL_ONFAULT)
+		to_clear |= VM_LOCKONFAULT;
+
 	for (vma = current->mm->mmap; vma ; vma = prev->vm_next) {
 		vm_flags_t newflags;
 
-		newflags = vma->vm_flags;
-		if (flags & MCL_CURRENT)
-			newflags &= ~VM_LOCKED;
+		newflags = vma->vm_flags & ~to_clear;
 
 		/* Ignore errors */
 		mlock_fixup(vma, &prev, vma->vm_start, vma->vm_end, newflags);
@@ -766,7 +798,7 @@ SYSCALL_DEFINE0(munlockall)
 	int ret;
 
 	down_write(&current->mm->mmap_sem);
-	ret = do_munlockall(MCL_CURRENT | MCL_FUTURE);
+	ret = do_munlockall(MCL_CURRENT | MCL_FUTURE | MCL_ONFAULT);
 	up_write(&current->mm->mmap_sem);
 	return ret;
 }
@@ -775,7 +807,7 @@ SYSCALL_DEFINE1(munlockall2, int, flags)
 {
 	int ret = -EINVAL;
 
-	if (!flags || flags & ~(MCL_CURRENT | MCL_FUTURE))
+	if (!flags || flags & ~(MCL_CURRENT | MCL_FUTURE | MCL_ONFAULT))
 		return ret;
 
 	down_write(&current->mm->mmap_sem);
diff --git a/mm/mmap.c b/mm/mmap.c
index aa632ad..eb970ba 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1232,8 +1232,8 @@ static inline int mlock_future_check(struct mm_struct *mm,
 {
 	unsigned long locked, lock_limit;
 
-	/*  mlock MCL_FUTURE? */
-	if (flags & VM_LOCKED) {
+	/*  mlock MCL_FUTURE or MCL_ONFAULT? */
+	if (flags & (VM_LOCKED | VM_LOCKONFAULT)) {
 		locked = len >> PAGE_SHIFT;
 		locked += mm->locked_vm;
 		lock_limit = rlimit(RLIMIT_MEMLOCK);
diff --git a/mm/swap.c b/mm/swap.c
index a3a0a2f..3580a21 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -710,7 +710,8 @@ void lru_cache_add_active_or_unevictable(struct page *page,
 {
 	VM_BUG_ON_PAGE(PageLRU(page), page);
 
-	if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED)) {
+	if (likely((vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT)) == 0) ||
+		   (vma->vm_flags & VM_SPECIAL)) {
 		SetPageActive(page);
 		lru_cache_add(page);
 		return;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
