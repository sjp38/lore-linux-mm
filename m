From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199910150006.RAA47575@google.engr.sgi.com>
Subject: [PATCH] kanoj-mm17-2.3.21 kswapd vma scanning protection
Date: Thu, 14 Oct 1999 17:06:00 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@transmeta.com, sct@redhat.com, manfreds@colorfullife.com, andrea@suse.de, viro@math.psu.edu
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Linus,

This 2.3 patch fixes the race between page stealing code doing vma
list traversal, and other pieces of code adding/deleting elements
to the list, or otherwise changing fields in the list elements
that might confuse the stealing code. Let me know if things seem
fine, or you want me to alter some code. 

There will probably be a second, independent part to this patch, 
where vma list scanners (callers to find_vma() for example) other
than the page stealing code are fixed to grab mmap_sem. Some of
this has already been pointed out by Manfred Spraul.

We should also probably spawn an independent discussion thread
about the driver swapout() method parameter passing, invoked from
try_to_swap_out(). swapout() currently takes the vma as an input,
but the vma might be getting deleted (the documentation which is
part of the patch describes currently how things are protected),
so it might be prudent to pass individual fields of the vma to the
swapout() method, rather than a pointer to the structure. 

Thanks.

Kanoj

--- Documentation/vm/locking	Thu Oct 14 15:38:03 1999
+++ Documentation/vm/locking	Thu Oct 14 15:44:40 1999
@@ -0,0 +1,83 @@
+Started Oct 1999 by Kanoj Sarcar <kanoj@sgi.com>
+
+The intent of this file is to have an uptodate, running commentary 
+from different people about how locking and synchronization is done 
+in the Linux vm code.
+
+vmlist_access_lock/vmlist_modify_lock
+--------------------------------------
+
+Page stealers pick processes out of the process pool and scan for 
+the best process to steal pages from. To guarantee the existance 
+of the victim mm, a mm_count inc and a mmdrop are done in swap_out().
+Page stealers hold kernel_lock to protect against a bunch of races.
+The vma list of the victim mm is also scanned by the stealer, 
+and the vmlist_lock is used to preserve list sanity against the
+process adding/deleting to the list. This also gurantees existance
+of the vma. Vma existance gurantee while invoking the driver
+swapout() method in try_to_swap_out() also relies on the fact
+that do_munmap() temporarily gets lock_kernel before decimating
+the vma, thus the swapout() method must snapshot all the vma 
+fields it needs before going to sleep (which will release the
+lock_kernel held by the page stealer). Currently, filemap_swapout
+is the only method that depends on this shaky interlocking.
+
+Any code that modifies the vmlist, or the vm_start/vm_end/
+vm_flags:VM_LOCKED/vm_next of any vma *in the list* must prevent 
+kswapd from looking at the chain. This does not include driver mmap() 
+methods, for example, since the vma is still not in the list.
+
+The rules are:
+1. To modify the vmlist (add/delete or change fields in an element), 
+you must hold mmap_sem to guard against clones doing mmap/munmap/faults, 
+(ie all vm system calls and faults), and from ptrace, swapin due to 
+swap deletion etc.
+2. To modify the vmlist (add/delete or change fields in an element), 
+you must also hold vmlist_modify_lock, to guard against page stealers 
+scanning the list.
+3. To scan the vmlist (find_vma()), you must either 
+        a. grab mmap_sem, which should be done by all cases except 
+	   page stealer.
+or
+        b. grab vmlist_access_lock, only done by page stealer.
+4. While holding the vmlist_modify_lock, you must be able to guarantee
+that no code path will lead to page stealing. A better guarantee is
+to claim non sleepability, which ensures that you are not sleeping
+for a lock, whose holder might in turn be doing page stealing.
+5. You must be able to guarantee that while holding vmlist_modify_lock
+or vmlist_access_lock of mm A, you will not try to get either lock
+for mm B.
+
+The caveats are:
+1. find_vma() makes use of, and updates, the mmap_cache pointer hint.
+The update of mmap_cache is racy (page stealer can race with other code
+that invokes find_vma with mmap_sem held), but that is okay, since it 
+is a hint. This can be fixed, if desired, by having find_vma grab the
+vmlist lock.
+
+
+Code that add/delete elements from the vmlist chain are
+1. callers of insert_vm_struct
+2. callers of merge_segments
+3. callers of avl_remove
+
+Code that changes vm_start/vm_end/vm_flags:VM_LOCKED of vma's on
+the list:
+1. expand_stack
+2. mprotect
+3. mlock
+4. mremap
+
+It is advisable that changes to vm_start/vm_end be protected, although 
+in some cases it is not really needed. Eg, vm_start is modified by 
+expand_stack(), it is hard to come up with a destructive scenario without 
+having the vmlist protection in this case.
+
+The vmlist lock nests with the inode i_shared_lock and the kmem cache
+c_spinlock spinlocks. This is okay, since code that holds i_shared_lock 
+never asks for memory, and the kmem code asks for pages after dropping
+c_spinlock.
+
+The vmlist lock can be a sleeping or spin lock. In either case, care
+must be taken that it is not held on entry to the driver methods, since
+those methods might sleep or ask for memory, causing deadlocks.
--- /usr/tmp/p_rdiff_a003hF/exec.c	Thu Oct 14 16:35:50 1999
+++ fs/exec.c	Thu Oct 14 09:50:25 1999
@@ -276,7 +276,9 @@
 		mpnt->vm_offset = 0;
 		mpnt->vm_file = NULL;
 		mpnt->vm_private_data = (void *) 0;
+		vmlist_modify_lock(current->mm);
 		insert_vm_struct(current->mm, mpnt);
+		vmlist_modify_unlock(current->mm);
 		current->mm->total_vm = (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT;
 	} 
 
--- /usr/tmp/p_rdiff_a003hO/mm.h	Thu Oct 14 16:35:59 1999
+++ include/linux/mm.h	Thu Oct 14 13:45:29 1999
@@ -427,6 +427,12 @@
 #define pgcache_under_min()	(atomic_read(&page_cache_size) * 100 < \
 				page_cache.min_percent * num_physpages)
 
+#define vmlist_access_lock(mm)		down(&mm->vmlist_lock)
+#define vmlist_access_unlock(mm)	up(&mm->vmlist_lock)
+#define vmlist_modify_lock(mm)		vmlist_access_lock(mm)
+#define vmlist_modify_unlock(mm)	vmlist_access_unlock(mm)
+
+
 #endif /* __KERNEL__ */
 
 #endif
--- /usr/tmp/p_rdiff_a003hX/sched.h	Thu Oct 14 16:36:08 1999
+++ include/linux/sched.h	Thu Oct 14 13:45:24 1999
@@ -213,6 +213,7 @@
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
 	int map_count;				/* number of VMAs */
 	struct semaphore mmap_sem;
+	struct semaphore vmlist_lock;		/* protect against kswapd */
 	spinlock_t page_table_lock;
 	unsigned long context;
 	unsigned long start_code, end_code, start_data, end_data;
@@ -235,6 +236,7 @@
 		swapper_pg_dir, 			\
 		ATOMIC_INIT(2), ATOMIC_INIT(1), 1,	\
 		__MUTEX_INITIALIZER(name.mmap_sem),	\
+		__MUTEX_INITIALIZER(name.vmlist_lock),	\
 		SPIN_LOCK_UNLOCKED,			\
 		0,					\
 		0, 0, 0, 0,				\
--- /usr/tmp/p_rdiff_a003he/shm.c	Thu Oct 14 16:36:17 1999
+++ ipc/shm.c	Wed Oct 13 14:31:47 1999
@@ -462,8 +462,10 @@
 	   > (unsigned long) current->rlim[RLIMIT_AS].rlim_cur)
 		return -ENOMEM;
 	current->mm->total_vm += tmp >> PAGE_SHIFT;
+	vmlist_modify_lock(current->mm);
 	insert_vm_struct(current->mm, shmd);
 	merge_segments(current->mm, shmd->vm_start, shmd->vm_end);
+	vmlist_modify_unlock(current->mm);
 
 	return 0;
 }
--- /usr/tmp/p_rdiff_a003hn/fork.c	Thu Oct 14 16:36:26 1999
+++ kernel/fork.c	Thu Oct 14 13:47:37 1999
@@ -303,6 +303,7 @@
 		atomic_set(&mm->mm_users, 1);
 		atomic_set(&mm->mm_count, 1);
 		init_MUTEX(&mm->mmap_sem);
+		init_MUTEX(&mm->vmlist_lock);
 		mm->page_table_lock = SPIN_LOCK_UNLOCKED;
 		mm->pgd = pgd_alloc();
 		if (mm->pgd)
--- /usr/tmp/p_rdiff_a003hw/ptrace.c	Thu Oct 14 16:36:34 1999
+++ kernel/ptrace.c	Wed Oct 13 10:43:38 1999
@@ -80,12 +80,14 @@
 int access_process_vm(struct task_struct *tsk, unsigned long addr, void *buf, int len, int write)
 {
 	int copied;
-	struct vm_area_struct * vma = find_extend_vma(tsk, addr);
+	struct vm_area_struct * vma;
 
-	if (!vma)
-		return 0;
-
 	down(&tsk->mm->mmap_sem);
+	vma = find_extend_vma(tsk, addr);
+	if (!vma) {
+		up(&tsk->mm->mmap_sem);
+		return 0;
+	}
 	copied = 0;
 	for (;;) {
 		unsigned long offset = addr & ~PAGE_MASK;
--- /usr/tmp/p_rdiff_a003i5/mlock.c	Thu Oct 14 16:36:43 1999
+++ mm/mlock.c	Tue Oct 12 16:35:25 1999
@@ -13,7 +13,9 @@
 
 static inline int mlock_fixup_all(struct vm_area_struct * vma, int newflags)
 {
+	vmlist_modify_lock(vma->vm_mm);
 	vma->vm_flags = newflags;
+	vmlist_modify_unlock(vma->vm_mm);
 	return 0;
 }
 
@@ -26,15 +28,17 @@
 	if (!n)
 		return -EAGAIN;
 	*n = *vma;
-	vma->vm_start = end;
 	n->vm_end = end;
-	vma->vm_offset += vma->vm_start - n->vm_start;
 	n->vm_flags = newflags;
 	if (n->vm_file)
 		get_file(n->vm_file);
 	if (n->vm_ops && n->vm_ops->open)
 		n->vm_ops->open(n);
+	vmlist_modify_lock(vma->vm_mm);
+	vma->vm_offset += end - vma->vm_start;
+	vma->vm_start = end;
 	insert_vm_struct(current->mm, n);
+	vmlist_modify_unlock(vma->vm_mm);
 	return 0;
 }
 
@@ -47,7 +51,6 @@
 	if (!n)
 		return -EAGAIN;
 	*n = *vma;
-	vma->vm_end = start;
 	n->vm_start = start;
 	n->vm_offset += n->vm_start - vma->vm_start;
 	n->vm_flags = newflags;
@@ -55,7 +58,10 @@
 		get_file(n->vm_file);
 	if (n->vm_ops && n->vm_ops->open)
 		n->vm_ops->open(n);
+	vmlist_modify_lock(vma->vm_mm);
+	vma->vm_end = start;
 	insert_vm_struct(current->mm, n);
+	vmlist_modify_unlock(vma->vm_mm);
 	return 0;
 }
 
@@ -75,10 +81,7 @@
 	*left = *vma;
 	*right = *vma;
 	left->vm_end = start;
-	vma->vm_start = start;
-	vma->vm_end = end;
 	right->vm_start = end;
-	vma->vm_offset += vma->vm_start - left->vm_start;
 	right->vm_offset += right->vm_start - left->vm_start;
 	vma->vm_flags = newflags;
 	if (vma->vm_file)
@@ -88,8 +91,14 @@
 		vma->vm_ops->open(left);
 		vma->vm_ops->open(right);
 	}
+	vmlist_modify_lock(vma->vm_mm);
+	vma->vm_offset += start - vma->vm_start;
+	vma->vm_start = start;
+	vma->vm_end = end;
+	vma->vm_flags = newflags;
 	insert_vm_struct(current->mm, left);
 	insert_vm_struct(current->mm, right);
+	vmlist_modify_unlock(vma->vm_mm);
 	return 0;
 }
 
@@ -168,7 +177,9 @@
 			break;
 		}
 	}
+	vmlist_modify_lock(current->mm);
 	merge_segments(current->mm, start, end);
+	vmlist_modify_unlock(current->mm);
 	return error;
 }
 
@@ -240,7 +251,9 @@
 		if (error)
 			break;
 	}
+	vmlist_modify_lock(current->mm);
 	merge_segments(current->mm, 0, TASK_SIZE);
+	vmlist_modify_unlock(current->mm);
 	return error;
 }
 
--- /usr/tmp/p_rdiff_a003iE/mmap.c	Thu Oct 14 16:36:52 1999
+++ mm/mmap.c	Thu Oct 14 15:30:30 1999
@@ -324,8 +324,10 @@
 	 */
 	flags = vma->vm_flags;
 	addr = vma->vm_start; /* can addr have changed?? */
+	vmlist_modify_lock(mm);
 	insert_vm_struct(mm, vma);
 	merge_segments(mm, vma->vm_start, vma->vm_end);
+	vmlist_modify_unlock(mm);
 	
 	mm->total_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED) {
@@ -528,11 +530,13 @@
 	}
 
 	/* Work out to one of the ends. */
-	if (end == area->vm_end)
+	if (end == area->vm_end) {
 		area->vm_end = addr;
-	else if (addr == area->vm_start) {
+		vmlist_modify_lock(current->mm);
+	} else if (addr == area->vm_start) {
 		area->vm_offset += (end - area->vm_start);
 		area->vm_start = end;
+		vmlist_modify_lock(current->mm);
 	} else {
 	/* Unmapping a hole: area->vm_start < addr <= end < area->vm_end */
 		/* Add end mapping -- leave beginning for below */
@@ -553,10 +557,12 @@
 		if (mpnt->vm_ops && mpnt->vm_ops->open)
 			mpnt->vm_ops->open(mpnt);
 		area->vm_end = addr;	/* Truncate area */
+		vmlist_modify_lock(current->mm);
 		insert_vm_struct(current->mm, mpnt);
 	}
 
 	insert_vm_struct(current->mm, area);
+	vmlist_modify_unlock(current->mm);
 	return extra;
 }
 
@@ -656,6 +662,7 @@
 
 	npp = (prev ? &prev->vm_next : &mm->mmap);
 	free = NULL;
+	vmlist_modify_lock(mm);
 	for ( ; mpnt && mpnt->vm_start < addr+len; mpnt = *npp) {
 		*npp = mpnt->vm_next;
 		mpnt->vm_next = free;
@@ -663,6 +670,8 @@
 		if (mm->mmap_avl)
 			avl_remove(mpnt, &mm->mmap_avl);
 	}
+	mm->mmap_cache = NULL;	/* Kill the cache. */
+	vmlist_modify_unlock(mm);
 
 	/* Ok - we have the memory areas we should free on the 'free' list,
 	 * so release them, and unmap the page range..
@@ -679,6 +688,11 @@
 		end = end > mpnt->vm_end ? mpnt->vm_end : end;
 		size = end - st;
 
+		/*
+		 * The lock_kernel interlocks with kswapd try_to_swap_out
+		 * invoking a driver swapout() method, and being able to
+		 * guarantee vma existance.
+		 */
 		lock_kernel();
 		if (mpnt->vm_ops && mpnt->vm_ops->unmap)
 			mpnt->vm_ops->unmap(mpnt, st, size);
@@ -703,7 +717,6 @@
 
 	free_pgtables(mm, prev, addr, addr+len);
 
-	mm->mmap_cache = NULL;	/* Kill the cache. */
 	return 0;
 }
 
@@ -787,8 +800,10 @@
 	flags = vma->vm_flags;
 	addr = vma->vm_start;
 
+	vmlist_modify_lock(mm);
 	insert_vm_struct(mm, vma);
 	merge_segments(mm, vma->vm_start, vma->vm_end);
+	vmlist_modify_unlock(mm);
 	
 	mm->total_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED) {
@@ -815,7 +830,9 @@
 
 	release_segments(mm);
 	mpnt = mm->mmap;
+	vmlist_modify_lock(mm);
 	mm->mmap = mm->mmap_avl = mm->mmap_cache = NULL;
+	vmlist_modify_unlock(mm);
 	mm->rss = 0;
 	mm->total_vm = 0;
 	mm->locked_vm = 0;
@@ -911,6 +928,7 @@
 		prev = mpnt;
 		mpnt = mpnt->vm_next;
 	}
+	mm->mmap_cache = NULL;		/* Kill the cache. */
 
 	/* prev and mpnt cycle through the list, as long as
 	 * start_addr < mpnt->vm_end && prev->vm_start < end_addr
@@ -947,7 +965,9 @@
 		if (mpnt->vm_ops && mpnt->vm_ops->close) {
 			mpnt->vm_offset += mpnt->vm_end - mpnt->vm_start;
 			mpnt->vm_start = mpnt->vm_end;
+			vmlist_modify_unlock(mm);
 			mpnt->vm_ops->close(mpnt);
+			vmlist_modify_lock(mm);
 		}
 		mm->map_count--;
 		remove_shared_vm_struct(mpnt);
@@ -956,7 +976,6 @@
 		kmem_cache_free(vm_area_cachep, mpnt);
 		mpnt = prev;
 	}
-	mm->mmap_cache = NULL;		/* Kill the cache. */
 }
 
 void __init vma_init(void)
--- /usr/tmp/p_rdiff_a003iN/mprotect.c	Thu Oct 14 16:37:02 1999
+++ mm/mprotect.c	Wed Oct 13 10:57:02 1999
@@ -82,8 +82,10 @@
 static inline int mprotect_fixup_all(struct vm_area_struct * vma,
 	int newflags, pgprot_t prot)
 {
+	vmlist_modify_lock(vma->vm_mm);
 	vma->vm_flags = newflags;
 	vma->vm_page_prot = prot;
+	vmlist_modify_unlock(vma->vm_mm);
 	return 0;
 }
 
@@ -97,9 +99,7 @@
 	if (!n)
 		return -ENOMEM;
 	*n = *vma;
-	vma->vm_start = end;
 	n->vm_end = end;
-	vma->vm_offset += vma->vm_start - n->vm_start;
 	n->vm_flags = newflags;
 	n->vm_page_prot = prot;
 	if (n->vm_file)
@@ -106,7 +106,11 @@
 		get_file(n->vm_file);
 	if (n->vm_ops && n->vm_ops->open)
 		n->vm_ops->open(n);
+	vmlist_modify_lock(vma->vm_mm);
+	vma->vm_offset += end - vma->vm_start;
+	vma->vm_start = end;
 	insert_vm_struct(current->mm, n);
+	vmlist_modify_unlock(vma->vm_mm);
 	return 0;
 }
 
@@ -120,7 +124,6 @@
 	if (!n)
 		return -ENOMEM;
 	*n = *vma;
-	vma->vm_end = start;
 	n->vm_start = start;
 	n->vm_offset += n->vm_start - vma->vm_start;
 	n->vm_flags = newflags;
@@ -129,7 +132,10 @@
 		get_file(n->vm_file);
 	if (n->vm_ops && n->vm_ops->open)
 		n->vm_ops->open(n);
+	vmlist_modify_lock(vma->vm_mm);
+	vma->vm_end = start;
 	insert_vm_struct(current->mm, n);
+	vmlist_modify_unlock(vma->vm_mm);
 	return 0;
 }
 
@@ -150,13 +156,8 @@
 	*left = *vma;
 	*right = *vma;
 	left->vm_end = start;
-	vma->vm_start = start;
-	vma->vm_end = end;
 	right->vm_start = end;
-	vma->vm_offset += vma->vm_start - left->vm_start;
 	right->vm_offset += right->vm_start - left->vm_start;
-	vma->vm_flags = newflags;
-	vma->vm_page_prot = prot;
 	if (vma->vm_file)
 		atomic_add(2,&vma->vm_file->f_count);
 	if (vma->vm_ops && vma->vm_ops->open) {
@@ -163,8 +164,15 @@
 		vma->vm_ops->open(left);
 		vma->vm_ops->open(right);
 	}
+	vmlist_modify_lock(vma->vm_mm);
+	vma->vm_offset += start - vma->vm_start;
+	vma->vm_start = start;
+	vma->vm_end = end;
+	vma->vm_flags = newflags;
+	vma->vm_page_prot = prot;
 	insert_vm_struct(current->mm, left);
 	insert_vm_struct(current->mm, right);
+	vmlist_modify_unlock(vma->vm_mm);
 	return 0;
 }
 
@@ -246,7 +254,9 @@
 			break;
 		}
 	}
+	vmlist_modify_lock(current->mm);
 	merge_segments(current->mm, start, end);
+	vmlist_modify_unlock(current->mm);
 out:
 	up(&current->mm->mmap_sem);
 	return error;
--- /usr/tmp/p_rdiff_a003iW/mremap.c	Thu Oct 14 16:37:10 1999
+++ mm/mremap.c	Wed Oct 13 10:58:54 1999
@@ -141,8 +141,10 @@
 				get_file(new_vma->vm_file);
 			if (new_vma->vm_ops && new_vma->vm_ops->open)
 				new_vma->vm_ops->open(new_vma);
+			vmlist_modify_lock(current->mm);
 			insert_vm_struct(current->mm, new_vma);
 			merge_segments(current->mm, new_vma->vm_start, new_vma->vm_end);
+			vmlist_modify_unlock(vma->vm_mm);
 			do_munmap(addr, old_len);
 			current->mm->total_vm += new_len >> PAGE_SHIFT;
 			if (new_vma->vm_flags & VM_LOCKED) {
@@ -220,7 +222,9 @@
 		/* can we just expand the current mapping? */
 		if (max_addr - addr >= new_len) {
 			int pages = (new_len - old_len) >> PAGE_SHIFT;
+			vmlist_modify_lock(vma->vm_mm);
 			vma->vm_end = addr + new_len;
+			vmlist_modify_unlock(vma->vm_mm);
 			current->mm->total_vm += pages;
 			if (vma->vm_flags & VM_LOCKED) {
 				current->mm->locked_vm += pages;
--- /usr/tmp/p_rdiff_a003id/vmscan.c	Thu Oct 14 16:37:19 1999
+++ mm/vmscan.c	Thu Oct 14 14:49:38 1999
@@ -139,6 +139,7 @@
 		spin_unlock(&vma->vm_mm->page_table_lock);
 		flush_tlb_page(vma, address);
 		vma->vm_mm->rss--;
+		vmlist_access_unlock(vma->vm_mm);
 		error = vma->vm_ops->swapout(vma, page);
 		if (!error)
 			goto out_free_success;
@@ -164,6 +165,7 @@
 	spin_unlock(&vma->vm_mm->page_table_lock);
 
 	flush_tlb_page(vma, address);
+	vmlist_access_unlock(vma->vm_mm);
 	swap_duplicate(entry);	/* One for the process, one for the swap cache */
 
 	/* This will also lock the page */
@@ -295,6 +297,7 @@
 	/*
 	 * Find the proper vm-area
 	 */
+	vmlist_access_lock(mm);
 	vma = find_vma(mm, address);
 	if (vma) {
 		if (address < vma->vm_start)
@@ -310,6 +313,7 @@
 			address = vma->vm_start;
 		}
 	}
+	vmlist_access_unlock(mm);
 
 	/* We didn't find anything for the process */
 	mm->swap_cnt = 0;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
