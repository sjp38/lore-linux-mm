Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id A27316B0035
	for <linux-mm@kvack.org>; Fri,  1 Nov 2013 16:17:25 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id p10so4274500pdj.39
        for <linux-mm@kvack.org>; Fri, 01 Nov 2013 13:17:25 -0700 (PDT)
Received: from psmtp.com ([74.125.245.148])
        by mx.google.com with SMTP id ra5si2399852pbc.164.2013.11.01.13.17.23
        for <linux-mm@kvack.org>;
        Fri, 01 Nov 2013 13:17:24 -0700 (PDT)
Message-ID: <1383337039.2653.18.camel@buesod1.americas.hpqcorp.net>
Subject: [PATCH] mm: cache largest vma
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Fri, 01 Nov 2013 13:17:19 -0700
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

While caching the last used vma already does a nice job avoiding
having to iterate the rbtree in find_vma, we can improve. After
studying the hit rate on a load of workloads and environments,
it was seen that it was around 45-50% - constant for a standard
desktop system (gnome3 + evolution + firefox + a few xterms),
and multiple java related workloads (including Hadoop/terasort),
and aim7, which indicates it's better than the 35% value documented
in the code.

By also caching the largest vma, that is, the one that contains
most addresses, there is a steady 10-15% hit rate gain, putting
it above the 60% region. This improvement comes at a very low
overhead for a miss. Furthermore, systems with !CONFIG_MMU keep
the current logic.

This patch introduces a second mmap_cache pointer, which is just
as racy as the first, but as we already know, doesn't matter in
this context. For documentation purposes, I have also added the
ACCESS_ONCE() around mm->mmap_cache updates, keeping it consistent
with the reads.

Cc: Hugh Dickins <hughd@google.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
Please note that nommu and unicore32 arch are *untested*.

I also have a patch on top of this one that caches the most 
used vma, which adds another 8-10% hit rate gain, However,
since it does add a counter to the vma structure and we have
to do more logic in find_vma to keep track, I was hesitant about
the overhead. If folks are interested I can send that out as well.


 Documentation/vm/locking                 |  4 +-
 arch/unicore32/include/asm/mmu_context.h |  2 +-
 include/linux/mm.h                       | 13 ++++++
 include/linux/mm_types.h                 | 15 ++++++-
 kernel/debug/debug_core.c                | 17 +++++++-
 kernel/fork.c                            |  2 +-
 mm/mmap.c                                | 68 ++++++++++++++++++++------------
 7 files changed, 87 insertions(+), 34 deletions(-)

diff --git a/Documentation/vm/locking b/Documentation/vm/locking
index f61228b..b4e8154 100644
--- a/Documentation/vm/locking
+++ b/Documentation/vm/locking
@@ -42,8 +42,8 @@ The rules are:
    for mm B.
 
 The caveats are:
-1. find_vma() makes use of, and updates, the mmap_cache pointer hint.
-The update of mmap_cache is racy (page stealer can race with other code
+1. find_vma() makes use of, and updates, the mmap_cache pointers hint.
+The updates of mmap_cache is racy (page stealer can race with other code
 that invokes find_vma with mmap_sem held), but that is okay, since it 
 is a hint. This can be fixed, if desired, by having find_vma grab the
 page_table_lock.
diff --git a/arch/unicore32/include/asm/mmu_context.h b/arch/unicore32/include/asm/mmu_context.h
index fb5e4c6..38cc7fc 100644
--- a/arch/unicore32/include/asm/mmu_context.h
+++ b/arch/unicore32/include/asm/mmu_context.h
@@ -73,7 +73,7 @@ do { \
 		else \
 			mm->mmap = NULL; \
 		rb_erase(&high_vma->vm_rb, &mm->mm_rb); \
-		mm->mmap_cache = NULL; \
+		vma_clear_caches(mm);			\
 		mm->map_count--; \
 		remove_vma(high_vma); \
 	} \
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8b6e55e..2c0f8ed 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1534,8 +1534,21 @@ static inline void mm_populate(unsigned long addr, unsigned long len)
 	/* Ignore errors */
 	(void) __mm_populate(addr, len, 1);
 }
+
+static inline void vma_clear_caches(struct mm_struct *mm)
+{
+	int i;
+
+	for (i = 0; i < NR_VMA_CACHES; i++)
+		mm->mmap_cache[i] = NULL;
+}
 #else
 static inline void mm_populate(unsigned long addr, unsigned long len) {}
+
+static inline void vma_clear_caches(struct mm_struct *mm)
+{
+	mm->mmap_cache = NULL;
+}
 #endif
 
 /* These take the mm semaphore themselves */
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index d9851ee..7f92835 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -322,12 +322,23 @@ struct mm_rss_stat {
 	atomic_long_t count[NR_MM_COUNTERS];
 };
 
+
+#ifdef CONFIG_MMU
+enum {
+	VMA_LAST_USED, /* last find_vma result */
+	VMA_LARGEST,   /* vma that contains most address */
+	NR_VMA_CACHES
+};
+#endif
+
 struct kioctx_table;
 struct mm_struct {
 	struct vm_area_struct * mmap;		/* list of VMAs */
 	struct rb_root mm_rb;
-	struct vm_area_struct * mmap_cache;	/* last find_vma result */
-#ifdef CONFIG_MMU
+#ifndef CONFIG_MMU
+	struct vm_area_struct *mmap_cache;      /* last find_vma result */
+#else
+	struct vm_area_struct *mmap_cache[NR_VMA_CACHES];
 	unsigned long (*get_unmapped_area) (struct file *filp,
 				unsigned long addr, unsigned long len,
 				unsigned long pgoff, unsigned long flags);
diff --git a/kernel/debug/debug_core.c b/kernel/debug/debug_core.c
index 0506d44..d9d72e4 100644
--- a/kernel/debug/debug_core.c
+++ b/kernel/debug/debug_core.c
@@ -221,13 +221,26 @@ int __weak kgdb_skipexception(int exception, struct pt_regs *regs)
  */
 static void kgdb_flush_swbreak_addr(unsigned long addr)
 {
+	struct mm_struct *mm = current->mm;
 	if (!CACHE_FLUSH_IS_SAFE)
 		return;
 
-	if (current->mm && current->mm->mmap_cache) {
-		flush_cache_range(current->mm->mmap_cache,
+#ifdef CONFIG_MMU
+	if (mm) {
+		int i;
+
+		for (i = 0; i < NR_VMA_CACHES; i++)
+			if (mm->mmap_cache[i])
+				flush_cache_range(mm->mmap_cache[i],
+						  addr,
+						  addr + BREAK_INSTR_SIZE);
+	}
+#else
+	if (mm && mm->mmap_cache) {
+		flush_cache_range(mm->mmap_cache,
 				  addr, addr + BREAK_INSTR_SIZE);
 	}
+#endif
 	/* Force flush instruction cache if it was outside the mm */
 	flush_icache_range(addr, addr + BREAK_INSTR_SIZE);
 }
diff --git a/kernel/fork.c b/kernel/fork.c
index 086fe73..7b92666 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -363,8 +363,8 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 
 	mm->locked_vm = 0;
 	mm->mmap = NULL;
-	mm->mmap_cache = NULL;
 	mm->map_count = 0;
+	vma_clear_caches(mm);
 	cpumask_clear(mm_cpumask(mm));
 	mm->mm_rb = RB_ROOT;
 	rb_link = &mm->mm_rb.rb_node;
diff --git a/mm/mmap.c b/mm/mmap.c
index 9d54851..29c3fc0 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -676,14 +676,17 @@ static inline void
 __vma_unlink(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct vm_area_struct *prev)
 {
+	int i;
 	struct vm_area_struct *next;
 
 	vma_rb_erase(vma, &mm->mm_rb);
 	prev->vm_next = next = vma->vm_next;
 	if (next)
 		next->vm_prev = prev;
-	if (mm->mmap_cache == vma)
-		mm->mmap_cache = prev;
+
+	for (i = 0; i < NR_VMA_CACHES; i++)
+		if (mm->mmap_cache[i] == vma)
+			mm->mmap_cache[i] = prev;
 }
 
 /*
@@ -1972,34 +1975,47 @@ EXPORT_SYMBOL(get_unmapped_area);
 /* Look up the first VMA which satisfies  addr < vm_end,  NULL if none. */
 struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
 {
+	unsigned long currlen = 0;
+	struct rb_node *rb_node;
 	struct vm_area_struct *vma = NULL;
 
-	/* Check the cache first. */
-	/* (Cache hit rate is typically around 35%.) */
-	vma = ACCESS_ONCE(mm->mmap_cache);
-	if (!(vma && vma->vm_end > addr && vma->vm_start <= addr)) {
-		struct rb_node *rb_node;
+	/* Check the cache first */
+	vma = ACCESS_ONCE(mm->mmap_cache[VMA_LAST_USED]);
+	if (vma && vma->vm_end > addr && vma->vm_start <= addr)
+		goto ret;
 
-		rb_node = mm->mm_rb.rb_node;
-		vma = NULL;
+	vma = ACCESS_ONCE(mm->mmap_cache[VMA_LARGEST]);
+	if (vma) {
+		if (vma->vm_end > addr && vma->vm_start <= addr)
+			goto ret;
+		currlen = vma->vm_end - vma->vm_start;
+	}
 
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
+	/* Bad cache! iterate rbtree */
+	rb_node = mm->mm_rb.rb_node;
+	vma = NULL;
+
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
+	}
+
+	if (vma) {
+		ACCESS_ONCE(mm->mmap_cache[VMA_LAST_USED]) = vma;
+		if (vma->vm_end - vma->vm_start > currlen)
+			ACCESS_ONCE(mm->mmap_cache[VMA_LARGEST]) = vma;
 	}
+ret:
 	return vma;
 }
 
@@ -2371,7 +2387,7 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
 	} else
 		mm->highest_vm_end = prev ? prev->vm_end : 0;
 	tail_vma->vm_next = NULL;
-	mm->mmap_cache = NULL;		/* Kill the cache. */
+	vma_clear_caches(mm);
 }
 
 /*
-- 
1.8.1.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
