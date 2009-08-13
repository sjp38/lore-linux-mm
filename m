Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7E18F6B004F
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 08:25:32 -0400 (EDT)
Date: Thu, 13 Aug 2009 20:12:17 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [UPDATED][PATCH][mmotm] Help Root Memory Cgroup Resource
 Counters Scale Better (v5)
Message-Id: <20090813201217.9b06de1f.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20090813080206.GH5087@balbir.in.ibm.com>
References: <20090813065504.GG5087@balbir.in.ibm.com>
	<20090813162640.fe2349e9.nishimura@mxp.nes.nec.co.jp>
	<20090813080206.GH5087@balbir.in.ibm.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "menage@google.com" <menage@google.com>, xemul@openvz.org, prarit@redhat.com, andi.kleen@intel.com, d-nishimura@mtf.biglobe.ne.jp, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 13 Aug 2009 13:32:06 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2009-08-13 16:26:40]:
> 
> > > @@ -1855,9 +1883,14 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
> > >  		break;
> > >  	}
> > >  
> > > -	res_counter_uncharge(&mem->res, PAGE_SIZE, &soft_limit_excess);
> > > -	if (do_swap_account && (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT))
> > > -		res_counter_uncharge(&mem->memsw, PAGE_SIZE, NULL);
> > > +	if (!mem_cgroup_is_root(mem)) {
> > > +		res_counter_uncharge(&mem->res, PAGE_SIZE, &soft_limit_excess);
> > > +		if (do_swap_account &&
> > > +				(ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT))
> > > +			res_counter_uncharge(&mem->memsw, PAGE_SIZE, NULL);
> > > +	}
> > > +	if (ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT && mem_cgroup_is_root(mem))
> > > +		mem_cgroup_swap_statistics(mem, true);
> > Hmm, if we don't count MEM_CGROUP_STAT_SWAPOUT properly about other groups than the root,
> > memsw.usage_in_bytes of the root would be incorrect in use_hierarchy==1 case, right?
> >
> 
> 
> OK, does this look better
> 
Looks good to me.

	Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Thanks,
Daisuke Nishimura.

>  
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> Enhancement: Remove the overhead of root based resource counter accounting
> 
> This patch reduces the resource counter overhead (mostly spinlock)
> associated with the root cgroup. This is a part of the several
> patches to reduce mem cgroup overhead. I had posted other
> approaches earlier (including using percpu counters). Those
> patches will be a natural addition and will be added iteratively
> on top of these.
> 
> The patch stops resource counter accounting for the root cgroup.
> The data for display is derived from the statisitcs we maintain
> via mem_cgroup_charge_statistics (which is more scalable).
> What happens today is that, we do double accounting, once using
> res_counter_charge() and once using memory_cgroup_charge_statistics().
> For the root, since we don't implement limits any more, we don't
> need to track every charge via res_counter_charge() and check
> for limit being exceeded and reclaim.
> 
> The main mem->res usage_in_bytes can be derived by summing
> the cache and rss usage data from memory statistics
> (MEM_CGROUP_STAT_RSS and MEM_CGROUP_STAT_CACHE). However, for
> memsw->res usage_in_bytes, we need additional data about
> swapped out memory. This patch adds a MEM_CGROUP_STAT_SWAPOUT
> and uses that along with MEM_CGROUP_STAT_RSS and MEM_CGROUP_STAT_CACHE
> to derive the memsw data. This data is computed recursively
> when hierarchy is enabled.
> 
> The tests results I see on a 24 way show that
> 
> 1. The lock contention disappears from /proc/lock_stats
> 2. The results of the test are comparable to running with
>    cgroup_disable=memory.
> 
> Here is a sample of my program runs
> 
> Without Patch
> 
>  Performance counter stats for '/home/balbir/parallel_pagefault':
> 
>  7192804.124144  task-clock-msecs         #     23.937 CPUs
>          424691  context-switches         #      0.000 M/sec
>             267  CPU-migrations           #      0.000 M/sec
>        28498113  page-faults              #      0.004 M/sec
>   5826093739340  cycles                   #    809.989 M/sec
>    408883496292  instructions             #      0.070 IPC
>      7057079452  cache-references         #      0.981 M/sec
>      3036086243  cache-misses             #      0.422 M/sec
> 
>   300.485365680  seconds time elapsed
> 
> With cgroup_disable=memory
> 
>  Performance counter stats for '/home/balbir/parallel_pagefault':
> 
>  7182183.546587  task-clock-msecs         #     23.915 CPUs
>          425458  context-switches         #      0.000 M/sec
>             203  CPU-migrations           #      0.000 M/sec
>        92545093  page-faults              #      0.013 M/sec
>   6034363609986  cycles                   #    840.185 M/sec
>    437204346785  instructions             #      0.072 IPC
>      6636073192  cache-references         #      0.924 M/sec
>      2358117732  cache-misses             #      0.328 M/sec
> 
>   300.320905827  seconds time elapsed
> 
> With this patch applied
> 
>  Performance counter stats for '/home/balbir/parallel_pagefault':
> 
>  7191619.223977  task-clock-msecs         #     23.955 CPUs
>          422579  context-switches         #      0.000 M/sec
>              88  CPU-migrations           #      0.000 M/sec
>        91946060  page-faults              #      0.013 M/sec
>   5957054385619  cycles                   #    828.333 M/sec
>   1058117350365  instructions             #      0.178 IPC
>      9161776218  cache-references         #      1.274 M/sec
>      1920494280  cache-misses             #      0.267 M/sec
> 
>   300.218764862  seconds time elapsed
> 
> 
> Data from Prarit (kernel compile with make -j64 on a 64
> CPU/32G machine)
> 
> For a single run
> 
> Without patch
> 
> real 27m8.988s
> user 87m24.916s
> sys 382m6.037s
> 
> With patch
> 
> real    4m18.607s
> user    84m58.943s
> sys     50m52.682s
> 
> 
> With config turned off
> 
> real    4m54.972s
> user    90m13.456s
> sys     50m19.711s
> 
> NOTE: The data looks counterintuitive due to the increased performance
> with the patch, even over the config being turned off. We probably need
> more runs, but so far all testing has shown that the patches definitely
> help.
> 
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> 
>  mm/memcontrol.c |  119 ++++++++++++++++++++++++++++++++++++++++++++++---------
>  1 files changed, 99 insertions(+), 20 deletions(-)
> 
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 48a38e1..36a8b6d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -70,6 +70,7 @@ enum mem_cgroup_stat_index {
>  	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
>  	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
>  	MEM_CGROUP_STAT_EVENTS,	/* sum of pagein + pageout for internal use */
> +	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
>  
>  	MEM_CGROUP_STAT_NSTATS,
>  };
> @@ -478,6 +479,19 @@ mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mctz)
>  	return mz;
>  }
>  
> +static void mem_cgroup_swap_statistics(struct mem_cgroup *mem,
> +					 bool charge)
> +{
> +	int val = (charge) ? 1 : -1;
> +	struct mem_cgroup_stat *stat = &mem->stat;
> +	struct mem_cgroup_stat_cpu *cpustat;
> +	int cpu = get_cpu();
> +
> +	cpustat = &stat->cpustat[cpu];
> +	__mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_SWAPOUT, val);
> +	put_cpu();
> +}
> +
>  static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
>  					 struct page_cgroup *pc,
>  					 bool charge)
> @@ -1281,9 +1295,11 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  	VM_BUG_ON(css_is_removed(&mem->css));
>  
>  	while (1) {
> -		int ret;
> +		int ret = 0;
>  		unsigned long flags = 0;
>  
> +		if (mem_cgroup_is_root(mem))
> +			goto done;
>  		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res,
>  						&soft_fail_res);
>  		if (likely(!ret)) {
> @@ -1343,6 +1359,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  		if (mem_cgroup_soft_limit_check(mem_over_soft_limit))
>  			mem_cgroup_update_tree(mem_over_soft_limit, page);
>  	}
> +done:
>  	return 0;
>  nomem:
>  	css_put(&mem->css);
> @@ -1415,9 +1432,12 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
>  	lock_page_cgroup(pc);
>  	if (unlikely(PageCgroupUsed(pc))) {
>  		unlock_page_cgroup(pc);
> -		res_counter_uncharge(&mem->res, PAGE_SIZE, NULL);
> -		if (do_swap_account)
> -			res_counter_uncharge(&mem->memsw, PAGE_SIZE, NULL);
> +		if (!mem_cgroup_is_root(mem)) {
> +			res_counter_uncharge(&mem->res, PAGE_SIZE, NULL);
> +			if (do_swap_account)
> +				res_counter_uncharge(&mem->memsw, PAGE_SIZE,
> +							NULL);
> +		}
>  		css_put(&mem->css);
>  		return;
>  	}
> @@ -1494,7 +1514,8 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
>  	if (pc->mem_cgroup != from)
>  		goto out;
>  
> -	res_counter_uncharge(&from->res, PAGE_SIZE, NULL);
> +	if (!mem_cgroup_is_root(from))
> +		res_counter_uncharge(&from->res, PAGE_SIZE, NULL);
>  	mem_cgroup_charge_statistics(from, pc, false);
>  
>  	page = pc->page;
> @@ -1513,7 +1534,7 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
>  						1);
>  	}
>  
> -	if (do_swap_account)
> +	if (do_swap_account && !mem_cgroup_is_root(from))
>  		res_counter_uncharge(&from->memsw, PAGE_SIZE, NULL);
>  	css_put(&from->css);
>  
> @@ -1584,9 +1605,11 @@ uncharge:
>  	/* drop extra refcnt by try_charge() */
>  	css_put(&parent->css);
>  	/* uncharge if move fails */
> -	res_counter_uncharge(&parent->res, PAGE_SIZE, NULL);
> -	if (do_swap_account)
> -		res_counter_uncharge(&parent->memsw, PAGE_SIZE, NULL);
> +	if (!mem_cgroup_is_root(parent)) {
> +		res_counter_uncharge(&parent->res, PAGE_SIZE, NULL);
> +		if (do_swap_account)
> +			res_counter_uncharge(&parent->memsw, PAGE_SIZE, NULL);
> +	}
>  	return ret;
>  }
>  
> @@ -1775,7 +1798,10 @@ __mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
>  			 * This recorded memcg can be obsolete one. So, avoid
>  			 * calling css_tryget
>  			 */
> -			res_counter_uncharge(&memcg->memsw, PAGE_SIZE, NULL);
> +			if (!mem_cgroup_is_root(memcg))
> +				res_counter_uncharge(&memcg->memsw, PAGE_SIZE,
> +							NULL);
> +			mem_cgroup_swap_statistics(memcg, false);
>  			mem_cgroup_put(memcg);
>  		}
>  		rcu_read_unlock();
> @@ -1800,9 +1826,11 @@ void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *mem)
>  		return;
>  	if (!mem)
>  		return;
> -	res_counter_uncharge(&mem->res, PAGE_SIZE, NULL);
> -	if (do_swap_account)
> -		res_counter_uncharge(&mem->memsw, PAGE_SIZE, NULL);
> +	if (!mem_cgroup_is_root(mem)) {
> +		res_counter_uncharge(&mem->res, PAGE_SIZE, NULL);
> +		if (do_swap_account)
> +			res_counter_uncharge(&mem->memsw, PAGE_SIZE, NULL);
> +	}
>  	css_put(&mem->css);
>  }
>  
> @@ -1855,9 +1883,14 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>  		break;
>  	}
>  
> -	res_counter_uncharge(&mem->res, PAGE_SIZE, &soft_limit_excess);
> -	if (do_swap_account && (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT))
> -		res_counter_uncharge(&mem->memsw, PAGE_SIZE, NULL);
> +	if (!mem_cgroup_is_root(mem)) {
> +		res_counter_uncharge(&mem->res, PAGE_SIZE, &soft_limit_excess);
> +		if (do_swap_account &&
> +				(ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT))
> +			res_counter_uncharge(&mem->memsw, PAGE_SIZE, NULL);
> +	}
> +	if (ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
> +		mem_cgroup_swap_statistics(mem, true);
>  	mem_cgroup_charge_statistics(mem, pc, false);
>  
>  	ClearPageCgroupUsed(pc);
> @@ -1948,7 +1981,9 @@ void mem_cgroup_uncharge_swap(swp_entry_t ent)
>  		 * We uncharge this because swap is freed.
>  		 * This memcg can be obsolete one. We avoid calling css_tryget
>  		 */
> -		res_counter_uncharge(&memcg->memsw, PAGE_SIZE, NULL);
> +		if (!mem_cgroup_is_root(memcg))
> +			res_counter_uncharge(&memcg->memsw, PAGE_SIZE, NULL);
> +		mem_cgroup_swap_statistics(memcg, false);
>  		mem_cgroup_put(memcg);
>  	}
>  	rcu_read_unlock();
> @@ -2451,20 +2486,64 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
>  	return retval;
>  }
>  
> +struct mem_cgroup_idx_data {
> +	s64 val;
> +	enum mem_cgroup_stat_index idx;
> +};
> +
> +static int
> +mem_cgroup_get_idx_stat(struct mem_cgroup *mem, void *data)
> +{
> +	struct mem_cgroup_idx_data *d = data;
> +	d->val += mem_cgroup_read_stat(&mem->stat, d->idx);
> +	return 0;
> +}
> +
> +static void
> +mem_cgroup_get_recursive_idx_stat(struct mem_cgroup *mem,
> +				enum mem_cgroup_stat_index idx, s64 *val)
> +{
> +	struct mem_cgroup_idx_data d;
> +	d.idx = idx;
> +	d.val = 0;
> +	mem_cgroup_walk_tree(mem, &d, mem_cgroup_get_idx_stat);
> +	*val = d.val;
> +}
> +
>  static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
>  {
>  	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
> -	u64 val = 0;
> +	u64 idx_val, val;
>  	int type, name;
>  
>  	type = MEMFILE_TYPE(cft->private);
>  	name = MEMFILE_ATTR(cft->private);
>  	switch (type) {
>  	case _MEM:
> -		val = res_counter_read_u64(&mem->res, name);
> +		if (name == RES_USAGE && mem_cgroup_is_root(mem)) {
> +			mem_cgroup_get_recursive_idx_stat(mem,
> +				MEM_CGROUP_STAT_CACHE, &idx_val);
> +			val = idx_val;
> +			mem_cgroup_get_recursive_idx_stat(mem,
> +				MEM_CGROUP_STAT_RSS, &idx_val);
> +			val += idx_val;
> +			val <<= PAGE_SHIFT;
> +		} else
> +			val = res_counter_read_u64(&mem->res, name);
>  		break;
>  	case _MEMSWAP:
> -		val = res_counter_read_u64(&mem->memsw, name);
> +		if (name == RES_USAGE && mem_cgroup_is_root(mem)) {
> +			mem_cgroup_get_recursive_idx_stat(mem,
> +				MEM_CGROUP_STAT_CACHE, &idx_val);
> +			val = idx_val;
> +			mem_cgroup_get_recursive_idx_stat(mem,
> +				MEM_CGROUP_STAT_RSS, &idx_val);
> +			val += idx_val;
> +			mem_cgroup_get_recursive_idx_stat(mem,
> +				MEM_CGROUP_STAT_SWAPOUT, &idx_val);
> +			val <<= PAGE_SHIFT;
> +		} else
> +			val = res_counter_read_u64(&mem->memsw, name);
>  		break;
>  	default:
>  		BUG();
> 
> -- 
> 	Balbir
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
