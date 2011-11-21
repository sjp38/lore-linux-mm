Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A4F646B0069
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 08:37:29 -0500 (EST)
Date: Mon, 21 Nov 2011 13:36:46 +0000
From: Luis Henriques <henrix@camandro.org>
Subject: Re: [patch] mm: memcg: shorten preempt-disabled section around event
 checks
Message-ID: <20111121133646.GC2182@hades>
References: <20111121110954.GE1771@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111121110954.GE1771@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Yong Zhang <yong.zhang0@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Nov 21, 2011 at 12:09:54PM +0100, Johannes Weiner wrote:
> -rt ran into a problem with the soft limit spinlock inside the
> non-preemptible section, because that is sleeping inside an atomic
> context.  But I think it makes sense for vanilla, too, to keep the
> non-preemptible section as short as possible.  Also, -3 lines.
> 
> Yong, Luis, could you add your Tested-bys?

Sure, but note that my tests were actually quite limited ;-)

Tested-by: Luis Henriques <henrix@camandro.org>

> ---
> Only the ratelimit checks themselves have to run with preemption
> disabled, the resulting actions - checking for usage thresholds,
> updating the soft limit tree - can and should run with preemption
> enabled.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> Reported-by: Yong Zhang <yong.zhang0@gmail.com>
> Reported-by: Luis Henriques <henrix@camandro.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
> ---
>  mm/memcontrol.c |   73 ++++++++++++++++++++++++++----------------------------
>  1 files changed, 35 insertions(+), 38 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6aff93c..8e62d3e 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -683,37 +683,32 @@ static unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg,
>  	return total;
>  }
>  
> -static bool __memcg_event_check(struct mem_cgroup *memcg, int target)
> +static bool mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
> +				       enum mem_cgroup_events_target target)
>  {
>  	unsigned long val, next;
>  
>  	val = __this_cpu_read(memcg->stat->events[MEM_CGROUP_EVENTS_COUNT]);
>  	next = __this_cpu_read(memcg->stat->targets[target]);
>  	/* from time_after() in jiffies.h */
> -	return ((long)next - (long)val < 0);
> -}
> -
> -static void __mem_cgroup_target_update(struct mem_cgroup *memcg, int target)
> -{
> -	unsigned long val, next;
> -
> -	val = __this_cpu_read(memcg->stat->events[MEM_CGROUP_EVENTS_COUNT]);
> -
> -	switch (target) {
> -	case MEM_CGROUP_TARGET_THRESH:
> -		next = val + THRESHOLDS_EVENTS_TARGET;
> -		break;
> -	case MEM_CGROUP_TARGET_SOFTLIMIT:
> -		next = val + SOFTLIMIT_EVENTS_TARGET;
> -		break;
> -	case MEM_CGROUP_TARGET_NUMAINFO:
> -		next = val + NUMAINFO_EVENTS_TARGET;
> -		break;
> -	default:
> -		return;
> +	if ((long)next - (long)val < 0) {
> +		switch (target) {
> +		case MEM_CGROUP_TARGET_THRESH:
> +			next = val + THRESHOLDS_EVENTS_TARGET;
> +			break;
> +		case MEM_CGROUP_TARGET_SOFTLIMIT:
> +			next = val + SOFTLIMIT_EVENTS_TARGET;
> +			break;
> +		case MEM_CGROUP_TARGET_NUMAINFO:
> +			next = val + NUMAINFO_EVENTS_TARGET;
> +			break;
> +		default:
> +			break;
> +		}
> +		__this_cpu_write(memcg->stat->targets[target], next);
> +		return true;
>  	}
> -
> -	__this_cpu_write(memcg->stat->targets[target], next);
> +	return false;
>  }
>  
>  /*
> @@ -724,25 +719,27 @@ static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
>  {
>  	preempt_disable();
>  	/* threshold event is triggered in finer grain than soft limit */
> -	if (unlikely(__memcg_event_check(memcg, MEM_CGROUP_TARGET_THRESH))) {
> +	if (unlikely(mem_cgroup_event_ratelimit(memcg,
> +						MEM_CGROUP_TARGET_THRESH))) {
> +		bool do_softlimit, do_numainfo;
> +
> +		do_softlimit = mem_cgroup_event_ratelimit(memcg,
> +						MEM_CGROUP_TARGET_SOFTLIMIT);
> +#if MAX_NUMNODES > 1
> +		do_numainfo = mem_cgroup_event_ratelimit(memcg,
> +						MEM_CGROUP_TARGET_NUMAINFO);
> +#endif
> +		preempt_enable();
> +
>  		mem_cgroup_threshold(memcg);
> -		__mem_cgroup_target_update(memcg, MEM_CGROUP_TARGET_THRESH);
> -		if (unlikely(__memcg_event_check(memcg,
> -			     MEM_CGROUP_TARGET_SOFTLIMIT))) {
> +		if (unlikely(do_softlimit))
>  			mem_cgroup_update_tree(memcg, page);
> -			__mem_cgroup_target_update(memcg,
> -						   MEM_CGROUP_TARGET_SOFTLIMIT);
> -		}
>  #if MAX_NUMNODES > 1
> -		if (unlikely(__memcg_event_check(memcg,
> -			MEM_CGROUP_TARGET_NUMAINFO))) {
> +		if (unlikely(do_numainfo))
>  			atomic_inc(&memcg->numainfo_events);
> -			__mem_cgroup_target_update(memcg,
> -				MEM_CGROUP_TARGET_NUMAINFO);
> -		}
>  #endif
> -	}
> -	preempt_enable();
> +	} else
> +		preempt_enable();
>  }
>  
>  static struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
