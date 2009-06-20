From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 11/15] HWPOISON: The high level memory error handler in the VM v8
Date: Sat, 20 Jun 2009 11:16:19 +0800
Message-ID: <20090620031626.106150781@intel.com>
References: <20090620031608.624240019@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4307F6B0092
	for <linux-mm@kvack.org>; Fri, 19 Jun 2009 23:19:53 -0400 (EDT)
Content-Disposition: inline; filename=high-level
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, hugh.dickins@tiscali.co.uk, npiggin@suse.de, chris.mason@oracle.com, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

From: Andi Kleen <ak@linux.intel.com>

Add the high level memory handler that poisons pages
that got corrupted by hardware (typically by a two bit flip in a DIMM
or a cache) on the Linux level. The goal is to prevent everyone
from accessing these pages in the future.

This done at the VM level by marking a page hwpoisoned
and doing the appropriate action based on the type of page
it is.

The code that does this is portable and lives in mm/memory-failure.c

To quote the overview comment:

 * High level machine check handler. Handles pages reported by the
 * hardware as being corrupted usually due to a 2bit ECC memory or cache
 * failure.
 *
 * This focuses on pages detected as corrupted in the background.
 * When the current CPU tries to consume corruption the currently
 * running process can just be killed directly instead. This implies
 * that if the error cannot be handled for some reason it's safe to
 * just ignore it because no corruption has been consumed yet. Instead
 * when that happens another machine check will happen.
 *
 * Handles page cache pages in various states. The tricky part
 * here is that we can access any page asynchronous to other VM
 * users, because memory failures could happen anytime and anywhere,
 * possibly violating some of their assumptions. This is why this code
 * has to be extremely careful. Generally it tries to use normal locking
 * rules, as in get the standard locks, even if that means the
 * error handling takes potentially a long time.
 *
 * Some of the operations here are somewhat inefficient and have non
 * linear algorithmic complexity, because the data structures have not
 * been optimized for this case. This is in particular the case
 * for the mapping from a vma to a process. Since this case is expected
 * to be rare we hope we can get away with this.

There are in principle two strategies to kill processes on poison:
- just unmap the data and wait for an actual reference before killing;
- kill as soon as corruption is detected.
Both have advantages and disadvantages and should be used
in different situations. Right now both are implemented and can
be switched with syscall prctl(PR_MEMORY_FAILURE_EARLY_KILL, 0/1, ...)
to be implemented in the next patch.  The default will be late kill.

The patch does some rmap data structure walking on its own to collect
processes to kill. This is unusual because normally all rmap data structure
knowledge is in rmap.c only. I put it here for now to keep
everything together and rmap knowledge has been seeping out anyways

v2: Fix anon vma unlock crash (noticed by Johannes Weiner <hannes@cmpxchg.org>)
Handle pages on free list correctly (also noticed by Johannes)
Fix inverted try_to_release_page check (found by Chris Mason)
Add documentation for the new sysctl.
Various other cleanups/comment fixes.
v3: Use blockable signal for AO SIGBUS for better qemu handling.
Numerous fixes from Fengguang Wu:
New code layout for the table (redone by AK)
Move the hwpoison bit setting before the lock (Fengguang Wu)
Some code cleanups (Fengguang Wu, AK)
Add missing lru_drain (Fengguang Wu)
Do more checks for valid mappings (inspired by patch from Fengguang)
Handle free pages and fixes for clean pages (Fengguang)
Removed swap cache handling for now, needs more work
Better mapping checks to avoid races (Fengguang)
Fix swapcache (Fengguang)
Handle private2 pages too (Fengguang)
v4: Various fixes based on review comments from Nick Piggin
Document locking order.
Improved comments.
Slightly improved description
Remove bogus hunk.
Wait properly for writeback pages (Nick Piggin)
v5: Improve various comments
Handle page_address_in_vma() failure better by SIGKILL and also
	make message debugging only
Clean up printks
Remove redundant PageWriteback check (Nick Piggin)
Add missing clear_page_mlock
Reformat state table to be <80 columns again
Use truncate helper instead of manual truncate in me_pagecache_*
Check for metadata buffer pages and reject them.
A few cleanups.
v6:
Fix a printk broken in the last round of cleanups.
More minor cleanups and fixes based on comments from FengguangWu.
Rename /proc/meminfo Header to "HardwareCorrupted"
Add a printk for the failed mapping case (Fengguang Wu)
Better clean page check (Fengguang Wu)
v7:
Fix kernel oops by action_result(invalid pfn) (Fengguang Wu)
make tasklist_lock/anon_vma locking order straight (Nick Piggin)
use the safer invalidate page for possible metadata pages (Nick Piggin)
v8:
check for page_mapped_in_vma() on anon pages (Hugh, Fengguang)
test and use page->mapping instead of page_mapping() (Fengguang)
cleanup some early kill comments (Fengguang)
introduce invalidate_inode_page() and don't remove dirty/writeback pages
from page cache (Nick, Fengguang)
account all poisoned pages in mce_bad_pages (Fengguang)

Cc: hugh.dickins@tiscali.co.uk
Cc: npiggin@suse.de
Cc: chris.mason@oracle.com
Acked-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 fs/proc/meminfo.c    |    9 
 include/linux/mm.h   |    6 
 include/linux/rmap.h |    1 
 mm/Kconfig           |    3 
 mm/Makefile          |    1 
 mm/filemap.c         |    4 
 mm/memory-failure.c  |  776 +++++++++++++++++++++++++++++++++++++++++
 mm/rmap.c            |    6 
 mm/truncate.c        |   23 -
 9 files changed, 821 insertions(+), 8 deletions(-)

--- sound-2.6.orig/mm/Makefile
+++ sound-2.6/mm/Makefile
@@ -42,5 +42,6 @@ obj-$(CONFIG_SMP) += allocpercpu.o
 endif
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
+obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
--- /dev/null
+++ sound-2.6/mm/memory-failure.c
@@ -0,0 +1,776 @@
+/*
+ * linux/mm/memory-failure.c
+ *
+ * High level machine check handler.
+ *
+ * Copyright (C) 2008, 2009 Intel Corporation
+ * Authors: Andi Kleen, Fengguang Wu
+ *
+ * This software may be redistributed and/or modified under the terms of
+ * the GNU General Public License ("GPL") version 2 only as published by the
+ * Free Software Foundation.
+ *
+ * Pages are reported by the hardware as being corrupted usually due to a
+ * 2bit ECC memory or cache failure. Machine check can either be raised when
+ * corruption is found in background memory scrubbing, or when someone tries to
+ * consume the corruption. This code focuses on the former case.  If it cannot
+ * handle the error for some reason it's safe to just ignore it because no
+ * corruption has been consumed yet. Instead when that happens another (deadly)
+ * machine check will happen.
+ *
+ * The tricky part here is that we can access any page asynchronous to other VM
+ * users, because memory failures could happen anytime and anywhere, possibly
+ * violating some of their assumptions. This is why this code has to be
+ * extremely careful. Generally it tries to use normal locking rules, as in get
+ * the standard locks, even if that means the error handling takes potentially
+ * a long time.
+ *
+ * We don't aim to rescue 100% corruptions. That's unreasonable goal - the
+ * kernel text and slab pages (including the big dcache/icache) are almost
+ * impossible to isolate. We also try to keep the code clean by ignoring the
+ * other thousands of small corruption windows.
+ *
+ * When the corrupted page data is not recoverable, the tasks mapped the page
+ * have to be killed. We offer two kill options:
+ * - early kill with SIGBUS.BUS_MCEERR_AO (optional)
+ * - late  kill with SIGBUS.BUS_MCEERR_AR (mandatory)
+ * A task will be early killed as soon as corruption is found in its virtual
+ * address space, if it has called prctl(PR_MEMORY_FAILURE_EARLY_KILL, 1, ...);
+ * Tasks will always be late killed when it tries to access its corrupted
+ * virtual address. The early kill option offers KVM or other apps with large
+ * caches an opportunity to isolate the corrupted page from its internal cache,
+ * so as to avoid being late killed.
+ */
+
+/*
+ * Notebook:
+ * - hugetlb needs more code
+ * - kcore/oldmem/vmcore/mem/kmem check for hwpoison pages
+ * - pass bad pages to kdump next kernel
+ */
+#define DEBUG 1
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/page-flags.h>
+#include <linux/sched.h>
+#include <linux/rmap.h>
+#include <linux/pagemap.h>
+#include <linux/swap.h>
+#include <linux/backing-dev.h>
+#include "internal.h"
+
+atomic_long_t mce_bad_pages __read_mostly = ATOMIC_LONG_INIT(0);
+
+/*
+ * Send all the processes who have the page mapped an ``action optional''
+ * signal.
+ */
+static int kill_proc_ao(struct task_struct *t, unsigned long addr, int trapno,
+			unsigned long pfn)
+{
+	struct siginfo si;
+	int ret;
+
+	printk(KERN_ERR
+	"MCE %#lx: Killing %s:%d early due to hardware memory corruption\n",
+		pfn, t->comm, t->pid);
+	si.si_signo = SIGBUS;
+	si.si_errno = 0;
+	si.si_code = BUS_MCEERR_AO;
+	si.si_addr = (void *)addr;
+#ifdef __ARCH_SI_TRAPNO
+	si.si_trapno = trapno;
+#endif
+	si.si_addr_lsb = PAGE_SHIFT;
+	/*
+	 * Don't use force here, it's convenient if the signal
+	 * can be temporarily blocked.
+	 * This could cause a loop when the user sets SIGBUS
+	 * to SIG_IGN, but hopefully noone will do that?
+	 */
+	ret = send_sig_info(SIGBUS, &si, t);  /* synchronous? */
+	if (ret < 0)
+		printk(KERN_INFO "MCE: Error sending signal to %s:%d: %d\n",
+		       t->comm, t->pid, ret);
+	return ret;
+}
+
+/*
+ * Kill all processes that have a poisoned page mapped and then isolate
+ * the page.
+ *
+ * General strategy:
+ * Find all processes having the page mapped and kill them.
+ * But we keep a page reference around so that the page is not
+ * actually freed yet.
+ * Then stash the page away
+ *
+ * There's no convenient way to get back to mapped processes
+ * from the VMAs. So do a brute-force search over all
+ * running processes.
+ *
+ * Remember that machine checks are not common (or rather
+ * if they are common you have other problems), so this shouldn't
+ * be a performance issue.
+ *
+ * Also there are some races possible while we get from the
+ * error detection to actually handle it.
+ */
+
+struct to_kill {
+	struct list_head nd;
+	struct task_struct *tsk;
+	unsigned long addr;
+	unsigned addr_valid:1;
+};
+
+/*
+ * Failure handling: if we can't find or can't kill a process there's
+ * not much we can do.	We just print a message and ignore otherwise.
+ */
+
+/*
+ * Schedule a process for later kill.
+ */
+static void add_to_kill(struct task_struct *tsk, struct page *p,
+			struct vm_area_struct *vma,
+			struct list_head *to_kill,
+			struct to_kill **tkc)
+{
+	struct to_kill *tk;
+
+	if (*tkc) {
+		tk = *tkc;
+		*tkc = NULL;
+	} else {
+		tk = kmalloc(sizeof(struct to_kill), GFP_ATOMIC);
+		if (!tk) {
+			printk(KERN_ERR
+		"MCE: Out of memory while machine check handling\n");
+			return;
+		}
+	}
+	tk->addr = page_address_in_vma(p, vma);
+	tk->addr_valid = 1;
+
+	/*
+	 * In theory we don't have to kill when the page was
+	 * munmaped. But it could be also a mremap. Since that's
+	 * likely very rare kill anyways just out of paranoia, but use
+	 * a SIGKILL because the error is not contained anymore.
+	 */
+	if (tk->addr == -EFAULT) {
+		pr_debug("MCE: Unable to find user space address %lx in %s\n",
+			page_to_pfn(p), tsk->comm);
+		tk->addr_valid = 0;
+	}
+	get_task_struct(tsk);
+	tk->tsk = tsk;
+	list_add_tail(&tk->nd, to_kill);
+}
+
+/*
+ * Kill the processes that have been collected earlier.
+ *
+ * Only do anything when DOIT is set, otherwise just free the list
+ * (this is used for clean pages which do not need killing)
+ * Also when FAIL is set do a force kill because something went
+ * wrong earlier.
+ */
+static void kill_procs_ao(struct list_head *to_kill, int doit, int trapno,
+			  int fail, unsigned long pfn)
+{
+	struct to_kill *tk, *next;
+
+	list_for_each_entry_safe (tk, next, to_kill, nd) {
+		if (doit) {
+			/*
+			 * In case something went wrong with munmaping
+			 * make sure the process doesn't catch the
+			 * signal and then access the memory. Just kill it.
+			 * the signal handlers
+			 */
+			if (fail || tk->addr_valid == 0) {
+				printk(KERN_ERR
+"MCE %#lx: forcibly killing %s:%d because of failure to unmap corrupted page\n",
+					pfn, tk->tsk->comm, tk->tsk->pid);
+				force_sig(SIGKILL, tk->tsk);
+			}
+
+			/*
+			 * In theory the process could have mapped
+			 * something else on the address in-between. We could
+			 * check for that, but we need to tell the
+			 * process anyways.
+			 */
+			else if (kill_proc_ao(tk->tsk, tk->addr, trapno,
+					      pfn) < 0)
+				printk(KERN_ERR
+	"MCE %#lx: Cannot send advisory machine check signal to %s:%d\n",
+					pfn, tk->tsk->comm, tk->tsk->pid);
+		}
+		put_task_struct(tk->tsk);
+		kfree(tk);
+	}
+}
+
+/*
+ * Collect processes when the error hit an anonymous page.
+ */
+static void collect_procs_anon(struct page *page, struct list_head *to_kill,
+			       struct to_kill **tkc)
+{
+	struct vm_area_struct *vma;
+	struct task_struct *tsk;
+	struct anon_vma *av;
+
+	read_lock(&tasklist_lock);
+
+	av = page_lock_anon_vma(page);
+	if (av == NULL)	/* Not actually mapped anymore */
+		goto out;
+
+	for_each_process (tsk) {
+		if (!tsk->mm)
+			continue;
+		list_for_each_entry (vma, &av->head, anon_vma_node) {
+			if (!page_mapped_in_vma(page, vma))
+				continue;
+
+			if (vma->vm_mm == tsk->mm)
+				add_to_kill(tsk, page, vma, to_kill, tkc);
+		}
+	}
+	page_unlock_anon_vma(av);
+out:
+	read_unlock(&tasklist_lock);
+}
+
+/*
+ * Collect processes when the error hit a file mapped page.
+ */
+static void collect_procs_file(struct page *page, struct list_head *to_kill,
+			       struct to_kill **tkc)
+{
+	struct vm_area_struct *vma;
+	struct task_struct *tsk;
+	struct prio_tree_iter iter;
+	struct address_space *mapping = page->mapping;
+
+	/*
+	 * A note on the locking order between the two locks.
+	 * We don't rely on this particular order.
+	 * If you have some other code that needs a different order
+	 * feel free to switch them around. Or add a reverse link
+	 * from mm_struct to task_struct, then this could be all
+	 * done without taking tasklist_lock and looping over all tasks.
+	 */
+
+	read_lock(&tasklist_lock);
+	spin_lock(&mapping->i_mmap_lock);
+	for_each_process(tsk) {
+		pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+
+		if (!tsk->mm)
+			continue;
+
+		vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff,
+				      pgoff)
+			/*
+			 * Send early kill signal to tasks whose vma covers
+			 * the page but not necessarily mapped it in its pte.
+			 * Applications who requested early kill normally want
+			 * to be informed of such data corruptions.
+			 */
+			if (vma->vm_mm == tsk->mm)
+				add_to_kill(tsk, page, vma, to_kill, tkc);
+	}
+	spin_unlock(&mapping->i_mmap_lock);
+	read_unlock(&tasklist_lock);
+}
+
+/*
+ * Collect the processes who have the corrupted page mapped to kill.
+ *
+ * The operation to map back from RMAP chains to processes has to walk
+ * the complete process list and has non linear complexity with the number
+ * mappings. In short it can be quite slow. But since memory corruptions
+ * are rare and only tasks flagged PF_EARLY_KILL will be searched, we hope to
+ * get away with this.
+ */
+static void collect_procs(struct page *page, struct list_head *tokill)
+{
+	struct to_kill *tk;
+
+	/*
+	 * First preallocate one to_kill structure outside the spin locks,
+	 * so that we can kill at least one process reasonably reliable.
+	 */
+	tk = kmalloc(sizeof(struct to_kill), GFP_NOIO);
+
+	if (PageAnon(page))
+		collect_procs_anon(page, tokill, &tk);
+	else
+		collect_procs_file(page, tokill, &tk);
+	kfree(tk);
+}
+
+/*
+ * Error handlers for various types of pages.
+ */
+
+enum outcome {
+	FAILED,		/* Error handling failed */
+	DELAYED,	/* Will be handled later */
+	IGNORED,	/* Error safely ignored */
+	RECOVERED,	/* Successfully recovered */
+};
+
+static const char *action_name[] = {
+	[FAILED] = "Failed",
+	[DELAYED] = "Delayed",
+	[IGNORED] = "Ignored",
+	[RECOVERED] = "Recovered",
+};
+
+/*
+ * Error hit kernel page.
+ * Do nothing, try to be lucky and not touch this instead. For a few cases we
+ * could be more sophisticated.
+ */
+static int me_kernel(struct page *p, unsigned long pfn)
+{
+	return DELAYED;
+}
+
+/*
+ * Already poisoned page.
+ */
+static int me_ignore(struct page *p, unsigned long pfn)
+{
+	return IGNORED;
+}
+
+/*
+ * Page in unknown state. Do nothing.
+ */
+static int me_unknown(struct page *p, unsigned long pfn)
+{
+	printk(KERN_ERR "MCE %#lx: Unknown page state\n", pfn);
+	return FAILED;
+}
+
+/*
+ * Free memory
+ */
+static int me_free(struct page *p, unsigned long pfn)
+{
+	return DELAYED;
+}
+
+/*
+ * Clean (or cleaned) page cache page.
+ */
+static int me_pagecache_clean(struct page *p, unsigned long pfn)
+{
+	struct address_space *mapping;
+
+	if (!isolate_lru_page(p))
+		page_cache_release(p);
+
+	mapping = page_mapping(p);
+	if (mapping == NULL)
+		return RECOVERED;
+
+	/*
+	 * Now remove it from page cache.
+	 * Currently we only remove clean, unused page for the sake of safety.
+	 */
+	if (!invalidate_inode_page(mapping, p)) {
+		printk(KERN_ERR
+		       "MCE %#lx: failed to remove from page cache\n", pfn);
+		return FAILED;
+	}
+	return RECOVERED;
+}
+
+/*
+ * Dirty cache page page
+ * Issues: when the error hit a hole page the error is not properly
+ * propagated.
+ */
+static int me_pagecache_dirty(struct page *p, unsigned long pfn)
+{
+	struct address_space *mapping = page_mapping(p);
+
+	SetPageError(p);
+	/* TBD: print more information about the file. */
+	if (mapping) {
+		/*
+		 * IO error will be reported by write(), fsync(), etc.
+		 * who check the mapping.
+		 * This way the application knows that something went
+		 * wrong with its dirty file data.
+		 *
+		 * There's one open issue:
+		 *
+		 * The EIO will be only reported on the next IO
+		 * operation and then cleared through the IO map.
+		 * Normally Linux has two mechanisms to pass IO error
+		 * first through the AS_EIO flag in the address space
+		 * and then through the PageError flag in the page.
+		 * Since we drop pages on memory failure handling the
+		 * only mechanism open to use is through AS_AIO.
+		 *
+		 * This has the disadvantage that it gets cleared on
+		 * the first operation that returns an error, while
+		 * the PageError bit is more sticky and only cleared
+		 * when the page is reread or dropped.  If an
+		 * application assumes it will always get error on
+		 * fsync, but does other operations on the fd before
+		 * and the page is dropped inbetween then the error
+		 * will not be properly reported.
+		 *
+		 * This can already happen even without hwpoisoned
+		 * pages: first on metadata IO errors (which only
+		 * report through AS_EIO) or when the page is dropped
+		 * at the wrong time.
+		 *
+		 * So right now we assume that the application DTRT on
+		 * the first EIO, but we're not worse than other parts
+		 * of the kernel.
+		 */
+		mapping_set_error(mapping, EIO);
+	}
+
+	return me_pagecache_clean(p, pfn);
+}
+
+/*
+ * Clean and dirty swap cache.
+ *
+ * Dirty swap cache page is tricky to handle. The page could live both in page
+ * cache and swap cache(ie. page is freshly swapped in). So it could be
+ * referenced concurrently by 2 types of PTEs:
+ * normal PTEs and swap PTEs. We try to handle them consistently by calling
+ * try_to_unmap(TTU_IGNORE_HWPOISON) to convert the normal PTEs to swap PTEs,
+ * and then
+ *      - clear dirty bit to prevent IO
+ *      - remove from LRU
+ *      - but keep in the swap cache, so that when we return to it on
+ *        a later page fault, we know the application is accessing
+ *        corrupted data and shall be killed (we installed simple
+ *        interception code in do_swap_page to catch it).
+ *
+ * Clean swap cache pages can be directly isolated. A later page fault will
+ * bring in the known good data from disk.
+ */
+static int me_swapcache_dirty(struct page *p, unsigned long pfn)
+{
+	ClearPageDirty(p);
+	/* Trigger EIO in shmem: */
+	ClearPageUptodate(p);
+
+	if (!isolate_lru_page(p))
+		page_cache_release(p);
+
+	return DELAYED;
+}
+
+static int me_swapcache_clean(struct page *p, unsigned long pfn)
+{
+	if (!isolate_lru_page(p))
+		page_cache_release(p);
+
+	delete_from_swap_cache(p);
+
+	return RECOVERED;
+}
+
+/*
+ * Huge pages. Needs work.
+ * Issues:
+ * No rmap support so we cannot find the original mapper. In theory could walk
+ * all MMs and look for the mappings, but that would be non atomic and racy.
+ * Need rmap for hugepages for this. Alternatively we could employ a heuristic,
+ * like just walking the current process and hoping it has it mapped (that
+ * should be usually true for the common "shared database cache" case)
+ * Should handle free huge pages and dequeue them too, but this needs to
+ * handle huge page accounting correctly.
+ */
+static int me_huge_page(struct page *p, unsigned long pfn)
+{
+	return FAILED;
+}
+
+/*
+ * Various page states we can handle.
+ *
+ * A page state is defined by its current page->flags bits.
+ * The table matches them in order and calls the right handler.
+ *
+ * This is quite tricky because we can access page at any time
+ * in its live cycle, so all accesses have to be extremly careful.
+ *
+ * This is not complete. More states could be added.
+ * For any missing state don't attempt recovery.
+ */
+
+#define dirty		(1UL << PG_dirty)
+#define sc		(1UL << PG_swapcache)
+#define unevict		(1UL << PG_unevictable)
+#define mlock		(1UL << PG_mlocked)
+#define writeback	(1UL << PG_writeback)
+#define lru		(1UL << PG_lru)
+#define swapbacked	(1UL << PG_swapbacked)
+#define head		(1UL << PG_head)
+#define tail		(1UL << PG_tail)
+#define compound	(1UL << PG_compound)
+#define slab		(1UL << PG_slab)
+#define buddy		(1UL << PG_buddy)
+#define reserved	(1UL << PG_reserved)
+
+static struct page_state {
+	unsigned long mask;
+	unsigned long res;
+	char *msg;
+	int (*action)(struct page *p, unsigned long pfn);
+} error_states[] = {
+	{ reserved,	reserved,	"reserved kernel",	me_ignore },
+	{ buddy,	buddy,		"free kernel",	me_free },
+
+	/*
+	 * Could in theory check if slab page is free or if we can drop
+	 * currently unused objects without touching them. But just
+	 * treat it as standard kernel for now.
+	 */
+	{ slab,		slab,		"kernel slab",	me_kernel },
+
+#ifdef CONFIG_PAGEFLAGS_EXTENDED
+	{ head,		head,		"huge",		me_huge_page },
+	{ tail,		tail,		"huge",		me_huge_page },
+#else
+	{ compound,	compound,	"huge",		me_huge_page },
+#endif
+
+	{ sc|dirty,	sc|dirty,	"swapcache",	me_swapcache_dirty },
+	{ sc|dirty,	sc,		"swapcache",	me_swapcache_clean },
+
+#ifdef CONFIG_UNEVICTABLE_LRU
+	{ unevict|dirty, unevict|dirty,	"unevictable LRU", me_pagecache_dirty},
+	{ unevict,	unevict,	"unevictable LRU", me_pagecache_clean},
+#endif
+
+#ifdef CONFIG_HAVE_MLOCKED_PAGE_BIT
+	{ mlock|dirty,	mlock|dirty,	"mlocked LRU",	me_pagecache_dirty },
+	{ mlock,	mlock,		"mlocked LRU",	me_pagecache_clean },
+#endif
+
+	{ lru|dirty,	lru|dirty,	"LRU",		me_pagecache_dirty },
+	{ lru|dirty,	lru,		"clean LRU",	me_pagecache_clean },
+	{ swapbacked,	swapbacked,	"anonymous",	me_pagecache_clean },
+
+	/*
+	 * Catchall entry: must be at end.
+	 */
+	{ 0,		0,		"unknown page state",	me_unknown },
+};
+
+static void action_result(unsigned long pfn, char *msg, int result)
+{
+	printk(KERN_ERR "MCE %#lx: %s%s page recovery: %s\n",
+		pfn, PageDirty(pfn_to_page(pfn)) ? "dirty " : "",
+		msg, action_name[result]);
+}
+
+static void page_action(struct page_state *ps, struct page *p,
+			unsigned long pfn)
+{
+	int result;
+
+	result = ps->action(p, pfn);
+	action_result(pfn, ps->msg, result);
+	if (page_count(p) != 1)
+		printk(KERN_ERR
+		       "MCE %#lx: %s page still referenced by %d users\n",
+		       pfn, ps->msg, page_count(p) - 1);
+
+	/*
+	 * Could adjust zone counters here to correct for the missing page.
+	 */
+}
+
+#define N_UNMAP_TRIES 5
+
+/*
+ * Do all that is necessary to remove user space mappings. Unmap
+ * the pages and send SIGBUS to the processes if the data was dirty.
+ */
+static void hwpoison_user_mappings(struct page *p, unsigned long pfn,
+				  int trapno)
+{
+	enum ttu_flags ttu = TTU_UNMAP | TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
+	struct address_space *mapping;
+	LIST_HEAD(tokill);
+	int kill = 1;
+	int ret;
+	int i;
+
+	if (PageReserved(p) || PageCompound(p) || PageSlab(p))
+		return;
+
+	if (!PageLRU(p))
+		lru_add_drain();
+
+	/*
+	 * This check implies we don't kill processes if their pages
+	 * are in the swap cache early. Those are always late kills.
+	 */
+	if (!page_mapped(p))
+		return;
+
+	if (PageSwapCache(p)) {
+		printk(KERN_ERR
+		       "MCE %#lx: keeping poisoned page in swap cache\n", pfn);
+		ttu |= TTU_IGNORE_HWPOISON;
+	}
+
+	/*
+	 * Propagate the dirty bit from PTEs to struct page first, because we
+	 * need this to decide if we should kill or just drop the page.
+	 */
+	mapping = page_mapping(p);
+	if (!PageDirty(p) && mapping && mapping_cap_writeback_dirty(mapping)) {
+		if (page_mkclean(p))
+			SetPageDirty(p);
+		else {
+			kill = 0;
+			ttu |= TTU_IGNORE_HWPOISON;
+			printk(KERN_INFO
+	"MCE %#lx: corrupted page was clean: dropped without side effects\n",
+				pfn);
+		}
+	}
+
+	/*
+	 * First collect all the processes that have the page
+	 * mapped.  This has to be done before try_to_unmap,
+	 * because ttu takes the rmap data structures down.
+	 *
+	 * Error handling: We ignore errors here because
+	 * there's nothing that can be done.
+	 */
+	if (kill && p->mapping)
+		collect_procs(p, &tokill);
+
+	/*
+	 * try_to_unmap can fail temporarily due to races.
+	 * Try a few times (RED-PEN better strategy?)
+	 */
+	for (i = 0; i < N_UNMAP_TRIES; i++) {
+		ret = try_to_unmap(p, ttu);
+		if (ret == SWAP_SUCCESS)
+			break;
+		pr_debug("MCE %#lx: try_to_unmap retry needed %d\n", pfn,  ret);
+	}
+
+	if (ret != SWAP_SUCCESS)
+		printk(KERN_ERR "MCE %#lx: failed to unmap page (mapcount=%d)\n",
+				pfn, page_mapcount(p));
+
+	/*
+	 * Now that the dirty bit has been propagated to the
+	 * struct page and all unmaps done we can decide if
+	 * killing is needed or not.  Only kill when the page
+	 * was dirty, otherwise the tokill list is merely
+	 * freed.  When there was a problem unmapping earlier
+	 * use a more force-full uncatchable kill to prevent
+	 * any accesses to the poisoned memory.
+	 */
+	kill_procs_ao(&tokill, !!PageDirty(p), trapno,
+		      ret != SWAP_SUCCESS, pfn);
+}
+
+/**
+ * memory_failure - Handle memory failure of a page.
+ * @pfn: Page Number of the corrupted page
+ * @trapno: Trap number reported in the signal to user space.
+ *
+ * This function is called by the low level machine check code
+ * of an architecture when it detects hardware memory corruption
+ * of a page. It tries its best to recover, which includes
+ * dropping pages, killing processes etc.
+ *
+ * The function is primarily of use for corruptions that
+ * happen outside the current execution context (e.g. when
+ * detected by a background scrubber)
+ *
+ * Must run in process context (e.g. a work queue) with interrupts
+ * enabled and no spinlocks hold.
+ */
+void memory_failure(unsigned long pfn, int trapno)
+{
+	struct page_state *ps;
+	struct page *p;
+
+	if (!pfn_valid(pfn)) {
+		printk(KERN_ERR
+		       "MCE %#lx: memory outside kernel control: Ignored\n",
+		       pfn);
+		return;
+	}
+
+	p = pfn_to_page(pfn);
+	if (TestSetPageHWPoison(p)) {
+		action_result(pfn, "already hardware poisoned", IGNORED);
+		return;
+	}
+
+	atomic_long_add(1, &mce_bad_pages);
+
+	/*
+	 * We need/can do nothing about count=0 pages.
+	 * 1) it's a free page, and therefore in safe hand:
+	 *    prep_new_page() will be the gate keeper.
+	 * 2) it's part of a non-compound high order page.
+	 *    Implies some kernel user: cannot stop them from
+	 *    R/W the page; let's pray that the page has been
+	 *    used and will be freed some time later.
+	 * In fact it's dangerous to directly bump up page count from 0,
+	 * that may make page_freeze_refs()/page_unfreeze_refs() mismatch.
+	 */
+	if (!get_page_unless_zero(compound_head(p))) {
+		action_result(pfn, "free or high order kernel", IGNORED);
+		return;
+	}
+
+	/*
+	 * Lock the page and wait for writeback to finish.
+	 * It's very difficult to mess with pages currently under IO
+	 * and in many cases impossible, so we just avoid it here.
+	 */
+	lock_page_nosync(p);
+	wait_on_page_writeback(p);
+
+	/*
+	 * Now take care of user space mappings.
+	 */
+	hwpoison_user_mappings(p, pfn, trapno);
+
+	/*
+	 * Torn down by someone else?
+	 */
+	if (PageLRU(p) && !PageSwapCache(p) && p->mapping == NULL) {
+		action_result(pfn, "already truncated LRU", IGNORED);
+		goto out;
+	}
+
+	for (ps = error_states;; ps++) {
+		if ((p->flags & ps->mask) == ps->res) {
+			page_action(ps, p, pfn);
+			break;
+		}
+	}
+out:
+	unlock_page(p);
+}
--- sound-2.6.orig/include/linux/mm.h
+++ sound-2.6/include/linux/mm.h
@@ -814,6 +814,8 @@ static inline void unmap_shared_mapping_
 extern int vmtruncate(struct inode * inode, loff_t offset);
 extern int vmtruncate_range(struct inode * inode, loff_t offset, loff_t end);
 
+int invalidate_inode_page(struct address_space *mapping, struct page *page);
+
 #ifdef CONFIG_MMU
 extern int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, int write_access);
@@ -1325,5 +1327,9 @@ void vmemmap_populate_print_last(void);
 extern int account_locked_memory(struct mm_struct *mm, struct rlimit *rlim,
 				 size_t size);
 extern void refund_locked_memory(struct mm_struct *mm, size_t size);
+
+extern void memory_failure(unsigned long pfn, int trapno);
+extern atomic_long_t mce_bad_pages;
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
--- sound-2.6.orig/fs/proc/meminfo.c
+++ sound-2.6/fs/proc/meminfo.c
@@ -95,7 +95,11 @@ static int meminfo_proc_show(struct seq_
 		"Committed_AS:   %8lu kB\n"
 		"VmallocTotal:   %8lu kB\n"
 		"VmallocUsed:    %8lu kB\n"
-		"VmallocChunk:   %8lu kB\n",
+		"VmallocChunk:   %8lu kB\n"
+#ifdef CONFIG_MEMORY_FAILURE
+		"HardwareCorrupted: %8lu kB\n"
+#endif
+		,
 		K(i.totalram),
 		K(i.freeram),
 		K(i.bufferram),
@@ -140,6 +144,9 @@ static int meminfo_proc_show(struct seq_
 		(unsigned long)VMALLOC_TOTAL >> 10,
 		vmi.used >> 10,
 		vmi.largest_chunk >> 10
+#ifdef CONFIG_MEMORY_FAILURE
+		,atomic_long_read(&mce_bad_pages) << (PAGE_SHIFT - 10)
+#endif
 		);
 
 	hugetlb_report_meminfo(m);
--- sound-2.6.orig/mm/Kconfig
+++ sound-2.6/mm/Kconfig
@@ -239,6 +239,9 @@ config KSM
 	  Enable the KSM kernel module to allow page sharing of equal pages
 	  among different tasks.
 
+config MEMORY_FAILURE
+	bool
+
 config NOMMU_INITIAL_TRIM_EXCESS
 	int "Turn on mmap() excess space trimming before booting"
 	depends on !MMU
--- sound-2.6.orig/mm/filemap.c
+++ sound-2.6/mm/filemap.c
@@ -105,6 +105,10 @@
  *
  *  ->task->proc_lock
  *    ->dcache_lock		(proc_pid_lookup)
+ *
+ *  (code doesn't rely on that order, so you could switch it around)
+ *  ->tasklist_lock             (memory_failure, collect_procs_ao)
+ *    ->i_mmap_lock
  */
 
 /*
--- sound-2.6.orig/mm/rmap.c
+++ sound-2.6/mm/rmap.c
@@ -36,6 +36,10 @@
  *                 mapping->tree_lock (widely used, in set_page_dirty,
  *                           in arch-dependent flush_dcache_mmap_lock,
  *                           within inode_lock in __sync_single_inode)
+ *
+ * (code doesn't rely on that order so it could be switched around)
+ * ->tasklist_lock
+ *   anon_vma->lock      (memory_failure, collect_procs_anon)
  */
 
 #include <linux/mm.h>
@@ -311,7 +315,7 @@ pte_t *page_check_address(struct page *p
  * if the page is not mapped into the page tables of this VMA.  Only
  * valid for normal file or anonymous VMAs.
  */
-static int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
+int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
 {
 	unsigned long address;
 	pte_t *pte;
--- sound-2.6.orig/mm/truncate.c
+++ sound-2.6/mm/truncate.c
@@ -135,6 +135,21 @@ invalidate_complete_page(struct address_
 	return ret;
 }
 
+/*
+ * Safely invalidate one page from its pagecache mapping.
+ * It only drops clean, unused pages. The page must be locked.
+ *
+ * Returns 1 if the page is successfully invalidated, otherwise 0.
+ */
+int invalidate_inode_page(struct address_space *mapping, struct page *page)
+{
+	if (PageDirty(page) || PageWriteback(page))
+		return 0;
+	if (page_mapped(page))
+		return 0;
+	return invalidate_complete_page(mapping, page);
+}
+
 /**
  * truncate_inode_pages - truncate range of pages specified by start & end byte offsets
  * @mapping: mapping to truncate
@@ -311,12 +326,8 @@ unsigned long invalidate_mapping_pages(s
 			if (lock_failed)
 				continue;
 
-			if (PageDirty(page) || PageWriteback(page))
-				goto unlock;
-			if (page_mapped(page))
-				goto unlock;
-			ret += invalidate_complete_page(mapping, page);
-unlock:
+			ret += invalidate_inode_page(mapping, page);
+
 			unlock_page(page);
 			if (next > end)
 				break;
--- sound-2.6.orig/include/linux/rmap.h
+++ sound-2.6/include/linux/rmap.h
@@ -134,6 +134,7 @@ int page_wrprotect(struct page *page, in
  */
 struct anon_vma *page_lock_anon_vma(struct page *page);
 void page_unlock_anon_vma(struct anon_vma *anon_vma);
+int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma);
 
 #else	/* !CONFIG_MMU */
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
