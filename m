Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 83E7B6B0038
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 06:31:20 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa1so4522765pad.14
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 03:31:20 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id nh4si8060027pdb.202.2014.09.26.03.31.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Sep 2014 03:31:19 -0700 (PDT)
Date: Fri, 26 Sep 2014 14:31:05 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch 1/3] mm: memcontrol: lockless page counters
Message-ID: <20140926103104.GE29445@esperanza>
References: <1411573390-9601-1-git-send-email-hannes@cmpxchg.org>
 <1411573390-9601-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1411573390-9601-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Johannes,

On Wed, Sep 24, 2014 at 11:43:08AM -0400, Johannes Weiner wrote:
> Memory is internally accounted in bytes, using spinlock-protected
> 64-bit counters, even though the smallest accounting delta is a page.
> The counter interface is also convoluted and does too many things.
> 
> Introduce a new lockless word-sized page counter API, then change all
> memory accounting over to it and remove the old one.  The translation
> from and to bytes then only happens when interfacing with userspace.
> 
> Aside from the locking costs, this gets rid of the icky unsigned long
> long types in the very heart of memcg, which is great for 32 bit and
> also makes the code a lot more readable.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

It looks much better to me. A few comments below, mostly nit picking.

[...]
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c2c75262a209..52c24119be69 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
[...]
> @@ -1490,12 +1495,23 @@ int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
>   */
>  static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
>  {
> -	unsigned long long margin;
> +	unsigned long margin = 0;
> +	unsigned long count;
> +	unsigned long limit;
>  
> -	margin = res_counter_margin(&memcg->res);
> -	if (do_swap_account)
> -		margin = min(margin, res_counter_margin(&memcg->memsw));
> -	return margin >> PAGE_SHIFT;
> +	count = page_counter_read(&memcg->memory);
> +	limit = ACCESS_ONCE(memcg->memory.limit);
> +	if (count < limit)

Nit: IMO this looks unwieldier and less readable than
res_counter_margin. And two lines below we repeat this.

> +		margin = limit - count;
> +
> +	if (do_swap_account) {
> +		count = page_counter_read(&memcg->memsw);
> +		limit = ACCESS_ONCE(memcg->memsw.limit);
> +		if (count < limit)
> +			margin = min(margin, limit - count);
> +	}
> +
> +	return margin;
>  }
>  
>  int mem_cgroup_swappiness(struct mem_cgroup *memcg)
[...]
> @@ -1685,30 +1698,19 @@ static int mem_cgroup_count_children(struct mem_cgroup *memcg)
>  }
>  
>  /*
> - * Return the memory (and swap, if configured) limit for a memcg.
> + * Return the memory (and swap, if configured) maximum consumption for a memcg.

Nit: Why did you change the comment? Now it doesn't seem to be relevant.

>   */
> -static u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
> +static unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg)
>  {
> -	u64 limit;
> +	unsigned long limit;
>  
> -	limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
> -
> -	/*
> -	 * Do not consider swap space if we cannot swap due to swappiness
> -	 */
> +	limit = memcg->memory.limit;
>  	if (mem_cgroup_swappiness(memcg)) {
> -		u64 memsw;
> +		unsigned long memsw_limit;
>  
> -		limit += total_swap_pages << PAGE_SHIFT;
> -		memsw = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
> -
> -		/*
> -		 * If memsw is finite and limits the amount of swap space
> -		 * available to this memcg, return that limit.
> -		 */
> -		limit = min(limit, memsw);
> +		memsw_limit = memcg->memsw.limit;
> +		limit = min(limit + total_swap_pages, memsw_limit);
>  	}
> -
>  	return limit;
>  }
>  
[...]
> @@ -4114,25 +4109,27 @@ out:
>  }
>  
>  static int memcg_activate_kmem(struct mem_cgroup *memcg,
> -			       unsigned long long limit)
> +			       unsigned long nr_pages)
>  {
>  	int ret;
>  
>  	mutex_lock(&activate_kmem_mutex);
> -	ret = __memcg_activate_kmem(memcg, limit);
> +	ret = __memcg_activate_kmem(memcg, nr_pages);
>  	mutex_unlock(&activate_kmem_mutex);
>  	return ret;
>  }
>  
>  static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
> -				   unsigned long long val)
> +				   unsigned long limit)
>  {
>  	int ret;
>  
> +	mutex_lock(&memcg_limit_mutex);
>  	if (!memcg_kmem_is_active(memcg))
> -		ret = memcg_activate_kmem(memcg, val);
> +		ret = memcg_activate_kmem(memcg, limit);

I think we can now get rid of the activate_kmem_mutex, but this should
be done separately of course.

>  	else
> -		ret = res_counter_set_limit(&memcg->kmem, val);
> +		ret = page_counter_limit(&memcg->kmem, limit);
> +	mutex_unlock(&memcg_limit_mutex);
>  	return ret;
>  }
>  
[...]
> @@ -5570,10 +5530,10 @@ static void mem_cgroup_css_reset(struct cgroup_subsys_state *css)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  
> -	mem_cgroup_resize_limit(memcg, ULLONG_MAX);
> -	mem_cgroup_resize_memsw_limit(memcg, ULLONG_MAX);
> -	memcg_update_kmem_limit(memcg, ULLONG_MAX);
> -	res_counter_set_soft_limit(&memcg->res, ULLONG_MAX);
> +	mem_cgroup_resize_limit(memcg, PAGE_COUNTER_MAX);
> +	mem_cgroup_resize_memsw_limit(memcg, PAGE_COUNTER_MAX);
> +	memcg_update_kmem_limit(memcg, PAGE_COUNTER_MAX);

I think we should do it only if memcg_kmem_is_active, but that's a
different story.

> +	memcg->soft_limit = 0;
>  }
>  
>  #ifdef CONFIG_MMU
[...]
> diff --git a/mm/page_counter.c b/mm/page_counter.c
> new file mode 100644
> index 000000000000..51c45921b8d1
> --- /dev/null
> +++ b/mm/page_counter.c
> @@ -0,0 +1,191 @@
> +/*
> + * Lockless hierarchical page accounting & limiting
> + *
> + * Copyright (C) 2014 Red Hat, Inc., Johannes Weiner
> + */
> +#include <linux/page_counter.h>
> +#include <linux/atomic.h>
> +
> +/**
> + * page_counter_cancel - take pages out of the local counter
> + * @counter: counter
> + * @nr_pages: number of pages to cancel
> + *
> + * Returns whether there are remaining pages in the counter.
> + */
> +int page_counter_cancel(struct page_counter *counter, unsigned long nr_pages)
> +{
> +	long new;
> +
> +	new = atomic_long_sub_return(nr_pages, &counter->count);
> +
> +	if (WARN_ON_ONCE(new < 0))
> +		atomic_long_add(nr_pages, &counter->count);
> +
> +	return new > 0;
> +}
> +
> +/**
> + * page_counter_charge - hierarchically charge pages
> + * @counter: counter
> + * @nr_pages: number of pages to charge
> + *
> + * NOTE: This may exceed the configured counter limits.
> + */
> +void page_counter_charge(struct page_counter *counter, unsigned long nr_pages)
> +{
> +	struct page_counter *c;
> +
> +	for (c = counter; c; c = c->parent) {
> +		long new;
> +
> +		new = atomic_long_add_return(nr_pages, &c->count);
> +		/*
> +		 * This is racy, but with the per-cpu caches on top
> +		 * it's just a ballpark metric anyway; and with lazy
> +		 * cache reclaim, the majority of workloads peg the
> +		 * watermark to the group limit soon after launch.
> +		 */
> +		if (new > c->watermark)
> +			c->watermark = new;
> +	}
> +}
> +
> +/**
> + * page_counter_try_charge - try to hierarchically charge pages
> + * @counter: counter
> + * @nr_pages: number of pages to charge
> + * @fail: points first counter to hit its limit, if any
> + *
> + * Returns 0 on success, or -ENOMEM and @fail if the counter or one of
> + * its ancestors has hit its limit.
> + */
> +int page_counter_try_charge(struct page_counter *counter,
> +			    unsigned long nr_pages,
> +			    struct page_counter **fail)
> +{
> +	struct page_counter *c;
> +
> +	for (c = counter; c; c = c->parent) {
> +		long new;
> +		/*
> +		 * Charge speculatively to avoid an expensive CAS.  If
> +		 * a bigger charge fails, it might falsely lock out a
> +		 * racing smaller charge and send it into reclaim
> +		 * eraly, but the error is limited to the difference

Nit: s/eraly/early

> +		 * between the two sizes, which is less than 2M/4M in
> +		 * case of a THP locking out a regular page charge.
> +		 */
> +		new = atomic_long_add_return(nr_pages, &c->count);
> +		if (new > c->limit) {
> +			atomic_long_sub(nr_pages, &c->count);
> +			/*
> +			 * This is racy, but the failcnt is only a
> +			 * ballpark metric anyway.
> +			 */

I still don't think that the failcnt is completely useless. As I
mentioned previously, it can be used to check whether the workload is
behaving badly due to memcg limits or for some other reason. And I don't
see why it couldn't be atomic. This isn't a show stopper though.

> +			c->failcnt++;
> +			*fail = c;
> +			goto failed;
> +		}
> +		/*
> +		 * This is racy, but with the per-cpu caches on top
> +		 * it's just a ballpark metric anyway; and with lazy
> +		 * cache reclaim, the majority of workloads peg the
> +		 * watermark to the group limit soon after launch.

Not for kmem, I think.

> +		 */
> +		if (new > c->watermark)
> +			c->watermark = new;
> +	}
> +	return 0;
> +
> +failed:
> +	for (c = counter; c != *fail; c = c->parent)
> +		page_counter_cancel(c, nr_pages);
> +
> +	return -ENOMEM;
> +}
> +
> +/**
> + * page_counter_uncharge - hierarchically uncharge pages
> + * @counter: counter
> + * @nr_pages: number of pages to uncharge
> + *
> + * Returns whether there are remaining charges in @counter.
> + */
> +int page_counter_uncharge(struct page_counter *counter, unsigned long nr_pages)
> +{
> +	struct page_counter *c;
> +	int ret = 1;
> +
> +	for (c = counter; c; c = c->parent) {
> +		int remainder;
> +
> +		remainder = page_counter_cancel(c, nr_pages);
> +		if (c == counter && !remainder)
> +			ret = 0;
> +	}
> +
> +	return ret;
> +}
> +
> +/**
> + * page_counter_limit - limit the number of pages allowed
> + * @counter: counter
> + * @limit: limit to set
> + *
> + * Returns 0 on success, -EBUSY if the current number of pages on the
> + * counter already exceeds the specified limit.
> + *
> + * The caller must serialize invocations on the same counter.
> + */
> +int page_counter_limit(struct page_counter *counter, unsigned long limit)
> +{
> +	for (;;) {
> +		unsigned long old;
> +		long count;
> +
> +		count = atomic_long_read(&counter->count);
> +
> +		old = xchg(&counter->limit, limit);

Why do you use xchg here?

> +
> +		if (atomic_long_read(&counter->count) != count) {
> +			counter->limit = old;
> +			continue;
> +		}
> +
> +		if (count > limit) {
> +			counter->limit = old;
> +			return -EBUSY;
> +		}

I have a suspicion that this can race with page_counter_try_charge.
Look, access to c->limit is not marked as volatile in try_charge so the
compiler is allowed to issue read only once, in the very beginning of
the try_charge function. Then try_charge may succeed after the limit was
actually updated to a smaller value.

Strictly speaking, using ACCESS_ONCE in try_charge wouldn't be enough
AFAIU. There must be memory barriers here and there.

> +
> +		return 0;
> +	}
> +}
> +
> +/**
> + * page_counter_memparse - memparse() for page counter limits
> + * @buf: string to parse
> + * @nr_pages: returns the result in number of pages
> + *
> + * Returns -EINVAL, or 0 and @nr_pages on success.  @nr_pages will be
> + * limited to %PAGE_COUNTER_MAX.
> + */
> +int page_counter_memparse(const char *buf, unsigned long *nr_pages)
> +{
> +	char unlimited[] = "-1";
> +	char *end;
> +	u64 bytes;
> +
> +	if (!strncmp(buf, unlimited, sizeof(unlimited))) {
> +		*nr_pages = PAGE_COUNTER_MAX;
> +		return 0;
> +	}
> +
> +	bytes = memparse(buf, &end);
> +	if (*end != '\0')
> +		return -EINVAL;
> +
> +	*nr_pages = min(bytes / PAGE_SIZE, (u64)PAGE_COUNTER_MAX);
> +
> +	return 0;
> +}
> diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
> index 1d191357bf88..272327134a1b 100644
> --- a/net/ipv4/tcp_memcontrol.c
> +++ b/net/ipv4/tcp_memcontrol.c
[...]
> @@ -126,43 +134,36 @@ static ssize_t tcp_cgroup_write(struct kernfs_open_file *of,
>  	return ret ?: nbytes;
>  }
>  
> -static u64 tcp_read_stat(struct mem_cgroup *memcg, int type, u64 default_val)
> -{
> -	struct cg_proto *cg_proto;
> -
> -	cg_proto = tcp_prot.proto_cgroup(memcg);
> -	if (!cg_proto)
> -		return default_val;
> -
> -	return res_counter_read_u64(&cg_proto->memory_allocated, type);
> -}
> -
> -static u64 tcp_read_usage(struct mem_cgroup *memcg)
> -{
> -	struct cg_proto *cg_proto;
> -
> -	cg_proto = tcp_prot.proto_cgroup(memcg);
> -	if (!cg_proto)
> -		return atomic_long_read(&tcp_memory_allocated) << PAGE_SHIFT;
> -
> -	return res_counter_read_u64(&cg_proto->memory_allocated, RES_USAGE);
> -}
> -
>  static u64 tcp_cgroup_read(struct cgroup_subsys_state *css, struct cftype *cft)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> +	struct cg_proto *cg_proto = tcp_prot.proto_cgroup(memcg);
>  	u64 val;
>  
>  	switch (cft->private) {
>  	case RES_LIMIT:
> -		val = tcp_read_stat(memcg, RES_LIMIT, RES_COUNTER_MAX);
> +		if (!cg_proto)
> +			return PAGE_COUNTER_MAX;

For compatibility it must be ULLONG_MAX.

> +		val = cg_proto->memory_allocated.limit;
> +		val *= PAGE_SIZE;
>  		break;
>  	case RES_USAGE:
> -		val = tcp_read_usage(memcg);
> +		if (!cg_proto)
> +			val = atomic_long_read(&tcp_memory_allocated);
> +		else
> +			val = page_counter_read(&cg_proto->memory_allocated);
> +		val *= PAGE_SIZE;
>  		break;
>  	case RES_FAILCNT:
> +		if (!cg_proto)
> +			return 0;
> +		val = cg_proto->memory_allocated.failcnt;
> +		break;
>  	case RES_MAX_USAGE:
> -		val = tcp_read_stat(memcg, cft->private, 0);
> +		if (!cg_proto)
> +			return 0;
> +		val = cg_proto->memory_allocated.watermark;
> +		val *= PAGE_SIZE;
>  		break;
>  	default:
>  		BUG();
[...]

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
