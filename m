Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 93C8F6B0032
	for <linux-mm@kvack.org>; Sun, 21 Apr 2013 22:14:15 -0400 (EDT)
Received: by mail-we0-f178.google.com with SMTP id z53so5540906wey.23
        for <linux-mm@kvack.org>; Sun, 21 Apr 2013 19:14:13 -0700 (PDT)
Date: Mon, 22 Apr 2013 04:14:11 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 3/3] vmscan, memcg: Do softlimit reclaim also for targeted
 reclaim
Message-ID: <20130422021411.GA16060@dhcp22.suse.cz>
References: <1365509595-665-1-git-send-email-mhocko@suse.cz>
 <1365509595-665-4-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365509595-665-4-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Ying Han <yinghan@google.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>

On Tue 09-04-13 14:13:15, Michal Hocko wrote:
> Soft reclaim has been done only for the global reclaim (both background
> and direct). Since "memcg: integrate soft reclaim tighter with zone
> shrinking code" there is no reason for this limitation anymore as the
> soft limit reclaim doesn't use any special code paths and it is a
> part of the zone shrinking code which is used by both global and
> targeted reclaims.
> 
> From semantic point of view it is even natural to consider soft limit
> before touching all groups in the hierarchy tree which is touching the
> hard limit because soft limit tells us where to push back when there is
> a memory pressure. It is not important whether the pressure comes from
> the limit or imbalanced zones.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/vmscan.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index ae3a387..cf729ca 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -141,7 +141,7 @@ static bool global_reclaim(struct scan_control *sc)
>  
>  static bool mem_cgroup_should_soft_reclaim(struct scan_control *sc)
>  {
> -	return global_reclaim(sc);
> +	return true;
>  }
>  #else
>  static bool global_reclaim(struct scan_control *sc)

This patch is not complete. We also need to update
mem_cgroup_soft_reclaim_eligible as well because we should ignore
parents that are above the current reclaim pressure. Say we have
A (over soft limit)
 \
  B (below s.l., hit the hard limit) 
 / \
C   D (below s.l.)

B is the source of the outside memory pressure now for D but we
shouldn't soft reclaim it because it is behaving well under B subtree.
mem_cgroup_soft_reclaim_eligible should therefore stop climbing up the
hierarchy at B (root of the memory pressure).
---
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 1833c95..80ed1b6 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -179,7 +179,8 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 	mem_cgroup_update_page_stat(page, idx, -1);
 }
 
-bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg);
+bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg,
+		struct mem_cgroup *root);
 
 void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
 static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
@@ -356,7 +357,8 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 }
 
 static inline
-bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg)
+bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg,
+		struct mem_cgroup *root)
 {
 	return false;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index be86815..19b4cb7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1845,12 +1845,14 @@ int mem_cgroup_select_victim_node(struct mem_cgroup *memcg)
 #endif
 
 /*
- * A group is eligible for the soft limit reclaim if it is
+ * A group is eligible for the soft limit reclaim under given root hierarchy
+ * if it is
  * 	a) doesn't have any soft limit set
  * 	b) is over its soft limit
  * 	c) any parent up the hierarchy is over its soft limit
  */
-bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg)
+bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg,
+		struct mem_cgroup *root)
 {
 	struct mem_cgroup *parent = memcg;
 
@@ -1863,13 +1865,15 @@ bool mem_cgroup_soft_reclaim_eligible(struct mem_cgroup *memcg)
 		return true;
 
 	/*
-	 * If any parent up the hierarchy is over its soft limit then we
-	 * have to obey and reclaim from this group as well.
+	 * If any parent up to the root in the hierarchy is over its soft limit
+	 * then we have to obey and reclaim from this group as well.
 	 */
 	while((parent = parent_mem_cgroup(parent))) {
 		if (parent->soft_limited &&
 				res_counter_soft_limit_excess(&parent->res))
 			return true;
+		if (parent == root)
+			break;
 	}
 
 	return false;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1fe9f81..471bf94 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1973,7 +1973,7 @@ __shrink_zone(struct zone *zone, struct scan_control *sc, bool soft_reclaim)
 			struct lruvec *lruvec;
 
 			if (soft_reclaim &&
-					!mem_cgroup_soft_reclaim_eligible(memcg)) {
+					!mem_cgroup_soft_reclaim_eligible(memcg, root)) {
 				memcg = mem_cgroup_iter(root, memcg, &reclaim);
 				continue;
 			}
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
