Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 3C7566B010A
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 17:57:49 -0400 (EDT)
From: Rik van Riel <riel@surriel.com>
Subject: [PATCH -mm v2 08/11] mm: remove x86 arch_get_unmapped_area(_topdown)
Date: Thu, 21 Jun 2012 17:57:12 -0400
Message-Id: <1340315835-28571-9-git-send-email-riel@surriel.com>
In-Reply-To: <1340315835-28571-1-git-send-email-riel@surriel.com>
References: <1340315835-28571-1-git-send-email-riel@surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>, Rik van Riel <riel@redhat.com>

The generic arch_get_unmapped_area(_topdown) should now be able
to do everything x86 needs.  Remove the x86 specific functions.

TODO: make the hugetlbfs arch_get_unmapped_area call the generic
code with proper alignment info.

Cc: Andi Kleen <andi@firstfloor.org>
Signed-off-by: Rik van Riel <riel@redhat.com>
---
 arch/x86/include/asm/pgtable_64.h |    2 -
 arch/x86/kernel/sys_x86_64.c      |  162 -------------------------------------
 2 files changed, 0 insertions(+), 164 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 8408ccd..0ff6500 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -167,8 +167,6 @@ static inline int pgd_large(pgd_t pgd) { return 0; }
 extern int kern_addr_valid(unsigned long addr);
 extern void cleanup_highmap(void);
 
-#define HAVE_ARCH_UNMAPPED_AREA
-#define HAVE_ARCH_UNMAPPED_AREA_TOPDOWN
 #define HAVE_ARCH_GET_ADDRESS_RANGE
 #define HAVE_ARCH_ALIGN_ADDR
 
diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index c059c19..ee03b18 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -135,165 +135,3 @@ void arch_get_address_range(unsigned long flags, unsigned long *begin,
 		*end = current->mm->mmap_base;
 	}
 }
-
-unsigned long
-arch_get_unmapped_area(struct file *filp, unsigned long addr,
-		unsigned long len, unsigned long pgoff, unsigned long flags)
-{
-	struct mm_struct *mm = current->mm;
-	struct vm_area_struct *vma;
-	unsigned long start_addr;
-	unsigned long begin, end;
-
-	if (flags & MAP_FIXED)
-		return addr;
-
-	arch_get_address_range(flags, &begin, &end, ALLOC_UP);
-
-	if (len > end)
-		return -ENOMEM;
-
-	if (addr) {
-		addr = PAGE_ALIGN(addr);
-		vma = find_vma(mm, addr);
-		if (end - len >= addr &&
-		    (!vma || addr + len <= vma->vm_start))
-			return addr;
-	}
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
-	addr = arch_align_addr(addr, filp, pgoff, flags, ALLOC_UP);
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
-
-		addr = vma->vm_end;
-		addr = arch_align_addr(addr, filp, pgoff, flags, ALLOC_UP);
-	}
-}
-
-
-unsigned long
-arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
-			  const unsigned long len, const unsigned long pgoff,
-			  const unsigned long flags)
-{
-	struct vm_area_struct *vma;
-	struct mm_struct *mm = current->mm;
-	unsigned long addr = addr0, start_addr;
-
-	/* requested length too big for entire address space */
-	if (len > TASK_SIZE)
-		return -ENOMEM;
-
-	if (flags & MAP_FIXED)
-		return addr;
-
-	/* for MAP_32BIT mappings we force the legact mmap base */
-	if (!test_thread_flag(TIF_ADDR32) && (flags & MAP_32BIT))
-		goto bottomup;
-
-	/* requesting a specific address */
-	if (addr) {
-		addr = PAGE_ALIGN(addr);
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
-try_again:
-	/* either no address requested or can't fit in requested address hole */
-	start_addr = addr = mm->free_area_cache;
-
-	if (addr < len)
-		goto fail;
-
-	addr -= len;
-	do {
-		addr = arch_align_addr(addr, filp, pgoff, flags, ALLOC_DOWN);
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
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
