Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 9F8E56B0072
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 02:07:31 -0500 (EST)
Date: Tue, 20 Nov 2012 08:07:28 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, memcg: avoid unnecessary function call when memcg is
 disabled
Message-ID: <20121120070728.GA7754@dhcp22.suse.cz>
References: <alpine.DEB.2.00.1211191741060.24618@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1211191741060.24618@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

On Mon 19-11-12 17:44:34, David Rientjes wrote:
> While profiling numa/core v16 with cgroup_disable=memory on the command 
> line, I noticed mem_cgroup_count_vm_event() still showed up as high as 
> 0.60% in perftop.
> 
> This occurs because the function is called extremely often even when memcg 
> is disabled.
> 
> To fix this, inline the check for mem_cgroup_disabled() so we avoid the 
> unnecessary function call if memcg is disabled.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> ---
>  include/linux/memcontrol.h |    9 ++++++++-
>  mm/memcontrol.c            |    9 ++++-----
>  2 files changed, 12 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -181,7 +181,14 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>  						gfp_t gfp_mask,
>  						unsigned long *total_scanned);
>  
> -void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
> +void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
> +static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
> +					     enum vm_event_item idx)
> +{
> +	if (mem_cgroup_disabled() || !mm)
> +		return;
> +	__mem_cgroup_count_vm_event(mm, idx);
> +}
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  void mem_cgroup_split_huge_fixup(struct page *head);
>  #endif
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -59,6 +59,8 @@
>  #include <trace/events/vmscan.h>
>  
>  struct cgroup_subsys mem_cgroup_subsys __read_mostly;
> +EXPORT_SYMBOL(mem_cgroup_subsys);
> +
>  #define MEM_CGROUP_RECLAIM_RETRIES	5
>  static struct mem_cgroup *root_mem_cgroup __read_mostly;
>  
> @@ -1015,13 +1017,10 @@ void mem_cgroup_iter_break(struct mem_cgroup *root,
>  	     iter != NULL;				\
>  	     iter = mem_cgroup_iter(NULL, iter, NULL))
>  
> -void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
> +void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
>  {
>  	struct mem_cgroup *memcg;
>  
> -	if (!mm)
> -		return;
> -
>  	rcu_read_lock();
>  	memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
>  	if (unlikely(!memcg))
> @@ -1040,7 +1039,7 @@ void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
>  out:
>  	rcu_read_unlock();
>  }
> -EXPORT_SYMBOL(mem_cgroup_count_vm_event);
> +EXPORT_SYMBOL(__mem_cgroup_count_vm_event);
>  
>  /**
>   * mem_cgroup_zone_lruvec - get the lru list vector for a zone and memcg
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
