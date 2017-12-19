Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E215B6B0038
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 19:02:00 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id i7so6261853plt.3
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 16:02:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x6sor3651336pgr.63.2017.12.18.16.01.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Dec 2017 16:01:59 -0800 (PST)
From: Shakeel Butt <shakeelb@google.com>
Subject: [RFC PATCH] mm: memcontrol: memory+swap accounting for cgroup-v2
Date: Mon, 18 Dec 2017 16:01:31 -0800
Message-Id: <20171219000131.149170-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

The memory controller in cgroup v1 provides the memory+swap (memsw)
interface to account to the combined usage of memory and swap of the
jobs. The memsw interface allows the users to limit or view the
consistent memory usage of their jobs irrespectibe of the presense of
swap on the system (consistent OOM and memory reclaim behavior). The
memory+swap accounting makes the job easier for centralized systems
doing resource usage monitoring, prediction or anomaly detection.

In cgroup v2, the 'memsw' interface was dropped and a new 'swap'
interface has been introduced which allows to limit the actual usage of
swap by the job. For the systems where swap is a limited resource,
'swap' interface can be used to fairly distribute the swap resource
between different jobs. There is no easy way to limit the swap usage
using the 'memsw' interface.

However for the systems where the swap is cheap and can be increased
dynamically (like remote swap and swap on zram), the 'memsw' interface
is much more appropriate as it makes swap transparent to the jobs and
gives consistent memory usage history to centralized monitoring systems.

This patch adds memsw interface to cgroup v2 memory controller behind a
mount option 'memsw'. The memsw interface is mutually exclusive with
the existing swap interface. When 'memsw' is enabled, reading or writing
to 'swap' interface files will return -ENOTSUPP and vice versa. Enabling
or disabling memsw through remounting cgroup v2, will only be effective
if there are no decendants of the root cgroup.

When memsw accounting is enabled then "memory.high" is comapred with
memory+swap usage. So, when the allocating job's memsw usage hits its
high mark, the job will be throttled by triggering memory reclaim.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 Documentation/cgroup-v2.txt |  69 ++++++++++++++++++++--------
 include/linux/cgroup-defs.h |   5 +++
 kernel/cgroup/cgroup.c      |  12 +++++
 mm/memcontrol.c             | 107 +++++++++++++++++++++++++++++++++++++-------
 4 files changed, 157 insertions(+), 36 deletions(-)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
index 9a4f2e54a97d..1cbc51203b00 100644
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -169,6 +169,12 @@ cgroup v2 currently supports the following mount options.
 	ignored on non-init namespace mounts.  Please refer to the
 	Delegation section for details.
 
+  memsw
+
+	Allows the enforcement of memory+swap limit on cgroups. This
+	option is system wide and can only be set on mount and can only
+	be modified through remount from the init namespace and if root
+	cgroup has no children.
 
 Organizing Processes and Threads
 --------------------------------
@@ -1020,6 +1026,10 @@ PAGE_SIZE multiple when read back.
 	Going over the high limit never invokes the OOM killer and
 	under extreme conditions the limit may be breached.
 
+	If memsw (memory+swap) enforcement is enabled then the
+	cgroup's memory+swap usage is checked against memory.high
+	instead of just memory.
+
   memory.max
 	A read-write single value file which exists on non-root
 	cgroups.  The default is "max".
@@ -1207,18 +1217,39 @@ PAGE_SIZE multiple when read back.
 
   memory.swap.current
 	A read-only single value file which exists on non-root
-	cgroups.
+	cgroups. If memsw is enabled then reading this file will return
+	-ENOTSUPP.
 
 	The total amount of swap currently being used by the cgroup
 	and its descendants.
 
   memory.swap.max
 	A read-write single value file which exists on non-root
-	cgroups.  The default is "max".
+	cgroups.  The default is "max". Accessing this file will return
+	-ENOTSUPP if memsw enforcement is enabled.
 
 	Swap usage hard limit.  If a cgroup's swap usage reaches this
 	limit, anonymous meomry of the cgroup will not be swapped out.
 
+  memory.memsw.current
+	A read-only single value file which exists on non-root
+	cgroups. -ENOTSUPP will be returned on read if memsw is not
+	enabled.
+
+	The total amount of memory+swap currently being used by the cgroup
+	and its descendants.
+
+  memory.memsw.max
+	A read-write single value file which exists on non-root
+	cgroups.  The default is "max". -ENOTSUPP will be returned on
+	access if memsw is not enabled.
+
+	Memory+swap usage hard limit. If a cgroup's memory+swap usage
+	reaches this limit and 	can't be reduced, the OOM killer is
+	invoked in the cgroup. Under certain circumstances, the usage
+	may go over the limit temporarily.
+
+
 
 Usage Guidelines
 ~~~~~~~~~~~~~~~~
@@ -1243,6 +1274,23 @@ memory - is necessary to determine whether a workload needs more
 memory; unfortunately, memory pressure monitoring mechanism isn't
 implemented yet.
 
+Please note that when memory+swap accounting is enforced then the
+"memory.high" is checked and enforced against memory+swap usage instead
+of just memory usage.
+
+Memory+Swap interface
+~~~~~~~~~~~~~~~~~~~~~
+
+The memory+swap i.e. memsw interface allows to limit and view the
+combined usage of memory and swap of the jobs. It gives a consistent
+memory usage history or memory limit enforcement irrespective of the
+presense of swap on the system. The consistent memory usage history
+is useful for centralized systems doing resource usage monitoring,
+prediction or anomaly detection.
+
+Also when swap is cheap, can be increased dynamically, is a system
+level resource and transparent to jobs, the memsw interface is more
+appropriate to use than just swap interface.
 
 Memory Ownership
 ~~~~~~~~~~~~~~~~
@@ -1987,20 +2035,3 @@ subject to a race condition, where concurrent charges could cause the
 limit setting to fail. memory.max on the other hand will first set the
 limit to prevent new charges, and then reclaim and OOM kill until the
 new limit is met - or the task writing to memory.max is killed.
-
-The combined memory+swap accounting and limiting is replaced by real
-control over swap space.
-
-The main argument for a combined memory+swap facility in the original
-cgroup design was that global or parental pressure would always be
-able to swap all anonymous memory of a child group, regardless of the
-child's own (possibly untrusted) configuration.  However, untrusted
-groups can sabotage swapping by other means - such as referencing its
-anonymous memory in a tight loop - and an admin can not assume full
-swappability when overcommitting untrusted jobs.
-
-For trusted jobs, on the other hand, a combined counter is not an
-intuitive userspace interface, and it flies in the face of the idea
-that cgroup controllers should account and limit specific physical
-resources.  Swap space is a resource like all others in the system,
-and that's why unified hierarchy allows distributing it separately.
diff --git a/include/linux/cgroup-defs.h b/include/linux/cgroup-defs.h
index 9fb99e25d654..d72c14eb1f5a 100644
--- a/include/linux/cgroup-defs.h
+++ b/include/linux/cgroup-defs.h
@@ -86,6 +86,11 @@ enum {
 	 * Enable cgroup-aware OOM killer.
 	 */
 	CGRP_GROUP_OOM = (1 << 5),
+
+	/*
+	 * Enable memsw interface in cgroup-v2.
+	 */
+	CGRP_ROOT_MEMSW = (1 << 6),
 };
 
 /* cftype->flags */
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index 693443282fc1..bedc24391879 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -1734,6 +1734,9 @@ static int parse_cgroup_root_flags(char *data, unsigned int *root_flags)
 		} else if (!strcmp(token, "groupoom")) {
 			*root_flags |= CGRP_GROUP_OOM;
 			continue;
+		} else if (!strcmp(token, "memsw")) {
+			*root_flags |= CGRP_ROOT_MEMSW;
+			continue;
 		}
 
 		pr_err("cgroup2: unknown option \"%s\"\n", token);
@@ -1755,6 +1758,13 @@ static void apply_cgroup_root_flags(unsigned int root_flags)
 			cgrp_dfl_root.flags |= CGRP_GROUP_OOM;
 		else
 			cgrp_dfl_root.flags &= ~CGRP_GROUP_OOM;
+
+		if (!cgrp_dfl_root.cgrp.nr_descendants) {
+			if (root_flags & CGRP_ROOT_MEMSW)
+				cgrp_dfl_root.flags |= CGRP_ROOT_MEMSW;
+			else
+				cgrp_dfl_root.flags &= ~CGRP_ROOT_MEMSW;
+		}
 	}
 }
 
@@ -1764,6 +1774,8 @@ static int cgroup_show_options(struct seq_file *seq, struct kernfs_root *kf_root
 		seq_puts(seq, ",nsdelegate");
 	if (cgrp_dfl_root.flags & CGRP_GROUP_OOM)
 		seq_puts(seq, ",groupoom");
+	if (cgrp_dfl_root.flags & CGRP_ROOT_MEMSW)
+		seq_puts(seq, ",memsw");
 	return 0;
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f40b5ad3f959..b04ba19a8c64 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -94,10 +94,12 @@ int do_swap_account __read_mostly;
 #define do_swap_account		0
 #endif
 
-/* Whether legacy memory+swap accounting is active */
+/* Whether memory+swap accounting is active */
 static bool do_memsw_account(void)
 {
-	return !cgroup_subsys_on_dfl(memory_cgrp_subsys) && do_swap_account;
+	return do_swap_account &&
+		(!cgroup_subsys_on_dfl(memory_cgrp_subsys) ||
+		 cgrp_dfl_root.flags & CGRP_ROOT_MEMSW);
 }
 
 static const char *const mem_cgroup_lru_names[] = {
@@ -1868,11 +1870,15 @@ static void reclaim_high(struct mem_cgroup *memcg,
 			 unsigned int nr_pages,
 			 gfp_t gfp_mask)
 {
+	struct page_counter *counter;
+	bool memsw = cgrp_dfl_root.flags & CGRP_ROOT_MEMSW;
+
 	do {
-		if (page_counter_read(&memcg->memory) <= memcg->high)
+		counter = memsw ? &memcg->memsw : &memcg->memory;
+		if (page_counter_read(counter) <= memcg->high)
 			continue;
 		mem_cgroup_event(memcg, MEMCG_HIGH);
-		try_to_free_mem_cgroup_pages(memcg, nr_pages, gfp_mask, true);
+		try_to_free_mem_cgroup_pages(memcg, nr_pages, gfp_mask, !memsw);
 	} while ((memcg = parent_mem_cgroup(memcg)));
 }
 
@@ -1912,6 +1918,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	unsigned long nr_reclaimed;
 	bool may_swap = true;
 	bool drained = false;
+	bool memsw = cgrp_dfl_root.flags & CGRP_ROOT_MEMSW;
 
 	if (mem_cgroup_is_root(memcg))
 		return 0;
@@ -2040,7 +2047,8 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * reclaim, the cost of mismatch is negligible.
 	 */
 	do {
-		if (page_counter_read(&memcg->memory) > memcg->high) {
+		counter = memsw ? &memcg->memsw : &memcg->memory;
+		if (page_counter_read(counter) > memcg->high) {
 			/* Don't bother a random interrupted task */
 			if (in_interrupt()) {
 				schedule_work(&memcg->high_work);
@@ -3906,6 +3914,7 @@ void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(wb->memcg_css);
 	struct mem_cgroup *parent;
+	bool memsw = cgrp_dfl_root.flags & CGRP_ROOT_MEMSW;
 
 	*pdirty = memcg_page_state(memcg, NR_FILE_DIRTY);
 
@@ -3919,6 +3928,9 @@ void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
 		unsigned long ceiling = min(memcg->memory.limit, memcg->high);
 		unsigned long used = page_counter_read(&memcg->memory);
 
+		if (memsw)
+			ceiling = min(ceiling, memcg->memsw.limit);
+
 		*pheadroom = min(*pheadroom, ceiling - min(ceiling, used));
 		memcg = parent;
 	}
@@ -5395,6 +5407,7 @@ static ssize_t memory_high_write(struct kernfs_open_file *of,
 				 char *buf, size_t nbytes, loff_t off)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+	bool memsw = cgrp_dfl_root.flags & CGRP_ROOT_MEMSW;
 	unsigned long nr_pages;
 	unsigned long high;
 	int err;
@@ -5406,10 +5419,10 @@ static ssize_t memory_high_write(struct kernfs_open_file *of,
 
 	memcg->high = high;
 
-	nr_pages = page_counter_read(&memcg->memory);
+	nr_pages = page_counter_read(memsw ? &memcg->memsw : &memcg->memory);
 	if (nr_pages > high)
 		try_to_free_mem_cgroup_pages(memcg, nr_pages - high,
-					     GFP_KERNEL, true);
+					     GFP_KERNEL, !memsw);
 
 	memcg_wb_domain_size_changed(memcg);
 	return nbytes;
@@ -5428,10 +5441,10 @@ static int memory_max_show(struct seq_file *m, void *v)
 	return 0;
 }
 
-static ssize_t memory_max_write(struct kernfs_open_file *of,
-				char *buf, size_t nbytes, loff_t off)
+static ssize_t counter_max_write(struct mem_cgroup *memcg,
+				 struct page_counter *counter, char *buf,
+				 size_t nbytes, bool may_swap)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
 	unsigned int nr_reclaims = MEM_CGROUP_RECLAIM_RETRIES;
 	bool drained = false;
 	unsigned long max;
@@ -5442,10 +5455,10 @@ static ssize_t memory_max_write(struct kernfs_open_file *of,
 	if (err)
 		return err;
 
-	xchg(&memcg->memory.limit, max);
+	xchg(&counter->limit, max);
 
 	for (;;) {
-		unsigned long nr_pages = page_counter_read(&memcg->memory);
+		unsigned long nr_pages = page_counter_read(counter);
 
 		if (nr_pages <= max)
 			break;
@@ -5463,7 +5476,7 @@ static ssize_t memory_max_write(struct kernfs_open_file *of,
 
 		if (nr_reclaims) {
 			if (!try_to_free_mem_cgroup_pages(memcg, nr_pages - max,
-							  GFP_KERNEL, true))
+							  GFP_KERNEL, may_swap))
 				nr_reclaims--;
 			continue;
 		}
@@ -5477,6 +5490,14 @@ static ssize_t memory_max_write(struct kernfs_open_file *of,
 	return nbytes;
 }
 
+static ssize_t memory_max_write(struct kernfs_open_file *of,
+				char *buf, size_t nbytes, loff_t off)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+
+	return counter_max_write(memcg, &memcg->memory, buf, nbytes, true);
+}
+
 static int memory_oom_group_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
@@ -6311,7 +6332,7 @@ int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry)
 	struct mem_cgroup *memcg;
 	unsigned short oldid;
 
-	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) || !do_swap_account)
+	if (!do_swap_account || do_memsw_account())
 		return 0;
 
 	memcg = page->mem_cgroup;
@@ -6356,7 +6377,7 @@ void mem_cgroup_uncharge_swap(swp_entry_t entry, unsigned int nr_pages)
 	memcg = mem_cgroup_from_id(id);
 	if (memcg) {
 		if (!mem_cgroup_is_root(memcg)) {
-			if (cgroup_subsys_on_dfl(memory_cgrp_subsys))
+			if (!do_memsw_account())
 				page_counter_uncharge(&memcg->swap, nr_pages);
 			else
 				page_counter_uncharge(&memcg->memsw, nr_pages);
@@ -6371,7 +6392,7 @@ long mem_cgroup_get_nr_swap_pages(struct mem_cgroup *memcg)
 {
 	long nr_swap_pages = get_nr_swap_pages();
 
-	if (!do_swap_account || !cgroup_subsys_on_dfl(memory_cgrp_subsys))
+	if (!do_swap_account || do_memsw_account())
 		return nr_swap_pages;
 	for (; memcg != root_mem_cgroup; memcg = parent_mem_cgroup(memcg))
 		nr_swap_pages = min_t(long, nr_swap_pages,
@@ -6388,7 +6409,7 @@ bool mem_cgroup_swap_full(struct page *page)
 
 	if (vm_swap_full())
 		return true;
-	if (!do_swap_account || !cgroup_subsys_on_dfl(memory_cgrp_subsys))
+	if (!do_swap_account || do_memsw_account())
 		return false;
 
 	memcg = page->mem_cgroup;
@@ -6432,6 +6453,9 @@ static int swap_max_show(struct seq_file *m, void *v)
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
 	unsigned long max = READ_ONCE(memcg->swap.limit);
 
+	if (do_memsw_account())
+		return -ENOTSUPP;
+
 	if (max == PAGE_COUNTER_MAX)
 		seq_puts(m, "max\n");
 	else
@@ -6447,6 +6471,9 @@ static ssize_t swap_max_write(struct kernfs_open_file *of,
 	unsigned long max;
 	int err;
 
+	if (do_memsw_account())
+		return -ENOTSUPP;
+
 	buf = strstrip(buf);
 	err = page_counter_memparse(buf, "max", &max);
 	if (err)
@@ -6461,6 +6488,41 @@ static ssize_t swap_max_write(struct kernfs_open_file *of,
 	return nbytes;
 }
 
+static u64 memsw_current_read(struct cgroup_subsys_state *css,
+			     struct cftype *cft)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+
+	return (u64)page_counter_read(&memcg->memsw) * PAGE_SIZE;
+}
+
+static int memsw_max_show(struct seq_file *m, void *v)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	unsigned long max = READ_ONCE(memcg->memsw.limit);
+
+	if (!do_memsw_account())
+		return -ENOTSUPP;
+
+	if (max == PAGE_COUNTER_MAX)
+		seq_puts(m, "max\n");
+	else
+		seq_printf(m, "%llu\n", (u64)max * PAGE_SIZE);
+
+	return 0;
+}
+
+static ssize_t memsw_max_write(struct kernfs_open_file *of,
+				char *buf, size_t nbytes, loff_t off)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+
+	if (!do_memsw_account())
+		return -ENOTSUPP;
+
+	return counter_max_write(memcg, &memcg->memsw, buf, nbytes, false);
+}
+
 static struct cftype swap_files[] = {
 	{
 		.name = "swap.current",
@@ -6473,6 +6535,17 @@ static struct cftype swap_files[] = {
 		.seq_show = swap_max_show,
 		.write = swap_max_write,
 	},
+	{
+		.name = "memsw.current",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.read_u64 = memsw_current_read,
+	},
+	{
+		.name = "memsw.max",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.seq_show = memsw_max_show,
+		.write = memsw_max_write,
+	},
 	{ }	/* terminate */
 };
 
-- 
2.15.1.504.g5279b80103-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
