Date: Sun, 4 Jul 1999 22:15:48 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] fix for OOM deadlock in swap_in (2.2.10) [Re: [test
 program] for OOM situations ]
In-Reply-To: <Pine.LNX.4.10.9907041041100.1352-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.10.9907042030310.521-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@nl.linux.org>, Bernd Kaindl <bk@suse.de>, Linux Kernel <linux-kernel@vger.rutgers.edu>, kernel@suse.de, linux-mm@kvack.org, Alan Cox <alan@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, 4 Jul 1999, Linus Torvalds wrote:

>Ok. I still have your old patch, I'll just flush it so I don't confuse it
>with anything else.

Ok. Excuse me for not specifying it was a new patch.

>However, I still much prefer the 2.3.x approach (ie just returning more
>than just 0/1 - a negative number means out-of-memory). In particular,
>your current approach gets the ptrace() case wrong for the SIGBUS case,
>and it's pretty much impossible to fix cleanly as far as I can tell.

Woops, I see your point, now I changed the patch as you suggested to catch
the ptrace case properly. Now the retval of handle_mm_fault means this:

	 1 ->	page fault resolved succesfully
	 0 ->	we accessed a shared mmap beyond the end of the file.
		So do_page_fault will send a sigbus in this case while
		ptrace won't send the sigbus and will return 0.
	-1 ->	OOM. But we don't need to send a sigkill since the lower
		layer just sent out the sigkill for us.

Here it is a new patch against 2.2.10 (called oom-2.2.10-D). The
differences with the previous are:

o	in ptrace I return 0 if handle_mm_fault isn't been succesfully

o	in mark_page_present I stop if handle_mm_fault gone oom, but I
	don't send the sigbus there.

o	in __verify_write in i386 where we don't have the write protect
	bit I send the sigbus if handle_mm_fault returned 0

This new patch replaces completly the previous one.

Please take a look also at what I am doing in swapin_readahead. I could
also get the information from read_swap_cache_async to know if the swap
entry was empty or if we had not enough memory to do the swapin (and so I
could continue the readahead if it's not an oom condition without harming
the OOM handling), but I think that if there's an hole in the cluster it's
not very important to swapin the other entries. This because even if we
access the cluster in write mode (so then we'll have a chance to take over
the swap cache) we just had one chance to swapin the whole cluster in
readahead mode.

I tested the patch with the sigbus testcase you sent in the previous email
+ with the memory hog I use to check the oom conditions.

Index: linux//arch/i386/kernel/ptrace.c
===================================================================
RCS file: /var/cvs/linux/arch/i386/kernel/ptrace.c,v
retrieving revision 1.1.1.5
diff -u -r1.1.1.5 ptrace.c
--- linux//arch/i386/kernel/ptrace.c	1999/06/14 15:17:43	1.1.1.5
+++ linux//arch/i386/kernel/ptrace.c	1999/07/04 19:12:44
@@ -84,8 +84,9 @@
 repeat:
 	pgdir = pgd_offset(vma->vm_mm, addr);
 	if (pgd_none(*pgdir)) {
-		handle_mm_fault(tsk, vma, addr, 0);
-		goto repeat;
+		if (handle_mm_fault(tsk, vma, addr, 0) == 1)
+			goto repeat;
+		return 0;
 	}
 	if (pgd_bad(*pgdir)) {
 		printk("ptrace: bad page directory %08lx\n", pgd_val(*pgdir));
@@ -94,8 +95,9 @@
 	}
 	pgmiddle = pmd_offset(pgdir, addr);
 	if (pmd_none(*pgmiddle)) {
-		handle_mm_fault(tsk, vma, addr, 0);
-		goto repeat;
+		if (handle_mm_fault(tsk, vma, addr, 0) == 1)
+			goto repeat;
+		return 0;
 	}
 	if (pmd_bad(*pgmiddle)) {
 		printk("ptrace: bad page middle %08lx\n", pmd_val(*pgmiddle));
@@ -104,8 +106,9 @@
 	}
 	pgtable = pte_offset(pgmiddle, addr);
 	if (!pte_present(*pgtable)) {
-		handle_mm_fault(tsk, vma, addr, 0);
-		goto repeat;
+		if (handle_mm_fault(tsk, vma, addr, 0) == 1)
+			goto repeat;
+		return 0;
 	}
 	page = pte_page(*pgtable);
 /* this is a hack for non-kernel-mapped video buffers and similar */
@@ -135,8 +138,9 @@
 repeat:
 	pgdir = pgd_offset(vma->vm_mm, addr);
 	if (!pgd_present(*pgdir)) {
-		handle_mm_fault(tsk, vma, addr, 1);
-		goto repeat;
+		if (handle_mm_fault(tsk, vma, addr, 1) == 1)
+			goto repeat;
+		return;
 	}
 	if (pgd_bad(*pgdir)) {
 		printk("ptrace: bad page directory %08lx\n", pgd_val(*pgdir));
@@ -145,8 +149,9 @@
 	}
 	pgmiddle = pmd_offset(pgdir, addr);
 	if (pmd_none(*pgmiddle)) {
-		handle_mm_fault(tsk, vma, addr, 1);
-		goto repeat;
+		if (handle_mm_fault(tsk, vma, addr, 1) == 1)
+			goto repeat;
+		return;
 	}
 	if (pmd_bad(*pgmiddle)) {
 		printk("ptrace: bad page middle %08lx\n", pmd_val(*pgmiddle));
@@ -155,13 +160,15 @@
 	}
 	pgtable = pte_offset(pgmiddle, addr);
 	if (!pte_present(*pgtable)) {
-		handle_mm_fault(tsk, vma, addr, 1);
-		goto repeat;
+		if (handle_mm_fault(tsk, vma, addr, 1) == 1)
+			goto repeat;
+		return;
 	}
 	page = pte_page(*pgtable);
 	if (!pte_write(*pgtable)) {
-		handle_mm_fault(tsk, vma, addr, 1);
-		goto repeat;
+		if (handle_mm_fault(tsk, vma, addr, 1) == 1)
+			goto repeat;
+		return;
 	}
 /* this is a hack for non-kernel-mapped video buffers and similar */
 	if (MAP_NR(page) < max_mapnr)
Index: linux//arch/i386/mm/fault.c
===================================================================
RCS file: /var/cvs/linux/arch/i386/mm/fault.c,v
retrieving revision 1.1.1.1
diff -u -r1.1.1.1 fault.c
--- linux//arch/i386/mm/fault.c	1999/01/18 01:28:56	1.1.1.1
+++ linux//arch/i386/mm/fault.c	1999/07/04 19:44:18
@@ -31,6 +31,7 @@
 {
 	struct vm_area_struct * vma;
 	unsigned long start = (unsigned long) addr;
+	int fault_retval;
 
 	if (!size)
 		return 1;
@@ -50,7 +51,9 @@
 	start &= PAGE_MASK;
 
 	for (;;) {
-		handle_mm_fault(current,vma, start, 1);
+		fault_retval = handle_mm_fault(current,vma, start, 1);
+		if (fault_retval != 1)
+			goto failed;
 		if (!size)
 			break;
 		size--;
@@ -70,7 +73,11 @@
 		goto bad_area;
 	if (expand_stack(vma, start) == 0)
 		goto good_area;
+	return 0;
 
+failed:
+	if (!fault_retval)
+		force_sig(SIGBUS, current);
 bad_area:
 	return 0;
 }
@@ -96,7 +103,7 @@
 	unsigned long address;
 	unsigned long page;
 	unsigned long fixup;
-	int write;
+	int write, fault_retval;
 
 	/* get the address */
 	__asm__("movl %%cr2,%0":"=r" (address));
@@ -162,8 +169,9 @@
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	if (!handle_mm_fault(tsk, vma, address, write))
-		goto do_sigbus;
+	fault_retval = handle_mm_fault(tsk, vma, address, write);
+	if (fault_retval != 1)
+		goto failed;
 
 	/*
 	 * Did it hit the DOS screen memory VA from vm86 mode?
@@ -255,7 +263,9 @@
  * We ran out of memory, or some other thing happened to us that made
  * us unable to handle the page fault gracefully.
  */
-do_sigbus:
+failed:
+	if (!fault_retval)
+		force_sig(SIGBUS, tsk);
 	up(&mm->mmap_sem);
 
 	/*
@@ -265,7 +275,6 @@
 	tsk->tss.cr2 = address;
 	tsk->tss.error_code = error_code;
 	tsk->tss.trap_no = 14;
-	force_sig(SIGBUS, tsk);
 
 	/* Kernel mode? Handle exceptions or die */
 	if (!(error_code & 4))
Index: linux//include/linux/mm.h
===================================================================
RCS file: /var/cvs/linux/include/linux/mm.h,v
retrieving revision 1.1.1.10
diff -u -r1.1.1.10 mm.h
--- linux//include/linux/mm.h	1999/06/14 15:29:23	1.1.1.10
+++ linux//include/linux/mm.h	1999/07/04 17:28:35
@@ -300,7 +300,7 @@
 extern unsigned long paging_init(unsigned long start_mem, unsigned long end_mem);
 extern void mem_init(unsigned long start_mem, unsigned long end_mem);
 extern void show_mem(void);
-extern void oom(struct task_struct * tsk);
+extern void oom(void);
 extern void si_meminfo(struct sysinfo * val);
 
 /* mmap.c */
Index: linux//include/linux/swap.h
===================================================================
RCS file: /var/cvs/linux/include/linux/swap.h,v
retrieving revision 1.1.1.5
diff -u -r1.1.1.5 swap.h
--- linux//include/linux/swap.h	1999/06/14 15:29:38	1.1.1.5
+++ linux//include/linux/swap.h	1999/07/04 17:28:35
@@ -69,6 +69,7 @@
 extern struct inode swapper_inode;
 extern unsigned long page_cache_size;
 extern int buffermem;
+extern struct wait_queue * kswapd_wait_oom;
 
 /* Incomplete types for prototype declarations: */
 struct task_struct;
@@ -91,8 +92,8 @@
 extern void swap_after_unlock_page (unsigned long entry);
 
 /* linux/mm/page_alloc.c */
-extern void swap_in(struct task_struct *, struct vm_area_struct *,
-		    pte_t *, unsigned long, int);
+extern int swap_in(struct task_struct *, struct vm_area_struct *,
+		   pte_t *, unsigned long, int);
 
 
 /* linux/mm/swap_state.c */
Index: linux//ipc/shm.c
===================================================================
RCS file: /var/cvs/linux/ipc/shm.c,v
retrieving revision 1.1.1.10
diff -u -r1.1.1.10 shm.c
--- linux//ipc/shm.c	1999/06/14 15:30:04	1.1.1.10
+++ linux//ipc/shm.c	1999/07/04 17:28:35
@@ -636,7 +636,7 @@
 	if (!pte_present(pte)) {
 		unsigned long page = get_free_page(GFP_USER);
 		if (!page) {
-			oom(current);
+			oom();
 			return 0;
 		}
 		pte = __pte(shp->shm_pages[idx]);
Index: linux//kernel/printk.c
===================================================================
RCS file: /var/cvs/linux/kernel/printk.c,v
retrieving revision 1.1.1.6
diff -u -r1.1.1.6 printk.c
--- linux//kernel/printk.c	1999/06/14 15:30:05	1.1.1.6
+++ linux//kernel/printk.c	1999/07/04 17:28:35
@@ -147,7 +147,8 @@
 			log_size--;
 			log_start &= LOG_BUF_LEN-1;
 			sti();
-			__put_user(c,buf);
+			if ((error = __put_user(c,buf)) == -EFAULT)
+				goto out;
 			buf++;
 			i++;
 			cli();
@@ -183,7 +184,8 @@
 		__restore_flags(flags);
 		for (i = 0; i < count; i++) {
 			c = *((char *) log_buf+(j++ & (LOG_BUF_LEN-1)));
-			__put_user(c, buf++);
+			if ((error = __put_user(c, buf++)) == -EFAULT)
+				goto out;
 		}
 		if (do_clear)
 			logged_chars = 0;
Index: linux//kernel/signal.c
===================================================================
RCS file: /var/cvs/linux/kernel/signal.c,v
retrieving revision 1.1.1.9
diff -u -r1.1.1.9 signal.c
--- linux//kernel/signal.c	1999/06/14 15:30:06	1.1.1.9
+++ linux//kernel/signal.c	1999/07/04 17:28:35
@@ -409,6 +409,9 @@
 {
 	unsigned long int flags;
 
+	if (t->pid == 1)
+		return 0;
+
 	spin_lock_irqsave(&t->sigmask_lock, flags);
 	if (t->sig == NULL) {
 		spin_unlock_irqrestore(&t->sigmask_lock, flags);
Index: linux//mm/filemap.c
===================================================================
RCS file: /var/cvs/linux/mm/filemap.c,v
retrieving revision 1.1.1.17
diff -u -r1.1.1.17 filemap.c
--- linux//mm/filemap.c	1999/06/14 15:30:07	1.1.1.17
+++ linux//mm/filemap.c	1999/07/04 18:57:48
@@ -958,7 +958,7 @@
 	if (no_share && !new_page) {
 		new_page = page_cache_alloc();
 		if (!new_page)
-			goto failure;
+			goto release_and_oom;
 	}
 
 	if (PageLocked(page))
@@ -1006,7 +1006,7 @@
 	if (!new_page)
 		new_page = page_cache_alloc();
 	if (!new_page)
-		goto no_page;
+		goto oom;
 
 	/*
 	 * During getting the above page we might have slept,
@@ -1060,6 +1060,12 @@
 		page_cache_free(new_page);
 no_page:
 	return 0;
+
+release_and_oom:
+	page_cache_release(page);
+oom:
+	oom();
+	return -1;
 }
 
 /*
Index: linux//mm/memory.c
===================================================================
RCS file: /var/cvs/linux/mm/memory.c,v
retrieving revision 1.1.1.8
diff -u -r1.1.1.8 memory.c
--- linux//mm/memory.c	1999/06/14 15:30:07	1.1.1.8
+++ linux//mm/memory.c	1999/07/04 20:00:10
@@ -65,10 +65,23 @@
  * oom() prints a message (so that the user knows why the process died),
  * and gives the process an untrappable SIGKILL.
  */
-void oom(struct task_struct * task)
+void oom(void)
 {
-	printk("\nOut of memory for %s.\n", task->comm);
-	force_sig(SIGKILL, task);
+	if (current->pid == 1)
+		return;
+
+	/*
+	 * Make sure the killed task will be scheduled ASAP. Otherwise
+	 * we risk to reschedule another task before running the signal
+	 * hander.
+	 */
+	current->policy = SCHED_FIFO;
+	current->rt_priority = 1000000;
+
+	printk("\nOut of memory for %s.\n", current->comm);
+	force_sig(SIGKILL, current);
+
+	wake_up_interruptible(&kswapd_wait_oom);
 }
 
 /*
@@ -545,19 +558,6 @@
 }
 
 /*
- * sanity-check function..
- */
-static void put_page(pte_t * page_table, pte_t pte)
-{
-	if (!pte_none(*page_table)) {
-		free_page_and_swap_cache(pte_page(pte));
-		return;
-	}
-/* no need for flush_tlb */
-	set_pte(page_table, pte);
-}
-
-/*
  * This routine is used to map in a page into an address space: needed by
  * execve() for the initial stack and environment pages.
  */
@@ -575,13 +575,13 @@
 	pmd = pmd_alloc(pgd, address);
 	if (!pmd) {
 		free_page(page);
-		oom(tsk);
+		oom();
 		return 0;
 	}
 	pte = pte_alloc(pmd, address);
 	if (!pte) {
 		free_page(page);
-		oom(tsk);
+		oom();
 		return 0;
 	}
 	if (!pte_none(*pte)) {
@@ -614,21 +614,15 @@
  * and potentially makes it more efficient.
  */
 static int do_wp_page(struct task_struct * tsk, struct vm_area_struct * vma,
-	unsigned long address, pte_t *page_table)
+	unsigned long address, pte_t *page_table, pte_t pte)
 {
-	pte_t pte;
 	unsigned long old_page, new_page;
 	struct page * page_map;
 	
-	pte = *page_table;
 	new_page = __get_free_page(GFP_USER);
 	/* Did swap_out() unmapped the protected page while we slept? */
 	if (pte_val(*page_table) != pte_val(pte))
 		goto end_wp_page;
-	if (!pte_present(pte))
-		goto end_wp_page;
-	if (pte_write(pte))
-		goto end_wp_page;
 	old_page = pte_page(pte);
 	if (MAP_NR(old_page) >= max_mapnr)
 		goto bad_wp_page;
@@ -684,13 +678,16 @@
 	return 1;
 
 bad_wp_page:
+	unlock_kernel();
 	printk("do_wp_page: bogus page at address %08lx (%08lx)\n",address,old_page);
 	send_sig(SIGKILL, tsk, 1);
-no_new_page:
-	unlock_kernel();
 	if (new_page)
 		free_page(new_page);
 	return 0;
+no_new_page:
+	unlock_kernel();
+	oom();
+	return -1;
 }
 
 /*
@@ -787,8 +784,9 @@
 	struct vm_area_struct * vma, unsigned long address,
 	pte_t * page_table, pte_t entry, int write_access)
 {
+	int ret = 1;
 	if (!vma->vm_ops || !vma->vm_ops->swapin) {
-		swap_in(tsk, vma, page_table, pte_val(entry), write_access);
+		ret = swap_in(tsk, vma, page_table, pte_val(entry), write_access);
 		flush_page_to_ram(pte_page(*page_table));
 	} else {
 		pte_t page = vma->vm_ops->swapin(vma, address - vma->vm_start + vma->vm_offset, pte_val(entry));
@@ -805,7 +803,7 @@
 		}
 	}
 	unlock_kernel();
-	return 1;
+	return ret;
 }
 
 /*
@@ -817,15 +815,18 @@
 	if (write_access) {
 		unsigned long page = __get_free_page(GFP_USER);
 		if (!page)
-			return 0;
+			goto oom;
 		clear_page(page);
 		entry = pte_mkwrite(pte_mkdirty(mk_pte(page, vma->vm_page_prot)));
 		vma->vm_mm->rss++;
 		tsk->min_flt++;
 		flush_page_to_ram(page);
 	}
-	put_page(page_table, entry);
+	set_pte(page_table, entry);
 	return 1;
+ oom:
+	oom();
+	return -1;
 }
 
 /*
@@ -882,7 +883,7 @@
 	} else if (atomic_read(&mem_map[MAP_NR(page)].count) > 1 &&
 		   !(vma->vm_flags & VM_SHARED))
 		entry = pte_wrprotect(entry);
-	put_page(page_table, entry);
+	set_pte(page_table, entry);
 	/* no need to invalidate: a not-present page shouldn't be cached */
 	return 1;
 }
@@ -916,7 +917,7 @@
 	flush_tlb_page(vma, address);
 	if (write_access) {
 		if (!pte_write(entry))
-			return do_wp_page(tsk, vma, address, pte);
+			return do_wp_page(tsk, vma, address, pte, entry);
 
 		entry = pte_mkdirty(entry);
 		set_pte(pte, entry);
@@ -934,19 +935,24 @@
 {
 	pgd_t *pgd;
 	pmd_t *pmd;
+	pte_t * pte;
+	int ret;
 
 	pgd = pgd_offset(vma->vm_mm, address);
 	pmd = pmd_alloc(pgd, address);
-	if (pmd) {
-		pte_t * pte = pte_alloc(pmd, address);
-		if (pte) {
-			if (handle_pte_fault(tsk, vma, address, write_access, pte)) {
-				update_mmu_cache(vma, address, *pte);
-				return 1;
-			}
-		}
-	}
-	return 0;
+	if (!pmd)
+		goto oom;
+	pte = pte_alloc(pmd, address);
+	if (!pte)
+		goto oom;
+	ret = handle_pte_fault(tsk, vma, address, write_access, pte);
+	if (ret == 1)
+		update_mmu_cache(vma, address, *pte);
+	return ret;
+
+ oom:
+	oom();
+	return -1;
 }
 
 /*
@@ -960,7 +966,8 @@
 	vma = find_vma(current->mm, addr);
 	write = (vma->vm_flags & VM_WRITE) != 0;
 	while (addr < end) {
-		handle_mm_fault(current, vma, addr, write);
+		if (handle_mm_fault(current, vma, addr, write) == -1)
+			break;
 		addr += PAGE_SIZE;
 	}
 }
Index: linux//mm/page_alloc.c
===================================================================
RCS file: /var/cvs/linux/mm/page_alloc.c,v
retrieving revision 1.1.1.10
diff -u -r1.1.1.10 page_alloc.c
--- linux//mm/page_alloc.c	1999/06/14 15:30:08	1.1.1.10
+++ linux//mm/page_alloc.c	1999/07/04 18:52:14
@@ -373,8 +373,13 @@
 
 		/* Ok, do the async read-ahead now */
 		new_page = read_swap_cache_async(SWP_ENTRY(SWP_TYPE(entry), offset), 0);
-		if (new_page != NULL)
-			__free_page(new_page);
+		/*
+		 * If we are OOM or if this isn't a contiguous swap cluster
+		 * stop the readahead.
+		 */
+		if (!new_page)
+			return;
+		__free_page(new_page);
 		offset++;
 	} while (--i);
 	return;
@@ -387,7 +392,7 @@
  * Also, don't bother to add to the swap cache if this page-in
  * was due to a write access.
  */
-void swap_in(struct task_struct * tsk, struct vm_area_struct * vma,
+int swap_in(struct task_struct * tsk, struct vm_area_struct * vma,
 	pte_t * page_table, unsigned long entry, int write_access)
 {
 	unsigned long page;
@@ -400,13 +405,11 @@
 	if (pte_val(*page_table) != entry) {
 		if (page_map)
 			free_page_and_swap_cache(page_address(page_map));
-		return;
+		return 1;
 	}
 	if (!page_map) {
-		set_pte(page_table, BAD_PAGE);
-		swap_free(entry);
-		oom(tsk);
-		return;
+		oom();
+		return -1;
 	}
 
 	page = page_address(page_map);
@@ -416,7 +419,7 @@
 
 	if (!write_access || is_page_shared(page_map)) {
 		set_pte(page_table, mk_pte(page, vma->vm_page_prot));
-		return;
+		return 1;
 	}
 
 	/*
@@ -426,5 +429,5 @@
 	 */
 	delete_from_swap_cache(page_map);
 	set_pte(page_table, pte_mkwrite(pte_mkdirty(mk_pte(page, vma->vm_page_prot))));
-  	return;
+  	return 1;
 }
Index: linux//mm/swapfile.c
===================================================================
RCS file: /var/cvs/linux/mm/swapfile.c,v
retrieving revision 1.1.1.8
diff -u -r1.1.1.8 swapfile.c
--- linux//mm/swapfile.c	1999/06/14 15:30:09	1.1.1.8
+++ linux//mm/swapfile.c	1999/07/04 17:28:35
@@ -131,15 +131,17 @@
 	offset = SWP_OFFSET(entry);
 	if (offset >= p->max)
 		goto bad_offset;
-	if (offset < p->lowest_bit)
-		p->lowest_bit = offset;
-	if (offset > p->highest_bit)
-		p->highest_bit = offset;
 	if (!p->swap_map[offset])
 		goto bad_free;
 	if (p->swap_map[offset] < SWAP_MAP_MAX) {
 		if (!--p->swap_map[offset])
+		{
+			if (offset < p->lowest_bit)
+				p->lowest_bit = offset;
+			if (offset > p->highest_bit)
+				p->highest_bit = offset;
 			nr_swap_pages++;
+		}
 	}
 #ifdef DEBUG_SWAP
 	printk("DebugVM: swap_free(entry %08lx, count now %d)\n",
Index: linux//mm/vmscan.c
===================================================================
RCS file: /var/cvs/linux/mm/vmscan.c,v
retrieving revision 1.1.1.8
diff -u -r1.1.1.8 vmscan.c
--- linux//mm/vmscan.c	1999/06/14 15:30:09	1.1.1.8
+++ linux//mm/vmscan.c	1999/07/04 17:28:35
@@ -308,7 +308,8 @@
 static int swap_out(unsigned int priority, int gfp_mask)
 {
 	struct task_struct * p, * pbest;
-	int counter, assign, max_cnt;
+	int assign = 0, counter;
+	unsigned long max_cnt;
 
 	/* 
 	 * We make one or two passes through the task list, indexed by 
@@ -327,11 +328,8 @@
 	counter = nr_tasks / (priority+1);
 	if (counter < 1)
 		counter = 1;
-	if (counter > nr_tasks)
-		counter = nr_tasks;
 
 	for (; counter >= 0; counter--) {
-		assign = 0;
 		max_cnt = 0;
 		pbest = NULL;
 	select:
@@ -343,7 +341,7 @@
 	 		if (p->mm->rss <= 0)
 				continue;
 			/* Refresh swap_cnt? */
-			if (assign)
+			if (assign == 1)
 				p->mm->swap_cnt = p->mm->rss;
 			if (p->mm->swap_cnt > max_cnt) {
 				max_cnt = p->mm->swap_cnt;
@@ -351,6 +349,8 @@
 			}
 		}
 		read_unlock(&tasklist_lock);
+		if (assign == 1)
+			assign = 2;
 		if (!pbest) {
 			if (!assign) {
 				assign = 1;
@@ -435,7 +435,8 @@
        printk ("Starting kswapd v%.*s\n", i, s);
 }
 
-static struct task_struct *kswapd_process;
+static struct wait_queue * kswapd_wait = NULL;
+struct wait_queue * kswapd_wait_oom = NULL;
 
 /*
  * The background pageout daemon, started as a kernel thread
@@ -455,7 +456,6 @@
 {
 	struct task_struct *tsk = current;
 
-	kswapd_process = tsk;
 	tsk->session = 1;
 	tsk->pgrp = 1;
 	strcpy(tsk->comm, "kswapd");
@@ -484,16 +484,17 @@
 		 * the processes needing more memory will wake us
 		 * up on a more timely basis.
 		 */
-		do {
-			if (nr_free_pages >= freepages.high)
-				break;
-
-			if (!do_try_to_free_pages(GFP_KSWAPD))
-				break;
-		} while (!tsk->need_resched);
-		run_task_queue(&tq_disk);
-		tsk->state = TASK_INTERRUPTIBLE;
-		schedule_timeout(HZ);
+		interruptible_sleep_on_timeout(&kswapd_wait, HZ);
+		while (nr_free_pages < freepages.high)
+		{
+			if (do_try_to_free_pages(GFP_KSWAPD))
+			{
+				if (tsk->need_resched)
+					schedule();
+				continue;
+			}
+			interruptible_sleep_on_timeout(&kswapd_wait_oom,10*HZ);
+		}
 	}
 }
 
@@ -516,7 +517,7 @@
 {
 	int retval = 1;
 
-	wake_up_process(kswapd_process);
+	wake_up_interruptible(&kswapd_wait);
 	if (gfp_mask & __GFP_WAIT)
 		retval = do_try_to_free_pages(gfp_mask);
 	return retval;


Note: the most important part of the patch is still the swapin
deadlock-fix. Previously swap_in was always returning 1 even if it gone
OOM, so if the swapin happened in a copy-user call we could deadlock
completly (easily reproducible generating some syslog entries while going
oom).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
