Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4C9F15F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 11:10:23 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <20090407509.382219156@firstfloor.org>
In-Reply-To: <20090407509.382219156@firstfloor.org>
Subject: [PATCH] [13/16] POISON: The high level memory error handler in the VM
Message-Id: <20090407151010.E72A91D0471@basil.firstfloor.org>
Date: Tue,  7 Apr 2009 17:10:10 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: hugh@veritas.com, npiggin@suse.de, riel@redhat.com, lee.schermerhorn@hp.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>


This patch adds the high level memory handler that poisons pages. 
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

This isn't complete yet. The biggest gap is the missing hugepage 
handling and also a few other corner cases. The code is unable
in all cases to get rid of all references.

This is rather tricky code and needs a lot of review. Undoubtedly it still
has bugs.

Cc: hugh@veritas.com
Cc: npiggin@suse.de
Cc: riel@redhat.com
Cc: lee.schermerhorn@hp.com
Cc: akpm@linux-foundation.org
Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 fs/proc/meminfo.c   |    9 
 include/linux/mm.h  |    4 
 kernel/sysctl.c     |   14 +
 mm/Kconfig          |    3 
 mm/Makefile         |    1 
 mm/memory-failure.c |  575 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 605 insertions(+), 1 deletion(-)

Index: linux/mm/Makefile
===================================================================
--- linux.orig/mm/Makefile	2009-04-07 16:39:21.000000000 +0200
+++ linux/mm/Makefile	2009-04-07 16:39:39.000000000 +0200
@@ -38,3 +38,4 @@
 endif
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
+obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
Index: linux/mm/memory-failure.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/mm/memory-failure.c	2009-04-07 16:39:39.000000000 +0200
@@ -0,0 +1,575 @@
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
+ * Some of the operations here are somewhat inefficient and have non
+ * linear algorithmic complexity, because the data structures have not
+ * been optimized for this case. This is in particular the case
+ * for the mapping from a VMA to a process. Since this case is expected
+ * to be rare we hope we can get away with this.
+ */
+
+/*
+ * Notebook:
+ * - hugetlb needs more code
+ * - nonlinear
+ * - remap races
+ * - anonymous (tinject):
+ *   + left over references when process catches signal?
+ * - error reporting on EIO missing (tinject)
+ * - kcore/oldmem/vmcore/mem/kmem check for poison pages
+ * - pass bad pages to kdump next kernel
+ */
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/page-flags.h>
+#include <linux/sched.h>
+#include <linux/rmap.h>
+#include <linux/pagemap.h>
+#include <linux/swap.h>
+#include "internal.h"
+
+#define Dprintk(x...) printk(x)
+
+int sysctl_memory_failure_early_kill __read_mostly = 1;
+
+atomic_long_t mce_bad_pages;
+
+/*
+ * Send all the processes who have the page mapped an ``action optional''
+ * signal.
+ */
+static int kill_proc_ao(struct task_struct *t, unsigned long addr, int trapno)
+{
+	struct siginfo si;
+	int ret;
+
+	printk(KERN_ERR
+		"MCE: Killing %s:%d due to hardware memory corruption\n",
+		t->comm, t->pid);
+	si.si_signo = SIGBUS;
+	si.si_errno = 0;
+	si.si_code = BUS_MCEERR_AO;
+	si.si_addr = (void *)addr;
+#ifdef __ARCH_SI_TRAPNO
+	si.si_trapno = trapno;
+#endif
+	si.si_addr_lsb = PAGE_SHIFT;
+	ret = force_sig_info(SIGBUS, &si, t);  /* synchronous? */
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
+ * not much we can do.  We just print a message and ignore otherwise.
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
+static void
+kill_procs_ao(struct list_head *to_kill, int doit, int trapno, int fail)
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
+			if (kill_proc_ao(tk->tsk, tk->addr, trapno) < 0)
+				printk(KERN_ERR
+		"MCE: Cannot send advisory machine check signal to %s:%d\n",
+						 tk->tsk->comm, tk->tsk->pid);
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
+		goto out;
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
+	read_unlock(&tasklist_lock);
+out:
+	page_unlock_anon_vma(av);
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
+	printk(KERN_ERR "MCE: Unknown state page %lx flags %lx, count %d\n",
+	       page_to_pfn(p), p->flags, page_count(p));
+	return FAILED;
+}
+
+/*
+ * Free memory
+ */
+static int me_free(struct page *p)
+{
+	/* TBD Should delete page from buddy here. */
+	return IGNORED;
+}
+
+/*
+ * Clean (or cleaned) page cache page.
+ */
+static int me_pagecache_clean(struct page *p)
+{
+	struct address_space *mapping;
+
+	if (PagePrivate(p))
+		do_invalidatepage(p, 0);
+	mapping = page_mapping(p);
+	if (mapping) {
+		if (!remove_mapping(mapping, p))
+			return FAILED;
+	}
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
+	printk(KERN_ERR "MCE: Hardware memory corruption on dirty file page: write error\n");
+	if (mapping) {
+		/* CHECKME: does that report the error in all cases? */
+		mapping_set_error(mapping, EIO);
+	}
+	if (PagePrivate(p)) {
+		if (try_to_release_page(p, GFP_KERNEL)) {
+			/*
+			 * Normally this should not happen because we
+			 * have the lock.  What should we do
+			 * here. wait on the page? (TBD)
+			 */
+			printk(KERN_ERR
+			       "MCE: Trying to release dirty page failed\n");
+			return FAILED;
+		}
+	} else if (mapping) {
+		cancel_dirty_page(p, PAGE_CACHE_SIZE);
+	}
+	return me_pagecache_clean(p);
+}
+
+/*
+ * Dirty swap cache.
+ * Cannot map back to the process because the rmaps are gone. Instead we rely
+ * on any subsequent re-fault to run into the Poison bit. This is not optimal.
+ */
+static int me_swapcache_dirty(struct page *p)
+{
+	delete_from_swap_cache(p);
+	return DELAYED;
+}
+
+/*
+ * Clean swap cache.
+ */
+static int me_swapcache_clean(struct page *p)
+{
+	delete_from_swap_cache(p);
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
+ * This is quite tricky because we can access page at any time
+ * in its live cycle.
+ *
+ * This is not complete. More states could be added.
+ */
+static struct page_state {
+	unsigned long mask;
+	unsigned long res;
+	char *msg;
+	int (*action)(struct page *p);
+} error_states[] = {
+#define F(x) (1UL << PG_ ## x)
+	{ F(reserved), F(reserved), "reserved kernel", me_ignore },
+	{ F(buddy), F(buddy), "free kernel", me_free },
+	/*
+	 * Could in theory check if slab page is free or if we can drop
+	 * currently unused objects without touching them. But just
+	 * treat it as standard kernel for now.
+	 */
+	{ F(slab), F(slab), "kernel slab", me_kernel },
+#ifdef CONFIG_PAGEFLAGS_EXTENDED
+	{ F(head), F(head), "hugetlb", me_huge_page },
+	{ F(tail), F(tail), "hugetlb", me_huge_page },
+#else
+	{ F(compound), F(compound), "hugetlb", me_huge_page },
+#endif
+	{ F(swapcache)|F(dirty), F(swapcache)|F(dirty), "dirty swapcache",
+	  me_swapcache_dirty },
+	{ F(swapcache)|F(dirty), F(swapcache), "clean swapcache",
+	  me_swapcache_clean },
+#ifdef CONFIG_UNEVICTABLE_LRU
+	{ F(unevictable)|F(dirty), F(unevictable)|F(dirty),
+	  "unevictable dirty page cache", me_pagecache_dirty },
+	{ F(unevictable), F(unevictable), "unevictable page cache",
+	  me_pagecache_clean },
+#endif
+#ifdef CONFIG_HAVE_MLOCKED_PAGE_BIT
+	{ F(mlocked)|F(dirty), F(mlocked)|F(dirty), "mlocked dirty page cache",
+	  me_pagecache_dirty },
+	{ F(mlocked), F(mlocked), "mlocked page cache", me_pagecache_clean },
+#endif
+	{ F(lru)|F(dirty), F(lru)|F(dirty), "dirty lru", me_pagecache_dirty },
+	{ F(lru)|F(dirty), F(lru), "clean lru", me_pagecache_clean },
+	{ F(swapbacked), F(swapbacked), "anonymous", me_pagecache_clean },
+	/*
+	 * More states could be added here.
+	 */
+	{ 0, 0, "unknown page state", me_unknown },  /* must be at end */
+#undef F
+};
+
+static void page_action(char *msg, struct page *p, int (*action)(struct page *),
+			unsigned long pfn)
+{
+	int ret;
+
+	printk(KERN_ERR
+	       "MCE: Starting recovery on %s page %lx corrupted by hardware\n",
+	       msg, pfn);
+	ret = action(p);
+	printk(KERN_ERR "MCE: Recovery of %s page %lx: %s\n",
+	       msg, pfn, action_name[ret]);
+	if (page_count(p) != 1)
+		printk(KERN_ERR
+       "MCE: Page %lx (flags %lx) still referenced by %d users after recovery\n",
+		       pfn, p->flags, page_count(p));
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
+static int poison_page_prepare(struct page *p, unsigned long pfn, int trapno)
+{
+	if (PagePoison(p)) {
+		printk(KERN_ERR
+		       "MCE: Error for already poisoned page at %lx\n", pfn);
+		return -1;
+	}
+	SetPagePoison(p);
+
+	if (!PageReserved(p) && !PageSlab(p) && page_mapped(p)) {
+		LIST_HEAD(tokill);
+		int ret;
+		int i;
+
+		/*
+		 * First collect all the processes that have the page
+		 * mapped.  This has to be done before try_to_unmap,
+		 * because ttu takes the rmap data structures down.
+		 *
+		 * Error handling: We ignore errors here because
+		 * there's nothing that can be done.
+		 *
+		 * RED-PEN some cases in process exit seem to deadlock
+		 * on the page lock. drop it or add poison checks?
+		 */
+		if (sysctl_memory_failure_early_kill)
+			collect_procs(p, &tokill);
+
+		/*
+		 * try_to_unmap can fail temporarily due to races.
+		 * Try a few times (RED-PEN better strategy?)
+		 */
+		for (i = 0; i < N_UNMAP_TRIES; i++) {
+			ret = try_to_unmap(p, TTU_UNMAP|
+					   TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+			if (ret == SWAP_SUCCESS)
+				break;
+			Dprintk("MCE: try_to_unmap retry needed %d\n", ret);
+		}
+
+		/*
+		 * Now that the dirty bit has been propagated to the
+		 * struct page and all unmaps done we can decide if
+		 * killing is needed or not.  Only kill when the page
+		 * was dirty, otherwise the tokill list is merely
+		 * freed.  When there was a problem unmapping earlier
+		 * use a more force-full uncatchable kill to prevent
+		 * any accesses to the poisoned memory.
+		 */
+		kill_procs_ao(&tokill, !!PageDirty(p), trapno,
+			      ret != SWAP_SUCCESS);
+	}
+
+	return 0;
+}
+
+/**
+ * memory_failure - Handle memory failure of a page.
+ *
+ */
+void memory_failure(unsigned long pfn, int trapno)
+{
+	Dprintk("memory failure %lx\n", pfn);
+
+	if (!pfn_valid(pfn)) {
+		printk(KERN_ERR
+   "MCE: Hardware memory corruption in memory outside kernel control at %lx\n",
+		       pfn);
+	} else {
+		struct page *p = pfn_to_page(pfn);
+		struct page_state *ps;
+
+		/*
+		 * Make sure no one frees the page outside our control.
+		 */
+		get_page(p);
+		lock_page_nosync(p);
+
+		if (poison_page_prepare(p, pfn, trapno) < 0)
+			goto out;
+
+		for (ps = error_states;; ps++) {
+			if ((p->flags & ps->mask) == ps->res) {
+				page_action(ps->msg, p, ps->action, pfn);
+				break;
+			}
+		}
+out:
+		unlock_page(p);
+	}
+}
Index: linux/include/linux/mm.h
===================================================================
--- linux.orig/include/linux/mm.h	2009-04-07 16:39:39.000000000 +0200
+++ linux/include/linux/mm.h	2009-04-07 16:39:39.000000000 +0200
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
--- linux.orig/kernel/sysctl.c	2009-04-07 16:39:21.000000000 +0200
+++ linux/kernel/sysctl.c	2009-04-07 16:39:39.000000000 +0200
@@ -1266,6 +1266,20 @@
 		.extra2		= &one,
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
--- linux.orig/fs/proc/meminfo.c	2009-04-07 16:39:21.000000000 +0200
+++ linux/fs/proc/meminfo.c	2009-04-07 16:39:39.000000000 +0200
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
--- linux.orig/mm/Kconfig	2009-04-07 16:39:21.000000000 +0200
+++ linux/mm/Kconfig	2009-04-07 16:39:39.000000000 +0200
@@ -223,3 +223,6 @@
 
 config MMU_NOTIFIER
 	bool
+
+config MEMORY_FAILURE
+	bool

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
