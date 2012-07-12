Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 987D46B005C
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 06:18:30 -0400 (EDT)
Date: Thu, 12 Jul 2012 12:18:27 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH RFC] mm/memcg: calculate max hierarchy limit number
 instead of min
Message-ID: <20120712101827.GD21013@tiehlicka.suse.cz>
References: <a>
 <1342013081-4096-1-git-send-email-liwp.linux@gmail.com>
 <20120711134757.GC4820@tiehlicka.suse.cz>
 <20120712093211.GC3181@kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120712093211.GC3181@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 12-07-12 17:32:11, Wanpeng Li wrote:
> On Wed, Jul 11, 2012 at 03:47:57PM +0200, Michal Hocko wrote:
> >On Wed 11-07-12 21:24:41, Wanpeng Li wrote:
> >> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
> >> 
> >> Since hierachical_memory_limit shows "of bytes of memory limit with
> >> regard to hierarchy under which the memory cgroup is", the count should
> >> calculate max hierarchy limit when use_hierarchy in order to show hierarchy
> >> subtree limit. hierachical_memsw_limit is the same case.
> >
> >No the patch is wrong. The hierarchical limit says when we start
> >reclaiming in the hierarchy and that one is triggered on smallest limit
> >up the way to the hierarchy root.
> 
> I see function mem_cgroup_hierachy_reclaim is removal, and hierarchical
> reclaim is still work? 

I am not aware of that.

> Could you explain me how it works in details, thank you for your time
> Michal.

I am not sure I understand what you are interested in. 

> 
> Thanks & Best Regards,
> Wanpeng Li
> >
> >What are you trying to accomplish here?
> >
> >> Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
> >> ---
> >>  mm/memcontrol.c |   14 +++++++-------
> >>  1 files changed, 7 insertions(+), 7 deletions(-)
> >> 
> >> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >> index 69a7d45..6392c0a 100644
> >> --- a/mm/memcontrol.c
> >> +++ b/mm/memcontrol.c
> >> @@ -3929,10 +3929,10 @@ static void memcg_get_hierarchical_limit(struct mem_cgroup *memcg,
> >>  		unsigned long long *mem_limit, unsigned long long *memsw_limit)
> >>  {
> >>  	struct cgroup *cgroup;
> >> -	unsigned long long min_limit, min_memsw_limit, tmp;
> >> +	unsigned long long max_limit, max_memsw_limit, tmp;
> >>  
> >> -	min_limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
> >> -	min_memsw_limit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
> >> +	max_limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
> >> +	max_memsw_limit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
> >>  	cgroup = memcg->css.cgroup;
> >>  	if (!memcg->use_hierarchy)
> >>  		goto out;
> >> @@ -3943,13 +3943,13 @@ static void memcg_get_hierarchical_limit(struct mem_cgroup *memcg,
> >>  		if (!memcg->use_hierarchy)
> >>  			break;
> >>  		tmp = res_counter_read_u64(&memcg->res, RES_LIMIT);
> >> -		min_limit = min(min_limit, tmp);
> >> +		max_limit = max(max_limit, tmp);
> >>  		tmp = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
> >> -		min_memsw_limit = min(min_memsw_limit, tmp);
> >> +		max_memsw_limit = max(max_memsw_limit, tmp);
> >>  	}
> >>  out:
> >> -	*mem_limit = min_limit;
> >> -	*memsw_limit = min_memsw_limit;
> >> +	*mem_limit = max_limit;
> >> +	*memsw_limit = max_memsw_limit;
> >>  }
> >>  
> >>  static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
> >> -- 
> >> 1.7.5.4
> >> 
> >
> >-- 
> >Michal Hocko
> >SUSE Labs
> >SUSE LINUX s.r.o.
> >Lihovarska 1060/12
> >190 00 Praha 9    
> >Czech Republic

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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
