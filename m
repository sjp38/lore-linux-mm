Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 9589B6B004A
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 17:42:07 -0500 (EST)
Date: Tue, 6 Mar 2012 22:42:01 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] cpuset: mm: Reduce large amounts of memory barrier
 related damage v2
Message-ID: <20120306224201.GA17697@suse.de>
References: <20120306132735.GA2855@suse.de>
 <20120306122657.8e5b128d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120306122657.8e5b128d.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux.com>, Miao Xie <miaox@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 06, 2012 at 12:26:57PM -0800, Andrew Morton wrote:
> > <SNIP>
> > --- a/include/linux/cpuset.h
> > +++ b/include/linux/cpuset.h
> > @@ -92,33 +92,19 @@ extern void cpuset_print_task_mems_allowed(struct task_struct *p);
> >   * reading current mems_allowed and mempolicy in the fastpath must protected
> >   * by get_mems_allowed()
> >   */
> > -static inline void get_mems_allowed(void)
> > +static inline unsigned int get_mems_allowed(void)
> >  {
> > -	current->mems_allowed_change_disable++;
> > -
> > -	/*
> > -	 * ensure that reading mems_allowed and mempolicy happens after the
> > -	 * update of ->mems_allowed_change_disable.
> > -	 *
> > -	 * the write-side task finds ->mems_allowed_change_disable is not 0,
> > -	 * and knows the read-side task is reading mems_allowed or mempolicy,
> > -	 * so it will clear old bits lazily.
> > -	 */
> > -	smp_mb();
> > +	return read_seqcount_begin(&current->mems_allowed_seq);
> >  }
> 
> Perhaps we could tickle up the interface documentation?  The current
> "documentation" is a grammatical mess and has a typo.
> 

There is no guarantee that I will do a better job :) . How about this?

/*
 * get_mems_allowed is required when making decisions involving mems_allowed
 * such as during page allocation. mems_allowed can be updated in parallel
 * and depending on the new value an operation can fail potentially causing
 * process failure. A retry loop with get_mems_allowed and put_mems_allowed
 * prevents these artificial failures.
 */
static inline unsigned int get_mems_allowed(void)
{
        return read_seqcount_begin(&current->mems_allowed_seq);
}

/*
 * If this returns false, the operation that took place after get_mems_allowed
 * may have failed. It is up to the caller to retry the operation if
 * appropriate.
 */
static inline bool put_mems_allowed(unsigned int seq)
{
        return !read_seqcount_retry(&current->mems_allowed_seq, seq);
}

?

> > -static inline void put_mems_allowed(void)
> > +/*
> > + * If this returns false, the operation that took place after get_mems_allowed
> > + * may have failed. It is up to the caller to retry the operation if
> > + * appropriate
> > + */
> > +static inline bool put_mems_allowed(unsigned int seq)
> >  {
> > -	/*
> > -	 * ensure that reading mems_allowed and mempolicy before reducing
> > -	 * mems_allowed_change_disable.
> > -	 *
> > -	 * the write-side task will know that the read-side task is still
> > -	 * reading mems_allowed or mempolicy, don't clears old bits in the
> > -	 * nodemask.
> > -	 */
> > -	smp_mb();
> > -	--ACCESS_ONCE(current->mems_allowed_change_disable);
> > +	return !read_seqcount_retry(&current->mems_allowed_seq, seq);
> >  }
> >  
> >  static inline void set_mems_allowed(nodemask_t nodemask)
> 
> How come set_mems_allowed() still uses task_lock()?
>

Consistency.

The task_lock is taken by kernel/cpuset.c when updating
mems_allowed so it is taken here. That said, it is unnecessary to take
as the two places where set_mems_allowed is used are not going to be
racing. In the unlikely event that set_mems_allowed() gets another user,
there is no harm is leaving the task_lock as it is. It's not in a hot
path of any description.
 
> 
> > @@ -234,12 +220,14 @@ static inline void set_mems_allowed(nodemask_t nodemask)
> >  {
> >  }
> >  
> > -static inline void get_mems_allowed(void)
> > +static inline unsigned int get_mems_allowed(void)
> >  {
> > +	return 0;
> >  }
> >  
> > -static inline void put_mems_allowed(void)
> > +static inline bool put_mems_allowed(unsigned int seq)
> >  {
> > +	return true;
> >  }
> >  
> >  #endif /* !CONFIG_CPUSETS */
> > diff --git a/include/linux/sched.h b/include/linux/sched.h
> > index 7d379a6..a0bb87a 100644
> > --- a/include/linux/sched.h
> > +++ b/include/linux/sched.h
> > @@ -1498,7 +1498,7 @@ struct task_struct {
> >  #endif
> >  #ifdef CONFIG_CPUSETS
> >  	nodemask_t mems_allowed;	/* Protected by alloc_lock */
> > -	int mems_allowed_change_disable;
> > +	seqcount_t mems_allowed_seq;	/* Seqence no to catch updates */
> 
> mems_allowed_seq never gets initialised.  That happens to be OK as
> we're never using its spinlock. 

Yes.

> But that's sloppy, and adding an
> initialisation to INIT_TASK() is free. But will copying a spinlock by
> value upset lockdep?  To be fully anal we should run seqlock_init()
> against each new task_struct.
> 

I did not check if lockdep throws a hissy fit but your point that
leaving it uninitialised is sloppy and fixing that is trivial.

> >  	int cpuset_mem_spread_rotor;
> >  	int cpuset_slab_spread_rotor;
> >  #endif
> >
> > ...
> >
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -498,12 +498,15 @@ struct page *__page_cache_alloc(gfp_t gfp)
> >  {
> >  	int n;
> >  	struct page *page;
> > +	unsigned int cpuset_mems_cookie;
> >  
> >  	if (cpuset_do_page_mem_spread()) {
> > -		get_mems_allowed();
> > -		n = cpuset_mem_spread_node();
> > -		page = alloc_pages_exact_node(n, gfp, 0);
> > -		put_mems_allowed();
> > +		do {
> > +			cpuset_mems_cookie = get_mems_allowed();
> > +			n = cpuset_mem_spread_node();
> > +			page = alloc_pages_exact_node(n, gfp, 0);
> > +		} while (!put_mems_allowed(cpuset_mems_cookie) && !page);
> 
> It would be a little tidier to move cpuset_mems_cookie's scope inwards.
> 

True.

> >  		return page;
> >  	}
> >  	return alloc_pages(gfp, 0);
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index 5f34bd8..5f1e959 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -460,8 +460,10 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
> >  	struct zonelist *zonelist;
> >  	struct zone *zone;
> >  	struct zoneref *z;
> > +	unsigned int cpuset_mems_cookie;
> >  
> > -	get_mems_allowed();
> > +retry_cpuset:
> > +	cpuset_mems_cookie = get_mems_allowed();
> >  	zonelist = huge_zonelist(vma, address,
> >  					htlb_alloc_mask, &mpol, &nodemask);
> >  	/*
> > @@ -490,7 +492,8 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
> >  	}
> >  err:
> >  	mpol_cond_put(mpol);
> > -	put_mems_allowed();
> > +	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
> > +		goto retry_cpuset;
> >  	return page;
> >  }
> 
> We didn't really want to retry the allocation if dequeue_huge_page_vma() has
> made one of its "goto err" decisions.
> 

Very good point, thanks. Fixed.

> >
> > ...
> >
> > @@ -2416,9 +2417,19 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
> >  		page = __alloc_pages_slowpath(gfp_mask, order,
> >  				zonelist, high_zoneidx, nodemask,
> >  				preferred_zone, migratetype);
> > -	put_mems_allowed();
> >  
> >  	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
> > +
> > +out:
> > +	/*
> > +	 * When updating a tasks mems_allowed, it is possible to race with
> 
> "task's"
> 

Fixed

> > +	 * parallel threads in such a way that an allocation can fail while
> > +	 * the mask is being updated. If a page allocation is about to fail,
> > +	 * check if the cpuset changed during allocation and if so, retry.
> > +	 */
> > +	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
> > +		goto retry_cpuset;
> > +
> >  	return page;
> >  }
> >  EXPORT_SYMBOL(__alloc_pages_nodemask);
> >
> > ...
> >
> > @@ -3312,11 +3310,14 @@ static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
> >  	enum zone_type high_zoneidx = gfp_zone(flags);
> >  	void *obj = NULL;
> >  	int nid;
> > +	unsigned int cpuset_mems_cookie;
> >  
> >  	if (flags & __GFP_THISNODE)
> >  		return NULL;
> >  
> > -	get_mems_allowed();
> > +retry_cpuset:
> > +	cpuset_mems_cookie = get_mems_allowed();
> > +
> >  	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
> >  	local_flags = flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
> >  
> > @@ -3372,7 +3373,9 @@ retry:
> >  			}
> >  		}
> >  	}
> > -	put_mems_allowed();
> > +
> > +	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !obj))
> > +		goto retry_cpuset;
> 
> We recalculate `zonelist' and `local_flags' each time around the loop. 
> The former is probably unnecessary and the latter is surely so.  I'd
> expect gcc to fix the `local_flags' one.
> 

It's not at all obvious but zonelist needs to be recalculated. In
slab_node, we access nodemask information that can be changed if the
cpuset nodemask is altered and the retry loop needs the new information.
I moved the local_flags one outside the retry loop anyway.

> >  	return obj;
> >  }
> >
> > ...
> >
> > @@ -1604,23 +1605,24 @@ static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags,
> >  			get_cycles() % 1024 > s->remote_node_defrag_ratio)
> >  		return NULL;
> >  
> > -	get_mems_allowed();
> > -	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
> > -	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
> > -		struct kmem_cache_node *n;
> > -
> > -		n = get_node(s, zone_to_nid(zone));
> > -
> > -		if (n && cpuset_zone_allowed_hardwall(zone, flags) &&
> > -				n->nr_partial > s->min_partial) {
> > -			object = get_partial_node(s, n, c);
> > -			if (object) {
> > -				put_mems_allowed();
> > -				return object;
> > +	do {
> > +		cpuset_mems_cookie = get_mems_allowed();
> > +		zonelist = node_zonelist(slab_node(current->mempolicy), flags);
> > +		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
> > +			struct kmem_cache_node *n;
> > +
> > +			n = get_node(s, zone_to_nid(zone));
> > +
> > +			if (n && cpuset_zone_allowed_hardwall(zone, flags) &&
> > +					n->nr_partial > s->min_partial) {
> > +				object = get_partial_node(s, n, c);
> > +				if (object) {
> > +					put_mems_allowed(cpuset_mems_cookie);
> > +					return object;
> 
> Confused.  If put_mems_allowed() returned false, doesn't that mean the
> result is unstable and we should retry?  Needs a comment explaining
> what's going on?
> 

There is a race between the allocator and the cpuset being updated. If
the cpuset is being updated but the allocation succeeded, I decided to
return the object as if the collision had never occurred. The
alternative was to free the object again and retry which seemed
completely unnecessary.

I added a comment.

> > +				}
> >  			}
> >  		}
> > -	}
> > -	put_mems_allowed();
> > +	} while (!put_mems_allowed(cpuset_mems_cookie));
> >  #endif
> >  	return NULL;
> >  }
> >
> > ...
> >
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
