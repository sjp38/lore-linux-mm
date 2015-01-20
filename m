Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 866626B0075
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 10:32:09 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id bs8so26669778wib.5
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 07:32:09 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id s3si33760769wjx.75.2015.01.20.07.32.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jan 2015 07:32:08 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/2] mm: memcontrol: default hierarchy interface for memory
Date: Tue, 20 Jan 2015 10:31:55 -0500
Message-Id: <1421767915-14232-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1421767915-14232-1-git-send-email-hannes@cmpxchg.org>
References: <1421767915-14232-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Introduce the basic control files to account, partition, and limit
memory using cgroups in default hierarchy mode.

This interface versioning allows us to address fundamental design
issues in the existing memory cgroup interface, further explained
below.  The old interface will be maintained indefinitely, but a
clearer model and improved workload performance should encourage
existing users to switch over to the new one eventually.

The control files are thus:

  - memory.current shows the current consumption of the cgroup and its
    descendants, in bytes.

  - memory.low configures the lower end of the cgroup's expected
    memory consumption range.  The kernel considers memory below that
    boundary to be a reserve - the minimum that the workload needs in
    order to make forward progress - and generally avoids reclaiming
    it, unless there is an imminent risk of entering an OOM situation.

  - memory.high configures the upper end of the cgroup's expected
    memory consumption range.  A cgroup whose consumption grows beyond
    this threshold is forced into direct reclaim, to work off the
    excess and to throttle new allocations heavily, but is generally
    allowed to continue and the OOM killer is not invoked.

  - memory.max configures the hard maximum amount of memory that the
    cgroup is allowed to consume before the OOM killer is invoked.

  - memory.events shows event counters that indicate how often the
    cgroup was reclaimed while below memory.low, how often it was
    forced to reclaim excess beyond memory.high, how often it hit
    memory.max, and how often it entered OOM due to memory.max.  This
    allows users to identify configuration problems when observing a
    degradation in workload performance.  An overcommitted system will
    have an increased rate of low boundary breaches, whereas increased
    rates of high limit breaches, maximum hits, or even OOM situations
    will indicate internally overcommitted cgroups.

For existing users of memory cgroups, the following deviations from
the current interface are worth pointing out and explaining:

  - The original lower boundary, the soft limit, is defined as a limit
    that is per default unset.  As a result, the set of cgroups that
    global reclaim prefers is opt-in, rather than opt-out.  The costs
    for optimizing these mostly negative lookups are so high that the
    implementation, despite its enormous size, does not even provide
    the basic desirable behavior.  First off, the soft limit has no
    hierarchical meaning.  All configured groups are organized in a
    global rbtree and treated like equal peers, regardless where they
    are located in the hierarchy.  This makes subtree delegation
    impossible.  Second, the soft limit reclaim pass is so aggressive
    that it not just introduces high allocation latencies into the
    system, but also impacts system performance due to overreclaim, to
    the point where the feature becomes self-defeating.

    The memory.low boundary on the other hand is a top-down allocated
    reserve.  A cgroup enjoys reclaim protection when it and all its
    ancestors are below their low boundaries, which makes delegation
    of subtrees possible.  Secondly, new cgroups have no reserve per
    default and in the common case most cgroups are eligible for the
    preferred reclaim pass.  This allows the new low boundary to be
    efficiently implemented with just a minor addition to the generic
    reclaim code, without the need for out-of-band data structures and
    reclaim passes.  Because the generic reclaim code considers all
    cgroups except for the ones running low in the preferred first
    reclaim pass, overreclaim of individual groups is eliminated as
    well, resulting in much better overall workload performance.

  - The original high boundary, the hard limit, is defined as a strict
    limit that can not budge, even if the OOM killer has to be called.
    But this generally goes against the goal of making the most out of
    the available memory.  The memory consumption of workloads varies
    during runtime, and that requires users to overcommit.  But doing
    that with a strict upper limit requires either a fairly accurate
    prediction of the working set size or adding slack to the limit.
    Since working set size estimation is hard and error prone, and
    getting it wrong results in OOM kills, most users tend to err on
    the side of a looser limit and end up wasting precious resources.

    The memory.high boundary on the other hand can be set much more
    conservatively.  When hit, it throttles allocations by forcing
    them into direct reclaim to work off the excess, but it never
    invokes the OOM killer.  As a result, a high boundary that is
    chosen too aggressively will not terminate the processes, but
    instead it will lead to gradual performance degradation.  The user
    can monitor this and make corrections until the minimal memory
    footprint that still gives acceptable performance is found.

    In extreme cases, with many concurrent allocations and a complete
    breakdown of reclaim progress within the group, the high boundary
    can be exceeded.  But even then it's mostly better to satisfy the
    allocation from the slack available in other groups or the rest of
    the system than killing the group.  Otherwise, memory.max is there
    to limit this type of spillover and ultimately contain buggy or
    even malicious applications.

  - The original control file names are unwieldy and inconsistent in
    many different ways.  For example, the upper boundary hit count is
    exported in the memory.failcnt file, but an OOM event count has to
    be manually counted by listening to memory.oom_control events, and
    lower boundary / soft limit events have to be counted by first
    setting a threshold for that value and then counting those events.
    Also, usage and limit files encode their units in the filename.
    That makes the filenames very long, even though this is not
    information that a user needs to be reminded of every time they
    type out those names.

    To address these naming issues, as well as to signal clearly that
    the new interface carries a new configuration model, the naming
    conventions in it necessarily differ from the old interface.

  - The original limit files indicate the state of an unset limit with
    a very high number, and a configured limit can be unset by echoing
    -1 into those files.  But that very high number is implementation
    and architecture dependent and not very descriptive.  And while -1
    can be understood as an underflow into the highest possible value,
    -2 or -10M etc. do not work, so it's not inconsistent.

    memory.low, memory.high, and memory.max will use the string
    "infinity" to indicate and set the highest possible value.

[akpm@linux-foundation.org: use seq_puts() for basic strings]
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Vladimir Davydov <vdavydov@parallels.com>
Cc: Greg Thelen <gthelen@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 Documentation/cgroups/unified-hierarchy.txt |  79 ++++++++++
 include/linux/memcontrol.h                  |  32 ++++
 mm/memcontrol.c                             | 229 ++++++++++++++++++++++++++--
 mm/vmscan.c                                 |  22 ++-
 4 files changed, 348 insertions(+), 14 deletions(-)

diff --git a/Documentation/cgroups/unified-hierarchy.txt b/Documentation/cgroups/unified-hierarchy.txt
index 4f4563277864..71daa35ec2d9 100644
--- a/Documentation/cgroups/unified-hierarchy.txt
+++ b/Documentation/cgroups/unified-hierarchy.txt
@@ -327,6 +327,85 @@ supported and the interface files "release_agent" and
 - use_hierarchy is on by default and the cgroup file for the flag is
   not created.
 
+- The original lower boundary, the soft limit, is defined as a limit
+  that is per default unset.  As a result, the set of cgroups that
+  global reclaim prefers is opt-in, rather than opt-out.  The costs
+  for optimizing these mostly negative lookups are so high that the
+  implementation, despite its enormous size, does not even provide the
+  basic desirable behavior.  First off, the soft limit has no
+  hierarchical meaning.  All configured groups are organized in a
+  global rbtree and treated like equal peers, regardless where they
+  are located in the hierarchy.  This makes subtree delegation
+  impossible.  Second, the soft limit reclaim pass is so aggressive
+  that it not just introduces high allocation latencies into the
+  system, but also impacts system performance due to overreclaim, to
+  the point where the feature becomes self-defeating.
+
+  The memory.low boundary on the other hand is a top-down allocated
+  reserve.  A cgroup enjoys reclaim protection when it and all its
+  ancestors are below their low boundaries, which makes delegation of
+  subtrees possible.  Secondly, new cgroups have no reserve per
+  default and in the common case most cgroups are eligible for the
+  preferred reclaim pass.  This allows the new low boundary to be
+  efficiently implemented with just a minor addition to the generic
+  reclaim code, without the need for out-of-band data structures and
+  reclaim passes.  Because the generic reclaim code considers all
+  cgroups except for the ones running low in the preferred first
+  reclaim pass, overreclaim of individual groups is eliminated as
+  well, resulting in much better overall workload performance.
+
+- The original high boundary, the hard limit, is defined as a strict
+  limit that can not budge, even if the OOM killer has to be called.
+  But this generally goes against the goal of making the most out of
+  the available memory.  The memory consumption of workloads varies
+  during runtime, and that requires users to overcommit.  But doing
+  that with a strict upper limit requires either a fairly accurate
+  prediction of the working set size or adding slack to the limit.
+  Since working set size estimation is hard and error prone, and
+  getting it wrong results in OOM kills, most users tend to err on the
+  side of a looser limit and end up wasting precious resources.
+
+  The memory.high boundary on the other hand can be set much more
+  conservatively.  When hit, it throttles allocations by forcing them
+  into direct reclaim to work off the excess, but it never invokes the
+  OOM killer.  As a result, a high boundary that is chosen too
+  aggressively will not terminate the processes, but instead it will
+  lead to gradual performance degradation.  The user can monitor this
+  and make corrections until the minimal memory footprint that still
+  gives acceptable performance is found.
+
+  In extreme cases, with many concurrent allocations and a complete
+  breakdown of reclaim progress within the group, the high boundary
+  can be exceeded.  But even then it's mostly better to satisfy the
+  allocation from the slack available in other groups or the rest of
+  the system than killing the group.  Otherwise, memory.max is there
+  to limit this type of spillover and ultimately contain buggy or even
+  malicious applications.
+
+- The original control file names are unwieldy and inconsistent in
+  many different ways.  For example, the upper boundary hit count is
+  exported in the memory.failcnt file, but an OOM event count has to
+  be manually counted by listening to memory.oom_control events, and
+  lower boundary / soft limit events have to be counted by first
+  setting a threshold for that value and then counting those events.
+  Also, usage and limit files encode their units in the filename.
+  That makes the filenames very long, even though this is not
+  information that a user needs to be reminded of every time they type
+  out those names.
+
+  To address these naming issues, as well as to signal clearly that
+  the new interface carries a new configuration model, the naming
+  conventions in it necessarily differ from the old interface.
+
+- The original limit files indicate the state of an unset limit with a
+  Very High Number, and a configured limit can be unset by echoing -1
+  into those files.  But that very high number is implementation and
+  architecture dependent and not very descriptive.  And while -1 can
+  be understood as an underflow into the highest possible value, -2 or
+  -10M etc. do not work, so it's not consistent.
+
+  memory.low, memory.high, and memory.max will use the string
+  "infinity" to indicate and set the highest possible value.
 
 5. Planned Changes
 
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 76f489fad640..72dff5fb0d0c 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -52,7 +52,27 @@ struct mem_cgroup_reclaim_cookie {
 	unsigned int generation;
 };
 
+enum mem_cgroup_events_index {
+	MEM_CGROUP_EVENTS_PGPGIN,	/* # of pages paged in */
+	MEM_CGROUP_EVENTS_PGPGOUT,	/* # of pages paged out */
+	MEM_CGROUP_EVENTS_PGFAULT,	/* # of page-faults */
+	MEM_CGROUP_EVENTS_PGMAJFAULT,	/* # of major page-faults */
+	MEM_CGROUP_EVENTS_NSTATS,
+	/* default hierarchy events */
+	MEMCG_LOW = MEM_CGROUP_EVENTS_NSTATS,
+	MEMCG_HIGH,
+	MEMCG_MAX,
+	MEMCG_OOM,
+	MEMCG_NR_EVENTS,
+};
+
 #ifdef CONFIG_MEMCG
+void mem_cgroup_events(struct mem_cgroup *memcg,
+		       enum mem_cgroup_events_index idx,
+		       unsigned int nr);
+
+bool mem_cgroup_low(struct mem_cgroup *root, struct mem_cgroup *memcg);
+
 int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
 			  gfp_t gfp_mask, struct mem_cgroup **memcgp);
 void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
@@ -175,6 +195,18 @@ void mem_cgroup_split_huge_fixup(struct page *head);
 #else /* CONFIG_MEMCG */
 struct mem_cgroup;
 
+static inline void mem_cgroup_events(struct mem_cgroup *memcg,
+				     enum mem_cgroup_events_index idx,
+				     unsigned int nr)
+{
+}
+
+static inline bool mem_cgroup_low(struct mem_cgroup *root,
+				  struct mem_cgroup *memcg)
+{
+	return false;
+}
+
 static inline int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
 					gfp_t gfp_mask,
 					struct mem_cgroup **memcgp)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a3592a756ad9..5730886e3b0e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -97,14 +97,6 @@ static const char * const mem_cgroup_stat_names[] = {
 	"swap",
 };
 
-enum mem_cgroup_events_index {
-	MEM_CGROUP_EVENTS_PGPGIN,	/* # of pages paged in */
-	MEM_CGROUP_EVENTS_PGPGOUT,	/* # of pages paged out */
-	MEM_CGROUP_EVENTS_PGFAULT,	/* # of page-faults */
-	MEM_CGROUP_EVENTS_PGMAJFAULT,	/* # of major page-faults */
-	MEM_CGROUP_EVENTS_NSTATS,
-};
-
 static const char * const mem_cgroup_events_names[] = {
 	"pgpgin",
 	"pgpgout",
@@ -138,7 +130,7 @@ enum mem_cgroup_events_target {
 
 struct mem_cgroup_stat_cpu {
 	long count[MEM_CGROUP_STAT_NSTATS];
-	unsigned long events[MEM_CGROUP_EVENTS_NSTATS];
+	unsigned long events[MEMCG_NR_EVENTS];
 	unsigned long nr_page_events;
 	unsigned long targets[MEM_CGROUP_NTARGETS];
 };
@@ -284,6 +276,10 @@ struct mem_cgroup {
 	struct page_counter memsw;
 	struct page_counter kmem;
 
+	/* Normal memory consumption range */
+	unsigned long low;
+	unsigned long high;
+
 	unsigned long soft_limit;
 
 	/* vmpressure notifications */
@@ -2327,6 +2323,8 @@ retry:
 	if (!(gfp_mask & __GFP_WAIT))
 		goto nomem;
 
+	mem_cgroup_events(mem_over_limit, MEMCG_MAX, 1);
+
 	nr_reclaimed = try_to_free_mem_cgroup_pages(mem_over_limit, nr_pages,
 						    gfp_mask, may_swap);
 
@@ -2368,6 +2366,8 @@ retry:
 	if (fatal_signal_pending(current))
 		goto bypass;
 
+	mem_cgroup_events(mem_over_limit, MEMCG_OOM, 1);
+
 	mem_cgroup_oom(mem_over_limit, gfp_mask, get_order(nr_pages));
 nomem:
 	if (!(gfp_mask & __GFP_NOFAIL))
@@ -2379,6 +2379,16 @@ done_restock:
 	css_get_many(&memcg->css, batch);
 	if (batch > nr_pages)
 		refill_stock(memcg, batch - nr_pages);
+	/*
+	 * If the hierarchy is above the normal consumption range,
+	 * make the charging task trim their excess contribution.
+	 */
+	do {
+		if (page_counter_read(&memcg->memory) <= memcg->high)
+			continue;
+		mem_cgroup_events(memcg, MEMCG_HIGH, 1);
+		try_to_free_mem_cgroup_pages(memcg, nr_pages, gfp_mask, true);
+	} while ((memcg = parent_mem_cgroup(memcg)));
 done:
 	return ret;
 }
@@ -4304,7 +4314,7 @@ out_kfree:
 	return ret;
 }
 
-static struct cftype mem_cgroup_files[] = {
+static struct cftype mem_cgroup_legacy_files[] = {
 	{
 		.name = "usage_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEM, RES_USAGE),
@@ -4580,6 +4590,7 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 	if (parent_css == NULL) {
 		root_mem_cgroup = memcg;
 		page_counter_init(&memcg->memory, NULL);
+		memcg->high = PAGE_COUNTER_MAX;
 		memcg->soft_limit = PAGE_COUNTER_MAX;
 		page_counter_init(&memcg->memsw, NULL);
 		page_counter_init(&memcg->kmem, NULL);
@@ -4625,6 +4636,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 
 	if (parent->use_hierarchy) {
 		page_counter_init(&memcg->memory, &parent->memory);
+		memcg->high = PAGE_COUNTER_MAX;
 		memcg->soft_limit = PAGE_COUNTER_MAX;
 		page_counter_init(&memcg->memsw, &parent->memsw);
 		page_counter_init(&memcg->kmem, &parent->kmem);
@@ -4635,6 +4647,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 		 */
 	} else {
 		page_counter_init(&memcg->memory, NULL);
+		memcg->high = PAGE_COUNTER_MAX;
 		memcg->soft_limit = PAGE_COUNTER_MAX;
 		page_counter_init(&memcg->memsw, NULL);
 		page_counter_init(&memcg->kmem, NULL);
@@ -4710,6 +4723,8 @@ static void mem_cgroup_css_reset(struct cgroup_subsys_state *css)
 	mem_cgroup_resize_limit(memcg, PAGE_COUNTER_MAX);
 	mem_cgroup_resize_memsw_limit(memcg, PAGE_COUNTER_MAX);
 	memcg_update_kmem_limit(memcg, PAGE_COUNTER_MAX);
+	memcg->low = 0;
+	memcg->high = PAGE_COUNTER_MAX;
 	memcg->soft_limit = PAGE_COUNTER_MAX;
 }
 
@@ -5296,6 +5311,147 @@ static void mem_cgroup_bind(struct cgroup_subsys_state *root_css)
 		mem_cgroup_from_css(root_css)->use_hierarchy = true;
 }
 
+static u64 memory_current_read(struct cgroup_subsys_state *css,
+			       struct cftype *cft)
+{
+	return mem_cgroup_usage(mem_cgroup_from_css(css), false);
+}
+
+static int memory_low_show(struct seq_file *m, void *v)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	unsigned long low = ACCESS_ONCE(memcg->low);
+
+	if (low == PAGE_COUNTER_MAX)
+		seq_puts(m, "infinity\n");
+	else
+		seq_printf(m, "%llu\n", (u64)low * PAGE_SIZE);
+
+	return 0;
+}
+
+static ssize_t memory_low_write(struct kernfs_open_file *of,
+				char *buf, size_t nbytes, loff_t off)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+	unsigned long low;
+	int err;
+
+	buf = strstrip(buf);
+	err = page_counter_memparse(buf, "infinity", &low);
+	if (err)
+		return err;
+
+	memcg->low = low;
+
+	return nbytes;
+}
+
+static int memory_high_show(struct seq_file *m, void *v)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	unsigned long high = ACCESS_ONCE(memcg->high);
+
+	if (high == PAGE_COUNTER_MAX)
+		seq_puts(m, "infinity\n");
+	else
+		seq_printf(m, "%llu\n", (u64)high * PAGE_SIZE);
+
+	return 0;
+}
+
+static ssize_t memory_high_write(struct kernfs_open_file *of,
+				 char *buf, size_t nbytes, loff_t off)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+	unsigned long high;
+	int err;
+
+	buf = strstrip(buf);
+	err = page_counter_memparse(buf, "infinity", &high);
+	if (err)
+		return err;
+
+	memcg->high = high;
+
+	return nbytes;
+}
+
+static int memory_max_show(struct seq_file *m, void *v)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	unsigned long max = ACCESS_ONCE(memcg->memory.limit);
+
+	if (max == PAGE_COUNTER_MAX)
+		seq_puts(m, "infinity\n");
+	else
+		seq_printf(m, "%llu\n", (u64)max * PAGE_SIZE);
+
+	return 0;
+}
+
+static ssize_t memory_max_write(struct kernfs_open_file *of,
+				char *buf, size_t nbytes, loff_t off)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+	unsigned long max;
+	int err;
+
+	buf = strstrip(buf);
+	err = page_counter_memparse(buf, "infinity", &max);
+	if (err)
+		return err;
+
+	err = mem_cgroup_resize_limit(memcg, max);
+	if (err)
+		return err;
+
+	return nbytes;
+}
+
+static int memory_events_show(struct seq_file *m, void *v)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+
+	seq_printf(m, "low %lu\n", mem_cgroup_read_events(memcg, MEMCG_LOW));
+	seq_printf(m, "high %lu\n", mem_cgroup_read_events(memcg, MEMCG_HIGH));
+	seq_printf(m, "max %lu\n", mem_cgroup_read_events(memcg, MEMCG_MAX));
+	seq_printf(m, "oom %lu\n", mem_cgroup_read_events(memcg, MEMCG_OOM));
+
+	return 0;
+}
+
+static struct cftype memory_files[] = {
+	{
+		.name = "current",
+		.read_u64 = memory_current_read,
+	},
+	{
+		.name = "low",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.seq_show = memory_low_show,
+		.write = memory_low_write,
+	},
+	{
+		.name = "high",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.seq_show = memory_high_show,
+		.write = memory_high_write,
+	},
+	{
+		.name = "max",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.seq_show = memory_max_show,
+		.write = memory_max_write,
+	},
+	{
+		.name = "events",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.seq_show = memory_events_show,
+	},
+	{ }	/* terminate */
+};
+
 struct cgroup_subsys memory_cgrp_subsys = {
 	.css_alloc = mem_cgroup_css_alloc,
 	.css_online = mem_cgroup_css_online,
@@ -5306,7 +5462,8 @@ struct cgroup_subsys memory_cgrp_subsys = {
 	.cancel_attach = mem_cgroup_cancel_attach,
 	.attach = mem_cgroup_move_task,
 	.bind = mem_cgroup_bind,
-	.legacy_cftypes = mem_cgroup_files,
+	.dfl_cftypes = memory_files,
+	.legacy_cftypes = mem_cgroup_legacy_files,
 	.early_init = 0,
 };
 
@@ -5341,6 +5498,56 @@ static void __init enable_swap_cgroup(void)
 }
 #endif
 
+/**
+ * mem_cgroup_events - count memory events against a cgroup
+ * @memcg: the memory cgroup
+ * @idx: the event index
+ * @nr: the number of events to account for
+ */
+void mem_cgroup_events(struct mem_cgroup *memcg,
+		       enum mem_cgroup_events_index idx,
+		       unsigned int nr)
+{
+	this_cpu_add(memcg->stat->events[idx], nr);
+}
+
+/**
+ * mem_cgroup_low - check if memory consumption is below the normal range
+ * @root: the highest ancestor to consider
+ * @memcg: the memory cgroup to check
+ *
+ * Returns %true if memory consumption of @memcg, and that of all
+ * configurable ancestors up to @root, is below the normal range.
+ */
+bool mem_cgroup_low(struct mem_cgroup *root, struct mem_cgroup *memcg)
+{
+	if (mem_cgroup_disabled())
+		return false;
+
+	/*
+	 * The toplevel group doesn't have a configurable range, so
+	 * it's never low when looked at directly, and it is not
+	 * considered an ancestor when assessing the hierarchy.
+	 */
+
+	if (memcg == root_mem_cgroup)
+		return false;
+
+	if (page_counter_read(&memcg->memory) > memcg->low)
+		return false;
+
+	while (memcg != root) {
+		memcg = parent_mem_cgroup(memcg);
+
+		if (memcg == root_mem_cgroup)
+			break;
+
+		if (page_counter_read(&memcg->memory) > memcg->low)
+			return false;
+	}
+	return true;
+}
+
 #ifdef CONFIG_MEMCG_SWAP
 /**
  * mem_cgroup_swapout - transfer a memsw charge to swap
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b89097185f46..f62ec654d4c5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -91,6 +91,9 @@ struct scan_control {
 	/* Can pages be swapped as part of reclaim? */
 	unsigned int may_swap:1;
 
+	/* Can cgroups be reclaimed below their normal consumption range? */
+	unsigned int may_thrash:1;
+
 	unsigned int hibernation_mode:1;
 
 	/* One of the zones is ready for compaction */
@@ -2333,6 +2336,12 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 			struct lruvec *lruvec;
 			int swappiness;
 
+			if (mem_cgroup_low(root, memcg)) {
+				if (!sc->may_thrash)
+					continue;
+				mem_cgroup_events(memcg, MEMCG_LOW, 1);
+			}
+
 			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 			swappiness = mem_cgroup_swappiness(memcg);
 			scanned = sc->nr_scanned;
@@ -2360,8 +2369,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 				mem_cgroup_iter_break(root, memcg);
 				break;
 			}
-			memcg = mem_cgroup_iter(root, memcg, &reclaim);
-		} while (memcg);
+		} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
 
 		/*
 		 * Shrink the slab caches in the same proportion that
@@ -2559,10 +2567,11 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 					  struct scan_control *sc)
 {
+	int initial_priority = sc->priority;
 	unsigned long total_scanned = 0;
 	unsigned long writeback_threshold;
 	bool zones_reclaimable;
-
+retry:
 	delayacct_freepages_start();
 
 	if (global_reclaim(sc))
@@ -2612,6 +2621,13 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	if (sc->compaction_ready)
 		return 1;
 
+	/* Untapped cgroup reserves?  Don't OOM, retry. */
+	if (!sc->may_thrash) {
+		sc->priority = initial_priority;
+		sc->may_thrash = 1;
+		goto retry;
+	}
+
 	/* Any of the zones still reclaimable?  Don't OOM. */
 	if (zones_reclaimable)
 		return 1;
-- 
2.2.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
