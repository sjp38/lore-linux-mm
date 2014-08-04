Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 34D6A6B0038
	for <linux-mm@kvack.org>; Mon,  4 Aug 2014 17:15:11 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id k14so22499wgh.8
        for <linux-mm@kvack.org>; Mon, 04 Aug 2014 14:15:09 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id n3si7398710wjf.99.2014.08.04.14.15.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 04 Aug 2014 14:15:07 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/4] mm: memcontrol: add memory.current and memory.high to default hierarchy
Date: Mon,  4 Aug 2014 17:14:55 -0400
Message-Id: <1407186897-21048-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1407186897-21048-1-git-send-email-hannes@cmpxchg.org>
References: <1407186897-21048-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Provide the most fundamental interface necessary for memory cgroups to
be useful in the default hierarchy: report the current usage and allow
setting an upper limit on it.

The upper limit, set in memory.high, is not a strict OOM limit and can
be breached under pressure.  But once it's breached, allocators are
throttled and forced into reclaim to clean up the excess.  This has
many advantages over more traditional hard upper limits and is thus
more suitable as the default upper boundary:

First, the limit is artificial and not due to shortness of actual
memory, so invoking the OOM killer to enforce it seems excessive for
the majority of usecases.  It's much preferable to breach the limit
temporarily and throttle the allocators, which in turn gives managing
software a chance to detect pressure in the group and intervene by
re-evaluating the limit, migrating the job to another machine,
hot-plugging memory etc., without fearing interfering OOM kills.

A secondary concern is allocation fairness: requiring the limit to
always be met allows the reclaim efforts of one allocator to be stolen
by concurrent allocations.  Most usecases would prefer temporarily
exceeding the default upper limit by a few pages over starving random
allocators indefinitely.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 Documentation/cgroups/unified-hierarchy.txt |  6 ++
 include/linux/res_counter.h                 | 29 ++++++++++
 kernel/res_counter.c                        |  3 +
 mm/memcontrol.c                             | 87 ++++++++++++++++++++++++++---
 4 files changed, 116 insertions(+), 9 deletions(-)

diff --git a/Documentation/cgroups/unified-hierarchy.txt b/Documentation/cgroups/unified-hierarchy.txt
index 4f4563277864..fd4f7f6847f6 100644
--- a/Documentation/cgroups/unified-hierarchy.txt
+++ b/Documentation/cgroups/unified-hierarchy.txt
@@ -327,6 +327,12 @@ supported and the interface files "release_agent" and
 - use_hierarchy is on by default and the cgroup file for the flag is
   not created.
 
+- memory.limit_in_bytes is removed as the primary upper boundary and
+  replaced with memory.high, a soft upper limit that will put memory
+  pressure on the group but can be breached in favor of OOM killing.
+
+- memory.usage_in_bytes is renamed to memory.current to be in line
+  with the new naming scheme
 
 5. Planned Changes
 
diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index 56b7bc32db4f..27394cfdf1fe 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -32,6 +32,10 @@ struct res_counter {
 	 */
 	unsigned long long max_usage;
 	/*
+	 * the high limit that creates pressure but can be exceeded
+	 */
+	unsigned long long high;
+	/*
 	 * the limit that usage cannot exceed
 	 */
 	unsigned long long limit;
@@ -85,6 +89,7 @@ int res_counter_memparse_write_strategy(const char *buf,
 enum {
 	RES_USAGE,
 	RES_MAX_USAGE,
+	RES_HIGH,
 	RES_LIMIT,
 	RES_FAILCNT,
 	RES_SOFT_LIMIT,
@@ -132,6 +137,19 @@ u64 res_counter_uncharge(struct res_counter *counter, unsigned long val);
 u64 res_counter_uncharge_until(struct res_counter *counter,
 			       struct res_counter *top,
 			       unsigned long val);
+
+static inline unsigned long long res_counter_high(struct res_counter *cnt)
+{
+	unsigned long long high = 0;
+	unsigned long flags;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	if (cnt->usage > cnt->high)
+		high = cnt->usage - cnt->high;
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return high;
+}
+
 /**
  * res_counter_margin - calculate chargeable space of a counter
  * @cnt: the counter
@@ -193,6 +211,17 @@ static inline void res_counter_reset_failcnt(struct res_counter *cnt)
 	spin_unlock_irqrestore(&cnt->lock, flags);
 }
 
+static inline int res_counter_set_high(struct res_counter *cnt,
+				       unsigned long long high)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	cnt->high = high;
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return 0;
+}
+
 static inline int res_counter_set_limit(struct res_counter *cnt,
 		unsigned long long limit)
 {
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index e791130f85a7..26a08be49a3d 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -17,6 +17,7 @@
 void res_counter_init(struct res_counter *counter, struct res_counter *parent)
 {
 	spin_lock_init(&counter->lock);
+	counter->high = RES_COUNTER_MAX;
 	counter->limit = RES_COUNTER_MAX;
 	counter->soft_limit = RES_COUNTER_MAX;
 	counter->parent = parent;
@@ -130,6 +131,8 @@ res_counter_member(struct res_counter *counter, int member)
 		return &counter->usage;
 	case RES_MAX_USAGE:
 		return &counter->max_usage;
+	case RES_HIGH:
+		return &counter->high;
 	case RES_LIMIT:
 		return &counter->limit;
 	case RES_FAILCNT:
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ddffeeda2d52..5a64fa96c08a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2530,8 +2530,8 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	unsigned int batch = max(CHARGE_BATCH, nr_pages);
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct mem_cgroup *mem_over_limit;
-	struct res_counter *fail_res;
 	unsigned long nr_reclaimed;
+	struct res_counter *res;
 	unsigned long flags = 0;
 	unsigned long long size;
 	int ret = 0;
@@ -2541,16 +2541,16 @@ retry:
 		goto done;
 
 	size = batch * PAGE_SIZE;
-	if (!res_counter_charge(&memcg->res, size, &fail_res)) {
+	if (!res_counter_charge(&memcg->res, size, &res)) {
 		if (!do_swap_account)
 			goto done_restock;
-		if (!res_counter_charge(&memcg->memsw, size, &fail_res))
+		if (!res_counter_charge(&memcg->memsw, size, &res))
 			goto done_restock;
 		res_counter_uncharge(&memcg->res, size);
-		mem_over_limit = mem_cgroup_from_res_counter(fail_res, memsw);
+		mem_over_limit = mem_cgroup_from_res_counter(res, memsw);
 		flags |= MEM_CGROUP_RECLAIM_NOSWAP;
 	} else
-		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
+		mem_over_limit = mem_cgroup_from_res_counter(res, res);
 
 	if (batch > nr_pages) {
 		batch = nr_pages;
@@ -2621,6 +2621,20 @@ bypass:
 done_restock:
 	if (batch > nr_pages)
 		refill_stock(memcg, batch - nr_pages);
+
+	res = &memcg->res;
+	while (res) {
+		unsigned long long high = res_counter_high(res);
+
+		if (high) {
+			unsigned long high_pages = high >> PAGE_SHIFT;
+			struct mem_cgroup *memcg;
+
+			memcg = mem_cgroup_from_res_counter(res, res);
+			mem_cgroup_reclaim(memcg, high_pages, gfp_mask, 0);
+		}
+		res = res->parent;
+	}
 done:
 	return ret;
 }
@@ -5196,7 +5210,7 @@ out_kfree:
 	return ret;
 }
 
-static struct cftype mem_cgroup_files[] = {
+static struct cftype mem_cgroup_legacy_files[] = {
 	{
 		.name = "usage_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEM, RES_USAGE),
@@ -5305,7 +5319,7 @@ static struct cftype mem_cgroup_files[] = {
 };
 
 #ifdef CONFIG_MEMCG_SWAP
-static struct cftype memsw_cgroup_files[] = {
+static struct cftype memsw_cgroup_legacy_files[] = {
 	{
 		.name = "memsw.usage_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_USAGE),
@@ -6250,6 +6264,60 @@ static void mem_cgroup_bind(struct cgroup_subsys_state *root_css)
 		mem_cgroup_from_css(root_css)->use_hierarchy = true;
 }
 
+static u64 memory_current_read(struct cgroup_subsys_state *css,
+			       struct cftype *cft)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+
+	return res_counter_read_u64(&memcg->res, RES_USAGE);
+}
+
+static u64 memory_high_read(struct cgroup_subsys_state *css,
+			    struct cftype *cft)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+
+	return res_counter_read_u64(&memcg->res, RES_HIGH);
+}
+
+static ssize_t memory_high_write(struct kernfs_open_file *of,
+				 char *buf, size_t nbytes, loff_t off)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+	u64 high;
+	int ret;
+
+	if (mem_cgroup_is_root(memcg))
+		return -EINVAL;
+
+	buf = strim(buf);
+	ret = res_counter_memparse_write_strategy(buf, &high);
+	if (ret)
+		return ret;
+
+	ret = res_counter_set_high(&memcg->res, high);
+	if (ret)
+		return ret;
+
+	high = res_counter_high(&memcg->res);
+	if (high)
+		mem_cgroup_reclaim(memcg, high >> PAGE_SHIFT, GFP_KERNEL, 0);
+
+	return nbytes;
+}
+
+static struct cftype memory_files[] = {
+	{
+		.name = "current",
+		.read_u64 = memory_current_read,
+	},
+	{
+		.name = "high",
+		.read_u64 = memory_high_read,
+		.write = memory_high_write,
+	},
+};
+
 struct cgroup_subsys memory_cgrp_subsys = {
 	.css_alloc = mem_cgroup_css_alloc,
 	.css_online = mem_cgroup_css_online,
@@ -6260,7 +6328,8 @@ struct cgroup_subsys memory_cgrp_subsys = {
 	.cancel_attach = mem_cgroup_cancel_attach,
 	.attach = mem_cgroup_move_task,
 	.bind = mem_cgroup_bind,
-	.legacy_cftypes = mem_cgroup_files,
+	.dfl_cftypes = memory_files,
+	.legacy_cftypes = mem_cgroup_legacy_files,
 	.early_init = 0,
 };
 
@@ -6278,7 +6347,7 @@ __setup("swapaccount=", enable_swap_account);
 static void __init memsw_file_init(void)
 {
 	WARN_ON(cgroup_add_legacy_cftypes(&memory_cgrp_subsys,
-					  memsw_cgroup_files));
+					  memsw_cgroup_legacy_files));
 }
 
 static void __init enable_swap_cgroup(void)
-- 
2.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
