Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 644D86B0098
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 11:16:11 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id u57so822822wes.33
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 08:16:10 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id gk4si22472314wic.6.2014.06.11.08.16.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 08:16:09 -0700 (PDT)
Date: Wed, 11 Jun 2014 11:15:44 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/4] memcg, mm: introduce lowlimit reclaim
Message-ID: <20140611151544.GA22516@cmpxchg.org>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
 <1398688005-26207-2-git-send-email-mhocko@suse.cz>
 <20140430225550.GD26041@cmpxchg.org>
 <20140502093628.GC3446@dhcp22.suse.cz>
 <20140502155805.GO23420@cmpxchg.org>
 <20140502164930.GP3446@dhcp22.suse.cz>
 <20140502220056.GP23420@cmpxchg.org>
 <20140505142100.GC32598@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140505142100.GC32598@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, May 05, 2014 at 04:21:00PM +0200, Michal Hocko wrote:
> On Fri 02-05-14 18:00:56, Johannes Weiner wrote:
> > On Fri, May 02, 2014 at 06:49:30PM +0200, Michal Hocko wrote:
> > > On Fri 02-05-14 11:58:05, Johannes Weiner wrote:
> > > > On Fri, May 02, 2014 at 11:36:28AM +0200, Michal Hocko wrote:
> > > > > On Wed 30-04-14 18:55:50, Johannes Weiner wrote:
> > > > > > On Mon, Apr 28, 2014 at 02:26:42PM +0200, Michal Hocko wrote:
> [...]
> > > > > > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > > > > > index c1cd99a5074b..0f428158254e 100644
> > > > > > > --- a/mm/vmscan.c
> > > > > > > +++ b/mm/vmscan.c
> > > > > [...]
> > > > > > > +static void shrink_zone(struct zone *zone, struct scan_control *sc)
> > > > > > > +{
> > > > > > > +	if (!__shrink_zone(zone, sc, true)) {
> > > > > > > +		/*
> > > > > > > +		 * First round of reclaim didn't find anything to reclaim
> > > > > > > +		 * because of low limit protection so try again and ignore
> > > > > > > +		 * the low limit this time.
> > > > > > > +		 */
> > > > > > > +		__shrink_zone(zone, sc, false);
> > > > > > > +	}
> > > > 
> > > > So I don't think this can work as it is, because we are not actually
> > > > changing priority levels yet. 
> > > 
> > > __shrink_zone returns with 0 only if the whole hierarchy is is under low
> > > limit. This means that they are over-committed and it doesn't make much
> > > sense to play with priority. Low limit reclaimability is independent on
> > > the priority.
> > > 
> > > > It will give up on the guarantees of bigger groups way before smaller
> > > > groups are even seriously looked at.
> > > 
> > > How would that happen? Those (smaller) groups would get reclaimed and we
> > > wouldn't fallback. Or am I missing your point?
> > 
> > Lol, I hadn't updated my brain to a394cb8ee632 ("memcg,vmscan: do not
> > break out targeted reclaim without reclaimed pages") yet...  Yes, you
> > are right.
> 
> You made me think about this more and you are right ;).
> The code as is doesn't cope with many racing reclaimers when some
> threads can fallback to ignore the lowlimit although there are groups to
> scan in the hierarchy but they were visited by other reclaimers.
> The patch bellow should help with that. What do you think?
> I am also thinking we want to add a fallback counter in memory.stat?
> ---
> >From e997b8b4ac724aa29bdeff998d2186ee3c0a97d8 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Mon, 5 May 2014 15:12:18 +0200
> Subject: [PATCH] vmscan: memcg: check whether the low limit should be ignored
> 
> Low-limit (aka guarantee) is ignored when there is no group scanned
> during the first round of __shink_zone. This approach doesn't work when
> multiple reclaimers race and reclaim the same hierarchy (e.g. kswapd
> vs. direct reclaim or multiple tasks hitting the hard limit) because
> memcg iterator makes sure that multiple reclaimers are interleaved
> in the hierarchy. This means that some reclaimers can see 0 scanned
> groups although there are groups which are above the low-limit and they
> were reclaimed on behalf of other reclaimers. This leads to a premature
> low-limit break.
> 
> This patch adds mem_cgroup_all_within_guarantee() which will check
> whether all the groups in the reclaimed hierarchy are within their low
> limit and shrink_zone will allow the fallback reclaim only when that is
> true. This alone is still not sufficient however because it would lead
> to another problem. If a reclaimer constantly fails to scan anything
> because it sees only groups within their guarantees while others do the
> reclaim then the reclaim priority would drop down very quickly.
> shrink_zone has to be careful to preserve scan at least one group
> semantic so __shrink_zone has to be retried until at least one group
> is scanned.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  include/linux/memcontrol.h |  5 +++++
>  mm/memcontrol.c            | 13 +++++++++++++
>  mm/vmscan.c                | 17 ++++++++++++-----
>  3 files changed, 30 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index c00ccc5f70b9..077a777bd9ff 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -94,6 +94,7 @@ bool task_in_mem_cgroup(struct task_struct *task,
>  
>  extern bool mem_cgroup_within_guarantee(struct mem_cgroup *memcg,
>  		struct mem_cgroup *root);
> +extern bool mem_cgroup_all_within_guarantee(struct mem_cgroup *root);
>  
>  extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
>  extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
> @@ -296,6 +297,10 @@ static inline bool mem_cgroup_within_guarantee(struct mem_cgroup *memcg,
>  {
>  	return false;
>  }
> +static inline bool mem_cgroup_all_within_guarantee(struct mem_cgroup *root)
> +{
> +	return false;
> +}
>  
>  static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
>  {
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 58982d18f6ea..4fd4784d1548 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2833,6 +2833,19 @@ bool mem_cgroup_within_guarantee(struct mem_cgroup *memcg,
>  	return false;
>  }
>  
> +bool mem_cgroup_all_within_guarantee(struct mem_cgroup *root)
> +{
> +	struct mem_cgroup *iter;
> +
> +	for_each_mem_cgroup_tree(iter, root)
> +		if (!mem_cgroup_within_guarantee(iter, root)) {
> +			mem_cgroup_iter_break(root, iter);
> +			return false;
> +		}
> +
> +	return true;
> +}
> +
>  struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
>  {
>  	struct mem_cgroup *memcg = NULL;
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 5f923999bb79..2686e47f04cc 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2293,13 +2293,20 @@ static unsigned __shrink_zone(struct zone *zone, struct scan_control *sc,
>  
>  static void shrink_zone(struct zone *zone, struct scan_control *sc)
>  {
> -	if (!__shrink_zone(zone, sc, true)) {
> +	bool honor_guarantee = true;
> +
> +	while (!__shrink_zone(zone, sc, honor_guarantee)) {
>  		/*
> -		 * First round of reclaim didn't find anything to reclaim
> -		 * because of the memory guantees for all memcgs in the
> -		 * reclaim target so try again and ignore guarantees this time.
> +		 * The previous round of reclaim didn't find anything to scan
> +		 * because
> +		 * a) the whole reclaimed hierarchy is within guarantee so
> +		 *    we fallback to ignore the guarantee because other option
> +		 *    would be the OOM
> +		 * b) multiple reclaimers are racing and so the first round
> +		 *    should be retried
>  		 */
> -		__shrink_zone(zone, sc, false);
> +		if (mem_cgroup_all_within_guarantee(sc->target_mem_cgroup))
> +			honor_guarantee = false;
>  	}

I don't like that this adds a non-chalant `for each memcg' here, we
can have a lot of memcgs.  Sooner or later we'll have to break up that
full hierarchy iteration in shrink_zone() because of scalability, I
want to avoid adding more of them.

How about these changes on top of what we currently have?  Sure it's
not as accurate, but it should be good start, and it's a *lot* less
overhead.

mem_cgroup_watermark() is also a more fitting name, given that this
has nothing to do with a guarantee for now.

It can also be easily extended to support the MIN watermark while the
code in vmscan.c remains readable.

---

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index a5cf853129ec..6167bed81d78 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -53,6 +53,11 @@ struct mem_cgroup_reclaim_cookie {
 	unsigned int generation;
 };
 
+enum memcg_watermark {
+	MEMCG_WMARK_NORMAL,
+	MEMCG_WMARK_LOW,
+};
+
 #ifdef CONFIG_MEMCG
 /*
  * All "charge" functions with gfp_mask should use GFP_KERNEL or
@@ -92,9 +97,8 @@ bool __mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
 bool task_in_mem_cgroup(struct task_struct *task,
 			const struct mem_cgroup *memcg);
 
-extern bool mem_cgroup_within_guarantee(struct mem_cgroup *memcg,
-		struct mem_cgroup *root);
-extern bool mem_cgroup_all_within_guarantee(struct mem_cgroup *root);
+enum memcg_watermark mem_cgroup_watermark(struct mem_cgroup *root,
+					  struct mem_cgroup *memcg);
 
 extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
@@ -292,16 +296,6 @@ static inline struct lruvec *mem_cgroup_page_lruvec(struct page *page,
 	return &zone->lruvec;
 }
 
-static inline bool mem_cgroup_within_guarantee(struct mem_cgroup *memcg,
-		struct mem_cgroup *root)
-{
-	return false;
-}
-static inline bool mem_cgroup_all_within_guarantee(struct mem_cgroup *root)
-{
-	return false;
-}
-
 static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 {
 	return NULL;
@@ -319,6 +313,12 @@ static inline bool task_in_mem_cgroup(struct task_struct *task,
 	return true;
 }
 
+static inline enum memcg_watermark
+mem_cgroup_watermark(struct mem_cgroup *root, struct mem_cgroup *memcg)
+{
+	return MEMCG_WMARK_NORMAL;
+}
+
 static inline struct cgroup_subsys_state
 		*mem_cgroup_css(struct mem_cgroup *memcg)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7ff5b8e297fd..8ee8786a286c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2780,44 +2780,20 @@ static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
 	return mem_cgroup_from_id(id);
 }
 
-/**
- * mem_cgroup_within_guarantee - checks whether given memcg is within its
- * memory guarantee
- * @memcg: target memcg for the reclaim
- * @root: root of the reclaim hierarchy (null for the global reclaim)
- *
- * The given group is within its reclaim gurantee if it is below its low limit
- * or the same applies for any parent up the hierarchy until root (including).
- * Such a group might be excluded from the reclaim.
- */
-bool mem_cgroup_within_guarantee(struct mem_cgroup *memcg,
-		struct mem_cgroup *root)
+enum memcg_watermark mem_cgroup_watermark(struct mem_cgroup *root,
+					  struct mem_cgroup *memcg)
 {
 	if (mem_cgroup_disabled())
-		return false;
+		return MEMCG_WMARK_NORMAL;
 
 	do {
 		if (!res_counter_low_limit_excess(&memcg->res))
-			return true;
+			return MEMCG_WMARK_LOW;
 		if (memcg == root)
 			break;
-
 	} while ((memcg = parent_mem_cgroup(memcg)));
 
-	return false;
-}
-
-bool mem_cgroup_all_within_guarantee(struct mem_cgroup *root)
-{
-	struct mem_cgroup *iter;
-
-	for_each_mem_cgroup_tree(iter, root)
-		if (!mem_cgroup_within_guarantee(iter, root)) {
-			mem_cgroup_iter_break(root, iter);
-			return false;
-		}
-
-	return true;
+	return MEMCG_WMARK_NORMAL;
 }
 
 struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b19ebb3a666b..687076b7a1a6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2231,21 +2231,9 @@ static inline bool should_continue_reclaim(struct zone *zone,
 	}
 }
 
-/**
- * __shrink_zone - shrinks a given zone
- *
- * @zone: zone to shrink
- * @sc: scan control with additional reclaim parameters
- * @honor_memcg_guarantee: do not reclaim memcgs which are within their memory
- * guarantee
- *
- * Returns the number of reclaimed memcgs.
- */
-static unsigned __shrink_zone(struct zone *zone, struct scan_control *sc,
-		bool honor_memcg_guarantee)
+static void shrink_zone(struct zone *zone, struct scan_control *sc)
 {
 	unsigned long nr_reclaimed, nr_scanned;
-	unsigned nr_scanned_groups = 0;
 
 	do {
 		struct mem_cgroup *root = sc->target_mem_cgroup;
@@ -2262,20 +2250,22 @@ static unsigned __shrink_zone(struct zone *zone, struct scan_control *sc,
 		do {
 			struct lruvec *lruvec;
 
-			/* Memcg might be protected from the reclaim */
-			if (honor_memcg_guarantee &&
-					mem_cgroup_within_guarantee(memcg, root)) {
+			switch (mem_cgroup_watermark(root, memcg)) {
+			case MEMCG_WMARK_LOW:
 				/*
-				 * It would be more optimal to skip the memcg
-				 * subtree now but we do not have a memcg iter
-				 * helper for that. Anyone?
+				 * Memcg within the configured low
+				 * watermark: try to avoid reclaim
+				 * until the reclaimer struggles.
 				 */
+				if (priority < DEF_PRIORITY - 2)
+					break;
+
+				/* XXX: skip the whole subtree */
 				memcg = mem_cgroup_iter(root, memcg, &reclaim);
 				continue;
 			}
 
 			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
-			nr_scanned_groups++;
 
 			sc->swappiness = mem_cgroup_swappiness(memcg);
 			shrink_lruvec(lruvec, sc);
@@ -2304,27 +2294,6 @@ static unsigned __shrink_zone(struct zone *zone, struct scan_control *sc,
 
 	} while (should_continue_reclaim(zone, sc->nr_reclaimed - nr_reclaimed,
 					 sc->nr_scanned - nr_scanned, sc));
-
-	return nr_scanned_groups;
-}
-
-static void shrink_zone(struct zone *zone, struct scan_control *sc)
-{
-	bool honor_guarantee = true;
-
-	while (!__shrink_zone(zone, sc, honor_guarantee)) {
-		/*
-		 * The previous round of reclaim didn't find anything to scan
-		 * because
-		 * a) the whole reclaimed hierarchy is within guarantee so
-		 *    we fallback to ignore the guarantee because other option
-		 *    would be the OOM
-		 * b) multiple reclaimers are racing and so the first round
-		 *    should be retried
-		 */
-		if (mem_cgroup_all_within_guarantee(sc->target_mem_cgroup))
-			honor_guarantee = false;
-	}
 }
 
 /* Returns true if compaction should go ahead for a high-order request */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
