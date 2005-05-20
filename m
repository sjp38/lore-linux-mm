Message-Id: <200505202351.j4KNpHg21468@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [PATCH] Avoiding mmap fragmentation - clean rev
Date: Fri, 20 May 2005 16:51:16 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20050519155441.7a8e94f9.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Andrew Morton' <akpm@osdl.org>, Wolfgang Wander <wwc@rentec.com>
Cc: herve@elma.fr, mingo@elte.hu, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote on Thursday, May 19, 2005 3:55 PM
> Wolfgang Wander <wwc@rentec.com> wrote:
> >
> > Clearly one has to weight the performance issues against the memory
> >  efficiency but since we demonstratibly throw away 25% (or 1GB) of the
> >  available address space in the various accumulated holes a long
> >  running application can generate
> 
> That sounds pretty bad.
> 
> > I hope that for the time being we can
> >  stick with my first solution,
> 
> I'm inclined to do this.
> 
> > preferably extended by your munmap fix?
> 
> And this, if someone has a patch? 


2nd patch on top of wolfgang's patch.  It's a compliment on top of initial
attempt by wolfgang to solve the fragmentation problem.  The code path
in munmap is suboptimal and potentially worsen the fragmentation because
with a series of munmap, the free_area_cache would point to last vma that
was freed, ignoring its surrounding and not performing any coalescing at all,
thus artificially create more holes in the virtual address space than necessary.
Since all the information needed to perform coalescing are actually already there.
This patch put that data in use so we will prevent artificial fragmentation.

It covers both bottom-up and top-down topology.  For bottom-up topology,
free_area_cache points to prev->vm_end. And for top-down, free_area_cache points
to next->vm_start.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
Acked-by: Ingo Molnar <mingo@elte.hu>

--- linux-2.6.12-rc4-mm2/mm/mmap.c.orig	2005-05-20 15:54:45.082381920 -0700
+++ linux-2.6.12-rc4-mm2/mm/mmap.c	2005-05-20 16:31:04.832355218 -0700
@@ -1217,14 +1217,11 @@ void arch_unmap_area(struct vm_area_stru
 	/*
 	 * Is this a new hole at the lowest possible address?
 	 */
-	if (area->vm_start >= TASK_UNMAPPED_BASE &&
-	    area->vm_start < area->vm_mm->free_area_cache) {
-	        unsigned area_size = area->vm_end-area->vm_start;
-
-		if (area->vm_mm->cached_hole_size < area_size)
-		        area->vm_mm->cached_hole_size = area_size;
-		else
-		        area->vm_mm->cached_hole_size = ~0UL;
+	unsigned long addr = (unsigned long) area->vm_private_data;
+
+	if (addr >= TASK_UNMAPPED_BASE && addr < area->vm_mm->free_area_cache) {
+		area->vm_mm->free_area_cache = addr;
+		area->vm_mm->cached_hole_size = ~0UL;
 	}
 }
 
@@ -1317,8 +1314,10 @@ void arch_unmap_area_topdown(struct vm_a
 	/*
 	 * Is this a new hole at the highest possible address?
 	 */
-	if (area->vm_end > area->vm_mm->free_area_cache)
-		area->vm_mm->free_area_cache = area->vm_end;
+	unsigned long addr = (unsigned long) area->vm_private_data;
+
+	if (addr > area->vm_mm->free_area_cache)
+		area->vm_mm->free_area_cache = addr;
 
 	/* dont allow allocations above current base */
 	if (area->vm_mm->free_area_cache > area->vm_mm->mmap_base)
@@ -1683,6 +1682,11 @@ detach_vmas_to_be_unmapped(struct mm_str
 	} while (vma && vma->vm_start < end);
 	*insertion_point = vma;
 	tail_vma->vm_next = NULL;
+	if (mm->unmap_area == arch_unmap_area)
+		tail_vma->vm_private_data = (void*) prev->vm_end;
+	else
+		tail_vma->vm_private_data = vma ?
+			(void*) vma->vm_start : (void*) mm->mmap_base;
 	mm->mmap_cache = NULL;		/* Kill the cache. */
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
