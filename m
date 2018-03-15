Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 55C796B0006
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 16:51:04 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 69-v6so3811401plc.18
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 13:51:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y96-v6sor1966353plh.37.2018.03.15.13.51.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Mar 2018 13:51:03 -0700 (PDT)
Date: Thu, 15 Mar 2018 13:51:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] mm, memcg: disregard mempolicies for cgroup-aware oom
 killer
In-Reply-To: <alpine.DEB.2.20.1803131720470.247949@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.20.1803151350420.55261@chino.kir.corp.google.com>
References: <alpine.DEB.2.20.1803121755590.192200@chino.kir.corp.google.com> <alpine.DEB.2.20.1803131720470.247949@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The cgroup-aware oom killer currently considers the set of allowed nodes
for the allocation that triggers the oom killer and discounts usage from
disallowed nodes when comparing cgroups.

If a cgroup has both the cpuset and memory controllers enabled, it may be
possible to restrict allocations to a subset of nodes, for example.  Some
latency sensitive users use cpusets to allocate only local memory, almost
to the point of oom even though there is an abundance of available free
memory on other nodes.

The same is true for processes that mbind(2) their memory to a set of
allowed nodes.

This yields very inconsistent results by considering usage from each mem
cgroup (and perhaps its subtree) for the allocation's set of allowed nodes
for its mempolicy.  Allocating a single page for a vma that is mbind to a
now-oom node can cause a cgroup that is restricted to that node by its
cpuset controller to be oom killed when other cgroups may have much higher
overall usage.

The cgroup-aware oom killer is described as killing the largest memory
consuming cgroup (or subtree) without mentioning the mempolicy of the
allocation.  For now, discount it.  It would be possible to add an
additional oom policy for NUMA awareness if it would be generally useful
later with the extensible interface.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Based on top of oom policy patch series at
 https://marc.info/?t=152090280800001 and follow-up patch at
 https://marc.info/?l=linux-kernel&m=152098687824112

 mm/memcontrol.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2608,19 +2608,15 @@ static inline bool memcg_has_children(struct mem_cgroup *memcg)
 	return ret;
 }
 
-static long memcg_oom_badness(struct mem_cgroup *memcg,
-			      const nodemask_t *nodemask)
+static long memcg_oom_badness(struct mem_cgroup *memcg)
 {
 	const bool is_root_memcg = memcg == root_mem_cgroup;
 	long points = 0;
 	int nid;
-	pg_data_t *pgdat;
 
 	for_each_node_state(nid, N_MEMORY) {
-		if (nodemask && !node_isset(nid, *nodemask))
-			continue;
+		pg_data_t *pgdat = NODE_DATA(nid);
 
-		pgdat = NODE_DATA(nid);
 		if (is_root_memcg) {
 			points += node_page_state(pgdat, NR_ACTIVE_ANON) +
 				  node_page_state(pgdat, NR_INACTIVE_ANON);
@@ -2656,8 +2652,7 @@ static long memcg_oom_badness(struct mem_cgroup *memcg,
  *   >0: memcg is eligible, and the returned value is an estimation
  *       of the memory footprint
  */
-static long oom_evaluate_memcg(struct mem_cgroup *memcg,
-			       const nodemask_t *nodemask)
+static long oom_evaluate_memcg(struct mem_cgroup *memcg)
 {
 	struct css_task_iter it;
 	struct task_struct *task;
@@ -2691,7 +2686,7 @@ static long oom_evaluate_memcg(struct mem_cgroup *memcg,
 	if (eligible <= 0)
 		return eligible;
 
-	return memcg_oom_badness(memcg, nodemask);
+	return memcg_oom_badness(memcg);
 }
 
 static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
@@ -2751,7 +2746,7 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
 		if (memcg_has_children(iter))
 			continue;
 
-		score = oom_evaluate_memcg(iter, oc->nodemask);
+		score = oom_evaluate_memcg(iter);
 
 		/*
 		 * Ignore empty and non-eligible memory cgroups.
@@ -2780,8 +2775,7 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
 
 	if (oc->chosen_memcg != INFLIGHT_VICTIM) {
 		if (root == root_mem_cgroup) {
-			group_score = oom_evaluate_memcg(root_mem_cgroup,
-							 oc->nodemask);
+			group_score = oom_evaluate_memcg(root_mem_cgroup);
 			if (group_score > leaf_score) {
 				/*
 				 * Discount the sum of all leaf scores to find
