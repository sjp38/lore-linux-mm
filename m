Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E351C6B0007
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 15:00:11 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x20so2220706wmc.0
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 12:00:11 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id x21si6039540edm.203.2018.04.05.12.00.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 12:00:09 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH v3 1/4] mm: rename page_counter's count/limit into usage/max
Date: Thu, 5 Apr 2018 19:59:18 +0100
Message-ID: <20180405185921.4942-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

This patch renames struct page_counter fields:
  count -> usage
  limit -> max

and the corresponding functions:
  page_counter_limit() -> page_counter_set_max()
  mem_cgroup_get_limit() -> mem_cgroup_get_max()
  mem_cgroup_resize_limit() -> mem_cgroup_resize_max()
  memcg_update_kmem_limit() -> memcg_update_kmem_max()
  memcg_update_tcp_limit() -> memcg_update_tcp_max()

The idea behind this renaming is to have the direct matching
between memory cgroup knobs (low, high, max) and page_counters API.

This is pure renaming, this patch doesn't bring any functional change.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: kernel-team@fb.com
Cc: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 include/linux/memcontrol.h   |   4 +-
 include/linux/page_counter.h |  12 ++---
 mm/hugetlb_cgroup.c          |   6 +--
 mm/memcontrol.c              | 112 +++++++++++++++++++++----------------------
 mm/oom_kill.c                |   2 +-
 mm/page_counter.c            |  28 +++++------
 6 files changed, 82 insertions(+), 82 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 44422e1d3def..caa31cc09e7e 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -475,7 +475,7 @@ unsigned long mem_cgroup_get_zone_lru_size(struct lruvec *lruvec,
 
 void mem_cgroup_handle_over_high(void);
 
-unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg);
+unsigned long mem_cgroup_get_max(struct mem_cgroup *memcg);
 
 void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 				struct task_struct *p);
@@ -882,7 +882,7 @@ mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
 	return 0;
 }
 
-static inline unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg)
+static inline unsigned long mem_cgroup_get_max(struct mem_cgroup *memcg)
 {
 	return 0;
 }
diff --git a/include/linux/page_counter.h b/include/linux/page_counter.h
index c15ab80ad32d..94029dad9317 100644
--- a/include/linux/page_counter.h
+++ b/include/linux/page_counter.h
@@ -7,8 +7,8 @@
 #include <asm/page.h>
 
 struct page_counter {
-	atomic_long_t count;
-	unsigned long limit;
+	atomic_long_t usage;
+	unsigned long max;
 	struct page_counter *parent;
 
 	/* legacy */
@@ -25,14 +25,14 @@ struct page_counter {
 static inline void page_counter_init(struct page_counter *counter,
 				     struct page_counter *parent)
 {
-	atomic_long_set(&counter->count, 0);
-	counter->limit = PAGE_COUNTER_MAX;
+	atomic_long_set(&counter->usage, 0);
+	counter->max = PAGE_COUNTER_MAX;
 	counter->parent = parent;
 }
 
 static inline unsigned long page_counter_read(struct page_counter *counter)
 {
-	return atomic_long_read(&counter->count);
+	return atomic_long_read(&counter->usage);
 }
 
 void page_counter_cancel(struct page_counter *counter, unsigned long nr_pages);
@@ -41,7 +41,7 @@ bool page_counter_try_charge(struct page_counter *counter,
 			     unsigned long nr_pages,
 			     struct page_counter **fail);
 void page_counter_uncharge(struct page_counter *counter, unsigned long nr_pages);
-int page_counter_limit(struct page_counter *counter, unsigned long limit);
+int page_counter_set_max(struct page_counter *counter, unsigned long nr_pages);
 int page_counter_memparse(const char *buf, const char *max,
 			  unsigned long *nr_pages);
 
diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index eec1150125b9..68c2f2f3c05b 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -84,7 +84,7 @@ static void hugetlb_cgroup_init(struct hugetlb_cgroup *h_cgroup,
 
 		limit = round_down(PAGE_COUNTER_MAX,
 				   1 << huge_page_order(&hstates[idx]));
-		ret = page_counter_limit(counter, limit);
+		ret = page_counter_set_max(counter, limit);
 		VM_BUG_ON(ret);
 	}
 }
@@ -273,7 +273,7 @@ static u64 hugetlb_cgroup_read_u64(struct cgroup_subsys_state *css,
 	case RES_USAGE:
 		return (u64)page_counter_read(counter) * PAGE_SIZE;
 	case RES_LIMIT:
-		return (u64)counter->limit * PAGE_SIZE;
+		return (u64)counter->max * PAGE_SIZE;
 	case RES_MAX_USAGE:
 		return (u64)counter->watermark * PAGE_SIZE;
 	case RES_FAILCNT:
@@ -306,7 +306,7 @@ static ssize_t hugetlb_cgroup_write(struct kernfs_open_file *of,
 	switch (MEMFILE_ATTR(of_cft(of)->private)) {
 	case RES_LIMIT:
 		mutex_lock(&hugetlb_limit_mutex);
-		ret = page_counter_limit(&h_cg->hugepage[idx], nr_pages);
+		ret = page_counter_set_max(&h_cg->hugepage[idx], nr_pages);
 		mutex_unlock(&hugetlb_limit_mutex);
 		break;
 	default:
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 18dda3f113bd..50d1ad6a8fdb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1033,13 +1033,13 @@ static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
 	unsigned long limit;
 
 	count = page_counter_read(&memcg->memory);
-	limit = READ_ONCE(memcg->memory.limit);
+	limit = READ_ONCE(memcg->memory.max);
 	if (count < limit)
 		margin = limit - count;
 
 	if (do_memsw_account()) {
 		count = page_counter_read(&memcg->memsw);
-		limit = READ_ONCE(memcg->memsw.limit);
+		limit = READ_ONCE(memcg->memsw.max);
 		if (count <= limit)
 			margin = min(margin, limit - count);
 		else
@@ -1147,13 +1147,13 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 
 	pr_info("memory: usage %llukB, limit %llukB, failcnt %lu\n",
 		K((u64)page_counter_read(&memcg->memory)),
-		K((u64)memcg->memory.limit), memcg->memory.failcnt);
+		K((u64)memcg->memory.max), memcg->memory.failcnt);
 	pr_info("memory+swap: usage %llukB, limit %llukB, failcnt %lu\n",
 		K((u64)page_counter_read(&memcg->memsw)),
-		K((u64)memcg->memsw.limit), memcg->memsw.failcnt);
+		K((u64)memcg->memsw.max), memcg->memsw.failcnt);
 	pr_info("kmem: usage %llukB, limit %llukB, failcnt %lu\n",
 		K((u64)page_counter_read(&memcg->kmem)),
-		K((u64)memcg->kmem.limit), memcg->kmem.failcnt);
+		K((u64)memcg->kmem.max), memcg->kmem.failcnt);
 
 	for_each_mem_cgroup_tree(iter, memcg) {
 		pr_info("Memory cgroup stats for ");
@@ -1178,21 +1178,21 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 /*
  * Return the memory (and swap, if configured) limit for a memcg.
  */
-unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg)
+unsigned long mem_cgroup_get_max(struct mem_cgroup *memcg)
 {
-	unsigned long limit;
+	unsigned long max;
 
-	limit = memcg->memory.limit;
+	max = memcg->memory.max;
 	if (mem_cgroup_swappiness(memcg)) {
-		unsigned long memsw_limit;
-		unsigned long swap_limit;
+		unsigned long memsw_max;
+		unsigned long swap_max;
 
-		memsw_limit = memcg->memsw.limit;
-		swap_limit = memcg->swap.limit;
-		swap_limit = min(swap_limit, (unsigned long)total_swap_pages);
-		limit = min(limit + swap_limit, memsw_limit);
+		memsw_max = memcg->memsw.max;
+		swap_max = memcg->swap.max;
+		swap_max = min(swap_max, (unsigned long)total_swap_pages);
+		max = min(max + swap_max, memsw_max);
 	}
-	return limit;
+	return max;
 }
 
 static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
@@ -2458,10 +2458,10 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
 }
 #endif
 
-static DEFINE_MUTEX(memcg_limit_mutex);
+static DEFINE_MUTEX(memcg_max_mutex);
 
-static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
-				   unsigned long limit, bool memsw)
+static int mem_cgroup_resize_max(struct mem_cgroup *memcg,
+				 unsigned long max, bool memsw)
 {
 	bool enlarge = false;
 	int ret;
@@ -2474,22 +2474,22 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 			break;
 		}
 
-		mutex_lock(&memcg_limit_mutex);
+		mutex_lock(&memcg_max_mutex);
 		/*
 		 * Make sure that the new limit (memsw or memory limit) doesn't
-		 * break our basic invariant rule memory.limit <= memsw.limit.
+		 * break our basic invariant rule memory.max <= memsw.max.
 		 */
-		limits_invariant = memsw ? limit >= memcg->memory.limit :
-					   limit <= memcg->memsw.limit;
+		limits_invariant = memsw ? max >= memcg->memory.max :
+					   max <= memcg->memsw.max;
 		if (!limits_invariant) {
-			mutex_unlock(&memcg_limit_mutex);
+			mutex_unlock(&memcg_max_mutex);
 			ret = -EINVAL;
 			break;
 		}
-		if (limit > counter->limit)
+		if (max > counter->max)
 			enlarge = true;
-		ret = page_counter_limit(counter, limit);
-		mutex_unlock(&memcg_limit_mutex);
+		ret = page_counter_set_max(counter, max);
+		mutex_unlock(&memcg_max_mutex);
 
 		if (!ret)
 			break;
@@ -2989,7 +2989,7 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
 			return (u64)mem_cgroup_usage(memcg, true) * PAGE_SIZE;
 		return (u64)page_counter_read(counter) * PAGE_SIZE;
 	case RES_LIMIT:
-		return (u64)counter->limit * PAGE_SIZE;
+		return (u64)counter->max * PAGE_SIZE;
 	case RES_MAX_USAGE:
 		return (u64)counter->watermark * PAGE_SIZE;
 	case RES_FAILCNT:
@@ -3103,24 +3103,24 @@ static void memcg_free_kmem(struct mem_cgroup *memcg)
 }
 #endif /* !CONFIG_SLOB */
 
-static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
-				   unsigned long limit)
+static int memcg_update_kmem_max(struct mem_cgroup *memcg,
+				 unsigned long max)
 {
 	int ret;
 
-	mutex_lock(&memcg_limit_mutex);
-	ret = page_counter_limit(&memcg->kmem, limit);
-	mutex_unlock(&memcg_limit_mutex);
+	mutex_lock(&memcg_max_mutex);
+	ret = page_counter_set_max(&memcg->kmem, max);
+	mutex_unlock(&memcg_max_mutex);
 	return ret;
 }
 
-static int memcg_update_tcp_limit(struct mem_cgroup *memcg, unsigned long limit)
+static int memcg_update_tcp_max(struct mem_cgroup *memcg, unsigned long max)
 {
 	int ret;
 
-	mutex_lock(&memcg_limit_mutex);
+	mutex_lock(&memcg_max_mutex);
 
-	ret = page_counter_limit(&memcg->tcpmem, limit);
+	ret = page_counter_set_max(&memcg->tcpmem, max);
 	if (ret)
 		goto out;
 
@@ -3145,7 +3145,7 @@ static int memcg_update_tcp_limit(struct mem_cgroup *memcg, unsigned long limit)
 		memcg->tcpmem_active = true;
 	}
 out:
-	mutex_unlock(&memcg_limit_mutex);
+	mutex_unlock(&memcg_max_mutex);
 	return ret;
 }
 
@@ -3173,16 +3173,16 @@ static ssize_t mem_cgroup_write(struct kernfs_open_file *of,
 		}
 		switch (MEMFILE_TYPE(of_cft(of)->private)) {
 		case _MEM:
-			ret = mem_cgroup_resize_limit(memcg, nr_pages, false);
+			ret = mem_cgroup_resize_max(memcg, nr_pages, false);
 			break;
 		case _MEMSWAP:
-			ret = mem_cgroup_resize_limit(memcg, nr_pages, true);
+			ret = mem_cgroup_resize_max(memcg, nr_pages, true);
 			break;
 		case _KMEM:
-			ret = memcg_update_kmem_limit(memcg, nr_pages);
+			ret = memcg_update_kmem_max(memcg, nr_pages);
 			break;
 		case _TCP:
-			ret = memcg_update_tcp_limit(memcg, nr_pages);
+			ret = memcg_update_tcp_max(memcg, nr_pages);
 			break;
 		}
 		break;
@@ -3358,8 +3358,8 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 	/* Hierarchical information */
 	memory = memsw = PAGE_COUNTER_MAX;
 	for (mi = memcg; mi; mi = parent_mem_cgroup(mi)) {
-		memory = min(memory, mi->memory.limit);
-		memsw = min(memsw, mi->memsw.limit);
+		memory = min(memory, mi->memory.max);
+		memsw = min(memsw, mi->memsw.max);
 	}
 	seq_printf(m, "hierarchical_memory_limit %llu\n",
 		   (u64)memory * PAGE_SIZE);
@@ -3858,7 +3858,7 @@ void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
 	*pheadroom = PAGE_COUNTER_MAX;
 
 	while ((parent = parent_mem_cgroup(memcg))) {
-		unsigned long ceiling = min(memcg->memory.limit, memcg->high);
+		unsigned long ceiling = min(memcg->memory.max, memcg->high);
 		unsigned long used = page_counter_read(&memcg->memory);
 
 		*pheadroom = min(*pheadroom, ceiling - min(ceiling, used));
@@ -4548,12 +4548,12 @@ static void mem_cgroup_css_reset(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
-	page_counter_limit(&memcg->memory, PAGE_COUNTER_MAX);
-	page_counter_limit(&memcg->swap, PAGE_COUNTER_MAX);
-	page_counter_limit(&memcg->memsw, PAGE_COUNTER_MAX);
-	page_counter_limit(&memcg->kmem, PAGE_COUNTER_MAX);
-	page_counter_limit(&memcg->tcpmem, PAGE_COUNTER_MAX);
 	memcg->low = 0;
+	page_counter_set_max(&memcg->memory, PAGE_COUNTER_MAX);
+	page_counter_set_max(&memcg->swap, PAGE_COUNTER_MAX);
+	page_counter_set_max(&memcg->memsw, PAGE_COUNTER_MAX);
+	page_counter_set_max(&memcg->kmem, PAGE_COUNTER_MAX);
+	page_counter_set_max(&memcg->tcpmem, PAGE_COUNTER_MAX);
 	memcg->high = PAGE_COUNTER_MAX;
 	memcg->soft_limit = PAGE_COUNTER_MAX;
 	memcg_wb_domain_size_changed(memcg);
@@ -5360,7 +5360,7 @@ static ssize_t memory_high_write(struct kernfs_open_file *of,
 static int memory_max_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
-	unsigned long max = READ_ONCE(memcg->memory.limit);
+	unsigned long max = READ_ONCE(memcg->memory.max);
 
 	if (max == PAGE_COUNTER_MAX)
 		seq_puts(m, "max\n");
@@ -5384,7 +5384,7 @@ static ssize_t memory_max_write(struct kernfs_open_file *of,
 	if (err)
 		return err;
 
-	xchg(&memcg->memory.limit, max);
+	xchg(&memcg->memory.max, max);
 
 	for (;;) {
 		unsigned long nr_pages = page_counter_read(&memcg->memory);
@@ -6331,7 +6331,7 @@ long mem_cgroup_get_nr_swap_pages(struct mem_cgroup *memcg)
 		return nr_swap_pages;
 	for (; memcg != root_mem_cgroup; memcg = parent_mem_cgroup(memcg))
 		nr_swap_pages = min_t(long, nr_swap_pages,
-				      READ_ONCE(memcg->swap.limit) -
+				      READ_ONCE(memcg->swap.max) -
 				      page_counter_read(&memcg->swap));
 	return nr_swap_pages;
 }
@@ -6352,7 +6352,7 @@ bool mem_cgroup_swap_full(struct page *page)
 		return false;
 
 	for (; memcg != root_mem_cgroup; memcg = parent_mem_cgroup(memcg))
-		if (page_counter_read(&memcg->swap) * 2 >= memcg->swap.limit)
+		if (page_counter_read(&memcg->swap) * 2 >= memcg->swap.max)
 			return true;
 
 	return false;
@@ -6386,7 +6386,7 @@ static u64 swap_current_read(struct cgroup_subsys_state *css,
 static int swap_max_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
-	unsigned long max = READ_ONCE(memcg->swap.limit);
+	unsigned long max = READ_ONCE(memcg->swap.max);
 
 	if (max == PAGE_COUNTER_MAX)
 		seq_puts(m, "max\n");
@@ -6408,9 +6408,9 @@ static ssize_t swap_max_write(struct kernfs_open_file *of,
 	if (err)
 		return err;
 
-	mutex_lock(&memcg_limit_mutex);
-	err = page_counter_limit(&memcg->swap, max);
-	mutex_unlock(&memcg_limit_mutex);
+	mutex_lock(&memcg_max_mutex);
+	err = page_counter_set_max(&memcg->swap, max);
+	mutex_unlock(&memcg_max_mutex);
 	if (err)
 		return err;
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index dfd370526909..a420a703b8d5 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -256,7 +256,7 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc)
 	int nid;
 
 	if (is_memcg_oom(oc)) {
-		oc->totalpages = mem_cgroup_get_limit(oc->memcg) ?: 1;
+		oc->totalpages = mem_cgroup_get_max(oc->memcg) ?: 1;
 		return CONSTRAINT_MEMCG;
 	}
 
diff --git a/mm/page_counter.c b/mm/page_counter.c
index 2a8df3ad60a4..41937c9a9d11 100644
--- a/mm/page_counter.c
+++ b/mm/page_counter.c
@@ -22,7 +22,7 @@ void page_counter_cancel(struct page_counter *counter, unsigned long nr_pages)
 {
 	long new;
 
-	new = atomic_long_sub_return(nr_pages, &counter->count);
+	new = atomic_long_sub_return(nr_pages, &counter->usage);
 	/* More uncharges than charges? */
 	WARN_ON_ONCE(new < 0);
 }
@@ -41,7 +41,7 @@ void page_counter_charge(struct page_counter *counter, unsigned long nr_pages)
 	for (c = counter; c; c = c->parent) {
 		long new;
 
-		new = atomic_long_add_return(nr_pages, &c->count);
+		new = atomic_long_add_return(nr_pages, &c->usage);
 		/*
 		 * This is indeed racy, but we can live with some
 		 * inaccuracy in the watermark.
@@ -82,9 +82,9 @@ bool page_counter_try_charge(struct page_counter *counter,
 		 * we either see the new limit or the setter sees the
 		 * counter has changed and retries.
 		 */
-		new = atomic_long_add_return(nr_pages, &c->count);
-		if (new > c->limit) {
-			atomic_long_sub(nr_pages, &c->count);
+		new = atomic_long_add_return(nr_pages, &c->usage);
+		if (new > c->max) {
+			atomic_long_sub(nr_pages, &c->usage);
 			/*
 			 * This is racy, but we can live with some
 			 * inaccuracy in the failcnt.
@@ -123,20 +123,20 @@ void page_counter_uncharge(struct page_counter *counter, unsigned long nr_pages)
 }
 
 /**
- * page_counter_limit - limit the number of pages allowed
+ * page_counter_set_max - set the maximum number of pages allowed
  * @counter: counter
- * @limit: limit to set
+ * @nr_pages: limit to set
  *
  * Returns 0 on success, -EBUSY if the current number of pages on the
  * counter already exceeds the specified limit.
  *
  * The caller must serialize invocations on the same counter.
  */
-int page_counter_limit(struct page_counter *counter, unsigned long limit)
+int page_counter_set_max(struct page_counter *counter, unsigned long nr_pages)
 {
 	for (;;) {
 		unsigned long old;
-		long count;
+		long usage;
 
 		/*
 		 * Update the limit while making sure that it's not
@@ -149,17 +149,17 @@ int page_counter_limit(struct page_counter *counter, unsigned long limit)
 		 * the limit, so if it sees the old limit, we see the
 		 * modified counter and retry.
 		 */
-		count = atomic_long_read(&counter->count);
+		usage = atomic_long_read(&counter->usage);
 
-		if (count > limit)
+		if (usage > nr_pages)
 			return -EBUSY;
 
-		old = xchg(&counter->limit, limit);
+		old = xchg(&counter->max, nr_pages);
 
-		if (atomic_long_read(&counter->count) <= count)
+		if (atomic_long_read(&counter->usage) <= usage)
 			return 0;
 
-		counter->limit = old;
+		counter->max = old;
 		cond_resched();
 	}
 }
-- 
2.14.3
