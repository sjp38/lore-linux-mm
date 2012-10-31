Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id E9AC76B0072
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 06:33:45 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so971403pbb.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2012 03:33:45 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [RFC PATCH 5/6] mm: use vm_unmapped_area() on x86_64 architecture
Date: Wed, 31 Oct 2012 03:33:24 -0700
Message-Id: <1351679605-4816-6-git-send-email-walken@google.com>
In-Reply-To: <1351679605-4816-1-git-send-email-walken@google.com>
References: <1351679605-4816-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org

Signed-off-by: Michel Lespinasse <walken@google.com>

---
 arch/x86/include/asm/elf.h   |    6 +-
 arch/x86/kernel/sys_x86_64.c |  151 ++++++++---------------------------------
 arch/x86/vdso/vma.c          |    2 +-
 3 files changed, 33 insertions(+), 126 deletions(-)

diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
index 5939f44fe0c0..9c999c1674fa 100644
--- a/arch/x86/include/asm/elf.h
+++ b/arch/x86/include/asm/elf.h
@@ -354,12 +354,10 @@ static inline int mmap_is_ia32(void)
 	return 0;
 }
 
-/* The first two values are special, do not change. See align_addr() */
+/* Do not change the values. See get_align_mask() */
 enum align_flags {
 	ALIGN_VA_32	= BIT(0),
 	ALIGN_VA_64	= BIT(1),
-	ALIGN_VDSO	= BIT(2),
-	ALIGN_TOPDOWN	= BIT(3),
 };
 
 struct va_alignment {
@@ -368,5 +366,5 @@ struct va_alignment {
 } ____cacheline_aligned;
 
 extern struct va_alignment va_align;
-extern unsigned long align_addr(unsigned long, struct file *, enum align_flags);
+extern unsigned long align_vdso_addr(unsigned long);
 #endif /* _ASM_X86_ELF_H */
diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index b4d3c3927dd8..fa9227214753 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -21,37 +21,23 @@
 
 /*
  * Align a virtual address to avoid aliasing in the I$ on AMD F15h.
- *
- * @flags denotes the allocation direction - bottomup or topdown -
- * or vDSO; see call sites below.
  */
-unsigned long align_addr(unsigned long addr, struct file *filp,
-			 enum align_flags flags)
+static unsigned long get_align_mask(void)
 {
-	unsigned long tmp_addr;
-
 	/* handle 32- and 64-bit case with a single conditional */
 	if (va_align.flags < 0 || !(va_align.flags & (2 - mmap_is_ia32())))
-		return addr;
+		return 0;
 
 	if (!(current->flags & PF_RANDOMIZE))
-		return addr;
-
-	if (!((flags & ALIGN_VDSO) || filp))
-		return addr;
-
-	tmp_addr = addr;
-
-	/*
-	 * We need an address which is <= than the original
-	 * one only when in topdown direction.
-	 */
-	if (!(flags & ALIGN_TOPDOWN))
-		tmp_addr += va_align.mask;
+		return 0;
 
-	tmp_addr &= ~va_align.mask;
+	return va_align.mask;
+}
 
-	return tmp_addr;
+unsigned long align_vdso_addr(unsigned long addr)
+{
+	unsigned long align_mask = get_align_mask();
+	return (addr + align_mask) & ~align_mask;
 }
 
 static int __init control_va_addr_alignment(char *str)
@@ -126,7 +112,7 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
-	unsigned long start_addr;
+	struct vm_unmapped_area_info info;
 	unsigned long begin, end;
 
 	if (flags & MAP_FIXED)
@@ -144,50 +130,16 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 		    (!vma || addr + len <= vma->vm_start))
 			return addr;
 	}
-	if (((flags & MAP_32BIT) || test_thread_flag(TIF_ADDR32))
-	    && len <= mm->cached_hole_size) {
-		mm->cached_hole_size = 0;
-		mm->free_area_cache = begin;
-	}
-	addr = mm->free_area_cache;
-	if (addr < begin)
-		addr = begin;
-	start_addr = addr;
-
-full_search:
-
-	addr = align_addr(addr, filp, 0);
-
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
-		/* At this point:  (!vma || addr < vma->vm_end). */
-		if (end - len < addr) {
-			/*
-			 * Start a new search - just in case we missed
-			 * some holes.
-			 */
-			if (start_addr != begin) {
-				start_addr = addr = begin;
-				mm->cached_hole_size = 0;
-				goto full_search;
-			}
-			return -ENOMEM;
-		}
-		if (!vma || addr + len <= vma->vm_start) {
-			/*
-			 * Remember the place where we stopped the search:
-			 */
-			mm->free_area_cache = addr + len;
-			return addr;
-		}
-		if (addr + mm->cached_hole_size < vma->vm_start)
-			mm->cached_hole_size = vma->vm_start - addr;
 
-		addr = vma->vm_end;
-		addr = align_addr(addr, filp, 0);
-	}
+	info.flags = 0;
+	info.length = len;
+	info.low_limit = begin;
+	info.high_limit = end;
+	info.align_mask = filp ? get_align_mask() : 0;
+	info.align_offset = 0;
+	return vm_unmapped_area(&info);
 }
 
-
 unsigned long
 arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 			  const unsigned long len, const unsigned long pgoff,
@@ -195,7 +147,8 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 {
 	struct vm_area_struct *vma;
 	struct mm_struct *mm = current->mm;
-	unsigned long addr = addr0, start_addr;
+	unsigned long addr = addr0;
+	struct vm_unmapped_area_info info;
 
 	/* requested length too big for entire address space */
 	if (len > TASK_SIZE)
@@ -217,51 +170,16 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 			return addr;
 	}
 
-	/* check if free_area_cache is useful for us */
-	if (len <= mm->cached_hole_size) {
-		mm->cached_hole_size = 0;
-		mm->free_area_cache = mm->mmap_base;
-	}
-
-try_again:
-	/* either no address requested or can't fit in requested address hole */
-	start_addr = addr = mm->free_area_cache;
-
-	if (addr < len)
-		goto fail;
-
-	addr -= len;
-	do {
-		addr = align_addr(addr, filp, ALIGN_TOPDOWN);
-
-		/*
-		 * Lookup failure means no vma is above this address,
-		 * else if new region fits below vma->vm_start,
-		 * return with success:
-		 */
-		vma = find_vma(mm, addr);
-		if (!vma || addr+len <= vma->vm_start)
-			/* remember the address as a hint for next time */
-			return mm->free_area_cache = addr;
-
-		/* remember the largest hole we saw so far */
-		if (addr + mm->cached_hole_size < vma->vm_start)
-			mm->cached_hole_size = vma->vm_start - addr;
-
-		/* try just below the current vma->vm_start */
-		addr = vma->vm_start-len;
-	} while (len < vma->vm_start);
-
-fail:
-	/*
-	 * if hint left us with no space for the requested
-	 * mapping then try again:
-	 */
-	if (start_addr != mm->mmap_base) {
-		mm->free_area_cache = mm->mmap_base;
-		mm->cached_hole_size = 0;
-		goto try_again;
-	}
+	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
+	info.length = len;
+	info.low_limit = 0;  // XXX could be PAGE_SIZE ???
+	info.high_limit = mm->mmap_base;
+	info.align_mask = filp ? get_align_mask() : 0;
+	info.align_offset = 0;
+	addr = vm_unmapped_area(&info);
+	if (!(addr & ~PAGE_MASK))
+		return addr;
+	VM_BUG_ON(addr != -ENOMEM);
 
 bottomup:
 	/*
@@ -270,14 +188,5 @@ bottomup:
 	 * can happen with large stack limits and large mmap()
 	 * allocations.
 	 */
-	mm->cached_hole_size = ~0UL;
-	mm->free_area_cache = TASK_UNMAPPED_BASE;
-	addr = arch_get_unmapped_area(filp, addr0, len, pgoff, flags);
-	/*
-	 * Restore the topdown base:
-	 */
-	mm->free_area_cache = mm->mmap_base;
-	mm->cached_hole_size = ~0UL;
-
-	return addr;
+	return arch_get_unmapped_area(filp, addr0, len, pgoff, flags);
 }
diff --git a/arch/x86/vdso/vma.c b/arch/x86/vdso/vma.c
index 00aaf047b39f..431e87544411 100644
--- a/arch/x86/vdso/vma.c
+++ b/arch/x86/vdso/vma.c
@@ -141,7 +141,7 @@ static unsigned long vdso_addr(unsigned long start, unsigned len)
 	 * unaligned here as a result of stack start randomization.
 	 */
 	addr = PAGE_ALIGN(addr);
-	addr = align_addr(addr, NULL, ALIGN_VDSO);
+	addr = align_vdso_addr(addr);
 
 	return addr;
 }
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
