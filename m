Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f45.google.com (mail-oa0-f45.google.com [209.85.219.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6F1CD6B0073
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 16:48:27 -0500 (EST)
Received: by mail-oa0-f45.google.com with SMTP id i11so3137044oag.4
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 13:48:27 -0800 (PST)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id e6si8446718oen.36.2014.02.27.13.48.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 27 Feb 2014 13:48:26 -0800 (PST)
Message-ID: <1393537704.2899.3.camel@buesod1.americas.hpqcorp.net>
Subject: [PATCH v4] mm: per-thread vma caching
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Thu, 27 Feb 2014 13:48:24 -0800
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Davidlohr Bueso <davidlohr@hp.com>, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Davidlohr Bueso <davidlohr@hp.com>

This patch is a continuation of efforts trying to optimize find_vma(),
avoiding potentially expensive rbtree walks to locate a vma upon faults.
The original approach (https://lkml.org/lkml/2013/11/1/410), where the
largest vma was also cached, ended up being too specific and random, thus
further comparison with other approaches were needed. There are two things
to consider when dealing with this, the cache hit rate and the latency of
find_vma(). Improving the hit-rate does not necessarily translate in finding
the vma any faster, as the overhead of any fancy caching schemes can be too
high to consider.

We currently cache the last used vma for the whole address space, which
provides a nice optimization, reducing the total cycles in find_vma() by up
to 250%, for workloads with good locality. On the other hand, this simple
scheme is pretty much useless for workloads with poor locality. Analyzing
ebizzy runs shows that, no matter how many threads are running, the
mmap_cache hit rate is less than 2%, and in many situations below 1%.

The proposed approach is to replace this scheme with a small per-thread cache,
maximizing hit rates at a very low maintenance cost. Invalidations are
performed by simply bumping up a 32-bit sequence number. The only expensive
operation is in the rare case of a seq number overflow, where all caches that
share the same address space are flushed. Upon a miss, the proposed replacement
policy is based on the page number that contains the virtual address in
question. Concretely, the following results are seen on an 80 core, 8 socket
x86-64 box:

1) System bootup: Most programs are single threaded, so the per-thread scheme
does improve ~50% hit rate by just adding a few more slots to the cache.

+----------------+----------+------------------+
| caching scheme | hit-rate | cycles (billion) |
+----------------+----------+------------------+
| baseline       | 50.61%   | 19.90            |
| patched        | 73.45%   | 13.58            |
+----------------+----------+------------------+

2) Kernel build: This one is already pretty good with the current approach
as we're dealing with good locality.

+----------------+----------+------------------+
| caching scheme | hit-rate | cycles (billion) |
+----------------+----------+------------------+
| baseline       | 75.28%   | 11.03            |
| patched        | 88.09%   | 9.31             |
+----------------+----------+------------------+

3) Oracle 11g Data Mining (4k pages): Similar to the kernel build workload.

+----------------+----------+------------------+
| caching scheme | hit-rate | cycles (billion) |
+----------------+----------+------------------+
| baseline       | 70.66%   | 17.14            |
| patched        | 91.15%   | 12.57            |
+----------------+----------+------------------+

4) Ebizzy: There's a fair amount of variation from run to run, but this
approach always shows nearly perfect hit rates, while baseline is just
about non-existent. The amounts of cycles can fluctuate between anywhere
from ~60 to ~116 for the baseline scheme, but this approach reduces it
considerably. For instance, with 80 threads:

+----------------+----------+------------------+
| caching scheme | hit-rate | cycles (billion) |
+----------------+----------+------------------+
| baseline       | 1.06%    | 91.54            |
| patched        | 99.97%   | 14.18            |
+----------------+----------+------------------+

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Acked-by: Linus Torvalds <torvalds@linux-foundation.org>
Reviewed-by: Michel Lespinasse <walken@google.com>
---
Changes from v3 (http://lkml.org/lkml/2014/2/26/637):
- Fixed an invalidation occurrence for nommu
- Make nommu have 4 slots, instead of limiting it to one.

Please note that kgdb, nommu and unicore32 arch are *untested*. Thanks.

 arch/unicore32/include/asm/mmu_context.h |  2 +-
 fs/exec.c                                |  4 +-
 fs/proc/task_mmu.c                       |  2 +-
 include/linux/mm_types.h                 |  4 +-
 include/linux/sched.h                    |  4 ++
 include/linux/vmacache.h                 | 40 ++++++++++++++
 kernel/debug/debug_core.c                | 13 ++++-
 kernel/fork.c                            |  5 +-
 mm/Makefile                              |  2 +-
 mm/mmap.c                                | 54 +++++++++---------
 mm/nommu.c                               | 23 +++++---
 mm/vmacache.c                            | 94 ++++++++++++++++++++++++++++++++
 12 files changed, 203 insertions(+), 44 deletions(-)
 create mode 100644 include/linux/vmacache.h
 create mode 100644 mm/vmacache.c

diff --git a/arch/unicore32/include/asm/mmu_context.h b/arch/unicore32/include/asm/mmu_context.h
index fb5e4c6..2dcd037 100644
--- a/arch/unicore32/include/asm/mmu_context.h
+++ b/arch/unicore32/include/asm/mmu_context.h
@@ -73,7 +73,7 @@ do { \
 		else \
 			mm->mmap = NULL; \
 		rb_erase(&high_vma->vm_rb, &mm->mm_rb); \
-		mm->mmap_cache = NULL; \
+		vmacache_invalidate(mm); \
 		mm->map_count--; \
 		remove_vma(high_vma); \
 	} \
diff --git a/fs/exec.c b/fs/exec.c
index 3d78fcc..3fb63b5 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -820,7 +820,7 @@ EXPORT_SYMBOL(read_code);
 static int exec_mmap(struct mm_struct *mm)
 {
 	struct task_struct *tsk;
-	struct mm_struct * old_mm, *active_mm;
+	struct mm_struct *old_mm, *active_mm;
 
 	/* Notify parent that we're no longer interested in the old VM */
 	tsk = current;
@@ -846,6 +846,8 @@ static int exec_mmap(struct mm_struct *mm)
 	tsk->mm = mm;
 	tsk->active_mm = mm;
 	activate_mm(active_mm, mm);
+	tsk->mm->vmacache_seqnum = 0;
+	vmacache_flush(tsk);
 	task_unlock(tsk);
 	if (old_mm) {
 		up_read(&old_mm->mmap_sem);
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index fb52b54..231c836 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -152,7 +152,7 @@ static void *m_start(struct seq_file *m, loff_t *pos)
 
 	/*
 	 * We remember last_addr rather than next_addr to hit with
-	 * mmap_cache most of the time. We have zero last_addr at
+	 * vmacache most of the time. We have zero last_addr at
 	 * the beginning and also after lseek. We will have -1 last_addr
 	 * after the end of the vmas.
 	 */
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 290901a..2b58d19 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -342,9 +342,9 @@ struct mm_rss_stat {
 
 struct kioctx_table;
 struct mm_struct {
-	struct vm_area_struct * mmap;		/* list of VMAs */
+	struct vm_area_struct *mmap;		/* list of VMAs */
 	struct rb_root mm_rb;
-	struct vm_area_struct * mmap_cache;	/* last find_vma result */
+	u32 vmacache_seqnum;                   /* per-thread vmacache */
 #ifdef CONFIG_MMU
 	unsigned long (*get_unmapped_area) (struct file *filp,
 				unsigned long addr, unsigned long len,
diff --git a/include/linux/sched.h b/include/linux/sched.h
index a781dec..7754ab0 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -23,6 +23,7 @@ struct sched_param {
 #include <linux/errno.h>
 #include <linux/nodemask.h>
 #include <linux/mm_types.h>
+#include <linux/vmacache.h>
 #include <linux/preempt_mask.h>
 
 #include <asm/page.h>
@@ -1228,6 +1229,9 @@ struct task_struct {
 #ifdef CONFIG_COMPAT_BRK
 	unsigned brk_randomized:1;
 #endif
+	/* per-thread vma caching */
+	u32 vmacache_seqnum;
+	struct vm_area_struct *vmacache[VMACACHE_SIZE];
 #if defined(SPLIT_RSS_COUNTING)
 	struct task_rss_stat	rss_stat;
 #endif
diff --git a/include/linux/vmacache.h b/include/linux/vmacache.h
new file mode 100644
index 0000000..40e4eb8
--- /dev/null
+++ b/include/linux/vmacache.h
@@ -0,0 +1,40 @@
+#ifndef __LINUX_VMACACHE_H
+#define __LINUX_VMACACHE_H
+
+#include <linux/mm.h>
+
+#define VMACACHE_BITS 2
+#define VMACACHE_SIZE (1U << VMACACHE_BITS)
+#define VMACACHE_MASK (VMACACHE_SIZE - 1)
+/*
+ * Hash based on the page number. Provides a good hit rate for
+ * workloads with good locality and those with random accesses as well.
+ */
+#define VMACACHE_HASH(addr) ((addr >> PAGE_SHIFT) & VMACACHE_MASK)
+
+#define vmacache_flush(tsk)					 \
+	do {							 \
+		memset(tsk->vmacache, 0, sizeof(tsk->vmacache)); \
+	} while (0)
+
+extern void vmacache_flush_all(struct mm_struct *mm);
+extern void vmacache_update(unsigned long addr, struct vm_area_struct *newvma);
+extern struct vm_area_struct *vmacache_find(struct mm_struct *mm,
+						    unsigned long addr);
+
+#ifndef CONFIG_MMU
+extern struct vm_area_struct *vmacache_find_exact(struct mm_struct *mm,
+						  unsigned long start,
+						  unsigned long end);
+#endif
+
+static inline void vmacache_invalidate(struct mm_struct *mm)
+{
+	mm->vmacache_seqnum++;
+
+	/* deal with overflows */
+	if (unlikely(mm->vmacache_seqnum == 0))
+		vmacache_flush_all(mm);
+}
+
+#endif /* __LINUX_VMACACHE_H */
diff --git a/kernel/debug/debug_core.c b/kernel/debug/debug_core.c
index 334b398..7f1a97a 100644
--- a/kernel/debug/debug_core.c
+++ b/kernel/debug/debug_core.c
@@ -224,10 +224,17 @@ static void kgdb_flush_swbreak_addr(unsigned long addr)
 	if (!CACHE_FLUSH_IS_SAFE)
 		return;
 
-	if (current->mm && current->mm->mmap_cache) {
-		flush_cache_range(current->mm->mmap_cache,
-				  addr, addr + BREAK_INSTR_SIZE);
+	if (current->mm) {
+		int i;
+
+		for (i = 0; i < VMACACHE_SIZE; i++) {
+			if (!current->vmacache[i])
+				continue;
+			flush_cache_range(current->vmacache[i],
+					  addr, addr + BREAK_INSTR_SIZE);
+		}
 	}
+
 	/* Force flush instruction cache if it was outside the mm */
 	flush_icache_range(addr, addr + BREAK_INSTR_SIZE);
 }
diff --git a/kernel/fork.c b/kernel/fork.c
index a17621c..523bce5 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -363,7 +363,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 
 	mm->locked_vm = 0;
 	mm->mmap = NULL;
-	mm->mmap_cache = NULL;
+	mm->vmacache_seqnum = 0;
 	mm->map_count = 0;
 	cpumask_clear(mm_cpumask(mm));
 	mm->mm_rb = RB_ROOT;
@@ -833,6 +833,9 @@ static struct mm_struct *dup_mm(struct task_struct *tsk)
 	if (mm->binfmt && !try_module_get(mm->binfmt->module))
 		goto free_pt;
 
+	/* initialize the new vmacache entries */
+	vmacache_flush(tsk);
+
 	return mm;
 
 free_pt:
diff --git a/mm/Makefile b/mm/Makefile
index 310c90a..ad6638f 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -17,7 +17,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 			   util.o mmzone.o vmstat.o backing-dev.o \
 			   mm_init.o mmu_context.o percpu.o slab_common.o \
 			   compaction.o balloon_compaction.o \
-			   interval_tree.o list_lru.o $(mmu-y)
+			   vmacache.o interval_tree.o list_lru.o $(mmu-y)
 
 obj-y += init-mm.o
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 20ff0c3..47329e1 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -681,8 +681,9 @@ __vma_unlink(struct mm_struct *mm, struct vm_area_struct *vma,
 	prev->vm_next = next = vma->vm_next;
 	if (next)
 		next->vm_prev = prev;
-	if (mm->mmap_cache == vma)
-		mm->mmap_cache = prev;
+
+	/* Kill the cache */
+	vmacache_invalidate(mm);
 }
 
 /*
@@ -1989,34 +1990,33 @@ EXPORT_SYMBOL(get_unmapped_area);
 /* Look up the first VMA which satisfies  addr < vm_end,  NULL if none. */
 struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
 {
-	struct vm_area_struct *vma = NULL;
+	struct rb_node *rb_node;
+	struct vm_area_struct *vma;
 
 	/* Check the cache first. */
-	/* (Cache hit rate is typically around 35%.) */
-	vma = ACCESS_ONCE(mm->mmap_cache);
-	if (!(vma && vma->vm_end > addr && vma->vm_start <= addr)) {
-		struct rb_node *rb_node;
+	vma = vmacache_find(mm, addr);
+	if (likely(vma))
+		return vma;
 
-		rb_node = mm->mm_rb.rb_node;
-		vma = NULL;
+	rb_node = mm->mm_rb.rb_node;
+	vma = NULL;
 
-		while (rb_node) {
-			struct vm_area_struct *vma_tmp;
-
-			vma_tmp = rb_entry(rb_node,
-					   struct vm_area_struct, vm_rb);
-
-			if (vma_tmp->vm_end > addr) {
-				vma = vma_tmp;
-				if (vma_tmp->vm_start <= addr)
-					break;
-				rb_node = rb_node->rb_left;
-			} else
-				rb_node = rb_node->rb_right;
-		}
-		if (vma)
-			mm->mmap_cache = vma;
+	while (rb_node) {
+		struct vm_area_struct *tmp;
+
+		tmp = rb_entry(rb_node, struct vm_area_struct, vm_rb);
+
+		if (tmp->vm_end > addr) {
+			vma = tmp;
+			if (tmp->vm_start <= addr)
+				break;
+			rb_node = rb_node->rb_left;
+		} else
+			rb_node = rb_node->rb_right;
 	}
+
+	if (vma)
+		vmacache_update(addr, vma);
 	return vma;
 }
 
@@ -2388,7 +2388,9 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
 	} else
 		mm->highest_vm_end = prev ? prev->vm_end : 0;
 	tail_vma->vm_next = NULL;
-	mm->mmap_cache = NULL;		/* Kill the cache. */
+
+	/* Kill the cache */
+	vmacache_invalidate(mm);
 }
 
 /*
diff --git a/mm/nommu.c b/mm/nommu.c
index 8740213..95c2bd9 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -768,16 +768,23 @@ static void add_vma_to_mm(struct mm_struct *mm, struct vm_area_struct *vma)
  */
 static void delete_vma_from_mm(struct vm_area_struct *vma)
 {
+	int i;
 	struct address_space *mapping;
 	struct mm_struct *mm = vma->vm_mm;
+	struct task_struct *curr = current;
 
 	kenter("%p", vma);
 
 	protect_vma(vma, 0);
 
 	mm->map_count--;
-	if (mm->mmap_cache == vma)
-		mm->mmap_cache = NULL;
+	for (i = 0; i < VMACACHE_SIZE; i++) {
+		/* if the vma is cached, invalidate the entire cache */
+		if (curr->vmacache[i] == vma) {
+			vmacache_invalidate(mm);
+			break;
+		}
+	}
 
 	/* remove the VMA from the mapping */
 	if (vma->vm_file) {
@@ -825,8 +832,8 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
 	struct vm_area_struct *vma;
 
 	/* check the cache first */
-	vma = ACCESS_ONCE(mm->mmap_cache);
-	if (vma && vma->vm_start <= addr && vma->vm_end > addr)
+	vma = vmacache_find(mm, addr);
+	if (likely(vma))
 		return vma;
 
 	/* trawl the list (there may be multiple mappings in which addr
@@ -835,7 +842,7 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
 		if (vma->vm_start > addr)
 			return NULL;
 		if (vma->vm_end > addr) {
-			mm->mmap_cache = vma;
+			vmacache_update(addr, vma);
 			return vma;
 		}
 	}
@@ -874,8 +881,8 @@ static struct vm_area_struct *find_vma_exact(struct mm_struct *mm,
 	unsigned long end = addr + len;
 
 	/* check the cache first */
-	vma = mm->mmap_cache;
-	if (vma && vma->vm_start == addr && vma->vm_end == end)
+	vma = vmacache_find_exact(mm, addr, end);
+	if (vma)
 		return vma;
 
 	/* trawl the list (there may be multiple mappings in which addr
@@ -886,7 +893,7 @@ static struct vm_area_struct *find_vma_exact(struct mm_struct *mm,
 		if (vma->vm_start > addr)
 			return NULL;
 		if (vma->vm_end == end) {
-			mm->mmap_cache = vma;
+			vmacache_update(addr, vma);
 			return vma;
 		}
 	}
diff --git a/mm/vmacache.c b/mm/vmacache.c
new file mode 100644
index 0000000..91cd694
--- /dev/null
+++ b/mm/vmacache.c
@@ -0,0 +1,94 @@
+/*
+ * Copyright (C) 2014 Davidlohr Bueso.
+ */
+#include <linux/sched.h>
+#include <linux/vmacache.h>
+
+/*
+ * Flush vma caches for threads that share a given mm.
+ *
+ * The operation is safe because the caller holds the mmap_sem
+ * exclusively and other threads accessing the vma cache will
+ * have mmap_sem held at least for read, so no extra locking
+ * is required to maintain the vma cache.
+ */
+void vmacache_flush_all(struct mm_struct *mm)
+{
+	struct task_struct *g, *p;
+
+	rcu_read_lock();
+	for_each_process_thread(g, p) {
+		/*
+		 * Only flush the vmacache pointers as the
+		 * mm seqnum is already set and curr's will
+		 * be set upon invalidation when the next
+		 * lookup is done.
+		 */
+		if (mm == p->mm)
+			vmacache_flush(p);
+	}
+	rcu_read_unlock();
+}
+
+void vmacache_update(unsigned long addr, struct vm_area_struct *newvma)
+{
+	int idx = VMACACHE_HASH(addr);
+	current->vmacache[idx] = newvma;
+}
+
+static bool vmacache_valid(struct mm_struct *mm)
+{
+	struct task_struct *curr = current;
+
+	if (mm != curr->mm)
+		return false;
+
+	if (mm->vmacache_seqnum != curr->vmacache_seqnum) {
+		/*
+		 * First attempt will always be invalid, initialize
+		 * the new cache for this task here.
+		 */
+		curr->vmacache_seqnum = mm->vmacache_seqnum;
+		vmacache_flush(curr);
+		return false;
+	}
+	return true;
+}
+
+struct vm_area_struct *vmacache_find(struct mm_struct *mm, unsigned long addr)
+{
+	int i;
+
+	if (!vmacache_valid(mm))
+		return NULL;
+
+	for (i = 0; i < VMACACHE_SIZE; i++) {
+		struct vm_area_struct *vma = current->vmacache[i];
+
+		if (vma && vma->vm_start <= addr && vma->vm_end > addr)
+			return vma;
+	}
+
+	return NULL;
+}
+
+#ifndef CONFIG_MMU
+struct vm_area_struct *vmacache_find_exact(struct mm_struct *mm,
+					   unsigned long start,
+					   unsigned long end)
+{
+	int i;
+
+	if (!vmacache_valid(mm))
+		return NULL;
+
+	for (i = 0; i < VMACACHE_SIZE; i++) {
+		struct vm_area_struct *vma = current->vmacache[i];
+
+		if (vma && vma->vm_start == start && vma->vm_end == end)
+			return vma;
+	}
+
+	return NULL;
+}
+#endif
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
