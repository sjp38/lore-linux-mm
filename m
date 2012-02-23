Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 300D36B007E
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 15:27:01 -0500 (EST)
Date: Thu, 23 Feb 2012 15:00:34 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm 2/2] mm: do not reset mm->free_area_cache on every
 single munmap
Message-ID: <20120223150034.2c757b3a@cuia.bos.redhat.com>
In-Reply-To: <20120223145417.261225fd@cuia.bos.redhat.com>
References: <20120223145417.261225fd@cuia.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, hughd@google.com

Some programs have a large number of VMAs, and make frequent calls
to mmap and munmap. Having munmap constantly cause the search
pointer for get_unmapped_area to get reset can cause a significant
slowdown for such programs. 

Likewise, starting all the way from the top any time we mmap a small 
VMA can greatly increase the amount of time spent in 
arch_get_unmapped_area_topdown.

For programs with many VMAs, a next-fit algorithm would be fastest,
however that could waste a lot of virtual address space, and potentially
page table memory.

A compromise is to reset the search pointer for get_unmapped_area
after we have unmapped 1/8th of the normal memory in a process. For
a process with 1000 similar sized VMAs, that means the search pointer
will only be reset once every 125 or so munmaps.  The cost is that
the program may use about 1/8th more virtual space for these VMAs,
and up to 1/8th more page tables.

We do not count special mappings, since there are programs that
use a large fraction of their address space mapping device memory,
etc.

The benefit is that things scale a lot better, and we remove about
200 lines of code.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
Tested on x86-64, the other architectures have the bug cut'n'pasted.

 arch/arm/mm/mmap.c               |   23 +------------------
 arch/mips/mm/mmap.c              |   16 -------------
 arch/powerpc/mm/slice.c          |   26 ++-------------------
 arch/sh/mm/mmap.c                |   23 +------------------
 arch/sparc/kernel/sys_sparc_64.c |   23 +------------------
 arch/sparc/mm/hugetlbpage.c      |   23 +------------------
 arch/tile/mm/hugetlbpage.c       |   27 +---------------------
 arch/x86/ia32/ia32_aout.c        |    2 +-
 arch/x86/kernel/sys_x86_64.c     |   22 +----------------
 arch/x86/mm/hugetlbpage.c        |   28 +----------------------
 fs/binfmt_aout.c                 |    2 +-
 fs/binfmt_elf.c                  |    2 +-
 include/linux/mm_types.h         |    2 +-
 kernel/fork.c                    |    4 +-
 mm/mmap.c                        |   45 +++++++++++---------------------------
 15 files changed, 32 insertions(+), 236 deletions(-)

diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
index ce8cb19..e435e59 100644
--- a/arch/arm/mm/mmap.c
+++ b/arch/arm/mm/mmap.c
@@ -104,12 +104,7 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 		    (!vma || addr + len <= vma->vm_start))
 			return addr;
 	}
-	if (len > mm->cached_hole_size) {
-	        start_addr = addr = mm->free_area_cache;
-	} else {
-	        start_addr = addr = mm->mmap_base;
-	        mm->cached_hole_size = 0;
-	}
+	start_addr = addr = mm->free_area_cache;
 
 full_search:
 	if (do_align)
@@ -126,7 +121,6 @@ full_search:
 			 */
 			if (start_addr != TASK_UNMAPPED_BASE) {
 				start_addr = addr = TASK_UNMAPPED_BASE;
-				mm->cached_hole_size = 0;
 				goto full_search;
 			}
 			return -ENOMEM;
@@ -138,8 +132,6 @@ full_search:
 			mm->free_area_cache = addr + len;
 			return addr;
 		}
-		if (addr + mm->cached_hole_size < vma->vm_start)
-		        mm->cached_hole_size = vma->vm_start - addr;
 		addr = vma->vm_end;
 		if (do_align)
 			addr = COLOUR_ALIGN(addr, pgoff);
@@ -187,13 +179,6 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 			return addr;
 	}
 
-	/* check if free_area_cache is useful for us */
-	if (len <= mm->cached_hole_size) {
-		mm->cached_hole_size = 0;
-		mm->free_area_cache = mm->mmap_base;
-	}
-
-	/* either no address requested or can't fit in requested address hole */
 	addr = mm->free_area_cache;
 	if (do_align) {
 		unsigned long base = COLOUR_ALIGN_DOWN(addr - len, pgoff);
@@ -226,10 +211,6 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 			/* remember the address as a hint for next time */
 			return (mm->free_area_cache = addr);
 
-		/* remember the largest hole we saw so far */
-		if (addr + mm->cached_hole_size < vma->vm_start)
-			mm->cached_hole_size = vma->vm_start - addr;
-
 		/* try just below the current vma->vm_start */
 		addr = vma->vm_start - len;
 		if (do_align)
@@ -243,14 +224,12 @@ bottomup:
 	 * can happen with large stack limits and large mmap()
 	 * allocations.
 	 */
-	mm->cached_hole_size = ~0UL;
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	addr = arch_get_unmapped_area(filp, addr0, len, pgoff, flags);
 	/*
 	 * Restore the topdown base:
 	 */
 	mm->free_area_cache = mm->mmap_base;
-	mm->cached_hole_size = ~0UL;
 
 	return addr;
 }
diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
index 302d779..eb00860 100644
--- a/arch/mips/mm/mmap.c
+++ b/arch/mips/mm/mmap.c
@@ -125,16 +125,6 @@ static unsigned long arch_get_unmapped_area_common(struct file *filp,
 				addr = COLOUR_ALIGN(addr, pgoff);
 		 }
 	 } else {
-		/* check if free_area_cache is useful for us */
-		if (len <= mm->cached_hole_size) {
-			mm->cached_hole_size = 0;
-			mm->free_area_cache = mm->mmap_base;
-		}
-
-		/*
-		 * either no address requested, or the mapping can't fit into
-		 * the requested address hole
-		 */
 		addr = mm->free_area_cache;
 		if (do_color_align) {
 			unsigned long base =
@@ -170,10 +160,6 @@ static unsigned long arch_get_unmapped_area_common(struct file *filp,
 				return mm->free_area_cache = addr;
 			}
 
-			/* remember the largest hole we saw so far */
-			if (addr + mm->cached_hole_size < vma->vm_start)
-				mm->cached_hole_size = vma->vm_start - addr;
-
 			/* try just below the current vma->vm_start */
 			addr = vma->vm_start - len;
 			if (do_color_align)
@@ -187,14 +173,12 @@ bottomup:
 		 * can happen with large stack limits and large mmap()
 		 * allocations.
 		 */
-		mm->cached_hole_size = ~0UL;
 		mm->free_area_cache = TASK_UNMAPPED_BASE;
 		addr = arch_get_unmapped_area(filp, addr0, len, pgoff, flags);
 		/*
 		 * Restore the topdown base:
 		 */
 		mm->free_area_cache = mm->mmap_base;
-		mm->cached_hole_size = ~0UL;
 
 		return addr;
 	}
diff --git a/arch/powerpc/mm/slice.c b/arch/powerpc/mm/slice.c
index 73709f7..6435c53 100644
--- a/arch/powerpc/mm/slice.c
+++ b/arch/powerpc/mm/slice.c
@@ -231,13 +231,9 @@ static unsigned long slice_find_area_bottomup(struct mm_struct *mm,
 	struct slice_mask mask;
 	int pshift = max_t(int, mmu_psize_defs[psize].shift, PAGE_SHIFT);
 
-	if (use_cache) {
-		if (len <= mm->cached_hole_size) {
-			start_addr = addr = TASK_UNMAPPED_BASE;
-			mm->cached_hole_size = 0;
-		} else
-			start_addr = addr = mm->free_area_cache;
-	} else
+	if (use_cache)
+		start_addr = addr = mm->free_area_cache;
+	else
 		start_addr = addr = TASK_UNMAPPED_BASE;
 
 full_search:
@@ -264,15 +260,12 @@ full_search:
 				mm->free_area_cache = addr + len;
 			return addr;
 		}
-		if (use_cache && (addr + mm->cached_hole_size) < vma->vm_start)
-		        mm->cached_hole_size = vma->vm_start - addr;
 		addr = vma->vm_end;
 	}
 
 	/* Make sure we didn't miss any holes */
 	if (use_cache && start_addr != TASK_UNMAPPED_BASE) {
 		start_addr = addr = TASK_UNMAPPED_BASE;
-		mm->cached_hole_size = 0;
 		goto full_search;
 	}
 	return -ENOMEM;
@@ -290,14 +283,6 @@ static unsigned long slice_find_area_topdown(struct mm_struct *mm,
 
 	/* check if free_area_cache is useful for us */
 	if (use_cache) {
-		if (len <= mm->cached_hole_size) {
-			mm->cached_hole_size = 0;
-			mm->free_area_cache = mm->mmap_base;
-		}
-
-		/* either no address requested or can't fit in requested
-		 * address hole
-		 */
 		addr = mm->free_area_cache;
 
 		/* make sure it can fit in the remaining address space */
@@ -343,10 +328,6 @@ static unsigned long slice_find_area_topdown(struct mm_struct *mm,
 			return addr;
 		}
 
-		/* remember the largest hole we saw so far */
-		if (use_cache && (addr + mm->cached_hole_size) < vma->vm_start)
-		        mm->cached_hole_size = vma->vm_start - addr;
-
 		/* try just below the current vma->vm_start */
 		addr = vma->vm_start;
 	}
@@ -364,7 +345,6 @@ static unsigned long slice_find_area_topdown(struct mm_struct *mm,
 	 */
 	if (use_cache) {
 		mm->free_area_cache = mm->mmap_base;
-		mm->cached_hole_size = ~0UL;
 	}
 
 	return addr;
diff --git a/arch/sh/mm/mmap.c b/arch/sh/mm/mmap.c
index fba1b32..a6e373a 100644
--- a/arch/sh/mm/mmap.c
+++ b/arch/sh/mm/mmap.c
@@ -79,12 +79,7 @@ unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr,
 			return addr;
 	}
 
-	if (len > mm->cached_hole_size) {
-		start_addr = addr = mm->free_area_cache;
-	} else {
-	        mm->cached_hole_size = 0;
-		start_addr = addr = TASK_UNMAPPED_BASE;
-	}
+	start_addr = addr = mm->free_area_cache;
 
 full_search:
 	if (do_colour_align)
@@ -101,7 +96,6 @@ full_search:
 			 */
 			if (start_addr != TASK_UNMAPPED_BASE) {
 				start_addr = addr = TASK_UNMAPPED_BASE;
-				mm->cached_hole_size = 0;
 				goto full_search;
 			}
 			return -ENOMEM;
@@ -113,8 +107,6 @@ full_search:
 			mm->free_area_cache = addr + len;
 			return addr;
 		}
-		if (addr + mm->cached_hole_size < vma->vm_start)
-		        mm->cached_hole_size = vma->vm_start - addr;
 
 		addr = vma->vm_end;
 		if (do_colour_align)
@@ -162,13 +154,6 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 			return addr;
 	}
 
-	/* check if free_area_cache is useful for us */
-	if (len <= mm->cached_hole_size) {
-	        mm->cached_hole_size = 0;
-		mm->free_area_cache = mm->mmap_base;
-	}
-
-	/* either no address requested or can't fit in requested address hole */
 	addr = mm->free_area_cache;
 	if (do_colour_align) {
 		unsigned long base = COLOUR_ALIGN_DOWN(addr-len, pgoff);
@@ -203,10 +188,6 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 			return (mm->free_area_cache = addr);
 		}
 
-		/* remember the largest hole we saw so far */
-		if (addr + mm->cached_hole_size < vma->vm_start)
-		        mm->cached_hole_size = vma->vm_start - addr;
-
 		/* try just below the current vma->vm_start */
 		addr = vma->vm_start-len;
 		if (do_colour_align)
@@ -220,14 +201,12 @@ bottomup:
 	 * can happen with large stack limits and large mmap()
 	 * allocations.
 	 */
-	mm->cached_hole_size = ~0UL;
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	addr = arch_get_unmapped_area(filp, addr0, len, pgoff, flags);
 	/*
 	 * Restore the topdown base:
 	 */
 	mm->free_area_cache = mm->mmap_base;
-	mm->cached_hole_size = ~0UL;
 
 	return addr;
 }
diff --git a/arch/sparc/kernel/sys_sparc_64.c b/arch/sparc/kernel/sys_sparc_64.c
index 232df99..edd5657 100644
--- a/arch/sparc/kernel/sys_sparc_64.c
+++ b/arch/sparc/kernel/sys_sparc_64.c
@@ -151,12 +151,7 @@ unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr, unsi
 			return addr;
 	}
 
-	if (len > mm->cached_hole_size) {
-	        start_addr = addr = mm->free_area_cache;
-	} else {
-	        start_addr = addr = TASK_UNMAPPED_BASE;
-	        mm->cached_hole_size = 0;
-	}
+	start_addr = addr = mm->free_area_cache;
 
 	task_size -= len;
 
@@ -176,7 +171,6 @@ full_search:
 		if (unlikely(task_size < addr)) {
 			if (start_addr != TASK_UNMAPPED_BASE) {
 				start_addr = addr = TASK_UNMAPPED_BASE;
-				mm->cached_hole_size = 0;
 				goto full_search;
 			}
 			return -ENOMEM;
@@ -188,8 +182,6 @@ full_search:
 			mm->free_area_cache = addr + len;
 			return addr;
 		}
-		if (addr + mm->cached_hole_size < vma->vm_start)
-		        mm->cached_hole_size = vma->vm_start - addr;
 
 		addr = vma->vm_end;
 		if (do_color_align)
@@ -241,13 +233,6 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 			return addr;
 	}
 
-	/* check if free_area_cache is useful for us */
-	if (len <= mm->cached_hole_size) {
- 	        mm->cached_hole_size = 0;
- 		mm->free_area_cache = mm->mmap_base;
- 	}
-
-	/* either no address requested or can't fit in requested address hole */
 	addr = mm->free_area_cache;
 	if (do_color_align) {
 		unsigned long base = COLOUR_ALIGN_DOWN(addr-len, pgoff);
@@ -283,10 +268,6 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 			return (mm->free_area_cache = addr);
 		}
 
- 		/* remember the largest hole we saw so far */
- 		if (addr + mm->cached_hole_size < vma->vm_start)
- 		        mm->cached_hole_size = vma->vm_start - addr;
-
 		/* try just below the current vma->vm_start */
 		addr = vma->vm_start-len;
 		if (do_color_align)
@@ -300,14 +281,12 @@ bottomup:
 	 * can happen with large stack limits and large mmap()
 	 * allocations.
 	 */
-	mm->cached_hole_size = ~0UL;
   	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	addr = arch_get_unmapped_area(filp, addr0, len, pgoff, flags);
 	/*
 	 * Restore the topdown base:
 	 */
 	mm->free_area_cache = mm->mmap_base;
-	mm->cached_hole_size = ~0UL;
 
 	return addr;
 }
diff --git a/arch/sparc/mm/hugetlbpage.c b/arch/sparc/mm/hugetlbpage.c
index 603a01d..ecc0703 100644
--- a/arch/sparc/mm/hugetlbpage.c
+++ b/arch/sparc/mm/hugetlbpage.c
@@ -40,12 +40,7 @@ static unsigned long hugetlb_get_unmapped_area_bottomup(struct file *filp,
 	if (unlikely(len >= VA_EXCLUDE_START))
 		return -ENOMEM;
 
-	if (len > mm->cached_hole_size) {
-	        start_addr = addr = mm->free_area_cache;
-	} else {
-	        start_addr = addr = TASK_UNMAPPED_BASE;
-	        mm->cached_hole_size = 0;
-	}
+	start_addr = addr = mm->free_area_cache;
 
 	task_size -= len;
 
@@ -62,7 +57,6 @@ full_search:
 		if (unlikely(task_size < addr)) {
 			if (start_addr != TASK_UNMAPPED_BASE) {
 				start_addr = addr = TASK_UNMAPPED_BASE;
-				mm->cached_hole_size = 0;
 				goto full_search;
 			}
 			return -ENOMEM;
@@ -74,8 +68,6 @@ full_search:
 			mm->free_area_cache = addr + len;
 			return addr;
 		}
-		if (addr + mm->cached_hole_size < vma->vm_start)
-		        mm->cached_hole_size = vma->vm_start - addr;
 
 		addr = ALIGN(vma->vm_end, HPAGE_SIZE);
 	}
@@ -94,13 +86,6 @@ hugetlb_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	/* This should only ever run for 32-bit processes.  */
 	BUG_ON(!test_thread_flag(TIF_32BIT));
 
-	/* check if free_area_cache is useful for us */
-	if (len <= mm->cached_hole_size) {
- 	        mm->cached_hole_size = 0;
- 		mm->free_area_cache = mm->mmap_base;
- 	}
-
-	/* either no address requested or can't fit in requested address hole */
 	addr = mm->free_area_cache & HPAGE_MASK;
 
 	/* make sure it can fit in the remaining address space */
@@ -127,10 +112,6 @@ hugetlb_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 			return (mm->free_area_cache = addr);
 		}
 
- 		/* remember the largest hole we saw so far */
- 		if (addr + mm->cached_hole_size < vma->vm_start)
- 		        mm->cached_hole_size = vma->vm_start - addr;
-
 		/* try just below the current vma->vm_start */
 		addr = (vma->vm_start-len) & HPAGE_MASK;
 	} while (likely(len < vma->vm_start));
@@ -142,14 +123,12 @@ bottomup:
 	 * can happen with large stack limits and large mmap()
 	 * allocations.
 	 */
-	mm->cached_hole_size = ~0UL;
   	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	addr = arch_get_unmapped_area(filp, addr0, len, pgoff, flags);
 	/*
 	 * Restore the topdown base:
 	 */
 	mm->free_area_cache = mm->mmap_base;
-	mm->cached_hole_size = ~0UL;
 
 	return addr;
 }
diff --git a/arch/tile/mm/hugetlbpage.c b/arch/tile/mm/hugetlbpage.c
index 42cfcba..5e05e49 100644
--- a/arch/tile/mm/hugetlbpage.c
+++ b/arch/tile/mm/hugetlbpage.c
@@ -161,12 +161,7 @@ static unsigned long hugetlb_get_unmapped_area_bottomup(struct file *file,
 	struct vm_area_struct *vma;
 	unsigned long start_addr;
 
-	if (len > mm->cached_hole_size) {
-		start_addr = mm->free_area_cache;
-	} else {
-		start_addr = TASK_UNMAPPED_BASE;
-		mm->cached_hole_size = 0;
-	}
+	start_addr = mm->free_area_cache;
 
 full_search:
 	addr = ALIGN(start_addr, huge_page_size(h));
@@ -180,7 +175,6 @@ full_search:
 			 */
 			if (start_addr != TASK_UNMAPPED_BASE) {
 				start_addr = TASK_UNMAPPED_BASE;
-				mm->cached_hole_size = 0;
 				goto full_search;
 			}
 			return -ENOMEM;
@@ -189,8 +183,6 @@ full_search:
 			mm->free_area_cache = addr + len;
 			return addr;
 		}
-		if (addr + mm->cached_hole_size < vma->vm_start)
-			mm->cached_hole_size = vma->vm_start - addr;
 		addr = ALIGN(vma->vm_end, huge_page_size(h));
 	}
 }
@@ -203,17 +195,12 @@ static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma, *prev_vma;
 	unsigned long base = mm->mmap_base, addr = addr0;
-	unsigned long largest_hole = mm->cached_hole_size;
 	int first_time = 1;
 
 	/* don't allow allocations above current base */
 	if (mm->free_area_cache > base)
 		mm->free_area_cache = base;
 
-	if (len <= largest_hole) {
-		largest_hole = 0;
-		mm->free_area_cache  = base;
-	}
 try_again:
 	/* make sure it can fit in the remaining address space */
 	if (mm->free_area_cache < len)
@@ -239,21 +226,14 @@ try_again:
 		if (addr + len <= vma->vm_start &&
 			    (!prev_vma || (addr >= prev_vma->vm_end))) {
 			/* remember the address as a hint for next time */
-			mm->cached_hole_size = largest_hole;
 			mm->free_area_cache = addr;
 			return addr;
 		} else {
 			/* pull free_area_cache down to the first hole */
-			if (mm->free_area_cache == vma->vm_end) {
+			if (mm->free_area_cache == vma->vm_end)
 				mm->free_area_cache = vma->vm_start;
-				mm->cached_hole_size = largest_hole;
-			}
 		}
 
-		/* remember the largest hole we saw so far */
-		if (addr + largest_hole < vma->vm_start)
-			largest_hole = vma->vm_start - addr;
-
 		/* try just below the current vma->vm_start */
 		addr = (vma->vm_start - len) & huge_page_mask(h);
 
@@ -266,7 +246,6 @@ fail:
 	 */
 	if (first_time) {
 		mm->free_area_cache = base;
-		largest_hole = 0;
 		first_time = 0;
 		goto try_again;
 	}
@@ -277,7 +256,6 @@ fail:
 	 * allocations.
 	 */
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
-	mm->cached_hole_size = ~0UL;
 	addr = hugetlb_get_unmapped_area_bottomup(file, addr0,
 			len, pgoff, flags);
 
@@ -285,7 +263,6 @@ fail:
 	 * Restore the topdown base:
 	 */
 	mm->free_area_cache = base;
-	mm->cached_hole_size = ~0UL;
 
 	return addr;
 }
diff --git a/arch/x86/ia32/ia32_aout.c b/arch/x86/ia32/ia32_aout.c
index fd84387..c4d3e3b 100644
--- a/arch/x86/ia32/ia32_aout.c
+++ b/arch/x86/ia32/ia32_aout.c
@@ -313,7 +313,7 @@ static int load_aout_binary(struct linux_binprm *bprm, struct pt_regs *regs)
 	current->mm->brk = ex.a_bss +
 		(current->mm->start_brk = N_BSSADDR(ex));
 	current->mm->free_area_cache = TASK_UNMAPPED_BASE;
-	current->mm->cached_hole_size = 0;
+	current->mm->freed_area = 0;
 
 	install_exec_creds(bprm);
 	current->flags &= ~PF_FORKNOEXEC;
diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index 1a3fa81..8254e3a 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -144,11 +144,9 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 		    (!vma || addr + len <= vma->vm_start))
 			return addr;
 	}
-	if (((flags & MAP_32BIT) || test_thread_flag(TIF_IA32))
-	    && len <= mm->cached_hole_size) {
-		mm->cached_hole_size = 0;
+	if (((flags & MAP_32BIT) || test_thread_flag(TIF_IA32)))
 		mm->free_area_cache = begin;
-	}
+
 	addr = mm->free_area_cache;
 	if (addr < begin)
 		addr = begin;
@@ -167,7 +165,6 @@ full_search:
 			 */
 			if (start_addr != begin) {
 				start_addr = addr = begin;
-				mm->cached_hole_size = 0;
 				goto full_search;
 			}
 			return -ENOMEM;
@@ -179,8 +176,6 @@ full_search:
 			mm->free_area_cache = addr + len;
 			return addr;
 		}
-		if (addr + mm->cached_hole_size < vma->vm_start)
-			mm->cached_hole_size = vma->vm_start - addr;
 
 		addr = vma->vm_end;
 		addr = align_addr(addr, filp, 0);
@@ -217,13 +212,6 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 			return addr;
 	}
 
-	/* check if free_area_cache is useful for us */
-	if (len <= mm->cached_hole_size) {
-		mm->cached_hole_size = 0;
-		mm->free_area_cache = mm->mmap_base;
-	}
-
-	/* either no address requested or can't fit in requested address hole */
 	addr = mm->free_area_cache;
 
 	/* make sure it can fit in the remaining address space */
@@ -253,10 +241,6 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 			/* remember the address as a hint for next time */
 			return mm->free_area_cache = addr;
 
-		/* remember the largest hole we saw so far */
-		if (addr + mm->cached_hole_size < vma->vm_start)
-			mm->cached_hole_size = vma->vm_start - addr;
-
 		/* try just below the current vma->vm_start */
 		addr = vma->vm_start-len;
 	} while (len < vma->vm_start);
@@ -268,14 +252,12 @@ bottomup:
 	 * can happen with large stack limits and large mmap()
 	 * allocations.
 	 */
-	mm->cached_hole_size = ~0UL;
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	addr = arch_get_unmapped_area(filp, addr0, len, pgoff, flags);
 	/*
 	 * Restore the topdown base:
 	 */
 	mm->free_area_cache = mm->mmap_base;
-	mm->cached_hole_size = ~0UL;
 
 	return addr;
 }
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index f581a18..84f2346 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -268,12 +268,7 @@ static unsigned long hugetlb_get_unmapped_area_bottomup(struct file *file,
 	struct vm_area_struct *vma;
 	unsigned long start_addr;
 
-	if (len > mm->cached_hole_size) {
-	        start_addr = mm->free_area_cache;
-	} else {
-	        start_addr = TASK_UNMAPPED_BASE;
-	        mm->cached_hole_size = 0;
-	}
+	start_addr = mm->free_area_cache;
 
 full_search:
 	addr = ALIGN(start_addr, huge_page_size(h));
@@ -287,7 +282,6 @@ full_search:
 			 */
 			if (start_addr != TASK_UNMAPPED_BASE) {
 				start_addr = TASK_UNMAPPED_BASE;
-				mm->cached_hole_size = 0;
 				goto full_search;
 			}
 			return -ENOMEM;
@@ -296,8 +290,6 @@ full_search:
 			mm->free_area_cache = addr + len;
 			return addr;
 		}
-		if (addr + mm->cached_hole_size < vma->vm_start)
-		        mm->cached_hole_size = vma->vm_start - addr;
 		addr = ALIGN(vma->vm_end, huge_page_size(h));
 	}
 }
@@ -310,17 +302,12 @@ static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma, *prev_vma;
 	unsigned long base = mm->mmap_base, addr = addr0;
-	unsigned long largest_hole = mm->cached_hole_size;
 	int first_time = 1;
 
 	/* don't allow allocations above current base */
 	if (mm->free_area_cache > base)
 		mm->free_area_cache = base;
 
-	if (len <= largest_hole) {
-	        largest_hole = 0;
-		mm->free_area_cache  = base;
-	}
 try_again:
 	/* make sure it can fit in the remaining address space */
 	if (mm->free_area_cache < len)
@@ -342,21 +329,13 @@ try_again:
 		 */
 		if (addr + len <= vma->vm_start &&
 		            (!prev_vma || (addr >= prev_vma->vm_end))) {
-			/* remember the address as a hint for next time */
-		        mm->cached_hole_size = largest_hole;
 		        return (mm->free_area_cache = addr);
 		} else {
 			/* pull free_area_cache down to the first hole */
-		        if (mm->free_area_cache == vma->vm_end) {
+		        if (mm->free_area_cache == vma->vm_end)
 				mm->free_area_cache = vma->vm_start;
-				mm->cached_hole_size = largest_hole;
-			}
 		}
 
-		/* remember the largest hole we saw so far */
-		if (addr + largest_hole < vma->vm_start)
-		        largest_hole = vma->vm_start - addr;
-
 		/* try just below the current vma->vm_start */
 		addr = (vma->vm_start - len) & huge_page_mask(h);
 	} while (len <= vma->vm_start);
@@ -368,7 +347,6 @@ fail:
 	 */
 	if (first_time) {
 		mm->free_area_cache = base;
-		largest_hole = 0;
 		first_time = 0;
 		goto try_again;
 	}
@@ -379,7 +357,6 @@ fail:
 	 * allocations.
 	 */
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
-	mm->cached_hole_size = ~0UL;
 	addr = hugetlb_get_unmapped_area_bottomup(file, addr0,
 			len, pgoff, flags);
 
@@ -387,7 +364,6 @@ fail:
 	 * Restore the topdown base:
 	 */
 	mm->free_area_cache = base;
-	mm->cached_hole_size = ~0UL;
 
 	return addr;
 }
diff --git a/fs/binfmt_aout.c b/fs/binfmt_aout.c
index a6395bd..d1fe7ea 100644
--- a/fs/binfmt_aout.c
+++ b/fs/binfmt_aout.c
@@ -257,7 +257,7 @@ static int load_aout_binary(struct linux_binprm * bprm, struct pt_regs * regs)
 	current->mm->brk = ex.a_bss +
 		(current->mm->start_brk = N_BSSADDR(ex));
 	current->mm->free_area_cache = current->mm->mmap_base;
-	current->mm->cached_hole_size = 0;
+	current->mm->freed_area = 0;
 
 	install_exec_creds(bprm);
  	current->flags &= ~PF_FORKNOEXEC;
diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index bcb884e..dc1c780 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -729,7 +729,7 @@ static int load_elf_binary(struct linux_binprm *bprm, struct pt_regs *regs)
 	/* Do this so that we can load the interpreter, if need be.  We will
 	   change some of these later */
 	current->mm->free_area_cache = current->mm->mmap_base;
-	current->mm->cached_hole_size = 0;
+	current->mm->freed_area = 0;
 	retval = setup_arg_pages(bprm, randomize_stack_top(STACK_TOP),
 				 executable_stack);
 	if (retval < 0) {
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 3cc3062..2737578 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -297,7 +297,7 @@ struct mm_struct {
 #endif
 	unsigned long mmap_base;		/* base of mmap area */
 	unsigned long task_size;		/* size of task vm space */
-	unsigned long cached_hole_size; 	/* if non-zero, the largest hole below free_area_cache */
+	unsigned long freed_area;		/* amount of recently unmapped space */
 	unsigned long free_area_cache;		/* first hole of size cached_hole_size or larger */
 	pgd_t * pgd;
 	atomic_t mm_users;			/* How many users with user space? */
diff --git a/kernel/fork.c b/kernel/fork.c
index b77fd55..9c336fa 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -326,7 +326,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 	mm->mmap = NULL;
 	mm->mmap_cache = NULL;
 	mm->free_area_cache = oldmm->mmap_base;
-	mm->cached_hole_size = ~0UL;
+	mm->freed_area = 0;
 	mm->map_count = 0;
 	cpumask_clear(mm_cpumask(mm));
 	mm->mm_rb = RB_ROOT;
@@ -496,7 +496,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 	memset(&mm->rss_stat, 0, sizeof(mm->rss_stat));
 	spin_lock_init(&mm->page_table_lock);
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
-	mm->cached_hole_size = ~0UL;
+	mm->freed_area = 0;
 	mm_init_aio(mm);
 	mm_init_owner(mm, p);
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 5eafe26..8864eab 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1381,12 +1381,7 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 		    (!vma || addr + len <= vma->vm_start))
 			return addr;
 	}
-	if (len > mm->cached_hole_size) {
-	        start_addr = addr = mm->free_area_cache;
-	} else {
-	        start_addr = addr = TASK_UNMAPPED_BASE;
-	        mm->cached_hole_size = 0;
-	}
+	start_addr = addr = mm->free_area_cache;
 
 full_search:
 	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
@@ -1399,7 +1394,6 @@ full_search:
 			if (start_addr != TASK_UNMAPPED_BASE) {
 				addr = TASK_UNMAPPED_BASE;
 			        start_addr = addr;
-				mm->cached_hole_size = 0;
 				goto full_search;
 			}
 			return -ENOMEM;
@@ -1411,8 +1405,6 @@ full_search:
 			mm->free_area_cache = addr + len;
 			return addr;
 		}
-		if (addr + mm->cached_hole_size < vma->vm_start)
-		        mm->cached_hole_size = vma->vm_start - addr;
 		addr = vma->vm_end;
 	}
 }
@@ -1421,11 +1413,12 @@ full_search:
 void arch_unmap_area(struct mm_struct *mm, unsigned long addr)
 {
 	/*
-	 * Is this a new hole at the lowest possible address?
+	 * Go back to first-fit search once more than 1/8th of normal
+	 * process memory has been unmapped.
 	 */
-	if (addr >= TASK_UNMAPPED_BASE && addr < mm->free_area_cache) {
-		mm->free_area_cache = addr;
-		mm->cached_hole_size = ~0UL;
+	if (mm->freed_area > (mm->total_vm - mm->reserved_vm) / 8) {
+		mm->free_area_cache = TASK_UNMAPPED_BASE;
+		mm->freed_area = 0;
 	}
 }
 
@@ -1459,13 +1452,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 			return addr;
 	}
 
-	/* check if free_area_cache is useful for us */
-	if (len <= mm->cached_hole_size) {
- 	        mm->cached_hole_size = 0;
- 		mm->free_area_cache = mm->mmap_base;
- 	}
-
-	/* either no address requested or can't fit in requested address hole */
+	/* use a next fit algorithm to quickly find a free area */
 	addr = mm->free_area_cache;
 
 	/* make sure it can fit in the remaining address space */
@@ -1490,10 +1477,6 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 			/* remember the address as a hint for next time */
 			return (mm->free_area_cache = addr);
 
- 		/* remember the largest hole we saw so far */
- 		if (addr + mm->cached_hole_size < vma->vm_start)
- 		        mm->cached_hole_size = vma->vm_start - addr;
-
 		/* try just below the current vma->vm_start */
 		addr = vma->vm_start-len;
 	} while (len < vma->vm_start);
@@ -1505,14 +1488,12 @@ bottomup:
 	 * can happen with large stack limits and large mmap()
 	 * allocations.
 	 */
-	mm->cached_hole_size = ~0UL;
   	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	addr = arch_get_unmapped_area(filp, addr0, len, pgoff, flags);
 	/*
 	 * Restore the topdown base:
 	 */
 	mm->free_area_cache = mm->mmap_base;
-	mm->cached_hole_size = ~0UL;
 
 	return addr;
 }
@@ -1521,14 +1502,13 @@ bottomup:
 void arch_unmap_area_topdown(struct mm_struct *mm, unsigned long addr)
 {
 	/*
-	 * Is this a new hole at the highest possible address?
+	 * Go back to first-fit search once more than 1/8th of normal
+	 * process memory has been unmapped.
 	 */
-	if (addr > mm->free_area_cache)
-		mm->free_area_cache = addr;
-
-	/* dont allow allocations above current base */
-	if (mm->free_area_cache > mm->mmap_base)
+	if (mm->freed_area > (mm->total_vm - mm->reserved_vm) / 8) {
 		mm->free_area_cache = mm->mmap_base;
+		mm->freed_area = 0;
+	}
 }
 
 unsigned long
@@ -1839,6 +1819,7 @@ static void remove_vma_list(struct mm_struct *mm, struct vm_area_struct *vma)
 		long nrpages = vma_pages(vma);
 
 		mm->total_vm -= nrpages;
+		mm->freed_area += nrpages;
 		vm_stat_account(mm, vma->vm_flags, vma->vm_file, -nrpages);
 		vma = remove_vma(vma);
 	} while (vma);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
