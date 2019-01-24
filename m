Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5694B8E0068
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 20:45:00 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id 68so2020719ybe.15
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 17:45:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n9sor3636878ywc.24.2019.01.23.17.44.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 Jan 2019 17:44:57 -0800 (PST)
Date: Wed, 23 Jan 2019 20:44:55 -0500
From: Chris Down <chris@chrisdown.name>
Subject: [PATCH] mm: Proportional memory.{low,min} reclaim
Message-ID: <20190124014455.GA6396@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

cgroup v2 introduces two memory protection thresholds: memory.low
(best-effort) and memory.min (hard protection). While they generally do
what they say on the tin, there is a limitation in their implementation
that makes them difficult to use effectively: that cliff behaviour often
manifests when they become eligible for reclaim. This patch implements
more intuitive and usable behaviour, where we gradually mount more
reclaim pressure as cgroups further and further exceed their protection
thresholds.

This cliff edge behaviour happens because we only choose whether or not
to reclaim based on whether the memcg is within its protection limits
(see the use of mem_cgroup_protected in shrink_node), but we don't vary
our reclaim behaviour based on this information. Imagine the following
timeline, with the numbers the lruvec size in this zone:

1. memory.low=1000000, memory.current=999999. 0 pages may be scanned.
2. memory.low=1000000, memory.current=1000000. 0 pages may be scanned.
3. memory.low=1000000, memory.current=1000001. 1000001* pages may be
   scanned. (?!)

* Of course, we won't usually scan all available pages in the zone even
  without this patch because of scan control priority, over-reclaim
  protection, etc. However, as shown by the tests at the end, these
  techniques don't sufficiently throttle such an extreme change in
  input, so cliff-like behaviour isn't really averted by their existence
  alone.

Here's an example of how this plays out in practice. At Facebook, we are
trying to protect various workloads from "system" software, like
configuration management tools, metric collectors, etc (see this[0] case
study). In order to find a suitable memory.low value, we start by
determining the expected memory range within which the workload will be
comfortable operating. This isn't an exact science -- memory usage
deemed "comfortable" will vary over time due to user behaviour,
differences in composition of work, etc, etc. As such we need to
ballpark memory.low, but doing this is currently problematic:

1. If we end up setting it too low for the workload, it won't have *any*
   effect (see discussion above). The group will receive the full weight
   of reclaim and won't have any priority while competing with the less
   important system software, as if we had no memory.low configured at
   all.

2. Because of this behaviour, we end up erring on the side of setting it
   too high, such that the comfort range is reliably covered. However,
   protected memory is completely unavailable to the rest of the system,
   so we might cause undue memory and IO pressure there when we *know*
   we have some elasticity in the workload.

3. Even if we get the value totally right, smack in the middle of the
   comfort zone, we get extreme jumps between no pressure and full
   pressure that cause unpredictable pressure spikes in the workload due
   to the current binary reclaim behaviour.

With this patch, we can set it to our ballpark estimation without too
much worry. Any undesirable behaviour, such as too much or too little
reclaim pressure on the workload or system will be proportional to how
far our estimation is off. This means we can set memory.low much more
conservatively and thus waste less resources *without* the risk of the
workload falling off a cliff if we overshoot.

As a more abstract technical description, this unintuitive behaviour
results in having to give high-priority workloads a large protection
buffer on top of their expected usage to function reliably, as otherwise
we have abrupt periods of dramatically increased memory pressure which
hamper performance.  Having to set these thresholds so high wastes
resources and generally works against the principle of work
conservation. In addition, having proportional memory reclaim behaviour
has other benefits. Most notably, before this patch it's basically
mandatory to set memory.low to a higher than desirable value because
otherwise as soon as you exceed memory.low, all protection is lost, and
all pages are eligible to scan again. By contrast, having a gradual ramp
in reclaim pressure means that you now still get some protection when
thresholds are exceeded, which means that one can now be more
comfortable setting memory.low to lower values without worrying that all
protection will be lost. This is important because workingset size is
really hard to know exactly, especially with variable workloads, so at
least getting *some* protection if your workingset size grows larger
than you expect increases user confidence in setting memory.low without
a huge buffer on top being needed.

Thanks a lot to Johannes Weiner and Tejun Heo for their advice and
assistance in thinking about how to make this work better.

In testing these changes, I intended to verify that:

1. Changes in page scanning become gradual and proportional instead of
   binary.

   To test this, I experimented stepping further and further down
   memory.low protection on a workload that floats around 19G workingset
   when under memory.low protection, watching page scan rates for the
   workload cgroup:

   +------------+-----------------+--------------------+--------------+
   | memory.low | test (pgscan/s) | control (pgscan/s) | % of control |
   +------------+-----------------+--------------------+--------------+
   |        21G |               0 |                  0 | N/A          |
   |        17G |             867 |               3799 | 23%          |
   |        12G |            1203 |               3543 | 34%          |
   |         8G |            2534 |               3979 | 64%          |
   |         4G |            3980 |               4147 | 96%          |
   |          0 |            3799 |               3980 | 95%          |
   +------------+-----------------+--------------------+--------------+

   As you can see, the test kernel (with a kernel containing this patch)
   ramps up page scanning significantly more gradually than the control
   kernel (without this patch).

2. More gradual ramp up in reclaim aggression doesn't result in
   premature OOMs.

   To test this, I wrote a script that slowly increments the number of
   pages held by stress(1)'s --vm-keep mode until a production system
   entered severe overall memory contention. This script runs in a
   highly protected slice taking up the majority of available system
   memory. Watching vmstat revealed that page scanning continued
   essentially nominally between test and control, without causing
   forward reclaim progress to become arrested.

[0]: https://facebookmicrosites.github.io/cgroup2/docs/overview.html#case-study-the-fbtax2-project

Signed-off-by: Chris Down <chris@chrisdown.name>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Roman Gushchin <guro@fb.com>
Cc: Dennis Zhou <dennis@kernel.org>
Cc: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: kernel-team@fb.com
---
 Documentation/admin-guide/cgroup-v2.rst | 20 +++++--
 include/linux/memcontrol.h              | 17 ++++++
 mm/memcontrol.c                         |  5 ++
 mm/vmscan.c                             | 76 +++++++++++++++++++++++--
 4 files changed, 106 insertions(+), 12 deletions(-)

diff --git a/Documentation/admin-guide/cgroup-v2.rst b/Documentation/admin-guide/cgroup-v2.rst
index 7bf3f129c68b..8ed408166890 100644
--- a/Documentation/admin-guide/cgroup-v2.rst
+++ b/Documentation/admin-guide/cgroup-v2.rst
@@ -606,8 +606,8 @@ on an IO device and is an example of this type.
 Protections
 -----------
 
-A cgroup is protected to be allocated upto the configured amount of
-the resource if the usages of all its ancestors are under their
+A cgroup is protected upto the configured amount of the resource
+as long as the usages of all its ancestors are under their
 protected levels.  Protections can be hard guarantees or best effort
 soft boundaries.  Protections can also be over-committed in which case
 only upto the amount available to the parent is protected among
@@ -1020,7 +1020,10 @@ PAGE_SIZE multiple when read back.
 	is within its effective min boundary, the cgroup's memory
 	won't be reclaimed under any conditions. If there is no
 	unprotected reclaimable memory available, OOM killer
-	is invoked.
+	is invoked. Above the effective min boundary (or
+	effective low boundary if it is higher), pages are reclaimed
+	proportionally to the overage, reducing reclaim pressure for
+	smaller overages.
 
        Effective min boundary is limited by memory.min values of
 	all ancestor cgroups. If there is memory.min overcommitment
@@ -1042,7 +1045,10 @@ PAGE_SIZE multiple when read back.
 	Best-effort memory protection.  If the memory usage of a
 	cgroup is within its effective low boundary, the cgroup's
 	memory won't be reclaimed unless memory can be reclaimed
-	from unprotected cgroups.
+	from unprotected cgroups.  Above the effective low boundary (or
+	effective min boundary if it is higher), pages are reclaimed
+	proportionally to the overage, reducing reclaim pressure for
+	smaller overages.
 
 	Effective low boundary is limited by memory.low values of
 	all ancestor cgroups. If there is memory.low overcommitment
@@ -2283,8 +2289,10 @@ system performance due to overreclaim, to the point where the feature
 becomes self-defeating.
 
 The memory.low boundary on the other hand is a top-down allocated
-reserve.  A cgroup enjoys reclaim protection when it's within its low,
-which makes delegation of subtrees possible.
+reserve.  A cgroup enjoys reclaim protection when it's within its
+effective low, which makes delegation of subtrees possible. It also
+enjoys having reclaim pressure proportional to its overage when
+above its effective low.
 
 The original high boundary, the hard limit, is defined as a strict
 limit that can not budge, even if the OOM killer has to be called.
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index b0eb29ea0d9c..290cfbfd60cd 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -333,6 +333,11 @@ static inline bool mem_cgroup_disabled(void)
 	return !cgroup_subsys_enabled(memory_cgrp_subsys);
 }
 
+static inline unsigned long mem_cgroup_protection(struct mem_cgroup *memcg)
+{
+	return max(READ_ONCE(memcg->memory.emin), READ_ONCE(memcg->memory.elow));
+}
+
 enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
 						struct mem_cgroup *memcg);
 
@@ -526,6 +531,8 @@ void mem_cgroup_handle_over_high(void);
 
 unsigned long mem_cgroup_get_max(struct mem_cgroup *memcg);
 
+unsigned long mem_cgroup_size(struct mem_cgroup *memcg);
+
 void mem_cgroup_print_oom_context(struct mem_cgroup *memcg,
 				struct task_struct *p);
 
@@ -819,6 +826,11 @@ static inline void memcg_memory_event_mm(struct mm_struct *mm,
 {
 }
 
+static inline unsigned long mem_cgroup_protection(struct mem_cgroup *memcg)
+{
+	return 0;
+}
+
 static inline enum mem_cgroup_protection mem_cgroup_protected(
 	struct mem_cgroup *root, struct mem_cgroup *memcg)
 {
@@ -971,6 +983,11 @@ static inline unsigned long mem_cgroup_get_max(struct mem_cgroup *memcg)
 	return 0;
 }
 
+static inline unsigned long mem_cgroup_size(struct mem_cgroup *memcg)
+{
+	return 0;
+}
+
 static inline void
 mem_cgroup_print_oom_context(struct mem_cgroup *memcg, struct task_struct *p)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 18f4aefbe0bf..1d2b2aaf124d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1377,6 +1377,11 @@ unsigned long mem_cgroup_get_max(struct mem_cgroup *memcg)
 	return max;
 }
 
+unsigned long mem_cgroup_size(struct mem_cgroup *memcg)
+{
+	return page_counter_read(&memcg->memory);
+}
+
 static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 				     int order)
 {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a714c4f800e9..638c3655dc4b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2445,17 +2445,74 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	*lru_pages = 0;
 	for_each_evictable_lru(lru) {
 		int file = is_file_lru(lru);
-		unsigned long size;
+		unsigned long lruvec_size;
 		unsigned long scan;
+		unsigned long protection;
+
+		lruvec_size = lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
+		protection = mem_cgroup_protection(memcg);
+
+		if (protection > 0) {
+			/*
+			 * Scale a cgroup's reclaim pressure by proportioning its current
+			 * usage to its memory.low or memory.min setting.
+			 *
+			 * This is important, as otherwise scanning aggression becomes
+			 * extremely binary -- from nothing as we approach the memory
+			 * protection threshold, to totally nominal as we exceed it. This
+			 * results in requiring setting extremely liberal protection
+			 * thresholds. It also means we simply get no protection at all if
+			 * we set it too low, which is not ideal.
+			 */
+			unsigned long cgroup_size = mem_cgroup_size(memcg);
+			unsigned long baseline = 0;
+
+			/*
+			 * During the reclaim first pass, we only consider cgroups in
+			 * excess of their protection setting, but if that doesn't produce
+			 * free pages, we come back for a second pass where we reclaim from
+			 * all groups.
+			 *
+			 * To maintain fairness in both cases, the first pass targets
+			 * groups in proportion to their overage, and the second pass
+			 * targets groups in proportion to their protection utilization.
+			 *
+			 * So on the first pass, a group whose size is 130% of its
+			 * protection will be targeted at 30% of its size. On the second
+			 * pass, a group whose size is at 40% of its protection will be
+			 * targeted at 40% of its size.
+			 */
+			if (!sc->memcg_low_reclaim)
+				baseline = lruvec_size;
+			scan = lruvec_size * cgroup_size / protection - baseline;
+
+			/*
+			 * Don't allow the scan target to exceed the lruvec size, which
+			 * otherwise could happen if we have >200% overage in the normal
+			 * case, or >100% overage when sc->memcg_low_reclaim is set.
+			 *
+			 * This is important because other cgroups without memory.low have
+			 * their scan target initially set to their lruvec size, so
+			 * allowing values >100% of the lruvec size here could result in
+			 * penalising cgroups with memory.low set even *more* than their
+			 * peers in some cases in the case of large overages.
+			 *
+			 * Also, minimally target SWAP_CLUSTER_MAX pages to keep reclaim
+			 * moving forwards.
+			 */
+			scan = clamp(scan, SWAP_CLUSTER_MAX, lruvec_size);
+		} else {
+			scan = lruvec_size;
+		}
+
+		scan >>= sc->priority;
 
-		size = lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
-		scan = size >> sc->priority;
 		/*
 		 * If the cgroup's already been deleted, make sure to
 		 * scrape out the remaining cache.
 		 */
 		if (!scan && !mem_cgroup_online(memcg))
-			scan = min(size, SWAP_CLUSTER_MAX);
+			scan = min(lruvec_size, SWAP_CLUSTER_MAX);
 
 		switch (scan_balance) {
 		case SCAN_EQUAL:
@@ -2475,7 +2532,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 		case SCAN_ANON:
 			/* Scan one type exclusively */
 			if ((scan_balance == SCAN_FILE) != file) {
-				size = 0;
+				lruvec_size = 0;
 				scan = 0;
 			}
 			break;
@@ -2484,7 +2541,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 			BUG();
 		}
 
-		*lru_pages += size;
+		*lru_pages += lruvec_size;
 		nr[lru] = scan;
 	}
 }
@@ -2745,6 +2802,13 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 				memcg_memory_event(memcg, MEMCG_LOW);
 				break;
 			case MEMCG_PROT_NONE:
+				/*
+				 * All protection thresholds breached. We may
+				 * still choose to vary the scan pressure
+				 * applied based on by how much the cgroup in
+				 * question has exceeded its protection
+				 * thresholds (see get_scan_count).
+				 */
 				break;
 			}
 
-- 
2.20.1
