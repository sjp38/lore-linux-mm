Received: from mail.ccr.net (ccr@alogconduit1af.ccr.net [208.130.159.6])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA19415
	for <linux-mm@kvack.org>; Sun, 17 Jan 1999 01:44:21 -0500
Subject: Beta quality write out daemon
References: <m1g19ep3p9.fsf@flinx.ccr.net> <m1iue96lhl.fsf@flinx.ccr.net> <34BD0786.93EEC074@xinit.se> <m1zp7kdi40.fsf@flinx.ccr.net>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 17 Jan 1999 00:12:25 -0600
In-Reply-To: ebiederm+eric@ccr.net's message of "15 Jan 1999 03:02:07 -0600"
Message-ID: <m1k8ym4ed2.fsf_-_@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Hans Eric Sandstrom <hes@xinit.se>
List-ID: <linux-mm.kvack.org>

O.k. For all who want to play with it here is my write out daemon.
It currently appears to be stable but untuned.

In particular I probably need a:
wait_for_any_page(unsigned long timeout);
primitive.

Currently a really fast memory allocator temporarly halts all processes that
request memory because it can't get any memory, and it doesn't really stall waiting
on I/O.  It just spins trying to get memory until it's spinning fails.
The memory allocation failure rate is also a little high.

I also seem to have detected a bug in some other part of the kernel.
Where I can find a dirty pte pointing to a swap cache page.

I'm going to attempt to reproduce this on a clean pre7 with added detection logic,
and I should have a small detection patch, against vanilla pre7 shortly.

We currently don't notice this case because we assume if a page is in the swap cache
it must be clean.

Eric

diff -uNrX linux-ignore-files linux-2.2.0-pre5.eb1.1/include/linux/mm.h linux-2.2.0-pre5.eb1.2/include/linux/mm.h
--- linux-2.2.0-pre5.eb1.1/include/linux/mm.h	Thu Jan  7 00:25:38 1999
+++ linux-2.2.0-pre5.eb1.2/include/linux/mm.h	Wed Jan 13 08:53:22 1999
@@ -100,6 +100,7 @@
 		unsigned long page);
 	int (*swapout)(struct vm_area_struct *,  unsigned long, pte_t *);
 	pte_t (*swapin)(struct vm_area_struct *, unsigned long, unsigned long);
+	int (*writeout)(struct vm_area_struct *, unsigned long offset, unsigned long page);
 };
 
 /*
@@ -392,6 +393,8 @@
 				buffer_mem.min_percent * num_physpages)
 #define pgcache_under_min()	(page_cache_size * 100 < \
 				page_cache.min_percent * num_physpages)
+
+extern void wakeup_pgflush(void);
 
 #endif /* __KERNEL__ */
 
diff -uNrX linux-ignore-files linux-2.2.0-pre5.eb1.1/include/linux/sched.h linux-2.2.0-pre5.eb1.2/include/linux/sched.h
--- linux-2.2.0-pre5.eb1.1/include/linux/sched.h	Wed Jan  6 22:51:44 1999
+++ linux-2.2.0-pre5.eb1.2/include/linux/sched.h	Wed Jan 13 08:53:16 1999
@@ -168,6 +168,9 @@
 	unsigned long rss, total_vm, locked_vm;
 	unsigned long def_flags;
 	unsigned long cpu_vm_mask;
+	unsigned long swap_write_pass;
+	unsigned long swap_address;
+	unsigned long swap_cnt;		/* number of pages to swap on next pass */
 	/*
 	 * This is an architecture-specific pointer: the portable
 	 * part of Linux does not know about any segments.
@@ -184,7 +187,9 @@
 		0, 0, 0, 				\
 		0, 0, 0, 0,				\
 		0, 0, 0,				\
-		0, 0, NULL }
+		0, 0, 					\
+		0, 0, 0,				\
+	        NULL }
 
 struct signal_struct {
 	atomic_t		count;
@@ -269,10 +274,8 @@
 	unsigned long min_flt, maj_flt, nswap, cmin_flt, cmaj_flt, cnswap;
 	int swappable:1;
 	int trashing_memory:1;
-	unsigned long swap_address;
 	unsigned long old_maj_flt;	/* old value of maj_flt */
 	unsigned long dec_flt;		/* page fault count of the last time */
-	unsigned long swap_cnt;		/* number of pages to swap on next pass */
 /* process credentials */
 	uid_t uid,euid,suid,fsuid;
 	gid_t gid,egid,sgid,fsgid;
@@ -354,7 +357,7 @@
 /* utime */	{0,0,0,0},0, \
 /* per CPU times */ {0, }, {0, }, \
 /* flt */	0,0,0,0,0,0, \
-/* swp */	0,0,0,0,0,0, \
+/* swp */	0,0,0,0, \
 /* process credentials */					\
 /* uid etc */	0,0,0,0,0,0,0,0,				\
 /* suppl grps*/ 0, {0,},					\
diff -uNrX linux-ignore-files linux-2.2.0-pre5.eb1.1/init/main.c linux-2.2.0-pre5.eb1.2/init/main.c
--- linux-2.2.0-pre5.eb1.1/init/main.c	Wed Jan  6 22:46:42 1999
+++ linux-2.2.0-pre5.eb1.2/init/main.c	Mon Jan 11 19:13:57 1999
@@ -65,6 +65,8 @@
 extern int bdflush(void *);
 extern int kswapd(void *);
 extern void kswapd_setup(void);
+extern int pgflush(void *);
+extern void pgflush_init(void);
 
 extern void init_IRQ(void);
 extern void init_modules(void);
@@ -1272,6 +1274,10 @@
 	/* Start the background pageout daemon. */
 	kswapd_setup();
 	kernel_thread(kswapd, NULL, CLONE_FS | CLONE_FILES | CLONE_SIGHAND);
+	/* Start the backgroud writeout daemon. */
+	pgflush_init();
+	kernel_thread(pgflush, NULL, CLONE_FS | CLONE_FILES | CLONE_SIGHAND);
+ 
 
 #if CONFIG_AP1000
 	/* Start the async paging daemon. */
diff -uNrX linux-ignore-files linux-2.2.0-pre5.eb1.1/mm/Makefile linux-2.2.0-pre5.eb1.2/mm/Makefile
--- linux-2.2.0-pre5.eb1.1/mm/Makefile	Tue May 12 14:17:54 1998
+++ linux-2.2.0-pre5.eb1.2/mm/Makefile	Mon Jan 11 22:09:47 1999
@@ -9,7 +9,7 @@
 
 O_TARGET := mm.o
 O_OBJS	 := memory.o mmap.o filemap.o mprotect.o mlock.o mremap.o \
-	    vmalloc.o slab.o \
+	    vmalloc.o slab.o vmclean.o \
 	    swap.o vmscan.o page_io.o page_alloc.o swap_state.o swapfile.o
 
 include $(TOPDIR)/Rules.make
diff -uNrX linux-ignore-files linux-2.2.0-pre5.eb1.1/mm/filemap.c linux-2.2.0-pre5.eb1.2/mm/filemap.c
--- linux-2.2.0-pre5.eb1.1/mm/filemap.c	Mon Jan 11 23:19:16 1999
+++ linux-2.2.0-pre5.eb1.2/mm/filemap.c	Fri Jan 15 00:41:40 1999
@@ -1115,58 +1115,14 @@
 	 */
 	file->f_count++;
 	down(&inode->i_sem);
+	atomic_inc(&page_map->count);
 	result = do_write_page(inode, file, (const char *) page, offset);
+	__free_page(page_map);
 	up(&inode->i_sem);
 	fput(file);
 	return result;
 }
 
-
-/*
- * Swapping to a shared file: while we're busy writing out the page
- * (and the page still exists in memory), we save the page information
- * in the page table, so that "filemap_swapin()" can re-use the page
- * immediately if it is called while we're busy swapping it out..
- *
- * Once we've written it all out, we mark the page entry "empty", which
- * will result in a normal page-in (instead of a swap-in) from the now
- * up-to-date disk file.
- */
-int filemap_swapout(struct vm_area_struct * vma,
-	unsigned long offset,
-	pte_t *page_table)
-{
-	int error;
-	unsigned long page = pte_page(*page_table);
-	unsigned long entry = SWP_ENTRY(SHM_SWP_TYPE, MAP_NR(page));
-
-	flush_cache_page(vma, (offset + vma->vm_start - vma->vm_offset));
-	set_pte(page_table, __pte(entry));
-	flush_tlb_page(vma, (offset + vma->vm_start - vma->vm_offset));
-	error = filemap_write_page(vma, offset, page);
-	if (pte_val(*page_table) == entry)
-		pte_clear(page_table);
-	return error;
-}
-
-/*
- * filemap_swapin() is called only if we have something in the page
- * tables that is non-zero (but not present), which we know to be the
- * page index of a page that is busy being swapped out (see above).
- * So we just use it directly..
- */
-static pte_t filemap_swapin(struct vm_area_struct * vma,
-	unsigned long offset,
-	unsigned long entry)
-{
-	unsigned long page = SWP_OFFSET(entry);
-
-	atomic_inc(&mem_map[page].count);
-	page = (page << PAGE_SHIFT) + PAGE_OFFSET;
-	return mk_pte(page,vma->vm_page_prot);
-}
-
-
 static inline int filemap_sync_pte(pte_t * ptep, struct vm_area_struct *vma,
 	unsigned long address, unsigned int flags)
 {
@@ -1306,8 +1262,9 @@
 	NULL,			/* advise */
 	filemap_nopage,		/* nopage */
 	NULL,			/* wppage */
-	filemap_swapout,	/* swapout */
-	filemap_swapin,		/* swapin */
+	NULL,			/* swapout */
+	NULL,			/* swapin */
+	filemap_write_page,	/* writeout */
 };
 
 /*
diff -uNrX linux-ignore-files linux-2.2.0-pre5.eb1.1/mm/page_io.c linux-2.2.0-pre5.eb1.2/mm/page_io.c
--- linux-2.2.0-pre5.eb1.1/mm/page_io.c	Wed Jan  6 22:46:43 1999
+++ linux-2.2.0-pre5.eb1.2/mm/page_io.c	Thu Jan 14 11:02:41 1999
@@ -18,6 +18,10 @@
 
 #include <asm/pgtable.h>
 
+#ifdef DEBUG_SWAP
+#include <linux/pagemap.h>
+#endif
+
 static struct wait_queue * lock_queue = NULL;
 
 /*
@@ -197,7 +201,7 @@
 #ifdef DEBUG_SWAP
 	printk ("DebugVM: %s_swap_page finished on page %p (count %d)\n",
 		(rw == READ) ? "read" : "write", 
-		(char *) page_adddress(page), 
+		(char *) page_address(page), 
 		atomic_read(&page->count));
 #endif
 }
diff -uNrX linux-ignore-files linux-2.2.0-pre5.eb1.1/mm/vmclean.c linux-2.2.0-pre5.eb1.2/mm/vmclean.c
--- linux-2.2.0-pre5.eb1.1/mm/vmclean.c	Wed Dec 31 18:00:00 1969
+++ linux-2.2.0-pre5.eb1.2/mm/vmclean.c	Sat Jan 16 23:24:10 1999
@@ -0,0 +1,415 @@
+/*
+ *  linux/mm/vmclean.c
+ *
+ *  Copyright (C) 1999 Eric Biederman
+ *
+ */
+
+#include <linux/slab.h>
+#include <linux/kernel_stat.h>
+#include <linux/swap.h>
+#include <linux/swapctl.h>
+#include <linux/smp_lock.h>
+#include <linux/pagemap.h>
+#include <linux/init.h>
+
+#include <asm/pgtable.h>
+
+/*
+ * The vm-clean  functions return 1 if they successfully
+ * cleaned something. It returns zero if it couldn't do anything, and
+ * any other value indicates it decreased rss, but the page was shared.
+ *
+ * NOTE! If it sleeps, it *must* return 1 to make sure we
+ * don't continue with the clean. Otherwise we may be
+ * using a process that no longer actually exists (it might
+ * have died while we slept).
+ */
+static int try_to_clean(struct vm_area_struct* vma, unsigned long address, pte_t * page_table)
+{
+	pte_t pte;
+	unsigned long entry;
+	unsigned long page;
+	struct page * page_map;
+	int result = 0;
+
+	pte = *page_table;
+	if (!pte_present(pte))
+		return result;
+	page = pte_page(pte);
+	if (MAP_NR(page) >= max_mapnr)
+		return result;
+
+	page_map = mem_map + MAP_NR(page);
+	if ((PageReserved(page_map))
+	    || PageLocked(page_map))
+		return result;
+
+	if (!pte_dirty(pte)) {
+		goto out;
+	}
+	flush_cache_page(vma, address);
+
+	if (vma->vm_ops && vma->vm_ops->writeout) {
+		set_pte(page_table, pte_mkclean(pte));
+		if (vma->vm_ops->writeout(vma, address - vma->vm_start + vma->vm_offset, page)) {
+			struct task_struct *tsk;
+			/* Find some appropriate process to tell,
+			 * anyone with the same mm_struct is fine
+			 */
+			read_lock(&tasklist_lock);
+			for_each_task(tsk) {
+				if (!tsk->swappable)
+					continue;
+				if (tsk->mm == vma->vm_mm) {
+					kill_proc(tsk->pid, SIGBUS, 1);
+					break;
+				}
+			}
+			read_unlock(&tasklist_lock);
+			result = 0;
+		} else {
+			result = 1;
+		}
+		goto out;
+	}
+	if (PageSwapCache(page_map)) {
+		printk(KERN_ERR "vm_clean: dirty page %08lx in swap cache?\n",
+		       page_address(page_map));
+		goto out;
+		       
+	}
+	/*
+	 * This is a dirty, swappable page.  First of all,
+	 * get a suitable swap entry for it, and make sure
+	 * we have the swap cache set up to associate the
+	 * page with that swap entry.
+	 */
+	entry = get_swap_page();
+	if (!entry)
+		goto out; /* No swap space left */
+
+	/* We checked we were unlocked way up above, and we
+	   have been careful not to stall until here */
+	set_bit(PG_locked, &page_map->flags);
+
+	/* get an extra reference in case we rw_swap_page does an unasked for
+	 * synchronous write
+	 */
+	atomic_inc(&page_map->count);
+
+	if (!add_to_swap_cache(page_map, entry)) {
+		printk(KERN_ERR "vm_clean: can't add page %08lx to swap_cache!\n",
+		       page_address(page_map));
+		swap_free(entry);
+		clear_bit(PG_locked, &page_map->flags);
+		wake_up(&page_map->wait);
+		__free_page(page_map);
+		goto out;
+	}
+
+	/* Note:  We make the page read only here to maintain the invariant
+	 * that swap cache pages are always read only.
+	 * Once we have PG_dirty or a similar mechanism implemented we
+	 * can relax this.
+	 *
+	 * We still need to be sure and clear the dirty bit before any I/O
+	 * occurs however.
+	 */
+	set_pte(page_table, pte_wrprotect(pte_mkclean(pte)));
+
+	/* OK, do a physical asynchronous write to swap.  */
+	rw_swap_page(WRITE, entry, (char *) page, 0);
+
+	__free_page(page_map);
+
+	result = 1; /* Could we have slept? Play it safe */
+
+out:
+	return result;
+}
+
+/*
+ * A new implementation of swap_out().  We do not swap complete processes,
+ * but only a small number of blocks, before we continue with the next
+ * process.  The number of blocks actually swapped is determined on the
+ * number of page faults, that this process actually had in the last time,
+ * so we won't swap heavily used processes all the time ...
+ *
+ * Note: the priority argument is a hint on much CPU to waste with the
+ *       swap block search, not a hint, of how much blocks to swap with
+ *       each process.
+ *
+ * (C) 1993 Kai Petzke, wpp@marie.physik.tu-berlin.de
+ */
+
+static inline int clean_pmd(struct vm_area_struct * vma,
+	pmd_t *dir, unsigned long address, unsigned long end,
+	unsigned long *paddress)
+{
+	pte_t * pte;
+	unsigned long pmd_end;
+
+	if (pmd_none(*dir))
+		return 0;
+	if (pmd_bad(*dir)) {
+		printk("clean_pmd: bad pmd (%08lx)\n", pmd_val(*dir));
+		pmd_clear(dir);
+		return 0;
+	}
+	
+	pte = pte_offset(dir, address);
+	
+	pmd_end = (address + PMD_SIZE) & PMD_MASK;
+	if (end > pmd_end)
+		end = pmd_end;
+
+	do {
+		int result;
+		*paddress = address + PAGE_SIZE;
+		result = try_to_clean(vma, address, pte);
+		if (result)
+			return result;
+		address += PAGE_SIZE;
+		pte++;
+	} while (address < end);
+	return 0;
+}
+
+static inline int clean_pgd(struct vm_area_struct * vma,
+	pgd_t *dir, unsigned long address, unsigned long end, unsigned long *paddress)
+{
+	pmd_t * pmd;
+	unsigned long pgd_end;
+
+	if (pgd_none(*dir))
+		return 0;
+	if (pgd_bad(*dir)) {
+		printk("clean_pgd: bad pgd (%08lx)\n", pgd_val(*dir));
+		pgd_clear(dir);
+		return 0;
+	}
+
+	pmd = pmd_offset(dir, address);
+
+	pgd_end = (address + PGDIR_SIZE) & PGDIR_MASK;	
+	if (end > pgd_end)
+		end = pgd_end;
+	
+	do {
+		int result;
+		result = clean_pmd(vma, pmd, address, end, paddress);
+		if (result)
+			return result;
+		address = (address + PMD_SIZE) & PMD_MASK;
+		pmd++;
+	} while (address < end);
+	return 0;
+}
+
+static int clean_vma(struct vm_area_struct *vma, 
+		     unsigned long address, unsigned long *paddress)
+{
+	pgd_t *pgdir;
+	unsigned long end;
+
+	/* Don't write out areas like shared memory which have their
+	 * own separate swapping mechanism
+	 */
+	if (vma->vm_flags & VM_SHM)  {
+		return 0;
+	}
+
+	/* Don't write out locked anonymous memory */
+	if (vma->vm_flags & VM_LOCKED && 
+	    (!vma->vm_ops || !vma->vm_ops->writeout)) {
+		return 0;
+	}
+
+	pgdir = pgd_offset(vma->vm_mm, address);
+
+	end = vma->vm_end;
+	while (address < end) {
+		int result;
+		result = clean_pgd(vma, pgdir, address, end, paddress);
+		if (result)
+			return result;
+		address = (address + PGDIR_SIZE) & PGDIR_MASK;
+		pgdir++;
+	}
+	return 0;
+}
+
+static int clean_mm(struct mm_struct *mm, unsigned long *paddress)
+{
+	struct vm_area_struct *vma;
+	unsigned long address = *paddress;
+
+	vma = find_vma(mm, address);
+	if (vma) {
+		if (address < vma->vm_start) {
+			address = vma->vm_start;
+		}
+		for(;atomic_read(&mm->count) > 1;) {
+			int result = clean_vma(vma, address, paddress);
+			if (result) 
+				return result;
+			vma = vma->vm_next;
+			if (!vma)
+				break;
+			address = vma->vm_start;
+		}
+	}
+	/* We didn't write anything out */
+	return -1;	
+}
+
+/*
+ * Select the task with maximal swap_cnt and try to swap out a page.
+ * N.B. This function returns only 0 or 1.  Return values != 1 from
+ * the lower level routines result in continued processing.
+ */
+static void clean_tsks(void)
+{
+	/* Use write pass so I don't write out the same mm more than once */
+	static unsigned long write_pass = 0;
+
+	for(;;) {	
+		struct mm_struct *mm;
+		int result;
+		unsigned long address;
+		struct task_struct *tsk;
+		mm = NULL;
+
+		read_lock(&tasklist_lock);
+		for_each_task(tsk) {
+			if (!tsk->swappable)  /* the task is being set up */
+				continue;
+			if (tsk->mm->rss == 0) {
+				tsk->mm->swap_write_pass = write_pass; /* bad? */
+				continue;
+			}
+			if (tsk->mm->swap_write_pass == write_pass) 
+				continue;
+			/* don't let the mm struct go away unexpectedly */
+			mm = tsk->mm;
+			mmget(mm);
+			break;
+		}
+		read_unlock(&tasklist_lock);
+		if (!mm) 
+			break;
+		lock_kernel();
+		address = 0;
+#if 0
+		printk(KERN_DEBUG "clean_mm(%ld) starting for %p\n", write_pass, mm);
+#endif
+		do {
+			result = clean_mm(mm, &address);
+			if (result) {
+#if 0
+				printk(KERN_DEBUG "clean_mm:%ld found a page\n", write_pass);
+#endif
+			}
+			if (atomic_read(&nr_async_pages) >= pager_daemon.swap_cluster) {
+				run_task_queue(&tq_disk);
+			}
+			if (current->need_resched) 
+				schedule();
+		} while((result > 0) && (atomic_read(&mm->count) > 1));
+		mm->swap_write_pass = write_pass;
+#if 0
+		printk(KERN_DEBUG "clean_mm:%ld done\n", write_pass);
+#endif
+		mmput(mm);
+		unlock_kernel();
+	}
+		
+	write_pass = (write_pass != 0)?0:1;
+}
+
+/* ====================== pgflush support =================== */
+
+/* This is a simple kernel daemon, whose job it is to write all dirty pages
+ * in memory.
+ */
+#if 1
+unsigned long pgflush_wait = 30*HZ;
+#else
+unsigned long pgflush_wait = HZ/5;
+#endif
+struct task_struct *pgflush_tsk = 0;
+
+void wakeup_pgflush(void)
+{
+	if (!pgflush_tsk)
+		return;
+	if (current == pgflush_tsk)
+		return;
+	wake_up_process(pgflush_tsk);
+}
+
+/*
+ * Before we start the kernel thread, print out the
+ * pgflushd initialization message (otherwise the init message
+ * may be printed in the middle of another driver's init
+ * message).  It looks very bad when that happens.
+ */
+__initfunc(void pgflush_init(void))
+{
+       printk ("Starting kpgflushd\n");
+}
+
+/* This is the actual pgflush daemon itself. 
+ * We launch it ourselves internally with
+ * kernel_thread(...)  directly after the first thread in init/main.c 
+ */
+
+int pgflush(void *unsused)
+{
+	/*
+	 *	We have a bare-bones task_struct, and really should fill
+	 *	in a few more things so "top" and /proc/2/{exe,root,cwd}
+	 *	display semi-sane things. Not real crucial though...  
+	 */
+
+	current->session = 1;
+	current->pgrp = 1;
+	sprintf(current->comm, "kpgflushd");
+	pgflush_tsk = current;
+
+	/*
+	 * Tell the memory management that we're a "memory allocator",
+	 * and that if we need more memory we should get access to it
+	 * regardless (see "__get_free_pages()"). "kswapd" should
+	 * never get caught in the normal page freeing logic.
+	 *
+	 * (Kswapd normally doesn't need memory anyway, but sometimes
+	 * you need a small amount of memory in order to be able to
+	 * page out something else, and this flag essentially protects
+	 * us from recursively trying to free more memory as we're
+	 * trying to free the first piece of memory in the first place).
+	 */
+	for(;;) {
+		unsigned long left;
+		current->state = TASK_INTERRUPTIBLE;
+
+		if (signal_pending(current)) {
+			spin_lock_irq(&current->sigmask_lock);
+			flush_signals(current);
+			spin_unlock_irq(&current->sigmask_lock);
+		}
+
+		printk(KERN_DEBUG "clean_tsks() starting\n");
+		clean_tsks();  /* fill up the dirty list */
+		printk(KERN_DEBUG "clean_tsks() done\n");
+		/* Then put it all on disk */
+		run_task_queue(&tq_disk);
+		/* Should I run tq_disk more often? */
+
+		printk(KERN_DEBUG "kpgflushd going to sleep\n");
+		left = schedule_timeout(pgflush_wait);
+		printk(KERN_DEBUG "kpgflushd awoke with %ld jiffies remaing\n",
+		       left);
+	}
+}
diff -uNrX linux-ignore-files linux-2.2.0-pre5.eb1.1/mm/vmscan.c linux-2.2.0-pre5.eb1.2/mm/vmscan.c
--- linux-2.2.0-pre5.eb1.1/mm/vmscan.c	Wed Jan  6 22:51:45 1999
+++ linux-2.2.0-pre5.eb1.2/mm/vmscan.c	Tue Jan 12 23:39:42 1999
@@ -79,7 +79,7 @@
 		tsk->nswap++;
 		flush_tlb_page(vma, address);
 		__free_page(page_map);
-		return 0;
+		return 0; /* This is the only work we can do now */
 	}
 
 	/*
@@ -99,61 +99,8 @@
 		pte_clear(page_table);
 		goto drop_pte;
 	}
-
-	/*
-	 * Ok, it's really dirty. That means that
-	 * we should either create a new swap cache
-	 * entry for it, or we should write it back
-	 * to its own backing store.
-	 *
-	 * Note that in neither case do we actually
-	 * know that we make a page available, but
-	 * as we potentially sleep we can no longer
-	 * continue scanning, so we migth as well
-	 * assume we free'd something.
-	 *
-	 * NOTE NOTE NOTE! This should just set a
-	 * dirty bit in page_map, and just drop the
-	 * pte. All the hard work would be done by
-	 * shrink_mmap().
-	 *
-	 * That would get rid of a lot of problems.
-	 */
-	if (vma->vm_ops && vma->vm_ops->swapout) {
-		pid_t pid = tsk->pid;
-		vma->vm_mm->rss--;
-		if (vma->vm_ops->swapout(vma, address - vma->vm_start + vma->vm_offset, page_table))
-			kill_proc(pid, SIGBUS, 1);
-		__free_page(page_map);
-		return 1;
-	}
-
-	/*
-	 * This is a dirty, swappable page.  First of all,
-	 * get a suitable swap entry for it, and make sure
-	 * we have the swap cache set up to associate the
-	 * page with that swap entry.
-	 */
-	entry = get_swap_page();
-	if (!entry)
-		return 0; /* No swap space left */
-		
-	vma->vm_mm->rss--;
-	tsk->nswap++;
-	flush_cache_page(vma, address);
-	set_pte(page_table, __pte(entry));
-	flush_tlb_page(vma, address);
-	swap_duplicate(entry);	/* One for the process, one for the swap cache */
-	add_to_swap_cache(page_map, entry);
-	/* We checked we were unlocked way up above, and we
-	   have been careful not to stall until here */
-	set_bit(PG_locked, &page_map->flags);
-
-	/* OK, do a physical asynchronous write to swap.  */
-	rw_swap_page(WRITE, entry, (char *) page, 0);
-
-	__free_page(page_map);
-	return 1;
+	/* wakeup_pgflush here? */
+	return 0;
 }
 
 /*
@@ -192,7 +139,7 @@
 
 	do {
 		int result;
-		tsk->swap_address = address + PAGE_SIZE;
+		tsk->mm->swap_address = address + PAGE_SIZE;
 		result = try_to_swap_out(tsk, vma, address, pte, gfp_mask);
 		if (result)
 			return result;
@@ -264,7 +211,7 @@
 	/*
 	 * Go through process' page directory.
 	 */
-	address = p->swap_address;
+	address = p->mm->swap_address;
 
 	/*
 	 * Find the proper vm-area
@@ -286,8 +233,8 @@
 	}
 
 	/* We didn't find anything for the process */
-	p->swap_cnt = 0;
-	p->swap_address = 0;
+	p->mm->swap_cnt = 0;
+	p->mm->swap_address = 0;
 	return 0;
 }
 
@@ -335,9 +282,9 @@
 				continue;
 			/* Refresh swap_cnt? */
 			if (assign)
-				p->swap_cnt = p->mm->rss;
-			if (p->swap_cnt > max_cnt) {
-				max_cnt = p->swap_cnt;
+				p->mm->swap_cnt = p->mm->rss;
+			if (p->mm->swap_cnt > max_cnt) {
+				max_cnt = p->mm->swap_cnt;
 				pbest = p;
 			}
 		}
@@ -456,6 +403,9 @@
 	/* Always trim SLAB caches when memory gets low. */
 	kmem_cache_reap(gfp_mask);
 
+	/* Also invest in clean pages */
+	wakeup_pgflush();
+
 	priority = 6;
 	do {
 		while (shrink_mmap(priority, gfp_mask)) {
@@ -476,6 +426,9 @@
 		}
 
 		shrink_dcache_memory(priority, gfp_mask);
+
+		schedule();
+
 	} while (--priority >= 0);
 done:
 	unlock_kernel();

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
