Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 479066B0038
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 11:43:22 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id d1so7582001wiv.12
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 08:43:21 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id hg1si23746wib.76.2014.09.24.08.43.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Sep 2014 08:43:20 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/3] mm: memcontrol: lockless page counters
Date: Wed, 24 Sep 2014 11:43:08 -0400
Message-Id: <1411573390-9601-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1411573390-9601-1-git-send-email-hannes@cmpxchg.org>
References: <1411573390-9601-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Memory is internally accounted in bytes, using spinlock-protected
64-bit counters, even though the smallest accounting delta is a page.
The counter interface is also convoluted and does too many things.

Introduce a new lockless word-sized page counter API, then change all
memory accounting over to it and remove the old one.  The translation
from and to bytes then only happens when interfacing with userspace.

Aside from the locking costs, this gets rid of the icky unsigned long
long types in the very heart of memcg, which is great for 32 bit and
also makes the code a lot more readable.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 Documentation/cgroups/memory.txt |   4 +-
 include/linux/memcontrol.h       |   5 +-
 include/linux/page_counter.h     |  49 +++
 include/net/sock.h               |  26 +-
 init/Kconfig                     |   5 +-
 mm/Makefile                      |   1 +
 mm/memcontrol.c                  | 635 ++++++++++++++++++---------------------
 mm/page_counter.c                | 191 ++++++++++++
 net/ipv4/tcp_memcontrol.c        |  87 +++---
 9 files changed, 598 insertions(+), 405 deletions(-)
 create mode 100644 include/linux/page_counter.h
 create mode 100644 mm/page_counter.c

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 02ab997a1ed2..f624727ab404 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -52,9 +52,9 @@ Brief summary of control files.
  tasks				 # attach a task(thread) and show list of threads
  cgroup.procs			 # show list of processes
  cgroup.event_control		 # an interface for event_fd()
- memory.usage_in_bytes		 # show current res_counter usage for memory
+ memory.usage_in_bytes		 # show current usage for memory
 				 (See 5.5 for details)
- memory.memsw.usage_in_bytes	 # show current res_counter usage for memory+Swap
+ memory.memsw.usage_in_bytes	 # show current usage for memory+Swap
 				 (See 5.5 for details)
  memory.limit_in_bytes		 # set/show limit of memory usage
  memory.memsw.limit_in_bytes	 # set/show limit of memory+Swap usage
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 19df5d857411..0daf383f8f1c 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -471,9 +471,8 @@ memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **memcg, int order)
 	/*
 	 * __GFP_NOFAIL allocations will move on even if charging is not
 	 * possible. Therefore we don't even try, and have this allocation
-	 * unaccounted. We could in theory charge it with
-	 * res_counter_charge_nofail, but we hope those allocations are rare,
-	 * and won't be worth the trouble.
+	 * unaccounted. We could in theory charge it forcibly, but we hope
+	 * those allocations are rare, and won't be worth the trouble.
 	 */
 	if (gfp & __GFP_NOFAIL)
 		return true;
diff --git a/include/linux/page_counter.h b/include/linux/page_counter.h
new file mode 100644
index 000000000000..d92d18949474
--- /dev/null
+++ b/include/linux/page_counter.h
@@ -0,0 +1,49 @@
+#ifndef _LINUX_PAGE_COUNTER_H
+#define _LINUX_PAGE_COUNTER_H
+
+#include <linux/atomic.h>
+
+struct page_counter {
+	atomic_long_t count;
+	unsigned long limit;
+	struct page_counter *parent;
+
+	/* legacy */
+	unsigned long watermark;
+	unsigned long failcnt;
+};
+
+#if BITS_PER_LONG == 32
+#define PAGE_COUNTER_MAX LONG_MAX
+#else
+#define PAGE_COUNTER_MAX (LONG_MAX / PAGE_SIZE)
+#endif
+
+static inline void page_counter_init(struct page_counter *counter,
+				     struct page_counter *parent)
+{
+	atomic_long_set(&counter->count, 0);
+	counter->limit = PAGE_COUNTER_MAX;
+	counter->parent = parent;
+}
+
+static inline unsigned long page_counter_read(struct page_counter *counter)
+{
+	return atomic_long_read(&counter->count);
+}
+
+int page_counter_cancel(struct page_counter *counter, unsigned long nr_pages);
+void page_counter_charge(struct page_counter *counter, unsigned long nr_pages);
+int page_counter_try_charge(struct page_counter *counter,
+			    unsigned long nr_pages,
+			    struct page_counter **fail);
+int page_counter_uncharge(struct page_counter *counter, unsigned long nr_pages);
+int page_counter_limit(struct page_counter *counter, unsigned long limit);
+int page_counter_memparse(const char *buf, unsigned long *nr_pages);
+
+static inline void page_counter_reset_watermark(struct page_counter *counter)
+{
+	counter->watermark = page_counter_read(counter);
+}
+
+#endif /* _LINUX_PAGE_COUNTER_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index 515a4d01e932..7ced53b6d896 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -54,8 +54,8 @@
 #include <linux/security.h>
 #include <linux/slab.h>
 #include <linux/uaccess.h>
+#include <linux/page_counter.h>
 #include <linux/memcontrol.h>
-#include <linux/res_counter.h>
 #include <linux/static_key.h>
 #include <linux/aio.h>
 #include <linux/sched.h>
@@ -1066,7 +1066,7 @@ enum cg_proto_flags {
 };
 
 struct cg_proto {
-	struct res_counter	memory_allocated;	/* Current allocated memory. */
+	struct page_counter	memory_allocated;	/* Current allocated memory. */
 	struct percpu_counter	sockets_allocated;	/* Current number of sockets. */
 	int			memory_pressure;
 	long			sysctl_mem[3];
@@ -1218,34 +1218,26 @@ static inline void memcg_memory_allocated_add(struct cg_proto *prot,
 					      unsigned long amt,
 					      int *parent_status)
 {
-	struct res_counter *fail;
-	int ret;
+	page_counter_charge(&prot->memory_allocated, amt);
 
-	ret = res_counter_charge_nofail(&prot->memory_allocated,
-					amt << PAGE_SHIFT, &fail);
-	if (ret < 0)
+	if (page_counter_read(&prot->memory_allocated) >
+	    prot->memory_allocated.limit)
 		*parent_status = OVER_LIMIT;
 }
 
 static inline void memcg_memory_allocated_sub(struct cg_proto *prot,
 					      unsigned long amt)
 {
-	res_counter_uncharge(&prot->memory_allocated, amt << PAGE_SHIFT);
-}
-
-static inline u64 memcg_memory_allocated_read(struct cg_proto *prot)
-{
-	u64 ret;
-	ret = res_counter_read_u64(&prot->memory_allocated, RES_USAGE);
-	return ret >> PAGE_SHIFT;
+	page_counter_uncharge(&prot->memory_allocated, amt);
 }
 
 static inline long
 sk_memory_allocated(const struct sock *sk)
 {
 	struct proto *prot = sk->sk_prot;
+
 	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
-		return memcg_memory_allocated_read(sk->sk_cgrp);
+		return page_counter_read(&sk->sk_cgrp->memory_allocated);
 
 	return atomic_long_read(prot->memory_allocated);
 }
@@ -1259,7 +1251,7 @@ sk_memory_allocated_add(struct sock *sk, int amt, int *parent_status)
 		memcg_memory_allocated_add(sk->sk_cgrp, amt, parent_status);
 		/* update the root cgroup regardless */
 		atomic_long_add_return(amt, prot->memory_allocated);
-		return memcg_memory_allocated_read(sk->sk_cgrp);
+		return page_counter_read(&sk->sk_cgrp->memory_allocated);
 	}
 
 	return atomic_long_add_return(amt, prot->memory_allocated);
diff --git a/init/Kconfig b/init/Kconfig
index ed4f42d79bd1..88b56940cb9e 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -983,9 +983,12 @@ config RESOURCE_COUNTERS
 	  This option enables controller independent resource accounting
 	  infrastructure that works with cgroups.
 
+config PAGE_COUNTER
+       bool
+
 config MEMCG
 	bool "Memory Resource Controller for Control Groups"
-	depends on RESOURCE_COUNTERS
+	select PAGE_COUNTER
 	select EVENTFD
 	help
 	  Provides a memory resource controller that manages both anonymous
diff --git a/mm/Makefile b/mm/Makefile
index af993eb61cf6..63551c9090f8 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -51,6 +51,7 @@ obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_TRANSPARENT_HUGEPAGE) += huge_memory.o
+obj-$(CONFIG_PAGE_COUNTER) += page_counter.o
 obj-$(CONFIG_MEMCG) += memcontrol.o page_cgroup.o vmpressure.o
 obj-$(CONFIG_CGROUP_HUGETLB) += hugetlb_cgroup.o
 obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c2c75262a209..52c24119be69 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -25,7 +25,7 @@
  * GNU General Public License for more details.
  */
 
-#include <linux/res_counter.h>
+#include <linux/page_counter.h>
 #include <linux/memcontrol.h>
 #include <linux/cgroup.h>
 #include <linux/mm.h>
@@ -165,7 +165,7 @@ struct mem_cgroup_per_zone {
 	struct mem_cgroup_reclaim_iter reclaim_iter[DEF_PRIORITY + 1];
 
 	struct rb_node		tree_node;	/* RB tree node */
-	unsigned long long	usage_in_excess;/* Set to the value by which */
+	unsigned long		usage_in_excess;/* Set to the value by which */
 						/* the soft limit is exceeded*/
 	bool			on_tree;
 	struct mem_cgroup	*memcg;		/* Back pointer, we cannot */
@@ -198,7 +198,7 @@ static struct mem_cgroup_tree soft_limit_tree __read_mostly;
 
 struct mem_cgroup_threshold {
 	struct eventfd_ctx *eventfd;
-	u64 threshold;
+	unsigned long threshold;
 };
 
 /* For threshold */
@@ -284,24 +284,18 @@ static void mem_cgroup_oom_notify(struct mem_cgroup *memcg);
  */
 struct mem_cgroup {
 	struct cgroup_subsys_state css;
-	/*
-	 * the counter to account for memory usage
-	 */
-	struct res_counter res;
+
+	/* Accounted resources */
+	struct page_counter memory;
+	struct page_counter memsw;
+	struct page_counter kmem;
+
+	unsigned long soft_limit;
 
 	/* vmpressure notifications */
 	struct vmpressure vmpressure;
 
 	/*
-	 * the counter to account for mem+swap usage.
-	 */
-	struct res_counter memsw;
-
-	/*
-	 * the counter to account for kernel memory usage.
-	 */
-	struct res_counter kmem;
-	/*
 	 * Should the accounting and control be hierarchical, per subtree?
 	 */
 	bool use_hierarchy;
@@ -647,7 +641,7 @@ static void disarm_kmem_keys(struct mem_cgroup *memcg)
 	 * This check can't live in kmem destruction function,
 	 * since the charges will outlive the cgroup
 	 */
-	WARN_ON(res_counter_read_u64(&memcg->kmem, RES_USAGE) != 0);
+	WARN_ON(page_counter_read(&memcg->kmem));
 }
 #else
 static void disarm_kmem_keys(struct mem_cgroup *memcg)
@@ -703,7 +697,7 @@ soft_limit_tree_from_page(struct page *page)
 
 static void __mem_cgroup_insert_exceeded(struct mem_cgroup_per_zone *mz,
 					 struct mem_cgroup_tree_per_zone *mctz,
-					 unsigned long long new_usage_in_excess)
+					 unsigned long new_usage_in_excess)
 {
 	struct rb_node **p = &mctz->rb_root.rb_node;
 	struct rb_node *parent = NULL;
@@ -752,10 +746,21 @@ static void mem_cgroup_remove_exceeded(struct mem_cgroup_per_zone *mz,
 	spin_unlock_irqrestore(&mctz->lock, flags);
 }
 
+static unsigned long soft_limit_excess(struct mem_cgroup *memcg)
+{
+	unsigned long nr_pages = page_counter_read(&memcg->memory);
+	unsigned long soft_limit = ACCESS_ONCE(memcg->soft_limit);
+	unsigned long excess = 0;
+
+	if (nr_pages > soft_limit)
+		excess = nr_pages - soft_limit;
+
+	return excess;
+}
 
 static void mem_cgroup_update_tree(struct mem_cgroup *memcg, struct page *page)
 {
-	unsigned long long excess;
+	unsigned long excess;
 	struct mem_cgroup_per_zone *mz;
 	struct mem_cgroup_tree_per_zone *mctz;
 
@@ -766,7 +771,7 @@ static void mem_cgroup_update_tree(struct mem_cgroup *memcg, struct page *page)
 	 */
 	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
 		mz = mem_cgroup_page_zoneinfo(memcg, page);
-		excess = res_counter_soft_limit_excess(&memcg->res);
+		excess = soft_limit_excess(memcg);
 		/*
 		 * We have to update the tree if mz is on RB-tree or
 		 * mem is over its softlimit.
@@ -822,7 +827,7 @@ retry:
 	 * position in the tree.
 	 */
 	__mem_cgroup_remove_exceeded(mz, mctz);
-	if (!res_counter_soft_limit_excess(&mz->memcg->res) ||
+	if (!soft_limit_excess(mz->memcg) ||
 	    !css_tryget_online(&mz->memcg->css))
 		goto retry;
 done:
@@ -1478,7 +1483,7 @@ int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
 	return inactive * inactive_ratio < active;
 }
 
-#define mem_cgroup_from_res_counter(counter, member)	\
+#define mem_cgroup_from_counter(counter, member)	\
 	container_of(counter, struct mem_cgroup, member)
 
 /**
@@ -1490,12 +1495,23 @@ int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
  */
 static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
 {
-	unsigned long long margin;
+	unsigned long margin = 0;
+	unsigned long count;
+	unsigned long limit;
 
-	margin = res_counter_margin(&memcg->res);
-	if (do_swap_account)
-		margin = min(margin, res_counter_margin(&memcg->memsw));
-	return margin >> PAGE_SHIFT;
+	count = page_counter_read(&memcg->memory);
+	limit = ACCESS_ONCE(memcg->memory.limit);
+	if (count < limit)
+		margin = limit - count;
+
+	if (do_swap_account) {
+		count = page_counter_read(&memcg->memsw);
+		limit = ACCESS_ONCE(memcg->memsw.limit);
+		if (count < limit)
+			margin = min(margin, limit - count);
+	}
+
+	return margin;
 }
 
 int mem_cgroup_swappiness(struct mem_cgroup *memcg)
@@ -1636,18 +1652,15 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 
 	rcu_read_unlock();
 
-	pr_info("memory: usage %llukB, limit %llukB, failcnt %llu\n",
-		res_counter_read_u64(&memcg->res, RES_USAGE) >> 10,
-		res_counter_read_u64(&memcg->res, RES_LIMIT) >> 10,
-		res_counter_read_u64(&memcg->res, RES_FAILCNT));
-	pr_info("memory+swap: usage %llukB, limit %llukB, failcnt %llu\n",
-		res_counter_read_u64(&memcg->memsw, RES_USAGE) >> 10,
-		res_counter_read_u64(&memcg->memsw, RES_LIMIT) >> 10,
-		res_counter_read_u64(&memcg->memsw, RES_FAILCNT));
-	pr_info("kmem: usage %llukB, limit %llukB, failcnt %llu\n",
-		res_counter_read_u64(&memcg->kmem, RES_USAGE) >> 10,
-		res_counter_read_u64(&memcg->kmem, RES_LIMIT) >> 10,
-		res_counter_read_u64(&memcg->kmem, RES_FAILCNT));
+	pr_info("memory: usage %llukB, limit %llukB, failcnt %lu\n",
+		K((u64)page_counter_read(&memcg->memory)),
+		K((u64)memcg->memory.limit), memcg->memory.failcnt);
+	pr_info("memory+swap: usage %llukB, limit %llukB, failcnt %lu\n",
+		K((u64)page_counter_read(&memcg->memsw)),
+		K((u64)memcg->memsw.limit), memcg->memsw.failcnt);
+	pr_info("kmem: usage %llukB, limit %llukB, failcnt %lu\n",
+		K((u64)page_counter_read(&memcg->kmem)),
+		K((u64)memcg->kmem.limit), memcg->kmem.failcnt);
 
 	for_each_mem_cgroup_tree(iter, memcg) {
 		pr_info("Memory cgroup stats for ");
@@ -1685,30 +1698,19 @@ static int mem_cgroup_count_children(struct mem_cgroup *memcg)
 }
 
 /*
- * Return the memory (and swap, if configured) limit for a memcg.
+ * Return the memory (and swap, if configured) maximum consumption for a memcg.
  */
-static u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
+static unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg)
 {
-	u64 limit;
+	unsigned long limit;
 
-	limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
-
-	/*
-	 * Do not consider swap space if we cannot swap due to swappiness
-	 */
+	limit = memcg->memory.limit;
 	if (mem_cgroup_swappiness(memcg)) {
-		u64 memsw;
+		unsigned long memsw_limit;
 
-		limit += total_swap_pages << PAGE_SHIFT;
-		memsw = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
-
-		/*
-		 * If memsw is finite and limits the amount of swap space
-		 * available to this memcg, return that limit.
-		 */
-		limit = min(limit, memsw);
+		memsw_limit = memcg->memsw.limit;
+		limit = min(limit + total_swap_pages, memsw_limit);
 	}
-
 	return limit;
 }
 
@@ -1732,7 +1734,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	}
 
 	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, order, NULL);
-	totalpages = mem_cgroup_get_limit(memcg) >> PAGE_SHIFT ? : 1;
+	totalpages = mem_cgroup_get_limit(memcg) ? : 1;
 	for_each_mem_cgroup_tree(iter, memcg) {
 		struct css_task_iter it;
 		struct task_struct *task;
@@ -1935,7 +1937,7 @@ static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
 		.priority = 0,
 	};
 
-	excess = res_counter_soft_limit_excess(&root_memcg->res) >> PAGE_SHIFT;
+	excess = soft_limit_excess(root_memcg);
 
 	while (1) {
 		victim = mem_cgroup_iter(root_memcg, victim, &reclaim);
@@ -1966,7 +1968,7 @@ static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
 		total += mem_cgroup_shrink_node_zone(victim, gfp_mask, false,
 						     zone, &nr_scanned);
 		*total_scanned += nr_scanned;
-		if (!res_counter_soft_limit_excess(&root_memcg->res))
+		if (!soft_limit_excess(root_memcg))
 			break;
 	}
 	mem_cgroup_iter_break(root_memcg, victim);
@@ -2293,33 +2295,31 @@ static DEFINE_MUTEX(percpu_charge_mutex);
 static bool consume_stock(struct mem_cgroup *memcg, unsigned int nr_pages)
 {
 	struct memcg_stock_pcp *stock;
-	bool ret = true;
+	bool ret = false;
 
 	if (nr_pages > CHARGE_BATCH)
-		return false;
+		return ret;
 
 	stock = &get_cpu_var(memcg_stock);
-	if (memcg == stock->cached && stock->nr_pages >= nr_pages)
+	if (memcg == stock->cached && stock->nr_pages >= nr_pages) {
 		stock->nr_pages -= nr_pages;
-	else /* need to call res_counter_charge */
-		ret = false;
+		ret = true;
+	}
 	put_cpu_var(memcg_stock);
 	return ret;
 }
 
 /*
- * Returns stocks cached in percpu to res_counter and reset cached information.
+ * Returns stocks cached in percpu and reset cached information.
  */
 static void drain_stock(struct memcg_stock_pcp *stock)
 {
 	struct mem_cgroup *old = stock->cached;
 
 	if (stock->nr_pages) {
-		unsigned long bytes = stock->nr_pages * PAGE_SIZE;
-
-		res_counter_uncharge(&old->res, bytes);
+		page_counter_uncharge(&old->memory, stock->nr_pages);
 		if (do_swap_account)
-			res_counter_uncharge(&old->memsw, bytes);
+			page_counter_uncharge(&old->memsw, stock->nr_pages);
 		stock->nr_pages = 0;
 	}
 	stock->cached = NULL;
@@ -2348,7 +2348,7 @@ static void __init memcg_stock_init(void)
 }
 
 /*
- * Cache charges(val) which is from res_counter, to local per_cpu area.
+ * Cache charges(val) to local per_cpu area.
  * This will be consumed by consume_stock() function, later.
  */
 static void refill_stock(struct mem_cgroup *memcg, unsigned int nr_pages)
@@ -2408,8 +2408,7 @@ out:
 /*
  * Tries to drain stocked charges in other cpus. This function is asynchronous
  * and just put a work per cpu for draining localy on each cpu. Caller can
- * expects some charges will be back to res_counter later but cannot wait for
- * it.
+ * expects some charges will be back later but cannot wait for it.
  */
 static void drain_all_stock_async(struct mem_cgroup *root_memcg)
 {
@@ -2483,9 +2482,8 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	unsigned int batch = max(CHARGE_BATCH, nr_pages);
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct mem_cgroup *mem_over_limit;
-	struct res_counter *fail_res;
+	struct page_counter *counter;
 	unsigned long nr_reclaimed;
-	unsigned long long size;
 	bool may_swap = true;
 	bool drained = false;
 	int ret = 0;
@@ -2496,16 +2494,15 @@ retry:
 	if (consume_stock(memcg, nr_pages))
 		goto done;
 
-	size = batch * PAGE_SIZE;
 	if (!do_swap_account ||
-	    !res_counter_charge(&memcg->memsw, size, &fail_res)) {
-		if (!res_counter_charge(&memcg->res, size, &fail_res))
+	    !page_counter_try_charge(&memcg->memsw, batch, &counter)) {
+		if (!page_counter_try_charge(&memcg->memory, batch, &counter))
 			goto done_restock;
 		if (do_swap_account)
-			res_counter_uncharge(&memcg->memsw, size);
-		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
+			page_counter_uncharge(&memcg->memsw, batch);
+		mem_over_limit = mem_cgroup_from_counter(counter, memory);
 	} else {
-		mem_over_limit = mem_cgroup_from_res_counter(fail_res, memsw);
+		mem_over_limit = mem_cgroup_from_counter(counter, memsw);
 		may_swap = false;
 	}
 
@@ -2588,32 +2585,12 @@ done:
 
 static void cancel_charge(struct mem_cgroup *memcg, unsigned int nr_pages)
 {
-	unsigned long bytes = nr_pages * PAGE_SIZE;
-
 	if (mem_cgroup_is_root(memcg))
 		return;
 
-	res_counter_uncharge(&memcg->res, bytes);
+	page_counter_uncharge(&memcg->memory, nr_pages);
 	if (do_swap_account)
-		res_counter_uncharge(&memcg->memsw, bytes);
-}
-
-/*
- * Cancel chrages in this cgroup....doesn't propagate to parent cgroup.
- * This is useful when moving usage to parent cgroup.
- */
-static void __mem_cgroup_cancel_local_charge(struct mem_cgroup *memcg,
-					unsigned int nr_pages)
-{
-	unsigned long bytes = nr_pages * PAGE_SIZE;
-
-	if (mem_cgroup_is_root(memcg))
-		return;
-
-	res_counter_uncharge_until(&memcg->res, memcg->res.parent, bytes);
-	if (do_swap_account)
-		res_counter_uncharge_until(&memcg->memsw,
-						memcg->memsw.parent, bytes);
+		page_counter_uncharge(&memcg->memsw, nr_pages);
 }
 
 /*
@@ -2737,8 +2714,6 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
 		unlock_page_lru(page, isolated);
 }
 
-static DEFINE_MUTEX(set_limit_mutex);
-
 #ifdef CONFIG_MEMCG_KMEM
 /*
  * The memcg_slab_mutex is held whenever a per memcg kmem cache is created or
@@ -2787,16 +2762,17 @@ static int mem_cgroup_slabinfo_read(struct seq_file *m, void *v)
 }
 #endif
 
-static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
+static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp,
+			     unsigned long nr_pages)
 {
-	struct res_counter *fail_res;
+	struct page_counter *counter;
 	int ret = 0;
 
-	ret = res_counter_charge(&memcg->kmem, size, &fail_res);
-	if (ret)
+	ret = page_counter_try_charge(&memcg->kmem, nr_pages, &counter);
+	if (ret < 0)
 		return ret;
 
-	ret = try_charge(memcg, gfp, size >> PAGE_SHIFT);
+	ret = try_charge(memcg, gfp, nr_pages);
 	if (ret == -EINTR)  {
 		/*
 		 * try_charge() chose to bypass to root due to OOM kill or
@@ -2813,25 +2789,25 @@ static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
 		 * when the allocation triggers should have been already
 		 * directed to the root cgroup in memcontrol.h
 		 */
-		res_counter_charge_nofail(&memcg->res, size, &fail_res);
+		page_counter_charge(&memcg->memory, nr_pages);
 		if (do_swap_account)
-			res_counter_charge_nofail(&memcg->memsw, size,
-						  &fail_res);
+			page_counter_charge(&memcg->memsw, nr_pages);
 		ret = 0;
 	} else if (ret)
-		res_counter_uncharge(&memcg->kmem, size);
+		page_counter_uncharge(&memcg->kmem, nr_pages);
 
 	return ret;
 }
 
-static void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size)
+static void memcg_uncharge_kmem(struct mem_cgroup *memcg,
+				unsigned long nr_pages)
 {
-	res_counter_uncharge(&memcg->res, size);
+	page_counter_uncharge(&memcg->memory, nr_pages);
 	if (do_swap_account)
-		res_counter_uncharge(&memcg->memsw, size);
+		page_counter_uncharge(&memcg->memsw, nr_pages);
 
 	/* Not down to 0 */
-	if (res_counter_uncharge(&memcg->kmem, size))
+	if (page_counter_uncharge(&memcg->kmem, nr_pages))
 		return;
 
 	/*
@@ -3107,19 +3083,21 @@ static void memcg_schedule_register_cache(struct mem_cgroup *memcg,
 
 int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order)
 {
+	unsigned int nr_pages = 1 << order;
 	int res;
 
-	res = memcg_charge_kmem(cachep->memcg_params->memcg, gfp,
-				PAGE_SIZE << order);
+	res = memcg_charge_kmem(cachep->memcg_params->memcg, gfp, nr_pages);
 	if (!res)
-		atomic_add(1 << order, &cachep->memcg_params->nr_pages);
+		atomic_add(nr_pages, &cachep->memcg_params->nr_pages);
 	return res;
 }
 
 void __memcg_uncharge_slab(struct kmem_cache *cachep, int order)
 {
-	memcg_uncharge_kmem(cachep->memcg_params->memcg, PAGE_SIZE << order);
-	atomic_sub(1 << order, &cachep->memcg_params->nr_pages);
+	unsigned int nr_pages = 1 << order;
+
+	memcg_uncharge_kmem(cachep->memcg_params->memcg, nr_pages);
+	atomic_sub(nr_pages, &cachep->memcg_params->nr_pages);
 }
 
 /*
@@ -3240,7 +3218,7 @@ __memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **_memcg, int order)
 		return true;
 	}
 
-	ret = memcg_charge_kmem(memcg, gfp, PAGE_SIZE << order);
+	ret = memcg_charge_kmem(memcg, gfp, 1 << order);
 	if (!ret)
 		*_memcg = memcg;
 
@@ -3257,7 +3235,7 @@ void __memcg_kmem_commit_charge(struct page *page, struct mem_cgroup *memcg,
 
 	/* The page allocation failed. Revert */
 	if (!page) {
-		memcg_uncharge_kmem(memcg, PAGE_SIZE << order);
+		memcg_uncharge_kmem(memcg, 1 << order);
 		return;
 	}
 	/*
@@ -3290,7 +3268,7 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order)
 		return;
 
 	VM_BUG_ON_PAGE(mem_cgroup_is_root(memcg), page);
-	memcg_uncharge_kmem(memcg, PAGE_SIZE << order);
+	memcg_uncharge_kmem(memcg, 1 << order);
 }
 #else
 static inline void memcg_unregister_all_caches(struct mem_cgroup *memcg)
@@ -3468,8 +3446,12 @@ static int mem_cgroup_move_parent(struct page *page,
 
 	ret = mem_cgroup_move_account(page, nr_pages,
 				pc, child, parent);
-	if (!ret)
-		__mem_cgroup_cancel_local_charge(child, nr_pages);
+	if (!ret) {
+		/* Take charge off the local counters */
+		page_counter_cancel(&child->memory, nr_pages);
+		if (do_swap_account)
+			page_counter_cancel(&child->memsw, nr_pages);
+	}
 
 	if (nr_pages > 1)
 		compound_unlock_irqrestore(page, flags);
@@ -3499,7 +3481,7 @@ static void mem_cgroup_swap_statistics(struct mem_cgroup *memcg,
  *
  * Returns 0 on success, -EINVAL on failure.
  *
- * The caller must have charged to @to, IOW, called res_counter_charge() about
+ * The caller must have charged to @to, IOW, called page_counter_charge() about
  * both res and memsw, and called css_get().
  */
 static int mem_cgroup_move_swap_account(swp_entry_t entry,
@@ -3515,7 +3497,7 @@ static int mem_cgroup_move_swap_account(swp_entry_t entry,
 		mem_cgroup_swap_statistics(to, true);
 		/*
 		 * This function is only called from task migration context now.
-		 * It postpones res_counter and refcount handling till the end
+		 * It postpones page_counter and refcount handling till the end
 		 * of task migration(mem_cgroup_clear_mc()) for performance
 		 * improvement. But we cannot postpone css_get(to)  because if
 		 * the process that has been moved to @to does swap-in, the
@@ -3573,60 +3555,57 @@ void mem_cgroup_print_bad_page(struct page *page)
 }
 #endif
 
+static DEFINE_MUTEX(memcg_limit_mutex);
+
 static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
-				unsigned long long val)
+				   unsigned long limit)
 {
+	unsigned long curusage;
+	unsigned long oldusage;
+	bool enlarge = false;
 	int retry_count;
-	int ret = 0;
-	int children = mem_cgroup_count_children(memcg);
-	u64 curusage, oldusage;
-	int enlarge;
+	int ret;
 
 	/*
 	 * For keeping hierarchical_reclaim simple, how long we should retry
 	 * is depends on callers. We set our retry-count to be function
 	 * of # of children which we should visit in this loop.
 	 */
-	retry_count = MEM_CGROUP_RECLAIM_RETRIES * children;
+	retry_count = MEM_CGROUP_RECLAIM_RETRIES *
+		      mem_cgroup_count_children(memcg);
 
-	oldusage = res_counter_read_u64(&memcg->res, RES_USAGE);
+	oldusage = page_counter_read(&memcg->memory);
 
-	enlarge = 0;
-	while (retry_count) {
+	do {
 		if (signal_pending(current)) {
 			ret = -EINTR;
 			break;
 		}
-		/*
-		 * Rather than hide all in some function, I do this in
-		 * open coded manner. You see what this really does.
-		 * We have to guarantee memcg->res.limit <= memcg->memsw.limit.
-		 */
-		mutex_lock(&set_limit_mutex);
-		if (res_counter_read_u64(&memcg->memsw, RES_LIMIT) < val) {
+
+		mutex_lock(&memcg_limit_mutex);
+		if (limit > memcg->memsw.limit) {
+			mutex_unlock(&memcg_limit_mutex);
 			ret = -EINVAL;
-			mutex_unlock(&set_limit_mutex);
 			break;
 		}
-
-		if (res_counter_read_u64(&memcg->res, RES_LIMIT) < val)
-			enlarge = 1;
-
-		ret = res_counter_set_limit(&memcg->res, val);
-		mutex_unlock(&set_limit_mutex);
+		if (limit > memcg->memory.limit)
+			enlarge = true;
+		ret = page_counter_limit(&memcg->memory, limit);
+		mutex_unlock(&memcg_limit_mutex);
 
 		if (!ret)
 			break;
 
 		try_to_free_mem_cgroup_pages(memcg, 1, GFP_KERNEL, true);
 
-		curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
+		curusage = page_counter_read(&memcg->memory);
 		/* Usage is reduced ? */
 		if (curusage >= oldusage)
 			retry_count--;
 		else
 			oldusage = curusage;
-	}
+	} while (retry_count);
+
 	if (!ret && enlarge)
 		memcg_oom_recover(memcg);
 
@@ -3634,52 +3613,53 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 }
 
 static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
-					unsigned long long val)
+					 unsigned long limit)
 {
+	unsigned long curusage;
+	unsigned long oldusage;
+	bool enlarge = false;
 	int retry_count;
-	u64 oldusage, curusage;
-	int children = mem_cgroup_count_children(memcg);
-	int ret = -EBUSY;
-	int enlarge = 0;
+	int ret;
 
 	/* see mem_cgroup_resize_res_limit */
-	retry_count = children * MEM_CGROUP_RECLAIM_RETRIES;
-	oldusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
-	while (retry_count) {
+	retry_count = MEM_CGROUP_RECLAIM_RETRIES *
+		      mem_cgroup_count_children(memcg);
+
+	oldusage = page_counter_read(&memcg->memsw);
+
+	do {
 		if (signal_pending(current)) {
 			ret = -EINTR;
 			break;
 		}
-		/*
-		 * Rather than hide all in some function, I do this in
-		 * open coded manner. You see what this really does.
-		 * We have to guarantee memcg->res.limit <= memcg->memsw.limit.
-		 */
-		mutex_lock(&set_limit_mutex);
-		if (res_counter_read_u64(&memcg->res, RES_LIMIT) > val) {
+
+		mutex_lock(&memcg_limit_mutex);
+		if (limit < memcg->memory.limit) {
+			mutex_unlock(&memcg_limit_mutex);
 			ret = -EINVAL;
-			mutex_unlock(&set_limit_mutex);
 			break;
 		}
-		if (res_counter_read_u64(&memcg->memsw, RES_LIMIT) < val)
-			enlarge = 1;
-		ret = res_counter_set_limit(&memcg->memsw, val);
-		mutex_unlock(&set_limit_mutex);
+		if (limit > memcg->memsw.limit)
+			enlarge = true;
+		ret = page_counter_limit(&memcg->memsw, limit);
+		mutex_unlock(&memcg_limit_mutex);
 
 		if (!ret)
 			break;
 
 		try_to_free_mem_cgroup_pages(memcg, 1, GFP_KERNEL, false);
 
-		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
+		curusage = page_counter_read(&memcg->memsw);
 		/* Usage is reduced ? */
 		if (curusage >= oldusage)
 			retry_count--;
 		else
 			oldusage = curusage;
-	}
+	} while (retry_count);
+
 	if (!ret && enlarge)
 		memcg_oom_recover(memcg);
+
 	return ret;
 }
 
@@ -3692,7 +3672,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 	unsigned long reclaimed;
 	int loop = 0;
 	struct mem_cgroup_tree_per_zone *mctz;
-	unsigned long long excess;
+	unsigned long excess;
 	unsigned long nr_scanned;
 
 	if (order > 0)
@@ -3746,7 +3726,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 			} while (1);
 		}
 		__mem_cgroup_remove_exceeded(mz, mctz);
-		excess = res_counter_soft_limit_excess(&mz->memcg->res);
+		excess = soft_limit_excess(mz->memcg);
 		/*
 		 * One school of thought says that we should not add
 		 * back the node to the tree if reclaim returns 0.
@@ -3839,7 +3819,6 @@ static void mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 static void mem_cgroup_reparent_charges(struct mem_cgroup *memcg)
 {
 	int node, zid;
-	u64 usage;
 
 	do {
 		/* This is for making all *used* pages to be on LRU. */
@@ -3871,9 +3850,8 @@ static void mem_cgroup_reparent_charges(struct mem_cgroup *memcg)
 		 * right after the check. RES_USAGE should be safe as we always
 		 * charge before adding to the LRU.
 		 */
-		usage = res_counter_read_u64(&memcg->res, RES_USAGE) -
-			res_counter_read_u64(&memcg->kmem, RES_USAGE);
-	} while (usage > 0);
+	} while (page_counter_read(&memcg->memory) -
+		 page_counter_read(&memcg->kmem) > 0);
 }
 
 /*
@@ -3913,7 +3891,7 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
 	/* we call try-to-free pages for make this cgroup empty */
 	lru_add_drain_all();
 	/* try to free all pages in this cgroup */
-	while (nr_retries && res_counter_read_u64(&memcg->res, RES_USAGE) > 0) {
+	while (nr_retries && page_counter_read(&memcg->memory)) {
 		int progress;
 
 		if (signal_pending(current))
@@ -3984,8 +3962,8 @@ out:
 	return retval;
 }
 
-static unsigned long mem_cgroup_recursive_stat(struct mem_cgroup *memcg,
-					       enum mem_cgroup_stat_index idx)
+static unsigned long tree_stat(struct mem_cgroup *memcg,
+			       enum mem_cgroup_stat_index idx)
 {
 	struct mem_cgroup *iter;
 	long val = 0;
@@ -4003,55 +3981,72 @@ static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
 {
 	u64 val;
 
-	if (!mem_cgroup_is_root(memcg)) {
+	if (mem_cgroup_is_root(memcg)) {
+		val = tree_stat(memcg, MEM_CGROUP_STAT_CACHE);
+		val += tree_stat(memcg, MEM_CGROUP_STAT_RSS);
+		if (swap)
+			val += tree_stat(memcg, MEM_CGROUP_STAT_SWAP);
+	} else {
 		if (!swap)
-			return res_counter_read_u64(&memcg->res, RES_USAGE);
+			val = page_counter_read(&memcg->memory);
 		else
-			return res_counter_read_u64(&memcg->memsw, RES_USAGE);
+			val = page_counter_read(&memcg->memsw);
 	}
-
-	/*
-	 * Transparent hugepages are still accounted for in MEM_CGROUP_STAT_RSS
-	 * as well as in MEM_CGROUP_STAT_RSS_HUGE.
-	 */
-	val = mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_CACHE);
-	val += mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_RSS);
-
-	if (swap)
-		val += mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_SWAP);
-
 	return val << PAGE_SHIFT;
 }
 
+enum {
+	RES_USAGE,
+	RES_LIMIT,
+	RES_MAX_USAGE,
+	RES_FAILCNT,
+	RES_SOFT_LIMIT,
+};
 
 static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
 			       struct cftype *cft)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
-	enum res_type type = MEMFILE_TYPE(cft->private);
-	int name = MEMFILE_ATTR(cft->private);
+	struct page_counter *counter;
 
-	switch (type) {
+	switch (MEMFILE_TYPE(cft->private)) {
 	case _MEM:
-		if (name == RES_USAGE)
-			return mem_cgroup_usage(memcg, false);
-		return res_counter_read_u64(&memcg->res, name);
+		counter = &memcg->memory;
+		break;
 	case _MEMSWAP:
-		if (name == RES_USAGE)
-			return mem_cgroup_usage(memcg, true);
-		return res_counter_read_u64(&memcg->memsw, name);
+		counter = &memcg->memsw;
+		break;
 	case _KMEM:
-		return res_counter_read_u64(&memcg->kmem, name);
+		counter = &memcg->kmem;
 		break;
 	default:
 		BUG();
 	}
+
+	switch (MEMFILE_ATTR(cft->private)) {
+	case RES_USAGE:
+		if (counter == &memcg->memory)
+			return mem_cgroup_usage(memcg, false);
+		if (counter == &memcg->memsw)
+			return mem_cgroup_usage(memcg, true);
+		return (u64)page_counter_read(counter) * PAGE_SIZE;
+	case RES_LIMIT:
+		return (u64)counter->limit * PAGE_SIZE;
+	case RES_MAX_USAGE:
+		return (u64)counter->watermark * PAGE_SIZE;
+	case RES_FAILCNT:
+		return counter->failcnt;
+	case RES_SOFT_LIMIT:
+		return (u64)memcg->soft_limit * PAGE_SIZE;
+	default:
+		BUG();
+	}
 }
 
 #ifdef CONFIG_MEMCG_KMEM
 /* should be called with activate_kmem_mutex held */
 static int __memcg_activate_kmem(struct mem_cgroup *memcg,
-				 unsigned long long limit)
+				 unsigned long nr_pages)
 {
 	int err = 0;
 	int memcg_id;
@@ -4098,7 +4093,7 @@ static int __memcg_activate_kmem(struct mem_cgroup *memcg,
 	 * We couldn't have accounted to this cgroup, because it hasn't got the
 	 * active bit set yet, so this should succeed.
 	 */
-	err = res_counter_set_limit(&memcg->kmem, limit);
+	err = page_counter_limit(&memcg->kmem, nr_pages);
 	VM_BUG_ON(err);
 
 	static_key_slow_inc(&memcg_kmem_enabled_key);
@@ -4114,25 +4109,27 @@ out:
 }
 
 static int memcg_activate_kmem(struct mem_cgroup *memcg,
-			       unsigned long long limit)
+			       unsigned long nr_pages)
 {
 	int ret;
 
 	mutex_lock(&activate_kmem_mutex);
-	ret = __memcg_activate_kmem(memcg, limit);
+	ret = __memcg_activate_kmem(memcg, nr_pages);
 	mutex_unlock(&activate_kmem_mutex);
 	return ret;
 }
 
 static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
-				   unsigned long long val)
+				   unsigned long limit)
 {
 	int ret;
 
+	mutex_lock(&memcg_limit_mutex);
 	if (!memcg_kmem_is_active(memcg))
-		ret = memcg_activate_kmem(memcg, val);
+		ret = memcg_activate_kmem(memcg, limit);
 	else
-		ret = res_counter_set_limit(&memcg->kmem, val);
+		ret = page_counter_limit(&memcg->kmem, limit);
+	mutex_unlock(&memcg_limit_mutex);
 	return ret;
 }
 
@@ -4150,13 +4147,13 @@ static int memcg_propagate_kmem(struct mem_cgroup *memcg)
 	 * after this point, because it has at least one child already.
 	 */
 	if (memcg_kmem_is_active(parent))
-		ret = __memcg_activate_kmem(memcg, RES_COUNTER_MAX);
+		ret = __memcg_activate_kmem(memcg, PAGE_COUNTER_MAX);
 	mutex_unlock(&activate_kmem_mutex);
 	return ret;
 }
 #else
 static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
-				   unsigned long long val)
+				   unsigned long limit)
 {
 	return -EINVAL;
 }
@@ -4170,110 +4167,69 @@ static ssize_t mem_cgroup_write(struct kernfs_open_file *of,
 				char *buf, size_t nbytes, loff_t off)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
-	enum res_type type;
-	int name;
-	unsigned long long val;
+	unsigned long nr_pages;
 	int ret;
 
 	buf = strstrip(buf);
-	type = MEMFILE_TYPE(of_cft(of)->private);
-	name = MEMFILE_ATTR(of_cft(of)->private);
+	ret = page_counter_memparse(buf, &nr_pages);
+	if (ret)
+		return ret;
 
-	switch (name) {
+	switch (MEMFILE_ATTR(of_cft(of)->private)) {
 	case RES_LIMIT:
 		if (mem_cgroup_is_root(memcg)) { /* Can't set limit on root */
 			ret = -EINVAL;
 			break;
 		}
-		/* This function does all necessary parse...reuse it */
-		ret = res_counter_memparse_write_strategy(buf, &val);
-		if (ret)
+		switch (MEMFILE_TYPE(of_cft(of)->private)) {
+		case _MEM:
+			ret = mem_cgroup_resize_limit(memcg, nr_pages);
 			break;
-		if (type == _MEM)
-			ret = mem_cgroup_resize_limit(memcg, val);
-		else if (type == _MEMSWAP)
-			ret = mem_cgroup_resize_memsw_limit(memcg, val);
-		else if (type == _KMEM)
-			ret = memcg_update_kmem_limit(memcg, val);
-		else
-			return -EINVAL;
-		break;
-	case RES_SOFT_LIMIT:
-		ret = res_counter_memparse_write_strategy(buf, &val);
-		if (ret)
+		case _MEMSWAP:
+			ret = mem_cgroup_resize_memsw_limit(memcg, nr_pages);
 			break;
-		/*
-		 * For memsw, soft limits are hard to implement in terms
-		 * of semantics, for now, we support soft limits for
-		 * control without swap
-		 */
-		if (type == _MEM)
-			ret = res_counter_set_soft_limit(&memcg->res, val);
-		else
-			ret = -EINVAL;
+		case _KMEM:
+			ret = memcg_update_kmem_limit(memcg, nr_pages);
+			break;
+		}
 		break;
-	default:
-		ret = -EINVAL; /* should be BUG() ? */
+	case RES_SOFT_LIMIT:
+		memcg->soft_limit = nr_pages;
+		ret = 0;
 		break;
 	}
 	return ret ?: nbytes;
 }
 
-static void memcg_get_hierarchical_limit(struct mem_cgroup *memcg,
-		unsigned long long *mem_limit, unsigned long long *memsw_limit)
-{
-	unsigned long long min_limit, min_memsw_limit, tmp;
-
-	min_limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
-	min_memsw_limit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
-	if (!memcg->use_hierarchy)
-		goto out;
-
-	while (memcg->css.parent) {
-		memcg = mem_cgroup_from_css(memcg->css.parent);
-		if (!memcg->use_hierarchy)
-			break;
-		tmp = res_counter_read_u64(&memcg->res, RES_LIMIT);
-		min_limit = min(min_limit, tmp);
-		tmp = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
-		min_memsw_limit = min(min_memsw_limit, tmp);
-	}
-out:
-	*mem_limit = min_limit;
-	*memsw_limit = min_memsw_limit;
-}
-
 static ssize_t mem_cgroup_reset(struct kernfs_open_file *of, char *buf,
 				size_t nbytes, loff_t off)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
-	int name;
-	enum res_type type;
+	struct page_counter *counter;
 
-	type = MEMFILE_TYPE(of_cft(of)->private);
-	name = MEMFILE_ATTR(of_cft(of)->private);
+	switch (MEMFILE_TYPE(of_cft(of)->private)) {
+	case _MEM:
+		counter = &memcg->memory;
+		break;
+	case _MEMSWAP:
+		counter = &memcg->memsw;
+		break;
+	case _KMEM:
+		counter = &memcg->kmem;
+		break;
+	default:
+		BUG();
+	}
 
-	switch (name) {
+	switch (MEMFILE_ATTR(of_cft(of)->private)) {
 	case RES_MAX_USAGE:
-		if (type == _MEM)
-			res_counter_reset_max(&memcg->res);
-		else if (type == _MEMSWAP)
-			res_counter_reset_max(&memcg->memsw);
-		else if (type == _KMEM)
-			res_counter_reset_max(&memcg->kmem);
-		else
-			return -EINVAL;
+		page_counter_reset_watermark(counter);
 		break;
 	case RES_FAILCNT:
-		if (type == _MEM)
-			res_counter_reset_failcnt(&memcg->res);
-		else if (type == _MEMSWAP)
-			res_counter_reset_failcnt(&memcg->memsw);
-		else if (type == _KMEM)
-			res_counter_reset_failcnt(&memcg->kmem);
-		else
-			return -EINVAL;
+		counter->failcnt = 0;
 		break;
+	default:
+		BUG();
 	}
 
 	return nbytes;
@@ -4370,6 +4326,7 @@ static inline void mem_cgroup_lru_names_not_uptodate(void)
 static int memcg_stat_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	unsigned long memory, memsw;
 	struct mem_cgroup *mi;
 	unsigned int i;
 
@@ -4389,14 +4346,16 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 			   mem_cgroup_nr_lru_pages(memcg, BIT(i)) * PAGE_SIZE);
 
 	/* Hierarchical information */
-	{
-		unsigned long long limit, memsw_limit;
-		memcg_get_hierarchical_limit(memcg, &limit, &memsw_limit);
-		seq_printf(m, "hierarchical_memory_limit %llu\n", limit);
-		if (do_swap_account)
-			seq_printf(m, "hierarchical_memsw_limit %llu\n",
-				   memsw_limit);
+	memory = memsw = PAGE_COUNTER_MAX;
+	for (mi = memcg; mi; mi = parent_mem_cgroup(mi)) {
+		memory = min(memory, mi->memory.limit);
+		memsw = min(memsw, mi->memsw.limit);
 	}
+	seq_printf(m, "hierarchical_memory_limit %llu\n",
+		   (u64)memory * PAGE_SIZE);
+	if (do_swap_account)
+		seq_printf(m, "hierarchical_memsw_limit %llu\n",
+			   (u64)memsw * PAGE_SIZE);
 
 	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
 		long long val = 0;
@@ -4480,7 +4439,7 @@ static int mem_cgroup_swappiness_write(struct cgroup_subsys_state *css,
 static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
 {
 	struct mem_cgroup_threshold_ary *t;
-	u64 usage;
+	unsigned long usage;
 	int i;
 
 	rcu_read_lock();
@@ -4579,10 +4538,11 @@ static int __mem_cgroup_usage_register_event(struct mem_cgroup *memcg,
 {
 	struct mem_cgroup_thresholds *thresholds;
 	struct mem_cgroup_threshold_ary *new;
-	u64 threshold, usage;
+	unsigned long threshold;
+	unsigned long usage;
 	int i, size, ret;
 
-	ret = res_counter_memparse_write_strategy(args, &threshold);
+	ret = page_counter_memparse(args, &threshold);
 	if (ret)
 		return ret;
 
@@ -4672,7 +4632,7 @@ static void __mem_cgroup_usage_unregister_event(struct mem_cgroup *memcg,
 {
 	struct mem_cgroup_thresholds *thresholds;
 	struct mem_cgroup_threshold_ary *new;
-	u64 usage;
+	unsigned long usage;
 	int i, j, size;
 
 	mutex_lock(&memcg->thresholds_lock);
@@ -4866,7 +4826,7 @@ static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
 
 	memcg_kmem_mark_dead(memcg);
 
-	if (res_counter_read_u64(&memcg->kmem, RES_USAGE) != 0)
+	if (page_counter_read(&memcg->kmem))
 		return;
 
 	if (memcg_kmem_test_and_clear_dead(memcg))
@@ -5346,9 +5306,9 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
  */
 struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg)
 {
-	if (!memcg->res.parent)
+	if (!memcg->memory.parent)
 		return NULL;
-	return mem_cgroup_from_res_counter(memcg->res.parent, res);
+	return mem_cgroup_from_counter(memcg->memory.parent, memory);
 }
 EXPORT_SYMBOL(parent_mem_cgroup);
 
@@ -5393,9 +5353,9 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 	/* root ? */
 	if (parent_css == NULL) {
 		root_mem_cgroup = memcg;
-		res_counter_init(&memcg->res, NULL);
-		res_counter_init(&memcg->memsw, NULL);
-		res_counter_init(&memcg->kmem, NULL);
+		page_counter_init(&memcg->memory, NULL);
+		page_counter_init(&memcg->memsw, NULL);
+		page_counter_init(&memcg->kmem, NULL);
 	}
 
 	memcg->last_scanned_node = MAX_NUMNODES;
@@ -5433,18 +5393,18 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	memcg->swappiness = mem_cgroup_swappiness(parent);
 
 	if (parent->use_hierarchy) {
-		res_counter_init(&memcg->res, &parent->res);
-		res_counter_init(&memcg->memsw, &parent->memsw);
-		res_counter_init(&memcg->kmem, &parent->kmem);
+		page_counter_init(&memcg->memory, &parent->memory);
+		page_counter_init(&memcg->memsw, &parent->memsw);
+		page_counter_init(&memcg->kmem, &parent->kmem);
 
 		/*
 		 * No need to take a reference to the parent because cgroup
 		 * core guarantees its existence.
 		 */
 	} else {
-		res_counter_init(&memcg->res, NULL);
-		res_counter_init(&memcg->memsw, NULL);
-		res_counter_init(&memcg->kmem, NULL);
+		page_counter_init(&memcg->memory, NULL);
+		page_counter_init(&memcg->memsw, NULL);
+		page_counter_init(&memcg->kmem, NULL);
 		/*
 		 * Deeper hierachy with use_hierarchy == false doesn't make
 		 * much sense so let cgroup subsystem know about this
@@ -5515,7 +5475,7 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 	/*
 	 * XXX: css_offline() would be where we should reparent all
 	 * memory to prepare the cgroup for destruction.  However,
-	 * memcg does not do css_tryget_online() and res_counter charging
+	 * memcg does not do css_tryget_online() and page_counter charging
 	 * under the same RCU lock region, which means that charging
 	 * could race with offlining.  Offlining only happens to
 	 * cgroups with no tasks in them but charges can show up
@@ -5535,7 +5495,7 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 	 * call_rcu()
 	 *   offline_css()
 	 *     reparent_charges()
-	 *                           res_counter_charge()
+	 *                           page_counter_try_charge()
 	 *                           css_put()
 	 *                             css_free()
 	 *                           pc->mem_cgroup = dead memcg
@@ -5570,10 +5530,10 @@ static void mem_cgroup_css_reset(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
-	mem_cgroup_resize_limit(memcg, ULLONG_MAX);
-	mem_cgroup_resize_memsw_limit(memcg, ULLONG_MAX);
-	memcg_update_kmem_limit(memcg, ULLONG_MAX);
-	res_counter_set_soft_limit(&memcg->res, ULLONG_MAX);
+	mem_cgroup_resize_limit(memcg, PAGE_COUNTER_MAX);
+	mem_cgroup_resize_memsw_limit(memcg, PAGE_COUNTER_MAX);
+	memcg_update_kmem_limit(memcg, PAGE_COUNTER_MAX);
+	memcg->soft_limit = 0;
 }
 
 #ifdef CONFIG_MMU
@@ -5887,19 +5847,18 @@ static void __mem_cgroup_clear_mc(void)
 	if (mc.moved_swap) {
 		/* uncharge swap account from the old cgroup */
 		if (!mem_cgroup_is_root(mc.from))
-			res_counter_uncharge(&mc.from->memsw,
-					     PAGE_SIZE * mc.moved_swap);
-
-		for (i = 0; i < mc.moved_swap; i++)
-			css_put(&mc.from->css);
+			page_counter_uncharge(&mc.from->memsw, mc.moved_swap);
 
 		/*
-		 * we charged both to->res and to->memsw, so we should
-		 * uncharge to->res.
+		 * we charged both to->memory and to->memsw, so we
+		 * should uncharge to->memory.
 		 */
 		if (!mem_cgroup_is_root(mc.to))
-			res_counter_uncharge(&mc.to->res,
-					     PAGE_SIZE * mc.moved_swap);
+			page_counter_uncharge(&mc.to->memory, mc.moved_swap);
+
+		for (i = 0; i < mc.moved_swap; i++)
+			css_put(&mc.from->css);
+
 		/* we've already done css_get(mc.to) */
 		mc.moved_swap = 0;
 	}
@@ -6265,7 +6224,7 @@ void mem_cgroup_uncharge_swap(swp_entry_t entry)
 	memcg = mem_cgroup_lookup(id);
 	if (memcg) {
 		if (!mem_cgroup_is_root(memcg))
-			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
+			page_counter_uncharge(&memcg->memsw, 1);
 		mem_cgroup_swap_statistics(memcg, false);
 		css_put(&memcg->css);
 	}
@@ -6431,11 +6390,9 @@ static void uncharge_batch(struct mem_cgroup *memcg, unsigned long pgpgout,
 
 	if (!mem_cgroup_is_root(memcg)) {
 		if (nr_mem)
-			res_counter_uncharge(&memcg->res,
-					     nr_mem * PAGE_SIZE);
+			page_counter_uncharge(&memcg->memory, nr_mem);
 		if (nr_memsw)
-			res_counter_uncharge(&memcg->memsw,
-					     nr_memsw * PAGE_SIZE);
+			page_counter_uncharge(&memcg->memsw, nr_memsw);
 		memcg_oom_recover(memcg);
 	}
 
diff --git a/mm/page_counter.c b/mm/page_counter.c
new file mode 100644
index 000000000000..51c45921b8d1
--- /dev/null
+++ b/mm/page_counter.c
@@ -0,0 +1,191 @@
+/*
+ * Lockless hierarchical page accounting & limiting
+ *
+ * Copyright (C) 2014 Red Hat, Inc., Johannes Weiner
+ */
+#include <linux/page_counter.h>
+#include <linux/atomic.h>
+
+/**
+ * page_counter_cancel - take pages out of the local counter
+ * @counter: counter
+ * @nr_pages: number of pages to cancel
+ *
+ * Returns whether there are remaining pages in the counter.
+ */
+int page_counter_cancel(struct page_counter *counter, unsigned long nr_pages)
+{
+	long new;
+
+	new = atomic_long_sub_return(nr_pages, &counter->count);
+
+	if (WARN_ON_ONCE(new < 0))
+		atomic_long_add(nr_pages, &counter->count);
+
+	return new > 0;
+}
+
+/**
+ * page_counter_charge - hierarchically charge pages
+ * @counter: counter
+ * @nr_pages: number of pages to charge
+ *
+ * NOTE: This may exceed the configured counter limits.
+ */
+void page_counter_charge(struct page_counter *counter, unsigned long nr_pages)
+{
+	struct page_counter *c;
+
+	for (c = counter; c; c = c->parent) {
+		long new;
+
+		new = atomic_long_add_return(nr_pages, &c->count);
+		/*
+		 * This is racy, but with the per-cpu caches on top
+		 * it's just a ballpark metric anyway; and with lazy
+		 * cache reclaim, the majority of workloads peg the
+		 * watermark to the group limit soon after launch.
+		 */
+		if (new > c->watermark)
+			c->watermark = new;
+	}
+}
+
+/**
+ * page_counter_try_charge - try to hierarchically charge pages
+ * @counter: counter
+ * @nr_pages: number of pages to charge
+ * @fail: points first counter to hit its limit, if any
+ *
+ * Returns 0 on success, or -ENOMEM and @fail if the counter or one of
+ * its ancestors has hit its limit.
+ */
+int page_counter_try_charge(struct page_counter *counter,
+			    unsigned long nr_pages,
+			    struct page_counter **fail)
+{
+	struct page_counter *c;
+
+	for (c = counter; c; c = c->parent) {
+		long new;
+		/*
+		 * Charge speculatively to avoid an expensive CAS.  If
+		 * a bigger charge fails, it might falsely lock out a
+		 * racing smaller charge and send it into reclaim
+		 * eraly, but the error is limited to the difference
+		 * between the two sizes, which is less than 2M/4M in
+		 * case of a THP locking out a regular page charge.
+		 */
+		new = atomic_long_add_return(nr_pages, &c->count);
+		if (new > c->limit) {
+			atomic_long_sub(nr_pages, &c->count);
+			/*
+			 * This is racy, but the failcnt is only a
+			 * ballpark metric anyway.
+			 */
+			c->failcnt++;
+			*fail = c;
+			goto failed;
+		}
+		/*
+		 * This is racy, but with the per-cpu caches on top
+		 * it's just a ballpark metric anyway; and with lazy
+		 * cache reclaim, the majority of workloads peg the
+		 * watermark to the group limit soon after launch.
+		 */
+		if (new > c->watermark)
+			c->watermark = new;
+	}
+	return 0;
+
+failed:
+	for (c = counter; c != *fail; c = c->parent)
+		page_counter_cancel(c, nr_pages);
+
+	return -ENOMEM;
+}
+
+/**
+ * page_counter_uncharge - hierarchically uncharge pages
+ * @counter: counter
+ * @nr_pages: number of pages to uncharge
+ *
+ * Returns whether there are remaining charges in @counter.
+ */
+int page_counter_uncharge(struct page_counter *counter, unsigned long nr_pages)
+{
+	struct page_counter *c;
+	int ret = 1;
+
+	for (c = counter; c; c = c->parent) {
+		int remainder;
+
+		remainder = page_counter_cancel(c, nr_pages);
+		if (c == counter && !remainder)
+			ret = 0;
+	}
+
+	return ret;
+}
+
+/**
+ * page_counter_limit - limit the number of pages allowed
+ * @counter: counter
+ * @limit: limit to set
+ *
+ * Returns 0 on success, -EBUSY if the current number of pages on the
+ * counter already exceeds the specified limit.
+ *
+ * The caller must serialize invocations on the same counter.
+ */
+int page_counter_limit(struct page_counter *counter, unsigned long limit)
+{
+	for (;;) {
+		unsigned long old;
+		long count;
+
+		count = atomic_long_read(&counter->count);
+
+		old = xchg(&counter->limit, limit);
+
+		if (atomic_long_read(&counter->count) != count) {
+			counter->limit = old;
+			continue;
+		}
+
+		if (count > limit) {
+			counter->limit = old;
+			return -EBUSY;
+		}
+
+		return 0;
+	}
+}
+
+/**
+ * page_counter_memparse - memparse() for page counter limits
+ * @buf: string to parse
+ * @nr_pages: returns the result in number of pages
+ *
+ * Returns -EINVAL, or 0 and @nr_pages on success.  @nr_pages will be
+ * limited to %PAGE_COUNTER_MAX.
+ */
+int page_counter_memparse(const char *buf, unsigned long *nr_pages)
+{
+	char unlimited[] = "-1";
+	char *end;
+	u64 bytes;
+
+	if (!strncmp(buf, unlimited, sizeof(unlimited))) {
+		*nr_pages = PAGE_COUNTER_MAX;
+		return 0;
+	}
+
+	bytes = memparse(buf, &end);
+	if (*end != '\0')
+		return -EINVAL;
+
+	*nr_pages = min(bytes / PAGE_SIZE, (u64)PAGE_COUNTER_MAX);
+
+	return 0;
+}
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index 1d191357bf88..272327134a1b 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -9,13 +9,13 @@
 int tcp_init_cgroup(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
 	/*
-	 * The root cgroup does not use res_counters, but rather,
+	 * The root cgroup does not use page_counters, but rather,
 	 * rely on the data already collected by the network
 	 * subsystem
 	 */
-	struct res_counter *res_parent = NULL;
-	struct cg_proto *cg_proto, *parent_cg;
 	struct mem_cgroup *parent = parent_mem_cgroup(memcg);
+	struct page_counter *counter_parent = NULL;
+	struct cg_proto *cg_proto, *parent_cg;
 
 	cg_proto = tcp_prot.proto_cgroup(memcg);
 	if (!cg_proto)
@@ -29,9 +29,9 @@ int tcp_init_cgroup(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 
 	parent_cg = tcp_prot.proto_cgroup(parent);
 	if (parent_cg)
-		res_parent = &parent_cg->memory_allocated;
+		counter_parent = &parent_cg->memory_allocated;
 
-	res_counter_init(&cg_proto->memory_allocated, res_parent);
+	page_counter_init(&cg_proto->memory_allocated, counter_parent);
 	percpu_counter_init(&cg_proto->sockets_allocated, 0, GFP_KERNEL);
 
 	return 0;
@@ -50,7 +50,7 @@ void tcp_destroy_cgroup(struct mem_cgroup *memcg)
 }
 EXPORT_SYMBOL(tcp_destroy_cgroup);
 
-static int tcp_update_limit(struct mem_cgroup *memcg, u64 val)
+static int tcp_update_limit(struct mem_cgroup *memcg, unsigned long nr_pages)
 {
 	struct cg_proto *cg_proto;
 	int i;
@@ -60,20 +60,17 @@ static int tcp_update_limit(struct mem_cgroup *memcg, u64 val)
 	if (!cg_proto)
 		return -EINVAL;
 
-	if (val > RES_COUNTER_MAX)
-		val = RES_COUNTER_MAX;
-
-	ret = res_counter_set_limit(&cg_proto->memory_allocated, val);
+	ret = page_counter_limit(&cg_proto->memory_allocated, nr_pages);
 	if (ret)
 		return ret;
 
 	for (i = 0; i < 3; i++)
-		cg_proto->sysctl_mem[i] = min_t(long, val >> PAGE_SHIFT,
+		cg_proto->sysctl_mem[i] = min_t(long, nr_pages,
 						sysctl_tcp_mem[i]);
 
-	if (val == RES_COUNTER_MAX)
+	if (nr_pages == PAGE_COUNTER_MAX)
 		clear_bit(MEMCG_SOCK_ACTIVE, &cg_proto->flags);
-	else if (val != RES_COUNTER_MAX) {
+	else {
 		/*
 		 * The active bit needs to be written after the static_key
 		 * update. This is what guarantees that the socket activation
@@ -102,11 +99,20 @@ static int tcp_update_limit(struct mem_cgroup *memcg, u64 val)
 	return 0;
 }
 
+enum {
+	RES_USAGE,
+	RES_LIMIT,
+	RES_MAX_USAGE,
+	RES_FAILCNT,
+};
+
+static DEFINE_MUTEX(tcp_limit_mutex);
+
 static ssize_t tcp_cgroup_write(struct kernfs_open_file *of,
 				char *buf, size_t nbytes, loff_t off)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
-	unsigned long long val;
+	unsigned long nr_pages;
 	int ret = 0;
 
 	buf = strstrip(buf);
@@ -114,10 +120,12 @@ static ssize_t tcp_cgroup_write(struct kernfs_open_file *of,
 	switch (of_cft(of)->private) {
 	case RES_LIMIT:
 		/* see memcontrol.c */
-		ret = res_counter_memparse_write_strategy(buf, &val);
+		ret = page_counter_memparse(buf, &nr_pages);
 		if (ret)
 			break;
-		ret = tcp_update_limit(memcg, val);
+		mutex_lock(&tcp_limit_mutex);
+		ret = tcp_update_limit(memcg, nr_pages);
+		mutex_unlock(&tcp_limit_mutex);
 		break;
 	default:
 		ret = -EINVAL;
@@ -126,43 +134,36 @@ static ssize_t tcp_cgroup_write(struct kernfs_open_file *of,
 	return ret ?: nbytes;
 }
 
-static u64 tcp_read_stat(struct mem_cgroup *memcg, int type, u64 default_val)
-{
-	struct cg_proto *cg_proto;
-
-	cg_proto = tcp_prot.proto_cgroup(memcg);
-	if (!cg_proto)
-		return default_val;
-
-	return res_counter_read_u64(&cg_proto->memory_allocated, type);
-}
-
-static u64 tcp_read_usage(struct mem_cgroup *memcg)
-{
-	struct cg_proto *cg_proto;
-
-	cg_proto = tcp_prot.proto_cgroup(memcg);
-	if (!cg_proto)
-		return atomic_long_read(&tcp_memory_allocated) << PAGE_SHIFT;
-
-	return res_counter_read_u64(&cg_proto->memory_allocated, RES_USAGE);
-}
-
 static u64 tcp_cgroup_read(struct cgroup_subsys_state *css, struct cftype *cft)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+	struct cg_proto *cg_proto = tcp_prot.proto_cgroup(memcg);
 	u64 val;
 
 	switch (cft->private) {
 	case RES_LIMIT:
-		val = tcp_read_stat(memcg, RES_LIMIT, RES_COUNTER_MAX);
+		if (!cg_proto)
+			return PAGE_COUNTER_MAX;
+		val = cg_proto->memory_allocated.limit;
+		val *= PAGE_SIZE;
 		break;
 	case RES_USAGE:
-		val = tcp_read_usage(memcg);
+		if (!cg_proto)
+			val = atomic_long_read(&tcp_memory_allocated);
+		else
+			val = page_counter_read(&cg_proto->memory_allocated);
+		val *= PAGE_SIZE;
 		break;
 	case RES_FAILCNT:
+		if (!cg_proto)
+			return 0;
+		val = cg_proto->memory_allocated.failcnt;
+		break;
 	case RES_MAX_USAGE:
-		val = tcp_read_stat(memcg, cft->private, 0);
+		if (!cg_proto)
+			return 0;
+		val = cg_proto->memory_allocated.watermark;
+		val *= PAGE_SIZE;
 		break;
 	default:
 		BUG();
@@ -183,10 +184,10 @@ static ssize_t tcp_cgroup_reset(struct kernfs_open_file *of,
 
 	switch (of_cft(of)->private) {
 	case RES_MAX_USAGE:
-		res_counter_reset_max(&cg_proto->memory_allocated);
+		page_counter_reset_watermark(&cg_proto->memory_allocated);
 		break;
 	case RES_FAILCNT:
-		res_counter_reset_failcnt(&cg_proto->memory_allocated);
+		cg_proto->memory_allocated.failcnt = 0;
 		break;
 	}
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
