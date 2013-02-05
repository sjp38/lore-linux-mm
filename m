Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id D1AC26B0002
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 13:53:30 -0500 (EST)
Date: Tue, 5 Feb 2013 13:53:24 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] memcg: reduce the size of struct memcg 244-fold.
Message-ID: <20130205185324.GB6481@cmpxchg.org>
References: <1359009996-5350-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1359009996-5350-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On Thu, Jan 24, 2013 at 10:46:35AM +0400, Glauber Costa wrote:
> In order to maintain all the memcg bookkeeping, we need per-node
> descriptors, which will in turn contain a per-zone descriptor.
> 
> Because we want to statically allocate those, this array ends up being
> very big. Part of the reason is that we allocate something large enough
> to hold MAX_NUMNODES, the compile time constant that holds the maximum
> number of nodes we would ever consider.
> 
> However, we can do better in some cases if the firmware help us. This is
> true for modern x86 machines; coincidentally one of the architectures in
> which MAX_NUMNODES tends to be very big.
> 
> By using the firmware-provided maximum number of nodes instead of
> MAX_NUMNODES, we can reduce the memory footprint of struct memcg
> considerably. In the extreme case in which we have only one node, this
> reduces the size of the structure from ~ 64k to ~2k. This is
> particularly important because it means that we will no longer resort to
> the vmalloc area for the struct memcg on defconfigs. We also have enough
> room for an extra node and still be outside vmalloc.
> 
> One also has to keep in mind that with the industry's ability to fit
> more processors in a die as fast as the FED prints money, a nodes = 2
> configuration is already respectably big.
> 
> [ v2: use size_t for size calculations ]
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Greg Thelen <gthelen@google.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Ying Han <yinghan@google.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Nitpick:

> @@ -349,8 +338,29 @@ struct mem_cgroup {
>          /* Index in the kmem_cache->memcg_params->memcg_caches array */
>  	int kmemcg_id;
>  #endif
> +
> +	int last_scanned_node;
> +#if MAX_NUMNODES > 1
> +	nodemask_t	scan_nodes;
> +	atomic_t	numainfo_events;
> +	atomic_t	numainfo_updating;
> +#endif
> +	/*
> +	 * Per cgroup active and inactive list, similar to the
> +	 * per zone LRU lists.
> +	 *
> +	 * WARNING: This has to be the last element of the struct. Don't
> +	 * add new fields after this point.
> +	 */
> +	struct mem_cgroup_lru_info info;

I can see myself ignoring comments pertaining to previous members when
adding to a struct.  The indirection through mem_cgroup_lru_info can
probably be dropped anyway, and it moves the [0] in a place where it
helps document the struct mem_cgroup layout.  What do you think about
the following:

---
Subject: [patch] memcg: reduce the size of struct memcg 244-fold morrr fix

Remove struct mem_cgroup_lru_info.  It only holds the nodeinfo array
and is actively misleading because there is all kinds of per-node
stuff in addition to the LRU info in there.  On that note, remove the
incorrect comment as well.

Move comment about the nodeinfo[0] array having to be the last field
in struct mem_cgroup after said array.  Should be more visible when
attempting to append new members to the struct.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2382fe9..29cb9e9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -179,10 +179,6 @@ struct mem_cgroup_per_node {
 	struct mem_cgroup_per_zone zoneinfo[MAX_NR_ZONES];
 };
 
-struct mem_cgroup_lru_info {
-	struct mem_cgroup_per_node *nodeinfo[0];
-};
-
 /*
  * Cgroups above their limits are maintained in a RB-Tree, independent of
  * their hierarchy representation
@@ -370,14 +366,8 @@ struct mem_cgroup {
 	atomic_t	numainfo_events;
 	atomic_t	numainfo_updating;
 #endif
-	/*
-	 * Per cgroup active and inactive list, similar to the
-	 * per zone LRU lists.
-	 *
-	 * WARNING: This has to be the last element of the struct. Don't
-	 * add new fields after this point.
-	 */
-	struct mem_cgroup_lru_info info;
+	struct mem_cgroup_per_node *nodeinfo[0];
+	/* WARNING: nodeinfo has to be the last member in here */
 };
 
 static inline size_t memcg_size(void)
@@ -718,7 +708,7 @@ static struct mem_cgroup_per_zone *
 mem_cgroup_zoneinfo(struct mem_cgroup *memcg, int nid, int zid)
 {
 	VM_BUG_ON((unsigned)nid >= nr_node_ids);
-	return &memcg->info.nodeinfo[nid]->zoneinfo[zid];
+	return &memcg->nodeinfo[nid]->zoneinfo[zid];
 }
 
 struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *memcg)
@@ -6093,13 +6083,13 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 		mz->on_tree = false;
 		mz->memcg = memcg;
 	}
-	memcg->info.nodeinfo[node] = pn;
+	memcg->nodeinfo[node] = pn;
 	return 0;
 }
 
 static void free_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 {
-	kfree(memcg->info.nodeinfo[node]);
+	kfree(memcg->nodeinfo[node]);
 }
 
 static struct mem_cgroup *mem_cgroup_alloc(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
