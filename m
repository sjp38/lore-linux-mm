Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 98322900138
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 03:46:07 -0400 (EDT)
Date: Thu, 18 Aug 2011 09:46:02 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v5 2/6]  memcg: stop vmscan when enough done.
Message-ID: <20110818074602.GD23056@tiehlicka.suse.cz>
References: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
 <20110809190933.d965888b.kamezawa.hiroyu@jp.fujitsu.com>
 <20110810141425.GC15007@tiehlicka.suse.cz>
 <20110811085252.b29081f1.kamezawa.hiroyu@jp.fujitsu.com>
 <20110811145055.GN8023@tiehlicka.suse.cz>
 <20110817095405.ee3dcd74.kamezawa.hiroyu@jp.fujitsu.com>
 <20110817113550.GA7482@tiehlicka.suse.cz>
 <20110818085233.69dbf23b.kamezawa.hiroyu@jp.fujitsu.com>
 <20110818062722.GB23056@tiehlicka.suse.cz>
 <20110818154259.6b4adf09.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110818154259.6b4adf09.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Thu 18-08-11 15:42:59, KAMEZAWA Hiroyuki wrote:
> On Thu, 18 Aug 2011 08:27:22 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Thu 18-08-11 08:52:33, KAMEZAWA Hiroyuki wrote:
> > > On Wed, 17 Aug 2011 13:35:50 +0200
> > > Michal Hocko <mhocko@suse.cz> wrote:
> > > 
> > > > On Wed 17-08-11 09:54:05, KAMEZAWA Hiroyuki wrote:
> > > > > On Thu, 11 Aug 2011 16:50:55 +0200
> > > > > > - mem_cgroup_force_empty asks for reclaiming all pages. I guess it should be
> > > > > >   OK but will have to think about it some more.
> > > > > 
> > > > > force_empty/rmdir() is allowed to be stopped by Ctrl-C. I think passing res->usage
> > > > > is overkilling.
> > > > 
> > > > So, how many pages should be reclaimed then?
> > > > 
> > > 
> > > How about (1 << (MAX_ORDER-1))/loop ?
> > 
> > Hmm, I am not sure I see any benefit. We want to reclaim all those
> > pages why shouldn't we do it in one batch? If we use a value based on
> > MAX_ORDER then we make a bigger chance that force_empty fails for big
> > cgroups (e.g. with a lot of page cache).
> 
> Why bigger chance to fail ? retry counter is decreased only when we cannot
> make any reclaim. The number passed here is not problem against the faiulre.

Yes, you are right. I have overlooked that.

 
> I don't like very long vmscan which cannot be stopped by Ctrl-C.

Sure, now I see your point. Thanks for clarification.

> > Anyway, if we want to mimic the previous behavior then we should use
> > something like nr_nodes * SWAP_CLUSTER_MAX (the above value would be
> > sufficient for up to 32 nodes).
> > 
> 
> agreed.

Updated patch:
Changes since v1:
- reclaim nr_nodes * SWAP_CLUSTER_MAX in mem_cgroup_force_empty
--- 
From: Michal Hocko <mhocko@suse.cz>
Subject: memcg: add nr_pages argument for hierarchical reclaim

Now that we are doing memcg direct reclaim limited to nr_to_reclaim
pages (introduced by "memcg: stop vmscan when enough done.") we have to
be more careful. Currently we are using SWAP_CLUSTER_MAX which is OK for
most callers but it might cause failures for limit resize or force_empty
code paths on big NUMA machines.

Previously we might have reclaimed up to nr_nodes * SWAP_CLUSTER_MAX
while now we have it at SWAP_CLUSTER_MAX. Both resize and force_empty rely
on reclaiming a certain amount of pages and retrying if their condition is
still not met.

Let's add nr_pages argument to mem_cgroup_hierarchical_reclaim which will
push it further to try_to_free_mem_cgroup_pages. We still fall back to
SWAP_CLUSTER_MAX for small requests so the standard code (hot) paths are not
affected by this.

We have to be careful in mem_cgroup_do_charge and do not provide the
given nr_pages because we would reclaim too much for THP which can
safely fall back to single page allocations.

mem_cgroup_force_empty could try to reclaim all pages at once but it is much
better to limit the nr_pages to something reasonable so that we are able to
terminate it by a signal. Let's mimic previous behavior by asking for
MAX_NUMNODES * SWAP_CLUSTER_MAX.

Signed-off-by: Michal Hocko <mhocko@suse.cz>

Index: linus_tree/include/linux/memcontrol.h
===================================================================
--- linus_tree.orig/include/linux/memcontrol.h	2011-08-18 09:30:24.000000000 +0200
+++ linus_tree/include/linux/memcontrol.h	2011-08-18 09:30:36.000000000 +0200
@@ -130,7 +130,8 @@ extern void mem_cgroup_print_oom_info(st
 
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
 						  gfp_t gfp_mask, bool noswap,
-						  struct memcg_scanrecord *rec);
+						  struct memcg_scanrecord *rec,
+						  unsigned long nr_pages);
 extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						gfp_t gfp_mask, bool noswap,
 						struct zone *zone,
Index: linus_tree/mm/memcontrol.c
===================================================================
--- linus_tree.orig/mm/memcontrol.c	2011-08-18 09:30:34.000000000 +0200
+++ linus_tree/mm/memcontrol.c	2011-08-18 09:36:41.000000000 +0200
@@ -1729,12 +1729,15 @@ static void mem_cgroup_record_scanstat(s
  * (other groups can be removed while we're walking....)
  *
  * If shrink==true, for avoiding to free too much, this returns immedieately.
+ * Given nr_pages tells how many pages are we over the soft limit or how many
+ * pages do we want to reclaim in the direct reclaim mode.
  */
 static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 						struct zone *zone,
 						gfp_t gfp_mask,
 						unsigned long reclaim_options,
-						unsigned long *total_scanned)
+						unsigned long *total_scanned,
+						unsigned long nr_pages)
 {
 	struct mem_cgroup *victim;
 	int ret, total = 0;
@@ -1743,11 +1746,8 @@ static int mem_cgroup_hierarchical_recla
 	bool shrink = reclaim_options & MEM_CGROUP_RECLAIM_SHRINK;
 	bool check_soft = reclaim_options & MEM_CGROUP_RECLAIM_SOFT;
 	struct memcg_scanrecord rec;
-	unsigned long excess;
 	unsigned long scanned;
 
-	excess = res_counter_soft_limit_excess(&root_mem->res) >> PAGE_SHIFT;
-
 	/* If memsw_is_minimum==1, swap-out is of-no-use. */
 	if (!check_soft && !shrink && root_mem->memsw_is_minimum)
 		noswap = true;
@@ -1785,11 +1785,11 @@ static int mem_cgroup_hierarchical_recla
 				}
 				/*
 				 * We want to do more targeted reclaim.
-				 * excess >> 2 is not to excessive so as to
+				 * nr_pages >> 2 is not to excessive so as to
 				 * reclaim too much, nor too less that we keep
 				 * coming back to reclaim from this cgroup
 				 */
-				if (total >= (excess >> 2) ||
+				if (total >= (nr_pages >> 2) ||
 					(loop > MEM_CGROUP_MAX_RECLAIM_LOOPS)) {
 					css_put(&victim->css);
 					break;
@@ -1816,7 +1816,7 @@ static int mem_cgroup_hierarchical_recla
 			*total_scanned += scanned;
 		} else
 			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
-						noswap, &rec);
+						noswap, &rec, nr_pages);
 		mem_cgroup_record_scanstat(&rec);
 		css_put(&victim->css);
 		/*
@@ -2331,8 +2331,14 @@ static int mem_cgroup_do_charge(struct m
 	if (!(gfp_mask & __GFP_WAIT))
 		return CHARGE_WOULDBLOCK;
 
+	/*
+	 * We are lying about nr_pages because we do not want to
+	 * reclaim too much for THP pages which should rather fallback
+	 * to small pages.
+	 */
 	ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
-					      gfp_mask, flags, NULL);
+					      gfp_mask, flags, NULL,
+					      1);
 	if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
 		return CHARGE_RETRY;
 	/*
@@ -3567,7 +3573,8 @@ static int mem_cgroup_resize_limit(struc
 
 		mem_cgroup_hierarchical_reclaim(memcg, NULL, GFP_KERNEL,
 						MEM_CGROUP_RECLAIM_SHRINK,
-						NULL);
+						NULL,
+						(val-memlimit) >> PAGE_SHIFT);
 		curusage = res_counter_read_u64(&memcg->res, RES_USAGE);
 		/* Usage is reduced ? */
   		if (curusage >= oldusage)
@@ -3628,7 +3635,8 @@ static int mem_cgroup_resize_memsw_limit
 		mem_cgroup_hierarchical_reclaim(memcg, NULL, GFP_KERNEL,
 						MEM_CGROUP_RECLAIM_NOSWAP |
 						MEM_CGROUP_RECLAIM_SHRINK,
-						NULL);
+						NULL,
+						(val-memswlimit) >> PAGE_SHIFT);
 		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
 		/* Usage is reduced ? */
 		if (curusage >= oldusage)
@@ -3671,10 +3679,12 @@ unsigned long mem_cgroup_soft_limit_recl
 			break;
 
 		nr_scanned = 0;
+		excess = res_counter_soft_limit_excess(&mz->mem->res);
 		reclaimed = mem_cgroup_hierarchical_reclaim(mz->mem, zone,
 						gfp_mask,
 						MEM_CGROUP_RECLAIM_SOFT,
-						&nr_scanned);
+						&nr_scanned,
+						excess >> PAGE_SHIFT);
 		nr_reclaimed += reclaimed;
 		*total_scanned += nr_scanned;
 		spin_lock(&mctz->lock);
@@ -3870,8 +3880,10 @@ try_to_free:
 		rec.context = SCAN_BY_SHRINK;
 		rec.mem = mem;
 		rec.root = mem;
+		/* reclaim from every node at least something */
 		progress = try_to_free_mem_cgroup_pages(mem, GFP_KERNEL,
-						false, &rec);
+						false, &rec,
+						MAX_NUMNODES * SWAP_CLUSTER_MAX);
 		if (!progress) {
 			nr_retries--;
 			/* maybe some writeback is necessary */
Index: linus_tree/mm/vmscan.c
===================================================================
--- linus_tree.orig/mm/vmscan.c	2011-08-18 09:30:24.000000000 +0200
+++ linus_tree/mm/vmscan.c	2011-08-18 09:30:36.000000000 +0200
@@ -2340,7 +2340,8 @@ unsigned long mem_cgroup_shrink_node_zon
 unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 					   gfp_t gfp_mask,
 					   bool noswap,
-					   struct memcg_scanrecord *rec)
+					   struct memcg_scanrecord *rec,
+					   unsigned long nr_pages)
 {
 	struct zonelist *zonelist;
 	unsigned long nr_reclaimed;
@@ -2350,7 +2351,7 @@ unsigned long try_to_free_mem_cgroup_pag
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
 		.may_swap = !noswap,
-		.nr_to_reclaim = SWAP_CLUSTER_MAX,
+		.nr_to_reclaim = max_t(unsigned long, nr_pages, SWAP_CLUSTER_MAX),
 		.order = 0,
 		.mem_cgroup = mem_cont,
 		.memcg_record = rec,

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
