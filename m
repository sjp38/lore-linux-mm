Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 80D876B00BC
	for <linux-mm@kvack.org>; Wed, 27 May 2009 16:12:46 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <200905271012.668777061@firstfloor.org>
In-Reply-To: <200905271012.668777061@firstfloor.org>
Subject: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-Id: <20090527201239.C2C9C1D0294@basil.firstfloor.org>
Date: Wed, 27 May 2009 22:12:39 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: hugh@veritas.com, npiggin@suse.de, riel@redhat.com, akpm@linux-foundation.org, chris.mason@oracle.comakpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>


This patch adds the high level memory handler that poisons pages
that got corrupted by hardware (typically by a bit flip in a DIMM
or a cache) on the Linux level. Linux tries to access these
pages in the future then.

It is portable code and lives in mm/memory-failure.c

To quote the overview comment:

 * High level machine check handler. Handles pages reported by the
 * hardware as being corrupted usually due to a 2bit ECC memory or cache
 * failure.
 *
 * This focusses on pages detected as corrupted in the background.
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
- just unmap the data and wait for an actual reference before 
killing
- kill as soon as corruption is detected.
Both have advantages and disadvantages and should be used 
in different situations. Right now both are implemented and can
be switched with a new sysctl vm.memory_failure_early_kill
The default is early kill.

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

Cc: hugh@veritas.com
Cc: npiggin@suse.de
Cc: riel@redhat.com
Cc: akpm@linux-foundation.org
Cc: chris.mason@oracle.com
Signed-off-by: Andi Kleen <ak@linux.intel.com>
Acked-by: Rik van Riel <riel@redhat.com>

---
 Documentation/sysctl/vm.txt |   21 +
 arch/x86/mm/fault.c         |    5 
 fs/proc/meminfo.c           |    9 
 include/linux/mm.h          |    4 
 kernel/sysctl.c             |   14 
 mm/Kconfig                  |    3 
 mm/Makefile                 |    1 
 mm/memory-failure.c         |  677 ++++++++++++++++++++++++++++++++++++++++++++
 8 files changed, 730 insertions(+), 4 deletions(-)

Index: linux/mm/Makefile
===================================================================
--- linux.orig/mm/Makefile	2009-05-27 21:23:18.000000000 +0200
+++ linux/mm/Makefile	2009-05-27 21:24:39.000000000 +0200
@@ -38,3 +38,4 @@
 endif
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
+obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
Index: linux/mm/memory-failure.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/mm/memory-failure.c	2009-05-27 21:28:19.000000000 +0200
@@ -0,0 +1,677 @@
+/*
+ * Copyright (C) 2008, 2009 Intel Corporation
+ * Author: Andi Kleen
+ *
+ * This software may be redistributed and/or modified under the terms of
+ * the GNU General Public License ("GPL") version 2 only as published by the
+ * Free Software Foundation.
+ *
+ * High level machine check handler. Handles pages reported by the
+ * hardware as being corrupted usually due to a 2bit ECC memory or cache
+ * failure.
+ *
+ * This focuses on pages detected as corrupted in the background.
+ * When the current CPU tries to consume corruption the currently
+ * running process can just be killed directly instead. This implies
+ * that if the error cannot be handled for some reason it's safe to
+ * just ignore it because no corruption has been consumed yet. Instead
+ * when that happens another machine check will happen.
+ *
+ * Handles page cache pages in various states.	The tricky part
+ * here is that we can access any page asynchronous to other VM
+ * users, because memory failures could happen anytime and anywhere,
+ * possibly violating some of their assumptions. This is why this code
+ * has to be extremely careful. Generally it tries to use normal locking
+ * rules, as in get the standard locks, even if that means the
+ * error handling takes potentially a long time.
+ *
+ * The operation to map back from RMAP chains to processes has to walk
+ * the complete process list and has non linear complexity with the number
+ * mappings. In short it can be quite slow. But since memory corruptions
+ * are rare we hope to get away with this.
+ */
+
+/*
+ * Notebook:
+ * - hugetlb needs more code
+ * - nonlinear
+ * - remap races
+ * - anonymous (tinject):
+ *   + left over references when process catches signal?
+ * - kcore/oldmem/vmcore/mem/kmem check for hwpoison pages
+ * - pass bad pages to kdump next kernel
+ */
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
+#define Dprintk(x...) printk(x)
+
+int sysctl_memory_failure_early_kill __read_mostly = 1;
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
+		"MCE %#lx: Killing %s:%d due to hardware memory corruption\n",
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
+};
+
+/*
+ * Failure handling: if we can't find or can't kill a process there's
+ * not much we can do.	We just print a message and ignore otherwise.
+ */
+
+/*
+ * Schedule a process for later kill.
+ * Uses GFP_ATOMIC allocations to avoid potential recursions in the VM.
+ * TBD would GFP_NOIO be enough?
+ */
+static void add_to_kill(struct task_struct *tsk, struct page *p,
+		       struct vm_area_struct *vma,
+		       struct list_head *to_kill,
+		       struct to_kill **tkc)
+{
+	int fail = 0;
+	struct to_kill *tk;
+
+	if (*tkc) {
+		tk = *tkc;
+		*tkc = NULL;
+	} else {
+		tk = kmalloc(sizeof(struct to_kill), GFP_ATOMIC);
+		if (!tk) {
+			printk(KERN_ERR "MCE: Out of memory while machine check handling\n");
+			return;
+		}
+	}
+	tk->addr = page_address_in_vma(p, vma);
+	if (tk->addr == -EFAULT) {
+		printk(KERN_INFO "MCE: Failed to get address in VMA\n");
+		tk->addr = 0;
+		fail = 1;
+	}
+	get_task_struct(tsk);
+	tk->tsk = tsk;
+	list_add_tail(&tk->nd, to_kill);
+}
+
+/*
+ * Kill the processes that have been collected earlier.
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
+			 * signal and then access the memory. So reset
+			 * the signal handlers
+			 */
+			if (fail)
+				flush_signal_handlers(tk->tsk, 1);
+
+			/*
+			 * In theory the process could have mapped
+			 * something else on the address in-between. We could
+			 * check for that, but we need to tell the
+			 * process anyways.
+			 */
+			if (kill_proc_ao(tk->tsk, tk->addr, trapno, pfn) < 0)
+				printk(KERN_ERR
+		"MCE %#lx: Cannot send advisory machine check signal to %s:%d\n",
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
+			      struct to_kill **tkc)
+{
+	struct vm_area_struct *vma;
+	struct task_struct *tsk;
+	struct anon_vma *av = page_lock_anon_vma(page);
+
+	if (av == NULL)	/* Not actually mapped anymore */
+		return;
+
+	read_lock(&tasklist_lock);
+	for_each_process (tsk) {
+		if (!tsk->mm)
+			continue;
+		list_for_each_entry (vma, &av->head, anon_vma_node) {
+			if (vma->vm_mm == tsk->mm)
+				add_to_kill(tsk, page, vma, to_kill, tkc);
+		}
+	}
+	page_unlock_anon_vma(av);
+	read_unlock(&tasklist_lock);
+}
+
+/*
+ * Collect processes when the error hit a file mapped page.
+ */
+static void collect_procs_file(struct page *page, struct list_head *to_kill,
+			      struct to_kill **tkc)
+{
+	struct vm_area_struct *vma;
+	struct task_struct *tsk;
+	struct prio_tree_iter iter;
+	struct address_space *mapping = page_mapping(page);
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
+			if (vma->vm_mm == tsk->mm)
+				add_to_kill(tsk, page, vma, to_kill, tkc);
+	}
+	spin_unlock(&mapping->i_mmap_lock);
+	read_unlock(&tasklist_lock);
+}
+
+/*
+ * Collect the processes who have the corrupted page mapped to kill.
+ * This is done in two steps for locking reasons.
+ * First preallocate one tokill structure outside the spin locks,
+ * so that we can kill at least one process reasonably reliable.
+ */
+static void collect_procs(struct page *page, struct list_head *tokill)
+{
+	struct to_kill *tk;
+
+	tk = kmalloc(sizeof(struct to_kill), GFP_KERNEL);
+	/* memory allocation failure is implicitly handled */
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
+	FAILED,
+	DELAYED,
+	IGNORED,
+	RECOVERED,
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
+static int me_kernel(struct page *p)
+{
+	return DELAYED;
+}
+
+/*
+ * Already poisoned page.
+ */
+static int me_ignore(struct page *p)
+{
+	return IGNORED;
+}
+
+/*
+ * Page in unknown state. Do nothing.
+ */
+static int me_unknown(struct page *p)
+{
+	printk(KERN_ERR "MCE %#lx: Unknown page state\n", page_to_pfn(p));
+	return FAILED;
+}
+
+/*
+ * Free memory
+ */
+static int me_free(struct page *p)
+{
+	return DELAYED;
+}
+
+/*
+ * Clean (or cleaned) page cache page.
+ */
+static int me_pagecache_clean(struct page *p)
+{
+	if (!isolate_lru_page(p))
+		page_cache_release(p);
+
+	if (page_has_private(p))
+		do_invalidatepage(p, 0);
+	if (page_has_private(p) && !try_to_release_page(p, GFP_NOIO))
+		Dprintk(KERN_ERR "MCE %#lx: failed to release buffers\n",
+			page_to_pfn(p));
+
+	/*
+	 * remove_from_page_cache assumes (mapping && !mapped)
+	 */
+	if (page_mapping(p) && !page_mapped(p)) {
+		remove_from_page_cache(p);
+		page_cache_release(p);
+	}
+
+	return RECOVERED;
+}
+
+/*
+ * Dirty cache page page
+ * Issues: when the error hit a hole page the error is not properly
+ * propagated.
+ */
+static int me_pagecache_dirty(struct page *p)
+{
+	struct address_space *mapping = page_mapping(p);
+
+	SetPageError(p);
+	/* TBD: print more information about the file. */
+	printk(KERN_ERR "MCE %#lx: Hardware memory corruption on dirty file page: write error\n",
+			page_to_pfn(p));
+	if (mapping) {
+		/*
+		 * Truncate does the same, but we're not quite the same
+		 * as truncate. Needs more checking, but keep it for now.
+		 */
+		cancel_dirty_page(p, PAGE_CACHE_SIZE);
+
+		/*
+		 * IO error will be reported by write(), fsync(), etc.
+		 * who check the mapping.
+		 */
+		mapping_set_error(mapping, EIO);
+	}
+
+	me_pagecache_clean(p);
+
+	/*
+	 * Did the earlier release work?
+	 */
+	if (page_has_private(p) && !try_to_release_page(p, GFP_NOIO))
+		return FAILED;
+
+	return RECOVERED;
+}
+
+/*
+ * Clean and dirty swap cache.
+ */
+static int me_swapcache_dirty(struct page *p)
+{
+	ClearPageDirty(p);
+
+	if (!isolate_lru_page(p))
+		page_cache_release(p);
+
+	return DELAYED;
+}
+
+static int me_swapcache_clean(struct page *p)
+{
+	ClearPageUptodate(p);
+
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
+static int me_huge_page(struct page *p)
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
+#define swapcache	(1UL << PG_swapcache)
+#define unevict		(1UL << PG_unevictable)
+#define mlocked		(1UL << PG_mlocked)
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
+/*
+ * The table is > 80 columns because all the alternatvies were much worse.
+ */
+
+static struct page_state {
+	unsigned long mask;
+	unsigned long res;
+	char *msg;
+	int (*action)(struct page *p);
+} error_states[] = {
+	{ reserved,	reserved,	"reserved kernel",	me_ignore },
+	{ buddy,	buddy,		"free kernel",		me_free },
+
+	/*
+	 * Could in theory check if slab page is free or if we can drop
+	 * currently unused objects without touching them. But just
+	 * treat it as standard kernel for now.
+	 */
+	{ slab,			slab,		"kernel slab",		me_kernel },
+
+#ifdef CONFIG_PAGEFLAGS_EXTENDED
+	{ head,			head,		"hugetlb",		me_huge_page },
+	{ tail,			tail,		"hugetlb",		me_huge_page },
+#else
+	{ compound,		compound,	"hugetlb",		me_huge_page },
+#endif
+
+	{ swapcache|dirty,	swapcache|dirty,"dirty swapcache",	me_swapcache_dirty },
+	{ swapcache|dirty,	swapcache,	"clean swapcache",	me_swapcache_clean },
+
+#ifdef CONFIG_UNEVICTABLE_LRU
+	{ unevict|dirty,	unevict|dirty,	"unevictable dirty lru", me_pagecache_dirty },
+	{ unevict,		unevict,	"unevictable lru",	me_pagecache_clean },
+#endif
+
+#ifdef CONFIG_HAVE_MLOCKED_PAGE_BIT
+	{ mlocked|dirty,	mlocked|dirty,	"mlocked dirty lru",	me_pagecache_dirty },
+	{ mlocked,		mlocked,	"mlocked lru",		me_pagecache_clean },
+#endif
+
+	{ lru|dirty,		lru|dirty,	"dirty lru",		me_pagecache_dirty },
+	{ lru|dirty,		lru,		"clean lru",		me_pagecache_clean },
+	{ swapbacked,		swapbacked,	"anonymous",		me_pagecache_clean },
+
+	/*
+	 * Add more states here.
+	 */
+
+	/*
+	 * Catchall entry: must be at end.
+	 */
+	{ 0,			0,		"unknown page state",	me_unknown },
+};
+
+static void page_action(char *msg, struct page *p, int (*action)(struct page *),
+			unsigned long pfn)
+{
+	int ret;
+
+	printk(KERN_ERR "MCE %#lx: %s page recovery: starting\n", pfn, msg);
+	ret = action(p);
+	printk(KERN_ERR "MCE %#lx: %s page recovery: %s\n",
+	       pfn, msg, action_name[ret]);
+	if (page_count(p) != 1)
+		printk(KERN_ERR
+		       "MCE %#lx: %s page still referenced by %d users\n",
+		       pfn, msg, page_count(p) - 1);
+
+	/* Could do more checks here if page looks ok */
+	atomic_long_add(1, &mce_bad_pages);
+
+	/*
+	 * Could adjust zone counters here to correct for the missing page.
+	 */
+}
+
+#define N_UNMAP_TRIES 5
+
+static void hwpoison_page_prepare(struct page *p, unsigned long pfn,
+				  int trapno)
+{
+	enum ttu_flags ttu = TTU_UNMAP| TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
+	int kill = sysctl_memory_failure_early_kill;
+	struct address_space *mapping;
+	LIST_HEAD(tokill);
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
+	 * Poisoned clean file pages are harmless, the
+	 * data can be restored by regular page faults.
+	 */
+	mapping = page_mapping(p);
+	if (!PageDirty(p) && !PageWriteback(p) &&
+	    !PageAnon(p) && !PageSwapBacked(p) &&
+	    mapping && mapping_cap_account_dirty(mapping)) {
+		if (page_mkclean(p))
+			SetPageDirty(p);
+		else {
+			kill = 0;
+			ttu |= TTU_IGNORE_HWPOISON;
+		}
+	}
+
+	/*
+	 * First collect all the processes that have the page
+	 * mapped.  This has to be done before try_to_unmap,
+	 * because ttu takes the rmap data structures down.
+	 *
+	 * This also has the side effect to propagate the dirty
+	 * bit from PTEs into the struct page. This is needed
+	 * to actually decide if something needs to be killed
+	 * or errored, or if it's ok to just drop the page.
+	 *
+	 * Error handling: We ignore errors here because
+	 * there's nothing that can be done.
+	 *
+	 * RED-PEN some cases in process exit seem to deadlock
+	 * on the page lock. drop it or add poison checks?
+	 */
+	if (kill)
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
+		Dprintk("MCE %#lx: try_to_unmap retry needed %d\n", pfn,  ret);
+	}
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
+ *
+ */
+void memory_failure(unsigned long pfn, int trapno)
+{
+	struct page_state *ps;
+	struct page *p;
+
+	if (!pfn_valid(pfn)) {
+		printk(KERN_ERR
+   "MCE %#lx: Hardware memory corruption in memory outside kernel control\n",
+		       pfn);
+		return;
+	}
+
+
+	p = pfn_to_page(pfn);
+	if (TestSetPageHWPoison(p)) {
+		printk(KERN_ERR "MCE %#lx: Error for already hardware poisoned page\n", pfn);
+		return;
+	}
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
+		printk(KERN_ERR
+		       "MCE 0x%lx: ignoring free or high order page\n", pfn);
+		return;
+	}
+
+	lock_page_nosync(p);
+	hwpoison_page_prepare(p, pfn, trapno);
+
+	/* Tored down by someone else? */
+	if (PageLRU(p) && !PageSwapCache(p) && p->mapping == NULL) {
+		printk(KERN_ERR
+		       "MCE %#lx: ignoring NULL mapping LRU page\n", pfn);
+		goto out;
+	}
+
+	for (ps = error_states;; ps++) {
+		if ((p->flags & ps->mask) == ps->res) {
+			page_action(ps->msg, p, ps->action, pfn);
+			break;
+		}
+	}
+out:
+	unlock_page(p);
+}
Index: linux/include/linux/mm.h
===================================================================
--- linux.orig/include/linux/mm.h	2009-05-27 21:24:39.000000000 +0200
+++ linux/include/linux/mm.h	2009-05-27 21:24:39.000000000 +0200
@@ -1322,6 +1322,10 @@
 
 extern void *alloc_locked_buffer(size_t size);
 extern void free_locked_buffer(void *buffer, size_t size);
+
+extern void memory_failure(unsigned long pfn, int trapno);
+extern int sysctl_memory_failure_early_kill;
+extern atomic_long_t mce_bad_pages;
 extern void release_locked_buffer(void *buffer, size_t size);
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
Index: linux/kernel/sysctl.c
===================================================================
--- linux.orig/kernel/sysctl.c	2009-05-27 21:23:18.000000000 +0200
+++ linux/kernel/sysctl.c	2009-05-27 21:24:39.000000000 +0200
@@ -1282,6 +1282,20 @@
 		.proc_handler	= &scan_unevictable_handler,
 	},
 #endif
+#ifdef CONFIG_MEMORY_FAILURE
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "memory_failure_early_kill",
+		.data		= &sysctl_memory_failure_early_kill,
+		.maxlen		= sizeof(vm_highmem_is_dirtyable),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
+#endif
+
 /*
  * NOTE: do not add new entries to this table unless you have read
  * Documentation/sysctl/ctl_unnumbered.txt
Index: linux/fs/proc/meminfo.c
===================================================================
--- linux.orig/fs/proc/meminfo.c	2009-05-27 21:23:18.000000000 +0200
+++ linux/fs/proc/meminfo.c	2009-05-27 21:24:39.000000000 +0200
@@ -97,7 +97,11 @@
 		"Committed_AS:   %8lu kB\n"
 		"VmallocTotal:   %8lu kB\n"
 		"VmallocUsed:    %8lu kB\n"
-		"VmallocChunk:   %8lu kB\n",
+		"VmallocChunk:   %8lu kB\n"
+#ifdef CONFIG_MEMORY_FAILURE
+		"BadPages:       %8lu kB\n"
+#endif
+		,
 		K(i.totalram),
 		K(i.freeram),
 		K(i.bufferram),
@@ -144,6 +148,9 @@
 		(unsigned long)VMALLOC_TOTAL >> 10,
 		vmi.used >> 10,
 		vmi.largest_chunk >> 10
+#ifdef CONFIG_MEMORY_FAILURE
+		,atomic_long_read(&mce_bad_pages) << (PAGE_SHIFT - 10)
+#endif
 		);
 
 	hugetlb_report_meminfo(m);
Index: linux/mm/Kconfig
===================================================================
--- linux.orig/mm/Kconfig	2009-05-27 21:23:18.000000000 +0200
+++ linux/mm/Kconfig	2009-05-27 21:24:39.000000000 +0200
@@ -226,6 +226,9 @@
 config MMU_NOTIFIER
 	bool
 
+config MEMORY_FAILURE
+	bool
+
 config NOMMU_INITIAL_TRIM_EXCESS
 	int "Turn on mmap() excess space trimming before booting"
 	depends on !MMU
Index: linux/Documentation/sysctl/vm.txt
===================================================================
--- linux.orig/Documentation/sysctl/vm.txt	2009-05-27 21:23:18.000000000 +0200
+++ linux/Documentation/sysctl/vm.txt	2009-05-27 21:24:39.000000000 +0200
@@ -32,6 +32,7 @@
 - legacy_va_layout
 - lowmem_reserve_ratio
 - max_map_count
+- memory_failure_early_kill
 - min_free_kbytes
 - min_slab_ratio
 - min_unmapped_ratio
@@ -53,7 +54,6 @@
 - vfs_cache_pressure
 - zone_reclaim_mode
 
-
 ==============================================================
 
 block_dump
@@ -275,6 +275,25 @@
 
 The default value is 65536.
 
+=============================================================
+
+memory_failure_early_kill:
+
+Control how to kill processes when uncorrected memory error (typically
+a 2bit error in a memory module) is detected in the background by hardware.
+
+1: Kill all processes that have the corrupted page mapped as soon as the
+corruption is detected.
+
+0: Only unmap the page from all processes and only kill a process
+who tries to access it.
+
+The kill is done using a catchable SIGBUS, so processes can handle this
+if they want to.
+
+This is only active on architectures/platforms with advanced machine
+check handling and depends on the hardware capabilities.
+
 ==============================================================
 
 min_free_kbytes:
Index: linux/arch/x86/mm/fault.c
===================================================================
--- linux.orig/arch/x86/mm/fault.c	2009-05-27 21:24:39.000000000 +0200
+++ linux/arch/x86/mm/fault.c	2009-05-27 21:24:39.000000000 +0200
@@ -851,8 +851,9 @@
 
 #ifdef CONFIG_MEMORY_FAILURE
 	if (fault & VM_FAULT_HWPOISON) {
-		printk(KERN_ERR "MCE: Killing %s:%d due to hardware memory corruption\n",
-			tsk->comm, tsk->pid);
+		printk(KERN_ERR
+       "MCE: Killing %s:%d for accessing hardware corrupted memory at %#lx\n",
+			tsk->comm, tsk->pid, address);
 		code = BUS_MCEERR_AR;
 	}
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
