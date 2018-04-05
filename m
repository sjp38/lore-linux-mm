Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A6E586B000C
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 15:01:38 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v77so13625043wrc.18
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 12:01:38 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id w33si7151042edm.154.2018.04.05.12.01.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 12:01:36 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH v3 2/4] mm: memory.low hierarchical behavior
Date: Thu, 5 Apr 2018 19:59:19 +0100
Message-ID: <20180405185921.4942-2-guro@fb.com>
In-Reply-To: <20180405185921.4942-1-guro@fb.com>
References: <20180405185921.4942-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

This patch aims to address an issue in current memory.low semantics,
which makes it hard to use it in a hierarchy, where some leaf memory
cgroups are more valuable than others.

For example, there are memcgs A, A/B, A/C, A/D and A/E:

  A      A/memory.low = 2G, A/memory.current = 6G
 //\\
BC  DE   B/memory.low = 3G  B/memory.current = 2G
         C/memory.low = 1G  C/memory.current = 2G
         D/memory.low = 0   D/memory.current = 2G
	 E/memory.low = 10G E/memory.current = 0

If we apply memory pressure, B, C and D are reclaimed at
the same pace while A's usage exceeds 2G.
This is obviously wrong, as B's usage is fully below B's memory.low,
and C has 1G of protection as well.
Also, A is pushed to the size, which is less than A's 2G memory.low,
which is also wrong.

A simple bash script (provided below) can be used to reproduce
the problem. Current results are:
  A:    1430097920
  A/B:  711929856
  A/C:  717426688
  A/D:  741376
  A/E:  0

To address the issue a concept of effective memory.low is introduced.
Effective memory.low is always equal or less than original memory.low.
In a case, when there is no memory.low overcommittment (and also for
top-level cgroups), these two values are equal.
Otherwise it's a part of parent's effective memory.low, calculated as
a cgroup's memory.low usage divided by sum of sibling's memory.low
usages (under memory.low usage I mean the size of actually protected
memory: memory.current if memory.current < memory.low, 0 otherwise).
It's necessary to track the actual usage, because otherwise an empty
cgroup with memory.low set (A/E in my example) will affect actual
memory distribution, which makes no sense. To avoid traversing
the cgroup tree twice, page_counters code is reused.

Calculating effective memory.low can be done in the reclaim path,
as we conveniently traversing the cgroup tree from top to bottom and
check memory.low on each level. So, it's a perfect place to calculate
effective memory low and save it to use it for children cgroups.

This also eliminates a need to traverse the cgroup tree from bottom
to top each time to check if parent's guarantee is not exceeded.

Setting/resetting effective memory.low is intentionally racy, but
it's fine and shouldn't lead to any significant differences in
actual memory distribution.

With this patch applied results are matching the expectations:
  A:    2147930112
  A/B:  1428721664
  A/C:  718393344
  A/D:  815104
  A/E:  0

Test script:
  #!/bin/bash

  CGPATH="/sys/fs/cgroup"

  truncate /file1 --size 2G
  truncate /file2 --size 2G
  truncate /file3 --size 2G
  truncate /file4 --size 50G

  mkdir "${CGPATH}/A"
  echo "+memory" > "${CGPATH}/A/cgroup.subtree_control"
  mkdir "${CGPATH}/A/B" "${CGPATH}/A/C" "${CGPATH}/A/D" "${CGPATH}/A/E"

  echo 2G > "${CGPATH}/A/memory.low"
  echo 3G > "${CGPATH}/A/B/memory.low"
  echo 1G > "${CGPATH}/A/C/memory.low"
  echo 0 > "${CGPATH}/A/D/memory.low"
  echo 10G > "${CGPATH}/A/E/memory.low"

  echo $$ > "${CGPATH}/A/B/cgroup.procs" && vmtouch -qt /file1
  echo $$ > "${CGPATH}/A/C/cgroup.procs" && vmtouch -qt /file2
  echo $$ > "${CGPATH}/A/D/cgroup.procs" && vmtouch -qt /file3
  echo $$ > "${CGPATH}/cgroup.procs" && vmtouch -qt /file4

  echo "A:   " `cat "${CGPATH}/A/memory.current"`
  echo "A/B: " `cat "${CGPATH}/A/B/memory.current"`
  echo "A/C: " `cat "${CGPATH}/A/C/memory.current"`
  echo "A/D: " `cat "${CGPATH}/A/D/memory.current"`
  echo "A/E: " `cat "${CGPATH}/A/E/memory.current"`

  rmdir "${CGPATH}/A/B" "${CGPATH}/A/C" "${CGPATH}/A/D" "${CGPATH}/A/E"
  rmdir "${CGPATH}/A"
  rm /file1 /file2 /file3 /file4

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
 include/linux/memcontrol.h   |   3 +-
 include/linux/page_counter.h |   7 +++
 mm/memcontrol.c              | 112 ++++++++++++++++++++++++++++++++-----------
 mm/page_counter.c            |  43 +++++++++++++++++
 4 files changed, 134 insertions(+), 31 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index caa31cc09e7e..0dfda3ac6e70 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -178,8 +178,7 @@ struct mem_cgroup {
 	struct page_counter kmem;
 	struct page_counter tcpmem;
 
-	/* Normal memory consumption range */
-	unsigned long low;
+	/* Upper bound of normal memory consumption range */
 	unsigned long high;
 
 	/* Range enforcement for interrupt charges */
diff --git a/include/linux/page_counter.h b/include/linux/page_counter.h
index 94029dad9317..7902a727d3b6 100644
--- a/include/linux/page_counter.h
+++ b/include/linux/page_counter.h
@@ -9,8 +9,14 @@
 struct page_counter {
 	atomic_long_t usage;
 	unsigned long max;
+	unsigned long low;
 	struct page_counter *parent;
 
+	/* effective memory.low and memory.low usage tracking */
+	unsigned long elow;
+	atomic_long_t low_usage;
+	atomic_long_t children_low_usage;
+
 	/* legacy */
 	unsigned long watermark;
 	unsigned long failcnt;
@@ -42,6 +48,7 @@ bool page_counter_try_charge(struct page_counter *counter,
 			     struct page_counter **fail);
 void page_counter_uncharge(struct page_counter *counter, unsigned long nr_pages);
 int page_counter_set_max(struct page_counter *counter, unsigned long nr_pages);
+void page_counter_set_low(struct page_counter *counter, unsigned long nr_pages);
 int page_counter_memparse(const char *buf, const char *max,
 			  unsigned long *nr_pages);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 50d1ad6a8fdb..78cf21f2a943 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4499,7 +4499,7 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	}
 	spin_unlock(&memcg->event_list_lock);
 
-	memcg->low = 0;
+	page_counter_set_low(&memcg->memory, 0);
 
 	memcg_offline_kmem(memcg);
 	wb_memcg_offline(memcg);
@@ -4548,12 +4548,12 @@ static void mem_cgroup_css_reset(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
-	memcg->low = 0;
 	page_counter_set_max(&memcg->memory, PAGE_COUNTER_MAX);
 	page_counter_set_max(&memcg->swap, PAGE_COUNTER_MAX);
 	page_counter_set_max(&memcg->memsw, PAGE_COUNTER_MAX);
 	page_counter_set_max(&memcg->kmem, PAGE_COUNTER_MAX);
 	page_counter_set_max(&memcg->tcpmem, PAGE_COUNTER_MAX);
+	page_counter_set_low(&memcg->memory, 0);
 	memcg->high = PAGE_COUNTER_MAX;
 	memcg->soft_limit = PAGE_COUNTER_MAX;
 	memcg_wb_domain_size_changed(memcg);
@@ -5293,7 +5293,7 @@ static u64 memory_current_read(struct cgroup_subsys_state *css,
 static int memory_low_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
-	unsigned long low = READ_ONCE(memcg->low);
+	unsigned long low = READ_ONCE(memcg->memory.low);
 
 	if (low == PAGE_COUNTER_MAX)
 		seq_puts(m, "max\n");
@@ -5315,7 +5315,7 @@ static ssize_t memory_low_write(struct kernfs_open_file *of,
 	if (err)
 		return err;
 
-	memcg->low = low;
+	page_counter_set_low(&memcg->memory, low);
 
 	return nbytes;
 }
@@ -5612,36 +5612,72 @@ struct cgroup_subsys memory_cgrp_subsys = {
  * @root: the top ancestor of the sub-tree being checked
  * @memcg: the memory cgroup to check
  *
- * Returns %true if memory consumption of @memcg, and that of all
- * ancestors up to (but not including) @root, is below the normal range.
+ * WARNING: This function is not stateless! It can only be used as part
+ *          of a top-down tree iteration, not for isolated queries.
  *
- * @root is exclusive; it is never low when looked at directly and isn't
- * checked when traversing the hierarchy.
+ * Returns %true if memory consumption of @memcg is below the normal range.
  *
- * Excluding @root enables using memory.low to prioritize memory usage
- * between cgroups within a subtree of the hierarchy that is limited by
- * memory.high or memory.max.
+ * @root is exclusive; it is never low when looked at directly
  *
- * For example, given cgroup A with children B and C:
+ * To provide a proper hierarchical behavior, effective memory.low value
+ * is used.
  *
- *    A
- *   / \
- *  B   C
+ * Effective memory.low is always equal or less than the original memory.low.
+ * If there is no memory.low overcommittment (which is always true for
+ * top-level memory cgroups), these two values are equal.
+ * Otherwise, it's a part of parent's effective memory.low,
+ * calculated as a cgroup's memory.low usage divided by sum of sibling's
+ * memory.low usages, where memory.low usage is the size of actually
+ * protected memory.
  *
- * and
+ *                                             low_usage
+ * elow = min( memory.low, parent->elow * ------------------ ),
+ *                                        siblings_low_usage
  *
- *  1. A/memory.current > A/memory.high
- *  2. A/B/memory.current < A/B/memory.low
- *  3. A/C/memory.current >= A/C/memory.low
+ *             | memory.current, if memory.current < memory.low
+ * low_usage = |
+	       | 0, otherwise.
  *
- * As 'A' is high, i.e. triggers reclaim from 'A', and 'B' is low, we
- * should reclaim from 'C' until 'A' is no longer high or until we can
- * no longer reclaim from 'C'.  If 'A', i.e. @root, isn't excluded by
- * mem_cgroup_low when reclaming from 'A', then 'B' won't be considered
- * low and we will reclaim indiscriminately from both 'B' and 'C'.
+ *
+ * Such definition of the effective memory.low provides the expected
+ * hierarchical behavior: parent's memory.low value is limiting
+ * children, unprotected memory is reclaimed first and cgroups,
+ * which are not using their guarantee do not affect actual memory
+ * distribution.
+ *
+ * For example, if there are memcgs A, A/B, A/C, A/D and A/E:
+ *
+ *     A      A/memory.low = 2G, A/memory.current = 6G
+ *    //\\
+ *   BC  DE   B/memory.low = 3G  B/memory.current = 2G
+ *            C/memory.low = 1G  C/memory.current = 2G
+ *            D/memory.low = 0   D/memory.current = 2G
+ *            E/memory.low = 10G E/memory.current = 0
+ *
+ * and the memory pressure is applied, the following memory distribution
+ * is expected (approximately):
+ *
+ *     A/memory.current = 2G
+ *
+ *     B/memory.current = 1.3G
+ *     C/memory.current = 0.6G
+ *     D/memory.current = 0
+ *     E/memory.current = 0
+ *
+ * These calculations require constant tracking of the actual low usages
+ * (see propagate_low_usage()), as well as recursive calculation of
+ * effective memory.low values. But as we do call mem_cgroup_low()
+ * path for each memory cgroup top-down from the reclaim,
+ * it's possible to optimize this part, and save calculated elow
+ * for next usage. This part is intentionally racy, but it's ok,
+ * as memory.low is a best-effort mechanism.
  */
 bool mem_cgroup_low(struct mem_cgroup *root, struct mem_cgroup *memcg)
 {
+	unsigned long usage, low_usage, siblings_low_usage;
+	unsigned long elow, parent_elow;
+	struct mem_cgroup *parent;
+
 	if (mem_cgroup_disabled())
 		return false;
 
@@ -5650,12 +5686,30 @@ bool mem_cgroup_low(struct mem_cgroup *root, struct mem_cgroup *memcg)
 	if (memcg == root)
 		return false;
 
-	for (; memcg != root; memcg = parent_mem_cgroup(memcg)) {
-		if (page_counter_read(&memcg->memory) >= memcg->low)
-			return false;
-	}
+	elow = memcg->memory.low;
+	usage = page_counter_read(&memcg->memory);
+	parent = parent_mem_cgroup(memcg);
 
-	return true;
+	if (parent == root)
+		goto exit;
+
+	parent_elow = READ_ONCE(parent->memory.elow);
+	elow = min(elow, parent_elow);
+
+	if (!elow || !parent_elow)
+		goto exit;
+
+	low_usage = min(usage, memcg->memory.low);
+	siblings_low_usage = atomic_long_read(
+		&parent->memory.children_low_usage);
+
+	if (!low_usage || !siblings_low_usage)
+		goto exit;
+
+	elow = min(elow, parent_elow * low_usage / siblings_low_usage);
+exit:
+	memcg->memory.elow = elow;
+	return usage < elow;
 }
 
 /**
diff --git a/mm/page_counter.c b/mm/page_counter.c
index 41937c9a9d11..a5ff4cbc355a 100644
--- a/mm/page_counter.c
+++ b/mm/page_counter.c
@@ -13,6 +13,28 @@
 #include <linux/bug.h>
 #include <asm/page.h>
 
+static void propagate_low_usage(struct page_counter *c, unsigned long usage)
+{
+	unsigned long low_usage, old;
+	long delta;
+
+	if (!c->parent)
+		return;
+
+	if (!c->low && !atomic_long_read(&c->low_usage))
+		return;
+
+	if (usage <= c->low)
+		low_usage = usage;
+	else
+		low_usage = 0;
+
+	old = atomic_long_xchg(&c->low_usage, low_usage);
+	delta = low_usage - old;
+	if (delta)
+		atomic_long_add(delta, &c->parent->children_low_usage);
+}
+
 /**
  * page_counter_cancel - take pages out of the local counter
  * @counter: counter
@@ -23,6 +45,7 @@ void page_counter_cancel(struct page_counter *counter, unsigned long nr_pages)
 	long new;
 
 	new = atomic_long_sub_return(nr_pages, &counter->usage);
+	propagate_low_usage(counter, new);
 	/* More uncharges than charges? */
 	WARN_ON_ONCE(new < 0);
 }
@@ -42,6 +65,7 @@ void page_counter_charge(struct page_counter *counter, unsigned long nr_pages)
 		long new;
 
 		new = atomic_long_add_return(nr_pages, &c->usage);
+		propagate_low_usage(counter, new);
 		/*
 		 * This is indeed racy, but we can live with some
 		 * inaccuracy in the watermark.
@@ -85,6 +109,7 @@ bool page_counter_try_charge(struct page_counter *counter,
 		new = atomic_long_add_return(nr_pages, &c->usage);
 		if (new > c->max) {
 			atomic_long_sub(nr_pages, &c->usage);
+			propagate_low_usage(counter, new);
 			/*
 			 * This is racy, but we can live with some
 			 * inaccuracy in the failcnt.
@@ -93,6 +118,7 @@ bool page_counter_try_charge(struct page_counter *counter,
 			*fail = c;
 			goto failed;
 		}
+		propagate_low_usage(counter, new);
 		/*
 		 * Just like with failcnt, we can live with some
 		 * inaccuracy in the watermark.
@@ -164,6 +190,23 @@ int page_counter_set_max(struct page_counter *counter, unsigned long nr_pages)
 	}
 }
 
+/**
+ * page_counter_set_low - set the amount of protected memory
+ * @counter: counter
+ * @nr_pages: value to set
+ *
+ * The caller must serialize invocations on the same counter.
+ */
+void page_counter_set_low(struct page_counter *counter, unsigned long nr_pages)
+{
+	struct page_counter *c;
+
+	counter->low = nr_pages;
+
+	for (c = counter; c; c = c->parent)
+		propagate_low_usage(c, atomic_long_read(&c->usage));
+}
+
 /**
  * page_counter_memparse - memparse() for page counter limits
  * @buf: string to parse
-- 
2.14.3
