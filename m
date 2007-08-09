Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id l79IldIV147512
	for <linux-mm@kvack.org>; Thu, 9 Aug 2007 18:47:39 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l79Ildl52322516
	for <linux-mm@kvack.org>; Thu, 9 Aug 2007 20:47:39 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l79IlcfN022354
	for <linux-mm@kvack.org>; Thu, 9 Aug 2007 20:47:39 +0200
Subject: [patch] move mm_struct and vm_area_struct.
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
Content-Type: text/plain
Date: Thu, 09 Aug 2007 20:51:20 +0200
Message-Id: <1186685480.9669.28.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: hugh@veritas.com, peterz@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,
I've updated the patch that moves mm_struct and vm_area_struct to
include/linux/mm_types.h to 2.6.23-rc2-mm1. The conflicting patch
is gone, could we readd this one to -mm? I will need it for the tlb
flush rework for s390.

--
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.
--
Subject: [PATCH] move mm_struct and vm_area_struct.

From: Martin Schwidefsky <schwidefsky@de.ibm.com>

Move the definitions of struct mm_struct and struct vma_area_struct
to include/mm_types.h. This allows to define more function in
asm/pgtable.h and friends with inline assemblies instead of macros.
Compile tested on i386, powerpc, powerpc64, s390-32, s390-64
and x86_64.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 include/linux/mm.h       |   63 --------------------
 include/linux/mm_types.h |  143 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/sched.h    |   74 ------------------------
 3 files changed, 144 insertions(+), 136 deletions(-)

diff -urpN linux-2.6/include/linux/mm.h linux-2.6-patched/include/linux/mm.h
--- linux-2.6/include/linux/mm.h	2007-08-09 11:00:47.000000000 +0200
+++ linux-2.6-patched/include/linux/mm.h	2007-08-09 11:00:51.000000000 +0200
@@ -51,69 +51,6 @@ extern int sysctl_legacy_va_layout;
  * mmap() functions).
  */
 
-/*
- * This struct defines a memory VMM memory area. There is one of these
- * per VM-area/task.  A VM area is any part of the process virtual memory
- * space that has a special rule for the page-fault handlers (ie a shared
- * library, the executable area etc).
- */
-struct vm_area_struct {
-	struct mm_struct * vm_mm;	/* The address space we belong to. */
-	unsigned long vm_start;		/* Our start address within vm_mm. */
-	unsigned long vm_end;		/* The first byte after our end address
-					   within vm_mm. */
-
-	/* linked list of VM areas per task, sorted by address */
-	struct vm_area_struct *vm_next;
-
-	pgprot_t vm_page_prot;		/* Access permissions of this VMA. */
-	unsigned long vm_flags;		/* Flags, listed below. */
-
-	struct rb_node vm_rb;
-
-	/*
-	 * For areas with an address space and backing store,
-	 * linkage into the address_space->i_mmap prio tree, or
-	 * linkage to the list of like vmas hanging off its node, or
-	 * linkage of vma in the address_space->i_mmap_nonlinear list.
-	 */
-	union {
-		struct {
-			struct list_head list;
-			void *parent;	/* aligns with prio_tree_node parent */
-			struct vm_area_struct *head;
-		} vm_set;
-
-		struct raw_prio_tree_node prio_tree_node;
-	} shared;
-
-	/*
-	 * A file's MAP_PRIVATE vma can be in both i_mmap tree and anon_vma
-	 * list, after a COW of one of the file pages.  A MAP_SHARED vma
-	 * can only be in the i_mmap tree.  An anonymous MAP_PRIVATE, stack
-	 * or brk vma (with NULL file) can only be in an anon_vma list.
-	 */
-	struct list_head anon_vma_node;	/* Serialized by anon_vma->lock */
-	struct anon_vma *anon_vma;	/* Serialized by page_table_lock */
-
-	/* Function pointers to deal with this struct. */
-	struct vm_operations_struct * vm_ops;
-
-	/* Information about our backing store: */
-	unsigned long vm_pgoff;		/* Offset (within vm_file) in PAGE_SIZE
-					   units, *not* PAGE_CACHE_SIZE */
-	struct file * vm_file;		/* File we map to (can be NULL). */
-	void * vm_private_data;		/* was vm_pte (shared mem) */
-	unsigned long vm_truncate_count;/* truncate_count or restart_addr */
-
-#ifndef CONFIG_MMU
-	atomic_t vm_usage;		/* refcount (VMAs shared if !MMU) */
-#endif
-#ifdef CONFIG_NUMA
-	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
-#endif
-};
-
 extern struct kmem_cache *vm_area_cachep;
 
 /*
diff -urpN linux-2.6/include/linux/mm_types.h linux-2.6-patched/include/linux/mm_types.h
--- linux-2.6/include/linux/mm_types.h	2007-08-09 11:00:47.000000000 +0200
+++ linux-2.6-patched/include/linux/mm_types.h	2007-08-09 11:00:51.000000000 +0200
@@ -1,13 +1,25 @@
 #ifndef _LINUX_MM_TYPES_H
 #define _LINUX_MM_TYPES_H
 
+#include <linux/auxvec.h>	/* For AT_VECTOR_SIZE */
 #include <linux/types.h>
 #include <linux/threads.h>
 #include <linux/list.h>
 #include <linux/spinlock.h>
+#include <linux/prio_tree.h>
+#include <linux/rbtree.h>
+#include <linux/rwsem.h>
+#include <linux/completion.h>
+#include <asm/mmu.h>
 
 struct address_space;
 
+#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
+typedef atomic_long_t mm_counter_t;
+#else  /* NR_CPUS < CONFIG_SPLIT_PTLOCK_CPUS */
+typedef unsigned long mm_counter_t;
+#endif /* NR_CPUS < CONFIG_SPLIT_PTLOCK_CPUS */
+
 /*
  * Each physical page in the system has a struct page associated with
  * it to keep track of whatever it is we are using the page for at the
@@ -85,4 +97,135 @@ struct page {
 #endif
 };
 
+/*
+ * This struct defines a memory VMM memory area. There is one of these
+ * per VM-area/task.  A VM area is any part of the process virtual memory
+ * space that has a special rule for the page-fault handlers (ie a shared
+ * library, the executable area etc).
+ */
+struct vm_area_struct {
+	struct mm_struct * vm_mm;	/* The address space we belong to. */
+	unsigned long vm_start;		/* Our start address within vm_mm. */
+	unsigned long vm_end;		/* The first byte after our end address
+					   within vm_mm. */
+
+	/* linked list of VM areas per task, sorted by address */
+	struct vm_area_struct *vm_next;
+
+	pgprot_t vm_page_prot;		/* Access permissions of this VMA. */
+	unsigned long vm_flags;		/* Flags, listed below. */
+
+	struct rb_node vm_rb;
+
+	/*
+	 * For areas with an address space and backing store,
+	 * linkage into the address_space->i_mmap prio tree, or
+	 * linkage to the list of like vmas hanging off its node, or
+	 * linkage of vma in the address_space->i_mmap_nonlinear list.
+	 */
+	union {
+		struct {
+			struct list_head list;
+			void *parent;	/* aligns with prio_tree_node parent */
+			struct vm_area_struct *head;
+		} vm_set;
+
+		struct raw_prio_tree_node prio_tree_node;
+	} shared;
+
+	/*
+	 * A file's MAP_PRIVATE vma can be in both i_mmap tree and anon_vma
+	 * list, after a COW of one of the file pages.	A MAP_SHARED vma
+	 * can only be in the i_mmap tree.  An anonymous MAP_PRIVATE, stack
+	 * or brk vma (with NULL file) can only be in an anon_vma list.
+	 */
+	struct list_head anon_vma_node;	/* Serialized by anon_vma->lock */
+	struct anon_vma *anon_vma;	/* Serialized by page_table_lock */
+
+	/* Function pointers to deal with this struct. */
+	struct vm_operations_struct * vm_ops;
+
+	/* Information about our backing store: */
+	unsigned long vm_pgoff;		/* Offset (within vm_file) in PAGE_SIZE
+					   units, *not* PAGE_CACHE_SIZE */
+	struct file * vm_file;		/* File we map to (can be NULL). */
+	void * vm_private_data;		/* was vm_pte (shared mem) */
+	unsigned long vm_truncate_count;/* truncate_count or restart_addr */
+
+#ifndef CONFIG_MMU
+	atomic_t vm_usage;		/* refcount (VMAs shared if !MMU) */
+#endif
+#ifdef CONFIG_NUMA
+	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
+#endif
+};
+
+struct mm_struct {
+	struct vm_area_struct * mmap;		/* list of VMAs */
+	struct rb_root mm_rb;
+	struct vm_area_struct * mmap_cache;	/* last find_vma result */
+	unsigned long (*get_unmapped_area) (struct file *filp,
+				unsigned long addr, unsigned long len,
+				unsigned long pgoff, unsigned long flags);
+	void (*unmap_area) (struct mm_struct *mm, unsigned long addr);
+	unsigned long mmap_base;		/* base of mmap area */
+	unsigned long task_size;		/* size of task vm space */
+	unsigned long cached_hole_size; 	/* if non-zero, the largest hole below free_area_cache */
+	unsigned long free_area_cache;		/* first hole of size cached_hole_size or larger */
+	pgd_t * pgd;
+	atomic_t mm_users;			/* How many users with user space? */
+	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
+	int map_count;				/* number of VMAs */
+	struct rw_semaphore mmap_sem;
+	spinlock_t page_table_lock;		/* Protects page tables and some counters */
+
+	struct list_head mmlist;		/* List of maybe swapped mm's.	These are globally strung
+						 * together off init_mm.mmlist, and are protected
+						 * by mmlist_lock
+						 */
+
+	/* Special counters, in some configurations protected by the
+	 * page_table_lock, in other configurations by being atomic.
+	 */
+	mm_counter_t _file_rss;
+	mm_counter_t _anon_rss;
+
+	unsigned long hiwater_rss;	/* High-watermark of RSS usage */
+	unsigned long hiwater_vm;	/* High-water virtual memory usage */
+
+	unsigned long total_vm, locked_vm, shared_vm, exec_vm;
+	unsigned long stack_vm, reserved_vm, def_flags, nr_ptes;
+	unsigned long start_code, end_code, start_data, end_data;
+	unsigned long start_brk, brk, start_stack;
+	unsigned long arg_start, arg_end, env_start, env_end;
+
+	unsigned long saved_auxv[AT_VECTOR_SIZE]; /* for /proc/PID/auxv */
+
+	cpumask_t cpu_vm_mask;
+
+	/* Architecture-specific MM context */
+	mm_context_t context;
+
+	/* Swap token stuff */
+	/*
+	 * Last value of global fault stamp as seen by this process.
+	 * In other words, this value gives an indication of how long
+	 * it has been since this task got the token.
+	 * Look at mm/thrash.c
+	 */
+	unsigned int faultstamp;
+	unsigned int token_priority;
+	unsigned int last_interval;
+
+	unsigned long flags; /* Must use atomic bitops to access the bits */
+
+	/* coredumping support */
+	int core_waiters;
+	struct completion *core_startup_done, core_done;
+
+	/* aio bits */
+	rwlock_t		ioctx_list_lock;
+	struct kioctx		*ioctx_list;
+};
+
 #endif /* _LINUX_MM_TYPES_H */
diff -urpN linux-2.6/include/linux/sched.h linux-2.6-patched/include/linux/sched.h
--- linux-2.6/include/linux/sched.h	2007-08-09 11:00:47.000000000 +0200
+++ linux-2.6-patched/include/linux/sched.h	2007-08-09 11:00:51.000000000 +0200
@@ -1,8 +1,6 @@
 #ifndef _LINUX_SCHED_H
 #define _LINUX_SCHED_H
 
-#include <linux/auxvec.h>	/* For AT_VECTOR_SIZE */
-
 /*
  * cloning flags:
  */
@@ -57,12 +55,12 @@ struct sched_param {
 #include <linux/cpumask.h>
 #include <linux/errno.h>
 #include <linux/nodemask.h>
+#include <linux/mm_types.h>
 
 #include <asm/system.h>
 #include <asm/semaphore.h>
 #include <asm/page.h>
 #include <asm/ptrace.h>
-#include <asm/mmu.h>
 #include <asm/cputime.h>
 
 #include <linux/smp.h>
@@ -319,7 +317,6 @@ extern void arch_unmap_area_topdown(stru
 #define add_mm_counter(mm, member, value) atomic_long_add(value, &(mm)->_##member)
 #define inc_mm_counter(mm, member) atomic_long_inc(&(mm)->_##member)
 #define dec_mm_counter(mm, member) atomic_long_dec(&(mm)->_##member)
-typedef atomic_long_t mm_counter_t;
 
 #else  /* NR_CPUS < CONFIG_SPLIT_PTLOCK_CPUS */
 /*
@@ -331,7 +328,6 @@ typedef atomic_long_t mm_counter_t;
 #define add_mm_counter(mm, member, value) (mm)->_##member += (value)
 #define inc_mm_counter(mm, member) (mm)->_##member++
 #define dec_mm_counter(mm, member) (mm)->_##member--
-typedef unsigned long mm_counter_t;
 
 #endif /* NR_CPUS < CONFIG_SPLIT_PTLOCK_CPUS */
 
@@ -369,74 +365,6 @@ extern int get_dumpable(struct mm_struct
 #define MMF_DUMP_FILTER_DEFAULT \
 	((1 << MMF_DUMP_ANON_PRIVATE) |	(1 << MMF_DUMP_ANON_SHARED))
 
-struct mm_struct {
-	struct vm_area_struct * mmap;		/* list of VMAs */
-	struct rb_root mm_rb;
-	struct vm_area_struct * mmap_cache;	/* last find_vma result */
-	unsigned long (*get_unmapped_area) (struct file *filp,
-				unsigned long addr, unsigned long len,
-				unsigned long pgoff, unsigned long flags);
-	void (*unmap_area) (struct mm_struct *mm, unsigned long addr);
-	unsigned long mmap_base;		/* base of mmap area */
-	unsigned long task_size;		/* size of task vm space */
-	unsigned long cached_hole_size;         /* if non-zero, the largest hole below free_area_cache */
-	unsigned long free_area_cache;		/* first hole of size cached_hole_size or larger */
-	pgd_t * pgd;
-	atomic_t mm_users;			/* How many users with user space? */
-	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
-	int map_count;				/* number of VMAs */
-	struct rw_semaphore mmap_sem;
-	spinlock_t page_table_lock;		/* Protects page tables and some counters */
-
-	struct list_head mmlist;		/* List of maybe swapped mm's.  These are globally strung
-						 * together off init_mm.mmlist, and are protected
-						 * by mmlist_lock
-						 */
-
-	/* Special counters, in some configurations protected by the
-	 * page_table_lock, in other configurations by being atomic.
-	 */
-	mm_counter_t _file_rss;
-	mm_counter_t _anon_rss;
-
-	unsigned long hiwater_rss;	/* High-watermark of RSS usage */
-	unsigned long hiwater_vm;	/* High-water virtual memory usage */
-
-	unsigned long total_vm, locked_vm, shared_vm, exec_vm;
-	unsigned long stack_vm, reserved_vm, def_flags, nr_ptes;
-	unsigned long start_code, end_code, start_data, end_data;
-	unsigned long start_brk, brk, start_stack;
-	unsigned long arg_start, arg_end, env_start, env_end;
-
-	unsigned long saved_auxv[AT_VECTOR_SIZE]; /* for /proc/PID/auxv */
-
-	cpumask_t cpu_vm_mask;
-
-	/* Architecture-specific MM context */
-	mm_context_t context;
-
-	/* Swap token stuff */
-	/*
-	 * Last value of global fault stamp as seen by this process.
-	 * In other words, this value gives an indication of how long
-	 * it has been since this task got the token.
-	 * Look at mm/thrash.c
-	 */
-	unsigned int faultstamp;
-	unsigned int token_priority;
-	unsigned int last_interval;
-
-	unsigned long flags; /* Must use atomic bitops to access the bits */
-
-	/* coredumping support */
-	int core_waiters;
-	struct completion *core_startup_done, core_done;
-
-	/* aio bits */
-	rwlock_t		ioctx_list_lock;
-	struct kioctx		*ioctx_list;
-};
-
 struct sighand_struct {
 	atomic_t		count;
 	struct k_sigaction	action[_NSIG];


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
