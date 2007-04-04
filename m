Date: Wed, 4 Apr 2007 11:34:47 +0200
From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: missing madvise functionality
Message-Id: <20070404113447.17ccbefa.dada1@cosmosbay.com>
In-Reply-To: <461367F6.10705@yahoo.com.au>
References: <46128051.9000609@redhat.com>
	<p73648dz5oa.fsf@bingen.suse.de>
	<46128CC2.9090809@redhat.com>
	<20070403172841.GB23689@one.firstfloor.org>
	<20070403125903.3e8577f4.akpm@linux-foundation.org>
	<4612B645.7030902@redhat.com>
	<20070403202937.GE355@devserv.devel.redhat.com>
	<20070403144948.fe8eede6.akpm@linux-foundation.org>
	<4612DCC6.7000504@cosmosbay.com>
	<46130BC8.9050905@yahoo.com.au>
	<1175675146.6483.26.camel@twins>
	<461367F6.10705@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jakub Jelinek <jakub@redhat.com>, Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, 04 Apr 2007 18:55:18 +1000
Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> Peter Zijlstra wrote:
> > On Wed, 2007-04-04 at 12:22 +1000, Nick Piggin wrote:
> > 
> >>Eric Dumazet wrote:
> > 
> > 
> >>>I do think such workloads might benefit from a vma_cache not shared by 
> >>>all threads but private to each thread. A sequence could invalidate the 
> >>>cache(s).
> >>>
> >>>ie instead of a mm->mmap_cache, having a mm->sequence, and each thread 
> >>>having a current->mmap_cache and current->mm_sequence
> >>
> >>I have a patchset to do exactly this, btw.
> > 
> > 
> > /me too
> > 
> > However, I decided against pushing it because when it does happen that a
> > task is not involved with a vma lookup for longer than it takes the seq
> > count to wrap we have a stale pointer...
> > 
> > We could go and walk the tasks once in a while to reset the pointer, but
> > it all got a tad involved.
> 
> Well here is my core patch (against I think 2.6.16 + a set of vma cache
> cleanups and abstractions). I didn't think the wrapping aspect was
> terribly involved.

Well, I believe this one is too expensive. I was thinking of a light one :

I am not deleting mmap_sem, but adding a sequence number to mm_struct, that is incremented each time a vma is added/deleted, not each time mmap_sem is taken (read or write)

Each thread has its own copy of the sequence, taken at the time find_vma() had to do a full lookup.

I believe some optimized paths could call check_vma_cache() without mmap_sem read lock taken, and if it fails, take the mmap_sem lock and do the slow path.


--- linux-2.6.21-rc5/include/linux/sched.h
+++ linux-2.6.21-rc5-ed/include/linux/sched.h
@@ -319,10 +319,14 @@ typedef unsigned long mm_counter_t;
 		(mm)->hiwater_vm = (mm)->total_vm;	\
 } while (0)
 
+struct vm_area_cache {
+	struct vm_area_struct * mmap_cache; /* last find_vma result */
+	unsigned int sequence;
+	};
+
 struct mm_struct {
 	struct vm_area_struct * mmap;		/* list of VMAs */
 	struct rb_root mm_rb;
-	struct vm_area_struct * mmap_cache;	/* last find_vma result */
 	unsigned long (*get_unmapped_area) (struct file *filp,
 				unsigned long addr, unsigned long len,
 				unsigned long pgoff, unsigned long flags);
@@ -336,6 +340,7 @@ struct mm_struct {
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
 	int map_count;				/* number of VMAs */
 	struct rw_semaphore mmap_sem;
+	unsigned int mm_sequence;
 	spinlock_t page_table_lock;		/* Protects page tables and some counters */
 
 	struct list_head mmlist;		/* List of maybe swapped mm's.  These are globally strung
@@ -875,7 +880,7 @@ struct task_struct {
 	struct list_head tasks;
 
 	struct mm_struct *mm, *active_mm;
-
+	struct vm_area_cache vmacache;
 /* task state */
 	struct linux_binfmt *binfmt;
 	int exit_state;
--- linux-2.6.21-rc5/include/linux/mm.h
+++ linux-2.6.21-rc5-ed/include/linux/mm.h
@@ -1176,15 +1176,18 @@ extern int expand_upwards(struct vm_area
 #endif
 
 /* Look up the first VMA which satisfies  addr < vm_end,  NULL if none. */
-extern struct vm_area_struct * find_vma(struct mm_struct * mm, unsigned long addr);
+extern struct vm_area_struct * find_vma(struct mm_struct * mm,
+					unsigned long addr,
+					struct vm_area_cache *cache);
 extern struct vm_area_struct * find_vma_prev(struct mm_struct * mm, unsigned long addr,
 					     struct vm_area_struct **pprev);
 
 /* Look up the first VMA which intersects the interval start_addr..end_addr-1,
    NULL if none.  Assume start_addr < end_addr. */
-static inline struct vm_area_struct * find_vma_intersection(struct mm_struct * mm, unsigned long start_addr, unsigned long end_addr)
+static inline struct vm_area_struct * find_vma_intersection(struct mm_struct * mm, 
+	unsigned long start_addr, unsigned long end_addr, struct vm_area_cache *cache)
 {
-	struct vm_area_struct * vma = find_vma(mm,start_addr);
+	struct vm_area_struct * vma = find_vma(mm,start_addr,cache);
 
 	if (vma && end_addr <= vma->vm_start)
 		vma = NULL;
--- linux-2.6.21-rc5/mm/mmap.c
+++ linux-2.6.21-rc5-ed/mm/mmap.c
@@ -267,7 +267,7 @@ asmlinkage unsigned long sys_brk(unsigne
 	}
 
 	/* Check against existing mmap mappings. */
-	if (find_vma_intersection(mm, oldbrk, newbrk+PAGE_SIZE))
+	if (find_vma_intersection(mm, oldbrk, newbrk+PAGE_SIZE, &current->vmacache))
 		goto out;
 
 	/* Ok, looks good - let it rip. */
@@ -447,6 +447,7 @@ static void vma_link(struct mm_struct *m
 		spin_unlock(&mapping->i_mmap_lock);
 
 	mm->map_count++;
+	mm->mm_sequence++;
 	validate_mm(mm);
 }
 
@@ -473,8 +474,7 @@ __vma_unlink(struct mm_struct *mm, struc
 {
 	prev->vm_next = vma->vm_next;
 	rb_erase(&vma->vm_rb, &mm->mm_rb);
-	if (mm->mmap_cache == vma)
-		mm->mmap_cache = prev;
+	mm->mm_sequence++;
 }
 
 /*
@@ -1201,7 +1201,7 @@ arch_get_unmapped_area(struct file *filp
 
 	if (addr) {
 		addr = PAGE_ALIGN(addr);
-		vma = find_vma(mm, addr);
+		vma = find_vma(mm, addr, &current->vmacache);
 		if (TASK_SIZE - len >= addr &&
 		    (!vma || addr + len <= vma->vm_start))
 			return addr;
@@ -1214,7 +1214,7 @@ arch_get_unmapped_area(struct file *filp
 	}
 
 full_search:
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr, &current->vmacache); ; vma = vma->vm_next) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr) {
 			/*
@@ -1275,7 +1275,7 @@ arch_get_unmapped_area_topdown(struct fi
 	/* requesting a specific address */
 	if (addr) {
 		addr = PAGE_ALIGN(addr);
-		vma = find_vma(mm, addr);
+		vma = find_vma(mm, addr, &current->vmacache);
 		if (TASK_SIZE - len >= addr &&
 				(!vma || addr + len <= vma->vm_start))
 			return addr;
@@ -1292,7 +1292,7 @@ arch_get_unmapped_area_topdown(struct fi
 
 	/* make sure it can fit in the remaining address space */
 	if (addr > len) {
-		vma = find_vma(mm, addr-len);
+		vma = find_vma(mm, addr-len, &current->vmacache);
 		if (!vma || addr <= vma->vm_start)
 			/* remember the address as a hint for next time */
 			return (mm->free_area_cache = addr-len);
@@ -1309,7 +1309,7 @@ arch_get_unmapped_area_topdown(struct fi
 		 * else if new region fits below vma->vm_start,
 		 * return with success:
 		 */
-		vma = find_vma(mm, addr);
+		vma = find_vma(mm, addr, &current->vmacache);
 		if (!vma || addr+len <= vma->vm_start)
 			/* remember the address as a hint for next time */
 			return (mm->free_area_cache = addr);
@@ -1397,16 +1397,28 @@ get_unmapped_area(struct file *file, uns
 
 EXPORT_SYMBOL(get_unmapped_area);
 
+struct vm_area_struct * check_vma_cache(struct mm_struct * mm, unsigned long addr, struct vm_area_cache *cache)
+{
+	struct vm_area_struct *vma = cache->mmap_cache;
+	unsigned int mmseq = mm->mm_sequence;
+	smp_rmb();
+	if (cache->sequence == mmseq &&
+		vma &&
+		addr < vma->vm_end && vma->vm_start <= addr)
+		return vma;
+	return NULL;
+}
+
 /* Look up the first VMA which satisfies  addr < vm_end,  NULL if none. */
-struct vm_area_struct * find_vma(struct mm_struct * mm, unsigned long addr)
+struct vm_area_struct * find_vma(struct mm_struct * mm, unsigned long addr, struct vm_area_cache *cache)
 {
 	struct vm_area_struct *vma = NULL;
 
 	if (mm) {
 		/* Check the cache first. */
 		/* (Cache hit rate is typically around 35%.) */
-		vma = mm->mmap_cache;
-		if (!(vma && vma->vm_end > addr && vma->vm_start <= addr)) {
+		vma = check_vma_cache(mm, addr, cache);
+		if (!vma) {
 			struct rb_node * rb_node;
 
 			rb_node = mm->mm_rb.rb_node;
@@ -1426,8 +1438,10 @@ struct vm_area_struct * find_vma(struct 
 				} else
 					rb_node = rb_node->rb_right;
 			}
-			if (vma)
-				mm->mmap_cache = vma;
+			if (vma) {
+				cache->mmap_cache = vma;
+				cache->sequence = mm->mm_sequence;
+			}
 		}
 	}
 	return vma;
@@ -1638,7 +1652,7 @@ find_extend_vma(struct mm_struct * mm, u
 	unsigned long start;
 
 	addr &= PAGE_MASK;
-	vma = find_vma(mm,addr);
+	vma = find_vma(mm,addr,&current->vmacache);
 	if (!vma)
 		return NULL;
 	if (vma->vm_start <= addr)
@@ -1726,7 +1740,7 @@ detach_vmas_to_be_unmapped(struct mm_str
 	else
 		addr = vma ?  vma->vm_end : mm->mmap_base;
 	mm->unmap_area(mm, addr);
-	mm->mmap_cache = NULL;		/* Kill the cache. */
+	mm->mm_sequence++;
 }
 
 /*
@@ -1823,7 +1837,7 @@ int do_munmap(struct mm_struct *mm, unsi
 	}
 
 	/* Does it split the last one? */
-	last = find_vma(mm, end);
+	last = find_vma(mm, end, &current->vmacache);
 	if (last && end > last->vm_start) {
 		int error = split_vma(mm, last, end, 1);
 		if (error)
--- linux-2.6.21-rc5/kernel/fork.c
+++ linux-2.6.21-rc5-ed/kernel/fork.c
@@ -213,7 +213,6 @@ static inline int dup_mmap(struct mm_str
 
 	mm->locked_vm = 0;
 	mm->mmap = NULL;
-	mm->mmap_cache = NULL;
 	mm->free_area_cache = oldmm->mmap_base;
 	mm->cached_hole_size = ~0UL;
 	mm->map_count = 0;
@@ -564,6 +563,7 @@ good_mm:
 
 	tsk->mm = mm;
 	tsk->active_mm = mm;
+	tsk->vmacache.mmap_cache = NULL;
 	return 0;
 
 fail_nomem:
--- linux-2.6.21-rc5/mm/mempolicy.c
+++ linux-2.6.21-rc5-ed/mm/mempolicy.c
@@ -532,7 +532,7 @@ long do_get_mempolicy(int *policy, nodem
 		return -EINVAL;
 	if (flags & MPOL_F_ADDR) {
 		down_read(&mm->mmap_sem);
-		vma = find_vma_intersection(mm, addr, addr+1);
+		vma = find_vma_intersection(mm, addr, addr+1, &current->mmcache);
 		if (!vma) {
 			up_read(&mm->mmap_sem);
 			return -EFAULT;
--- linux-2.6.21-rc5/arch/i386/mm/fault.c
+++ linux-2.6.21-rc5-ed/arch/i386/mm/fault.c
@@ -374,7 +374,7 @@ fastcall void __kprobes do_page_fault(st
 		down_read(&mm->mmap_sem);
 	}
 
-	vma = find_vma(mm, address);
+	vma = find_vma(mm, address, &tsk->vmacache);
 	if (!vma)
 		goto bad_area;
 	if (vma->vm_start <= address)
--- linux-2.6.21-rc5/kernel/futex.c
+++ linux-2.6.21-rc5-ed/kernel/futex.c
@@ -346,7 +346,7 @@ static int futex_handle_fault(unsigned l
 	struct vm_area_struct * vma;
 	struct mm_struct *mm = current->mm;
 
-	if (attempt > 2 || !(vma = find_vma(mm, address)) ||
+	if (attempt > 2 || !(vma = find_vma(mm, address, &current->vmacache)) ||
 	    vma->vm_start > address || !(vma->vm_flags & VM_WRITE))
 		return -EFAULT;
 
--- linux-2.6.21-rc5/mm/fremap.c
+++ linux-2.6.21-rc5-ed/mm/fremap.c
@@ -146,7 +146,7 @@ asmlinkage long sys_remap_file_pages(uns
 	/* We need down_write() to change vma->vm_flags. */
 	down_read(&mm->mmap_sem);
  retry:
-	vma = find_vma(mm, start);
+	vma = find_vma(mm, start, &current->vmacache);
 
 	/*
 	 * Make sure the vma is shared, that it supports prefaulting,
--- linux-2.6.21-rc5/mm/madvise.c
+++ linux-2.6.21-rc5-ed/mm/madvise.c
@@ -329,7 +329,7 @@ asmlinkage long sys_madvise(unsigned lon
 		if (prev)
 			vma = prev->vm_next;
 		else	/* madvise_remove dropped mmap_sem */
-			vma = find_vma(current->mm, start);
+			vma = find_vma(current->mm, start, &current->vmacache);
 	}
 out:
 	up_write(&current->mm->mmap_sem);
--- linux-2.6.21-rc5/mm/memory.c
+++ linux-2.6.21-rc5-ed/mm/memory.c
@@ -2556,7 +2556,7 @@ int make_pages_present(unsigned long add
 	int ret, len, write;
 	struct vm_area_struct * vma;
 
-	vma = find_vma(current->mm, addr);
+	vma = find_vma(current->mm, addr, &current->vmacache);
 	if (!vma)
 		return -1;
 	write = (vma->vm_flags & VM_WRITE) != 0;
--- linux-2.6.21-rc5/mm/mincore.c
+++ linux-2.6.21-rc5-ed/mm/mincore.c
@@ -63,7 +63,7 @@ static long do_mincore(unsigned long add
 	unsigned long nr;
 	int i;
 	pgoff_t pgoff;
-	struct vm_area_struct *vma = find_vma(current->mm, addr);
+	struct vm_area_struct *vma = find_vma(current->mm, addr, &current->vmacache);
 
 	/*
 	 * find_vma() didn't find anything above us, or we're
--- linux-2.6.21-rc5/mm/mremap.c
+++ linux-2.6.21-rc5-ed/mm/mremap.c
@@ -315,7 +315,7 @@ unsigned long do_mremap(unsigned long ad
 	 * Ok, we need to grow..  or relocate.
 	 */
 	ret = -EFAULT;
-	vma = find_vma(mm, addr);
+	vma = find_vma(mm, addr, &current->vmacache);
 	if (!vma || vma->vm_start > addr)
 		goto out;
 	if (is_vm_hugetlb_page(vma)) {
--- linux-2.6.21-rc5/mm/msync.c
+++ linux-2.6.21-rc5-ed/mm/msync.c
@@ -54,7 +54,7 @@ asmlinkage long sys_msync(unsigned long 
 	 * just ignore them, but return -ENOMEM at the end.
 	 */
 	down_read(&mm->mmap_sem);
-	vma = find_vma(mm, start);
+	vma = find_vma(mm, start, &current->vmacache);
 	for (;;) {
 		struct file *file;
 
@@ -86,7 +86,7 @@ asmlinkage long sys_msync(unsigned long 
 			if (error || start >= end)
 				goto out;
 			down_read(&mm->mmap_sem);
-			vma = find_vma(mm, start);
+			vma = find_vma(mm, start, &current->vmacache);
 		} else {
 			if (start >= end) {
 				error = 0;
--- linux-2.6.21-rc5/fs/proc/task_mmu.c
+++ linux-2.6.21-rc5-ed/fs/proc/task_mmu.c
@@ -405,9 +405,15 @@ static void *m_start(struct seq_file *m,
 	down_read(&mm->mmap_sem);
 
 	/* Start with last addr hint */
-	if (last_addr && (vma = find_vma(mm, last_addr))) {
-		vma = vma->vm_next;
-		goto out;
+	if (last_addr) {
+		struct vm_area_cache nocache = {
+			.sequence = mm->mm_sequence - 1,
+			};
+		vma = find_vma(mm, last_addr, &nocache);
+		if (vma) {
+			vma = vma->vm_next;
+			goto out;
+		}
 	}
 
 	/*
--- linux-2.6.21-rc5/drivers/char/mem.c
+++ linux-2.6.21-rc5-ed/drivers/char/mem.c
@@ -633,7 +633,7 @@ static inline size_t read_zero_pagealign
 	down_read(&mm->mmap_sem);
 
 	/* For private mappings, just map in zero pages. */
-	for (vma = find_vma(mm, addr); vma; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr, &current->vmacache); vma; vma = vma->vm_next) {
 		unsigned long count;
 
 		if (vma->vm_start > addr || (vma->vm_flags & VM_WRITE) == 0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
