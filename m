Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7B86D6B03A0
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 18:01:59 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z36so29788085wrc.14
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 15:01:59 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id g80si21579241wme.112.2017.04.04.15.01.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 15:01:57 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 3/4] mm: memcontrol: re-use node VM page state enum
Date: Tue,  4 Apr 2017 18:01:47 -0400
Message-Id: <20170404220148.28338-3-hannes@cmpxchg.org>
In-Reply-To: <20170404220148.28338-1-hannes@cmpxchg.org>
References: <20170404220148.28338-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

The current duplication is a high-maintenance mess, and it's painful
to add new items or query memcg state from the rest of the VM.

This increases the size of the stat array marginally, but we should
aim to track all these stats on a per-cgroup level anyway.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 100 +++++++++++++++------------------
 mm/memcontrol.c            | 135 +++++++++++++++++++++++----------------------
 mm/page-writeback.c        |  10 ++--
 mm/rmap.c                  |   4 +-
 mm/vmscan.c                |   5 +-
 mm/workingset.c            |   7 +--
 6 files changed, 123 insertions(+), 138 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 0bb5f055bd26..0fa1f5de6841 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -35,40 +35,45 @@ struct page;
 struct mm_struct;
 struct kmem_cache;
 
-/*
- * The corresponding mem_cgroup_stat_names is defined in mm/memcontrol.c,
- * These two lists should keep in accord with each other.
- */
-enum mem_cgroup_stat_index {
-	/*
-	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
-	 */
-	MEM_CGROUP_STAT_CACHE,		/* # of pages charged as cache */
-	MEM_CGROUP_STAT_RSS,		/* # of pages charged as anon rss */
-	MEM_CGROUP_STAT_RSS_HUGE,	/* # of pages charged as anon huge */
-	MEM_CGROUP_STAT_SHMEM,		/* # of pages charged as shmem */
-	MEM_CGROUP_STAT_FILE_MAPPED,	/* # of pages charged as file rss */
-	MEM_CGROUP_STAT_DIRTY,          /* # of dirty pages in page cache */
-	MEM_CGROUP_STAT_WRITEBACK,	/* # of pages under writeback */
-	MEM_CGROUP_STAT_SWAP,		/* # of pages, swapped out */
-	MEM_CGROUP_STAT_NSTATS,
-	/* default hierarchy stats */
-	MEMCG_KERNEL_STACK_KB = MEM_CGROUP_STAT_NSTATS,
+/* Cgroup-specific page state, on top of universal node page state */
+enum memcg_stat_item {
+	MEMCG_CACHE = NR_VM_NODE_STAT_ITEMS,
+	MEMCG_RSS,
+	MEMCG_RSS_HUGE,
+	MEMCG_SWAP,
+	MEMCG_SOCK,
+	/* XXX: why are these zone and not node counters? */
+	MEMCG_KERNEL_STACK_KB,
 	MEMCG_SLAB_RECLAIMABLE,
 	MEMCG_SLAB_UNRECLAIMABLE,
-	MEMCG_SOCK,
-	MEMCG_WORKINGSET_REFAULT,
-	MEMCG_WORKINGSET_ACTIVATE,
-	MEMCG_WORKINGSET_NODERECLAIM,
 	MEMCG_NR_STAT,
 };
 
+/* Cgroup-specific events, on top of universal VM events */
+enum memcg_event_item {
+	MEMCG_LOW = NR_VM_EVENT_ITEMS,
+	MEMCG_HIGH,
+	MEMCG_MAX,
+	MEMCG_OOM,
+	MEMCG_NR_EVENTS,
+};
+
 struct mem_cgroup_reclaim_cookie {
 	pg_data_t *pgdat;
 	int priority;
 	unsigned int generation;
 };
 
+#ifdef CONFIG_MEMCG
+
+#define MEM_CGROUP_ID_SHIFT	16
+#define MEM_CGROUP_ID_MAX	USHRT_MAX
+
+struct mem_cgroup_id {
+	int id;
+	atomic_t ref;
+};
+
 /*
  * Per memcg event counter is incremented at every pagein/pageout. With THP,
  * it will be incremated by the number of pages. This counter is used for
@@ -82,25 +87,6 @@ enum mem_cgroup_events_target {
 	MEM_CGROUP_NTARGETS,
 };
 
-#ifdef CONFIG_MEMCG
-
-#define MEM_CGROUP_ID_SHIFT	16
-#define MEM_CGROUP_ID_MAX	USHRT_MAX
-
-struct mem_cgroup_id {
-	int id;
-	atomic_t ref;
-};
-
-/* Cgroup-specific events, on top of universal VM events */
-enum memcg_event_item {
-	MEMCG_LOW = NR_VM_EVENT_ITEMS,
-	MEMCG_HIGH,
-	MEMCG_MAX,
-	MEMCG_OOM,
-	MEMCG_NR_EVENTS,
-};
-
 struct mem_cgroup_stat_cpu {
 	long count[MEMCG_NR_STAT];
 	unsigned long events[MEMCG_NR_EVENTS];
@@ -487,7 +473,7 @@ void lock_page_memcg(struct page *page);
 void unlock_page_memcg(struct page *page);
 
 static inline unsigned long mem_cgroup_read_stat(struct mem_cgroup *memcg,
-						 enum mem_cgroup_stat_index idx)
+						 enum memcg_stat_item idx)
 {
 	long val = 0;
 	int cpu;
@@ -502,20 +488,20 @@ static inline unsigned long mem_cgroup_read_stat(struct mem_cgroup *memcg,
 }
 
 static inline void mem_cgroup_update_stat(struct mem_cgroup *memcg,
-				   enum mem_cgroup_stat_index idx, int val)
+					  enum memcg_stat_item idx, int val)
 {
 	if (!mem_cgroup_disabled())
 		this_cpu_add(memcg->stat->count[idx], val);
 }
 
 static inline void mem_cgroup_inc_stat(struct mem_cgroup *memcg,
-				   enum mem_cgroup_stat_index idx)
+				       enum memcg_stat_item idx)
 {
 	mem_cgroup_update_stat(memcg, idx, 1);
 }
 
 static inline void mem_cgroup_dec_stat(struct mem_cgroup *memcg,
-				   enum mem_cgroup_stat_index idx)
+				       enum memcg_stat_item idx)
 {
 	mem_cgroup_update_stat(memcg, idx, -1);
 }
@@ -538,20 +524,20 @@ static inline void mem_cgroup_dec_stat(struct mem_cgroup *memcg,
  * Kernel pages are an exception to this, since they'll never move.
  */
 static inline void mem_cgroup_update_page_stat(struct page *page,
-				 enum mem_cgroup_stat_index idx, int val)
+				 enum memcg_stat_item idx, int val)
 {
 	if (page->mem_cgroup)
 		mem_cgroup_update_stat(page->mem_cgroup, idx, val);
 }
 
 static inline void mem_cgroup_inc_page_stat(struct page *page,
-					    enum mem_cgroup_stat_index idx)
+					    enum memcg_stat_item idx)
 {
 	mem_cgroup_update_page_stat(page, idx, 1);
 }
 
 static inline void mem_cgroup_dec_page_stat(struct page *page,
-					    enum mem_cgroup_stat_index idx)
+					    enum memcg_stat_item idx)
 {
 	mem_cgroup_update_page_stat(page, idx, -1);
 }
@@ -760,33 +746,33 @@ static inline unsigned long mem_cgroup_read_stat(struct mem_cgroup *memcg,
 }
 
 static inline void mem_cgroup_update_stat(struct mem_cgroup *memcg,
-				   enum mem_cgroup_stat_index idx, int val)
+					  enum memcg_stat_item idx, int val)
 {
 }
 
 static inline void mem_cgroup_inc_stat(struct mem_cgroup *memcg,
-				   enum mem_cgroup_stat_index idx)
+				       enum memcg_stat_item idx)
 {
 }
 
 static inline void mem_cgroup_dec_stat(struct mem_cgroup *memcg,
-				   enum mem_cgroup_stat_index idx)
+				       enum memcg_stat_item idx)
 {
 }
 
 static inline void mem_cgroup_update_page_stat(struct page *page,
-					       enum mem_cgroup_stat_index idx,
+					       enum memcg_stat_item idx,
 					       int nr)
 {
 }
 
 static inline void mem_cgroup_inc_page_stat(struct page *page,
-					    enum mem_cgroup_stat_index idx)
+					    enum memcg_stat_item idx)
 {
 }
 
 static inline void mem_cgroup_dec_page_stat(struct page *page,
-					    enum mem_cgroup_stat_index idx)
+					    enum memcg_stat_item idx)
 {
 }
 
@@ -906,7 +892,7 @@ static inline int memcg_cache_id(struct mem_cgroup *memcg)
  * @val: number of pages (positive or negative)
  */
 static inline void memcg_kmem_update_page_stat(struct page *page,
-				enum mem_cgroup_stat_index idx, int val)
+				enum memcg_stat_item idx, int val)
 {
 	if (memcg_kmem_enabled() && page->mem_cgroup)
 		this_cpu_add(page->mem_cgroup->stat->count[idx], val);
@@ -935,7 +921,7 @@ static inline void memcg_put_cache_ids(void)
 }
 
 static inline void memcg_kmem_update_page_stat(struct page *page,
-				enum mem_cgroup_stat_index idx, int val)
+				enum memcg_stat_item idx, int val)
 {
 }
 #endif /* CONFIG_MEMCG && !CONFIG_SLOB */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6b42887e5f14..6fe4c7fafbfc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -100,18 +100,7 @@ static bool do_memsw_account(void)
 	return !cgroup_subsys_on_dfl(memory_cgrp_subsys) && do_swap_account;
 }
 
-static const char * const mem_cgroup_stat_names[] = {
-	"cache",
-	"rss",
-	"rss_huge",
-	"shmem",
-	"mapped_file",
-	"dirty",
-	"writeback",
-	"swap",
-};
-
-static const char * const mem_cgroup_lru_names[] = {
+static const char *const mem_cgroup_lru_names[] = {
 	"inactive_anon",
 	"active_anon",
 	"inactive_file",
@@ -583,20 +572,16 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
 	 * counted as CACHE even if it's on ANON LRU.
 	 */
 	if (PageAnon(page))
-		__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_RSS],
-				nr_pages);
+		__this_cpu_add(memcg->stat->count[MEMCG_RSS], nr_pages);
 	else {
-		__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_CACHE],
-				nr_pages);
+		__this_cpu_add(memcg->stat->count[MEMCG_CACHE], nr_pages);
 		if (PageSwapBacked(page))
-			__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_SHMEM],
-				       nr_pages);
+			__this_cpu_add(memcg->stat->count[NR_SHMEM], nr_pages);
 	}
 
 	if (compound) {
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
-		__this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_RSS_HUGE],
-				nr_pages);
+		__this_cpu_add(memcg->stat->count[MEMCG_RSS_HUGE], nr_pages);
 	}
 
 	/* pagein of a big page is an event. So, ignore page size */
@@ -1125,6 +1110,28 @@ static bool mem_cgroup_wait_acct_move(struct mem_cgroup *memcg)
 	return false;
 }
 
+unsigned int memcg1_stats[] = {
+	MEMCG_CACHE,
+	MEMCG_RSS,
+	MEMCG_RSS_HUGE,
+	NR_SHMEM,
+	NR_FILE_MAPPED,
+	NR_FILE_DIRTY,
+	NR_WRITEBACK,
+	MEMCG_SWAP,
+};
+
+static const char *const memcg1_stat_names[] = {
+	"cache",
+	"rss",
+	"rss_huge",
+	"shmem",
+	"mapped_file",
+	"dirty",
+	"writeback",
+	"swap",
+};
+
 #define K(x) ((x) << (PAGE_SHIFT-10))
 /**
  * mem_cgroup_print_oom_info: Print OOM information relevant to memory controller.
@@ -1169,11 +1176,11 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 		pr_cont_cgroup_path(iter->css.cgroup);
 		pr_cont(":");
 
-		for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
-			if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
+		for (i = 0; i < ARRAY_SIZE(memcg1_stats); i++) {
+			if (memcg1_stats[i] == MEMCG_SWAP && !do_swap_account)
 				continue;
-			pr_cont(" %s:%luKB", mem_cgroup_stat_names[i],
-				K(mem_cgroup_read_stat(iter, i)));
+			pr_cont(" %s:%luKB", memcg1_stat_names[i],
+				K(mem_cgroup_read_stat(iter, memcg1_stats[i])));
 		}
 
 		for (i = 0; i < NR_LRU_LISTS; i++)
@@ -2362,7 +2369,7 @@ void mem_cgroup_split_huge_fixup(struct page *head)
 	for (i = 1; i < HPAGE_PMD_NR; i++)
 		head[i].mem_cgroup = head->mem_cgroup;
 
-	__this_cpu_sub(head->mem_cgroup->stat->count[MEM_CGROUP_STAT_RSS_HUGE],
+	__this_cpu_sub(head->mem_cgroup->stat->count[MEMCG_RSS_HUGE],
 		       HPAGE_PMD_NR);
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
@@ -2372,7 +2379,7 @@ static void mem_cgroup_swap_statistics(struct mem_cgroup *memcg,
 					 bool charge)
 {
 	int val = (charge) ? 1 : -1;
-	this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_SWAP], val);
+	this_cpu_add(memcg->stat->count[MEMCG_SWAP], val);
 }
 
 /**
@@ -2731,13 +2738,10 @@ static unsigned long mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
 		struct mem_cgroup *iter;
 
 		for_each_mem_cgroup_tree(iter, memcg) {
-			val += mem_cgroup_read_stat(iter,
-					MEM_CGROUP_STAT_CACHE);
-			val += mem_cgroup_read_stat(iter,
-					MEM_CGROUP_STAT_RSS);
+			val += mem_cgroup_read_stat(iter, MEMCG_CACHE);
+			val += mem_cgroup_read_stat(iter, MEMCG_RSS);
 			if (swap)
-				val += mem_cgroup_read_stat(iter,
-						MEM_CGROUP_STAT_SWAP);
+				val += mem_cgroup_read_stat(iter, MEMCG_SWAP);
 		}
 	} else {
 		if (!swap)
@@ -3134,15 +3138,15 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 	struct mem_cgroup *mi;
 	unsigned int i;
 
-	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_stat_names) !=
-		     MEM_CGROUP_STAT_NSTATS);
+	BUILD_BUG_ON(ARRAY_SIZE(memcg1_stat_names) != ARRAY_SIZE(memcg1_stats));
 	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_lru_names) != NR_LRU_LISTS);
 
-	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
-		if (i == MEM_CGROUP_STAT_SWAP && !do_memsw_account())
+	for (i = 0; i < ARRAY_SIZE(memcg1_stats); i++) {
+		if (memcg1_stats[i] == MEMCG_SWAP && !do_memsw_account())
 			continue;
-		seq_printf(m, "%s %lu\n", mem_cgroup_stat_names[i],
-			   mem_cgroup_read_stat(memcg, i) * PAGE_SIZE);
+		seq_printf(m, "%s %lu\n", memcg1_stat_names[i],
+			   mem_cgroup_read_stat(memcg, memcg1_stats[i]) *
+			   PAGE_SIZE);
 	}
 
 	for (i = 0; i < ARRAY_SIZE(memcg1_events); i++)
@@ -3165,14 +3169,15 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 		seq_printf(m, "hierarchical_memsw_limit %llu\n",
 			   (u64)memsw * PAGE_SIZE);
 
-	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
+	for (i = 0; i < ARRAY_SIZE(memcg1_stats); i++) {
 		unsigned long long val = 0;
 
-		if (i == MEM_CGROUP_STAT_SWAP && !do_memsw_account())
+		if (memcg1_stats[i] == MEMCG_SWAP && !do_memsw_account())
 			continue;
 		for_each_mem_cgroup_tree(mi, memcg)
-			val += mem_cgroup_read_stat(mi, i) * PAGE_SIZE;
-		seq_printf(m, "total_%s %llu\n", mem_cgroup_stat_names[i], val);
+			val += mem_cgroup_read_stat(mi, memcg1_stats[i]) *
+			PAGE_SIZE;
+		seq_printf(m, "total_%s %llu\n", memcg1_stat_names[i], val);
 	}
 
 	for (i = 0; i < ARRAY_SIZE(memcg1_events); i++) {
@@ -3645,10 +3650,10 @@ void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
 	struct mem_cgroup *memcg = mem_cgroup_from_css(wb->memcg_css);
 	struct mem_cgroup *parent;
 
-	*pdirty = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_DIRTY);
+	*pdirty = mem_cgroup_read_stat(memcg, NR_FILE_DIRTY);
 
 	/* this should eventually include NR_UNSTABLE_NFS */
-	*pwriteback = mem_cgroup_read_stat(memcg, MEM_CGROUP_STAT_WRITEBACK);
+	*pwriteback = mem_cgroup_read_stat(memcg, NR_WRITEBACK);
 	*pfilepages = mem_cgroup_nr_lru_pages(memcg, (1 << LRU_INACTIVE_FILE) |
 						     (1 << LRU_ACTIVE_FILE));
 	*pheadroom = PAGE_COUNTER_MAX;
@@ -4504,10 +4509,8 @@ static int mem_cgroup_move_account(struct page *page,
 	spin_lock_irqsave(&from->move_lock, flags);
 
 	if (!anon && page_mapped(page)) {
-		__this_cpu_sub(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED],
-			       nr_pages);
-		__this_cpu_add(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED],
-			       nr_pages);
+		__this_cpu_sub(from->stat->count[NR_FILE_MAPPED], nr_pages);
+		__this_cpu_add(to->stat->count[NR_FILE_MAPPED], nr_pages);
 	}
 
 	/*
@@ -4519,18 +4522,16 @@ static int mem_cgroup_move_account(struct page *page,
 		struct address_space *mapping = page_mapping(page);
 
 		if (mapping_cap_account_dirty(mapping)) {
-			__this_cpu_sub(from->stat->count[MEM_CGROUP_STAT_DIRTY],
+			__this_cpu_sub(from->stat->count[NR_FILE_DIRTY],
 				       nr_pages);
-			__this_cpu_add(to->stat->count[MEM_CGROUP_STAT_DIRTY],
+			__this_cpu_add(to->stat->count[NR_FILE_DIRTY],
 				       nr_pages);
 		}
 	}
 
 	if (PageWriteback(page)) {
-		__this_cpu_sub(from->stat->count[MEM_CGROUP_STAT_WRITEBACK],
-			       nr_pages);
-		__this_cpu_add(to->stat->count[MEM_CGROUP_STAT_WRITEBACK],
-			       nr_pages);
+		__this_cpu_sub(from->stat->count[NR_WRITEBACK], nr_pages);
+		__this_cpu_add(to->stat->count[NR_WRITEBACK], nr_pages);
 	}
 
 	/*
@@ -5190,9 +5191,9 @@ static int memory_stat_show(struct seq_file *m, void *v)
 	tree_events(memcg, events);
 
 	seq_printf(m, "anon %llu\n",
-		   (u64)stat[MEM_CGROUP_STAT_RSS] * PAGE_SIZE);
+		   (u64)stat[MEMCG_RSS] * PAGE_SIZE);
 	seq_printf(m, "file %llu\n",
-		   (u64)stat[MEM_CGROUP_STAT_CACHE] * PAGE_SIZE);
+		   (u64)stat[MEMCG_CACHE] * PAGE_SIZE);
 	seq_printf(m, "kernel_stack %llu\n",
 		   (u64)stat[MEMCG_KERNEL_STACK_KB] * 1024);
 	seq_printf(m, "slab %llu\n",
@@ -5202,13 +5203,13 @@ static int memory_stat_show(struct seq_file *m, void *v)
 		   (u64)stat[MEMCG_SOCK] * PAGE_SIZE);
 
 	seq_printf(m, "shmem %llu\n",
-		   (u64)stat[MEM_CGROUP_STAT_SHMEM] * PAGE_SIZE);
+		   (u64)stat[NR_SHMEM] * PAGE_SIZE);
 	seq_printf(m, "file_mapped %llu\n",
-		   (u64)stat[MEM_CGROUP_STAT_FILE_MAPPED] * PAGE_SIZE);
+		   (u64)stat[NR_FILE_MAPPED] * PAGE_SIZE);
 	seq_printf(m, "file_dirty %llu\n",
-		   (u64)stat[MEM_CGROUP_STAT_DIRTY] * PAGE_SIZE);
+		   (u64)stat[NR_FILE_DIRTY] * PAGE_SIZE);
 	seq_printf(m, "file_writeback %llu\n",
-		   (u64)stat[MEM_CGROUP_STAT_WRITEBACK] * PAGE_SIZE);
+		   (u64)stat[NR_WRITEBACK] * PAGE_SIZE);
 
 	for (i = 0; i < NR_LRU_LISTS; i++) {
 		struct mem_cgroup *mi;
@@ -5231,11 +5232,11 @@ static int memory_stat_show(struct seq_file *m, void *v)
 	seq_printf(m, "pgmajfault %lu\n", events[PGMAJFAULT]);
 
 	seq_printf(m, "workingset_refault %lu\n",
-		   stat[MEMCG_WORKINGSET_REFAULT]);
+		   stat[WORKINGSET_REFAULT]);
 	seq_printf(m, "workingset_activate %lu\n",
-		   stat[MEMCG_WORKINGSET_ACTIVATE]);
+		   stat[WORKINGSET_ACTIVATE]);
 	seq_printf(m, "workingset_nodereclaim %lu\n",
-		   stat[MEMCG_WORKINGSET_NODERECLAIM]);
+		   stat[WORKINGSET_NODERECLAIM]);
 
 	return 0;
 }
@@ -5492,10 +5493,10 @@ static void uncharge_batch(struct mem_cgroup *memcg, unsigned long pgpgout,
 	}
 
 	local_irq_save(flags);
-	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_RSS], nr_anon);
-	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_CACHE], nr_file);
-	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_RSS_HUGE], nr_huge);
-	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_SHMEM], nr_shmem);
+	__this_cpu_sub(memcg->stat->count[MEMCG_RSS], nr_anon);
+	__this_cpu_sub(memcg->stat->count[MEMCG_CACHE], nr_file);
+	__this_cpu_sub(memcg->stat->count[MEMCG_RSS_HUGE], nr_huge);
+	__this_cpu_sub(memcg->stat->count[NR_SHMEM], nr_shmem);
 	__this_cpu_add(memcg->stat->events[PGPGOUT], pgpgout);
 	__this_cpu_add(memcg->stat->nr_page_events, nr_pages);
 	memcg_check_events(memcg, dummy_page);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 33df0583edb9..777711203809 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2427,7 +2427,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 		inode_attach_wb(inode, page);
 		wb = inode_to_wb(inode);
 
-		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_DIRTY);
+		mem_cgroup_inc_page_stat(page, NR_FILE_DIRTY);
 		__inc_node_page_state(page, NR_FILE_DIRTY);
 		__inc_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 		__inc_node_page_state(page, NR_DIRTIED);
@@ -2449,7 +2449,7 @@ void account_page_cleaned(struct page *page, struct address_space *mapping,
 			  struct bdi_writeback *wb)
 {
 	if (mapping_cap_account_dirty(mapping)) {
-		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_DIRTY);
+		mem_cgroup_dec_page_stat(page, NR_FILE_DIRTY);
 		dec_node_page_state(page, NR_FILE_DIRTY);
 		dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 		dec_wb_stat(wb, WB_RECLAIMABLE);
@@ -2706,7 +2706,7 @@ int clear_page_dirty_for_io(struct page *page)
 		 */
 		wb = unlocked_inode_to_wb_begin(inode, &locked);
 		if (TestClearPageDirty(page)) {
-			mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_DIRTY);
+			mem_cgroup_dec_page_stat(page, NR_FILE_DIRTY);
 			dec_node_page_state(page, NR_FILE_DIRTY);
 			dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 			dec_wb_stat(wb, WB_RECLAIMABLE);
@@ -2753,7 +2753,7 @@ int test_clear_page_writeback(struct page *page)
 		ret = TestClearPageWriteback(page);
 	}
 	if (ret) {
-		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
+		mem_cgroup_dec_page_stat(page, NR_WRITEBACK);
 		dec_node_page_state(page, NR_WRITEBACK);
 		dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 		inc_node_page_state(page, NR_WRITTEN);
@@ -2808,7 +2808,7 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 		ret = TestSetPageWriteback(page);
 	}
 	if (!ret) {
-		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
+		mem_cgroup_inc_page_stat(page, NR_WRITEBACK);
 		inc_node_page_state(page, NR_WRITEBACK);
 		inc_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 	}
diff --git a/mm/rmap.c b/mm/rmap.c
index a69a2a70d057..f6bbfcf01422 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1158,7 +1158,7 @@ void page_add_file_rmap(struct page *page, bool compound)
 			goto out;
 	}
 	__mod_node_page_state(page_pgdat(page), NR_FILE_MAPPED, nr);
-	mem_cgroup_update_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED, nr);
+	mem_cgroup_update_page_stat(page, NR_FILE_MAPPED, nr);
 out:
 	unlock_page_memcg(page);
 }
@@ -1198,7 +1198,7 @@ static void page_remove_file_rmap(struct page *page, bool compound)
 	 * pte lock(a spinlock) is held, which implies preemption disabled.
 	 */
 	__mod_node_page_state(page_pgdat(page), NR_FILE_MAPPED, -nr);
-	mem_cgroup_update_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED, -nr);
+	mem_cgroup_update_page_stat(page, NR_FILE_MAPPED, -nr);
 
 	if (unlikely(PageMlocked(page)))
 		clear_page_mlock(page);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 18731310ca36..d77c97552ed3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2046,8 +2046,7 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 	active = lruvec_lru_size(lruvec, active_lru, sc->reclaim_idx);
 
 	if (memcg)
-		refaults = mem_cgroup_read_stat(memcg,
-						MEMCG_WORKINGSET_ACTIVATE);
+		refaults = mem_cgroup_read_stat(memcg, WORKINGSET_ACTIVATE);
 	else
 		refaults = node_page_state(pgdat, WORKINGSET_ACTIVATE);
 
@@ -2742,7 +2741,7 @@ static void snapshot_refaults(struct mem_cgroup *root_memcg, pg_data_t *pgdat)
 
 		if (memcg)
 			refaults = mem_cgroup_read_stat(memcg,
-						MEMCG_WORKINGSET_ACTIVATE);
+							WORKINGSET_ACTIVATE);
 		else
 			refaults = node_page_state(pgdat, WORKINGSET_ACTIVATE);
 
diff --git a/mm/workingset.c b/mm/workingset.c
index 51c6f61d4cea..37fc1057cd86 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -289,11 +289,11 @@ bool workingset_refault(void *shadow)
 	refault_distance = (refault - eviction) & EVICTION_MASK;
 
 	inc_node_state(pgdat, WORKINGSET_REFAULT);
-	mem_cgroup_inc_stat(memcg, MEMCG_WORKINGSET_REFAULT);
+	mem_cgroup_inc_stat(memcg, WORKINGSET_REFAULT);
 
 	if (refault_distance <= active_file) {
 		inc_node_state(pgdat, WORKINGSET_ACTIVATE);
-		mem_cgroup_inc_stat(memcg, MEMCG_WORKINGSET_ACTIVATE);
+		mem_cgroup_inc_stat(memcg, WORKINGSET_ACTIVATE);
 		rcu_read_unlock();
 		return true;
 	}
@@ -475,8 +475,7 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 	if (WARN_ON_ONCE(node->exceptional))
 		goto out_invalid;
 	inc_node_state(page_pgdat(virt_to_page(node)), WORKINGSET_NODERECLAIM);
-	mem_cgroup_inc_page_stat(virt_to_page(node),
-				 MEMCG_WORKINGSET_NODERECLAIM);
+	mem_cgroup_inc_page_stat(virt_to_page(node), WORKINGSET_NODERECLAIM);
 	__radix_tree_delete_node(&mapping->page_tree, node,
 				 workingset_update_node, mapping);
 
-- 
2.12.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
