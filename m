Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f49.google.com (mail-oa0-f49.google.com [209.85.219.49])
	by kanga.kvack.org (Postfix) with ESMTP id 033986B00B4
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 00:28:47 -0500 (EST)
Received: by mail-oa0-f49.google.com with SMTP id i4so1296612oah.36
        for <linux-mm@kvack.org>; Thu, 20 Feb 2014 21:28:47 -0800 (PST)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id ke9si3431039oeb.129.2014.02.20.21.28.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 20 Feb 2014 21:28:47 -0800 (PST)
Message-ID: <1392960523.3039.16.camel@buesod1.americas.hpqcorp.net>
Subject: [PATCH] mm: per-thread vma caching
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Thu, 20 Feb 2014 21:28:43 -0800
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>
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

The proposed approach is to keep the current cache and adding a small, per
thread, LRU cache. By keeping the mm->mmap_cache, programs with large heaps
or good locality can benefit by not having to deal with an additional cache
when the hit rate is good enough. Concretely, the following results are seen
on an 80 core, 8 socket x86-64 box:

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

Systems with !CONFIG_MMU get to keep the current logic.

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
Please note that nommu and unicore32 arch are *untested*.
Thanks.

 arch/unicore32/include/asm/mmu_context.h |  3 +-
 fs/proc/task_mmu.c                       |  2 +-
 include/linux/mm_types.h                 |  5 ++-
 include/linux/sched.h                    |  5 +++
 include/linux/vmacache.h                 | 19 ++++++++++
 kernel/debug/debug_core.c                |  4 +-
 kernel/fork.c                            |  3 +-
 mm/Makefile                              |  2 +-
 mm/mmap.c                                | 55 +++++++++++++++-------------
 mm/nommu.c                               | 12 +++---
 mm/vmacache.c                            | 63 ++++++++++++++++++++++++++++++++
 11 files changed, 133 insertions(+), 40 deletions(-)
 create mode 100644 include/linux/vmacache.h
 create mode 100644 mm/vmacache.c

diff --git a/arch/unicore32/include/asm/mmu_context.h b/arch/unicore32/include/asm/mmu_context.h
index fb5e4c6..bc79303 100644
--- a/arch/unicore32/include/asm/mmu_context.h
+++ b/arch/unicore32/include/asm/mmu_context.h
@@ -73,7 +73,8 @@ do { \
 		else \
 			mm->mmap = NULL; \
 		rb_erase(&high_vma->vm_rb, &mm->mm_rb); \
-		mm->mmap_cache = NULL; \
+		mm->vmacache = NULL; \
+		vmacache_invalidate(mm); \
 		mm->map_count--; \
 		remove_vma(high_vma); \
 	} \
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
index 290901a..03d941c 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -342,9 +342,10 @@ struct mm_rss_stat {
 
 struct kioctx_table;
 struct mm_struct {
-	struct vm_area_struct * mmap;		/* list of VMAs */
+	struct vm_area_struct *mmap;		/* list of VMAs */
 	struct rb_root mm_rb;
-	struct vm_area_struct * mmap_cache;	/* last find_vma result */
+	unsigned long vmacache_seqnum;
+	struct vm_area_struct *vmacache;	/* last find_vma result */
 #ifdef CONFIG_MMU
 	unsigned long (*get_unmapped_area) (struct file *filp,
 				unsigned long addr, unsigned long len,
diff --git a/include/linux/sched.h b/include/linux/sched.h
index a781dec..171c718 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -23,6 +23,7 @@ struct sched_param {
 #include <linux/errno.h>
 #include <linux/nodemask.h>
 #include <linux/mm_types.h>
+#include <linux/vmacache.h>
 #include <linux/preempt_mask.h>
 
 #include <asm/page.h>
@@ -1225,6 +1226,10 @@ struct task_struct {
 #endif
 
 	struct mm_struct *mm, *active_mm;
+#ifdef CONFIG_MMU
+	unsigned long vmacache_seqnum;
+	struct vm_area_struct *vmacache[VMACACHE_SIZE];
+#endif
 #ifdef CONFIG_COMPAT_BRK
 	unsigned brk_randomized:1;
 #endif
diff --git a/include/linux/vmacache.h b/include/linux/vmacache.h
new file mode 100644
index 0000000..b15bf82
--- /dev/null
+++ b/include/linux/vmacache.h
@@ -0,0 +1,19 @@
+#ifndef __LINUX_VMACACHE_H
+#define __LINUX_VMACACHE_H
+
+#include <linux/mm.h>
+
+#define VMACACHE_SIZE 4
+
+static inline void vmacache_invalidate(struct mm_struct *mm)
+{
+	mm->vmacache_seqnum++;
+}
+
+extern bool vmacache_valid(struct mm_struct *mm);
+extern void vmacache_update(struct mm_struct *mm, unsigned long addr,
+			    struct vm_area_struct *newvma);
+extern struct vm_area_struct *vmacache_find(struct mm_struct *mm,
+					    unsigned long addr);
+
+#endif /* __LINUX_VMACACHE_H */
diff --git a/kernel/debug/debug_core.c b/kernel/debug/debug_core.c
index 334b398..fa5fa24 100644
--- a/kernel/debug/debug_core.c
+++ b/kernel/debug/debug_core.c
@@ -224,8 +224,8 @@ static void kgdb_flush_swbreak_addr(unsigned long addr)
 	if (!CACHE_FLUSH_IS_SAFE)
 		return;
 
-	if (current->mm && current->mm->mmap_cache) {
-		flush_cache_range(current->mm->mmap_cache,
+	if (current->mm && current->mm->vmacache) {
+		flush_cache_range(current->mm->vmacache,
 				  addr, addr + BREAK_INSTR_SIZE);
 	}
 	/* Force flush instruction cache if it was outside the mm */
diff --git a/kernel/fork.c b/kernel/fork.c
index a17621c..949744b 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -363,7 +363,8 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 
 	mm->locked_vm = 0;
 	mm->mmap = NULL;
-	mm->mmap_cache = NULL;
+	mm->vmacache = NULL;
+	mm->vmacache_seqnum = oldmm->vmacache_seqnum + 1;
 	mm->map_count = 0;
 	cpumask_clear(mm_cpumask(mm));
 	mm->mm_rb = RB_ROOT;
diff --git a/mm/Makefile b/mm/Makefile
index 310c90a..2bb5b6a 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -5,7 +5,7 @@
 mmu-y			:= nommu.o
 mmu-$(CONFIG_MMU)	:= fremap.o highmem.o madvise.o memory.o mincore.o \
 			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
-			   vmalloc.o pagewalk.o pgtable-generic.o
+			   vmalloc.o pagewalk.o pgtable-generic.o vmacache.o
 
 ifdef CONFIG_CROSS_MEMORY_ATTACH
 mmu-$(CONFIG_MMU)	+= process_vm_access.o
diff --git a/mm/mmap.c b/mm/mmap.c
index 20ff0c3..fd18f03 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -681,8 +681,9 @@ __vma_unlink(struct mm_struct *mm, struct vm_area_struct *vma,
 	prev->vm_next = next = vma->vm_next;
 	if (next)
 		next->vm_prev = prev;
-	if (mm->mmap_cache == vma)
-		mm->mmap_cache = prev;
+	if (mm->vmacache == vma)
+		mm->vmacache = prev;
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
+		struct vm_area_struct *vma_tmp;
+
+		vma_tmp = rb_entry(rb_node,
+				   struct vm_area_struct, vm_rb);
+
+		if (vma_tmp->vm_end > addr) {
+			vma = vma_tmp;
+			if (vma_tmp->vm_start <= addr)
+				break;
+			rb_node = rb_node->rb_left;
+		} else
+			rb_node = rb_node->rb_right;
 	}
+	if (vma)
+		vmacache_update(mm, addr, vma);
 	return vma;
 }
 
@@ -2388,7 +2388,10 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
 	} else
 		mm->highest_vm_end = prev ? prev->vm_end : 0;
 	tail_vma->vm_next = NULL;
-	mm->mmap_cache = NULL;		/* Kill the cache. */
+
+	/* Kill the cache */
+	mm->vmacache = NULL;
+	vmacache_invalidate(mm);
 }
 
 /*
diff --git a/mm/nommu.c b/mm/nommu.c
index 8740213..c2d1b92 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -776,8 +776,8 @@ static void delete_vma_from_mm(struct vm_area_struct *vma)
 	protect_vma(vma, 0);
 
 	mm->map_count--;
-	if (mm->mmap_cache == vma)
-		mm->mmap_cache = NULL;
+	if (mm->vmacache == vma)
+		mm->vmacache = NULL;
 
 	/* remove the VMA from the mapping */
 	if (vma->vm_file) {
@@ -825,7 +825,7 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
 	struct vm_area_struct *vma;
 
 	/* check the cache first */
-	vma = ACCESS_ONCE(mm->mmap_cache);
+	vma = ACCESS_ONCE(mm->vmacache);
 	if (vma && vma->vm_start <= addr && vma->vm_end > addr)
 		return vma;
 
@@ -835,7 +835,7 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
 		if (vma->vm_start > addr)
 			return NULL;
 		if (vma->vm_end > addr) {
-			mm->mmap_cache = vma;
+			mm->vmacache = vma;
 			return vma;
 		}
 	}
@@ -874,7 +874,7 @@ static struct vm_area_struct *find_vma_exact(struct mm_struct *mm,
 	unsigned long end = addr + len;
 
 	/* check the cache first */
-	vma = mm->mmap_cache;
+	vma = mm->vmacache;
 	if (vma && vma->vm_start == addr && vma->vm_end == end)
 		return vma;
 
@@ -886,7 +886,7 @@ static struct vm_area_struct *find_vma_exact(struct mm_struct *mm,
 		if (vma->vm_start > addr)
 			return NULL;
 		if (vma->vm_end == end) {
-			mm->mmap_cache = vma;
+			mm->vmacache = vma;
 			return vma;
 		}
 	}
diff --git a/mm/vmacache.c b/mm/vmacache.c
new file mode 100644
index 0000000..1a8c0f3
--- /dev/null
+++ b/mm/vmacache.c
@@ -0,0 +1,63 @@
+#include <linux/sched.h>
+#include <linux/vmacache.h>
+
+bool vmacache_valid(struct mm_struct *mm)
+{
+	struct task_struct *curr = current;
+
+	if (mm != curr->mm)
+		return false;
+
+	if (mm->vmacache_seqnum != curr->vmacache_seqnum) {
+		/*
+		 * First attempt will always be invalid, initialize the
+		 * new cache for this task here.
+		 */
+		curr->vmacache_seqnum = mm->vmacache_seqnum;
+		memset(curr->vmacache, 0, sizeof(curr->vmacache));
+		return false;
+	}
+	return true;
+}
+
+struct vm_area_struct *vmacache_find(struct mm_struct *mm,
+				     unsigned long addr)
+
+{
+	int i;
+	struct vm_area_struct *vma = ACCESS_ONCE(mm->vmacache);
+	struct task_struct *curr = current;
+
+	if (vma && vma->vm_start <= addr && vma->vm_end > addr)
+		return vma;
+
+	if (!vmacache_valid(mm))
+		return NULL;
+
+	vma = NULL;
+	for (i = 0; i < VMACACHE_SIZE; i++) {
+		vma = curr->vmacache[i];
+
+		if (vma && vma->vm_start <= addr && vma->vm_end > addr)
+			return vma;
+	}
+
+	return NULL;
+}
+
+void vmacache_update(struct mm_struct *mm, unsigned long addr,
+		     struct vm_area_struct *newvma)
+{
+	int idx =  (addr >> 10) & 3;
+	struct task_struct *curr = current;
+
+	if (!vmacache_valid(mm)) {
+		curr->vmacache[idx] = newvma;
+		goto done;
+	}
+
+	if (curr->vmacache[idx] != newvma)
+		curr->vmacache[idx] = newvma;
+done:
+	ACCESS_ONCE(mm->vmacache) = newvma;
+}
-- 
1.8.1.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
