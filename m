From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 3/5] HWPOISON: remove early kill option for now
Date: Thu, 11 Jun 2009 22:22:42 +0800
Message-ID: <20090611144430.682162784@intel.com>
References: <20090611142239.192891591@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9E0A36B005C
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 10:52:57 -0400 (EDT)
Content-Disposition: inline; filename=hwpoison-remove-early-kill.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

It needs more thoughts, and is not a must have for .31.

CC: Nick Piggin <npiggin@suse.de>
CC: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 Documentation/sysctl/vm.txt |   28 ---
 include/linux/mm.h          |    1 
 include/linux/rmap.h        |    6 
 kernel/sysctl.c             |   13 -
 mm/filemap.c                |    4 
 mm/memory-failure.c         |  272 ----------------------------------
 mm/rmap.c                   |    8 -
 7 files changed, 3 insertions(+), 329 deletions(-)

--- sound-2.6.orig/mm/memory-failure.c
+++ sound-2.6/mm/memory-failure.c
@@ -48,251 +48,9 @@
 #include <linux/backing-dev.h>
 #include "internal.h"
 
-int sysctl_memory_failure_early_kill __read_mostly = 1;
-
 atomic_long_t mce_bad_pages __read_mostly = ATOMIC_LONG_INIT(0);
 
 /*
- * Send all the processes who have the page mapped an ``action optional''
- * signal.
- */
-static int kill_proc_ao(struct task_struct *t, unsigned long addr, int trapno,
-			unsigned long pfn)
-{
-	struct siginfo si;
-	int ret;
-
-	printk(KERN_ERR
-	       "MCE %#lx: Killing %s:%d early due to hardware memory corruption\n",
-	       pfn, t->comm, t->pid);
-	si.si_signo = SIGBUS;
-	si.si_errno = 0;
-	si.si_code = BUS_MCEERR_AO;
-	si.si_addr = (void *)addr;
-#ifdef __ARCH_SI_TRAPNO
-	si.si_trapno = trapno;
-#endif
-	si.si_addr_lsb = PAGE_SHIFT;
-	/*
-	 * Don't use force here, it's convenient if the signal
-	 * can be temporarily blocked.
-	 * This could cause a loop when the user sets SIGBUS
-	 * to SIG_IGN, but hopefully noone will do that?
-	 */
-	ret = send_sig_info(SIGBUS, &si, t);  /* synchronous? */
-	if (ret < 0)
-		printk(KERN_INFO "MCE: Error sending signal to %s:%d: %d\n",
-		       t->comm, t->pid, ret);
-	return ret;
-}
-
-/*
- * Kill all processes that have a poisoned page mapped and then isolate
- * the page.
- *
- * General strategy:
- * Find all processes having the page mapped and kill them.
- * But we keep a page reference around so that the page is not
- * actually freed yet.
- * Then stash the page away
- *
- * There's no convenient way to get back to mapped processes
- * from the VMAs. So do a brute-force search over all
- * running processes.
- *
- * Remember that machine checks are not common (or rather
- * if they are common you have other problems), so this shouldn't
- * be a performance issue.
- *
- * Also there are some races possible while we get from the
- * error detection to actually handle it.
- */
-
-struct to_kill {
-	struct list_head nd;
-	struct task_struct *tsk;
-	unsigned long addr;
-	unsigned addr_valid:1;
-};
-
-/*
- * Failure handling: if we can't find or can't kill a process there's
- * not much we can do. We just print a message and ignore otherwise.
- */
-
-/*
- * Schedule a process for later kill.
- * Uses GFP_ATOMIC allocations to avoid potential recursions in the VM.
- * TBD would GFP_NOIO be enough?
- */
-static void add_to_kill(struct task_struct *tsk, struct page *p,
-			struct vm_area_struct *vma,
-			struct list_head *to_kill,
-			struct to_kill **tkc)
-{
-	struct to_kill *tk;
-
-	if (*tkc) {
-		tk = *tkc;
-		*tkc = NULL;
-	} else {
-		tk = kmalloc(sizeof(struct to_kill), GFP_ATOMIC);
-		if (!tk) {
-			printk(KERN_ERR
-		"MCE: Out of memory while machine check handling\n");
-			return;
-		}
-	}
-	tk->addr = page_address_in_vma(p, vma);
-	tk->addr_valid = 1;
-
-	/*
-	 * In theory we don't have to kill when the page was
-	 * munmaped. But it could be also a mremap. Since that's
-	 * likely very rare kill anyways just out of paranoia, but use
-	 * a SIGKILL because the error is not contained anymore.
-	 */
-	if (tk->addr == -EFAULT) {
-		pr_debug("MCE: Unable to find user space address %lx in %s\n",
-			 page_to_pfn(p), tsk->comm);
-		tk->addr_valid = 0;
-	}
-	get_task_struct(tsk);
-	tk->tsk = tsk;
-	list_add_tail(&tk->nd, to_kill);
-}
-
-/*
- * Kill the processes that have been collected earlier.
- *
- * Only do anything when DOIT is set, otherwise just free the list
- * (this is used for clean pages which do not need killing)
- * Also when FAIL is set do a force kill because something went
- * wrong earlier.
- */
-static void kill_procs_ao(struct list_head *to_kill, int doit, int trapno,
-			  int fail, unsigned long pfn)
-{
-	struct to_kill *tk, *next;
-
-	list_for_each_entry_safe (tk, next, to_kill, nd) {
-		if (doit) {
-			/*
-			 * In case something went wrong with munmaping
-			 * make sure the process doesn't catch the
-			 * signal and then access the memory. Just kill it.
-			 * the signal handlers
-			 */
-			if (fail || tk->addr_valid == 0) {
-				printk(KERN_ERR
-		"MCE %#lx: forcibly killing %s:%d because of failure to unmap corrupted page\n",
-					pfn, tk->tsk->comm, tk->tsk->pid);
-				force_sig(SIGKILL, tk->tsk);
-			}
-
-			/*
-			 * In theory the process could have mapped
-			 * something else on the address in-between. We could
-			 * check for that, but we need to tell the
-			 * process anyways.
-			 */
-			else if (kill_proc_ao(tk->tsk, tk->addr, trapno,
-					      pfn) < 0)
-				printk(KERN_ERR
-		"MCE %#lx: Cannot send advisory machine check signal to %s:%d\n",
-					pfn, tk->tsk->comm, tk->tsk->pid);
-		}
-		put_task_struct(tk->tsk);
-		kfree(tk);
-	}
-}
-
-/*
- * Collect processes when the error hit an anonymous page.
- */
-static void collect_procs_anon(struct page *page, struct list_head *to_kill,
-			       struct to_kill **tkc)
-{
-	struct vm_area_struct *vma;
-	struct task_struct *tsk;
-	struct anon_vma *av;
-
-	read_lock(&tasklist_lock);
-
-	av = page_lock_anon_vma(page);
-	if (av == NULL) /* Not actually mapped anymore */
-		goto out;
-
-	for_each_process (tsk) {
-		if (!tsk->mm)
-			continue;
-		list_for_each_entry (vma, &av->head, anon_vma_node) {
-			if (vma->vm_mm == tsk->mm)
-				add_to_kill(tsk, page, vma, to_kill, tkc);
-		}
-	}
-	page_unlock_anon_vma(av);
-out:
-	read_unlock(&tasklist_lock);
-}
-
-/*
- * Collect processes when the error hit a file mapped page.
- */
-static void collect_procs_file(struct page *page, struct list_head *to_kill,
-			       struct to_kill **tkc)
-{
-	struct vm_area_struct *vma;
-	struct task_struct *tsk;
-	struct prio_tree_iter iter;
-	struct address_space *mapping = page_mapping(page);
-
-	/*
-	 * A note on the locking order between the two locks.
-	 * We don't rely on this particular order.
-	 * If you have some other code that needs a different order
-	 * feel free to switch them around. Or add a reverse link
-	 * from mm_struct to task_struct, then this could be all
-	 * done without taking tasklist_lock and looping over all tasks.
-	 */
-
-	read_lock(&tasklist_lock);
-	spin_lock(&mapping->i_mmap_lock);
-	for_each_process(tsk) {
-		pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
-
-		if (!tsk->mm)
-			continue;
-
-		vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff,
-				     pgoff)
-			if (vma->vm_mm == tsk->mm)
-				add_to_kill(tsk, page, vma, to_kill, tkc);
-	}
-	spin_unlock(&mapping->i_mmap_lock);
-	read_unlock(&tasklist_lock);
-}
-
-/*
- * Collect the processes who have the corrupted page mapped to kill.
- * This is done in two steps for locking reasons.
- * First preallocate one tokill structure outside the spin locks,
- * so that we can kill at least one process reasonably reliable.
- */
-static void collect_procs(struct page *page, struct list_head *tokill)
-{
-	struct to_kill *tk;
-
-	tk = kmalloc(sizeof(struct to_kill), GFP_KERNEL);
-	/* memory allocation failure is implicitly handled */
-	if (PageAnon(page))
-		collect_procs_anon(page, tokill, &tk);
-	else
-		collect_procs_file(page, tokill, &tk);
-	kfree(tk);
-}
-
-/*
  * Error handlers for various types of pages.
  */
 
@@ -599,7 +357,6 @@ static void hwpoison_user_mappings(struc
 				   int trapno)
 {
 	enum ttu_flags ttu = TTU_UNMAP | TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
-	int kill = sysctl_memory_failure_early_kill;
 	struct address_space *mapping;
 	LIST_HEAD(tokill);
 	int ret;
@@ -633,7 +390,6 @@ static void hwpoison_user_mappings(struc
 		if (page_mkclean(p))
 			SetPageDirty(p);
 		else {
-			kill = 0;
 			ttu |= TTU_IGNORE_HWPOISON;
 			printk(KERN_INFO
 	"MCE %#lx: corrupted page was clean: dropped without side effects\n",
@@ -642,22 +398,6 @@ static void hwpoison_user_mappings(struc
 	}
 
 	/*
-	 * First collect all the processes that have the page
-	 * mapped.  This has to be done before try_to_unmap,
-	 * because ttu takes the rmap data structures down.
-	 *
-	 * This also has the side effect to propagate the dirty
-	 * bit from PTEs into the struct page. This is needed
-	 * to actually decide if something needs to be killed
-	 * or errored, or if it's ok to just drop the page.
-	 *
-	 * Error handling: We ignore errors here because
-	 * there's nothing that can be done.
-	 */
-	if (kill)
-		collect_procs(p, &tokill);
-
-	/*
 	 * try_to_unmap can fail temporarily due to races.
 	 * Try a few times (RED-PEN better strategy?)
 	 */
@@ -671,18 +411,6 @@ static void hwpoison_user_mappings(struc
 	if (ret != SWAP_SUCCESS)
 		printk(KERN_ERR "MCE %#lx: failed to unmap page (mapcount=%d)\n",
 				pfn, page_mapcount(p));
-
-	/*
-	 * Now that the dirty bit has been propagated to the
-	 * struct page and all unmaps done we can decide if
-	 * killing is needed or not.  Only kill when the page
-	 * was dirty, otherwise the tokill list is merely
-	 * freed.  When there was a problem unmapping earlier
-	 * use a more force-full uncatchable kill to prevent
-	 * any accesses to the poisoned memory.
-	 */
-	kill_procs_ao(&tokill, !!PageDirty(p), trapno,
-		      ret != SWAP_SUCCESS, pfn);
 }
 
 /**
--- sound-2.6.orig/Documentation/sysctl/vm.txt
+++ sound-2.6/Documentation/sysctl/vm.txt
@@ -32,7 +32,6 @@ Currently, these files are in /proc/sys/
 - legacy_va_layout
 - lowmem_reserve_ratio
 - max_map_count
-- memory_failure_early_kill
 - min_free_kbytes
 - min_slab_ratio
 - min_unmapped_ratio
@@ -54,6 +53,7 @@ Currently, these files are in /proc/sys/
 - vfs_cache_pressure
 - zone_reclaim_mode
 
+
 ==============================================================
 
 block_dump
@@ -275,32 +275,6 @@ e.g., up to one or two maps per allocati
 
 The default value is 65536.
 
-=============================================================
-
-memory_failure_early_kill:
-
-Control how to kill processes when uncorrected memory error (typically
-a 2bit error in a memory module) is detected in the background by hardware
-that cannot be handled by the kernel. In some cases (like the page
-still having a valid copy on disk) the kernel will handle the failure
-transparently without affecting any applications. But if there is
-no other uptodate copy of the data it will kill to prevent any data
-corruptions from propagating.
-
-1: Kill all processes that have the corrupted and not reloadable page mapped
-as soon as the corruption is detected.  Note this is not supported
-for a few types of pages, like kernel internally allocated data or
-the swap cache, but works for the majority of user pages.
-
-0: Only unmap the corrupted page from all processes and only kill a process
-who tries to access it.
-
-The kill is done using a catchable SIGBUS with BUS_MCEERR_AO, so processes can
-handle this if they want to.
-
-This is only active on architectures/platforms with advanced machine
-check handling and depends on the hardware capabilities.
-
 ==============================================================
 
 min_free_kbytes:
--- sound-2.6.orig/include/linux/mm.h
+++ sound-2.6/include/linux/mm.h
@@ -1331,7 +1331,6 @@ extern int account_locked_memory(struct 
 extern void refund_locked_memory(struct mm_struct *mm, size_t size);
 
 extern void memory_failure(unsigned long pfn, int trapno);
-extern int sysctl_memory_failure_early_kill;
 extern atomic_long_t mce_bad_pages;
 
 #endif /* __KERNEL__ */
--- sound-2.6.orig/kernel/sysctl.c
+++ sound-2.6/kernel/sysctl.c
@@ -1319,19 +1319,6 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &scan_unevictable_handler,
 	},
-#ifdef CONFIG_MEMORY_FAILURE
-       {
-               .ctl_name       = CTL_UNNUMBERED,
-               .procname       = "memory_failure_early_kill",
-               .data           = &sysctl_memory_failure_early_kill,
-               .maxlen         = sizeof(sysctl_memory_failure_early_kill),
-               .mode           = 0644,
-               .proc_handler   = &proc_dointvec_minmax,
-               .strategy       = &sysctl_intvec,
-               .extra1         = &zero,
-               .extra2         = &one,
-       },
-#endif
 
 /*
  * NOTE: do not add new entries to this table unless you have read
--- sound-2.6.orig/mm/filemap.c
+++ sound-2.6/mm/filemap.c
@@ -105,10 +105,6 @@
  *
  *  ->task->proc_lock
  *    ->dcache_lock		(proc_pid_lookup)
- *
- *  (code doesn't rely on that order, so you could switch it around)
- *  ->tasklist_lock             (memory_failure, collect_procs_ao)
- *    ->i_mmap_lock
  */
 
 /*
--- sound-2.6.orig/mm/rmap.c
+++ sound-2.6/mm/rmap.c
@@ -36,10 +36,6 @@
  *                 mapping->tree_lock (widely used, in set_page_dirty,
  *                           in arch-dependent flush_dcache_mmap_lock,
  *                           within inode_lock in __sync_single_inode)
- *
- * (code doesn't rely on that order so it could be switched around)
- * ->tasklist_lock
- *   anon_vma->lock      (memory_failure, collect_procs_anon)
  */
 
 #include <linux/mm.h>
@@ -195,7 +191,7 @@ void __init anon_vma_init(void)
  * Getting a lock on a stable anon_vma from a page off the LRU is
  * tricky: page_lock_anon_vma rely on RCU to guard against the races.
  */
-struct anon_vma *page_lock_anon_vma(struct page *page)
+static struct anon_vma *page_lock_anon_vma(struct page *page)
 {
 	struct anon_vma *anon_vma;
 	unsigned long anon_mapping;
@@ -215,7 +211,7 @@ out:
 	return NULL;
 }
 
-void page_unlock_anon_vma(struct anon_vma *anon_vma)
+static void page_unlock_anon_vma(struct anon_vma *anon_vma)
 {
 	spin_unlock(&anon_vma->lock);
 	rcu_read_unlock();
--- sound-2.6.orig/include/linux/rmap.h
+++ sound-2.6/include/linux/rmap.h
@@ -129,12 +129,6 @@ int try_to_munlock(struct page *);
 int page_wrprotect(struct page *page, int *odirect_sync, int count_offset);
 #endif
 
-/*
- * Called by memory-failure.c to kill processes.
- */
-struct anon_vma *page_lock_anon_vma(struct page *page);
-void page_unlock_anon_vma(struct anon_vma *anon_vma);
-
 #else	/* !CONFIG_MMU */
 
 #define anon_vma_init()		do {} while (0)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
