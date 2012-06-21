Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 5A5476B0111
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 17:57:55 -0400 (EDT)
From: Rik van Riel <riel@surriel.com>
Subject: [PATCH -mm v2 07/11] mm: make cache alignment code generic
Date: Thu, 21 Jun 2012 17:57:11 -0400
Message-Id: <1340315835-28571-8-git-send-email-riel@surriel.com>
In-Reply-To: <1340315835-28571-1-git-send-email-riel@surriel.com>
References: <1340315835-28571-1-git-send-email-riel@surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>, Rik van Riel <riel@redhat.com>

Fix the x86-64 cache alignment code to take pgoff into account.
Use the x86 and MIPS cache alignment code as the basis for a generic
cache alignment function.

Teach the generic arch_get_unmapped_area(_topdown) code to call the
cache alignment code.

Make sure that ALIGN_DOWN always aligns down, and ends up at the
right page colour.

The old x86 code will always align the mmap to aliasing boundaries,
even if the program mmaps the file with a non-zero pgoff.

If program A mmaps the file with pgoff 0, and program B mmaps the
file with pgoff 1. The old code would align the mmaps, resulting in
misaligned pages:

A:  0123
B:  123

After this patch, they are aligned so the pages line up:

A: 0123
B:  123

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 arch/mips/include/asm/page.h      |    2 -
 arch/mips/include/asm/pgtable.h   |    1 +
 arch/x86/include/asm/elf.h        |    3 -
 arch/x86/include/asm/pgtable_64.h |    1 +
 arch/x86/kernel/sys_x86_64.c      |   39 +++++++++++-----
 arch/x86/vdso/vma.c               |    2 +-
 include/linux/sched.h             |    8 +++-
 mm/mmap.c                         |   91 ++++++++++++++++++++++++++++++++-----
 8 files changed, 115 insertions(+), 32 deletions(-)

diff --git a/arch/mips/include/asm/page.h b/arch/mips/include/asm/page.h
index da9bd7d..459cc25 100644
--- a/arch/mips/include/asm/page.h
+++ b/arch/mips/include/asm/page.h
@@ -63,8 +63,6 @@ extern void build_copy_page(void);
 extern void clear_page(void * page);
 extern void copy_page(void * to, void * from);
 
-extern unsigned long shm_align_mask;
-
 static inline unsigned long pages_do_alias(unsigned long addr1,
 	unsigned long addr2)
 {
diff --git a/arch/mips/include/asm/pgtable.h b/arch/mips/include/asm/pgtable.h
index b2202a6..f133a4c 100644
--- a/arch/mips/include/asm/pgtable.h
+++ b/arch/mips/include/asm/pgtable.h
@@ -415,6 +415,7 @@ int phys_mem_access_prot_allowed(struct file *file, unsigned long pfn,
  */
 #define HAVE_ARCH_UNMAPPED_AREA
 #define HAVE_ARCH_UNMAPPED_AREA_TOPDOWN
+#define HAVE_ARCH_ALIGN_ADDR
 
 /*
  * No page table caches to initialise
diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
index 5939f44..dc2d0bf 100644
--- a/arch/x86/include/asm/elf.h
+++ b/arch/x86/include/asm/elf.h
@@ -358,8 +358,6 @@ static inline int mmap_is_ia32(void)
 enum align_flags {
 	ALIGN_VA_32	= BIT(0),
 	ALIGN_VA_64	= BIT(1),
-	ALIGN_VDSO	= BIT(2),
-	ALIGN_TOPDOWN	= BIT(3),
 };
 
 struct va_alignment {
@@ -368,5 +366,4 @@ struct va_alignment {
 } ____cacheline_aligned;
 
 extern struct va_alignment va_align;
-extern unsigned long align_addr(unsigned long, struct file *, enum align_flags);
 #endif /* _ASM_X86_ELF_H */
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 8af36f6..8408ccd 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -170,6 +170,7 @@ extern void cleanup_highmap(void);
 #define HAVE_ARCH_UNMAPPED_AREA
 #define HAVE_ARCH_UNMAPPED_AREA_TOPDOWN
 #define HAVE_ARCH_GET_ADDRESS_RANGE
+#define HAVE_ARCH_ALIGN_ADDR
 
 #define pgtable_cache_init()   do { } while (0)
 #define check_pgt_cache()      do { } while (0)
diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index 2595a5e..c059c19 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -25,31 +25,44 @@
  * @flags denotes the allocation direction - bottomup or topdown -
  * or vDSO; see call sites below.
  */
-unsigned long align_addr(unsigned long addr, struct file *filp,
-			 enum align_flags flags)
+unsigned long arch_align_addr(unsigned long addr, struct file *filp,
+			      unsigned long pgoff, unsigned long flags,
+			      enum mmap_allocation_direction direction)
 {
-	unsigned long tmp_addr;
+	unsigned long tmp_addr = PAGE_ALIGN(addr);
 
 	/* handle 32- and 64-bit case with a single conditional */
 	if (va_align.flags < 0 || !(va_align.flags & (2 - mmap_is_ia32())))
-		return addr;
+		return tmp_addr;
 
-	if (!(current->flags & PF_RANDOMIZE))
-		return addr;
+	/* Always allow MAP_FIXED. Colouring is a performance thing only. */
+	if (flags & MAP_FIXED)
+		return tmp_addr;
 
-	if (!((flags & ALIGN_VDSO) || filp))
-		return addr;
+	if (!(current->flags & PF_RANDOMIZE))
+		return tmp_addr;
 
-	tmp_addr = addr;
+	if (!(filp || direction == ALLOC_VDSO))
+		return tmp_addr;
 
 	/*
 	 * We need an address which is <= than the original
 	 * one only when in topdown direction.
 	 */
-	if (!(flags & ALIGN_TOPDOWN))
+	if (direction == ALLOC_UP)
 		tmp_addr += va_align.mask;
 
 	tmp_addr &= ~va_align.mask;
+	tmp_addr += ((pgoff << PAGE_SHIFT) & va_align.mask);
+
+	/*
+	 * When aligning down, make sure we did not accidentally go up.
+	 * The caller will check for underflow.
+	 */
+	if (direction == ALLOC_DOWN && tmp_addr > addr) {
+		tmp_addr -= va_align.mask;
+		tmp_addr &= ~va_align.mask;
+	}
 
 	return tmp_addr;
 }
@@ -159,7 +172,7 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 
 full_search:
 
-	addr = align_addr(addr, filp, 0);
+	addr = arch_align_addr(addr, filp, pgoff, flags, ALLOC_UP);
 
 	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
@@ -186,7 +199,7 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 			mm->cached_hole_size = vma->vm_start - addr;
 
 		addr = vma->vm_end;
-		addr = align_addr(addr, filp, 0);
+		addr = arch_align_addr(addr, filp, pgoff, flags, ALLOC_UP);
 	}
 }
 
@@ -235,7 +248,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 
 	addr -= len;
 	do {
-		addr = align_addr(addr, filp, ALIGN_TOPDOWN);
+		addr = arch_align_addr(addr, filp, pgoff, flags, ALLOC_DOWN);
 
 		/*
 		 * Lookup failure means no vma is above this address,
diff --git a/arch/x86/vdso/vma.c b/arch/x86/vdso/vma.c
index 00aaf04..83e0355 100644
--- a/arch/x86/vdso/vma.c
+++ b/arch/x86/vdso/vma.c
@@ -141,7 +141,7 @@ static unsigned long vdso_addr(unsigned long start, unsigned len)
 	 * unaligned here as a result of stack start randomization.
 	 */
 	addr = PAGE_ALIGN(addr);
-	addr = align_addr(addr, NULL, ALIGN_VDSO);
+	addr = arch_align_addr(addr, NULL, 0, 0, ALLOC_VDSO);
 
 	return addr;
 }
diff --git a/include/linux/sched.h b/include/linux/sched.h
index fc76318..18f9326 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -390,12 +390,18 @@ extern int sysctl_max_map_count;
 #ifdef CONFIG_MMU
 enum mmap_allocation_direction {
 	ALLOC_UP,
-	ALLOC_DOWN
+	ALLOC_DOWN,
+	ALLOC_VDSO,
 };
 extern void arch_pick_mmap_layout(struct mm_struct *mm);
 extern void
 arch_get_address_range(unsigned long flags, unsigned long *begin,
 		unsigned long *end, enum mmap_allocation_direction direction);
+extern unsigned long shm_align_mask;
+extern unsigned long
+arch_align_addr(unsigned long addr, struct file *filp,
+		unsigned long pgoff, unsigned long flags,
+		enum mmap_allocation_direction direction);
 extern unsigned long
 arch_get_unmapped_area(struct file *, unsigned long, unsigned long,
 		       unsigned long, unsigned long);
diff --git a/mm/mmap.c b/mm/mmap.c
index 2420951..3da19f8 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1482,6 +1482,51 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	return error;
 }
 
+#ifndef HAVE_ARCH_ALIGN_ADDR
+/* Each architecture is responsible for setting this to the required value. */
+unsigned long shm_align_mask = PAGE_SIZE - 1;
+EXPORT_SYMBOL(shm_align_mask);
+
+unsigned long arch_align_addr(unsigned long addr, struct file *filp,
+			      unsigned long pgoff, unsigned long flags,
+			      enum mmap_allocation_direction direction)
+{
+	unsigned long tmp_addr = PAGE_ALIGN(addr);
+
+	if (shm_align_mask <= PAGE_SIZE)
+		return tmp_addr;
+
+	/* Allow MAP_FIXED without MAP_SHARED at any address. */
+	if ((flags & (MAP_FIXED|MAP_SHARED)) == MAP_FIXED)
+		return tmp_addr;
+
+	/* Enforce page colouring for any file or MAP_SHARED mapping. */
+	if (!(filp || (flags & MAP_SHARED)))
+		return tmp_addr;
+
+	/*
+	 * We need an address which is <= than the original
+	 * one only when in topdown direction.
+	 */
+	if (direction == ALLOC_UP)
+		tmp_addr += shm_align_mask;
+
+	tmp_addr &= ~shm_align_mask;
+	tmp_addr += ((pgoff << PAGE_SHIFT) & shm_align_mask);
+
+	/*
+	 * When aligning down, make sure we did not accidentally go up.
+	 * The caller will check for underflow.
+	 */
+	if (direction == ALLOC_DOWN && tmp_addr > addr) {
+		tmp_addr -= shm_align_mask;
+		tmp_addr &= ~shm_align_mask;
+	}
+
+	return tmp_addr;
+}
+#endif
+
 #ifndef HAVE_ARCH_GET_ADDRESS_RANGE
 void arch_get_address_range(unsigned long flags, unsigned long *begin,
 		unsigned long *end, enum mmap_allocation_direction direction)
@@ -1515,18 +1560,22 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma = NULL;
 	struct rb_node *rb_node;
-	unsigned long lower_limit, upper_limit;
+	unsigned long lower_limit, upper_limit, tmp_addr;
 
 	arch_get_address_range(flags, &lower_limit, &upper_limit, ALLOC_UP);
 
 	if (len > TASK_SIZE)
 		return -ENOMEM;
 
-	if (flags & MAP_FIXED)
+	if (flags & MAP_FIXED) {
+		tmp_addr = arch_align_addr(addr, filp, pgoff, flags, ALLOC_UP);
+		if (tmp_addr != PAGE_ALIGN(addr))
+			return -EINVAL;
 		return addr;
+	}
 
 	if (addr) {
-		addr = PAGE_ALIGN(addr);
+		addr = arch_align_addr(addr, filp, pgoff, flags, ALLOC_UP);
 		vma = find_vma(mm, addr);
 		if (TASK_SIZE - len >= addr &&
 		    (!vma || addr + len <= vma->vm_start))
@@ -1535,7 +1584,7 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 
 	/* Find the left-most free area of sufficient size. */
 	for (addr = 0, rb_node = mm->mm_rb.rb_node; rb_node; ) {
-		unsigned long vma_start;
+		unsigned long vma_start, tmp_addr;
 		bool found_here = false;
 
 		vma = rb_to_vma(rb_node);
@@ -1543,13 +1592,17 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 		if (vma->vm_start > len) {
 			if (!vma->vm_prev) {
 				/* This is the left-most VMA. */
-				if (vma->vm_start - len >= lower_limit) {
-					addr = lower_limit;
+				tmp_addr = arch_align_addr(lower_limit, filp,
+						pgoff, flags, ALLOC_UP);
+				if (vma->vm_start - len >= tmp_addr) {
+					addr = tmp_addr;
 					goto found_addr;
 				}
 			} else {
 				/* Is this gap large enough? Remember it. */
 				vma_start = max(vma->vm_prev->vm_end, lower_limit);
+				vma_start = arch_align_addr(vma_start, filp,
+						pgoff, flags, ALLOC_UP);
 				if (vma->vm_start - len >= vma_start) {
 					addr = vma_start;
 					found_here = true;
@@ -1601,6 +1654,8 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	if (addr < lower_limit)
 		addr = lower_limit;
 
+	addr = arch_align_addr(addr, filp, pgoff, flags, ALLOC_UP);
+
  found_addr:
 	if (TASK_SIZE - len < addr)
 		return -ENOMEM;
@@ -1643,12 +1698,17 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	if (len > TASK_SIZE)
 		return -ENOMEM;
 
-	if (flags & MAP_FIXED)
+	if (flags & MAP_FIXED) {
+		unsigned long tmp_addr;
+		tmp_addr = arch_align_addr(addr, filp, pgoff, flags, ALLOC_DOWN);
+		if (tmp_addr != PAGE_ALIGN(addr))
+			return -EINVAL;
 		return addr;
+	}
 
 	/* requesting a specific address */
 	if (addr) {
-		addr = PAGE_ALIGN(addr);
+		addr = arch_align_addr(addr, filp, pgoff, flags, ALLOC_DOWN);
 		vma = find_vma(mm, addr);
 		if (TASK_SIZE - len >= addr &&
 				(!vma || addr + len <= vma->vm_start))
@@ -1665,7 +1725,9 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	 */
 	if (upper_limit - len > mm->highest_vm_end) {
 		addr = upper_limit - len;
-		goto found_addr;
+		addr = arch_align_addr(addr, filp, pgoff, flags, ALLOC_DOWN);
+		if (addr >= mm->highest_vm_end);
+			goto found_addr;
 	}
 
 	/* Find the right-most free area of sufficient size. */
@@ -1678,9 +1740,14 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 		/* Is this gap large enough? Remember it. */
 		vma_start = min(vma->vm_start, upper_limit);
 		if (vma_start > len) {
-			if (!vma->vm_prev ||
-			    (vma_start - len >= vma->vm_prev->vm_end)) {
-				addr = vma_start - len;
+			unsigned long tmp_addr = vma_start - len;
+			tmp_addr = arch_align_addr(tmp_addr, filp,
+						   pgoff, flags, ALLOC_DOWN);
+			/* No underflow? Does it still fit the hole? */
+			if (tmp_addr && tmp_addr <= vma_start - len &&
+					(!vma->vm_prev ||
+					 tmp_addr >= vma->vm_prev->vm_end)) {
+				addr = tmp_addr;
 				found_here = true;
 			}
 		}
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
