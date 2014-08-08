Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 169CA6B0038
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 17:38:26 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id k48so6148212wev.40
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 14:38:26 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id kp1si13561604wjb.61.2014.08.08.14.38.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 08 Aug 2014 14:38:25 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/4] mm: memcontrol: add memory.current and memory.high to default hierarchy
Date: Fri,  8 Aug 2014 17:38:12 -0400
Message-Id: <1407533894-25845-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1407533894-25845-1-git-send-email-hannes@cmpxchg.org>
References: <1407533894-25845-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Provide the most fundamental interface necessary for memory cgroups to
partition the machine for concurrent workloads in unified hierarchy:
report the current usage and allow setting an upper limit on it.

The upper limit, set in memory.high, is not a strict OOM limit and is
enforced purely by direct reclaim.  This is a deviation from the old
hard upper limit, which history has shown to fail at partitioning a
machine for real workloads in a resource-efficient manner: if chosen
conservatively, the hard limit risks OOM kills; if chosen generously,
memory is underutilized most of the time.  As a result, in practice
the limit is mostly used to contain extremes and balancing of regular
workingset fluctuations and cache trimming is left to global reclaim
and the global OOM killer, which creates an increasing demand for
complicated cgroup-specific prioritization features in both of them.

The high limit on the other hand is a target size limit that is meant
to trim caches and keep consumption at the average working set size
while providing elasticity for peaks.  This allows memory cgroups to
be useful for workload packing without relying too much on global VM
interventions, except for parallel peaks or inadequate configurations.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 Documentation/cgroups/unified-hierarchy.txt | 52 +++++++++++++++++
 include/linux/res_counter.h                 | 29 ++++++++++
 kernel/res_counter.c                        |  3 +
 mm/memcontrol.c                             | 89 ++++++++++++++++++++++++++---
 4 files changed, 164 insertions(+), 9 deletions(-)

diff --git a/Documentation/cgroups/unified-hierarchy.txt b/Documentation/cgroups/unified-hierarchy.txt
index 4f4563277864..2d91530b8d6c 100644
--- a/Documentation/cgroups/unified-hierarchy.txt
+++ b/Documentation/cgroups/unified-hierarchy.txt
@@ -324,9 +324,61 @@ supported and the interface files "release_agent" and
 
 4-3-3. memory
 
+Memory cgroups account and limit the memory consumption of cgroups,
+but the current limit semantics make the feature hard to use and
+creates problems in existing configurations.
+
+4.3.3.1 No more default hard limit
+
+'memory.limit_in_bytes' is the current upper limit that can not be
+exceeded under any circumstances.  If it can not be met by direct
+reclaim, the tasks in the cgroup are OOM killed.
+
+While this may look like a valid approach to partition the machine, in
+practice workloads expand and contract during runtime, and it's
+impossible to get the machine-wide configuration right: if users set
+this hard limit conservatively, they are plagued by cgroup-internal
+OOM kills during peaks while memory might be idle (external waste).
+If they set it too generously, precious resources are either unused or
+wasted on old cache (internal waste).  Because of that, in practice
+users set the hard limit only to handle extremes and then overcommit
+the machine.  This leaves the actual partitioning and group trimming
+to global reclaim and OOM handling, which has led to increasing
+demands for recognizing cgroup policy during global reclaim, and even
+the ability to handle global OOM situations from userspace using
+task-specific memory reserves.  All these outcomes and developments
+show the utter failure of hard limits to effectively partition the
+machine for maximum utilization.
+
+When it comes to monitoring cgroup health, 'memory.pressure_level' was
+added for userspace to monitor memory pressure based on group-internal
+reclaim efficiency.  But as per above the group trimming is mostly
+done by global reclaim and the pressure the group experiences is not
+proportional to its excess.  And once internal pressure actually
+builds, the window between onset and an OOM kill can be very short
+with hard limits - by the time internal pressure is reported to
+userspace, it's often too late to intervene before the group goes OOM.
+Both aspects severely limit the ability to monitor cgroup health,
+detect looming OOM situations, and pinpoint offenders.
+
+In unified hierarchy, the primary means of limiting memory consumption
+is 'memory.high'.  It's enforced by direct reclaim to trim caches and
+keep the workload lean, but can be exceeded during working set peaks.
+This moves the responsibility of partitioning mostly back to memory
+cgroups, and global handling only enganges during concurrent peaks.
+
+Configurations can start out by setting this limit to a conservative
+estimate of the average working set size and then make upward
+adjustments based on monitoring high limit excess, workload
+performance, and the global memory situation.
+
+4.3.3.2 Misc changes
+
 - use_hierarchy is on by default and the cgroup file for the flag is
   not created.
 
+- memory.usage_in_bytes is renamed to memory.current to be in line
+  with the new limit naming scheme
 
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
index 4146c0f47ba2..81627387fbd7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2481,8 +2481,8 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	unsigned int batch = max(CHARGE_BATCH, nr_pages);
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct mem_cgroup *mem_over_limit;
-	struct res_counter *fail_res;
 	unsigned long nr_reclaimed;
+	struct res_counter *res;
 	unsigned long long size;
 	bool may_swap = true;
 	bool drained = false;
@@ -2493,16 +2493,16 @@ retry:
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
 		may_swap = false;
 	} else
-		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
+		mem_over_limit = mem_cgroup_from_res_counter(res, res);
 
 	if (batch > nr_pages) {
 		batch = nr_pages;
@@ -2579,6 +2579,21 @@ bypass:
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
+			try_to_free_mem_cgroup_pages(memcg, high_pages,
+						     gfp_mask, true);
+		}
+		res = res->parent;
+	}
 done:
 	return ret;
 }
@@ -5141,7 +5156,7 @@ out_kfree:
 	return ret;
 }
 
-static struct cftype mem_cgroup_files[] = {
+static struct cftype mem_cgroup_legacy_files[] = {
 	{
 		.name = "usage_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEM, RES_USAGE),
@@ -5250,7 +5265,7 @@ static struct cftype mem_cgroup_files[] = {
 };
 
 #ifdef CONFIG_MEMCG_SWAP
-static struct cftype memsw_cgroup_files[] = {
+static struct cftype memsw_cgroup_legacy_files[] = {
 	{
 		.name = "memsw.usage_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_USAGE),
@@ -6195,6 +6210,61 @@ static void mem_cgroup_bind(struct cgroup_subsys_state *root_css)
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
+		try_to_free_mem_cgroup_pages(memcg, high >> PAGE_SHIFT,
+					     GFP_KERNEL, true);
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
@@ -6205,7 +6275,8 @@ struct cgroup_subsys memory_cgrp_subsys = {
 	.cancel_attach = mem_cgroup_cancel_attach,
 	.attach = mem_cgroup_move_task,
 	.bind = mem_cgroup_bind,
-	.legacy_cftypes = mem_cgroup_files,
+	.dfl_cftypes = memory_files,
+	.legacy_cftypes = mem_cgroup_legacy_files,
 	.early_init = 0,
 };
 
@@ -6223,7 +6294,7 @@ __setup("swapaccount=", enable_swap_account);
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
