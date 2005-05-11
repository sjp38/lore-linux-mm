From: Wolfgang Wander <wwc@rentec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17026.6227.225173.588629@gargle.gargle.HOWL>
Date: Wed, 11 May 2005 10:36:03 -0400
Subject: [PATCH] Avoiding mmap fragmentation  (against 2.6.12-rc4)
 to
In-Reply-To: <20050510125747.65b83b4c.akpm@osdl.org>
References: <20050510115818.0828f5d1.akpm@osdl.org>
	<200505101934.j4AJYfg26483@unix-os.sc.intel.com>
	<20050510124357.2a7d2f9b.akpm@osdl.org>
	<17025.4213.255704.748374@gargle.gargle.HOWL>
	<20050510125747.65b83b4c.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Wolfgang Wander <wwc@rentec.com>, kenneth.w.chen@intel.com, mingo@elte.hu, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


The patch below is against linux-2.6.12-rc4.

Ingo recently introduced a great speedup for allocating new
mmaps using the free_area_cache pointer which boosts the specweb 
SSL benchmark by 4-5% and causes huge performance increases in
thread creation.

The downside of this patch is that it does lead to fragmentation
in the mmap-ed areas (visible via /proc/self/maps), such that
some applications that work fine under 2.4 kernels quickly run
out of memory on any 2.6 kernel.

The problem is twofold:

  1) the free_area_cache is used to continue a search for
     memory where the last search ended.  Before the change
     new areas were always searched from the base address on.

     So now new small areas are cluttering holes of all sizes
     throughout the whole mmap-able region whereas before small
     holes tended to close holes near the base leaving holes
     far from the base large and available for larger requests.

  2) the free_area_cache also is set to the location of the last
     munmap-ed area so in scenarios where we allocate e.g.
     five regions of 1K each, then free regions 4 2 3 in this
     order the next request for 1K will be placed in the position
     of the old region 3, whereas before we appended it to the
     still active region 1, placing it at the location of the old
     region 2.  Before we had 1 free region of 2K, now we only
     get two free regions of 1K -> fragmentation.

The patch adresses thes issues by introducing yet another cache
descriptor cached_hole_size that contains the largest known hole
size below the current free_area_cache.  If a new request comes
in the size is compared against the cached_hole_size and if the
request can be filled with a hole below free_area_cache the
search is started from the base instead.

The results look promising:  Whereas 2.6.12-rc4 fragments
quickly and my (earlier posted) leakme.c test program terminates
after 50000+ iterations with 96 distinct and fragmented maps in
/proc/self/maps it performs nicely (as expected) with thread creation,
Ingo's test_str02 with 20000 threads requires 0.7s system time.

Taking out Ingo's patch (un-patch available per request) by basically
deleting all mentions of free_area_cache from the kernel and starting
the search for new memory always at the respective bases we observe:
leakme terminates successfully with 11 distinctive hardly fragmented
areas in /proc/self/maps but thread creating is gringdingly slow:
30+s(!) system time for Ingo's test_str02 with 20000 threads.

Now - drumroll ;-) the appended patch works fine with leakme: it
ends with only 7 distinct areas in /proc/self/maps and also thread
creation seems sufficiently fast with 0.71s for 20000 threads.

           Wolfgang


      ----------------------------------------

Signed-off-by: Wolfgang Wander <wwc@rentec.com>

      ----------------------------------------


diff -rpu linux-2.6.12-rc4-vanilla/arch/arm/mm/mmap.c linux-2.6.12-rc4-wwc/arch/arm/mm/mmap.c
--- linux-2.6.12-rc4-vanilla/arch/arm/mm/mmap.c	2005-03-02 02:38:10.000000000 -0500
+++ linux-2.6.12-rc4-wwc/arch/arm/mm/mmap.c	2005-05-10 16:33:34.363204724 -0400
@@ -73,8 +73,13 @@ arch_get_unmapped_area(struct file *filp
 		    (!vma || addr + len <= vma->vm_start))
 			return addr;
 	}
-	start_addr = addr = mm->free_area_cache;
-
+	if( len > mm->cached_hole_size )
+	        start_addr = addr = mm->free_area_cache;
+	else {
+	        start_addr = TASK_UNMAPPED_BASE;
+	        mm->cached_hole_size = 0;
+	}
+	
 full_search:
 	if (do_align)
 		addr = COLOUR_ALIGN(addr, pgoff);
@@ -90,6 +95,7 @@ full_search:
 			 */
 			if (start_addr != TASK_UNMAPPED_BASE) {
 				start_addr = addr = TASK_UNMAPPED_BASE;
+				mm->cached_hole_size = 0;
 				goto full_search;
 			}
 			return -ENOMEM;
@@ -101,6 +107,8 @@ full_search:
 			mm->free_area_cache = addr + len;
 			return addr;
 		}
+		if( addr + mm->cached_hole_size < vma->vm_start )
+		        mm->cached_hole_size = vma->vm_start - addr;
 		addr = vma->vm_end;
 		if (do_align)
 			addr = COLOUR_ALIGN(addr, pgoff);
diff -rpu linux-2.6.12-rc4-vanilla/arch/i386/mm/hugetlbpage.c linux-2.6.12-rc4-wwc/arch/i386/mm/hugetlbpage.c
--- linux-2.6.12-rc4-vanilla/arch/i386/mm/hugetlbpage.c	2005-05-10 18:28:55.902605331 -0400
+++ linux-2.6.12-rc4-wwc/arch/i386/mm/hugetlbpage.c	2005-05-10 16:33:34.364204677 -0400
@@ -294,7 +294,12 @@ static unsigned long hugetlb_get_unmappe
 	struct vm_area_struct *vma;
 	unsigned long start_addr;
 
-	start_addr = mm->free_area_cache;
+	if( len > mm->cached_hole_size ) 
+	        start_addr = mm->free_area_cache;
+	else {
+	        start_addr = TASK_UNMAPPED_BASE;
+	        mm->cached_hole_size = 0;
+	}
 
 full_search:
 	addr = ALIGN(start_addr, HPAGE_SIZE);
@@ -308,6 +313,7 @@ full_search:
 			 */
 			if (start_addr != TASK_UNMAPPED_BASE) {
 				start_addr = TASK_UNMAPPED_BASE;
+				mm->cached_hole_size = 0;
 				goto full_search;
 			}
 			return -ENOMEM;
@@ -316,6 +322,8 @@ full_search:
 			mm->free_area_cache = addr + len;
 			return addr;
 		}
+		if( addr + mm->cached_hole_size < vma->vm_start )
+		        mm->cached_hole_size = vma->vm_start - addr;
 		addr = ALIGN(vma->vm_end, HPAGE_SIZE);
 	}
 }
@@ -327,12 +335,17 @@ static unsigned long hugetlb_get_unmappe
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma, *prev_vma;
 	unsigned long base = mm->mmap_base, addr = addr0;
+	unsigned long largest_hole = mm->cached_hole_size;
 	int first_time = 1;
 
 	/* don't allow allocations above current base */
 	if (mm->free_area_cache > base)
 		mm->free_area_cache = base;
 
+	if( len <= largest_hole ) {
+	        largest_hole = 0;
+		mm->free_area_cache  = base;
+	}
 try_again:
 	/* make sure it can fit in the remaining address space */
 	if (mm->free_area_cache < len)
@@ -353,13 +366,20 @@ try_again:
 		 * vma->vm_start, use it:
 		 */
 		if (addr + len <= vma->vm_start &&
-				(!prev_vma || (addr >= prev_vma->vm_end)))
+		        (!prev_vma || (addr >= prev_vma->vm_end))) {
 			/* remember the address as a hint for next time */
-			return (mm->free_area_cache = addr);
-		else
+		        mm->cached_hole_size = largest_hole;
+		        return (mm->free_area_cache = addr);
+		} else
 			/* pull free_area_cache down to the first hole */
-			if (mm->free_area_cache == vma->vm_end)
+		        if (mm->free_area_cache == vma->vm_end) {
 				mm->free_area_cache = vma->vm_start;
+				mm->cached_hole_size = largest_hole;
+			}
+				
+		/* remember the largest hole we saw so far */
+		if( addr + largest_hole < vma->vm_start )
+		        largest_hole = vma->vm_start - addr;
 
 		/* try just below the current vma->vm_start */
 		addr = (vma->vm_start - len) & HPAGE_MASK;
@@ -372,6 +392,7 @@ fail:
 	 */
 	if (first_time) {
 		mm->free_area_cache = base;
+		largest_hole = 0;
 		first_time = 0;
 		goto try_again;
 	}
@@ -382,6 +403,7 @@ fail:
 	 * allocations.
 	 */
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
+	mm->cached_hole_size = ~0UL;
 	addr = hugetlb_get_unmapped_area_bottomup(file, addr0,
 			len, pgoff, flags);
 
@@ -389,7 +411,8 @@ fail:
 	 * Restore the topdown base:
 	 */
 	mm->free_area_cache = base;
-
+	mm->cached_hole_size = ~0UL;
+	
 	return addr;
 }
 
diff -rpu linux-2.6.12-rc4-vanilla/arch/ia64/kernel/sys_ia64.c linux-2.6.12-rc4-wwc/arch/ia64/kernel/sys_ia64.c
--- linux-2.6.12-rc4-vanilla/arch/ia64/kernel/sys_ia64.c	2005-05-10 18:28:55.929604069 -0400
+++ linux-2.6.12-rc4-wwc/arch/ia64/kernel/sys_ia64.c	2005-05-10 16:33:34.365204630 -0400
@@ -38,9 +38,15 @@ arch_get_unmapped_area (struct file *fil
 	if (REGION_NUMBER(addr) == REGION_HPAGE)
 		addr = 0;
 #endif
-	if (!addr)
-		addr = mm->free_area_cache;
-
+	if (!addr) {
+	        if( len > mm->cached_hole_size )
+		        addr = mm->free_area_cache;
+		else {
+		        addr = TASK_UNMAPPED_BASE;
+			mm->cached_hole_size = 0;
+		}
+	}
+			
 	if (map_shared && (TASK_SIZE > 0xfffffffful))
 		/*
 		 * For 64-bit tasks, align shared segments to 1MB to avoid potential
@@ -59,6 +65,7 @@ arch_get_unmapped_area (struct file *fil
 			if (start_addr != TASK_UNMAPPED_BASE) {
 				/* Start a new search --- just in case we missed some holes.  */
 				addr = TASK_UNMAPPED_BASE;
+				mm->cached_hole_size = 0;
 				goto full_search;
 			}
 			return -ENOMEM;
@@ -68,6 +75,8 @@ arch_get_unmapped_area (struct file *fil
 			mm->free_area_cache = addr + len;
 			return addr;
 		}
+		if( addr + mm->cached_hole_size < vma->vm_start )
+		        mm->cached_hole_size = vma->vm_start - addr;
 		addr = (vma->vm_end + align_mask) & ~align_mask;
 	}
 }
diff -rpu linux-2.6.12-rc4-vanilla/arch/ppc64/mm/hugetlbpage.c linux-2.6.12-rc4-wwc/arch/ppc64/mm/hugetlbpage.c
--- linux-2.6.12-rc4-vanilla/arch/ppc64/mm/hugetlbpage.c	2005-05-10 18:28:56.186592052 -0400
+++ linux-2.6.12-rc4-wwc/arch/ppc64/mm/hugetlbpage.c	2005-05-10 16:33:34.366204583 -0400
@@ -468,7 +468,12 @@ unsigned long arch_get_unmapped_area(str
 		    && !is_hugepage_only_range(mm, addr,len))
 			return addr;
 	}
-	start_addr = addr = mm->free_area_cache;
+	if( len > mm->cached_hole_size ) 
+	        start_addr = addr = mm->free_area_cache;
+	else {
+	        start_addr = addr = TASK_UNMAPPED_BASE;
+	        mm->cached_hole_size = 0;
+	}
 
 full_search:
 	vma = find_vma(mm, addr);
@@ -492,6 +497,8 @@ full_search:
 			mm->free_area_cache = addr + len;
 			return addr;
 		}
+		if( addr + mm->cached_hole_size < vma->vm_start )
+		        mm->cached_hole_size = vma->vm_start - addr;
 		addr = vma->vm_end;
 		vma = vma->vm_next;
 	}
@@ -499,6 +506,7 @@ full_search:
 	/* Make sure we didn't miss any holes */
 	if (start_addr != TASK_UNMAPPED_BASE) {
 		start_addr = addr = TASK_UNMAPPED_BASE;
+		mm->cached_hole_size = 0;
 		goto full_search;
 	}
 	return -ENOMEM;
@@ -520,6 +528,7 @@ arch_get_unmapped_area_topdown(struct fi
 	struct vm_area_struct *vma, *prev_vma;
 	struct mm_struct *mm = current->mm;
 	unsigned long base = mm->mmap_base, addr = addr0;
+	unsigned long largest_hole = mm->cached_hole_size;
 	int first_time = 1;
 
 	/* requested length too big for entire address space */
@@ -540,6 +549,10 @@ arch_get_unmapped_area_topdown(struct fi
 			return addr;
 	}
 
+	if( len <= largest_hole ) {
+	        largest_hole = 0;
+		mm->free_area_cache  = base;
+	}
 try_again:
 	/* make sure it can fit in the remaining address space */
 	if (mm->free_area_cache < len)
@@ -568,13 +581,21 @@ hugepage_recheck:
 		 * vma->vm_start, use it:
 		 */
 		if (addr+len <= vma->vm_start &&
-				(!prev_vma || (addr >= prev_vma->vm_end)))
+		          (!prev_vma || (addr >= prev_vma->vm_end))) {
 			/* remember the address as a hint for next time */
-			return (mm->free_area_cache = addr);
+		        mm->cached_hole_size = largest_hole;
+		        return (mm->free_area_cache = addr);
+		}
 		else
 			/* pull free_area_cache down to the first hole */
-			if (mm->free_area_cache == vma->vm_end)
+		        if (mm->free_area_cache == vma->vm_end) {
 				mm->free_area_cache = vma->vm_start;
+				mm->cached_hole_size = largest_hole;
+			}
+				
+		/* remember the largest hole we saw so far */
+		if( addr + largest_hole < vma->vm_start )
+		        largest_hole = vma->vm_start - addr;
 
 		/* try just below the current vma->vm_start */
 		addr = vma->vm_start-len;
@@ -587,6 +608,7 @@ fail:
 	 */
 	if (first_time) {
 		mm->free_area_cache = base;
+		largest_hole = 0;
 		first_time = 0;
 		goto try_again;
 	}
@@ -597,12 +619,14 @@ fail:
 	 * allocations.
 	 */
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
+	mm->cached_hole_size = ~0UL;
 	addr = arch_get_unmapped_area(filp, addr0, len, pgoff, flags);
 	/*
 	 * Restore the topdown base:
 	 */
 	mm->free_area_cache = base;
-
+	mm->cached_hole_size = ~0UL;
+	
 	return addr;
 }
 
diff -rpu linux-2.6.12-rc4-vanilla/arch/sh/kernel/sys_sh.c linux-2.6.12-rc4-wwc/arch/sh/kernel/sys_sh.c
--- linux-2.6.12-rc4-vanilla/arch/sh/kernel/sys_sh.c	2005-03-02 02:38:34.000000000 -0500
+++ linux-2.6.12-rc4-wwc/arch/sh/kernel/sys_sh.c	2005-05-10 16:33:34.366204583 -0400
@@ -79,6 +79,10 @@ unsigned long arch_get_unmapped_area(str
 		    (!vma || addr + len <= vma->vm_start))
 			return addr;
 	}
+	if( len <= mm->cached_hole_size ) {
+	        mm->cached_hole_size = 0;
+		mm->free_area_cache = TASK_UNMAPPED_BASE;
+	}
 	if (flags & MAP_PRIVATE)
 		addr = PAGE_ALIGN(mm->free_area_cache);
 	else
@@ -95,6 +99,7 @@ full_search:
 			 */
 			if (start_addr != TASK_UNMAPPED_BASE) {
 				start_addr = addr = TASK_UNMAPPED_BASE;
+				mm->cached_hole_size = 0;
 				goto full_search;
 			}
 			return -ENOMEM;
@@ -106,6 +111,9 @@ full_search:
 			mm->free_area_cache = addr + len;
 			return addr;
 		}
+		if( addr + mm->cached_hole_size < vma->vm_start )
+		        mm->cached_hole_size = vma->vm_start - addr;
+		
 		addr = vma->vm_end;
 		if (!(flags & MAP_PRIVATE))
 			addr = COLOUR_ALIGN(addr);
diff -rpu linux-2.6.12-rc4-vanilla/arch/sparc64/kernel/sys_sparc.c linux-2.6.12-rc4-wwc/arch/sparc64/kernel/sys_sparc.c
--- linux-2.6.12-rc4-vanilla/arch/sparc64/kernel/sys_sparc.c	2005-03-02 02:38:10.000000000 -0500
+++ linux-2.6.12-rc4-wwc/arch/sparc64/kernel/sys_sparc.c	2005-05-10 16:33:34.367204536 -0400
@@ -84,6 +84,10 @@ unsigned long arch_get_unmapped_area(str
 			return addr;
 	}
 
+	if( len <= mm->cached_hole_size ) {
+	        mm->cached_hole_size = 0;
+		mm->free_area_cache = TASK_UNMAPPED_BASE;
+	}
 	start_addr = addr = mm->free_area_cache;
 
 	task_size -= len;
@@ -103,6 +107,7 @@ full_search:
 		if (task_size < addr) {
 			if (start_addr != TASK_UNMAPPED_BASE) {
 				start_addr = addr = TASK_UNMAPPED_BASE;
+				mm->cached_hole_size = 0;
 				goto full_search;
 			}
 			return -ENOMEM;
@@ -114,6 +119,9 @@ full_search:
 			mm->free_area_cache = addr + len;
 			return addr;
 		}
+		if( addr + mm->cached_hole_size < vma->vm_start )
+		        mm->cached_hole_size = vma->vm_start - addr;
+		
 		addr = vma->vm_end;
 		if (do_color_align)
 			addr = COLOUR_ALIGN(addr, pgoff);
diff -rpu linux-2.6.12-rc4-vanilla/arch/x86_64/ia32/ia32_aout.c linux-2.6.12-rc4-wwc/arch/x86_64/ia32/ia32_aout.c
--- linux-2.6.12-rc4-vanilla/arch/x86_64/ia32/ia32_aout.c	2005-05-10 18:28:56.386582700 -0400
+++ linux-2.6.12-rc4-wwc/arch/x86_64/ia32/ia32_aout.c	2005-05-10 16:33:34.367204536 -0400
@@ -312,6 +312,7 @@ static int load_aout_binary(struct linux
 	current->mm->brk = ex.a_bss +
 		(current->mm->start_brk = N_BSSADDR(ex));
 	current->mm->free_area_cache = TASK_UNMAPPED_BASE;
+	current->mm->cached_hole_size = 0;
 
 	set_mm_counter(current->mm, rss, 0);
 	current->mm->mmap = NULL;
diff -rpu linux-2.6.12-rc4-vanilla/arch/x86_64/kernel/sys_x86_64.c linux-2.6.12-rc4-wwc/arch/x86_64/kernel/sys_x86_64.c
--- linux-2.6.12-rc4-vanilla/arch/x86_64/kernel/sys_x86_64.c	2005-05-10 18:28:56.406581765 -0400
+++ linux-2.6.12-rc4-wwc/arch/x86_64/kernel/sys_x86_64.c	2005-05-10 16:33:34.368204490 -0400
@@ -111,6 +111,10 @@ arch_get_unmapped_area(struct file *filp
 		    (!vma || addr + len <= vma->vm_start))
 			return addr;
 	}
+	if( len <= mm->cached_hole_size ) {
+	        mm->cached_hole_size = 0;
+		mm->free_area_cache = begin;
+	}
 	addr = mm->free_area_cache;
 	if (addr < begin) 
 		addr = begin; 
@@ -126,6 +130,7 @@ full_search:
 			 */
 			if (start_addr != begin) {
 				start_addr = addr = begin;
+				mm->cached_hole_size = 0;
 				goto full_search;
 			}
 			return -ENOMEM;
@@ -137,6 +142,9 @@ full_search:
 			mm->free_area_cache = addr + len;
 			return addr;
 		}
+		if( addr + mm->cached_hole_size < vma->vm_start )
+		        mm->cached_hole_size = vma->vm_start - addr;
+		
 		addr = vma->vm_end;
 	}
 }
diff -rpu linux-2.6.12-rc4-vanilla/fs/binfmt_aout.c linux-2.6.12-rc4-wwc/fs/binfmt_aout.c
--- linux-2.6.12-rc4-vanilla/fs/binfmt_aout.c	2005-05-10 18:28:59.957415723 -0400
+++ linux-2.6.12-rc4-wwc/fs/binfmt_aout.c	2005-05-10 16:33:34.368204490 -0400
@@ -316,6 +316,7 @@ static int load_aout_binary(struct linux
 	current->mm->brk = ex.a_bss +
 		(current->mm->start_brk = N_BSSADDR(ex));
 	current->mm->free_area_cache = current->mm->mmap_base;
+	current->mm->cached_hole_size = current->mm->cached_hole_size;
 
 	set_mm_counter(current->mm, rss, 0);
 	current->mm->mmap = NULL;
diff -rpu linux-2.6.12-rc4-vanilla/fs/binfmt_elf.c linux-2.6.12-rc4-wwc/fs/binfmt_elf.c
--- linux-2.6.12-rc4-vanilla/fs/binfmt_elf.c	2005-05-10 18:28:59.958415676 -0400
+++ linux-2.6.12-rc4-wwc/fs/binfmt_elf.c	2005-05-10 16:34:23.696894470 -0400
@@ -775,6 +775,7 @@ static int load_elf_binary(struct linux_
 	   change some of these later */
 	set_mm_counter(current->mm, rss, 0);
 	current->mm->free_area_cache = current->mm->mmap_base;
+	current->mm->cached_hole_size = current->mm->cached_hole_size;
 	retval = setup_arg_pages(bprm, randomize_stack_top(STACK_TOP),
 				 executable_stack);
 	if (retval < 0) {
diff -rpu linux-2.6.12-rc4-vanilla/fs/hugetlbfs/inode.c linux-2.6.12-rc4-wwc/fs/hugetlbfs/inode.c
--- linux-2.6.12-rc4-vanilla/fs/hugetlbfs/inode.c	2005-05-10 18:29:00.032412216 -0400
+++ linux-2.6.12-rc4-wwc/fs/hugetlbfs/inode.c	2005-05-10 16:33:34.370204396 -0400
@@ -122,6 +122,11 @@ hugetlb_get_unmapped_area(struct file *f
 
 	start_addr = mm->free_area_cache;
 
+	if(len <= mm->cached_hole_size ) 
+		start_addr = TASK_UNMAPPED_BASE;
+
+
+
 full_search:
 	addr = ALIGN(start_addr, HPAGE_SIZE);
 
diff -rpu linux-2.6.12-rc4-vanilla/include/linux/sched.h linux-2.6.12-rc4-wwc/include/linux/sched.h
--- linux-2.6.12-rc4-vanilla/include/linux/sched.h	2005-05-10 18:29:02.918277269 -0400
+++ linux-2.6.12-rc4-wwc/include/linux/sched.h	2005-05-10 16:33:34.371204349 -0400
@@ -219,8 +219,9 @@ struct mm_struct {
 				unsigned long addr, unsigned long len,
 				unsigned long pgoff, unsigned long flags);
 	void (*unmap_area) (struct vm_area_struct *area);
-	unsigned long mmap_base;		/* base of mmap area */
-	unsigned long free_area_cache;		/* first hole */
+        unsigned long mmap_base;		/* base of mmap area */
+        unsigned long cached_hole_size;         /* if non-zero, the largest hole below free_area_cache */
+	unsigned long free_area_cache;		/* first hole of size cached_hole_size or larger */
 	pgd_t * pgd;
 	atomic_t mm_users;			/* How many users with user space? */
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
diff -rpu linux-2.6.12-rc4-vanilla/kernel/fork.c linux-2.6.12-rc4-wwc/kernel/fork.c
--- linux-2.6.12-rc4-vanilla/kernel/fork.c	2005-05-10 18:29:02.994273715 -0400
+++ linux-2.6.12-rc4-wwc/kernel/fork.c	2005-05-10 16:33:34.372204302 -0400
@@ -194,6 +194,7 @@ static inline int dup_mmap(struct mm_str
 	mm->mmap = NULL;
 	mm->mmap_cache = NULL;
 	mm->free_area_cache = oldmm->mmap_base;
+	mm->cached_hole_size = ~0UL;
 	mm->map_count = 0;
 	set_mm_counter(mm, rss, 0);
 	set_mm_counter(mm, anon_rss, 0);
@@ -322,7 +323,8 @@ static struct mm_struct * mm_init(struct
 	mm->ioctx_list = NULL;
 	mm->default_kioctx = (struct kioctx)INIT_KIOCTX(mm->default_kioctx, *mm);
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
-
+	mm->cached_hole_size = ~0UL;
+	
 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
 		return mm;
diff -rpu linux-2.6.12-rc4-vanilla/mm/mmap.c linux-2.6.12-rc4-wwc/mm/mmap.c
--- linux-2.6.12-rc4-vanilla/mm/mmap.c	2005-05-10 18:29:03.031271985 -0400
+++ linux-2.6.12-rc4-wwc/mm/mmap.c	2005-05-10 17:57:17.869390186 -0400
@@ -1175,7 +1175,12 @@ arch_get_unmapped_area(struct file *filp
 		    (!vma || addr + len <= vma->vm_start))
 			return addr;
 	}
-	start_addr = addr = mm->free_area_cache;
+	if( len > mm->cached_hole_size ) 
+	        start_addr = addr = mm->free_area_cache;
+	else {
+	        start_addr = addr = TASK_UNMAPPED_BASE;
+	        mm->cached_hole_size = 0;
+	}
 
 full_search:
 	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
@@ -1186,7 +1191,8 @@ full_search:
 			 * some holes.
 			 */
 			if (start_addr != TASK_UNMAPPED_BASE) {
-				start_addr = addr = TASK_UNMAPPED_BASE;
+			        start_addr = addr = TASK_UNMAPPED_BASE;
+				mm->cached_hole_size = 0;
 				goto full_search;
 			}
 			return -ENOMEM;
@@ -1198,6 +1204,8 @@ full_search:
 			mm->free_area_cache = addr + len;
 			return addr;
 		}
+		if( addr + mm->cached_hole_size < vma->vm_start )
+		        mm->cached_hole_size = vma->vm_start - addr;
 		addr = vma->vm_end;
 	}
 }
@@ -1209,8 +1217,13 @@ void arch_unmap_area(struct vm_area_stru
 	 * Is this a new hole at the lowest possible address?
 	 */
 	if (area->vm_start >= TASK_UNMAPPED_BASE &&
-			area->vm_start < area->vm_mm->free_area_cache)
-		area->vm_mm->free_area_cache = area->vm_start;
+	    area->vm_start < area->vm_mm->free_area_cache) {
+	        unsigned area_size = area->vm_end-area->vm_start;
+		if( area->vm_mm->cached_hole_size < area_size ) 
+		        area->vm_mm->cached_hole_size = area_size;
+		else
+		        area->vm_mm->cached_hole_size = ~0UL;
+	}
 }
 
 /*
@@ -1240,13 +1253,19 @@ arch_get_unmapped_area_topdown(struct fi
 			return addr;
 	}
 
+	/* check if free_area_cache is useful for us */
+	if( len <= mm->cached_hole_size ) {
+ 	        mm->cached_hole_size = 0;
+ 		mm->free_area_cache  = mm->mmap_base;
+ 	}
+
 	/* either no address requested or can't fit in requested address hole */
 	addr = mm->free_area_cache;
 
 	/* make sure it can fit in the remaining address space */
 	if (addr >= len) {
 		vma = find_vma(mm, addr-len);
-		if (!vma || addr <= vma->vm_start)
+		if (!vma || addr <= vma->vm_start) 
 			/* remember the address as a hint for next time */
 			return (mm->free_area_cache = addr-len);
 	}
@@ -1264,6 +1283,10 @@ arch_get_unmapped_area_topdown(struct fi
 			/* remember the address as a hint for next time */
 			return (mm->free_area_cache = addr);
 
+ 		/* remember the largest hole we saw so far */
+ 		if( addr + mm->cached_hole_size < vma->vm_start )
+ 		        mm->cached_hole_size = vma->vm_start - addr;
+
 		/* try just below the current vma->vm_start */
 		addr = vma->vm_start-len;
 	} while (len <= vma->vm_start);
@@ -1274,13 +1297,15 @@ arch_get_unmapped_area_topdown(struct fi
 	 * can happen with large stack limits and large mmap()
 	 * allocations.
 	 */
-	mm->free_area_cache = TASK_UNMAPPED_BASE;
+	mm->cached_hole_size = ~0UL;
+  	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	addr = arch_get_unmapped_area(filp, addr0, len, pgoff, flags);
 	/*
 	 * Restore the topdown base:
 	 */
 	mm->free_area_cache = mm->mmap_base;
-
+	mm->cached_hole_size = ~0UL;
+  	
 	return addr;
 }
 #endif
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
