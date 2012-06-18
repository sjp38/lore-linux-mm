Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 3A9006B006E
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 18:06:02 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm 7/7] remove ARM arch_get_unmapped_area functions
Date: Mon, 18 Jun 2012 18:05:26 -0400
Message-Id: <1340057126-31143-8-git-send-email-riel@redhat.com>
In-Reply-To: <1340057126-31143-1-git-send-email-riel@redhat.com>
References: <1340057126-31143-1-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>, Russell King <linux@arm.linux.org.uk>, Rik van Riel <riel@redhat.com>

From: Rik van Riel <riel@surriel.com>

Remove the ARM special variants of arch_get_unmapped_area since the
generic functions should now be able to handle everything.

Untested because I have no ARM hardware.

Cc: Russell King <linux@arm.linux.org.uk>
Signed-off-by: Rik van Riel <riel@redhat.com>
---
 arch/arm/include/asm/pgtable.h |    6 -
 arch/arm/mm/init.c             |    3 +
 arch/arm/mm/mmap.c             |  217 +---------------------------------------
 3 files changed, 4 insertions(+), 222 deletions(-)

diff --git a/arch/arm/include/asm/pgtable.h b/arch/arm/include/asm/pgtable.h
index f66626d..6754183 100644
--- a/arch/arm/include/asm/pgtable.h
+++ b/arch/arm/include/asm/pgtable.h
@@ -296,12 +296,6 @@ static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
 #include <asm-generic/pgtable.h>
 
 /*
- * We provide our own arch_get_unmapped_area to cope with VIPT caches.
- */
-#define HAVE_ARCH_UNMAPPED_AREA
-#define HAVE_ARCH_UNMAPPED_AREA_TOPDOWN
-
-/*
  * remap a physical page `pfn' of size `size' with page protection `prot'
  * into virtual address `from'
  */
diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index f54d592..534dd96 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -600,6 +600,9 @@ void __init mem_init(void)
 	extern u32 itcm_end;
 #endif
 
+	/* Tell the page colouring code what we need. */
+	shm_align_mask = SHMLBA - 1;
+
 	max_mapnr   = pfn_to_page(max_pfn + PHYS_PFN_OFFSET) - mem_map;
 
 	/* this will put all unused low memory onto the freelists */
diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
index ce8cb19..2b1f881 100644
--- a/arch/arm/mm/mmap.c
+++ b/arch/arm/mm/mmap.c
@@ -11,21 +11,7 @@
 #include <linux/random.h>
 #include <asm/cachetype.h>
 
-static inline unsigned long COLOUR_ALIGN_DOWN(unsigned long addr,
-					      unsigned long pgoff)
-{
-	unsigned long base = addr & ~(SHMLBA-1);
-	unsigned long off = (pgoff << PAGE_SHIFT) & (SHMLBA-1);
-
-	if (base + off <= addr)
-		return base + off;
-
-	return base - off;
-}
-
-#define COLOUR_ALIGN(addr,pgoff)		\
-	((((addr)+SHMLBA-1)&~(SHMLBA-1)) +	\
-	 (((pgoff)<<PAGE_SHIFT) & (SHMLBA-1)))
+unsigned long shm_align_mask = SHMLBA - 1;
 
 /* gap between mmap and stack */
 #define MIN_GAP (128*1024*1024UL)
@@ -54,207 +40,6 @@ static unsigned long mmap_base(unsigned long rnd)
 	return PAGE_ALIGN(TASK_SIZE - gap - rnd);
 }
 
-/*
- * We need to ensure that shared mappings are correctly aligned to
- * avoid aliasing issues with VIPT caches.  We need to ensure that
- * a specific page of an object is always mapped at a multiple of
- * SHMLBA bytes.
- *
- * We unconditionally provide this function for all cases, however
- * in the VIVT case, we optimise out the alignment rules.
- */
-unsigned long
-arch_get_unmapped_area(struct file *filp, unsigned long addr,
-		unsigned long len, unsigned long pgoff, unsigned long flags)
-{
-	struct mm_struct *mm = current->mm;
-	struct vm_area_struct *vma;
-	unsigned long start_addr;
-	int do_align = 0;
-	int aliasing = cache_is_vipt_aliasing();
-
-	/*
-	 * We only need to do colour alignment if either the I or D
-	 * caches alias.
-	 */
-	if (aliasing)
-		do_align = filp || (flags & MAP_SHARED);
-
-	/*
-	 * We enforce the MAP_FIXED case.
-	 */
-	if (flags & MAP_FIXED) {
-		if (aliasing && flags & MAP_SHARED &&
-		    (addr - (pgoff << PAGE_SHIFT)) & (SHMLBA - 1))
-			return -EINVAL;
-		return addr;
-	}
-
-	if (len > TASK_SIZE)
-		return -ENOMEM;
-
-	if (addr) {
-		if (do_align)
-			addr = COLOUR_ALIGN(addr, pgoff);
-		else
-			addr = PAGE_ALIGN(addr);
-
-		vma = find_vma(mm, addr);
-		if (TASK_SIZE - len >= addr &&
-		    (!vma || addr + len <= vma->vm_start))
-			return addr;
-	}
-	if (len > mm->cached_hole_size) {
-	        start_addr = addr = mm->free_area_cache;
-	} else {
-	        start_addr = addr = mm->mmap_base;
-	        mm->cached_hole_size = 0;
-	}
-
-full_search:
-	if (do_align)
-		addr = COLOUR_ALIGN(addr, pgoff);
-	else
-		addr = PAGE_ALIGN(addr);
-
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
-		/* At this point:  (!vma || addr < vma->vm_end). */
-		if (TASK_SIZE - len < addr) {
-			/*
-			 * Start a new search - just in case we missed
-			 * some holes.
-			 */
-			if (start_addr != TASK_UNMAPPED_BASE) {
-				start_addr = addr = TASK_UNMAPPED_BASE;
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
-		        mm->cached_hole_size = vma->vm_start - addr;
-		addr = vma->vm_end;
-		if (do_align)
-			addr = COLOUR_ALIGN(addr, pgoff);
-	}
-}
-
-unsigned long
-arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
-			const unsigned long len, const unsigned long pgoff,
-			const unsigned long flags)
-{
-	struct vm_area_struct *vma;
-	struct mm_struct *mm = current->mm;
-	unsigned long addr = addr0;
-	int do_align = 0;
-	int aliasing = cache_is_vipt_aliasing();
-
-	/*
-	 * We only need to do colour alignment if either the I or D
-	 * caches alias.
-	 */
-	if (aliasing)
-		do_align = filp || (flags & MAP_SHARED);
-
-	/* requested length too big for entire address space */
-	if (len > TASK_SIZE)
-		return -ENOMEM;
-
-	if (flags & MAP_FIXED) {
-		if (aliasing && flags & MAP_SHARED &&
-		    (addr - (pgoff << PAGE_SHIFT)) & (SHMLBA - 1))
-			return -EINVAL;
-		return addr;
-	}
-
-	/* requesting a specific address */
-	if (addr) {
-		if (do_align)
-			addr = COLOUR_ALIGN(addr, pgoff);
-		else
-			addr = PAGE_ALIGN(addr);
-		vma = find_vma(mm, addr);
-		if (TASK_SIZE - len >= addr &&
-				(!vma || addr + len <= vma->vm_start))
-			return addr;
-	}
-
-	/* check if free_area_cache is useful for us */
-	if (len <= mm->cached_hole_size) {
-		mm->cached_hole_size = 0;
-		mm->free_area_cache = mm->mmap_base;
-	}
-
-	/* either no address requested or can't fit in requested address hole */
-	addr = mm->free_area_cache;
-	if (do_align) {
-		unsigned long base = COLOUR_ALIGN_DOWN(addr - len, pgoff);
-		addr = base + len;
-	}
-
-	/* make sure it can fit in the remaining address space */
-	if (addr > len) {
-		vma = find_vma(mm, addr-len);
-		if (!vma || addr <= vma->vm_start)
-			/* remember the address as a hint for next time */
-			return (mm->free_area_cache = addr-len);
-	}
-
-	if (mm->mmap_base < len)
-		goto bottomup;
-
-	addr = mm->mmap_base - len;
-	if (do_align)
-		addr = COLOUR_ALIGN_DOWN(addr, pgoff);
-
-	do {
-		/*
-		 * Lookup failure means no vma is above this address,
-		 * else if new region fits below vma->vm_start,
-		 * return with success:
-		 */
-		vma = find_vma(mm, addr);
-		if (!vma || addr+len <= vma->vm_start)
-			/* remember the address as a hint for next time */
-			return (mm->free_area_cache = addr);
-
-		/* remember the largest hole we saw so far */
-		if (addr + mm->cached_hole_size < vma->vm_start)
-			mm->cached_hole_size = vma->vm_start - addr;
-
-		/* try just below the current vma->vm_start */
-		addr = vma->vm_start - len;
-		if (do_align)
-			addr = COLOUR_ALIGN_DOWN(addr, pgoff);
-	} while (len < vma->vm_start);
-
-bottomup:
-	/*
-	 * A failed mmap() very likely causes application failure,
-	 * so fall back to the bottom-up function here. This scenario
-	 * can happen with large stack limits and large mmap()
-	 * allocations.
-	 */
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
-}
-
 void arch_pick_mmap_layout(struct mm_struct *mm)
 {
 	unsigned long random_factor = 0UL;
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
