From: Wolfgang Wander <wwc@rentec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17007.55694.791558.230293@gargle.gargle.HOWL>
Date: Wed, 27 Apr 2005 14:27:26 -0400
Subject: Re: Fw: [Bug 4520] New: /proc/*/maps fragments too quickly compared to
 2.4
In-Reply-To: <20050423211819.3ec82cc7.akpm@osdl.org>
References: <20050423211819.3ec82cc7.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Ingo Molnar <mingo@elte.hu>, Arjan van de Ven <arjanv@redhat.com>, linux-mm@kvack.org, wwc@rentec.com
List-ID: <linux-mm.kvack.org>

Andrew Morton writes:
 > 
 > Guys, Wolfgang has found what appears to be a serious mmap fragmentation
 > problem with the mm_struct.free_area_cache.
 > 

Andrew asked me to send the appended patch also to the list for
comments:

  ------

   In addtion to the the free_area_cache I've added another member
called cached_hole_size which contains the largest hole we have found
up to the position of free_area_cache.  Thus if we come in with a new
request we know that we better start from scratch if the requested
length is less or equal to the cached_hole_size.

   I've tried to patch all available architectures but of course have
not even tried to compile it.  So far only i32 and x86_64 is tested.

   It avoids fragmentation (as 2.4 did) and should be still faster
than the uncached version I hacked earlier.  And yes - check how
I implemented the biggest unsigned long (~0UL), I'm not sure if that
is ok with your standards...

                Wolfgang


diff -ru linux-2.6.11.7/arch/arm/mm/mmap.c linux-2.6.11.7.wwc/arch/arm/mm/mmap.c
--- linux-2.6.11.7/arch/arm/mm/mmap.c	2005-03-02 02:38:10.000000000 -0500
+++ linux-2.6.11.7.wwc/arch/arm/mm/mmap.c	2005-04-27 09:19:19.000000000 -0400
@@ -73,8 +73,13 @@
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
@@ -90,6 +95,7 @@
 			 */
 			if (start_addr != TASK_UNMAPPED_BASE) {
 				start_addr = addr = TASK_UNMAPPED_BASE;
+				mm->cached_hole_size = 0;
 				goto full_search;
 			}
 			return -ENOMEM;
@@ -101,6 +107,8 @@
 			mm->free_area_cache = addr + len;
 			return addr;
 		}
+		if( addr + mm->cached_hole_size < vma->vm_start )
+		        mm->cached_hole_size = vma->vm_start - addr;
 		addr = vma->vm_end;
 		if (do_align)
 			addr = COLOUR_ALIGN(addr, pgoff);
diff -ru linux-2.6.11.7/arch/i386/mm/hugetlbpage.c linux-2.6.11.7.wwc/arch/i386/mm/hugetlbpage.c
--- linux-2.6.11.7/arch/i386/mm/hugetlbpage.c	2005-03-02 02:38:26.000000000 -0500
+++ linux-2.6.11.7.wwc/arch/i386/mm/hugetlbpage.c	2005-04-27 12:41:42.000000000 -0400
@@ -298,7 +298,12 @@
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
@@ -312,6 +317,7 @@
 			 */
 			if (start_addr != TASK_UNMAPPED_BASE) {
 				start_addr = TASK_UNMAPPED_BASE;
+				mm->cached_hole_size = 0;
 				goto full_search;
 			}
 			return -ENOMEM;
@@ -320,6 +326,8 @@
 			mm->free_area_cache = addr + len;
 			return addr;
 		}
+		if( addr + mm->cached_hole_size < vma->vm_start )
+		        mm->cached_hole_size = vma->vm_start - addr;
 		addr = ALIGN(vma->vm_end, HPAGE_SIZE);
 	}
 }
@@ -331,12 +339,17 @@
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
@@ -357,13 +370,20 @@
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
@@ -376,6 +396,7 @@
 	 */
 	if (first_time) {
 		mm->free_area_cache = base;
+		largest_hole = 0;
 		first_time = 0;
 		goto try_again;
 	}
@@ -386,6 +407,7 @@
 	 * allocations.
 	 */
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
+	mm->cached_hole_size = ~0UL;
 	addr = hugetlb_get_unmapped_area_bottomup(file, addr0,
 			len, pgoff, flags);
 
@@ -393,7 +415,8 @@
 	 * Restore the topdown base:
 	 */
 	mm->free_area_cache = base;
-
+	mm->cached_hole_size = ~0UL;
+	
 	return addr;
 }
 
diff -ru linux-2.6.11.7/arch/ia64/kernel/sys_ia64.c linux-2.6.11.7.wwc/arch/ia64/kernel/sys_ia64.c
--- linux-2.6.11.7/arch/ia64/kernel/sys_ia64.c	2005-03-02 02:38:10.000000000 -0500
+++ linux-2.6.11.7.wwc/arch/ia64/kernel/sys_ia64.c	2005-04-27 09:19:19.000000000 -0400
@@ -38,9 +38,15 @@
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
@@ -59,6 +65,7 @@
 			if (start_addr != TASK_UNMAPPED_BASE) {
 				/* Start a new search --- just in case we missed some holes.  */
 				addr = TASK_UNMAPPED_BASE;
+				mm->cached_hole_size = 0;
 				goto full_search;
 			}
 			return -ENOMEM;
@@ -68,6 +75,8 @@
 			mm->free_area_cache = addr + len;
 			return addr;
 		}
+		if( addr + mm->cached_hole_size < vma->vm_start )
+		        mm->cached_hole_size = vma->vm_start - addr;
 		addr = (vma->vm_end + align_mask) & ~align_mask;
 	}
 }
diff -ru linux-2.6.11.7/arch/ppc64/mm/hugetlbpage.c linux-2.6.11.7.wwc/arch/ppc64/mm/hugetlbpage.c
--- linux-2.6.11.7/arch/ppc64/mm/hugetlbpage.c	2005-03-02 02:38:09.000000000 -0500
+++ linux-2.6.11.7.wwc/arch/ppc64/mm/hugetlbpage.c	2005-04-27 12:43:52.000000000 -0400
@@ -515,7 +515,12 @@
 		    && !is_hugepage_only_range(addr,len))
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
@@ -539,6 +544,8 @@
 			mm->free_area_cache = addr + len;
 			return addr;
 		}
+		if( addr + mm->cached_hole_size < vma->vm_start )
+		        mm->cached_hole_size = vma->vm_start - addr;
 		addr = vma->vm_end;
 		vma = vma->vm_next;
 	}
@@ -546,6 +553,7 @@
 	/* Make sure we didn't miss any holes */
 	if (start_addr != TASK_UNMAPPED_BASE) {
 		start_addr = addr = TASK_UNMAPPED_BASE;
+		mm->cached_hole_size = 0;
 		goto full_search;
 	}
 	return -ENOMEM;
@@ -567,6 +575,7 @@
 	struct vm_area_struct *vma, *prev_vma;
 	struct mm_struct *mm = current->mm;
 	unsigned long base = mm->mmap_base, addr = addr0;
+	unsigned long largest_hole = mm->cached_hole_size;
 	int first_time = 1;
 
 	/* requested length too big for entire address space */
@@ -587,6 +596,10 @@
 			return addr;
 	}
 
+	if( len <= largest_hole ) {
+	        largest_hole = 0;
+		mm->free_area_cache  = base;
+	}
 try_again:
 	/* make sure it can fit in the remaining address space */
 	if (mm->free_area_cache < len)
@@ -615,13 +628,21 @@
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
@@ -634,6 +655,7 @@
 	 */
 	if (first_time) {
 		mm->free_area_cache = base;
+		largest_hole = 0;
 		first_time = 0;
 		goto try_again;
 	}
@@ -644,12 +666,14 @@
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
 
diff -ru linux-2.6.11.7/arch/sh/kernel/sys_sh.c linux-2.6.11.7.wwc/arch/sh/kernel/sys_sh.c
--- linux-2.6.11.7/arch/sh/kernel/sys_sh.c	2005-03-02 02:38:34.000000000 -0500
+++ linux-2.6.11.7.wwc/arch/sh/kernel/sys_sh.c	2005-04-27 09:19:19.000000000 -0400
@@ -79,6 +79,10 @@
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
@@ -95,6 +99,7 @@
 			 */
 			if (start_addr != TASK_UNMAPPED_BASE) {
 				start_addr = addr = TASK_UNMAPPED_BASE;
+				mm->cached_hole_size = 0;
 				goto full_search;
 			}
 			return -ENOMEM;
@@ -106,6 +111,9 @@
 			mm->free_area_cache = addr + len;
 			return addr;
 		}
+		if( addr + mm->cached_hole_size < vma->vm_start )
+		        mm->cached_hole_size = vma->vm_start - addr;
+		
 		addr = vma->vm_end;
 		if (!(flags & MAP_PRIVATE))
 			addr = COLOUR_ALIGN(addr);
diff -ru linux-2.6.11.7/arch/sparc64/kernel/sys_sparc.c linux-2.6.11.7.wwc/arch/sparc64/kernel/sys_sparc.c
--- linux-2.6.11.7/arch/sparc64/kernel/sys_sparc.c	2005-03-02 02:38:10.000000000 -0500
+++ linux-2.6.11.7.wwc/arch/sparc64/kernel/sys_sparc.c	2005-04-27 09:19:19.000000000 -0400
@@ -84,6 +84,10 @@
 			return addr;
 	}
 
+	if( len <= mm->cached_hole_size ) {
+	        mm->cached_hole_size = 0;
+		mm->free_area_cache = TASK_UNMAPPED_BASE;
+	}
 	start_addr = addr = mm->free_area_cache;
 
 	task_size -= len;
@@ -103,6 +107,7 @@
 		if (task_size < addr) {
 			if (start_addr != TASK_UNMAPPED_BASE) {
 				start_addr = addr = TASK_UNMAPPED_BASE;
+				mm->cached_hole_size = 0;
 				goto full_search;
 			}
 			return -ENOMEM;
@@ -114,6 +119,9 @@
 			mm->free_area_cache = addr + len;
 			return addr;
 		}
+		if( addr + mm->cached_hole_size < vma->vm_start )
+		        mm->cached_hole_size = vma->vm_start - addr;
+		
 		addr = vma->vm_end;
 		if (do_color_align)
 			addr = COLOUR_ALIGN(addr, pgoff);
diff -ru linux-2.6.11.7/arch/x86_64/ia32/ia32_aout.c linux-2.6.11.7.wwc/arch/x86_64/ia32/ia32_aout.c
--- linux-2.6.11.7/arch/x86_64/ia32/ia32_aout.c	2005-03-02 02:38:33.000000000 -0500
+++ linux-2.6.11.7.wwc/arch/x86_64/ia32/ia32_aout.c	2005-04-27 09:19:19.000000000 -0400
@@ -312,6 +312,7 @@
 	current->mm->brk = ex.a_bss +
 		(current->mm->start_brk = N_BSSADDR(ex));
 	current->mm->free_area_cache = TASK_UNMAPPED_BASE;
+	current->mm->cached_hole_size = 0;
 
 	current->mm->rss = 0;
 	current->mm->mmap = NULL;
diff -ru linux-2.6.11.7/arch/x86_64/kernel/sys_x86_64.c linux-2.6.11.7.wwc/arch/x86_64/kernel/sys_x86_64.c
--- linux-2.6.11.7/arch/x86_64/kernel/sys_x86_64.c	2005-03-02 02:38:13.000000000 -0500
+++ linux-2.6.11.7.wwc/arch/x86_64/kernel/sys_x86_64.c	2005-04-27 09:19:19.000000000 -0400
@@ -112,6 +112,10 @@
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
@@ -127,6 +131,7 @@
 			 */
 			if (start_addr != begin) {
 				start_addr = addr = begin;
+				mm->cached_hole_size = 0;
 				goto full_search;
 			}
 			return -ENOMEM;
@@ -138,6 +143,9 @@
 			mm->free_area_cache = addr + len;
 			return addr;
 		}
+		if( addr + mm->cached_hole_size < vma->vm_start )
+		        mm->cached_hole_size = vma->vm_start - addr;
+		
 		addr = vma->vm_end;
 	}
 }
diff -ru linux-2.6.11.7/fs/binfmt_aout.c linux-2.6.11.7.wwc/fs/binfmt_aout.c
--- linux-2.6.11.7/fs/binfmt_aout.c	2005-03-02 02:38:37.000000000 -0500
+++ linux-2.6.11.7.wwc/fs/binfmt_aout.c	2005-04-27 09:19:19.000000000 -0400
@@ -316,6 +316,7 @@
 	current->mm->brk = ex.a_bss +
 		(current->mm->start_brk = N_BSSADDR(ex));
 	current->mm->free_area_cache = current->mm->mmap_base;
+	current->mm->cached_hole_size = current->mm->cached_hole_size;
 
 	current->mm->rss = 0;
 	current->mm->mmap = NULL;
diff -ru linux-2.6.11.7/fs/binfmt_elf.c linux-2.6.11.7.wwc/fs/binfmt_elf.c
--- linux-2.6.11.7/fs/binfmt_elf.c	2005-04-27 13:15:09.000000000 -0400
+++ linux-2.6.11.7.wwc/fs/binfmt_elf.c	2005-04-27 09:19:19.000000000 -0400
@@ -766,6 +766,8 @@
 	   change some of these later */
 	current->mm->rss = 0;
 	current->mm->free_area_cache = current->mm->mmap_base;
+	current->mm->cached_hole_size = current->mm->cached_hole_size;
+	
 	retval = setup_arg_pages(bprm, STACK_TOP, executable_stack);
 	if (retval < 0) {
 		send_sig(SIGKILL, current, 0);
diff -ru linux-2.6.11.7/fs/hugetlbfs/inode.c linux-2.6.11.7.wwc/fs/hugetlbfs/inode.c
--- linux-2.6.11.7/fs/hugetlbfs/inode.c	2005-03-02 02:38:25.000000000 -0500
+++ linux-2.6.11.7.wwc/fs/hugetlbfs/inode.c	2005-04-27 12:39:19.000000000 -0400
@@ -122,6 +122,11 @@
 
 	start_addr = mm->free_area_cache;
 
+	if(len <= mm->cached_hole_size ) 
+		start_addr = TASK_UNMAPPED_BASE;
+
+
+
 full_search:
 	addr = ALIGN(start_addr, HPAGE_SIZE);
 
diff -ru linux-2.6.11.7/include/linux/sched.h linux-2.6.11.7.wwc/include/linux/sched.h
--- linux-2.6.11.7/include/linux/sched.h	2005-03-02 02:37:48.000000000 -0500
+++ linux-2.6.11.7.wwc/include/linux/sched.h	2005-04-27 09:19:19.000000000 -0400
@@ -212,8 +212,9 @@
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
diff -ru linux-2.6.11.7/kernel/fork.c linux-2.6.11.7.wwc/kernel/fork.c
--- linux-2.6.11.7/kernel/fork.c	2005-03-02 02:37:48.000000000 -0500
+++ linux-2.6.11.7.wwc/kernel/fork.c	2005-04-27 12:44:24.000000000 -0400
@@ -173,6 +173,7 @@
 	mm->mmap = NULL;
 	mm->mmap_cache = NULL;
 	mm->free_area_cache = oldmm->mmap_base;
+	mm->cached_hole_size = ~0UL;
 	mm->map_count = 0;
 	mm->rss = 0;
 	mm->anon_rss = 0;
@@ -301,7 +302,8 @@
 	mm->ioctx_list = NULL;
 	mm->default_kioctx = (struct kioctx)INIT_KIOCTX(mm->default_kioctx, *mm);
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
-
+	mm->cached_hole_size = ~0UL;
+	
 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
 		return mm;
diff -ru linux-2.6.11.7/mm/mmap.c linux-2.6.11.7.wwc/mm/mmap.c
--- linux-2.6.11.7/mm/mmap.c	2005-03-02 02:38:12.000000000 -0500
+++ linux-2.6.11.7.wwc/mm/mmap.c	2005-04-27 12:57:00.000000000 -0400
@@ -1173,7 +1173,12 @@
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
@@ -1184,7 +1189,8 @@
 			 * some holes.
 			 */
 			if (start_addr != TASK_UNMAPPED_BASE) {
-				start_addr = addr = TASK_UNMAPPED_BASE;
+			        start_addr = addr = TASK_UNMAPPED_BASE;
+				mm->cached_hole_size = 0;
 				goto full_search;
 			}
 			return -ENOMEM;
@@ -1196,6 +1202,8 @@
 			mm->free_area_cache = addr + len;
 			return addr;
 		}
+		if( addr + mm->cached_hole_size < vma->vm_start )
+		        mm->cached_hole_size = vma->vm_start - addr;
 		addr = vma->vm_end;
 	}
 }
@@ -1207,8 +1215,13 @@
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
@@ -1224,6 +1237,7 @@
 	struct vm_area_struct *vma, *prev_vma;
 	struct mm_struct *mm = current->mm;
 	unsigned long base = mm->mmap_base, addr = addr0;
+	unsigned long largest_hole = mm->cached_hole_size;
 	int first_time = 1;
 
 	/* requested length too big for entire address space */
@@ -1243,6 +1257,10 @@
 			return addr;
 	}
 
+	if( len <= mm->cached_hole_size ) {
+	        largest_hole = 0;
+		mm->free_area_cache  = base;
+	}
 try_again:
 	/* make sure it can fit in the remaining address space */
 	if (mm->free_area_cache < len)
@@ -1263,13 +1281,20 @@
 		 * vma->vm_start, use it:
 		 */
 		if (addr+len <= vma->vm_start &&
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
 		addr = vma->vm_start-len;
@@ -1282,6 +1307,7 @@
 	 */
 	if (first_time) {
 		mm->free_area_cache = base;
+		largest_hole = 0;
 		first_time = 0;
 		goto try_again;
 	}
@@ -1292,12 +1318,14 @@
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
 #endif
@@ -1307,8 +1335,13 @@
 	/*
 	 * Is this a new hole at the highest possible address?
 	 */
-	if (area->vm_end > area->vm_mm->free_area_cache)
-		area->vm_mm->free_area_cache = area->vm_end;
+        if (area->vm_end > area->vm_mm->free_area_cache) {
+	        unsigned area_size = area->vm_end-area->vm_start;
+		if( area->vm_mm->cached_hole_size < area_size ) 
+		        area->vm_mm->cached_hole_size = area_size;
+		else
+		        area->vm_mm->cached_hole_size = ~0UL;
+	}
 }
 
 unsigned long
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
