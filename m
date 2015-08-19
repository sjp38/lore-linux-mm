Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id C4AD96B0038
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 19:08:56 -0400 (EDT)
Received: by igbjg10 with SMTP id jg10so116617805igb.0
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 16:08:56 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y80si1863515iod.160.2015.08.19.16.08.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Aug 2015 16:08:55 -0700 (PDT)
Date: Wed, 19 Aug 2015 16:08:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [linux-next:master 9078/9582]
 arch/arm64/include/asm/pgtable.h:238:0: warning: "HUGE_MAX_HSTATE"
 redefined
Message-Id: <20150819160854.45141f3c7ab91c49939b3578@linux-foundation.org>
In-Reply-To: <20150819143305.fc1fbb979fee6e9b60c59d3c@linux-foundation.org>
References: <201508192138.toXxw84b%fengguang.wu@intel.com>
	<20150819143305.fc1fbb979fee6e9b60c59d3c@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>

On Wed, 19 Aug 2015 14:33:05 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 19 Aug 2015 21:32:40 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
> 
> > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> > head:   dcaa9a3e88c4082096bfed62d9de2d9b6ad9e3d6
> > commit: 878b6f5bcef8de64a5c39b685e785166357bf0dc [9078/9582] mm-hugetlb-proc-add-hugetlbpages-field-to-proc-pid-status-fix-3
> > config: arm64-allmodconfig (attached as .config)
> > reproduce:
> >   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
> >   chmod +x ~/bin/make.cross
> >   git checkout 878b6f5bcef8de64a5c39b685e785166357bf0dc
> >   # save the attached .config to linux build tree
> >   make.cross ARCH=arm64 
> > 
> > All warnings (new ones prefixed by >>):
> > 
> >    In file included from include/linux/mm.h:54:0,
> >                     from arch/arm64/kernel/asm-offsets.c:22:
> > >> arch/arm64/include/asm/pgtable.h:238:0: warning: "HUGE_MAX_HSTATE" redefined
> >     #define HUGE_MAX_HSTATE  2
> >     ^
> >    In file included from include/linux/sched.h:27:0,
> >                     from arch/arm64/kernel/asm-offsets.c:21:
> >    include/linux/mm_types.h:372:0: note: this is the location of the previous definition
> >     #define HUGE_MAX_HSTATE 1
> 
> I've spent far too long trying to come up with a nice fix for this and
> everything I try leads down a path of horror.  Our include files are a
> big mess.

This might help a bit.  Talk about making a rod for my own back :(

This patch will need to be kept in -next for a cycle (and I might end
up burning it), so don't depend on it when fixing the above.


From: Andrew Morton <akpm@linux-foundation.org>
Subject: sched.h: don't include mm_types.h

An attempt to untangle some of our include file mess.

sched.h presently needs the definition of mm_struct and some other mm
types (page_frag, mm_rss_stat, ...).  This ends up causing various
circular dependencies.

The patch removes the mm_struct requirement from sched.h.  All sched.h
inlines etc which referred to the mm_struct are moved elsewhere, mainly
into mm.h.

This change will break .c files which were depending on sched.h's
inclusion of mm_types.h.  They should include mm_types.h directly.

The overall approach to fixing up the inevitable fallout was to create
small, single-purpose finer grained header files:

include/linux/mm-flags.h: coredump filtering flags
include/linux/page_frag.h: the page_frag infrastructure
include/linux/mm-config.h: magic cpp calculations specific to MM
include/linux/mm-rss.h: RSS structs and defines

Cc: Ingo Molnar <mingo@elte.hu>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/gpu/drm/amd/amdkfd/kfd_process.c |    1 
 fs/binfmt_elf.c                          |    1 
 fs/binfmt_elf_fdpic.c                    |    1 
 fs/exec.c                                |    1 
 fs/proc/base.c                           |    1 
 include/linux/khugepaged.h               |    2 
 include/linux/ksm.h                      |    1 
 include/linux/mm-config.h                |   18 +++
 include/linux/mm-flags.h                 |   48 ++++++++
 include/linux/mm-rss.h                   |   17 ++
 include/linux/mm.h                       |   67 +++++++++++
 include/linux/mm_types.h                 |   57 ---------
 include/linux/page_frag.h                |   39 ++++++
 include/linux/sched.h                    |  122 ++-------------------
 include/linux/threads.h                  |    4 
 kernel/events/uprobes.c                  |    2 
 kernel/fork.c                            |    1 
 kernel/ptrace.c                          |    1 
 kernel/sys.c                             |    1 
 kernel/user_namespace.c                  |    1 
 lib/is_single_threaded.c                 |    1 
 mm/huge_memory.c                         |    1 
 mm/ksm.c                                 |    1 
 23 files changed, 220 insertions(+), 169 deletions(-)

diff -puN include/linux/sched.h~a include/linux/sched.h
--- a/include/linux/sched.h~a
+++ a/include/linux/sched.h
@@ -22,10 +22,12 @@ struct sched_param {
 #include <linux/rbtree.h>
 #include <linux/thread_info.h>
 #include <linux/cpumask.h>
+#include <linux/mm-config.h>
+#include <linux/mm-rss.h>
 #include <linux/errno.h>
 #include <linux/nodemask.h>
-#include <linux/mm_types.h>
 #include <linux/preempt.h>
+#include <linux/page_frag.h>
 
 #include <asm/page.h>
 #include <asm/ptrace.h>
@@ -134,6 +136,7 @@ struct perf_event_context;
 struct blk_plug;
 struct filename;
 struct nameidata;
+struct mm_struct;
 
 #define VMACACHE_BITS 2
 #define VMACACHE_SIZE (1U << VMACACHE_BITS)
@@ -435,78 +438,6 @@ static inline void io_schedule(void)
 struct nsproxy;
 struct user_namespace;
 
-#ifdef CONFIG_MMU
-extern void arch_pick_mmap_layout(struct mm_struct *mm);
-extern unsigned long
-arch_get_unmapped_area(struct file *, unsigned long, unsigned long,
-		       unsigned long, unsigned long);
-extern unsigned long
-arch_get_unmapped_area_topdown(struct file *filp, unsigned long addr,
-			  unsigned long len, unsigned long pgoff,
-			  unsigned long flags);
-#else
-static inline void arch_pick_mmap_layout(struct mm_struct *mm) {}
-#endif
-
-#define SUID_DUMP_DISABLE	0	/* No setuid dumping */
-#define SUID_DUMP_USER		1	/* Dump as user of process */
-#define SUID_DUMP_ROOT		2	/* Dump as root */
-
-/* mm flags */
-
-/* for SUID_DUMP_* above */
-#define MMF_DUMPABLE_BITS 2
-#define MMF_DUMPABLE_MASK ((1 << MMF_DUMPABLE_BITS) - 1)
-
-extern void set_dumpable(struct mm_struct *mm, int value);
-/*
- * This returns the actual value of the suid_dumpable flag. For things
- * that are using this for checking for privilege transitions, it must
- * test against SUID_DUMP_USER rather than treating it as a boolean
- * value.
- */
-static inline int __get_dumpable(unsigned long mm_flags)
-{
-	return mm_flags & MMF_DUMPABLE_MASK;
-}
-
-static inline int get_dumpable(struct mm_struct *mm)
-{
-	return __get_dumpable(mm->flags);
-}
-
-/* coredump filter bits */
-#define MMF_DUMP_ANON_PRIVATE	2
-#define MMF_DUMP_ANON_SHARED	3
-#define MMF_DUMP_MAPPED_PRIVATE	4
-#define MMF_DUMP_MAPPED_SHARED	5
-#define MMF_DUMP_ELF_HEADERS	6
-#define MMF_DUMP_HUGETLB_PRIVATE 7
-#define MMF_DUMP_HUGETLB_SHARED  8
-
-#define MMF_DUMP_FILTER_SHIFT	MMF_DUMPABLE_BITS
-#define MMF_DUMP_FILTER_BITS	7
-#define MMF_DUMP_FILTER_MASK \
-	(((1 << MMF_DUMP_FILTER_BITS) - 1) << MMF_DUMP_FILTER_SHIFT)
-#define MMF_DUMP_FILTER_DEFAULT \
-	((1 << MMF_DUMP_ANON_PRIVATE) |	(1 << MMF_DUMP_ANON_SHARED) |\
-	 (1 << MMF_DUMP_HUGETLB_PRIVATE) | MMF_DUMP_MASK_DEFAULT_ELF)
-
-#ifdef CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS
-# define MMF_DUMP_MASK_DEFAULT_ELF	(1 << MMF_DUMP_ELF_HEADERS)
-#else
-# define MMF_DUMP_MASK_DEFAULT_ELF	0
-#endif
-					/* leave room for more dump flags */
-#define MMF_VM_MERGEABLE	16	/* KSM may merge identical pages */
-#define MMF_VM_HUGEPAGE		17	/* set when VM_HUGEPAGE is set on vma */
-#define MMF_EXE_FILE_CHANGED	18	/* see prctl_set_mm_exe_file() */
-
-#define MMF_HAS_UPROBES		19	/* has uprobes */
-#define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
-
-#define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
-
 struct sighand_struct {
 	atomic_t		count;
 	struct k_sigaction	action[_NSIG];
@@ -1360,6 +1291,14 @@ struct tlbflush_unmap_batch {
 	bool writable;
 };
 
+#ifdef SPLIT_RSS_COUNTING
+/* per-thread cached information, */
+struct task_rss_stat {
+	int events;	/* for synchronization threshold */
+	int count[NR_MM_COUNTERS];
+};
+#endif /* USE_SPLIT_PTE_PTLOCKS */
+
 struct task_struct {
 	volatile long state;	/* -1 unrunnable, 0 runnable, >0 stopped */
 	void *stack;
@@ -2408,9 +2347,6 @@ static inline int kstack_end(void *addr)
 
 extern union thread_union init_thread_union;
 extern struct task_struct init_task;
-
-extern struct   mm_struct init_mm;
-
 extern struct pid_namespace init_pid_ns;
 
 /*
@@ -2551,32 +2487,6 @@ static inline unsigned long sigsp(unsign
 	return sp;
 }
 
-/*
- * Routines for handling mm_structs
- */
-extern struct mm_struct * mm_alloc(void);
-
-/* mmdrop drops the mm and the page tables */
-extern void __mmdrop(struct mm_struct *);
-static inline void mmdrop(struct mm_struct * mm)
-{
-	if (unlikely(atomic_dec_and_test(&mm->mm_count)))
-		__mmdrop(mm);
-}
-
-/* mmput gets rid of the mappings and all user-space */
-extern void mmput(struct mm_struct *);
-/* Grab a reference to a task's mm, if it is not already going away */
-extern struct mm_struct *get_task_mm(struct task_struct *task);
-/*
- * Grab a reference to a task's mm, if it is not already going away
- * and ptrace_may_access with the mode parameter passed to it
- * succeeds.
- */
-extern struct mm_struct *mm_access(struct task_struct *task, unsigned int mode);
-/* Remove the current tasks stale references to the old mm_struct */
-extern void mm_release(struct task_struct *, struct mm_struct *);
-
 #ifdef CONFIG_HAVE_COPY_THREAD_TLS
 extern int copy_thread_tls(unsigned long, unsigned long, unsigned long,
 			struct task_struct *, unsigned long);
@@ -3150,14 +3060,6 @@ static inline void inc_syscw(struct task
 #define TASK_SIZE_OF(tsk)	TASK_SIZE
 #endif
 
-#ifdef CONFIG_MEMCG
-extern void mm_update_next_owner(struct mm_struct *mm);
-#else
-static inline void mm_update_next_owner(struct mm_struct *mm)
-{
-}
-#endif /* CONFIG_MEMCG */
-
 static inline unsigned long task_rlimit(const struct task_struct *tsk,
 		unsigned int limit)
 {
diff -puN include/linux/mm.h~a include/linux/mm.h
--- a/include/linux/mm.h~a
+++ a/include/linux/mm.h
@@ -14,6 +14,7 @@
 #include <linux/atomic.h>
 #include <linux/debug_locks.h>
 #include <linux/mm_types.h>
+#include <linux/mm-flags.h>
 #include <linux/range.h>
 #include <linux/pfn.h>
 #include <linux/bit_spinlock.h>
@@ -2260,5 +2261,71 @@ void __init setup_nr_node_ids(void);
 static inline void setup_nr_node_ids(void) {}
 #endif
 
+#ifdef CONFIG_MMU
+extern void arch_pick_mmap_layout(struct mm_struct *mm);
+extern unsigned long
+arch_get_unmapped_area(struct file *, unsigned long, unsigned long,
+		       unsigned long, unsigned long);
+extern unsigned long
+arch_get_unmapped_area_topdown(struct file *filp, unsigned long addr,
+			  unsigned long len, unsigned long pgoff,
+			  unsigned long flags);
+#else
+static inline void arch_pick_mmap_layout(struct mm_struct *mm) {}
+#endif
+
+extern struct mm_struct init_mm;
+
+/*
+ * Routines for handling mm_structs
+ */
+extern struct mm_struct * mm_alloc(void);
+
+/* mmdrop drops the mm and the page tables */
+extern void __mmdrop(struct mm_struct *);
+static inline void mmdrop(struct mm_struct * mm)
+{
+	if (unlikely(atomic_dec_and_test(&mm->mm_count)))
+		__mmdrop(mm);
+}
+
+/* mmput gets rid of the mappings and all user-space */
+extern void mmput(struct mm_struct *);
+/* Grab a reference to a task's mm, if it is not already going away */
+extern struct mm_struct *get_task_mm(struct task_struct *task);
+/*
+ * Grab a reference to a task's mm, if it is not already going away
+ * and ptrace_may_access with the mode parameter passed to it
+ * succeeds.
+ */
+extern struct mm_struct *mm_access(struct task_struct *task, unsigned int mode);
+/* Remove the current tasks stale references to the old mm_struct */
+extern void mm_release(struct task_struct *, struct mm_struct *);
+
+#ifdef CONFIG_MEMCG
+extern void mm_update_next_owner(struct mm_struct *mm);
+#else
+static inline void mm_update_next_owner(struct mm_struct *mm)
+{
+}
+#endif /* CONFIG_MEMCG */
+
+extern void set_dumpable(struct mm_struct *mm, int value);
+/*
+ * This returns the actual value of the suid_dumpable flag. For things
+ * that are using this for checking for privilege transitions, it must
+ * test against SUID_DUMP_USER rather than treating it as a boolean
+ * value.
+ */
+static inline int __get_dumpable(unsigned long mm_flags)
+{
+	return mm_flags & MMF_DUMPABLE_MASK;
+}
+
+static inline int get_dumpable(struct mm_struct *mm)
+{
+	return __get_dumpable(mm->flags);
+}
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff -puN include/linux/mm_types.h~a include/linux/mm_types.h
--- a/include/linux/mm_types.h~a
+++ a/include/linux/mm_types.h
@@ -7,7 +7,10 @@
 #include <linux/list.h>
 #include <linux/spinlock.h>
 #include <linux/rbtree.h>
+#include <linux/mm-config.h>
+#include <linux/mm-rss.h>
 #include <linux/rwsem.h>
+#include <linux/mm-config.h>
 #include <linux/completion.h>
 #include <linux/cpumask.h>
 #include <linux/uprobes.h>
@@ -23,11 +26,6 @@
 struct address_space;
 struct mem_cgroup;
 
-#define USE_SPLIT_PTE_PTLOCKS	(NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS)
-#define USE_SPLIT_PMD_PTLOCKS	(USE_SPLIT_PTE_PTLOCKS && \
-		IS_ENABLED(CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK))
-#define ALLOC_SPLIT_PTLOCKS	(SPINLOCK_SIZE > BITS_PER_LONG/8)
-
 typedef void compound_page_dtor(struct page *);
 
 /*
@@ -206,35 +204,6 @@ struct page {
 #endif
 ;
 
-struct page_frag {
-	struct page *page;
-#if (BITS_PER_LONG > 32) || (PAGE_SIZE >= 65536)
-	__u32 offset;
-	__u32 size;
-#else
-	__u16 offset;
-	__u16 size;
-#endif
-};
-
-#define PAGE_FRAG_CACHE_MAX_SIZE	__ALIGN_MASK(32768, ~PAGE_MASK)
-#define PAGE_FRAG_CACHE_MAX_ORDER	get_order(PAGE_FRAG_CACHE_MAX_SIZE)
-
-struct page_frag_cache {
-	void * va;
-#if (PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
-	__u16 offset;
-	__u16 size;
-#else
-	__u32 offset;
-#endif
-	/* we maintain a pagecount bias, so that we dont dirty cache line
-	 * containing page->_count every time we allocate a fragment.
-	 */
-	unsigned int		pagecnt_bias;
-	bool pfmemalloc;
-};
-
 typedef unsigned long vm_flags_t;
 
 /*
@@ -346,26 +315,6 @@ struct core_state {
 	struct completion startup;
 };
 
-enum {
-	MM_FILEPAGES,
-	MM_ANONPAGES,
-	MM_SWAPENTS,
-	NR_MM_COUNTERS
-};
-
-#if USE_SPLIT_PTE_PTLOCKS && defined(CONFIG_MMU)
-#define SPLIT_RSS_COUNTING
-/* per-thread cached information, */
-struct task_rss_stat {
-	int events;	/* for synchronization threshold */
-	int count[NR_MM_COUNTERS];
-};
-#endif /* USE_SPLIT_PTE_PTLOCKS */
-
-struct mm_rss_stat {
-	atomic_long_t count[NR_MM_COUNTERS];
-};
-
 #ifdef CONFIG_HUGETLB_PAGE
 
 #ifndef HUGE_MAX_HSTATE
diff -puN /dev/null include/linux/mm-flags.h
--- /dev/null
+++ a/include/linux/mm-flags.h
@@ -0,0 +1,48 @@
+#ifndef MM_FLAGS_H_INCLUDED
+#define MM_FLAGS_H_INCLUDED
+
+#include <linux/mm_types.h>
+
+/* mm flags */
+
+#define SUID_DUMP_DISABLE	0	/* No setuid dumping */
+#define SUID_DUMP_USER		1	/* Dump as user of process */
+#define SUID_DUMP_ROOT		2	/* Dump as root */
+
+/* for SUID_DUMP_* above */
+#define MMF_DUMPABLE_BITS 2
+#define MMF_DUMPABLE_MASK ((1 << MMF_DUMPABLE_BITS) - 1)
+
+/* coredump filter bits */
+#define MMF_DUMP_ANON_PRIVATE	2
+#define MMF_DUMP_ANON_SHARED	3
+#define MMF_DUMP_MAPPED_PRIVATE	4
+#define MMF_DUMP_MAPPED_SHARED	5
+#define MMF_DUMP_ELF_HEADERS	6
+#define MMF_DUMP_HUGETLB_PRIVATE 7
+#define MMF_DUMP_HUGETLB_SHARED  8
+
+#define MMF_DUMP_FILTER_SHIFT	MMF_DUMPABLE_BITS
+#define MMF_DUMP_FILTER_BITS	7
+#define MMF_DUMP_FILTER_MASK \
+	(((1 << MMF_DUMP_FILTER_BITS) - 1) << MMF_DUMP_FILTER_SHIFT)
+#define MMF_DUMP_FILTER_DEFAULT \
+	((1 << MMF_DUMP_ANON_PRIVATE) |	(1 << MMF_DUMP_ANON_SHARED) |\
+	 (1 << MMF_DUMP_HUGETLB_PRIVATE) | MMF_DUMP_MASK_DEFAULT_ELF)
+
+#ifdef CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS
+# define MMF_DUMP_MASK_DEFAULT_ELF	(1 << MMF_DUMP_ELF_HEADERS)
+#else
+# define MMF_DUMP_MASK_DEFAULT_ELF	0
+#endif
+					/* leave room for more dump flags */
+#define MMF_VM_MERGEABLE	16	/* KSM may merge identical pages */
+#define MMF_VM_HUGEPAGE		17	/* set when VM_HUGEPAGE is set on vma */
+#define MMF_EXE_FILE_CHANGED	18	/* see prctl_set_mm_exe_file() */
+
+#define MMF_HAS_UPROBES		19	/* has uprobes */
+#define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
+
+#define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
+
+#endif		/* MM_FLAGS_H_INCLUDED */
diff -puN fs/binfmt_elf.c~a fs/binfmt_elf.c
--- a/fs/binfmt_elf.c~a
+++ a/fs/binfmt_elf.c
@@ -13,6 +13,7 @@
 #include <linux/kernel.h>
 #include <linux/fs.h>
 #include <linux/mm.h>
+#include <linux/mm-flags.h>
 #include <linux/mman.h>
 #include <linux/errno.h>
 #include <linux/signal.h>
diff -puN fs/binfmt_elf_fdpic.c~a fs/binfmt_elf_fdpic.c
--- a/fs/binfmt_elf_fdpic.c~a
+++ a/fs/binfmt_elf_fdpic.c
@@ -16,6 +16,7 @@
 #include <linux/stat.h>
 #include <linux/sched.h>
 #include <linux/mm.h>
+#include <linux/mm-flags.h>
 #include <linux/mman.h>
 #include <linux/errno.h>
 #include <linux/signal.h>
diff -puN kernel/fork.c~a kernel/fork.c
--- a/kernel/fork.c~a
+++ a/kernel/fork.c
@@ -29,6 +29,7 @@
 #include <linux/mmu_notifier.h>
 #include <linux/fs.h>
 #include <linux/mm.h>
+#include <linux/mm-flags.h>
 #include <linux/vmacache.h>
 #include <linux/nsproxy.h>
 #include <linux/capability.h>
diff -puN kernel/sys.c~a kernel/sys.c
--- a/kernel/sys.c~a
+++ a/kernel/sys.c
@@ -6,6 +6,7 @@
 
 #include <linux/export.h>
 #include <linux/mm.h>
+#include <linux/mm-flags.h>
 #include <linux/utsname.h>
 #include <linux/mman.h>
 #include <linux/reboot.h>
diff -puN mm/huge_memory.c~a mm/huge_memory.c
--- a/mm/huge_memory.c~a
+++ a/mm/huge_memory.c
@@ -8,6 +8,7 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/mm.h>
+#include <linux/mm-flags.h>
 #include <linux/sched.h>
 #include <linux/highmem.h>
 #include <linux/hugetlb.h>
diff -puN mm/ksm.c~a mm/ksm.c
--- a/mm/ksm.c~a
+++ a/mm/ksm.c
@@ -16,6 +16,7 @@
 
 #include <linux/errno.h>
 #include <linux/mm.h>
+#include <linux/mm-flags.h>
 #include <linux/fs.h>
 #include <linux/mman.h>
 #include <linux/sched.h>
diff -puN include/linux/khugepaged.h~a include/linux/khugepaged.h
--- a/include/linux/khugepaged.h~a
+++ a/include/linux/khugepaged.h
@@ -1,7 +1,7 @@
 #ifndef _LINUX_KHUGEPAGED_H
 #define _LINUX_KHUGEPAGED_H
 
-#include <linux/sched.h> /* MMF_VM_HUGEPAGE */
+#include <linux/mm-flags.h> /* MMF_VM_HUGEPAGE */
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 extern int __khugepaged_enter(struct mm_struct *mm);
diff -puN include/linux/ksm.h~a include/linux/ksm.h
--- a/include/linux/ksm.h~a
+++ a/include/linux/ksm.h
@@ -9,6 +9,7 @@
 
 #include <linux/bitops.h>
 #include <linux/mm.h>
+#include <linux/mm-flags.h>
 #include <linux/pagemap.h>
 #include <linux/rmap.h>
 #include <linux/sched.h>
diff -puN fs/exec.c~a fs/exec.c
--- a/fs/exec.c~a
+++ a/fs/exec.c
@@ -26,6 +26,7 @@
 #include <linux/file.h>
 #include <linux/fdtable.h>
 #include <linux/mm.h>
+#include <linux/mm-flags.h>
 #include <linux/vmacache.h>
 #include <linux/stat.h>
 #include <linux/fcntl.h>
diff -puN fs/proc/base.c~a fs/proc/base.c
--- a/fs/proc/base.c~a
+++ a/fs/proc/base.c
@@ -63,6 +63,7 @@
 #include <linux/namei.h>
 #include <linux/mnt_namespace.h>
 #include <linux/mm.h>
+#include <linux/mm-flags.h>
 #include <linux/swap.h>
 #include <linux/rcupdate.h>
 #include <linux/kallsyms.h>
diff -puN kernel/events/uprobes.c~a kernel/events/uprobes.c
--- a/kernel/events/uprobes.c~a
+++ a/kernel/events/uprobes.c
@@ -27,6 +27,8 @@
 #include <linux/pagemap.h>	/* read_mapping_page */
 #include <linux/slab.h>
 #include <linux/sched.h>
+#include <linux/mm.h>
+#include <linux/mm-flags.h>
 #include <linux/export.h>
 #include <linux/rmap.h>		/* anon_vma_prepare */
 #include <linux/mmu_notifier.h>	/* set_pte_at_notify */
diff -puN /dev/null include/linux/page_frag.h
--- /dev/null
+++ a/include/linux/page_frag.h
@@ -0,0 +1,39 @@
+#ifndef PAGE_FRAG_H_INCLUDED
+#define PAGE_FRAG_H_INCLUDED
+
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <asm-generic/getorder.h>
+
+struct page;
+
+struct page_frag {
+	struct page *page;
+#if (BITS_PER_LONG > 32) || (PAGE_SIZE >= 65536)
+	__u32 offset;
+	__u32 size;
+#else
+	__u16 offset;
+	__u16 size;
+#endif
+};
+
+#define PAGE_FRAG_CACHE_MAX_SIZE	__ALIGN_MASK(32768, ~PAGE_MASK)
+#define PAGE_FRAG_CACHE_MAX_ORDER	get_order(PAGE_FRAG_CACHE_MAX_SIZE)
+
+struct page_frag_cache {
+	void * va;
+#if (PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
+	__u16 offset;
+	__u16 size;
+#else
+	__u32 offset;
+#endif
+	/* we maintain a pagecount bias, so that we dont dirty cache line
+	 * containing page->_count every time we allocate a fragment.
+	 */
+	unsigned int		pagecnt_bias;
+	bool pfmemalloc;
+};
+
+#endif		/* PAGE_FRAG_H_INCLUDED */
diff -puN /dev/null include/linux/mm-config.h
--- /dev/null
+++ a/include/linux/mm-config.h
@@ -0,0 +1,18 @@
+#ifndef LINUX_MM_CONFIG_H_INCLUDED
+#define LINUX_MM_CONFIG_H_INCLUDED
+
+/*
+ * mm-config.h is the place where new mm-related #defines are calculated from
+ * Kconfig variables.  And related activities, perhaps.
+ */
+
+#define USE_SPLIT_PTE_PTLOCKS	(CONFIG_NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS)
+#define USE_SPLIT_PMD_PTLOCKS	(USE_SPLIT_PTE_PTLOCKS && \
+		IS_ENABLED(CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK))
+#define ALLOC_SPLIT_PTLOCKS	(SPINLOCK_SIZE > BITS_PER_LONG/8)
+
+#if USE_SPLIT_PTE_PTLOCKS && defined(CONFIG_MMU)
+#define SPLIT_RSS_COUNTING
+#endif
+
+#endif		/* LINUX_MM_CONFIG_H_INCLUDED */
diff -puN include/linux/threads.h~a include/linux/threads.h
--- a/include/linux/threads.h~a
+++ a/include/linux/threads.h
@@ -11,10 +11,6 @@
  * Maximum supported processors.  Setting this smaller saves quite a
  * bit of memory.  Use nr_cpu_ids instead of this except for static bitmaps.
  */
-#ifndef CONFIG_NR_CPUS
-/* FIXME: This should be fixed in the arch's Kconfig */
-#define CONFIG_NR_CPUS	1
-#endif
 
 /* Places which use this should consider cpumask_var_t. */
 #define NR_CPUS		CONFIG_NR_CPUS
diff -puN kernel/ptrace.c~a kernel/ptrace.c
--- a/kernel/ptrace.c~a
+++ a/kernel/ptrace.c
@@ -12,6 +12,7 @@
 #include <linux/sched.h>
 #include <linux/errno.h>
 #include <linux/mm.h>
+#include <linux/mm-flags.h>
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
 #include <linux/ptrace.h>
diff -puN kernel/cred.c~a kernel/cred.c
diff -puN /dev/null include/linux/mm-rss.h
--- /dev/null
+++ a/include/linux/mm-rss.h
@@ -0,0 +1,17 @@
+#ifndef MM_RSS_H_INCLUDED
+#define MM_RSS_H_INCLUDED
+
+#include <asm-generic/atomic-long.h>
+
+enum {
+	MM_FILEPAGES,
+	MM_ANONPAGES,
+	MM_SWAPENTS,
+	NR_MM_COUNTERS
+};
+
+struct mm_rss_stat {
+	atomic_long_t count[NR_MM_COUNTERS];
+};
+
+#endif		/* MM_RSS_H_INCLUDED */
diff -puN kernel/user_namespace.c~a kernel/user_namespace.c
--- a/kernel/user_namespace.c~a
+++ a/kernel/user_namespace.c
@@ -14,6 +14,7 @@
 #include <linux/cred.h>
 #include <linux/securebits.h>
 #include <linux/keyctl.h>
+#include <linux/mm_types.h>
 #include <linux/key-type.h>
 #include <keys/user-type.h>
 #include <linux/seq_file.h>
diff -puN lib/is_single_threaded.c~a lib/is_single_threaded.c
--- a/lib/is_single_threaded.c~a
+++ a/lib/is_single_threaded.c
@@ -11,6 +11,7 @@
  */
 
 #include <linux/sched.h>
+#include <linux/mm_types.h>
 
 /*
  * Returns true if the task does not share ->mm with another thread/process.
diff -puN drivers/gpu/drm/amd/amdkfd/kfd_process.c~a drivers/gpu/drm/amd/amdkfd/kfd_process.c
--- a/drivers/gpu/drm/amd/amdkfd/kfd_process.c~a
+++ a/drivers/gpu/drm/amd/amdkfd/kfd_process.c
@@ -23,6 +23,7 @@
 #include <linux/mutex.h>
 #include <linux/log2.h>
 #include <linux/sched.h>
+#include <linux/mm.h>
 #include <linux/slab.h>
 #include <linux/amd-iommu.h>
 #include <linux/notifier.h>
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
