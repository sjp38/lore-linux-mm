Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id C2FE56B004A
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 15:26:59 -0500 (EST)
Date: Tue, 6 Mar 2012 12:26:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] cpuset: mm: Reduce large amounts of memory barrier
 related damage v2
Message-Id: <20120306122657.8e5b128d.akpm@linux-foundation.org>
In-Reply-To: <20120306132735.GA2855@suse.de>
References: <20120306132735.GA2855@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux.com>, Miao Xie <miaox@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 6 Mar 2012 13:27:35 +0000
Mel Gorman <mgorman@suse.de> wrote:

> Changelog since V1
>   o Use seqcount with rmb instead of atomics (Peter, Christoph)
> 
> Commit [c0ff7453: cpuset,mm: fix no node to alloc memory when changing
> cpuset's mems] wins a super prize for the largest number of memory
> barriers entered into fast paths for one commit. [get|put]_mems_allowed
> is incredibly heavy with pairs of full memory barriers inserted into a
> number of hot paths. This was detected while investigating at large page
> allocator slowdown introduced some time after 2.6.32. The largest portion
> of this overhead was shown by oprofile to be at an mfence introduced by
> this commit into the page allocator hot path.
> 
> For extra style points, the commit introduced the use of yield() in an
> implementation of what looks like a spinning mutex.
> 
> This patch replaces the full memory barriers on both read and write sides
> with a sequence counter with just read barriers on the fast path side.
> This is much cheaper on some architectures, including x86.  The main bulk
> of the patch is the retry logic if the nodemask changes in a manner that
> can cause a false failure.
> 
> While updating the nodemask, a check is made to see if a false failure is
> a risk. If it is, the sequence number gets bumped and parallel allocators
> will briefly stall while the nodemask update takes place.
> 
> In a page fault test microbenchmark, oprofile samples from
> __alloc_pages_nodemask went from 4.53% of all samples to 1.15%. The actual
> results were
> 
>                          3.3.0-rc3          3.3.0-rc3
>                          rc3-vanilla        nobarrier-v2r1
> Clients   1 UserTime       0.07 (  0.00%)   0.08 (-14.19%)
> Clients   2 UserTime       0.07 (  0.00%)   0.07 (  2.72%)
> Clients   4 UserTime       0.08 (  0.00%)   0.07 (  3.29%)
> Clients   1 SysTime        0.70 (  0.00%)   0.65 (  6.65%)
> Clients   2 SysTime        0.85 (  0.00%)   0.82 (  3.65%)
> Clients   4 SysTime        1.41 (  0.00%)   1.41 (  0.32%)
> Clients   1 WallTime       0.77 (  0.00%)   0.74 (  4.19%)
> Clients   2 WallTime       0.47 (  0.00%)   0.45 (  3.73%)
> Clients   4 WallTime       0.38 (  0.00%)   0.37 (  1.58%)
> Clients   1 Flt/sec/cpu  497620.28 (  0.00%) 520294.53 (  4.56%)
> Clients   2 Flt/sec/cpu  414639.05 (  0.00%) 429882.01 (  3.68%)
> Clients   4 Flt/sec/cpu  257959.16 (  0.00%) 258761.48 (  0.31%)
> Clients   1 Flt/sec      495161.39 (  0.00%) 517292.87 (  4.47%)
> Clients   2 Flt/sec      820325.95 (  0.00%) 850289.77 (  3.65%)
> Clients   4 Flt/sec      1020068.93 (  0.00%) 1022674.06 (  0.26%)
> MMTests Statistics: duration
> Sys Time Running Test (seconds)             135.68    132.17
> User+Sys Time Running Test (seconds)         164.2    160.13
> Total Elapsed Time (seconds)                123.46    120.87
> 
> The overall improvement is small but the System CPU time is much improved
> and roughly in correlation to what oprofile reported (these performance
> figures are without profiling so skew is expected). The actual number of
> page faults is noticeably improved.
> 
> For benchmarks like kernel builds, the overall benefit is marginal but
> the system CPU time is slightly reduced.
> 
> To test the actual bug the commit fixed I opened two terminals. The first
> ran within a cpuset and continually ran a small program that faulted 100M
> of anonymous data. In a second window, the nodemask of the cpuset was
> continually randomised in a loop. Without the commit, the program would
> fail every so often (usually within 10 seconds) and obviously with the
> commit everything worked fine. With this patch applied, it also worked
> fine so the fix should be functionally equivalent.
> 
>
> ...
>
> --- a/include/linux/cpuset.h
> +++ b/include/linux/cpuset.h
> @@ -92,33 +92,19 @@ extern void cpuset_print_task_mems_allowed(struct task_struct *p);
>   * reading current mems_allowed and mempolicy in the fastpath must protected
>   * by get_mems_allowed()
>   */
> -static inline void get_mems_allowed(void)
> +static inline unsigned int get_mems_allowed(void)
>  {
> -	current->mems_allowed_change_disable++;
> -
> -	/*
> -	 * ensure that reading mems_allowed and mempolicy happens after the
> -	 * update of ->mems_allowed_change_disable.
> -	 *
> -	 * the write-side task finds ->mems_allowed_change_disable is not 0,
> -	 * and knows the read-side task is reading mems_allowed or mempolicy,
> -	 * so it will clear old bits lazily.
> -	 */
> -	smp_mb();
> +	return read_seqcount_begin(&current->mems_allowed_seq);
>  }

Perhaps we could tickle up the interface documentation?  The current
"documentation" is a grammatical mess and has a typo.

> -static inline void put_mems_allowed(void)
> +/*
> + * If this returns false, the operation that took place after get_mems_allowed
> + * may have failed. It is up to the caller to retry the operation if
> + * appropriate
> + */
> +static inline bool put_mems_allowed(unsigned int seq)
>  {
> -	/*
> -	 * ensure that reading mems_allowed and mempolicy before reducing
> -	 * mems_allowed_change_disable.
> -	 *
> -	 * the write-side task will know that the read-side task is still
> -	 * reading mems_allowed or mempolicy, don't clears old bits in the
> -	 * nodemask.
> -	 */
> -	smp_mb();
> -	--ACCESS_ONCE(current->mems_allowed_change_disable);
> +	return !read_seqcount_retry(&current->mems_allowed_seq, seq);
>  }
>  
>  static inline void set_mems_allowed(nodemask_t nodemask)

How come set_mems_allowed() still uses task_lock()?


> @@ -234,12 +220,14 @@ static inline void set_mems_allowed(nodemask_t nodemask)
>  {
>  }
>  
> -static inline void get_mems_allowed(void)
> +static inline unsigned int get_mems_allowed(void)
>  {
> +	return 0;
>  }
>  
> -static inline void put_mems_allowed(void)
> +static inline bool put_mems_allowed(unsigned int seq)
>  {
> +	return true;
>  }
>  
>  #endif /* !CONFIG_CPUSETS */
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 7d379a6..a0bb87a 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1498,7 +1498,7 @@ struct task_struct {
>  #endif
>  #ifdef CONFIG_CPUSETS
>  	nodemask_t mems_allowed;	/* Protected by alloc_lock */
> -	int mems_allowed_change_disable;
> +	seqcount_t mems_allowed_seq;	/* Seqence no to catch updates */

mems_allowed_seq never gets initialised.  That happens to be OK as
we're never using its spinlock.  But that's sloppy, and adding an
initialisation to INIT_TASK() is free.  But will copying a spinlock by
value upset lockdep?  To be fully anal we should run seqlock_init()
against each new task_struct.

>  	int cpuset_mem_spread_rotor;
>  	int cpuset_slab_spread_rotor;
>  #endif
>
> ...
>
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -498,12 +498,15 @@ struct page *__page_cache_alloc(gfp_t gfp)
>  {
>  	int n;
>  	struct page *page;
> +	unsigned int cpuset_mems_cookie;
>  
>  	if (cpuset_do_page_mem_spread()) {
> -		get_mems_allowed();
> -		n = cpuset_mem_spread_node();
> -		page = alloc_pages_exact_node(n, gfp, 0);
> -		put_mems_allowed();
> +		do {
> +			cpuset_mems_cookie = get_mems_allowed();
> +			n = cpuset_mem_spread_node();
> +			page = alloc_pages_exact_node(n, gfp, 0);
> +		} while (!put_mems_allowed(cpuset_mems_cookie) && !page);

It would be a little tidier to move cpuset_mems_cookie's scope inwards.

>  		return page;
>  	}
>  	return alloc_pages(gfp, 0);
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 5f34bd8..5f1e959 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -460,8 +460,10 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
>  	struct zonelist *zonelist;
>  	struct zone *zone;
>  	struct zoneref *z;
> +	unsigned int cpuset_mems_cookie;
>  
> -	get_mems_allowed();
> +retry_cpuset:
> +	cpuset_mems_cookie = get_mems_allowed();
>  	zonelist = huge_zonelist(vma, address,
>  					htlb_alloc_mask, &mpol, &nodemask);
>  	/*
> @@ -490,7 +492,8 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
>  	}
>  err:
>  	mpol_cond_put(mpol);
> -	put_mems_allowed();
> +	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
> +		goto retry_cpuset;
>  	return page;
>  }

We didn't really want to retry the allocation if dequeue_huge_page_vma() has
made one of its "goto err" decisions.

>
> ...
>
> @@ -2416,9 +2417,19 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  		page = __alloc_pages_slowpath(gfp_mask, order,
>  				zonelist, high_zoneidx, nodemask,
>  				preferred_zone, migratetype);
> -	put_mems_allowed();
>  
>  	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
> +
> +out:
> +	/*
> +	 * When updating a tasks mems_allowed, it is possible to race with

"task's"

> +	 * parallel threads in such a way that an allocation can fail while
> +	 * the mask is being updated. If a page allocation is about to fail,
> +	 * check if the cpuset changed during allocation and if so, retry.
> +	 */
> +	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
> +		goto retry_cpuset;
> +
>  	return page;
>  }
>  EXPORT_SYMBOL(__alloc_pages_nodemask);
>
> ...
>
> @@ -3312,11 +3310,14 @@ static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
>  	enum zone_type high_zoneidx = gfp_zone(flags);
>  	void *obj = NULL;
>  	int nid;
> +	unsigned int cpuset_mems_cookie;
>  
>  	if (flags & __GFP_THISNODE)
>  		return NULL;
>  
> -	get_mems_allowed();
> +retry_cpuset:
> +	cpuset_mems_cookie = get_mems_allowed();
> +
>  	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
>  	local_flags = flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
>  
> @@ -3372,7 +3373,9 @@ retry:
>  			}
>  		}
>  	}
> -	put_mems_allowed();
> +
> +	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !obj))
> +		goto retry_cpuset;

We recalculate `zonelist' and `local_flags' each time around the loop. 
The former is probably unnecessary and the latter is surely so.  I'd
expect gcc to fix the `local_flags' one.

>  	return obj;
>  }
>
> ...
>
> @@ -1604,23 +1605,24 @@ static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags,
>  			get_cycles() % 1024 > s->remote_node_defrag_ratio)
>  		return NULL;
>  
> -	get_mems_allowed();
> -	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
> -	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
> -		struct kmem_cache_node *n;
> -
> -		n = get_node(s, zone_to_nid(zone));
> -
> -		if (n && cpuset_zone_allowed_hardwall(zone, flags) &&
> -				n->nr_partial > s->min_partial) {
> -			object = get_partial_node(s, n, c);
> -			if (object) {
> -				put_mems_allowed();
> -				return object;
> +	do {
> +		cpuset_mems_cookie = get_mems_allowed();
> +		zonelist = node_zonelist(slab_node(current->mempolicy), flags);
> +		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
> +			struct kmem_cache_node *n;
> +
> +			n = get_node(s, zone_to_nid(zone));
> +
> +			if (n && cpuset_zone_allowed_hardwall(zone, flags) &&
> +					n->nr_partial > s->min_partial) {
> +				object = get_partial_node(s, n, c);
> +				if (object) {
> +					put_mems_allowed(cpuset_mems_cookie);
> +					return object;

Confused.  If put_mems_allowed() returned false, doesn't that mean the
result is unstable and we should retry?  Needs a comment explaining
what's going on?

> +				}
>  			}
>  		}
> -	}
> -	put_mems_allowed();
> +	} while (!put_mems_allowed(cpuset_mems_cookie));
>  #endif
>  	return NULL;
>  }
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
