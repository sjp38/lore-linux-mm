From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199910181945.MAA81369@google.engr.sgi.com>
Subject: Re: [PATCH] kanoj-mm17-2.3.21 kswapd vma scanning protection
Date: Mon, 18 Oct 1999 12:45:02 -0700 (PDT)
In-Reply-To: <199910150006.RAA47575@google.engr.sgi.com> from "Kanoj Sarcar" at Oct 14, 99 05:06:00 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@transmeta.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus,

Here is the reworked vma scanning protection patch against 2.3.22.
This patch has to get one less lock in the page stealing path 
compared to the previous patch that I posted. Let me know if this 
looks okay now, and I will send you an incremental swapout() interface 
cleanup patch that we have discussed.

Thanks.

Kanoj


--- Documentation/vm/locking	Mon Oct 18 11:20:13 1999
+++ Documentation/vm/locking	Mon Oct 18 10:59:49 1999
@@ -0,0 +1,88 @@
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
+
+The current implementation of the vmlist lock uses the page_table_lock,
+which is also the spinlock that page stealers use to protect changes to
+the victim process' ptes. Thus we have a reduction in the total number
+of locks. 
--- /usr/tmp/p_rdiff_a004tQ/exec.c	Mon Oct 18 12:25:58 1999
+++ fs/exec.c	Mon Oct 18 10:39:20 1999
@@ -276,7 +276,9 @@
 		mpnt->vm_offset = 0;
 		mpnt->vm_file = NULL;
 		mpnt->vm_private_data = (void *) 0;
+		vmlist_modify_lock(current->mm);
 		insert_vm_struct(current->mm, mpnt);
+		vmlist_modify_unlock(current->mm);
 		current->mm->total_vm = (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT;
 	} 
 
--- /usr/tmp/p_rdiff_a004tQ/mm.h	Mon Oct 18 12:26:01 1999
+++ include/linux/mm.h	Mon Oct 18 10:40:34 1999
@@ -427,6 +427,12 @@
 #define pgcache_under_min()	(atomic_read(&page_cache_size) * 100 < \
 				page_cache.min_percent * num_physpages)
 
+#define vmlist_access_lock(mm)		spin_lock(&mm->page_table_lock)
+#define vmlist_access_unlock(mm)	spin_unlock(&mm->page_table_lock)
+#define vmlist_modify_lock(mm)		vmlist_access_lock(mm)
+#define vmlist_modify_unlock(mm)	vmlist_access_unlock(mm)
+
+
 #endif /* __KERNEL__ */
 
 #endif
--- /usr/tmp/p_rdiff_a004tQ/shm.c	Mon Oct 18 12:26:05 1999
+++ ipc/shm.c	Mon Oct 18 10:41:05 1999
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
--- /usr/tmp/p_rdiff_a004tQ/ptrace.c	Mon Oct 18 12:26:07 1999
+++ kernel/ptrace.c	Mon Oct 18 10:41:33 1999
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
--- /usr/tmp/p_rdiff_a004tQ/mlock.c	Mon Oct 18 12:26:09 1999
+++ mm/mlock.c	Mon Oct 18 10:42:27 1999
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
 
--- /usr/tmp/p_rdiff_a004tQ/mmap.c	Mon Oct 18 12:26:12 1999
+++ mm/mmap.c	Mon Oct 18 10:43:45 1999
@@ -323,8 +323,10 @@
 	 */
 	flags = vma->vm_flags;
 	addr = vma->vm_start; /* can addr have changed?? */
+	vmlist_modify_lock(mm);
 	insert_vm_struct(mm, vma);
 	merge_segments(mm, vma->vm_start, vma->vm_end);
+	vmlist_modify_unlock(mm);
 	
 	mm->total_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED) {
@@ -527,11 +529,13 @@
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
@@ -552,10 +556,12 @@
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
 
@@ -655,6 +661,7 @@
 
 	npp = (prev ? &prev->vm_next : &mm->mmap);
 	free = NULL;
+	vmlist_modify_lock(mm);
 	for ( ; mpnt && mpnt->vm_start < addr+len; mpnt = *npp) {
 		*npp = mpnt->vm_next;
 		mpnt->vm_next = free;
@@ -662,6 +669,8 @@
 		if (mm->mmap_avl)
 			avl_remove(mpnt, &mm->mmap_avl);
 	}
+	mm->mmap_cache = NULL;	/* Kill the cache. */
+	vmlist_modify_unlock(mm);
 
 	/* Ok - we have the memory areas we should free on the 'free' list,
 	 * so release them, and unmap the page range..
@@ -678,6 +687,11 @@
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
@@ -702,7 +716,6 @@
 
 	free_pgtables(mm, prev, addr, addr+len);
 
-	mm->mmap_cache = NULL;	/* Kill the cache. */
 	return 0;
 }
 
@@ -786,8 +799,10 @@
 	flags = vma->vm_flags;
 	addr = vma->vm_start;
 
+	vmlist_modify_lock(mm);
 	insert_vm_struct(mm, vma);
 	merge_segments(mm, vma->vm_start, vma->vm_end);
+	vmlist_modify_unlock(mm);
 	
 	mm->total_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED) {
@@ -814,7 +829,9 @@
 
 	release_segments(mm);
 	mpnt = mm->mmap;
+	vmlist_modify_lock(mm);
 	mm->mmap = mm->mmap_avl = mm->mmap_cache = NULL;
+	vmlist_modify_unlock(mm);
 	mm->rss = 0;
 	mm->total_vm = 0;
 	mm->locked_vm = 0;
@@ -910,6 +927,7 @@
 		prev = mpnt;
 		mpnt = mpnt->vm_next;
 	}
+	mm->mmap_cache = NULL;		/* Kill the cache. */
 
 	/* prev and mpnt cycle through the list, as long as
 	 * start_addr < mpnt->vm_end && prev->vm_start < end_addr
@@ -946,7 +964,9 @@
 		if (mpnt->vm_ops && mpnt->vm_ops->close) {
 			mpnt->vm_offset += mpnt->vm_end - mpnt->vm_start;
 			mpnt->vm_start = mpnt->vm_end;
+			vmlist_modify_unlock(mm);
 			mpnt->vm_ops->close(mpnt);
+			vmlist_modify_lock(mm);
 		}
 		mm->map_count--;
 		remove_shared_vm_struct(mpnt);
@@ -955,7 +975,6 @@
 		kmem_cache_free(vm_area_cachep, mpnt);
 		mpnt = prev;
 	}
-	mm->mmap_cache = NULL;		/* Kill the cache. */
 }
 
 void __init vma_init(void)
--- /usr/tmp/p_rdiff_a004tQ/mprotect.c	Mon Oct 18 12:26:16 1999
+++ mm/mprotect.c	Mon Oct 18 10:44:41 1999
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
--- /usr/tmp/p_rdiff_a004tQ/mremap.c	Mon Oct 18 12:26:18 1999
+++ mm/mremap.c	Mon Oct 18 10:45:11 1999
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
--- /usr/tmp/p_rdiff_a004tQ/vmscan.c	Mon Oct 18 12:26:20 1999
+++ mm/vmscan.c	Mon Oct 18 10:45:52 1999
@@ -47,9 +47,6 @@
 		goto out_failed;
 
 	page = mem_map + MAP_NR(page_addr);
-	spin_lock(&vma->vm_mm->page_table_lock);
-	if (pte_val(pte) != pte_val(*page_table))
-		goto out_failed_unlock;
 
 	/* Don't look at this pte if it's been accessed recently. */
 	if (pte_young(pte)) {
@@ -59,7 +56,7 @@
 		 */
 		set_pte(page_table, pte_mkold(pte));
 		set_bit(PG_referenced, &page->flags);
-		goto out_failed_unlock;
+		goto out_failed;
 	}
 
 	if (PageReserved(page)
@@ -66,7 +63,7 @@
 	    || PageLocked(page)
 	    || ((gfp_mask & __GFP_DMA) && !PageDMA(page))
 	    || (!(gfp_mask & __GFP_BIGMEM) && PageBIGMEM(page)))
-		goto out_failed_unlock;
+		goto out_failed;
 
 	/*
 	 * Is the page already in the swap cache? If so, then
@@ -84,7 +81,7 @@
 		vma->vm_mm->rss--;
 		flush_tlb_page(vma, address);
 		__free_page(page);
-		goto out_failed_unlock;
+		goto out_failed;
 	}
 
 	/*
@@ -111,7 +108,7 @@
 	 * locks etc.
 	 */
 	if (!(gfp_mask & __GFP_IO))
-		goto out_failed_unlock;
+		goto out_failed;
 
 	/*
 	 * Ok, it's really dirty. That means that
@@ -136,9 +133,9 @@
 	if (vma->vm_ops && vma->vm_ops->swapout) {
 		int error;
 		pte_clear(page_table);
-		spin_unlock(&vma->vm_mm->page_table_lock);
-		flush_tlb_page(vma, address);
 		vma->vm_mm->rss--;
+		flush_tlb_page(vma, address);
+		vmlist_access_unlock(vma->vm_mm);
 		error = vma->vm_ops->swapout(vma, page);
 		if (!error)
 			goto out_free_success;
@@ -154,14 +151,14 @@
 	 */
 	entry = acquire_swap_entry(page);
 	if (!entry)
-		goto out_failed_unlock; /* No swap space left */
+		goto out_failed; /* No swap space left */
 		
 	if (!(page = prepare_bigmem_swapout(page)))
-		goto out_swap_free_unlock;
+		goto out_swap_free;
 
 	vma->vm_mm->rss--;
 	set_pte(page_table, __pte(entry));
-	spin_unlock(&vma->vm_mm->page_table_lock);
+	vmlist_access_unlock(vma->vm_mm);
 
 	flush_tlb_page(vma, address);
 	swap_duplicate(entry);	/* One for the process, one for the swap cache */
@@ -175,13 +172,9 @@
 out_free_success:
 	__free_page(page);
 	return 1;
-out_failed_unlock:
-	spin_unlock(&vma->vm_mm->page_table_lock);
-out_failed:
-	return 0;
-out_swap_free_unlock:
+out_swap_free:
 	swap_free(entry);
-	spin_unlock(&vma->vm_mm->page_table_lock);
+out_failed:
 	return 0;
 
 }
@@ -293,8 +286,10 @@
 	address = mm->swap_address;
 
 	/*
-	 * Find the proper vm-area
+	 * Find the proper vm-area after freezing the vma chain 
+	 * and ptes.
 	 */
+	vmlist_access_lock(mm);
 	vma = find_vma(mm, address);
 	if (vma) {
 		if (address < vma->vm_start)
@@ -310,6 +305,7 @@
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
