Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D2F296B0047
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 06:46:04 -0500 (EST)
Date: Fri, 12 Feb 2010 20:48:10 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [PATCH 2/2] memcg : share event counter rather than duplicate
 v2
Message-Id: <20100212204810.704f90f0.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20100212180952.28b2f6c5.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100212154422.58bfdc4d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100212180508.eb58a4d1.kamezawa.hiroyu@jp.fujitsu.com>
	<20100212180952.28b2f6c5.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 12 Feb 2010 18:09:52 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Memcg has 2 eventcountes which counts "the same" event. Just usages are
> different from each other. This patch tries to reduce event counter.
> 
> Now logic uses "only increment, no reset" counter and masks for each
> checks. Softlimit chesk was done per 1000 evetns. So, the similar check
> can be done by !(new_counter & 0x3ff). Threshold check was done per 100
> events. So, the similar check can be done by (!new_counter & 0x7f)
> 
> ALL event checks are done right after EVENT percpu counter is updated.
> 
> Changelog: 2010/02/12
>  - fixed to use "inc" rather than "dec"
>  - modified to be more unified style of counter handling.
>  - taking care of account-move.
> 
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |   86 ++++++++++++++++++++++++++------------------------------
>  1 file changed, 41 insertions(+), 45 deletions(-)
> 
> Index: mmotm-2.6.33-Feb10/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.33-Feb10.orig/mm/memcontrol.c
> +++ mmotm-2.6.33-Feb10/mm/memcontrol.c
> @@ -63,8 +63,15 @@ static int really_do_swap_account __init
>  #define do_swap_account		(0)
>  #endif
>  
> -#define SOFTLIMIT_EVENTS_THRESH (1000)
> -#define THRESHOLDS_EVENTS_THRESH (100)
> +/*
> + * Per memcg event counter is incremented at every pagein/pageout. This counter
> + * is used for trigger some periodic events. This is straightforward and better
> + * than using jiffies etc. to handle periodic memcg event.
> + *
> + * These values will be used as !((event) & ((1 <<(thresh)) - 1))
> + */
> +#define THRESHOLDS_EVENTS_THRESH (7) /* once in 128 */
> +#define SOFTLIMIT_EVENTS_THRESH (10) /* once in 1024 */
>  
>  /*
>   * Statistics for memory cgroup.
> @@ -79,10 +86,7 @@ enum mem_cgroup_stat_index {
>  	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
>  	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
>  	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> -	MEM_CGROUP_STAT_SOFTLIMIT, /* decrements on each page in/out.
> -					used by soft limit implementation */
> -	MEM_CGROUP_STAT_THRESHOLDS, /* decrements on each page in/out.
> -					used by threshold implementation */
> +	MEM_CGROUP_EVENTS,	/* incremented at every  pagein/pageout */
>  
>  	MEM_CGROUP_STAT_NSTATS,
>  };
> @@ -154,7 +158,6 @@ struct mem_cgroup_threshold_ary {
>  	struct mem_cgroup_threshold entries[0];
>  };
>  
> -static bool mem_cgroup_threshold_check(struct mem_cgroup *mem);
>  static void mem_cgroup_threshold(struct mem_cgroup *mem);
>  
>  /*
> @@ -392,19 +395,6 @@ mem_cgroup_remove_exceeded(struct mem_cg
>  	spin_unlock(&mctz->lock);
>  }
>  
> -static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem)
> -{
> -	bool ret = false;
> -	s64 val;
> -
> -	val = this_cpu_read(mem->stat->count[MEM_CGROUP_STAT_SOFTLIMIT]);
> -	if (unlikely(val < 0)) {
> -		this_cpu_write(mem->stat->count[MEM_CGROUP_STAT_SOFTLIMIT],
> -				SOFTLIMIT_EVENTS_THRESH);
> -		ret = true;
> -	}
> -	return ret;
> -}
>  
>  static void mem_cgroup_update_tree(struct mem_cgroup *mem, struct page *page)
>  {
> @@ -542,8 +532,7 @@ static void mem_cgroup_charge_statistics
>  		__this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_PGPGIN_COUNT]);
>  	else
>  		__this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_PGPGOUT_COUNT]);
> -	__this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_SOFTLIMIT]);
> -	__this_cpu_dec(mem->stat->count[MEM_CGROUP_STAT_THRESHOLDS]);
> +	__this_cpu_inc(mem->stat->count[MEM_CGROUP_EVENTS]);
>  
>  	preempt_enable();
>  }
> @@ -563,6 +552,29 @@ static unsigned long mem_cgroup_get_loca
>  	return total;
>  }
>  
> +static bool __memcg_event_check(struct mem_cgroup *mem, int event_mask_shift)
> +{
> +	s64 val;
> +
> +	val = this_cpu_read(mem->stat->count[MEM_CGROUP_EVENTS]);
> +
> +	return !(val & ((1 << event_mask_shift) - 1));
> +}
> +
> +/*
> + * Check events in order.
> + *
> + */
> +static void memcg_check_events(struct mem_cgroup *mem, struct page *page)
> +{
> +	/* threshold event is triggered in finer grain than soft limit */
> +	if (unlikely(__memcg_event_check(mem, THRESHOLDS_EVENTS_THRESH))) {
> +		mem_cgroup_threshold(mem);
> +		if (unlikely(__memcg_event_check(mem, SOFTLIMIT_EVENTS_THRESH)))
> +			mem_cgroup_update_tree(mem, page);
> +	}
> +}
> +
>  static struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
>  {
>  	return container_of(cgroup_subsys_state(cont,
> @@ -1686,11 +1698,7 @@ static void __mem_cgroup_commit_charge(s
>  	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
>  	 * if they exceeds softlimit.
>  	 */
> -	if (mem_cgroup_soft_limit_check(mem))
> -		mem_cgroup_update_tree(mem, pc->page);
> -	if (mem_cgroup_threshold_check(mem))
> -		mem_cgroup_threshold(mem);
> -
> +	memcg_check_events(mem, pc->page);
>  }
>  
>  /**
> @@ -1760,6 +1768,11 @@ static int mem_cgroup_move_account(struc
>  		ret = 0;
>  	}
>  	unlock_page_cgroup(pc);
> +	/*
> +	 * check events
> +	 */
> +	memcg_check_events(to, pc->page);
> +	memcg_check_events(from, pc->page);
>  	return ret;
>  }
>  
Strictly speaking, "if (!ret)" would be needed(it's not a big deal, though).

Thanks,
Daisuke Nishimura.

> @@ -2128,10 +2141,7 @@ __mem_cgroup_uncharge_common(struct page
>  	mz = page_cgroup_zoneinfo(pc);
>  	unlock_page_cgroup(pc);
>  
> -	if (mem_cgroup_soft_limit_check(mem))
> -		mem_cgroup_update_tree(mem, page);
> -	if (mem_cgroup_threshold_check(mem))
> -		mem_cgroup_threshold(mem);
> +	memcg_check_events(mem, page);
>  	/* at swapout, this memcg will be accessed to record to swap */
>  	if (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
>  		css_put(&mem->css);
> @@ -3207,20 +3217,6 @@ static int mem_cgroup_swappiness_write(s
>  	return 0;
>  }
>  
> -static bool mem_cgroup_threshold_check(struct mem_cgroup *mem)
> -{
> -	bool ret = false;
> -	s64 val;
> -
> -	val = this_cpu_read(mem->stat->count[MEM_CGROUP_STAT_THRESHOLDS]);
> -	if (unlikely(val < 0)) {
> -		this_cpu_write(mem->stat->count[MEM_CGROUP_STAT_THRESHOLDS],
> -				THRESHOLDS_EVENTS_THRESH);
> -		ret = true;
> -	}
> -	return ret;
> -}
> -
>  static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
>  {
>  	struct mem_cgroup_threshold_ary *t;
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
