Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id F03386B0009
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 12:39:11 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id c1so6180511wri.22
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 09:39:11 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id d34si7789968edd.435.2018.03.23.09.39.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 09:39:10 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH v2] mm: memory.low hierarchical behavior
Date: Fri, 23 Mar 2018 16:37:50 +0000
Message-ID: <20180323163750.8050-1-guro@fb.com>
In-Reply-To: <20180321182308.GA28232@cmpxchg.org>
References: <20180321182308.GA28232@cmpxchg.org>
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
memory distribution, which makes no sense.

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
  A:    2143293440
  A/B:  1424736256
  A/C:  717766656
  A/D:  790528
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
 include/linux/memcontrol.h |   8 +++
 mm/memcontrol.c            | 140 +++++++++++++++++++++++++++++++++++++--------
 2 files changed, 123 insertions(+), 25 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 44422e1d3def..59873cb99093 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -182,6 +182,14 @@ struct mem_cgroup {
 	unsigned long low;
 	unsigned long high;
 
+	/*
+	 * Effective memory.low and memory.low usage tracking.
+	 * Please, refer to mem_cgroup_low() for more details.
+	 */
+	unsigned long elow;
+	atomic_long_t low_usage;
+	atomic_long_t children_low_usage;
+
 	/* Range enforcement for interrupt charges */
 	struct work_struct high_work;
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 636f3dc7b53a..24afbf12b9a6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1663,6 +1663,36 @@ void unlock_page_memcg(struct page *page)
 }
 EXPORT_SYMBOL(unlock_page_memcg);
 
+static void memcg_update_low(struct mem_cgroup *memcg)
+{
+	unsigned long usage, low_usage, prev_low_usage;
+	struct mem_cgroup *parent;
+	long delta;
+
+	do {
+		parent = parent_mem_cgroup(memcg);
+		if (!parent || mem_cgroup_is_root(parent))
+			break;
+
+		if (!memcg->low && !atomic_long_read(&memcg->low_usage))
+			break;
+
+		usage = page_counter_read(&memcg->memory);
+		if (usage < memcg->low)
+			low_usage = usage;
+		else
+			low_usage = 0;
+
+		prev_low_usage = atomic_long_xchg(&memcg->low_usage, low_usage);
+		delta = low_usage - prev_low_usage;
+		if (delta == 0)
+			break;
+
+		atomic_long_add(delta, &parent->children_low_usage);
+
+	} while ((memcg = parent));
+}
+
 struct memcg_stock_pcp {
 	struct mem_cgroup *cached; /* this never be root cgroup */
 	unsigned int nr_pages;
@@ -1717,6 +1747,7 @@ static void drain_stock(struct memcg_stock_pcp *stock)
 		page_counter_uncharge(&old->memory, stock->nr_pages);
 		if (do_memsw_account())
 			page_counter_uncharge(&old->memsw, stock->nr_pages);
+		memcg_update_low(old);
 		css_put_many(&old->css, stock->nr_pages);
 		stock->nr_pages = 0;
 	}
@@ -2008,11 +2039,13 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	if (do_memsw_account())
 		page_counter_charge(&memcg->memsw, nr_pages);
 	css_get_many(&memcg->css, nr_pages);
+	memcg_update_low(memcg);
 
 	return 0;
 
 done_restock:
 	css_get_many(&memcg->css, batch);
+	memcg_update_low(memcg);
 	if (batch > nr_pages)
 		refill_stock(memcg, batch - nr_pages);
 
@@ -2050,6 +2083,7 @@ static void cancel_charge(struct mem_cgroup *memcg, unsigned int nr_pages)
 	if (do_memsw_account())
 		page_counter_uncharge(&memcg->memsw, nr_pages);
 
+	memcg_update_low(memcg);
 	css_put_many(&memcg->css, nr_pages);
 }
 
@@ -2396,6 +2430,7 @@ void memcg_kmem_uncharge(struct page *page, int order)
 	if (PageKmemcg(page))
 		__ClearPageKmemcg(page);
 
+	memcg_update_low(memcg);
 	css_put_many(&memcg->css, nr_pages);
 }
 #endif /* !CONFIG_SLOB */
@@ -4500,6 +4535,7 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	spin_unlock(&memcg->event_list_lock);
 
 	memcg->low = 0;
+	memcg_update_low(memcg);
 
 	memcg_offline_kmem(memcg);
 	wb_memcg_offline(memcg);
@@ -4554,6 +4590,7 @@ static void mem_cgroup_css_reset(struct cgroup_subsys_state *css)
 	page_counter_limit(&memcg->kmem, PAGE_COUNTER_MAX);
 	page_counter_limit(&memcg->tcpmem, PAGE_COUNTER_MAX);
 	memcg->low = 0;
+	memcg_update_low(memcg);
 	memcg->high = PAGE_COUNTER_MAX;
 	memcg->soft_limit = PAGE_COUNTER_MAX;
 	memcg_wb_domain_size_changed(memcg);
@@ -5316,6 +5353,7 @@ static ssize_t memory_low_write(struct kernfs_open_file *of,
 		return err;
 
 	memcg->low = low;
+	memcg_update_low(memcg);
 
 	return nbytes;
 }
@@ -5612,36 +5650,69 @@ struct cgroup_subsys memory_cgrp_subsys = {
  * @root: the top ancestor of the sub-tree being checked
  * @memcg: the memory cgroup to check
  *
- * Returns %true if memory consumption of @memcg, and that of all
- * ancestors up to (but not including) @root, is below the normal range.
+ * Returns %true if memory consumption of @memcg is below the normal range.
+ *
+ * @root is exclusive; it is never low when looked at directly
  *
- * @root is exclusive; it is never low when looked at directly and isn't
- * checked when traversing the hierarchy.
+ * To provide a proper hierarchical behavior, effective memory.low value
+ * is used.
  *
- * Excluding @root enables using memory.low to prioritize memory usage
- * between cgroups within a subtree of the hierarchy that is limited by
- * memory.high or memory.max.
+ * Effective memory.low is always equal or less than the original memory.low.
+ * If there is no memory.low overcommittment (which is always true for
+ * top-level memory cgroups), these two values are equal.
+ * Otherwise, it's a part of parent's effective memory.low,
+ * calculated as a cgroup's memory.low usage divided by sum of sibling's
+ * memory.low usages, where memory.low usage is the size of actually
+ * protected memory.
  *
- * For example, given cgroup A with children B and C:
+ *                                             low_usage
+ * elow = min( memory.low, parent->elow * ------------------ ),
+ *                                        siblings_low_usage
  *
- *    A
- *   / \
- *  B   C
+ *             | memory.current, if memory.current < memory.low
+ * low_usage = |
+	       | 0, otherwise.
  *
- * and
  *
- *  1. A/memory.current > A/memory.high
- *  2. A/B/memory.current < A/B/memory.low
- *  3. A/C/memory.current >= A/C/memory.low
+ * Such definition of the effective memory.low provides the expected
+ * hierarchical behavior: parent's memory.low value is limiting
+ * children, unprotected memory is reclaimed first and cgroups,
+ * which are not using their guarantee do not affect actual memory
+ * distribution.
  *
- * As 'A' is high, i.e. triggers reclaim from 'A', and 'B' is low, we
- * should reclaim from 'C' until 'A' is no longer high or until we can
- * no longer reclaim from 'C'.  If 'A', i.e. @root, isn't excluded by
- * mem_cgroup_low when reclaming from 'A', then 'B' won't be considered
- * low and we will reclaim indiscriminately from both 'B' and 'C'.
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
+ * (see memcg_update_low()), as well as recursive calculation of
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
 
@@ -5650,12 +5721,30 @@ bool mem_cgroup_low(struct mem_cgroup *root, struct mem_cgroup *memcg)
 	if (memcg == root)
 		return false;
 
-	for (; memcg != root; memcg = parent_mem_cgroup(memcg)) {
-		if (page_counter_read(&memcg->memory) >= memcg->low)
-			return false;
-	}
+	elow = memcg->low;
+	usage = page_counter_read(&memcg->memory);
 
-	return true;
+	parent = parent_mem_cgroup(memcg);
+	if (parent == root)
+		goto exit;
+
+	parent_elow = parent->elow;
+	elow = min(elow, parent_elow);
+
+	if (!elow || !parent_elow)
+		goto exit;
+
+	low_usage = min(usage, memcg->low);
+	siblings_low_usage = atomic_long_read(&parent->children_low_usage);
+	if (!low_usage || !siblings_low_usage)
+		goto exit;
+
+	elow = min(elow, parent_elow * low_usage / siblings_low_usage);
+
+exit:
+	memcg->elow = elow;
+
+	return usage < elow;
 }
 
 /**
@@ -5829,6 +5918,7 @@ static void uncharge_batch(const struct uncharge_gather *ug)
 		if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) && ug->nr_kmem)
 			page_counter_uncharge(&ug->memcg->kmem, ug->nr_kmem);
 		memcg_oom_recover(ug->memcg);
+		memcg_update_low(ug->memcg);
 	}
 
 	local_irq_save(flags);
-- 
2.14.3
