Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3A0286B00F0
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 20:30:52 -0400 (EDT)
Date: Fri, 22 Jul 2011 09:27:59 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 3/4] memcg: get rid of percpu_charge_mutex lock
Message-Id: <20110722092759.9be9078f.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20110721124223.GE27855@tiehlicka.suse.cz>
References: <cover.1311241300.git.mhocko@suse.cz>
	<2bfb2b7687c1a6b39da2a04689190725075cc4f8.1311241300.git.mhocko@suse.cz>
	<20110721193051.cd3266e5.kamezawa.hiroyu@jp.fujitsu.com>
	<20110721114704.GC27855@tiehlicka.suse.cz>
	<20110721124223.GE27855@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org

On Thu, 21 Jul 2011 14:42:23 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Thu 21-07-11 13:47:04, Michal Hocko wrote:
> > On Thu 21-07-11 19:30:51, KAMEZAWA Hiroyuki wrote:
> > > On Thu, 21 Jul 2011 09:58:24 +0200
> > > Michal Hocko <mhocko@suse.cz> wrote:
> [...]
> > > > --- a/mm/memcontrol.c
> > > > +++ b/mm/memcontrol.c
> > > > @@ -2166,7 +2165,8 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
> > > >  
> > > >  	for_each_online_cpu(cpu) {
> > > >  		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
> > > > -		if (test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
> > > > +		if (root_mem == stock->cached &&
> > > > +				test_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
> > > >  			flush_work(&stock->work);
> > > 
> > > Doesn't this new check handle hierarchy ?
> > > css_is_ancestor() will be required if you do this check.
> > 
> > Yes you are right. Will fix it. I will add a helper for the check.
> 
> Here is the patch with the helper. The above will then read 
> 	if (mem_cgroup_same_or_subtree(root_mem, stock->cached))
> 
I welcome this new helper function, but it can be used in
memcg_oom_wake_function() and mem_cgroup_under_move() too, can't it ?

Thanks,
Daisuke Nishimura.

> ---
> From b963a9f4dac61044daac49700f84b7819d7c2f53 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Thu, 21 Jul 2011 13:54:13 +0200
> Subject: [PATCH] memcg: add mem_cgroup_same_or_subtree helper
> 
> We are checking whether a given two groups are same or at least in the
> same subtree of a hierarchy at several places. Let's make a helper for
> it to make code easier to read.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/memcontrol.c |   29 ++++++++++++++++++-----------
>  1 files changed, 18 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8180cd9..8dbb9d6 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1046,6 +1046,21 @@ void mem_cgroup_move_lists(struct page *page,
>  	mem_cgroup_add_lru_list(page, to);
>  }
>  
> +/*
> + * Checks whether given mem is same or in the root_mem's
> + * hierarchy subtree
> + */
> +static bool mem_cgroup_same_or_subtree(const struct mem_cgroup *root_mem,
> +		struct mem_cgroup *mem)
> +{
> +	if (root_mem != mem) {
> +		return (root_mem->use_hierarchy &&
> +			css_is_ancestor(&mem->css, &root_mem->css));
> +	}
> +
> +	return true;
> +}
> +
>  int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
>  {
>  	int ret;
> @@ -1065,10 +1080,7 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
>  	 * enabled in "curr" and "curr" is a child of "mem" in *cgroup*
>  	 * hierarchy(even if use_hierarchy is disabled in "mem").
>  	 */
> -	if (mem->use_hierarchy)
> -		ret = css_is_ancestor(&curr->css, &mem->css);
> -	else
> -		ret = (curr == mem);
> +	ret = mem_cgroup_same_or_subtree(mem, curr);
>  	css_put(&curr->css);
>  	return ret;
>  }
> @@ -2150,13 +2162,8 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
>  		mem = stock->cached;
>  		if (!mem || !stock->nr_pages)
>  			continue;
> -		if (mem != root_mem) {
> -			if (!root_mem->use_hierarchy)
> -				continue;
> -			/* check whether "mem" is under tree of "root_mem" */
> -			if (!css_is_ancestor(&mem->css, &root_mem->css))
> -				continue;
> -		}
> +		if (!mem_cgroup_same_or_subtree(root_mem, mem))
> +			continue;
>  		if (!test_and_set_bit(FLUSHING_CACHED_CHARGE, &stock->flags))
>  			schedule_work_on(cpu, &stock->work);
>  	}
> -- 
> 1.7.5.4
> 
> 
> -- 
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9    
> Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
