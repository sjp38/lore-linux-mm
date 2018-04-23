Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id A175A6B0003
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 08:37:01 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id a124so10824129qkb.19
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 05:37:01 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id y188si748126qkd.54.2018.04.23.05.36.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 05:36:59 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH v2] mm: introduce memory.min
Date: Mon, 23 Apr 2018 13:36:10 +0100
Message-ID: <20180423123610.27988-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kernel-team@fb.com, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>

Memory controller implements the memory.low best-effort memory
protection mechanism, which works perfectly in many cases and
allows protecting working sets of important workloads from
sudden reclaim.

But its semantics has a significant limitation: it works
only as long as there is a supply of reclaimable memory.
This makes it pretty useless against any sort of slow memory
leaks or memory usage increases. This is especially true
for swapless systems. If swap is enabled, memory soft protection
effectively postpones problems, allowing a leaking application
to fill all swap area, which makes no sense.
The only effective way to guarantee the memory protection
in this case is to invoke the OOM killer.

It's possible to handle this case in userspace by reacting
on MEMCG_LOW events; but there is still a place for a fail-safe
in-kernel mechanism to provide stronger guarantees.

This patch introduces the memory.min interface for cgroup v2
memory controller. It works very similarly to memory.low
(sharing the same hierarchical behavior), except that it's
not disabled if there is no more reclaimable memory in the system.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Tejun Heo <tj@kernel.org>
---
 Documentation/cgroup-v2.txt  |  24 ++++++++-
 include/linux/memcontrol.h   |  15 ++++--
 include/linux/page_counter.h |  11 +++-
 mm/memcontrol.c              | 118 ++++++++++++++++++++++++++++++++++---------
 mm/page_counter.c            |  63 ++++++++++++++++-------
 mm/vmscan.c                  |  18 ++++++-
 6 files changed, 199 insertions(+), 50 deletions(-)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
index 657fe1769c75..a413118b9c29 100644
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -1002,6 +1002,26 @@ PAGE_SIZE multiple when read back.
 	The total amount of memory currently being used by the cgroup
 	and its descendants.
 
+  memory.min
+	A read-write single value file which exists on non-root
+	cgroups.  The default is "0".
+
+	Hard memory protection.  If the memory usage of a cgroup
+	is within its effective min boundary, the cgroup's memory
+	won't be reclaimed under any conditions. If there is no
+	unprotected reclaimable memory available, OOM killer
+	is invoked.
+
+	Effective low boundary is limited by memory.min values of
+	all ancestor cgroups. If there is memory.min overcommitment
+	(child cgroup or cgroups are requiring more protected memory
+	than parent will allow), then each child cgroup will get
+	the part of parent's protection proportional to its
+	actual memory usage below memory.min.
+
+	Putting more memory than generally available under this
+	protection is discouraged and may lead to constant OOMs.
+
   memory.low
 	A read-write single value file which exists on non-root
 	cgroups.  The default is "0".
@@ -1013,9 +1033,9 @@ PAGE_SIZE multiple when read back.
 
 	Effective low boundary is limited by memory.low values of
 	all ancestor cgroups. If there is memory.low overcommitment
-	(child cgroup or cgroups are requiring more protected memory,
+	(child cgroup or cgroups are requiring more protected memory
 	than parent will allow), then each child cgroup will get
-	the part of parent's protection proportional to the its
+	the part of parent's protection proportional to its
 	actual memory usage below memory.low.
 
 	Putting more memory than generally available under this
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index ab60ff55bdb3..6aa47086105a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -59,6 +59,12 @@ enum memcg_memory_event {
 	MEMCG_NR_MEMORY_EVENTS,
 };
 
+enum mem_cgroup_protection {
+	MEMCG_PROT_NONE,
+	MEMCG_PROT_LOW,
+	MEMCG_PROT_HIGH,
+};
+
 struct mem_cgroup_reclaim_cookie {
 	pg_data_t *pgdat;
 	int priority;
@@ -297,7 +303,8 @@ static inline bool mem_cgroup_disabled(void)
 	return !cgroup_subsys_enabled(memory_cgrp_subsys);
 }
 
-bool mem_cgroup_low(struct mem_cgroup *root, struct mem_cgroup *memcg);
+enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
+						struct mem_cgroup *memcg);
 
 int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
 			  gfp_t gfp_mask, struct mem_cgroup **memcgp,
@@ -756,10 +763,10 @@ static inline void memcg_memory_event(struct mem_cgroup *memcg,
 {
 }
 
-static inline bool mem_cgroup_low(struct mem_cgroup *root,
-				  struct mem_cgroup *memcg)
+static inline enum mem_cgroup_protection mem_cgroup_protected(
+	struct mem_cgroup *root, struct mem_cgroup *memcg)
 {
-	return false;
+	return MEMCG_PROT_NONE;
 }
 
 static inline int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
diff --git a/include/linux/page_counter.h b/include/linux/page_counter.h
index 7902a727d3b6..bab7e57f659b 100644
--- a/include/linux/page_counter.h
+++ b/include/linux/page_counter.h
@@ -8,10 +8,16 @@
 
 struct page_counter {
 	atomic_long_t usage;
-	unsigned long max;
+	unsigned long min;
 	unsigned long low;
+	unsigned long max;
 	struct page_counter *parent;
 
+	/* effective memory.min and memory.min usage tracking */
+	unsigned long emin;
+	atomic_long_t min_usage;
+	atomic_long_t children_min_usage;
+
 	/* effective memory.low and memory.low usage tracking */
 	unsigned long elow;
 	atomic_long_t low_usage;
@@ -47,8 +53,9 @@ bool page_counter_try_charge(struct page_counter *counter,
 			     unsigned long nr_pages,
 			     struct page_counter **fail);
 void page_counter_uncharge(struct page_counter *counter, unsigned long nr_pages);
-int page_counter_set_max(struct page_counter *counter, unsigned long nr_pages);
+void page_counter_set_min(struct page_counter *counter, unsigned long nr_pages);
 void page_counter_set_low(struct page_counter *counter, unsigned long nr_pages);
+int page_counter_set_max(struct page_counter *counter, unsigned long nr_pages);
 int page_counter_memparse(const char *buf, const char *max,
 			  unsigned long *nr_pages);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 25b148c2d222..34b8f597f48c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4508,6 +4508,7 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	}
 	spin_unlock(&memcg->event_list_lock);
 
+	page_counter_set_min(&memcg->memory, 0);
 	page_counter_set_low(&memcg->memory, 0);
 
 	memcg_offline_kmem(memcg);
@@ -4562,6 +4563,7 @@ static void mem_cgroup_css_reset(struct cgroup_subsys_state *css)
 	page_counter_set_max(&memcg->memsw, PAGE_COUNTER_MAX);
 	page_counter_set_max(&memcg->kmem, PAGE_COUNTER_MAX);
 	page_counter_set_max(&memcg->tcpmem, PAGE_COUNTER_MAX);
+	page_counter_set_min(&memcg->memory, 0);
 	page_counter_set_low(&memcg->memory, 0);
 	memcg->high = PAGE_COUNTER_MAX;
 	memcg->soft_limit = PAGE_COUNTER_MAX;
@@ -5299,6 +5301,36 @@ static u64 memory_current_read(struct cgroup_subsys_state *css,
 	return (u64)page_counter_read(&memcg->memory) * PAGE_SIZE;
 }
 
+static int memory_min_show(struct seq_file *m, void *v)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	unsigned long min = READ_ONCE(memcg->memory.min);
+
+	if (min == PAGE_COUNTER_MAX)
+		seq_puts(m, "max\n");
+	else
+		seq_printf(m, "%llu\n", (u64)min * PAGE_SIZE);
+
+	return 0;
+}
+
+static ssize_t memory_min_write(struct kernfs_open_file *of,
+				char *buf, size_t nbytes, loff_t off)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+	unsigned long min;
+	int err;
+
+	buf = strstrip(buf);
+	err = page_counter_memparse(buf, "max", &min);
+	if (err)
+		return err;
+
+	page_counter_set_min(&memcg->memory, min);
+
+	return nbytes;
+}
+
 static int memory_low_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
@@ -5566,6 +5598,12 @@ static struct cftype memory_files[] = {
 		.flags = CFTYPE_NOT_ON_ROOT,
 		.read_u64 = memory_current_read,
 	},
+	{
+		.name = "min",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.seq_show = memory_min_show,
+		.write = memory_min_write,
+	},
 	{
 		.name = "low",
 		.flags = CFTYPE_NOT_ON_ROOT,
@@ -5621,19 +5659,24 @@ struct cgroup_subsys memory_cgrp_subsys = {
 };
 
 /**
- * mem_cgroup_low - check if memory consumption is in the normal range
+ * mem_cgroup_protected - check if memory consumption is in the normal range
  * @root: the top ancestor of the sub-tree being checked
  * @memcg: the memory cgroup to check
  *
  * WARNING: This function is not stateless! It can only be used as part
  *          of a top-down tree iteration, not for isolated queries.
  *
- * Returns %true if memory consumption of @memcg is in the normal range.
+ * Returns one of the following:
+ *   MEMCG_PROT_NONE: cgroup memory is not protected
+ *   MEMCG_PROT_LOW: cgroup memory is protected as long there is
+ *     an unprotected supply of reclaimable memory from other cgroups.
+ *   MEMCG_PROT_HIGH: cgroup memory is protected
  *
- * @root is exclusive; it is never low when looked at directly
+ * @root is exclusive; it is never protected when looked at directly
  *
- * To provide a proper hierarchical behavior, effective memory.low value
- * is used.
+ * To provide a proper hierarchical behavior, effective memory.min/low values
+ * are used. Below is the description of how effective memory.low is calculated.
+ * Effective memory.min values is calculated in the same way.
  *
  * Effective memory.low is always equal or less than the original memory.low.
  * If there is no memory.low overcommittment (which is always true for
@@ -5678,51 +5721,78 @@ struct cgroup_subsys memory_cgrp_subsys = {
  *     E/memory.current = 0
  *
  * These calculations require constant tracking of the actual low usages
- * (see propagate_low_usage()), as well as recursive calculation of
- * effective memory.low values. But as we do call mem_cgroup_low()
+ * (see propagate_protected_usage()), as well as recursive calculation of
+ * effective memory.low values. But as we do call mem_cgroup_protected()
  * path for each memory cgroup top-down from the reclaim,
  * it's possible to optimize this part, and save calculated elow
  * for next usage. This part is intentionally racy, but it's ok,
  * as memory.low is a best-effort mechanism.
  */
-bool mem_cgroup_low(struct mem_cgroup *root, struct mem_cgroup *memcg)
+enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
+						struct mem_cgroup *memcg)
 {
-	unsigned long usage, low_usage, siblings_low_usage;
-	unsigned long elow, parent_elow;
 	struct mem_cgroup *parent;
+	unsigned long emin, parent_emin;
+	unsigned long elow, parent_elow;
+	unsigned long usage;
 
 	if (mem_cgroup_disabled())
-		return false;
+		return MEMCG_PROT_NONE;
 
 	if (!root)
 		root = root_mem_cgroup;
 	if (memcg == root)
-		return false;
+		return MEMCG_PROT_NONE;
 
-	elow = memcg->memory.low;
 	usage = page_counter_read(&memcg->memory);
-	parent = parent_mem_cgroup(memcg);
+	if (!usage)
+		return MEMCG_PROT_NONE;
+
+	emin = memcg->memory.min;
+	elow = memcg->memory.low;
 
+	parent = parent_mem_cgroup(memcg);
 	if (parent == root)
 		goto exit;
 
+	parent_emin = READ_ONCE(parent->memory.emin);
+	emin = min(emin, parent_emin);
+	if (emin && parent_emin) {
+		unsigned long min_usage, siblings_min_usage;
+
+		min_usage = min(usage, memcg->memory.min);
+		siblings_min_usage = atomic_long_read(
+			&parent->memory.children_min_usage);
+
+		if (min_usage && siblings_min_usage)
+			emin = min(emin, parent_emin * min_usage /
+				   siblings_min_usage);
+	}
+
 	parent_elow = READ_ONCE(parent->memory.elow);
 	elow = min(elow, parent_elow);
+	if (elow && parent_elow) {
+		unsigned long low_usage, siblings_low_usage;
 
-	if (!elow || !parent_elow)
-		goto exit;
+		low_usage = min(usage, memcg->memory.low);
+		siblings_low_usage = atomic_long_read(
+			&parent->memory.children_low_usage);
 
-	low_usage = min(usage, memcg->memory.low);
-	siblings_low_usage = atomic_long_read(
-		&parent->memory.children_low_usage);
-
-	if (!low_usage || !siblings_low_usage)
-		goto exit;
+		if (low_usage && siblings_low_usage)
+			elow = min(elow, parent_elow * low_usage /
+				   siblings_low_usage);
+	}
 
-	elow = min(elow, parent_elow * low_usage / siblings_low_usage);
 exit:
+	memcg->memory.emin = emin;
 	memcg->memory.elow = elow;
-	return usage && usage <= elow;
+
+	if (usage <= emin)
+		return MEMCG_PROT_HIGH;
+	else if (usage <= elow)
+		return MEMCG_PROT_LOW;
+	else
+		return MEMCG_PROT_NONE;
 }
 
 /**
diff --git a/mm/page_counter.c b/mm/page_counter.c
index a5ff4cbc355a..de31470655f6 100644
--- a/mm/page_counter.c
+++ b/mm/page_counter.c
@@ -13,26 +13,38 @@
 #include <linux/bug.h>
 #include <asm/page.h>
 
-static void propagate_low_usage(struct page_counter *c, unsigned long usage)
+static void propagate_protected_usage(struct page_counter *c,
+				      unsigned long usage)
 {
-	unsigned long low_usage, old;
+	unsigned long protected, old_protected;
 	long delta;
 
 	if (!c->parent)
 		return;
 
-	if (!c->low && !atomic_long_read(&c->low_usage))
-		return;
+	if (c->min || atomic_long_read(&c->min_usage)) {
+		if (usage <= c->min)
+			protected = usage;
+		else
+			protected = 0;
+
+		old_protected = atomic_long_xchg(&c->min_usage, protected);
+		delta = protected - old_protected;
+		if (delta)
+			atomic_long_add(delta, &c->parent->children_min_usage);
+	}
 
-	if (usage <= c->low)
-		low_usage = usage;
-	else
-		low_usage = 0;
+	if (c->low || atomic_long_read(&c->low_usage)) {
+		if (usage <= c->low)
+			protected = usage;
+		else
+			protected = 0;
 
-	old = atomic_long_xchg(&c->low_usage, low_usage);
-	delta = low_usage - old;
-	if (delta)
-		atomic_long_add(delta, &c->parent->children_low_usage);
+		old_protected = atomic_long_xchg(&c->low_usage, protected);
+		delta = protected - old_protected;
+		if (delta)
+			atomic_long_add(delta, &c->parent->children_low_usage);
+	}
 }
 
 /**
@@ -45,7 +57,7 @@ void page_counter_cancel(struct page_counter *counter, unsigned long nr_pages)
 	long new;
 
 	new = atomic_long_sub_return(nr_pages, &counter->usage);
-	propagate_low_usage(counter, new);
+	propagate_protected_usage(counter, new);
 	/* More uncharges than charges? */
 	WARN_ON_ONCE(new < 0);
 }
@@ -65,7 +77,7 @@ void page_counter_charge(struct page_counter *counter, unsigned long nr_pages)
 		long new;
 
 		new = atomic_long_add_return(nr_pages, &c->usage);
-		propagate_low_usage(counter, new);
+		propagate_protected_usage(counter, new);
 		/*
 		 * This is indeed racy, but we can live with some
 		 * inaccuracy in the watermark.
@@ -109,7 +121,7 @@ bool page_counter_try_charge(struct page_counter *counter,
 		new = atomic_long_add_return(nr_pages, &c->usage);
 		if (new > c->max) {
 			atomic_long_sub(nr_pages, &c->usage);
-			propagate_low_usage(counter, new);
+			propagate_protected_usage(counter, new);
 			/*
 			 * This is racy, but we can live with some
 			 * inaccuracy in the failcnt.
@@ -118,7 +130,7 @@ bool page_counter_try_charge(struct page_counter *counter,
 			*fail = c;
 			goto failed;
 		}
-		propagate_low_usage(counter, new);
+		propagate_protected_usage(counter, new);
 		/*
 		 * Just like with failcnt, we can live with some
 		 * inaccuracy in the watermark.
@@ -190,6 +202,23 @@ int page_counter_set_max(struct page_counter *counter, unsigned long nr_pages)
 	}
 }
 
+/**
+ * page_counter_set_min - set the amount of protected memory
+ * @counter: counter
+ * @nr_pages: value to set
+ *
+ * The caller must serialize invocations on the same counter.
+ */
+void page_counter_set_min(struct page_counter *counter, unsigned long nr_pages)
+{
+	struct page_counter *c;
+
+	counter->min = nr_pages;
+
+	for (c = counter; c; c = c->parent)
+		propagate_protected_usage(c, atomic_long_read(&c->usage));
+}
+
 /**
  * page_counter_set_low - set the amount of protected memory
  * @counter: counter
@@ -204,7 +233,7 @@ void page_counter_set_low(struct page_counter *counter, unsigned long nr_pages)
 	counter->low = nr_pages;
 
 	for (c = counter; c; c = c->parent)
-		propagate_low_usage(c, atomic_long_read(&c->usage));
+		propagate_protected_usage(c, atomic_long_read(&c->usage));
 }
 
 /**
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9b697323a88c..0a42ab1ce42b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2544,12 +2544,28 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			unsigned long reclaimed;
 			unsigned long scanned;
 
-			if (mem_cgroup_low(root, memcg)) {
+			switch (mem_cgroup_protected(root, memcg)) {
+			case MEMCG_PROT_HIGH:
+				/*
+				 * Hard protection.
+				 * If there is no reclaimable memory, OOM.
+				 */
+				continue;
+			case MEMCG_PROT_LOW:
+				/*
+				 * Soft protection.
+				 * Respect the protection only as long as
+				 * there is an unprotected supply
+				 * of reclaimable memory from other cgroups.
+				 */
 				if (!sc->memcg_low_reclaim) {
 					sc->memcg_low_skipped = 1;
 					continue;
 				}
 				memcg_memory_event(memcg, MEMCG_LOW);
+				break;
+			case MEMCG_PROT_NONE:
+				break;
 			}
 
 			reclaimed = sc->nr_reclaimed;
-- 
2.14.3
