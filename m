Date: Fri, 13 Oct 2000 20:11:36 +0200
From: Rasmus Andersen <rasmus@jaquet.dk>
Subject: Re: Updated Linux 2.4 Status/TODO List (from the ALS show)
Message-ID: <20001013201136.B630@jaquet.dk>
References: <200010130425.VAA11538@pizda.ninka.net> <Pine.LNX.4.10.10010122203410.14174-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10010122203410.14174-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Thu, Oct 12, 2000 at 10:05:19PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@conectiva.com.br
List-ID: <linux-mm.kvack.org>

> In fact, if somebody sends me patches to remove the "vmlist_access_lock()"
> stuff completely, and replace them with explicit page_table_lock things,
> I'll apply it pretty much immediately. I don't like information hiding,
> and right now that's the only thing that the vmlist_access_lock() stuff is
> doing.

(Pruned the cc-list and added Rik van Riel since this touches his
 code domain.)

Something like this?

diff -aur linux-240-test10-pre1/fs/exec.c linux/fs/exec.c
--- linux-240-test10-pre1/fs/exec.c	Mon Oct  2 22:32:47 2000
+++ linux/fs/exec.c	Fri Oct 13 16:01:29 2000
@@ -314,9 +314,9 @@
 		mpnt->vm_pgoff = 0;
 		mpnt->vm_file = NULL;
 		mpnt->vm_private_data = (void *) 0;
-		vmlist_modify_lock(current->mm);
+		spin_lock(&current->mm->page_table_lock);
 		insert_vm_struct(current->mm, mpnt);
-		vmlist_modify_unlock(current->mm);
+		spin_unlock(&current->mm->page_table_lock);
 		current->mm->total_vm = (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT;
 	} 
 
diff -aur linux-240-test10-pre1/include/linux/mm.h linux/include/linux/mm.h
--- linux-240-test10-pre1/include/linux/mm.h	Tue Oct  3 22:12:52 2000
+++ linux/include/linux/mm.h	Fri Oct 13 18:43:42 2000
@@ -527,11 +527,6 @@
 #define pgcache_under_min()	(atomic_read(&page_cache_size) * 100 < \
 				page_cache.min_percent * num_physpages)
 
-#define vmlist_access_lock(mm)		spin_lock(&mm->page_table_lock)
-#define vmlist_access_unlock(mm)	spin_unlock(&mm->page_table_lock)
-#define vmlist_modify_lock(mm)		vmlist_access_lock(mm)
-#define vmlist_modify_unlock(mm)	vmlist_access_unlock(mm)
-
 #endif /* __KERNEL__ */
 
 #endif
diff -aur linux-240-test10-pre1/mm/filemap.c linux/mm/filemap.c
--- linux-240-test10-pre1/mm/filemap.c	Tue Oct  3 22:12:52 2000
+++ linux/mm/filemap.c	Fri Oct 13 16:01:29 2000
@@ -1766,11 +1766,11 @@
 	get_file(n->vm_file);
 	if (n->vm_ops && n->vm_ops->open)
 		n->vm_ops->open(n);
-	vmlist_modify_lock(vma->vm_mm);
+	spin_lock(&vma->vm_mm->page_table_lock);
 	vma->vm_pgoff += (end - vma->vm_start) >> PAGE_SHIFT;
 	vma->vm_start = end;
 	insert_vm_struct(current->mm, n);
-	vmlist_modify_unlock(vma->vm_mm);
+	spin_unlock(&vma->vm_mm->page_table_lock);
 	return 0;
 }
 
@@ -1790,10 +1790,10 @@
 	get_file(n->vm_file);
 	if (n->vm_ops && n->vm_ops->open)
 		n->vm_ops->open(n);
-	vmlist_modify_lock(vma->vm_mm);
+	spin_lock(&vma->vm_mm->page_table_lock);
 	vma->vm_end = start;
 	insert_vm_struct(current->mm, n);
-	vmlist_modify_unlock(vma->vm_mm);
+	spin_unlock(&vma->vm_mm->page_table_lock);
 	return 0;
 }
 
@@ -1823,7 +1823,7 @@
 		vma->vm_ops->open(left);
 		vma->vm_ops->open(right);
 	}
-	vmlist_modify_lock(vma->vm_mm);
+	spin_lock(&vma->vm_mm->page_table_lock);
 	vma->vm_pgoff += (start - vma->vm_start) >> PAGE_SHIFT;
 	vma->vm_start = start;
 	vma->vm_end = end;
@@ -1831,7 +1831,7 @@
 	vma->vm_raend = 0;
 	insert_vm_struct(current->mm, left);
 	insert_vm_struct(current->mm, right);
-	vmlist_modify_unlock(vma->vm_mm);
+	spin_unlock(&vma->vm_mm->page_table_lock);
 	return 0;
 }
 
diff -aur linux-240-test10-pre1/mm/mlock.c linux/mm/mlock.c
--- linux-240-test10-pre1/mm/mlock.c	Wed Mar 15 02:45:20 2000
+++ linux/mm/mlock.c	Fri Oct 13 16:01:29 2000
@@ -14,9 +14,9 @@
 
 static inline int mlock_fixup_all(struct vm_area_struct * vma, int newflags)
 {
-	vmlist_modify_lock(vma->vm_mm);
+	spin_lock(&vma->vm_mm->page_table_lock);
 	vma->vm_flags = newflags;
-	vmlist_modify_unlock(vma->vm_mm);
+	spin_unlock(&vma->vm_mm->page_table_lock);
 	return 0;
 }
 
@@ -36,11 +36,11 @@
 		get_file(n->vm_file);
 	if (n->vm_ops && n->vm_ops->open)
 		n->vm_ops->open(n);
-	vmlist_modify_lock(vma->vm_mm);
+	spin_lock(&vma->vm_mm->page_table_lock);
 	vma->vm_pgoff += (end - vma->vm_start) >> PAGE_SHIFT;
 	vma->vm_start = end;
 	insert_vm_struct(current->mm, n);
-	vmlist_modify_unlock(vma->vm_mm);
+	spin_unlock(&vma->vm_mm->page_table_lock);
 	return 0;
 }
 
@@ -61,10 +61,10 @@
 		get_file(n->vm_file);
 	if (n->vm_ops && n->vm_ops->open)
 		n->vm_ops->open(n);
-	vmlist_modify_lock(vma->vm_mm);
+	spin_lock(&vma->vm_mm->page_table_lock);
 	vma->vm_end = start;
 	insert_vm_struct(current->mm, n);
-	vmlist_modify_unlock(vma->vm_mm);
+	spin_unlock(&vma->vm_mm->page_table_lock);
 	return 0;
 }
 
@@ -96,7 +96,7 @@
 		vma->vm_ops->open(left);
 		vma->vm_ops->open(right);
 	}
-	vmlist_modify_lock(vma->vm_mm);
+	spin_lock(&vma->vm_mm->page_table_lock);
 	vma->vm_pgoff += (start - vma->vm_start) >> PAGE_SHIFT;
 	vma->vm_start = start;
 	vma->vm_end = end;
@@ -104,7 +104,7 @@
 	vma->vm_raend = 0;
 	insert_vm_struct(current->mm, left);
 	insert_vm_struct(current->mm, right);
-	vmlist_modify_unlock(vma->vm_mm);
+	spin_unlock(&vma->vm_mm->page_table_lock);
 	return 0;
 }
 
@@ -183,9 +183,9 @@
 			break;
 		}
 	}
-	vmlist_modify_lock(current->mm);
+	spin_lock(&current->mm->page_table_lock);
 	merge_segments(current->mm, start, end);
-	vmlist_modify_unlock(current->mm);
+	spin_unlock(&current->mm->page_table_lock);
 	return error;
 }
 
@@ -257,9 +257,9 @@
 		if (error)
 			break;
 	}
-	vmlist_modify_lock(current->mm);
+	spin_lock(&current->mm->page_table_lock);
 	merge_segments(current->mm, 0, TASK_SIZE);
-	vmlist_modify_unlock(current->mm);
+	spin_unlock(&current->mm->page_table_lock);
 	return error;
 }
 
diff -aur linux-240-test10-pre1/mm/mmap.c linux/mm/mmap.c
--- linux-240-test10-pre1/mm/mmap.c	Mon Oct  2 22:32:50 2000
+++ linux/mm/mmap.c	Fri Oct 13 18:48:06 2000
@@ -317,12 +317,12 @@
 	 */
 	flags = vma->vm_flags;
 	addr = vma->vm_start; /* can addr have changed?? */
-	vmlist_modify_lock(mm);
+	spin_lock(&mm->page_table_lock);
 	insert_vm_struct(mm, vma);
 	if (correct_wcount)
 		atomic_inc(&file->f_dentry->d_inode->i_writecount);
 	merge_segments(mm, vma->vm_start, vma->vm_end);
-	vmlist_modify_unlock(mm);
+	spin_unlock(&mm->page_table_lock);
 	
 	mm->total_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED) {
@@ -534,11 +534,11 @@
 	/* Work out to one of the ends. */
 	if (end == area->vm_end) {
 		area->vm_end = addr;
-		vmlist_modify_lock(mm);
+		spin_lock(&mm->page_table_lock);
 	} else if (addr == area->vm_start) {
 		area->vm_pgoff += (end - area->vm_start) >> PAGE_SHIFT;
 		area->vm_start = end;
-		vmlist_modify_lock(mm);
+		spin_lock(&mm->page_table_lock);
 	} else {
 	/* Unmapping a hole: area->vm_start < addr <= end < area->vm_end */
 		/* Add end mapping -- leave beginning for below */
@@ -560,12 +560,12 @@
 		if (mpnt->vm_ops && mpnt->vm_ops->open)
 			mpnt->vm_ops->open(mpnt);
 		area->vm_end = addr;	/* Truncate area */
-		vmlist_modify_lock(mm);
+		spin_lock(&mm->page_table_lock);
 		insert_vm_struct(mm, mpnt);
 	}
 
 	insert_vm_struct(mm, area);
-	vmlist_modify_unlock(mm);
+	spin_unlock(&mm->page_table_lock);
 	return extra;
 }
 
@@ -670,7 +670,7 @@
 
 	npp = (prev ? &prev->vm_next : &mm->mmap);
 	free = NULL;
-	vmlist_modify_lock(mm);
+	spin_lock(&mm->page_table_lock);
 	for ( ; mpnt && mpnt->vm_start < addr+len; mpnt = *npp) {
 		*npp = mpnt->vm_next;
 		mpnt->vm_next = free;
@@ -679,7 +679,7 @@
 			avl_remove(mpnt, &mm->mmap_avl);
 	}
 	mm->mmap_cache = NULL;	/* Kill the cache. */
-	vmlist_modify_unlock(mm);
+	spin_unlock(&mm->page_table_lock);
 
 	/* Ok - we have the memory areas we should free on the 'free' list,
 	 * so release them, and unmap the page range..
@@ -811,10 +811,10 @@
 	flags = vma->vm_flags;
 	addr = vma->vm_start;
 
-	vmlist_modify_lock(mm);
+	spin_lock(&mm->page_table_lock);
 	insert_vm_struct(mm, vma);
 	merge_segments(mm, vma->vm_start, vma->vm_end);
-	vmlist_modify_unlock(mm);
+	spin_unlock(&mm->page_table_lock);
 	
 	mm->total_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED) {
@@ -841,9 +841,9 @@
 
 	release_segments(mm);
-	vmlist_modify_lock(mm);
+	spin_lock(&mm->page_table_lock);
 	mpnt = mm->mmap;
 	mm->mmap = mm->mmap_avl = mm->mmap_cache = NULL;
-	vmlist_modify_unlock(mm);
+	spin_unlock(&mm->page_table_lock);
 	mm->rss = 0;
 	mm->total_vm = 0;
 	mm->locked_vm = 0;
@@ -985,9 +985,9 @@
 		if (mpnt->vm_ops && mpnt->vm_ops->close) {
 			mpnt->vm_pgoff += (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT;
 			mpnt->vm_start = mpnt->vm_end;
-			vmlist_modify_unlock(mm);
+			spin_unlock(&mm->page_table_lock);
 			mpnt->vm_ops->close(mpnt);
-			vmlist_modify_lock(mm);
+			spin_lock(&mm->page_table_lock);
 		}
 		mm->map_count--;
 		remove_shared_vm_struct(mpnt);
diff -aur linux-240-test10-pre1/mm/mprotect.c linux/mm/mprotect.c
--- linux-240-test10-pre1/mm/mprotect.c	Wed Mar 15 02:45:21 2000
+++ linux/mm/mprotect.c	Fri Oct 13 16:01:29 2000
@@ -86,10 +86,10 @@
 static inline int mprotect_fixup_all(struct vm_area_struct * vma,
 	int newflags, pgprot_t prot)
 {
-	vmlist_modify_lock(vma->vm_mm);
+	spin_lock(&vma->vm_mm->page_table_lock);
 	vma->vm_flags = newflags;
 	vma->vm_page_prot = prot;
-	vmlist_modify_unlock(vma->vm_mm);
+	spin_unlock(&vma->vm_mm->page_table_lock);
 	return 0;
 }
 
@@ -111,11 +111,11 @@
 		get_file(n->vm_file);
 	if (n->vm_ops && n->vm_ops->open)
 		n->vm_ops->open(n);
-	vmlist_modify_lock(vma->vm_mm);
+	spin_lock(&vma->vm_mm->page_table_lock);
 	vma->vm_pgoff += (end - vma->vm_start) >> PAGE_SHIFT;
 	vma->vm_start = end;
 	insert_vm_struct(current->mm, n);
-	vmlist_modify_unlock(vma->vm_mm);
+	spin_unlock(&vma->vm_mm->page_table_lock);
 	return 0;
 }
 
@@ -138,10 +138,10 @@
 		get_file(n->vm_file);
 	if (n->vm_ops && n->vm_ops->open)
 		n->vm_ops->open(n);
-	vmlist_modify_lock(vma->vm_mm);
+	spin_lock(&vma->vm_mm->page_table_lock);
 	vma->vm_end = start;
 	insert_vm_struct(current->mm, n);
-	vmlist_modify_unlock(vma->vm_mm);
+	spin_unlock(&vma->vm_mm->page_table_lock);
 	return 0;
 }
 
@@ -172,7 +172,7 @@
 		vma->vm_ops->open(left);
 		vma->vm_ops->open(right);
 	}
-	vmlist_modify_lock(vma->vm_mm);
+	spin_lock(&vma->vm_mm->page_table_lock);
 	vma->vm_pgoff += (start - vma->vm_start) >> PAGE_SHIFT;
 	vma->vm_start = start;
 	vma->vm_end = end;
@@ -181,7 +181,7 @@
 	vma->vm_page_prot = prot;
 	insert_vm_struct(current->mm, left);
 	insert_vm_struct(current->mm, right);
-	vmlist_modify_unlock(vma->vm_mm);
+	spin_unlock(&vma->vm_mm->page_table_lock);
 	return 0;
 }
 
@@ -263,9 +263,9 @@
 			break;
 		}
 	}
-	vmlist_modify_lock(current->mm);
+	spin_lock(&current->mm->page_table_lock);
 	merge_segments(current->mm, start, end);
-	vmlist_modify_unlock(current->mm);
+	spin_unlock(&current->mm->page_table_lock);
 out:
 	up(&current->mm->mmap_sem);
 	return error;
diff -aur linux-240-test10-pre1/mm/mremap.c linux/mm/mremap.c
--- linux-240-test10-pre1/mm/mremap.c	Tue Oct  3 22:12:52 2000
+++ linux/mm/mremap.c	Fri Oct 13 16:01:29 2000
@@ -141,10 +141,10 @@
 				get_file(new_vma->vm_file);
 			if (new_vma->vm_ops && new_vma->vm_ops->open)
 				new_vma->vm_ops->open(new_vma);
-			vmlist_modify_lock(current->mm);
+			spin_lock(&current->mm->page_table_lock);
 			insert_vm_struct(current->mm, new_vma);
 			merge_segments(current->mm, new_vma->vm_start, new_vma->vm_end);
-			vmlist_modify_unlock(current->mm);
+			spin_unlock(&current->mm->page_table_lock);
 			do_munmap(current->mm, addr, old_len);
 			current->mm->total_vm += new_len >> PAGE_SHIFT;
 			if (new_vma->vm_flags & VM_LOCKED) {
@@ -258,9 +258,9 @@
 		/* can we just expand the current mapping? */
 		if (max_addr - addr >= new_len) {
 			int pages = (new_len - old_len) >> PAGE_SHIFT;
-			vmlist_modify_lock(vma->vm_mm);
+			spin_lock(&vma->vm_mm->page_table_lock);
 			vma->vm_end = addr + new_len;
-			vmlist_modify_unlock(vma->vm_mm);
+			spin_unlock(&vma->vm_mm->page_table_lock);
 			current->mm->total_vm += pages;
 			if (vma->vm_flags & VM_LOCKED) {
 				current->mm->locked_vm += pages;
diff -aur linux-240-test10-pre1/mm/swapfile.c linux/mm/swapfile.c
--- linux-240-test10-pre1/mm/swapfile.c	Mon Oct  2 22:31:57 2000
+++ linux/mm/swapfile.c	Fri Oct 13 19:06:08 2000
@@ -315,12 +315,12 @@
 	 */
 	if (!mm)
 		return;
-	vmlist_access_lock(mm);
+	spin_lock(&mm->page_table_lock);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		pgd_t * pgd = pgd_offset(mm, vma->vm_start);
 		unuse_vma(vma, pgd, entry, page);
 	}
-	vmlist_access_unlock(mm);
+	spin_unlock(&mm->page_table_lock);
 	return;
 }
 
--- linux-240-test10-pre1/mm/vmscan.c	Tue Oct 10 19:12:23 2000
+++ linux/mm/vmscan.c	Fri Oct 13 19:49:40 2000
@@ -172,7 +172,7 @@
 		pte_clear(page_table);
 		mm->rss--;
 		flush_tlb_page(vma, address);
-		vmlist_access_unlock(mm);
+		spin_unlock(&mm->page_table_lock);
 		error = swapout(page, file);
 		UnlockPage(page);
 		if (file) fput(file);
@@ -205,7 +205,7 @@
 	mm->rss--;
 	set_pte(page_table, swp_entry_to_pte(entry));
 	flush_tlb_page(vma, address);
-	vmlist_access_unlock(mm);
+	spin_unlock(&mm->page_table_lock);
 
 	/* OK, do a physical asynchronous write to swap.  */
 	rw_swap_page(WRITE, page, 0);
@@ -341,7 +341,7 @@
 	 * Find the proper vm-area after freezing the vma chain 
 	 * and ptes.
 	 */
-	vmlist_access_lock(mm);
+	spin_lock(&mm->page_table_lock);
 	vma = find_vma(mm, address);
 	if (vma) {
 		if (address < vma->vm_start)
@@ -364,7 +364,7 @@
 	mm->swap_cnt = 0;
 
 out_unlock:
-	vmlist_access_unlock(mm);
+	spin_unlock(&mm->page_table_lock);
 
 	/* We didn't find anything for the process */
 	return 0;


-- 
Regards,
        Rasmus(rasmus@jaquet.dk)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
