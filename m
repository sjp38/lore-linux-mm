Message-ID: <3AB9D2F8.86D8E359@uow.edu.au>
Date: Thu, 22 Mar 2001 21:24:56 +1100
From: Andrew Morton <andrewm@uow.edu.au>
MIME-Version: 1.0
Subject: Re: 3rd version of R/W mmap_sem patch available
References: <3AB77311.77EB7D60@uow.edu.au> <Pine.LNX.4.31.0103200801480.1503-100000@penguin.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On Wed, 21 Mar 2001, Andrew Morton wrote:
> >
> >       The handling of mm->rss is racy.  But I think
> >       it always has been?
> 
> It always has been. Right now I think we hold the page_table_lock over
> most of them, that the old patch to fix this might end up being just that
> one place. Somebody interested in checking?
> 

There were two places which needed fixing, and it was
pretty trivial.  With this patch, mm_struct.rss handling
is racefree on x86.  Some other archs (notably ia64/ia32)
are still a little racy on the exec() path.

I was sorely tempted to make put_dirty_page() require
that tsk->mm->page_table_lock be held by the caller,
which would save a bunch of locking.  But put_dirty_page()
is used by architectures which I don't understand.

The patch also includes a feeble attempt to document
some locking rules.



--- linux-2.4.3-pre6/include/linux/sched.h	Thu Mar 22 18:52:52 2001
+++ lk/include/linux/sched.h	Thu Mar 22 19:41:06 2001
@@ -209,9 +209,12 @@
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
 	int map_count;				/* number of VMAs */
 	struct rw_semaphore mmap_sem;
-	spinlock_t page_table_lock;
+	spinlock_t page_table_lock;		/* Protects task page tables and mm->rss */
 
-	struct list_head mmlist;		/* List of all active mm's */
+	struct list_head mmlist;		/* List of all active mm's.  These are globally strung
+						 * together off init_mm.mmlist, and are protected
+						 * by mmlist_lock
+						 */
 
 	unsigned long start_code, end_code, start_data, end_data;
 	unsigned long start_brk, brk, start_stack;
--- linux-2.4.3-pre6/fs/exec.c	Thu Mar 22 18:52:52 2001
+++ lk/fs/exec.c	Thu Mar 22 19:51:35 2001
@@ -252,6 +252,8 @@
 /*
  * This routine is used to map in a page into an address space: needed by
  * execve() for the initial stack and environment pages.
+ *
+ * tsk->mmap_sem is held for writing.
  */
 void put_dirty_page(struct task_struct * tsk, struct page *page, unsigned long address)
 {
@@ -291,6 +293,7 @@
 	unsigned long stack_base;
 	struct vm_area_struct *mpnt;
 	int i;
+	unsigned long rss_increment = 0;
 
 	stack_base = STACK_TOP - MAX_ARG_PAGES*PAGE_SIZE;
 
@@ -322,11 +325,14 @@
 		struct page *page = bprm->page[i];
 		if (page) {
 			bprm->page[i] = NULL;
-			current->mm->rss++;
+			rss_increment++;
 			put_dirty_page(current,page,stack_base);
 		}
 		stack_base += PAGE_SIZE;
 	}
+	spin_lock(&current->mm->page_table_lock);
+	current->mm->rss += rss_increment;
+	spin_unlock(&current->mm->page_table_lock);
 	up_write(&current->mm->mmap_sem);
 	
 	return 0;
--- linux-2.4.3-pre6/mm/memory.c	Thu Mar 22 18:52:52 2001
+++ lk/mm/memory.c	Thu Mar 22 21:13:29 2001
@@ -374,7 +374,6 @@
 		address = (address + PGDIR_SIZE) & PGDIR_MASK;
 		dir++;
 	} while (address && (address < end));
-	spin_unlock(&mm->page_table_lock);
 	/*
 	 * Update rss for the mm_struct (not necessarily current->mm)
 	 * Notice that rss is an unsigned long.
@@ -383,6 +382,7 @@
 		mm->rss -= freed;
 	else
 		mm->rss = 0;
+	spin_unlock(&mm->page_table_lock);
 }
 
 
@@ -792,6 +792,8 @@
  *  - flush the old one
  *  - update the page tables
  *  - inform the TLB about the new one
+ *
+ * We hold the mm semaphore for reading and vma->vm_mm->page_table_lock
  */
 static inline void establish_pte(struct vm_area_struct * vma, unsigned long address, pte_t *page_table, pte_t entry)
 {
@@ -800,6 +802,9 @@
 	update_mmu_cache(vma, address, entry);
 }
 
+/*
+ * We hold the mm semaphore for reading and vma->vm_mm->page_table_lock
+ */
 static inline void break_cow(struct vm_area_struct * vma, struct page *	old_page, struct page * new_page, unsigned long address, 
 		pte_t *page_table)
 {
@@ -1024,8 +1029,7 @@
 }
 
 /*
- * We hold the mm semaphore and the page_table_lock on entry
- * and exit.
+ * We hold the mm semaphore and the page_table_lock on entry and exit.
  */
 static int do_swap_page(struct mm_struct * mm,
 	struct vm_area_struct * vma, unsigned long address,
--- linux-2.4.3-pre6/mm/mmap.c	Thu Mar 22 18:52:52 2001
+++ lk/mm/mmap.c	Thu Mar 22 19:19:08 2001
@@ -889,8 +889,8 @@
 	spin_lock(&mm->page_table_lock);
 	mpnt = mm->mmap;
 	mm->mmap = mm->mmap_avl = mm->mmap_cache = NULL;
-	spin_unlock(&mm->page_table_lock);
 	mm->rss = 0;
+	spin_unlock(&mm->page_table_lock);
 	mm->total_vm = 0;
 	mm->locked_vm = 0;
 
--- linux-2.4.3-pre6/mm/vmscan.c	Tue Jan 16 07:36:49 2001
+++ lk/mm/vmscan.c	Thu Mar 22 19:32:11 2001
@@ -25,16 +25,15 @@
 #include <asm/pgalloc.h>
 
 /*
- * The swap-out functions return 1 if they successfully
- * threw something out, and we got a free page. It returns
- * zero if it couldn't do anything, and any other value
- * indicates it decreased rss, but the page was shared.
+ * The swap-out function returns 1 if it successfully
+ * scanned all the pages it was asked to (`count').
+ * It returns zero if it couldn't do anything,
  *
- * NOTE! If it sleeps, it *must* return 1 to make sure we
- * don't continue with the swap-out. Otherwise we may be
- * using a process that no longer actually exists (it might
- * have died while we slept).
+ * rss may decrease because pages are shared, but this
+ * doesn't count as having freed a page.
  */
+
+/* mm->page_table_lock is held. mmap_sem is not held */
 static void try_to_swap_out(struct mm_struct * mm, struct vm_area_struct* vma, unsigned long address, pte_t * page_table, struct page *page)
 {
 	pte_t pte;
@@ -129,6 +128,7 @@
 	return;
 }
 
+/* mm->page_table_lock is held. mmap_sem is not held */
 static int swap_out_pmd(struct mm_struct * mm, struct vm_area_struct * vma, pmd_t *dir, unsigned long address, unsigned long end, int count)
 {
 	pte_t * pte;
@@ -165,6 +165,7 @@
 	return count;
 }
 
+/* mm->page_table_lock is held. mmap_sem is not held */
 static inline int swap_out_pgd(struct mm_struct * mm, struct vm_area_struct * vma, pgd_t *dir, unsigned long address, unsigned long end, int count)
 {
 	pmd_t * pmd;
@@ -194,6 +195,7 @@
 	return count;
 }
 
+/* mm->page_table_lock is held. mmap_sem is not held */
 static int swap_out_vma(struct mm_struct * mm, struct vm_area_struct * vma, unsigned long address, int count)
 {
 	pgd_t *pgdir;
@@ -218,6 +220,9 @@
 	return count;
 }
 
+/*
+ * Returns non-zero if we scanned all `count' pages
+ */
 static int swap_out_mm(struct mm_struct * mm, int count)
 {
 	unsigned long address;
--- linux-2.4.3-pre6/mm/swapfile.c	Sun Feb 25 17:37:14 2001
+++ lk/mm/swapfile.c	Thu Mar 22 19:56:36 2001
@@ -209,6 +209,7 @@
  * share this swap entry, so be cautious and let do_wp_page work out
  * what to do if a write is requested later.
  */
+/* tasklist_lock and vma->vm_mm->page_table_lock are held */
 static inline void unuse_pte(struct vm_area_struct * vma, unsigned long address,
 	pte_t *dir, swp_entry_t entry, struct page* page)
 {
@@ -234,6 +235,7 @@
 	++vma->vm_mm->rss;
 }
 
+/* tasklist_lock and vma->vm_mm->page_table_lock are held */
 static inline void unuse_pmd(struct vm_area_struct * vma, pmd_t *dir,
 	unsigned long address, unsigned long size, unsigned long offset,
 	swp_entry_t entry, struct page* page)
@@ -261,6 +263,7 @@
 	} while (address && (address < end));
 }
 
+/* tasklist_lock and vma->vm_mm->page_table_lock are held */
 static inline void unuse_pgd(struct vm_area_struct * vma, pgd_t *dir,
 	unsigned long address, unsigned long size,
 	swp_entry_t entry, struct page* page)
@@ -291,6 +294,7 @@
 	} while (address && (address < end));
 }
 
+/* tasklist_lock and vma->vm_mm->page_table_lock are held */
 static void unuse_vma(struct vm_area_struct * vma, pgd_t *pgdir,
 			swp_entry_t entry, struct page* page)
 {
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
