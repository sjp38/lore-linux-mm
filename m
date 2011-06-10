Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C4D2D6B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 07:04:55 -0400 (EDT)
Date: Fri, 10 Jun 2011 13:04:12 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [BUGFIX][PATCH v3] memcg: fix behavior of per cpu charge cache
 draining.
Message-ID: <20110610110412.GE4110@tiehlicka.suse.cz>
References: <20110609093045.1f969d30.kamezawa.hiroyu@jp.fujitsu.com>
 <20110610081218.GC4832@tiehlicka.suse.cz>
 <20110610173958.d9ab901c.kamezawa.hiroyu@jp.fujitsu.com>
 <20110610090802.GB4110@tiehlicka.suse.cz>
 <20110610185952.a07b968f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110610185952.a07b968f.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Ying Han <yinghan@google.com>

On Fri 10-06-11 18:59:52, KAMEZAWA Hiroyuki wrote:
> On Fri, 10 Jun 2011 11:08:02 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Fri 10-06-11 17:39:58, KAMEZAWA Hiroyuki wrote:
> > > On Fri, 10 Jun 2011 10:12:19 +0200
> > > Michal Hocko <mhocko@suse.cz> wrote:
> > > 
> > > > On Thu 09-06-11 09:30:45, KAMEZAWA Hiroyuki wrote:
> > [...]
> > > > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > > > index bd9052a..3baddcb 100644
> > > > > --- a/mm/memcontrol.c
> > > > > +++ b/mm/memcontrol.c
> > > > [...]
> > > > >  static struct mem_cgroup_per_zone *
> > > > >  mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
> > > > > @@ -1670,8 +1670,6 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> > > > >  		victim = mem_cgroup_select_victim(root_mem);
> > > > >  		if (victim == root_mem) {
> > > > >  			loop++;
> > > > > -			if (loop >= 1)
> > > > > -				drain_all_stock_async();
> > > > >  			if (loop >= 2) {
> > > > >  				/*
> > > > >  				 * If we have not been able to reclaim
> > > > > @@ -1723,6 +1721,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
> > > > >  				return total;
> > > > >  		} else if (mem_cgroup_margin(root_mem))
> > > > >  			return total;
> > > > > +		drain_all_stock_async(root_mem);
> > > > >  	}
> > > > >  	return total;
> > > > >  }
> > > > 
> > > > I still think that we pointlessly reclaim even though we could have a
> > > > lot of pages pre-charged in the cache (the more CPUs we have the more
> > > > significant this might be).
> > > 
> > > The more CPUs, the more scan cost for each per-cpu memory, which makes
> > > cache-miss.
> > > 
> > > I know placement of drain_all_stock_async() is not big problem on my host,
> > > which has 2socket/8core cpus. But, assuming 1000+ cpu host, 
> > 
> > Hmm, it really depends what you want to optimize for. Reclaim path is
> > already slow path and cache misses, while not good, are not the most
> > significant issue, I guess.
> > What I would see as a much bigger problem is that there might be a lot
> > of memory pre-charged at those per-cpu caches. Falling into a reclaim
> > costs us much more IMO and we can evict something that could be useful
> > for no good reason.
> > 
> 
> It's waste of time to talk this kind of things without the numbers.
> 
> ok, I don't change the caller's logic. Discuss this when someone gets
> number of LARGE smp box. 

Sounds reasonable.

[..,]
> please test/ack if ok.

see comment bellow.
Reviewed-by: Michal Hocko <mhocko@suse.cz>

[...]
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index bd9052a..75713cb 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -359,7 +359,7 @@ enum charge_type {
>  static void mem_cgroup_get(struct mem_cgroup *mem);
>  static void mem_cgroup_put(struct mem_cgroup *mem);
>  static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
> -static void drain_all_stock_async(void);
> +static void drain_all_stock_async(struct mem_cgroup *mem);
>  
>  static struct mem_cgroup_per_zone *
>  mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
> @@ -1670,8 +1670,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>  		victim = mem_cgroup_select_victim(root_mem);
>  		if (victim == root_mem) {
>  			loop++;
> -			if (loop >= 1)
> -				drain_all_stock_async();
> +			drain_all_stock_async(root_mem);
>  			if (loop >= 2) {
>  				/*
>  				 * If we have not been able to reclaim

This still doesn't prevent from direct reclaim even though we have freed
enough pages from pcp caches. Should I post it as a separate patch?

> @@ -1934,9 +1933,12 @@ struct memcg_stock_pcp {
>  	struct mem_cgroup *cached; /* this never be root cgroup */
>  	unsigned int nr_pages;
>  	struct work_struct work;
> +	unsigned long flags;
> +#define ASYNC_FLUSHING	(0)

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
