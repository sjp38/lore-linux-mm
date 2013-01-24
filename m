Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id BD3736B0012
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 20:30:08 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id kp14so3772437pab.33
        for <linux-mm@kvack.org>; Wed, 23 Jan 2013 17:30:08 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 6/8] mm: remove free_area_cache use in powerpc architecture
Date: Wed, 23 Jan 2013 17:29:49 -0800
Message-Id: <1358990991-21316-7-git-send-email-walken@google.com>
In-Reply-To: <1358990991-21316-1-git-send-email-walken@google.com>
References: <1358990991-21316-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, David Howells <dhowells@redhat.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-parisc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org

As all other architectures have been converted to use vm_unmapped_area(),
we are about to retire the free_area_cache.

This change simply removes the use of that cache in
slice_get_unmapped_area(), which will most certainly have a
performance cost. Next one will convert that function to use the
vm_unmapped_area() infrastructure and regain the performance.

Signed-off-by: Michel Lespinasse <walken@google.com>
Acked-by: Rik van Riel <riel@redhat.com>

---
 arch/powerpc/include/asm/page_64.h       |    3 +-
 arch/powerpc/mm/hugetlbpage.c            |    2 +-
 arch/powerpc/mm/slice.c                  |  108 +++++------------------------
 arch/powerpc/platforms/cell/spufs/file.c |    2 +-
 4 files changed, 22 insertions(+), 93 deletions(-)

diff --git a/arch/powerpc/include/asm/page_64.h b/arch/powerpc/include/asm/page_64.h
index cd915d6b093d..88693cef4f3d 100644
--- a/arch/powerpc/include/asm/page_64.h
+++ b/arch/powerpc/include/asm/page_64.h
@@ -99,8 +99,7 @@ extern unsigned long slice_get_unmapped_area(unsigned long addr,
 					     unsigned long len,
 					     unsigned long flags,
 					     unsigned int psize,
-					     int topdown,
-					     int use_cache);
+					     int topdown);
 
 extern unsigned int get_slice_psize(struct mm_struct *mm,
 				    unsigned long addr);
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 1a6de0a7d8eb..5dc52d803ed8 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -742,7 +742,7 @@ unsigned long hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 	struct hstate *hstate = hstate_file(file);
 	int mmu_psize = shift_to_mmu_psize(huge_page_shift(hstate));
 
-	return slice_get_unmapped_area(addr, len, flags, mmu_psize, 1, 0);
+	return slice_get_unmapped_area(addr, len, flags, mmu_psize, 1);
 }
 #endif
 
diff --git a/arch/powerpc/mm/slice.c b/arch/powerpc/mm/slice.c
index cf9dada734b6..999a74f25ebe 100644
--- a/arch/powerpc/mm/slice.c
+++ b/arch/powerpc/mm/slice.c
@@ -240,23 +240,15 @@ static void slice_convert(struct mm_struct *mm, struct slice_mask mask, int psiz
 static unsigned long slice_find_area_bottomup(struct mm_struct *mm,
 					      unsigned long len,
 					      struct slice_mask available,
-					      int psize, int use_cache)
+					      int psize)
 {
 	struct vm_area_struct *vma;
-	unsigned long start_addr, addr;
+	unsigned long addr;
 	struct slice_mask mask;
 	int pshift = max_t(int, mmu_psize_defs[psize].shift, PAGE_SHIFT);
 
-	if (use_cache) {
-		if (len <= mm->cached_hole_size) {
-			start_addr = addr = TASK_UNMAPPED_BASE;
-			mm->cached_hole_size = 0;
-		} else
-			start_addr = addr = mm->free_area_cache;
-	} else
-		start_addr = addr = TASK_UNMAPPED_BASE;
+	addr = TASK_UNMAPPED_BASE;
 
-full_search:
 	for (;;) {
 		addr = _ALIGN_UP(addr, 1ul << pshift);
 		if ((TASK_SIZE - len) < addr)
@@ -272,63 +264,24 @@ full_search:
 				addr = _ALIGN_UP(addr + 1,  1ul << SLICE_HIGH_SHIFT);
 			continue;
 		}
-		if (!vma || addr + len <= vma->vm_start) {
-			/*
-			 * Remember the place where we stopped the search:
-			 */
-			if (use_cache)
-				mm->free_area_cache = addr + len;
+		if (!vma || addr + len <= vma->vm_start)
 			return addr;
-		}
-		if (use_cache && (addr + mm->cached_hole_size) < vma->vm_start)
-		        mm->cached_hole_size = vma->vm_start - addr;
 		addr = vma->vm_end;
 	}
 
-	/* Make sure we didn't miss any holes */
-	if (use_cache && start_addr != TASK_UNMAPPED_BASE) {
-		start_addr = addr = TASK_UNMAPPED_BASE;
-		mm->cached_hole_size = 0;
-		goto full_search;
-	}
 	return -ENOMEM;
 }
 
 static unsigned long slice_find_area_topdown(struct mm_struct *mm,
 					     unsigned long len,
 					     struct slice_mask available,
-					     int psize, int use_cache)
+					     int psize)
 {
 	struct vm_area_struct *vma;
 	unsigned long addr;
 	struct slice_mask mask;
 	int pshift = max_t(int, mmu_psize_defs[psize].shift, PAGE_SHIFT);
 
-	/* check if free_area_cache is useful for us */
-	if (use_cache) {
-		if (len <= mm->cached_hole_size) {
-			mm->cached_hole_size = 0;
-			mm->free_area_cache = mm->mmap_base;
-		}
-
-		/* either no address requested or can't fit in requested
-		 * address hole
-		 */
-		addr = mm->free_area_cache;
-
-		/* make sure it can fit in the remaining address space */
-		if (addr > len) {
-			addr = _ALIGN_DOWN(addr - len, 1ul << pshift);
-			mask = slice_range_to_mask(addr, len);
-			if (slice_check_fit(mask, available) &&
-			    slice_area_is_free(mm, addr, len))
-					/* remember the address as a hint for
-					 * next time
-					 */
-					return (mm->free_area_cache = addr);
-		}
-	}
-
 	addr = mm->mmap_base;
 	while (addr > len) {
 		/* Go down by chunk size */
@@ -352,16 +305,8 @@ static unsigned long slice_find_area_topdown(struct mm_struct *mm,
 		 * return with success:
 		 */
 		vma = find_vma(mm, addr);
-		if (!vma || (addr + len) <= vma->vm_start) {
-			/* remember the address as a hint for next time */
-			if (use_cache)
-				mm->free_area_cache = addr;
+		if (!vma || (addr + len) <= vma->vm_start)
 			return addr;
-		}
-
-		/* remember the largest hole we saw so far */
-		if (use_cache && (addr + mm->cached_hole_size) < vma->vm_start)
-		        mm->cached_hole_size = vma->vm_start - addr;
 
 		/* try just below the current vma->vm_start */
 		addr = vma->vm_start;
@@ -373,28 +318,18 @@ static unsigned long slice_find_area_topdown(struct mm_struct *mm,
 	 * can happen with large stack limits and large mmap()
 	 * allocations.
 	 */
-	addr = slice_find_area_bottomup(mm, len, available, psize, 0);
-
-	/*
-	 * Restore the topdown base:
-	 */
-	if (use_cache) {
-		mm->free_area_cache = mm->mmap_base;
-		mm->cached_hole_size = ~0UL;
-	}
-
-	return addr;
+	return slice_find_area_bottomup(mm, len, available, psize);
 }
 
 
 static unsigned long slice_find_area(struct mm_struct *mm, unsigned long len,
 				     struct slice_mask mask, int psize,
-				     int topdown, int use_cache)
+				     int topdown)
 {
 	if (topdown)
-		return slice_find_area_topdown(mm, len, mask, psize, use_cache);
+		return slice_find_area_topdown(mm, len, mask, psize);
 	else
-		return slice_find_area_bottomup(mm, len, mask, psize, use_cache);
+		return slice_find_area_bottomup(mm, len, mask, psize);
 }
 
 #define or_mask(dst, src)	do {			\
@@ -415,7 +350,7 @@ static unsigned long slice_find_area(struct mm_struct *mm, unsigned long len,
 
 unsigned long slice_get_unmapped_area(unsigned long addr, unsigned long len,
 				      unsigned long flags, unsigned int psize,
-				      int topdown, int use_cache)
+				      int topdown)
 {
 	struct slice_mask mask = {0, 0};
 	struct slice_mask good_mask;
@@ -430,8 +365,8 @@ unsigned long slice_get_unmapped_area(unsigned long addr, unsigned long len,
 	BUG_ON(mm->task_size == 0);
 
 	slice_dbg("slice_get_unmapped_area(mm=%p, psize=%d...\n", mm, psize);
-	slice_dbg(" addr=%lx, len=%lx, flags=%lx, topdown=%d, use_cache=%d\n",
-		  addr, len, flags, topdown, use_cache);
+	slice_dbg(" addr=%lx, len=%lx, flags=%lx, topdown=%d\n",
+		  addr, len, flags, topdown);
 
 	if (len > mm->task_size)
 		return -ENOMEM;
@@ -503,8 +438,7 @@ unsigned long slice_get_unmapped_area(unsigned long addr, unsigned long len,
 		/* Now let's see if we can find something in the existing
 		 * slices for that size
 		 */
-		newaddr = slice_find_area(mm, len, good_mask, psize, topdown,
-					  use_cache);
+		newaddr = slice_find_area(mm, len, good_mask, psize, topdown);
 		if (newaddr != -ENOMEM) {
 			/* Found within the good mask, we don't have to setup,
 			 * we thus return directly
@@ -536,8 +470,7 @@ unsigned long slice_get_unmapped_area(unsigned long addr, unsigned long len,
 	 * anywhere in the good area.
 	 */
 	if (addr) {
-		addr = slice_find_area(mm, len, good_mask, psize, topdown,
-				       use_cache);
+		addr = slice_find_area(mm, len, good_mask, psize, topdown);
 		if (addr != -ENOMEM) {
 			slice_dbg(" found area at 0x%lx\n", addr);
 			return addr;
@@ -547,15 +480,14 @@ unsigned long slice_get_unmapped_area(unsigned long addr, unsigned long len,
 	/* Now let's see if we can find something in the existing slices
 	 * for that size plus free slices
 	 */
-	addr = slice_find_area(mm, len, potential_mask, psize, topdown,
-			       use_cache);
+	addr = slice_find_area(mm, len, potential_mask, psize, topdown);
 
 #ifdef CONFIG_PPC_64K_PAGES
 	if (addr == -ENOMEM && psize == MMU_PAGE_64K) {
 		/* retry the search with 4k-page slices included */
 		or_mask(potential_mask, compat_mask);
 		addr = slice_find_area(mm, len, potential_mask, psize,
-				       topdown, use_cache);
+				       topdown);
 	}
 #endif
 
@@ -586,8 +518,7 @@ unsigned long arch_get_unmapped_area(struct file *filp,
 				     unsigned long flags)
 {
 	return slice_get_unmapped_area(addr, len, flags,
-				       current->mm->context.user_psize,
-				       0, 1);
+				       current->mm->context.user_psize, 0);
 }
 
 unsigned long arch_get_unmapped_area_topdown(struct file *filp,
@@ -597,8 +528,7 @@ unsigned long arch_get_unmapped_area_topdown(struct file *filp,
 					     const unsigned long flags)
 {
 	return slice_get_unmapped_area(addr0, len, flags,
-				       current->mm->context.user_psize,
-				       1, 1);
+				       current->mm->context.user_psize, 1);
 }
 
 unsigned int get_slice_psize(struct mm_struct *mm, unsigned long addr)
diff --git a/arch/powerpc/platforms/cell/spufs/file.c b/arch/powerpc/platforms/cell/spufs/file.c
index 0cfece4cf6ef..2eb4df2a9388 100644
--- a/arch/powerpc/platforms/cell/spufs/file.c
+++ b/arch/powerpc/platforms/cell/spufs/file.c
@@ -352,7 +352,7 @@ static unsigned long spufs_get_unmapped_area(struct file *file,
 
 	/* Else, try to obtain a 64K pages slice */
 	return slice_get_unmapped_area(addr, len, flags,
-				       MMU_PAGE_64K, 1, 0);
+				       MMU_PAGE_64K, 1);
 }
 #endif /* CONFIG_SPU_FS_64K_LS */
 
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
