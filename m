Message-Id: <200505271637.j4RGbGg03420@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [PATCH] Avoiding mmap fragmentation - clean rev
Date: Fri, 27 May 2005 09:37:17 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: 
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Wolfgang Wander' <wwc@rentec.com>
Cc: 'Andrew Morton' <akpm@osdl.org>, herve@elma.fr, mingo@elte.hu, arjanv@redhat.com, linux-mm@kvack.org, colin.harrison@virgin.net
List-ID: <linux-mm.kvack.org>

Wolfgang Wander wrote on Thursday, May 26, 2005 10:32 AM
> 'prev' seems to possibly be NULL and the assignemnt of
>    tail_vma->vm_private_data = (void*) prev->vm_end;
> which fix-2 adds does not check for that.
> That potential problem does not seem to match the stacktrace
> below however...

Chen, Kenneth W wrote on Thursday, May 26, 2005 10:44 AM
> It sure looks like 'prev' can be null.  It needs the similar check
> like the one in the top down case.  I will double check on it.


Sorry, I was side tracked for awhile yesterday.  Oh boy, major clash for
corrupting vm_private_data with avoiding-mmap-fragmentation-fix-2.patch.

TO fix this, I think we can either pass the hint address down the call
stack, or pull mm->unmap_area() call site in unmap_area() two function
level up into detach_vmas_to_be_unmapped().  It also makes logical sense
to me that at the end of unlinking all the vmas, we fix up free_area_cache
in one shot instead of fixing it up for each iteration of vma removal.

Here is a patch. Majority of them is to change function prototype: to
use mm_struct pointer instead of vm_area_struct and to add hint addr
in the mm->unmap_area function argument.  Last 3 hunks are the real ones
that fix the conflict with vm_private_data.  This patch also fix the bug
where 'prev' is de-referenced without proper checking.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

--- ./include/linux/sched.h.orig	2005-05-27 02:04:17.601950694 -0700
+++ ./include/linux/sched.h	2005-05-27 03:06:31.389014330 -0700
@@ -201,8 +201,8 @@ extern unsigned long
 arch_get_unmapped_area_topdown(struct file *filp, unsigned long addr,
 			  unsigned long len, unsigned long pgoff,
 			  unsigned long flags);
-extern void arch_unmap_area(struct vm_area_struct *area);
-extern void arch_unmap_area_topdown(struct vm_area_struct *area);
+extern void arch_unmap_area(struct mm_struct *, unsigned long);
+extern void arch_unmap_area_topdown(struct mm_struct *, unsigned long);
 
 #define set_mm_counter(mm, member, value) (mm)->_##member = (value)
 #define get_mm_counter(mm, member) ((mm)->_##member)
@@ -218,7 +218,7 @@ struct mm_struct {
 	unsigned long (*get_unmapped_area) (struct file *filp,
 				unsigned long addr, unsigned long len,
 				unsigned long pgoff, unsigned long flags);
-	void (*unmap_area) (struct vm_area_struct *area);
+	void (*unmap_area) (struct mm_struct *mm, unsigned long addr);
         unsigned long mmap_base;		/* base of mmap area */
         unsigned long cached_hole_size;         /* if non-zero, the largest hole below free_area_cache */
 	unsigned long free_area_cache;		/* first hole of size cached_hole_size or larger */
--- ./mm/nommu.c.orig	2005-05-27 02:05:47.380269907 -0700
+++ ./mm/nommu.c	2005-05-27 03:07:31.773779216 -0700
@@ -1067,7 +1067,7 @@ unsigned long arch_get_unmapped_area(str
 	return -ENOMEM;
 }
 
-void arch_unmap_area(struct vm_area_struct *area)
+void arch_unmap_area(struct mm_struct *mm, unsigned long addr)
 {
 }
 
--- ./mm/mmap.c.orig	2005-05-27 02:03:22.152732623 -0700
+++ ./mm/mmap.c	2005-05-27 03:10:36.865573823 -0700
@@ -1212,16 +1212,14 @@ full_search:
 }
 #endif	
 
-void arch_unmap_area(struct vm_area_struct *area)
+void arch_unmap_area(struct mm_struct *mm, unsigned long addr)
 {
 	/*
 	 * Is this a new hole at the lowest possible address?
 	 */
-	unsigned long addr = (unsigned long) area->vm_private_data;
-
-	if (addr >= TASK_UNMAPPED_BASE && addr < area->vm_mm->free_area_cache) {
-		area->vm_mm->free_area_cache = addr;
-		area->vm_mm->cached_hole_size = ~0UL;
+	if (addr >= TASK_UNMAPPED_BASE && addr < mm->free_area_cache) {
+		mm->free_area_cache = addr;
+		mm->cached_hole_size = ~0UL;
 	}
 }
 
@@ -1309,19 +1307,17 @@ arch_get_unmapped_area_topdown(struct fi
 }
 #endif
 
-void arch_unmap_area_topdown(struct vm_area_struct *area)
+void arch_unmap_area_topdown(struct mm_struct *mm, unsigned long addr)
 {
 	/*
 	 * Is this a new hole at the highest possible address?
 	 */
-	unsigned long addr = (unsigned long) area->vm_private_data;
-
-	if (addr > area->vm_mm->free_area_cache)
-		area->vm_mm->free_area_cache = addr;
+	if (addr > mm->free_area_cache)
+		mm->free_area_cache = addr;
 
 	/* dont allow allocations above current base */
-	if (area->vm_mm->free_area_cache > area->vm_mm->mmap_base)
-		area->vm_mm->free_area_cache = area->vm_mm->mmap_base;
+	if (mm->free_area_cache > mm->mmap_base)
+		mm->free_area_cache = mm->mmap_base;
 }
 
 unsigned long
@@ -1621,7 +1617,6 @@ static void unmap_vma(struct mm_struct *
 	if (area->vm_flags & VM_LOCKED)
 		area->vm_mm->locked_vm -= len >> PAGE_SHIFT;
 	vm_stat_unaccount(area);
-	area->vm_mm->unmap_area(area);
 	remove_vm_struct(area);
 }
 
@@ -1675,6 +1670,7 @@ detach_vmas_to_be_unmapped(struct mm_str
 {
 	struct vm_area_struct **insertion_point;
 	struct vm_area_struct *tail_vma = NULL;
+	unsigned long addr;
 
 	insertion_point = (prev ? &prev->vm_next : &mm->mmap);
 	do {
@@ -1686,10 +1682,10 @@ detach_vmas_to_be_unmapped(struct mm_str
 	*insertion_point = vma;
 	tail_vma->vm_next = NULL;
 	if (mm->unmap_area == arch_unmap_area)
-		tail_vma->vm_private_data = (void*) prev->vm_end;
+		addr = prev ? prev->vm_end : mm->mmap_base;
 	else
-		tail_vma->vm_private_data = vma ?
-			(void*) vma->vm_start : (void*) mm->mmap_base;
+		addr = vma ?  vma->vm_start : mm->mmap_base;
+	mm->unmap_area(mm, addr);
 	mm->mmap_cache = NULL;		/* Kill the cache. */
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
