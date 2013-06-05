Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 1C2606B0075
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 19:08:44 -0400 (EDT)
Date: Wed, 5 Jun 2013 16:08:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 29/35] memcg: per-memcg kmem shrinking
Message-Id: <20130605160841.909420c06bfde62039489d2e@linux-foundation.org>
In-Reply-To: <1370287804-3481-30-git-send-email-glommer@openvz.org>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
	<1370287804-3481-30-git-send-email-glommer@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>, Rik van Riel <riel@redhat.com>

On Mon,  3 Jun 2013 23:29:58 +0400 Glauber Costa <glommer@openvz.org> wrote:

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

"spawn"!

> a worker, let it finish its job and proceed with the allocation. As slow
> as it is, at this point we are already past any hopes anyway.

>
> ...
>
> + * If the kernel limit is smaller than the user limit, we will have situations
> + * in which our allocations fail but freeing user pages will buy us nothing.
> + * In those, we would like to call a specialized memcg reclaimer that only
> + * frees kernel memory and leave the user memory alone.

"leaves"

> + * This test exists so we can differentiate between those. Everytime one of the

"Every time"

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
>  #endif
>  
>  /* Stuffs for move charges at task migration. */
> @@ -3013,8 +3042,6 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
>  	memcg_check_events(memcg, page);
>  }
>  
> -static DEFINE_MUTEX(set_limit_mutex);
> -
>  #ifdef CONFIG_MEMCG_KMEM
>  static inline bool memcg_can_account_kmem(struct mem_cgroup *memcg)
>  {
> @@ -3056,16 +3083,91 @@ static int mem_cgroup_slabinfo_read(struct cgroup *cont, struct cftype *cft,
>  }
>  #endif
>  
> +/*
> + * During the creation a new cache, we need to disable our accounting mechanism

"creation of"

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

Please identify the type of caches we're talking about here.  slab
caches?  inode/dentry/anything-whcih-hash-a-shrinker?

(yes, these observations pertain to existing code)

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

But this is pointless.  Calling a function via a different thread and
then waiting for it to complete is equivalent to calling it directly.

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
> +		} else
> +			try_to_free_mem_cgroup_kmem(memcg, gfp);
> +	} while (retries--);
> +
> +	return ret;
> +}
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
