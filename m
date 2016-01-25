Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 06CA96B0258
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 11:39:57 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id l65so71502050wmf.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 08:39:56 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id i74si25419288wmc.39.2016.01.25.08.39.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 08:39:55 -0800 (PST)
Date: Mon, 25 Jan 2016 11:39:07 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] mm: workingset: make workingset detection logic memcg
 aware
Message-ID: <20160125163907.GA29291@cmpxchg.org>
References: <1453654576-8371-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453654576-8371-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Jan 24, 2016 at 07:56:16PM +0300, Vladimir Davydov wrote:
> Currently, inactive_age is maintained per zone, which results in
> unexpected file page activations in case memory cgroups are used. For
> example, if the total number of active pages is big, a memory cgroup
> might get every refaulted file page activated even if refault distance
> is much greater than the number of active file pages in the cgroup. This
> patch fixes this issue by making inactive_age per lruvec.

Argh!!

It's great that you're still interested in this and kept working on
it. I just regret that I worked on the same stuff the last couple days
without pinging you before picking it up. Oh well...

However, my patches are sufficiently different that I think it makes
sense to discuss them both and figure out the best end result.  I have
some comments below and will followup this email with my version.

> The patch is pretty straightforward and self-explaining, but there are
> two things that should be noted:
> 
>  - workingset_{eviction,activation} need to get lruvec given a page.
>    On the default hierarchy one can safely access page->mem_cgroup
>    provided the page is pinned, but on the legacy hierarchy a page can
>    be migrated from one cgroup to another at any moment, so extra care
>    must be taken to assure page->mem_cgroup will stay put.
> 
>    workingset_eviction is passed a locked page, so it is safe to use
>    page->mem_cgroup in this function. workingset_activation is trickier:
>    it is called from mark_page_accessed, where the page is not
>    necessarily locked. To protect it against page->mem_cgroup change, we
>    move it to __activate_page, which is called by mark_page_accessed
>    once there's enough pages on percpu pagevec. This function is called
>    with zone->lru_lock held, which rules out page charge migration.

When a page moves to another cgroup at the same time it's activated,
there really is no wrong lruvec to age. Both would be correct. The
locking guarantees a stable answer, but we don't need it here. It's
enough to take the rcu lock here to ensure page_memcg() isn't freed.

>  - To calculate refault distance correctly even in case a page is
>    refaulted by a different cgroup, we need to store memcg id in shadow
>    entry. There's no problem with it on 64-bit, but on 32-bit there's
>    not much space left in radix tree slot after storing information
>    about node, zone, and memory cgroup, so we can't just save eviction
>    counter as is, because it would trim max refault distance making it
>    unusable.
> 
>    To overcome this problem, we increase refault distance granularity,
>    as proposed by Johannes Weiner. We disregard 10 least significant
>    bits of eviction counter. This reduces refault distance accuracy to
>    4MB, which is still fine. With the default NODE_SHIFT (3) this leaves
>    us 9 bits for storing eviction counter, hence maximal refault
>    distance will be 2GB, which should be enough for 32-bit systems.

If we limit it to 2G it becomes a clear-cut correctness issue once you
have more memory. Instead, we should continue to stretch out the
distance with an ever-increasing bucket size. The more memory you
have, the less important the granularity becomes anyway. With 8G, an
8M granularity is still okay, and so forth. And once we get beyond a
certain point, and it creates problems for people, it should be fair
enough to recommend upgrading to 64 bit.

> @@ -152,8 +152,72 @@
>   * refault distance will immediately activate the refaulting page.
>   */
>  
> -static void *pack_shadow(unsigned long eviction, struct zone *zone)
> +#ifdef CONFIG_MEMCG
> +/*
> + * On 32-bit there is not much space left in radix tree slot after
> + * storing information about node, zone, and memory cgroup, so we
> + * disregard 10 least significant bits of eviction counter. This
> + * reduces refault distance accuracy to 4MB, which is still fine.
> + *
> + * With the default NODE_SHIFT (3) this leaves us 9 bits for storing
> + * eviction counter, hence maximal refault distance will be 2GB, which
> + * should be enough for 32-bit systems.
> + */
> +#ifdef CONFIG_64BIT
> +# define REFAULT_DISTANCE_GRANULARITY		0
> +#else
> +# define REFAULT_DISTANCE_GRANULARITY		10
> +#endif
> +
> +static unsigned long pack_shadow_memcg(unsigned long eviction,
> +				       struct mem_cgroup *memcg)
> +{
> +	if (mem_cgroup_disabled())
> +		return eviction;
> +
> +	eviction >>= REFAULT_DISTANCE_GRANULARITY;
> +	eviction = (eviction << MEM_CGROUP_ID_SHIFT) | mem_cgroup_id(memcg);
> +	return eviction;
> +}
> +
> +static unsigned long unpack_shadow_memcg(unsigned long entry,
> +					 unsigned long *mask,
> +					 struct mem_cgroup **memcg)
> +{
> +	if (mem_cgroup_disabled()) {
> +		*memcg = NULL;
> +		return entry;
> +	}
> +
> +	rcu_read_lock();
> +	*memcg = mem_cgroup_from_id(entry & MEM_CGROUP_ID_MAX);
> +	rcu_read_unlock();
> +
> +	entry >>= MEM_CGROUP_ID_SHIFT;
> +	entry <<= REFAULT_DISTANCE_GRANULARITY;
> +	*mask >>= MEM_CGROUP_ID_SHIFT - REFAULT_DISTANCE_GRANULARITY;
> +	return entry;
> +}
> +#else /* !CONFIG_MEMCG */
> +static unsigned long pack_shadow_memcg(unsigned long eviction,
> +				       struct mem_cgroup *memcg)
> +{
> +	return eviction;
> +}
> +
> +static unsigned long unpack_shadow_memcg(unsigned long entry,
> +					 unsigned long *mask,
> +					 struct mem_cgroup **memcg)
> +{
> +	*memcg = NULL;
> +	return entry;
> +}
> +#endif /* CONFIG_MEMCG */
> +
> +static void *pack_shadow(unsigned long eviction, struct zone *zone,
> +			 struct mem_cgroup *memcg)
>  {
> +	eviction = pack_shadow_memcg(eviction, memcg);
>  	eviction = (eviction << NODES_SHIFT) | zone_to_nid(zone);
>  	eviction = (eviction << ZONES_SHIFT) | zone_idx(zone);
>  	eviction = (eviction << RADIX_TREE_EXCEPTIONAL_SHIFT);

For !CONFIG_MEMCG, we can define MEMCG_ID_SHIFT to 0 and pass in a
cssid of 0. That would save much of the special casing here.

> @@ -213,10 +282,16 @@ static void unpack_shadow(void *shadow,
>  void *workingset_eviction(struct address_space *mapping, struct page *page)
>  {
>  	struct zone *zone = page_zone(page);
> +	struct mem_cgroup *memcg = page_memcg(page);
> +	struct lruvec *lruvec;
>  	unsigned long eviction;
>  
> -	eviction = atomic_long_inc_return(&zone->inactive_age);
> -	return pack_shadow(eviction, zone);
> +	if (!mem_cgroup_disabled())
> +		mem_cgroup_get(memcg);
> +
> +	lruvec = mem_cgroup_zone_lruvec(zone, memcg);
> +	eviction = atomic_long_inc_return(&lruvec->inactive_age);
> +	return pack_shadow(eviction, zone, memcg);

I don't think we need to hold a reference to the memcg here, it should
be enough to verify whether the cssid is still existent upon refault.

What could theoretically happen then is that the original memcg gets
deleted, a new one will reuse the same id and then refault the same
pages. However, there are two things that should make this acceptable:
1. a couple pages don't matter in this case, and sharing data between
cgroups on a large scale already leads to weird accounting artifacts
in other places; this wouldn't be much different. 2. from a system
perspective, those pages were in fact recently evicted, so even if we
activate them by accident in the new cgroup, it wouldn't be entirely
unreasonable. The workload will shake out what the true active list
frequency is on its own.

So I think we can just do away with the reference counting for now,
and reconsider it should the false sharing in this case create new
problems that are worse than existing consequences of false sharing.

> @@ -230,13 +305,22 @@ void *workingset_eviction(struct address_space *mapping, struct page *page)
>   */
>  bool workingset_refault(void *shadow)
>  {
> -	unsigned long refault_distance;
> +	unsigned long refault_distance, nr_active;
>  	struct zone *zone;
> +	struct mem_cgroup *memcg;
> +	struct lruvec *lruvec;
>  
> -	unpack_shadow(shadow, &zone, &refault_distance);
> +	unpack_shadow(shadow, &zone, &memcg, &refault_distance);
>  	inc_zone_state(zone, WORKINGSET_REFAULT);
>  
> -	if (refault_distance <= zone_page_state(zone, NR_ACTIVE_FILE)) {
> +	if (!mem_cgroup_disabled()) {
> +		lruvec = mem_cgroup_zone_lruvec(zone, memcg);
> +		nr_active = mem_cgroup_get_lru_size(lruvec, LRU_ACTIVE_FILE);
> +		mem_cgroup_put(memcg);
> +	} else
> +		nr_active = zone_page_state(zone, NR_ACTIVE_FILE);

This is basically get_lru_size(), so I reused that instead.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
