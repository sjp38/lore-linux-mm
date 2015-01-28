Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id A61576B0032
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 08:24:08 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so25514452pab.12
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 05:24:08 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id w5si5749184pbz.124.2015.01.28.05.24.07
        for <linux-mm@kvack.org>;
        Wed, 28 Jan 2015 05:24:07 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/4] mm: split up mm_struct to separate header file
Date: Wed, 28 Jan 2015 15:17:42 +0200
Message-Id: <1422451064-109023-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1422451064-109023-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1422451064-109023-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We want to use __PAGETABLE_PMD_FOLDED in mm_struct to drop nr_pmds if
pmd is folded. __PAGETABLE_PMD_FOLDED is defined in <asm/pgtable.h>, but
<asm/pgtable.h> itself wants <linux/mm_types.h> for struct page
definition.

This patch move mm_struct definition into separate header file in order
to fix circular header dependencies.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/arm64/kernel/efi.c            |   1 +
 arch/c6x/kernel/dma.c              |   1 -
 arch/s390/include/asm/pgtable.h    |   1 +
 arch/x86/include/asm/mmu_context.h |   1 +
 arch/x86/include/asm/pgtable.h     |  15 +--
 drivers/iommu/amd_iommu_v2.c       |   1 +
 drivers/staging/android/ion/ion.c  |   1 -
 include/linux/mm.h                 |   1 +
 include/linux/mm_struct.h          | 214 ++++++++++++++++++++++++++++++++++++
 include/linux/mm_types.h           | 218 ++-----------------------------------
 include/linux/mmu_notifier.h       |   1 +
 include/linux/sched.h              |   1 +
 mm/init-mm.c                       |   1 +
 mm/kmemcheck.c                     |   1 -
 14 files changed, 232 insertions(+), 226 deletions(-)
 create mode 100644 include/linux/mm_struct.h

diff --git a/arch/arm64/kernel/efi.c b/arch/arm64/kernel/efi.c
index b42c7b480e1e..fbf0a6d6f691 100644
--- a/arch/arm64/kernel/efi.c
+++ b/arch/arm64/kernel/efi.c
@@ -17,6 +17,7 @@
 #include <linux/export.h>
 #include <linux/memblock.h>
 #include <linux/mm_types.h>
+#include <linux/mm_struct.h>
 #include <linux/bootmem.h>
 #include <linux/of.h>
 #include <linux/of_fdt.h>
diff --git a/arch/c6x/kernel/dma.c b/arch/c6x/kernel/dma.c
index ab7b12de144d..5a489f1eabbd 100644
--- a/arch/c6x/kernel/dma.c
+++ b/arch/c6x/kernel/dma.c
@@ -9,7 +9,6 @@
 #include <linux/module.h>
 #include <linux/dma-mapping.h>
 #include <linux/mm.h>
-#include <linux/mm_types.h>
 #include <linux/scatterlist.h>
 
 #include <asm/cacheflush.h>
diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index fbb5ee3ae57c..578eb098b1be 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -29,6 +29,7 @@
 #ifndef __ASSEMBLY__
 #include <linux/sched.h>
 #include <linux/mm_types.h>
+#include <linux/mm_struct.h>
 #include <linux/page-flags.h>
 #include <linux/radix-tree.h>
 #include <asm/bug.h>
diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 4b75d591eb5e..78a87a30ec50 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -4,6 +4,7 @@
 #include <asm/desc.h>
 #include <linux/atomic.h>
 #include <linux/mm_types.h>
+#include <linux/mm_struct.h>
 
 #include <trace/events/tlb.h>
 
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 9d0ade00923e..594d09d07bb4 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -445,18 +445,9 @@ static inline int pte_present(pte_t a)
 	return pte_flags(a) & (_PAGE_PRESENT | _PAGE_PROTNONE);
 }
 
-#define pte_accessible pte_accessible
-static inline bool pte_accessible(struct mm_struct *mm, pte_t a)
-{
-	if (pte_flags(a) & _PAGE_PRESENT)
-		return true;
-
-	if ((pte_flags(a) & _PAGE_PROTNONE) &&
-			mm_tlb_flush_pending(mm))
-		return true;
-
-	return false;
-}
+#define pte_accessible(mm, pte) \
+	(pte_flags(pte) & _PAGE_PRESENT) || \
+	((pte_flags(pte) & _PAGE_PROTNONE) && mm_tlb_flush_pending(mm))
 
 static inline int pte_hidden(pte_t pte)
 {
diff --git a/drivers/iommu/amd_iommu_v2.c b/drivers/iommu/amd_iommu_v2.c
index 90f70d0e1141..d49cd95eaf7b 100644
--- a/drivers/iommu/amd_iommu_v2.c
+++ b/drivers/iommu/amd_iommu_v2.c
@@ -19,6 +19,7 @@
 #include <linux/mmu_notifier.h>
 #include <linux/amd-iommu.h>
 #include <linux/mm_types.h>
+#include <linux/mm_struct.h>
 #include <linux/profile.h>
 #include <linux/module.h>
 #include <linux/sched.h>
diff --git a/drivers/staging/android/ion/ion.c b/drivers/staging/android/ion/ion.c
index b8f1c491553e..1cb3c88f6423 100644
--- a/drivers/staging/android/ion/ion.c
+++ b/drivers/staging/android/ion/ion.c
@@ -27,7 +27,6 @@
 #include <linux/miscdevice.h>
 #include <linux/export.h>
 #include <linux/mm.h>
-#include <linux/mm_types.h>
 #include <linux/rbtree.h>
 #include <linux/slab.h>
 #include <linux/seq_file.h>
diff --git a/include/linux/mm.h b/include/linux/mm.h
index b976d9ffbcd6..543e9723d441 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -14,6 +14,7 @@
 #include <linux/atomic.h>
 #include <linux/debug_locks.h>
 #include <linux/mm_types.h>
+#include <linux/mm_struct.h>
 #include <linux/range.h>
 #include <linux/pfn.h>
 #include <linux/bit_spinlock.h>
diff --git a/include/linux/mm_struct.h b/include/linux/mm_struct.h
new file mode 100644
index 000000000000..0a233c232a39
--- /dev/null
+++ b/include/linux/mm_struct.h
@@ -0,0 +1,214 @@
+#ifndef _LINUX_MM_STRUCT_H
+#define _LINUX_MM_STRUCT_H
+
+#include <linux/auxvec.h>
+#include <linux/rbtree.h>
+#include <linux/rwsem.h>
+#include <linux/types.h>
+#include <linux/uprobes.h>
+
+#include <asm/mmu.h>
+
+struct kioctx_table;
+struct vm_area_struct;
+
+#ifndef AT_VECTOR_SIZE_ARCH
+#define AT_VECTOR_SIZE_ARCH 0
+#endif
+#define AT_VECTOR_SIZE (2*(AT_VECTOR_SIZE_ARCH + AT_VECTOR_SIZE_BASE + 1))
+
+enum {
+	MM_FILEPAGES,
+	MM_ANONPAGES,
+	MM_SWAPENTS,
+	NR_MM_COUNTERS
+};
+
+#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS && defined(CONFIG_MMU)
+#define SPLIT_RSS_COUNTING
+/* per-thread cached information, */
+struct task_rss_stat {
+	int events;	/* for synchronization threshold */
+	int count[NR_MM_COUNTERS];
+};
+#endif /* USE_SPLIT_PTE_PTLOCKS */
+
+struct mm_rss_stat {
+	atomic_long_t count[NR_MM_COUNTERS];
+};
+
+struct mm_struct {
+	struct vm_area_struct *mmap;		/* list of VMAs */
+	struct rb_root mm_rb;
+	u32 vmacache_seqnum;                   /* per-thread vmacache */
+#ifdef CONFIG_MMU
+	unsigned long (*get_unmapped_area) (struct file *filp,
+				unsigned long addr, unsigned long len,
+				unsigned long pgoff, unsigned long flags);
+#endif
+	unsigned long mmap_base;		/* base of mmap area */
+	unsigned long mmap_legacy_base;         /* base of mmap area in bottom-up allocations */
+	unsigned long task_size;		/* size of task vm space */
+	unsigned long highest_vm_end;		/* highest vma end address */
+	pgd_t * pgd;
+	atomic_t mm_users;			/* How many users with user space? */
+	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
+	atomic_long_t nr_ptes;			/* PTE page table pages */
+	atomic_long_t nr_pmds;			/* PMD page table pages */
+	int map_count;				/* number of VMAs */
+
+	spinlock_t page_table_lock;		/* Protects page tables and some counters */
+	struct rw_semaphore mmap_sem;
+
+	struct list_head mmlist;		/* List of maybe swapped mm's.	These are globally strung
+						 * together off init_mm.mmlist, and are protected
+						 * by mmlist_lock
+						 */
+
+
+	unsigned long hiwater_rss;	/* High-watermark of RSS usage */
+	unsigned long hiwater_vm;	/* High-water virtual memory usage */
+
+	unsigned long total_vm;		/* Total pages mapped */
+	unsigned long locked_vm;	/* Pages that have PG_mlocked set */
+	unsigned long pinned_vm;	/* Refcount permanently increased */
+	unsigned long shared_vm;	/* Shared pages (files) */
+	unsigned long exec_vm;		/* VM_EXEC & ~VM_WRITE */
+	unsigned long stack_vm;		/* VM_GROWSUP/DOWN */
+	unsigned long def_flags;
+	unsigned long start_code, end_code, start_data, end_data;
+	unsigned long start_brk, brk, start_stack;
+	unsigned long arg_start, arg_end, env_start, env_end;
+
+	unsigned long saved_auxv[AT_VECTOR_SIZE]; /* for /proc/PID/auxv */
+
+	/*
+	 * Special counters, in some configurations protected by the
+	 * page_table_lock, in other configurations by being atomic.
+	 */
+	struct mm_rss_stat rss_stat;
+
+	struct linux_binfmt *binfmt;
+
+	cpumask_var_t cpu_vm_mask_var;
+
+	/* Architecture-specific MM context */
+	mm_context_t context;
+
+	unsigned long flags; /* Must use atomic bitops to access the bits */
+
+	struct core_state *core_state; /* coredumping support */
+#ifdef CONFIG_AIO
+	spinlock_t			ioctx_lock;
+	struct kioctx_table __rcu	*ioctx_table;
+#endif
+#ifdef CONFIG_MEMCG
+	/*
+	 * "owner" points to a task that is regarded as the canonical
+	 * user/owner of this mm. All of the following must be true in
+	 * order for it to be changed:
+	 *
+	 * current == mm->owner
+	 * current->mm != mm
+	 * new_owner->mm == mm
+	 * new_owner->alloc_lock is held
+	 */
+	struct task_struct __rcu *owner;
+#endif
+
+	/* store ref to file /proc/<pid>/exe symlink points to */
+	struct file *exe_file;
+#ifdef CONFIG_MMU_NOTIFIER
+	struct mmu_notifier_mm *mmu_notifier_mm;
+#endif
+#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
+	pgtable_t pmd_huge_pte; /* protected by page_table_lock */
+#endif
+#ifdef CONFIG_CPUMASK_OFFSTACK
+	struct cpumask cpumask_allocation;
+#endif
+#ifdef CONFIG_NUMA_BALANCING
+	/*
+	 * numa_next_scan is the next time that the PTEs will be marked
+	 * pte_numa. NUMA hinting faults will gather statistics and migrate
+	 * pages to new nodes if necessary.
+	 */
+	unsigned long numa_next_scan;
+
+	/* Restart point for scanning and setting pte_numa */
+	unsigned long numa_scan_offset;
+
+	/* numa_scan_seq prevents two threads setting pte_numa */
+	int numa_scan_seq;
+#endif
+#if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
+	/*
+	 * An operation with batched TLB flushing is going on. Anything that
+	 * can move process memory needs to flush the TLB when moving a
+	 * PROT_NONE or PROT_NUMA mapped page.
+	 */
+	bool tlb_flush_pending;
+#endif
+	struct uprobes_state uprobes_state;
+#ifdef CONFIG_X86_INTEL_MPX
+	/* address of the bounds directory */
+	void __user *bd_addr;
+#endif
+};
+
+static inline void mm_init_cpumask(struct mm_struct *mm)
+{
+#ifdef CONFIG_CPUMASK_OFFSTACK
+	mm->cpu_vm_mask_var = &mm->cpumask_allocation;
+#endif
+	cpumask_clear(mm->cpu_vm_mask_var);
+}
+
+/* Future-safe accessor for struct mm_struct's cpu_vm_mask. */
+static inline cpumask_t *mm_cpumask(struct mm_struct *mm)
+{
+	return mm->cpu_vm_mask_var;
+}
+
+#if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
+/*
+ * Memory barriers to keep this state in sync are graciously provided by
+ * the page table locks, outside of which no page table modifications happen.
+ * The barriers below prevent the compiler from re-ordering the instructions
+ * around the memory barriers that are already present in the code.
+ */
+static inline bool mm_tlb_flush_pending(struct mm_struct *mm)
+{
+	barrier();
+	return mm->tlb_flush_pending;
+}
+static inline void set_tlb_flush_pending(struct mm_struct *mm)
+{
+	mm->tlb_flush_pending = true;
+
+	/*
+	 * Guarantee that the tlb_flush_pending store does not leak into the
+	 * critical section updating the page tables
+	 */
+	smp_mb__before_spinlock();
+}
+/* Clearing is done after a TLB flush, which also provides a barrier. */
+static inline void clear_tlb_flush_pending(struct mm_struct *mm)
+{
+	barrier();
+	mm->tlb_flush_pending = false;
+}
+#else
+static inline bool mm_tlb_flush_pending(struct mm_struct *mm)
+{
+	return false;
+}
+static inline void set_tlb_flush_pending(struct mm_struct *mm)
+{
+}
+static inline void clear_tlb_flush_pending(struct mm_struct *mm)
+{
+}
+#endif
+
+#endif
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 5dfdd5ed5254..80797b1c1e26 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -1,24 +1,16 @@
 #ifndef _LINUX_MM_TYPES_H
 #define _LINUX_MM_TYPES_H
 
-#include <linux/auxvec.h>
-#include <linux/types.h>
-#include <linux/threads.h>
-#include <linux/list.h>
-#include <linux/spinlock.h>
-#include <linux/rbtree.h>
-#include <linux/rwsem.h>
 #include <linux/completion.h>
 #include <linux/cpumask.h>
-#include <linux/uprobes.h>
+#include <linux/list.h>
 #include <linux/page-flags-layout.h>
-#include <asm/page.h>
-#include <asm/mmu.h>
+#include <linux/rbtree.h>
+#include <linux/spinlock.h>
+#include <linux/threads.h>
+#include <linux/types.h>
 
-#ifndef AT_VECTOR_SIZE_ARCH
-#define AT_VECTOR_SIZE_ARCH 0
-#endif
-#define AT_VECTOR_SIZE (2*(AT_VECTOR_SIZE_ARCH + AT_VECTOR_SIZE_BASE + 1))
+#include <asm/page.h>
 
 struct address_space;
 struct mem_cgroup;
@@ -326,203 +318,7 @@ struct core_state {
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
-struct kioctx_table;
-struct mm_struct {
-	struct vm_area_struct *mmap;		/* list of VMAs */
-	struct rb_root mm_rb;
-	u32 vmacache_seqnum;                   /* per-thread vmacache */
-#ifdef CONFIG_MMU
-	unsigned long (*get_unmapped_area) (struct file *filp,
-				unsigned long addr, unsigned long len,
-				unsigned long pgoff, unsigned long flags);
-#endif
-	unsigned long mmap_base;		/* base of mmap area */
-	unsigned long mmap_legacy_base;         /* base of mmap area in bottom-up allocations */
-	unsigned long task_size;		/* size of task vm space */
-	unsigned long highest_vm_end;		/* highest vma end address */
-	pgd_t * pgd;
-	atomic_t mm_users;			/* How many users with user space? */
-	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
-	atomic_long_t nr_ptes;			/* PTE page table pages */
-	atomic_long_t nr_pmds;			/* PMD page table pages */
-	int map_count;				/* number of VMAs */
-
-	spinlock_t page_table_lock;		/* Protects page tables and some counters */
-	struct rw_semaphore mmap_sem;
-
-	struct list_head mmlist;		/* List of maybe swapped mm's.	These are globally strung
-						 * together off init_mm.mmlist, and are protected
-						 * by mmlist_lock
-						 */
-
-
-	unsigned long hiwater_rss;	/* High-watermark of RSS usage */
-	unsigned long hiwater_vm;	/* High-water virtual memory usage */
-
-	unsigned long total_vm;		/* Total pages mapped */
-	unsigned long locked_vm;	/* Pages that have PG_mlocked set */
-	unsigned long pinned_vm;	/* Refcount permanently increased */
-	unsigned long shared_vm;	/* Shared pages (files) */
-	unsigned long exec_vm;		/* VM_EXEC & ~VM_WRITE */
-	unsigned long stack_vm;		/* VM_GROWSUP/DOWN */
-	unsigned long def_flags;
-	unsigned long start_code, end_code, start_data, end_data;
-	unsigned long start_brk, brk, start_stack;
-	unsigned long arg_start, arg_end, env_start, env_end;
-
-	unsigned long saved_auxv[AT_VECTOR_SIZE]; /* for /proc/PID/auxv */
-
-	/*
-	 * Special counters, in some configurations protected by the
-	 * page_table_lock, in other configurations by being atomic.
-	 */
-	struct mm_rss_stat rss_stat;
-
-	struct linux_binfmt *binfmt;
-
-	cpumask_var_t cpu_vm_mask_var;
-
-	/* Architecture-specific MM context */
-	mm_context_t context;
-
-	unsigned long flags; /* Must use atomic bitops to access the bits */
-
-	struct core_state *core_state; /* coredumping support */
-#ifdef CONFIG_AIO
-	spinlock_t			ioctx_lock;
-	struct kioctx_table __rcu	*ioctx_table;
-#endif
-#ifdef CONFIG_MEMCG
-	/*
-	 * "owner" points to a task that is regarded as the canonical
-	 * user/owner of this mm. All of the following must be true in
-	 * order for it to be changed:
-	 *
-	 * current == mm->owner
-	 * current->mm != mm
-	 * new_owner->mm == mm
-	 * new_owner->alloc_lock is held
-	 */
-	struct task_struct __rcu *owner;
-#endif
-
-	/* store ref to file /proc/<pid>/exe symlink points to */
-	struct file *exe_file;
-#ifdef CONFIG_MMU_NOTIFIER
-	struct mmu_notifier_mm *mmu_notifier_mm;
-#endif
-#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
-	pgtable_t pmd_huge_pte; /* protected by page_table_lock */
-#endif
-#ifdef CONFIG_CPUMASK_OFFSTACK
-	struct cpumask cpumask_allocation;
-#endif
-#ifdef CONFIG_NUMA_BALANCING
-	/*
-	 * numa_next_scan is the next time that the PTEs will be marked
-	 * pte_numa. NUMA hinting faults will gather statistics and migrate
-	 * pages to new nodes if necessary.
-	 */
-	unsigned long numa_next_scan;
-
-	/* Restart point for scanning and setting pte_numa */
-	unsigned long numa_scan_offset;
-
-	/* numa_scan_seq prevents two threads setting pte_numa */
-	int numa_scan_seq;
-#endif
-#if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
-	/*
-	 * An operation with batched TLB flushing is going on. Anything that
-	 * can move process memory needs to flush the TLB when moving a
-	 * PROT_NONE or PROT_NUMA mapped page.
-	 */
-	bool tlb_flush_pending;
-#endif
-	struct uprobes_state uprobes_state;
-#ifdef CONFIG_X86_INTEL_MPX
-	/* address of the bounds directory */
-	void __user *bd_addr;
-#endif
-};
-
-static inline void mm_init_cpumask(struct mm_struct *mm)
-{
-#ifdef CONFIG_CPUMASK_OFFSTACK
-	mm->cpu_vm_mask_var = &mm->cpumask_allocation;
-#endif
-	cpumask_clear(mm->cpu_vm_mask_var);
-}
-
-/* Future-safe accessor for struct mm_struct's cpu_vm_mask. */
-static inline cpumask_t *mm_cpumask(struct mm_struct *mm)
-{
-	return mm->cpu_vm_mask_var;
-}
-
-#if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
-/*
- * Memory barriers to keep this state in sync are graciously provided by
- * the page table locks, outside of which no page table modifications happen.
- * The barriers below prevent the compiler from re-ordering the instructions
- * around the memory barriers that are already present in the code.
- */
-static inline bool mm_tlb_flush_pending(struct mm_struct *mm)
-{
-	barrier();
-	return mm->tlb_flush_pending;
-}
-static inline void set_tlb_flush_pending(struct mm_struct *mm)
-{
-	mm->tlb_flush_pending = true;
-
-	/*
-	 * Guarantee that the tlb_flush_pending store does not leak into the
-	 * critical section updating the page tables
-	 */
-	smp_mb__before_spinlock();
-}
-/* Clearing is done after a TLB flush, which also provides a barrier. */
-static inline void clear_tlb_flush_pending(struct mm_struct *mm)
-{
-	barrier();
-	mm->tlb_flush_pending = false;
-}
-#else
-static inline bool mm_tlb_flush_pending(struct mm_struct *mm)
-{
-	return false;
-}
-static inline void set_tlb_flush_pending(struct mm_struct *mm)
-{
-}
-static inline void clear_tlb_flush_pending(struct mm_struct *mm)
-{
-}
-#endif
-
-struct vm_special_mapping
-{
+struct vm_special_mapping {
 	const char *name;
 	struct page **pages;
 };
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 95243d28a0ee..779e32567e6d 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -4,6 +4,7 @@
 #include <linux/list.h>
 #include <linux/spinlock.h>
 #include <linux/mm_types.h>
+#include <linux/mm_struct.h>
 #include <linux/srcu.h>
 
 struct mmu_notifier;
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 22ee0d5d7f8c..99001775ffa0 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -25,6 +25,7 @@ struct sched_param {
 #include <linux/errno.h>
 #include <linux/nodemask.h>
 #include <linux/mm_types.h>
+#include <linux/mm_struct.h>
 #include <linux/preempt_mask.h>
 
 #include <asm/page.h>
diff --git a/mm/init-mm.c b/mm/init-mm.c
index a56a851908d2..310ae8c7d9c6 100644
--- a/mm/init-mm.c
+++ b/mm/init-mm.c
@@ -1,4 +1,5 @@
 #include <linux/mm_types.h>
+#include <linux/mm_struct.h>
 #include <linux/rbtree.h>
 #include <linux/rwsem.h>
 #include <linux/spinlock.h>
diff --git a/mm/kmemcheck.c b/mm/kmemcheck.c
index cab58bb592d8..c40d065013d2 100644
--- a/mm/kmemcheck.c
+++ b/mm/kmemcheck.c
@@ -1,5 +1,4 @@
 #include <linux/gfp.h>
-#include <linux/mm_types.h>
 #include <linux/mm.h>
 #include <linux/slab.h>
 #include "slab.h"
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
