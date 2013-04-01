Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 128326B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 04:32:02 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0C3203EE0AE
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 17:32:01 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E0C9245DE57
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 17:32:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C515C45DE51
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 17:32:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AFAB11DB8041
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 17:32:00 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 55FEA1DB8037
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 17:32:00 +0900 (JST)
Message-ID: <515945E3.9090809@jp.fujitsu.com>
Date: Mon, 01 Apr 2013 17:31:31 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 26/28] memcg: per-memcg kmem shrinking
References: <1364548450-28254-1-git-send-email-glommer@parallels.com> <1364548450-28254-27-git-send-email-glommer@parallels.com>
In-Reply-To: <1364548450-28254-27-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Dave Chinner <dchinner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

(2013/03/29 18:14), Glauber Costa wrote:
> If the kernel limit is smaller than the user limit, we will have
> situations in which our allocations fail but freeing user pages will buy
> us nothing.  In those, we would like to call a specialized memcg
> reclaimer that only frees kernel memory and leave the user memory alone.
> Those are also expected to fail when we account memcg->kmem, instead of
> when we account memcg->res. Based on that, this patch implements a
> memcg-specific reclaimer, that only shrinks kernel objects, withouth
> touching user pages.
> 
> There might be situations in which there are plenty of objects to
> shrink, but we can't do it because the __GFP_FS flag is not set.
> Although they can happen with user pages, they are a lot more common
> with fs-metadata: this is the case with almost all inode allocation.
> 
> Those allocations are, however, capable of waiting.  So we can just span
> a worker, let it finish its job and proceed with the allocation. As slow
> as it is, at this point we are already past any hopes anyway.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Cc: Dave Chinner <dchinner@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>   include/linux/swap.h |   2 +
>   mm/memcontrol.c      | 182 ++++++++++++++++++++++++++++++++++++++++-----------
>   mm/vmscan.c          |  37 ++++++++++-
>   3 files changed, 183 insertions(+), 38 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 2818a12..80f6635 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -268,6 +268,8 @@ extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>   extern int __isolate_lru_page(struct page *page, isolate_mode_t mode);
>   extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
>   						  gfp_t gfp_mask, bool noswap);
> +extern unsigned long try_to_free_mem_cgroup_kmem(struct mem_cgroup *mem,
> +						 gfp_t gfp_mask);
>   extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
>   						gfp_t gfp_mask, bool noswap,
>   						struct zone *zone,
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 89b7ffb..a5a0f39 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -353,6 +353,8 @@ struct mem_cgroup {
>   	atomic_t	numainfo_events;
>   	atomic_t	numainfo_updating;
>   #endif
> +	/* when kmem shrinkers can sleep but can't proceed due to context */
> +	struct work_struct kmemcg_shrink_work;
>   	/*
>   	 * Per cgroup active and inactive list, similar to the
>   	 * per zone LRU lists.
> @@ -369,11 +371,14 @@ static size_t memcg_size(void)
>   		nr_node_ids * sizeof(struct mem_cgroup_per_node);
>   }
>   
> +static DEFINE_MUTEX(set_limit_mutex);
> +
>   /* internal only representation about the status of kmem accounting. */
>   enum {
>   	KMEM_ACCOUNTED_ACTIVE = 0, /* accounted by this cgroup itself */
>   	KMEM_ACCOUNTED_ACTIVATED, /* static key enabled. */
>   	KMEM_ACCOUNTED_DEAD, /* dead memcg with pending kmem charges */
> +	KMEM_MAY_SHRINK, /* kmem limit < mem limit, shrink kmem only */
>   };
>   
>   /* We account when limit is on, but only after call sites are patched */
> @@ -412,6 +417,31 @@ static bool memcg_kmem_test_and_clear_dead(struct mem_cgroup *memcg)
>   	return test_and_clear_bit(KMEM_ACCOUNTED_DEAD,
>   				  &memcg->kmem_account_flags);
>   }
> +
> +/*
> + * If the kernel limit is smaller than the user limit, we will have situations
> + * in which our allocations fail but freeing user pages will buy us nothing.
> + * In those, we would like to call a specialized memcg reclaimer that only
> + * frees kernel memory and leave the user memory alone.
> + *
> + * This test exists so we can differentiate between those. Everytime one of the
> + * limits is updated, we need to run it. The set_limit_mutex must be held, so
> + * they don't change again.
> + */
> +static void memcg_update_shrink_status(struct mem_cgroup *memcg)
> +{
> +	mutex_lock(&set_limit_mutex);
> +	if (res_counter_read_u64(&memcg->kmem, RES_LIMIT) <
> +		res_counter_read_u64(&memcg->res, RES_LIMIT))
> +		set_bit(KMEM_MAY_SHRINK, &memcg->kmem_account_flags);
> +	else
> +		clear_bit(KMEM_MAY_SHRINK, &memcg->kmem_account_flags);
> +	mutex_unlock(&set_limit_mutex);
> +}
> +#else
> +static void memcg_update_shrink_status(struct mem_cgroup *memcg)
> +{
> +}
>   #endif
>   
>   /* Stuffs for move charges at task migration. */
> @@ -2838,8 +2868,6 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
>   	memcg_check_events(memcg, page);
>   }
>   
> -static DEFINE_MUTEX(set_limit_mutex);
> -
>   #ifdef CONFIG_MEMCG_KMEM
>   static inline bool memcg_can_account_kmem(struct mem_cgroup *memcg)
>   {
> @@ -2881,16 +2909,92 @@ static int mem_cgroup_slabinfo_read(struct cgroup *cont, struct cftype *cft,
>   }
>   #endif
>   
> +/*
> + * During the creation a new cache, we need to disable our accounting mechanism
> + * altogether. This is true even if we are not creating, but rather just
> + * enqueing new caches to be created.
> + *
> + * This is because that process will trigger allocations; some visible, like
> + * explicit kmallocs to auxiliary data structures, name strings and internal
> + * cache structures; some well concealed, like INIT_WORK() that can allocate
> + * objects during debug.
> + *
> + * If any allocation happens during memcg_kmem_get_cache, we will recurse back
> + * to it. This may not be a bounded recursion: since the first cache creation
> + * failed to complete (waiting on the allocation), we'll just try to create the
> + * cache again, failing at the same point.
> + *
> + * memcg_kmem_get_cache is prepared to abort after seeing a positive count of
> + * memcg_kmem_skip_account. So we enclose anything that might allocate memory
> + * inside the following two functions.
> + */
> +static inline void memcg_stop_kmem_account(void)
> +{
> +	VM_BUG_ON(!current->mm);
> +	current->memcg_kmem_skip_account++;
> +}
> +
> +static inline void memcg_resume_kmem_account(void)
> +{
> +	VM_BUG_ON(!current->mm);
> +	current->memcg_kmem_skip_account--;
> +}
> +
> +static int memcg_try_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
> +{
> +	int retries = MEM_CGROUP_RECLAIM_RETRIES;

I'm not sure this retry numbers, for anon/file LRUs is suitable for kmem.

> +	struct res_counter *fail_res;
> +	int ret;
> +
> +	do {
> +		ret = res_counter_charge(&memcg->kmem, size, &fail_res);
> +		if (!ret)
> +			return ret;
> +
> +		if (!(gfp & __GFP_WAIT))
> +			return ret;
> +
> +		/*
> +		 * We will try to shrink kernel memory present in caches. We
> +		 * are sure that we can wait, so we will. The duration of our
> +		 * wait is determined by congestion, the same way as vmscan.c
> +		 *
> +		 * If we are in FS context, though, then although we can wait,
> +		 * we cannot call the shrinkers. Most fs shrinkers (which
> +		 * comprises most of our kmem data) will not run without
> +		 * __GFP_FS since they can deadlock. The solution is to
> +		 * synchronously run that in a different context.
> +		 */
> +		if (!(gfp & __GFP_FS)) {
> +			/*
> +			 * we are already short on memory, every queue
> +			 * allocation is likely to fail
> +			 */
> +			memcg_stop_kmem_account();
> +			schedule_work(&memcg->kmemcg_shrink_work);
> +			flush_work(&memcg->kmemcg_shrink_work);
> +			memcg_resume_kmem_account();
> +		} else if (!try_to_free_mem_cgroup_kmem(memcg, gfp))
> +			congestion_wait(BLK_RW_ASYNC, HZ/10);

Why congestion_wait() ? I think calling congestion_wait() in vmscan.c is
a part of memory-reclaim logic but I don't think the caller should do
this kind of voluteer wait without good reason..


> +
> +	} while (retries--);
> +
> +	return ret;
> +}
> +
>   static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
>   {
>   	struct res_counter *fail_res;
>   	struct mem_cgroup *_memcg;
>   	int ret = 0;
>   	bool may_oom;
> +	bool kmem_first = test_bit(KMEM_MAY_SHRINK, &memcg->kmem_account_flags);
>   
> -	ret = res_counter_charge(&memcg->kmem, size, &fail_res);
> -	if (ret)
> -		return ret;
> +	if (kmem_first) {
> +		ret = memcg_try_charge_kmem(memcg, gfp, size);
> +		if (ret)
> +			return ret;
> +	}
>   
>   	/*
>   	 * Conditions under which we can wait for the oom_killer. Those are
> @@ -2923,12 +3027,43 @@ static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
>   			res_counter_charge_nofail(&memcg->memsw, size,
>   						  &fail_res);
>   		ret = 0;
> -	} else if (ret)
> +		if (!kmem_first)
> +			res_counter_charge_nofail(&memcg->kmem, size, &fail_res);
> +	} else if (ret && kmem_first)
>   		res_counter_uncharge(&memcg->kmem, size);
>   
> +	if (!kmem_first) {
> +		ret = memcg_try_charge_kmem(memcg, gfp, size);
> +		if (!ret)
> +			return ret;
> +
> +		res_counter_uncharge(&memcg->res, size);
> +		if (do_swap_account)
> +			res_counter_uncharge(&memcg->memsw, size);
> +	}
> +
>   	return ret;
>   }
>   
> +/*
> + * There might be situations in which there are plenty of objects to shrink,
> + * but we can't do it because the __GFP_FS flag is not set.  This is the case
> + * with almost all inode allocation. They do are, however, capable of waiting.
> + * So we can just span a worker, let it finish its job and proceed with the
> + * allocation. As slow as it is, at this point we are already past any hopes
> + * anyway.
> + */
> +static void kmemcg_shrink_work_fn(struct work_struct *w)
> +{
> +	struct mem_cgroup *memcg;
> +
> +	memcg = container_of(w, struct mem_cgroup, kmemcg_shrink_work);
> +
> +	if (!try_to_free_mem_cgroup_kmem(memcg, GFP_KERNEL))
> +		congestion_wait(BLK_RW_ASYNC, HZ/10);

ditto..

> +}
> +
> +
>   static void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size)
>   {
>   	res_counter_uncharge(&memcg->res, size);
> @@ -3005,6 +3140,7 @@ int memcg_update_cache_sizes(struct mem_cgroup *memcg)
>   	memcg_update_array_size(num + 1);
>   
>   	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
> +	INIT_WORK(&memcg->kmemcg_shrink_work, kmemcg_shrink_work_fn);
>   	mutex_init(&memcg->slab_caches_mutex);
>   
>   	return 0;
> @@ -3281,37 +3417,6 @@ out:
>   	kfree(s->memcg_params);
>   }
>   
> -/*
> - * During the creation a new cache, we need to disable our accounting mechanism
> - * altogether. This is true even if we are not creating, but rather just
> - * enqueing new caches to be created.
> - *
> - * This is because that process will trigger allocations; some visible, like
> - * explicit kmallocs to auxiliary data structures, name strings and internal
> - * cache structures; some well concealed, like INIT_WORK() that can allocate
> - * objects during debug.
> - *
> - * If any allocation happens during memcg_kmem_get_cache, we will recurse back
> - * to it. This may not be a bounded recursion: since the first cache creation
> - * failed to complete (waiting on the allocation), we'll just try to create the
> - * cache again, failing at the same point.
> - *
> - * memcg_kmem_get_cache is prepared to abort after seeing a positive count of
> - * memcg_kmem_skip_account. So we enclose anything that might allocate memory
> - * inside the following two functions.
> - */
> -static inline void memcg_stop_kmem_account(void)
> -{
> -	VM_BUG_ON(!current->mm);
> -	current->memcg_kmem_skip_account++;
> -}
> -
> -static inline void memcg_resume_kmem_account(void)
> -{
> -	VM_BUG_ON(!current->mm);
> -	current->memcg_kmem_skip_account--;
> -}
> -
>   static struct mem_cgroup *mem_cgroup_from_kmem_page(struct page *page)
>   {
>   	struct page_cgroup *pc;
> @@ -5292,6 +5397,9 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
>   			ret = memcg_update_kmem_limit(cont, val);
>   		else
>   			return -EINVAL;
> +
> +		if (!ret)
> +			memcg_update_shrink_status(memcg);
>   		break;
>   	case RES_SOFT_LIMIT:
>   		ret = res_counter_memparse_write_strategy(buffer, &val);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 43928fd..dd235e6 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2504,7 +2504,42 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
>   
>   	return nr_reclaimed;
>   }
> -#endif
> +
> +#ifdef CONFIG_MEMCG_KMEM
> +/*
> + * This function is called when we are under kmem-specific pressure.  It will
> + * only trigger in environments with kmem.limit_in_bytes < limit_in_bytes, IOW,
> + * with a lower kmem allowance than the memory allowance.
> + *
> + * In this situation, freeing user pages from the cgroup won't do us any good.
> + * What we really need is to call the memcg-aware shrinkers, in the hope of
> + * freeing pages holding kmem objects. It may also be that we won't be able to
> + * free any pages, but will get rid of old objects opening up space for new
> + * ones.
> + */
> +unsigned long try_to_free_mem_cgroup_kmem(struct mem_cgroup *memcg,
> +					  gfp_t gfp_mask)
> +{
> +	struct shrink_control shrink = {
> +		.gfp_mask = gfp_mask,
> +		.target_mem_cgroup = memcg,
> +	};
> +
> +	if (!(gfp_mask & __GFP_WAIT))
> +		return 0;
> +
> +	nodes_setall(shrink.nodes_to_scan);
> +
> +	/*
> +	 * We haven't scanned any user LRU, so we basically come up with
> +	 * crafted values of nr_scanned and LRU page (1 and 0 respectively).
> +	 * This should be enough to tell shrink_slab that the freeing
> +	 * responsibility is all on himself.
> +	 */
> +	return shrink_slab(&shrink, 1, 0);
> +}
> +#endif /* CONFIG_MEMCG_KMEM */
> +#endif /* CONFIG_MEMCG */
>   
>   static void age_active_anon(struct zone *zone, struct scan_control *sc)
>   {
> 


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
