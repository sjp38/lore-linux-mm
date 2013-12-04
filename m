Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f43.google.com (mail-yh0-f43.google.com [209.85.213.43])
	by kanga.kvack.org (Postfix) with ESMTP id C808C6B0036
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 00:20:01 -0500 (EST)
Received: by mail-yh0-f43.google.com with SMTP id a41so10390466yho.2
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 21:20:01 -0800 (PST)
Received: from mail-yh0-x232.google.com (mail-yh0-x232.google.com [2607:f8b0:4002:c01::232])
        by mx.google.com with ESMTPS id e33si46749424yhq.293.2013.12.03.21.20.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Dec 2013 21:20:01 -0800 (PST)
Received: by mail-yh0-f50.google.com with SMTP id b6so11048182yha.37
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 21:20:00 -0800 (PST)
Date: Tue, 3 Dec 2013 21:19:57 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 2/8] mm, mempolicy: rename slab_node for clarity
In-Reply-To: <alpine.DEB.2.02.1312032116440.29733@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1312032117330.29733@chino.kir.corp.google.com>
References: <20131119131400.GC20655@dhcp22.suse.cz> <20131119134007.GD20655@dhcp22.suse.cz> <alpine.DEB.2.02.1311192352070.20752@chino.kir.corp.google.com> <20131120152251.GA18809@dhcp22.suse.cz> <alpine.DEB.2.02.1311201917520.7167@chino.kir.corp.google.com>
 <20131128115458.GK2761@dhcp22.suse.cz> <alpine.DEB.2.02.1312021504170.13465@chino.kir.corp.google.com> <alpine.DEB.2.02.1312032116440.29733@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

slab_node() is actually a mempolicy function, so rename it to
mempolicy_slab_node() to make it clearer that it used for processes with
mempolicies.

At the same time, cleanup its code by saving numa_mem_id() in a local
variable (since we require a node with memory, not just any node) and
remove an obsolete comment that assumes the mempolicy is actually passed
into the function.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/mempolicy.h |  2 +-
 mm/mempolicy.c            | 15 ++++++---------
 mm/slab.c                 |  4 ++--
 mm/slub.c                 |  2 +-
 4 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -151,7 +151,7 @@ extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
 extern bool init_nodemask_of_mempolicy(nodemask_t *mask);
 extern bool mempolicy_nodemask_intersects(struct task_struct *tsk,
 				const nodemask_t *mask);
-extern unsigned slab_node(void);
+extern unsigned int mempolicy_slab_node(void);
 
 extern enum zone_type policy_zone;
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1783,21 +1783,18 @@ static unsigned interleave_nodes(struct mempolicy *policy)
 /*
  * Depending on the memory policy provide a node from which to allocate the
  * next slab entry.
- * @policy must be protected by freeing by the caller.  If @policy is
- * the current task's mempolicy, this protection is implicit, as only the
- * task can change it's policy.  The system default policy requires no
- * such protection.
  */
-unsigned slab_node(void)
+unsigned int mempolicy_slab_node(void)
 {
 	struct mempolicy *policy;
+	int node = numa_mem_id();
 
 	if (in_interrupt())
-		return numa_node_id();
+		return node;
 
 	policy = current->mempolicy;
 	if (!policy || policy->flags & MPOL_F_LOCAL)
-		return numa_node_id();
+		return node;
 
 	switch (policy->mode) {
 	case MPOL_PREFERRED:
@@ -1817,11 +1814,11 @@ unsigned slab_node(void)
 		struct zonelist *zonelist;
 		struct zone *zone;
 		enum zone_type highest_zoneidx = gfp_zone(GFP_KERNEL);
-		zonelist = &NODE_DATA(numa_node_id())->node_zonelists[0];
+		zonelist = &NODE_DATA(node)->node_zonelists[0];
 		(void)first_zones_zonelist(zonelist, highest_zoneidx,
 							&policy->v.nodes,
 							&zone);
-		return zone ? zone->node : numa_node_id();
+		return zone ? zone->node : node;
 	}
 
 	default:
diff --git a/mm/slab.c b/mm/slab.c
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3042,7 +3042,7 @@ static void *alternate_node_alloc(struct kmem_cache *cachep, gfp_t flags)
 	if (cpuset_do_slab_mem_spread() && (cachep->flags & SLAB_MEM_SPREAD))
 		nid_alloc = cpuset_slab_spread_node();
 	else if (current->mempolicy)
-		nid_alloc = slab_node();
+		nid_alloc = mempolicy_slab_node();
 	if (nid_alloc != nid_here)
 		return ____cache_alloc_node(cachep, flags, nid_alloc);
 	return NULL;
@@ -3074,7 +3074,7 @@ static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
 
 retry_cpuset:
 	cpuset_mems_cookie = get_mems_allowed();
-	zonelist = node_zonelist(slab_node(), flags);
+	zonelist = node_zonelist(mempolicy_slab_node(), flags);
 
 retry:
 	/*
diff --git a/mm/slub.c b/mm/slub.c
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1663,7 +1663,7 @@ static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
 
 	do {
 		cpuset_mems_cookie = get_mems_allowed();
-		zonelist = node_zonelist(slab_node(), flags);
+		zonelist = node_zonelist(mempolicy_slab_node(), flags);
 		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 			struct kmem_cache_node *n;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
