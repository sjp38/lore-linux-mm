Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 96AD76B0007
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 18:34:48 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id h11so1714572pfn.0
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 15:34:48 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id x4-v6si2454777plv.81.2018.03.20.15.34.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 15:34:47 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [RFC] mm: memory.low heirarchical behavior
Date: Tue, 20 Mar 2018 22:33:53 +0000
Message-ID: <20180320223353.5673-1-guro@fb.com>
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
BC  DE   B/memory.low = 3G  B/memory.usage = 2G
         C/memory.low = 1G  C/memory.usage = 2G
         D/memory.low = 0   D/memory.usage = 2G
	 E/memory.low = 10G E/memory.usage = 0

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

Effective memory.low is always capped by memory.low, set by user.
That means it's not possible to become a larger guarantee than
memory.low set by a user, even if corresponding part of parent's
guarantee is larger. This matches existing semantics.

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
  A:    2146160640
  A/B:  1427795968
  A/C:  717705216
  A/D:  659456
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
 include/linux/memcontrol.h |  4 +++
 mm/memcontrol.c            | 64 +++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 64 insertions(+), 4 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 4525b4404a9e..a95a2e9938b2 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -180,8 +180,12 @@ struct mem_cgroup {
 
 	/* Normal memory consumption range */
 	unsigned long low;
+	unsigned long e_low;
 	unsigned long high;
 
+	atomic_long_t low_usage;
+	atomic_long_t s_low_usage;
+
 	/* Range enforcement for interrupt charges */
 	struct work_struct high_work;
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3801ac1fcfbc..5af3199451f0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1672,6 +1672,36 @@ void unlock_page_memcg(struct page *page)
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
+		atomic_long_add(delta, &parent->s_low_usage);
+
+	} while ((memcg = parent));
+}
+
 struct memcg_stock_pcp {
 	struct mem_cgroup *cached; /* this never be root cgroup */
 	unsigned int nr_pages;
@@ -1726,6 +1756,7 @@ static void drain_stock(struct memcg_stock_pcp *stock)
 		page_counter_uncharge(&old->memory, stock->nr_pages);
 		if (do_memsw_account())
 			page_counter_uncharge(&old->memsw, stock->nr_pages);
+		memcg_update_low(old);
 		css_put_many(&old->css, stock->nr_pages);
 		stock->nr_pages = 0;
 	}
@@ -2017,11 +2048,13 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
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
 
@@ -2059,6 +2092,7 @@ static void cancel_charge(struct mem_cgroup *memcg, unsigned int nr_pages)
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
@@ -5642,6 +5677,9 @@ struct cgroup_subsys memory_cgrp_subsys = {
  */
 bool mem_cgroup_low(struct mem_cgroup *root, struct mem_cgroup *memcg)
 {
+	unsigned long usage, low_usage, s_low_usage, p_e_low, e_low;
+	struct mem_cgroup *parent;
+
 	if (mem_cgroup_disabled())
 		return false;
 
@@ -5650,12 +5688,29 @@ bool mem_cgroup_low(struct mem_cgroup *root, struct mem_cgroup *memcg)
 	if (memcg == root)
 		return false;
 
-	for (; memcg != root; memcg = parent_mem_cgroup(memcg)) {
-		if (page_counter_read(&memcg->memory) >= memcg->low)
-			return false;
+	e_low = memcg->low;
+	usage = page_counter_read(&memcg->memory);
+
+	parent = parent_mem_cgroup(memcg);
+	if (mem_cgroup_is_root(parent))
+		goto exit;
+
+	p_e_low = parent->e_low;
+	e_low = min(e_low, p_e_low);
+
+	if (e_low && p_e_low) {
+		low_usage = min(usage, memcg->low);
+		s_low_usage = atomic_long_read(&parent->s_low_usage);
+		if (!low_usage || !s_low_usage)
+			goto exit;
+
+		e_low = min(e_low, p_e_low * low_usage / s_low_usage);
 	}
 
-	return true;
+exit:
+	memcg->e_low = e_low;
+
+	return usage < e_low;
 }
 
 /**
@@ -5829,6 +5884,7 @@ static void uncharge_batch(const struct uncharge_gather *ug)
 		if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) && ug->nr_kmem)
 			page_counter_uncharge(&ug->memcg->kmem, ug->nr_kmem);
 		memcg_oom_recover(ug->memcg);
+		memcg_update_low(ug->memcg);
 	}
 
 	local_irq_save(flags);
-- 
2.14.3
