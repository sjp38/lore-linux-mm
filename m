From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906280148.SAA94463@google.engr.sgi.com>
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8 Fix swapoff races
Date: Sun, 27 Jun 1999 18:48:47 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.10.9906250203110.22024-100000@laser.random> from "Andrea Arcangeli" at Jun 25, 99 02:26:11 am
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: torvalds@transmeta.com, sct@redhat.com, linux-mm@kvack.org, Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

Linus/Andrea/Stephen,

This is the patch that tries to cure the swapoff races with processes
forking, exiting, and (readahead) swapping by faulting. 

Basically, all these operations are synchronized by the process
mmap_sem. Unfortunately, swapoff has to visit all processes, during
which it must hold tasklist_lock, a spinlock. Hence, it can not take
the mmap_sem, a sleeping mutex. So, the patch links up all active
mm's in a list that swapoff can visit (with minor restructuring, 
kswapd can also use this, although it can not hold mmap_sem).
Addition/deletions to the list are protected by a sleeping 
mutex, hence swapoff can grab the individual mmap_sems, while
preventing changes to the list. Effectively, process creation
and destruction are locked out if swapoff is running.

To do this, the lock ordering is mm_sem -> mmap_sem. To 
prevent deadlocks, care must be taken that a process invoking
delete/insert_mmlist does not have its own mmap_sem held. For
this, the do_fork path needs to change so as not to acquire
mmap_sem early, rather only when it is really needed. This does
not open up a resource-ordering problem between kernel_lock and
mmap_sem, since the kernel_lock is a monitor lock that is released
at schedule time, so no deadlocks are possible.

I have just done basic sanity testing on this, I am hoping Andrea 
can run his swapoff stress tests to see whether this patch helps
cure the problem he was seeing.

Thanks.

Kanoj
kanoj@engr.sgi.com


--- /usr/tmp/p_rdiff_a009HP/exec.c	Sun Jun 27 16:51:58 1999
+++ fs/exec.c	Sun Jun 27 15:14:43 1999
@@ -399,6 +399,7 @@
 	up(&mm->mmap_sem);
 	mm_release();
 	mmput(old_mm);
+	insert_mmlist(mm);
 	return 0;
 
 	/*
--- /usr/tmp/p_rdiff_a009HP/sched.h	Sun Jun 27 16:52:01 1999
+++ include/linux/sched.h	Fri Jun 25 17:22:56 1999
@@ -170,6 +170,8 @@
 	atomic_t count;
 	int map_count;				/* number of VMAs */
 	struct semaphore mmap_sem;
+	struct mm_struct *prev;			/* list of allocated mms */
+	struct mm_struct *next;			/* list of allocated mms */
 	unsigned long context;
 	unsigned long start_code, end_code, start_data, end_data;
 	unsigned long start_brk, brk, start_stack;
@@ -191,7 +193,7 @@
 		swapper_pg_dir, 			\
 		ATOMIC_INIT(1), 1,			\
 		__MUTEX_INITIALIZER(name.mmap_sem),	\
-		0,					\
+		&init_mm, &init_mm, 0,			\
 		0, 0, 0, 0,				\
 		0, 0, 0, 				\
 		0, 0, 0, 0,				\
@@ -611,6 +613,7 @@
 /*
  * Routines for handling mm_structs
  */
+extern struct semaphore mm_sem;
 extern struct mm_struct * mm_alloc(void);
 static inline void mmget(struct mm_struct * mm)
 {
@@ -619,6 +622,22 @@
 extern void mmput(struct mm_struct *);
 /* Remove the current tasks stale references to the old mm_struct */
 extern void mm_release(void);
+static inline void insert_mmlist(struct mm_struct * mm)
+{
+	down(&mm_sem);
+	mm->prev = &init_mm;
+	mm->next = init_mm.next;
+	init_mm.next->prev = mm;
+	init_mm.next = mm;
+	up(&mm_sem);
+}
+static inline void delete_mmlist(struct mm_struct * mm)
+{
+	down(&mm_sem);
+	mm->next->prev = mm->prev;
+	mm->prev->next = mm->next;
+	up(&mm_sem);
+}
 
 extern int  copy_thread(int, unsigned long, unsigned long, struct task_struct *, struct pt_regs *);
 extern void flush_thread(void);
--- /usr/tmp/p_rdiff_a009HP/fork.c	Sun Jun 27 16:52:04 1999
+++ kernel/fork.c	Sun Jun 27 15:28:34 1999
@@ -351,6 +351,7 @@
 		release_segments(mm);
 		exit_mmap(mm);
 		free_page_tables(mm);
+		delete_mmlist(mm);
 		kmem_cache_free(mm_cachep, mm);
 	}
 }
@@ -383,7 +384,11 @@
 	retval = new_page_tables(tsk);
 	if (retval)
 		goto free_mm;
+	insert_mmlist(mm);
+
+	down(&current->mm->mmap_sem);
 	retval = dup_mmap(mm);
+	up(&current->mm->mmap_sem);
 	if (retval)
 		goto free_pt;
 	up(&mm->mmap_sem);
@@ -549,7 +554,6 @@
 
 	*p = *current;
 
-	down(&current->mm->mmap_sem);
 	lock_kernel();
 
 	retval = -EAGAIN;
@@ -676,7 +680,6 @@
 	++total_forks;
 bad_fork:
 	unlock_kernel();
-	up(&current->mm->mmap_sem);
 fork_out:
 	if ((clone_flags & CLONE_VFORK) && (retval > 0)) 
 		down(&sem);
--- /usr/tmp/p_rdiff_a009HP/mmap.c	Sun Jun 27 16:52:07 1999
+++ mm/mmap.c	Sun Jun 27 15:20:08 1999
@@ -39,6 +39,8 @@
 /* SLAB cache for vm_area_struct's. */
 kmem_cache_t *vm_area_cachep;
 
+struct semaphore mm_sem;
+
 int sysctl_overcommit_memory;
 
 /* Check that a process has enough memory to allocate a
@@ -812,6 +814,7 @@
 {
 	struct vm_area_struct * mpnt;
 
+	down(&mm->mmap_sem);
 	mpnt = mm->mmap;
 	mm->mmap = mm->mmap_avl = mm->mmap_cache = NULL;
 	mm->rss = 0;
@@ -843,6 +846,7 @@
 		printk("exit_mmap: map count is %d\n", mm->map_count);
 
 	clear_page_tables(mm, 0, USER_PTRS_PER_PGD);
+	up(&mm->mmap_sem);
 }
 
 /* Insert vm structure into process list sorted by address
@@ -957,6 +961,7 @@
 
 void __init vma_init(void)
 {
+	init_MUTEX(&mm_sem);
 	vm_area_cachep = kmem_cache_create("vm_area_struct",
 					   sizeof(struct vm_area_struct),
 					   0, SLAB_HWCACHE_ALIGN,
--- /usr/tmp/p_rdiff_a009HP/page_alloc.c	Sun Jun 27 16:52:09 1999
+++ mm/page_alloc.c	Sun Jun 27 15:39:58 1999
@@ -385,10 +385,9 @@
 }
 
 /*
- * The tests may look silly, but it essentially makes sure that
- * no other process did a swap-in on us just as we were waiting.
+ * Concurrent swap-in via swapoff is interlocked out.
  *
- * Also, don't bother to add to the swap cache if this page-in
+ * Don't bother to add to the swap cache if this page-in
  * was due to a write access.
  */
 void swap_in(struct task_struct * tsk, struct vm_area_struct * vma,
@@ -400,11 +399,6 @@
 	if (!page_map) {
 		swapin_readahead(entry);
 		page_map = read_swap_cache(entry);
-	}
-	if (pte_val(*page_table) != entry) {
-		if (page_map)
-			free_page_and_swap_cache(page_address(page_map));
-		return;
 	}
 	if (!page_map) {
 		set_pte(page_table, BAD_PAGE);
--- /usr/tmp/p_rdiff_a009HP/swapfile.c	Sun Jun 27 16:52:12 1999
+++ mm/swapfile.c	Sun Jun 27 15:27:49 1999
@@ -259,20 +259,20 @@
 	}
 }
 
-static void unuse_process(struct mm_struct * mm, unsigned long entry, 
+static void unuse_mm(struct mm_struct * mm, unsigned long entry, 
 			unsigned long page)
 {
 	struct vm_area_struct* vma;
 
 	/*
-	 * Go through process' page directory.
+	 * Go through address space page directory.
 	 */
-	if (!mm || mm == &init_mm)
-		return;
+	down(&mm->mmap_sem);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		pgd_t * pgd = pgd_offset(mm, vma->vm_start);
 		unuse_vma(vma, pgd, entry, page);
 	}
+	up(&mm->mmap_sem);
 	return;
 }
 
@@ -283,8 +283,8 @@
  */
 static int try_to_unuse(unsigned int type)
 {
+	struct mm_struct * mm;
 	struct swap_info_struct * si = &swap_info[type];
-	struct task_struct *p;
 	struct page *page_map;
 	unsigned long entry, page;
 	int i;
@@ -316,10 +316,12 @@
   			return -ENOMEM;
 		}
 		page = page_address(page_map);
-		read_lock(&tasklist_lock);
-		for_each_task(p)
-			unuse_process(p->mm, entry, page);
-		read_unlock(&tasklist_lock);
+		down(&mm_sem);
+		mm = init_mm.next;
+		while (mm != &init_mm) {
+			unuse_mm(mm, entry, page);
+		}
+		up(&mm_sem);
 		shm_unuse(entry, page);
 		/* Now get rid of the extra reference to the temporary
                    page we've been using. */
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
