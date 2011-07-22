Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id D29076B004A
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 05:41:29 -0400 (EDT)
Date: Fri, 22 Jul 2011 11:41:26 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/4] memcg: get rid of percpu_charge_mutex lock
Message-ID: <20110722094126.GD4004@tiehlicka.suse.cz>
References: <cover.1311241300.git.mhocko@suse.cz>
 <2bfb2b7687c1a6b39da2a04689190725075cc4f8.1311241300.git.mhocko@suse.cz>
 <20110721193051.cd3266e5.kamezawa.hiroyu@jp.fujitsu.com>
 <20110721114704.GC27855@tiehlicka.suse.cz>
 <20110721124223.GE27855@tiehlicka.suse.cz>
 <20110722092759.9be9078f.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110722092759.9be9078f.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org

On Fri 22-07-11 09:27:59, Daisuke Nishimura wrote:
> On Thu, 21 Jul 2011 14:42:23 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Thu 21-07-11 13:47:04, Michal Hocko wrote:
> > > On Thu 21-07-11 19:30:51, KAMEZAWA Hiroyuki wrote:
> > > > On Thu, 21 Jul 2011 09:58:24 +0200
> > > > Michal Hocko <mhocko@suse.cz> wrote:
> > [...]
> > > > > --- a/mm/memcontrol.c
> > > > > +++ b/mm/memcontrol.c
> > > > > @@ -2166,7 +2165,8 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
> > > > >  
> > > > >  	for_each_online_cpu(cpu) {
> > > > >  		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
> > > > > -		if (test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
> > > > > +		if (root_mem == stock->cached &&
> > > > > +				test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
> > > > >  			flush_work(&stock->work);
> > > > 
> > > > Doesn't this new check handle hierarchy ?
> > > > css_is_ancestor() will be required if you do this check.
> > > 
> > > Yes you are right. Will fix it. I will add a helper for the check.
> > 
> > Here is the patch with the helper. The above will then read 
> > 	if (mem_cgroup_same_or_subtree(root_mem, stock->cached))
> > 
> I welcome this new helper function, but it can be used in
> memcg_oom_wake_function() and mem_cgroup_under_move() too, can't it ?

Sure. Incremental patch (I will fold it into the one above):
--- 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8dbb9d6..64569c7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1416,10 +1416,9 @@ static bool mem_cgroup_under_move(struct mem_cgroup *mem)
 	to = mc.to;
 	if (!from)
 		goto unlock;
-	if (from == mem || to == mem
-	    || (mem->use_hierarchy && css_is_ancestor(&from->css, &mem->css))
-	    || (mem->use_hierarchy && css_is_ancestor(&to->css,	&mem->css)))
-		ret = true;
+
+	ret = mem_cgroup_same_or_subtree(mem, from)
+		|| mem_cgroup_same_or_subtree(mem, to);
 unlock:
 	spin_unlock(&mc.lock);
 	return ret;
@@ -1906,25 +1905,20 @@ struct oom_wait_info {
 static int memcg_oom_wake_function(wait_queue_t *wait,
 	unsigned mode, int sync, void *arg)
 {
-	struct mem_cgroup *wake_mem = (struct mem_cgroup *)arg;
+	struct mem_cgroup *wake_mem = (struct mem_cgroup *)arg,
+			  *oom_wait_mem;
 	struct oom_wait_info *oom_wait_info;
 
 	oom_wait_info = container_of(wait, struct oom_wait_info, wait);
+	oom_wait_mem = oom_wait_info->mem;
 
-	if (oom_wait_info->mem == wake_mem)
-		goto wakeup;
-	/* if no hierarchy, no match */
-	if (!oom_wait_info->mem->use_hierarchy || !wake_mem->use_hierarchy)
-		return 0;
 	/*
 	 * Both of oom_wait_info->mem and wake_mem are stable under us.
 	 * Then we can use css_is_ancestor without taking care of RCU.
 	 */
-	if (!css_is_ancestor(&oom_wait_info->mem->css, &wake_mem->css) &&
-	    !css_is_ancestor(&wake_mem->css, &oom_wait_info->mem->css))
+	if (!mem_cgroup_same_or_subtree(oom_wait_mem, wake_mem)
+			&& !mem_cgroup_same_or_subtree(wake_mem, oom_wait_mem))
 		return 0;
-
-wakeup:
 	return autoremove_wake_function(wait, mode, sync, arg);
 }
 
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
