Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id AEC726B003D
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 23:07:58 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3S382JC027272
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 28 Apr 2009 12:08:02 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 072F645DD7C
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 12:08:02 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B19BC45DD74
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 12:08:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F4C21DB8016
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 12:08:01 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F035B1DB801A
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 12:08:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: meminfo Committed_AS underflows
In-Reply-To: <20090427132722.926b07f1.akpm@linux-foundation.org>
References: <20090415084713.GU7082@balbir.in.ibm.com> <20090427132722.926b07f1.akpm@linux-foundation.org>
Message-Id: <20090428092400.EBB6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 28 Apr 2009 12:07:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, balbir@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ebmunson@us.ibm.com, mel@linux.vnet.ibm.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> On Wed, 15 Apr 2009 14:17:13 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-04-15 13:10:06]:
> > 
> > > > * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-04-15 11:04:59]:
> > > > 
> > > > >  	committed = atomic_long_read(&vm_committed_space);
> > > > > +	if (committed < 0)
> > > > > +		committed = 0;
> > > > 
> 
> Is there a reason why we can't use a boring old percpu_counter for
> vm_committed_space?  That way the meminfo code can just use
> percpu_counter_read_positive().
> 
> Or perhaps just percpu_counter_read().  The percpu_counter code does a
> better job of handling large cpu counts than the
> mysteriously-duplicative open-coded stuff we have there.

At that time, I thought smallest patch is better because it can send -stable
tree easily.
but maybe I was wrong. it made bikeshed discussion :(

ok, I'm going to right way.


=========================================
Subject: [PATCH] fix Committed_AS underfolow on large NR_CPUS environment

As reported by Dave Hansen, the Committed_AS field can underflow in certain
situations:

>         # while true; do cat /proc/meminfo  | grep _AS; sleep 1; done | uniq -c
>               1 Committed_AS: 18446744073709323392 kB
>              11 Committed_AS: 18446744073709455488 kB
>               6 Committed_AS:    35136 kB
>               5 Committed_AS: 18446744073709454400 kB
>               7 Committed_AS:    35904 kB
>               3 Committed_AS: 18446744073709453248 kB
>               2 Committed_AS:    34752 kB
>               9 Committed_AS: 18446744073709453248 kB
>               8 Committed_AS:    34752 kB
>               3 Committed_AS: 18446744073709320960 kB
>               7 Committed_AS: 18446744073709454080 kB
>               3 Committed_AS: 18446744073709320960 kB
>               5 Committed_AS: 18446744073709454080 kB
>               6 Committed_AS: 18446744073709320960 kB

Because NR_CPUS can be greater than 1000 and meminfo_proc_show() does not check
for underflow.

But NR_CPUS proportional isn't good calculation. In general, possibility of
lock contention is proportional to the number of online cpus, not theorical
maximum cpus (NR_CPUS).
the current kernel has generic percpu-counter stuff. using it is right way.
it makes code simplify and percpu_counter_read_positive() don't make underflow issue.


Reported-by: Dave Hansen <dave@linux.vnet.ibm.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Eric B Munson <ebmunson@us.ibm.com>
---
 fs/proc/meminfo.c    |    2 +-
 include/linux/mman.h |    9 +++------
 mm/mmap.c            |   12 ++++++------
 mm/nommu.c           |   13 +++++++------
 mm/swap.c            |   46 ----------------------------------------------
 5 files changed, 17 insertions(+), 65 deletions(-)

Index: b/fs/proc/meminfo.c
===================================================================
--- a/fs/proc/meminfo.c	2009-04-28 11:36:43.000000000 +0900
+++ b/fs/proc/meminfo.c	2009-04-28 11:36:54.000000000 +0900
@@ -35,7 +35,7 @@ static int meminfo_proc_show(struct seq_
 #define K(x) ((x) << (PAGE_SHIFT - 10))
 	si_meminfo(&i);
 	si_swapinfo(&i);
-	committed = atomic_long_read(&vm_committed_space);
+	committed = percpu_counter_read_positive(&vm_committed_as);
 	allowed = ((totalram_pages - hugetlb_total_pages())
 		* sysctl_overcommit_ratio / 100) + total_swap_pages;
 
Index: b/mm/mmap.c
===================================================================
--- a/mm/mmap.c	2009-04-28 11:36:43.000000000 +0900
+++ b/mm/mmap.c	2009-04-28 11:36:54.000000000 +0900
@@ -85,7 +85,7 @@ EXPORT_SYMBOL(vm_get_page_prot);
 int sysctl_overcommit_memory = OVERCOMMIT_GUESS;  /* heuristic overcommit */
 int sysctl_overcommit_ratio = 50;	/* default is 50% */
 int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
-atomic_long_t vm_committed_space = ATOMIC_LONG_INIT(0);
+struct percpu_counter vm_committed_as;
 
 /*
  * Check that a process has enough memory to allocate a new virtual
@@ -179,11 +179,7 @@ int __vm_enough_memory(struct mm_struct 
 	if (mm)
 		allowed -= mm->total_vm / 32;
 
-	/*
-	 * cast `allowed' as a signed long because vm_committed_space
-	 * sometimes has a negative value
-	 */
-	if (atomic_long_read(&vm_committed_space) < (long)allowed)
+	if (percpu_counter_read_positive(&vm_committed_as) < allowed)
 		return 0;
 error:
 	vm_unacct_memory(pages);
@@ -2481,4 +2477,8 @@ void mm_drop_all_locks(struct mm_struct 
  */
 void __init mmap_init(void)
 {
+	int ret;
+
+	ret = percpu_counter_init(&vm_committed_as, 0);
+	VM_BUG_ON(ret);
 }
Index: b/mm/nommu.c
===================================================================
--- a/mm/nommu.c	2009-04-28 11:36:43.000000000 +0900
+++ b/mm/nommu.c	2009-04-28 11:36:54.000000000 +0900
@@ -62,7 +62,7 @@ void *high_memory;
 struct page *mem_map;
 unsigned long max_mapnr;
 unsigned long num_physpages;
-atomic_long_t vm_committed_space = ATOMIC_LONG_INIT(0);
+struct percpu_counter vm_committed_as;
 int sysctl_overcommit_memory = OVERCOMMIT_GUESS; /* heuristic overcommit */
 int sysctl_overcommit_ratio = 50; /* default is 50% */
 int sysctl_max_map_count = DEFAULT_MAX_MAP_COUNT;
@@ -463,6 +463,10 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
  */
 void __init mmap_init(void)
 {
+	int ret;
+
+	ret = percpu_counter_init(&vm_committed_as, 0);
+	VM_BUG_ON(ret);
 	vm_region_jar = KMEM_CACHE(vm_region, SLAB_PANIC);
 }
 
@@ -1847,12 +1851,9 @@ int __vm_enough_memory(struct mm_struct 
 	if (mm)
 		allowed -= mm->total_vm / 32;
 
-	/*
-	 * cast `allowed' as a signed long because vm_committed_space
-	 * sometimes has a negative value
-	 */
-	if (atomic_long_read(&vm_committed_space) < (long)allowed)
+	if (percpu_counter_read_positive(&vm_committed_as) < allowed)
 		return 0;
+
 error:
 	vm_unacct_memory(pages);
 
Index: b/mm/swap.c
===================================================================
--- a/mm/swap.c	2009-04-28 11:36:43.000000000 +0900
+++ b/mm/swap.c	2009-04-28 11:36:54.000000000 +0900
@@ -491,49 +491,6 @@ unsigned pagevec_lookup_tag(struct pagev
 
 EXPORT_SYMBOL(pagevec_lookup_tag);
 
-#ifdef CONFIG_SMP
-/*
- * We tolerate a little inaccuracy to avoid ping-ponging the counter between
- * CPUs
- */
-#define ACCT_THRESHOLD	max(16, NR_CPUS * 2)
-
-static DEFINE_PER_CPU(long, committed_space);
-
-void vm_acct_memory(long pages)
-{
-	long *local;
-
-	preempt_disable();
-	local = &__get_cpu_var(committed_space);
-	*local += pages;
-	if (*local > ACCT_THRESHOLD || *local < -ACCT_THRESHOLD) {
-		atomic_long_add(*local, &vm_committed_space);
-		*local = 0;
-	}
-	preempt_enable();
-}
-
-#ifdef CONFIG_HOTPLUG_CPU
-
-/* Drop the CPU's cached committed space back into the central pool. */
-static int cpu_swap_callback(struct notifier_block *nfb,
-			     unsigned long action,
-			     void *hcpu)
-{
-	long *committed;
-
-	committed = &per_cpu(committed_space, (long)hcpu);
-	if (action == CPU_DEAD || action == CPU_DEAD_FROZEN) {
-		atomic_long_add(*committed, &vm_committed_space);
-		*committed = 0;
-		drain_cpu_pagevecs((long)hcpu);
-	}
-	return NOTIFY_OK;
-}
-#endif /* CONFIG_HOTPLUG_CPU */
-#endif /* CONFIG_SMP */
-
 /*
  * Perform any setup for the swap system
  */
@@ -554,7 +511,4 @@ void __init swap_setup(void)
 	 * Right now other parts of the system means that we
 	 * _really_ don't want to cluster much more
 	 */
-#ifdef CONFIG_HOTPLUG_CPU
-	hotcpu_notifier(cpu_swap_callback, 0);
-#endif
 }
Index: b/include/linux/mman.h
===================================================================
--- a/include/linux/mman.h	2009-04-28 11:32:47.000000000 +0900
+++ b/include/linux/mman.h	2009-04-28 11:38:42.000000000 +0900
@@ -12,21 +12,18 @@
 
 #ifdef __KERNEL__
 #include <linux/mm.h>
+#include <linux/percpu_counter.h>
 
 #include <asm/atomic.h>
 
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
-extern atomic_long_t vm_committed_space;
+extern struct percpu_counter vm_committed_as;
 
-#ifdef CONFIG_SMP
-extern void vm_acct_memory(long pages);
-#else
 static inline void vm_acct_memory(long pages)
 {
-	atomic_long_add(pages, &vm_committed_space);
+	percpu_counter_add(&vm_committed_as, pages);
 }
-#endif
 
 static inline void vm_unacct_memory(long pages)
 {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
