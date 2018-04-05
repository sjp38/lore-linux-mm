Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2F5F06B0007
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 11:00:28 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id b9so8102713wrj.15
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 08:00:28 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id t56si2268778edm.341.2018.04.05.08.00.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 05 Apr 2018 08:00:24 -0700 (PDT)
Date: Thu, 5 Apr 2018 11:00:19 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC] mm: memory.low heirarchical behavior
Message-ID: <20180405150019.GA1959@cmpxchg.org>
References: <20180320223353.5673-1-guro@fb.com>
 <20180321182308.GA28232@cmpxchg.org>
 <20180321190801.GA22452@castle.DHCP.thefacebook.com>
 <20180404170700.GA2161@cmpxchg.org>
 <20180405135450.GA5396@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180405135450.GA5396@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Apr 05, 2018 at 02:54:57PM +0100, Roman Gushchin wrote:
> On Wed, Apr 04, 2018 at 01:07:00PM -0400, Johannes Weiner wrote:
> > @@ -9,8 +9,13 @@
> >  struct page_counter {
> >  	atomic_long_t count;
> >  	unsigned long limit;
> > +	unsigned long protected;
> >  	struct page_counter *parent;
> >  
> > +	/* Hierarchical, proportional protection */
> > +	atomic_long_t protected_count;
> > +	atomic_long_t children_protected_count;
> > +
> 
> I followed your approach, but without introducing the new "protected" term.
> It looks cute in the usage tracking part, but a bit weird in mem_cgroup_low(),
> and it's not clear how to reuse it for memory.min. I think, we shouldn't
> introduce a new term without strict necessity.

I just found the "low_usage" term a bit confusing, but it's true, once
we have both min and low, "protected" is not descriptive enough.

> Also, I moved the low field from memcg to page_counter, what made
> the code simpler and cleaner.

Yep, makes sense.

> @@ -178,8 +178,7 @@ struct mem_cgroup {
>  	struct page_counter kmem;
>  	struct page_counter tcpmem;
>  
> -	/* Normal memory consumption range */
> -	unsigned long low;
> +	/* Upper bound of normal memory consumption range */
>  	unsigned long high;
>  
>  	/* Range enforcement for interrupt charges */
> diff --git a/include/linux/page_counter.h b/include/linux/page_counter.h
> index c15ab80ad32d..e916595fb700 100644
> --- a/include/linux/page_counter.h
> +++ b/include/linux/page_counter.h
> @@ -9,8 +9,14 @@
>  struct page_counter {
>  	atomic_long_t count;
>  	unsigned long limit;
> +	unsigned long low;
>  	struct page_counter *parent;
>  
> +	/* effective memory.low and memory.low usage tracking */
> +	unsigned long elow;
> +	atomic_long_t low_usage;
> +	atomic_long_t children_low_usage;

It's still a bit messy and confusing.

1. It uses both "usage" and "count" for the same thing. Can we pick
one? I wouldn't mind changing count -> usage throughout.

2. "Limit" is its own term, but we're starting to add low and min now,
which are more cgroup-specific. The idea with page_counter (previously
res_counter) was to be generic infrastructure, but after a decade no
other user has materialized. We can just follow the cgroup naming IMO.

3. The page counter is always hierarchical and so "children_" is the
implied default. I think we should point out when it's local instead.

usage, max, low, (elow, low_usage, children_low_usage)?

> @@ -5612,36 +5612,69 @@ struct cgroup_subsys memory_cgrp_subsys = {
>   * @root: the top ancestor of the sub-tree being checked
>   * @memcg: the memory cgroup to check
>   *
> - * Returns %true if memory consumption of @memcg, and that of all
> - * ancestors up to (but not including) @root, is below the normal range.
> + * Returns %true if memory consumption of @memcg is below the normal range.

Can you please add something like:

    * WARNING: This function is not stateless! It can only be used as part
    *          of a top-down tree iteration, not for isolated queries.

here?

> - * @root is exclusive; it is never low when looked at directly and isn't
> - * checked when traversing the hierarchy.
> + * @root is exclusive; it is never low when looked at directly
>   *
> - * Excluding @root enables using memory.low to prioritize memory usage
> - * between cgroups within a subtree of the hierarchy that is limited by
> - * memory.high or memory.max.
> + * To provide a proper hierarchical behavior, effective memory.low value
> + * is used.
>   *
> - * For example, given cgroup A with children B and C:
> + * Effective memory.low is always equal or less than the original memory.low.
> + * If there is no memory.low overcommittment (which is always true for
> + * top-level memory cgroups), these two values are equal.
> + * Otherwise, it's a part of parent's effective memory.low,
> + * calculated as a cgroup's memory.low usage divided by sum of sibling's
> + * memory.low usages, where memory.low usage is the size of actually
> + * protected memory.
>   *
> - *    A
> - *   / \
> - *  B   C
> + *                                             low_usage
> + * elow = min( memory.low, parent->elow * ------------------ ),
> + *                                        siblings_low_usage
>   *
> - * and
> + *             | memory.current, if memory.current < memory.low
> + * low_usage = |
> +	       | 0, otherwise.
>   *
> - *  1. A/memory.current > A/memory.high
> - *  2. A/B/memory.current < A/B/memory.low
> - *  3. A/C/memory.current >= A/C/memory.low
>   *
> - * As 'A' is high, i.e. triggers reclaim from 'A', and 'B' is low, we
> - * should reclaim from 'C' until 'A' is no longer high or until we can
> - * no longer reclaim from 'C'.  If 'A', i.e. @root, isn't excluded by
> - * mem_cgroup_low when reclaming from 'A', then 'B' won't be considered
> - * low and we will reclaim indiscriminately from both 'B' and 'C'.
> + * Such definition of the effective memory.low provides the expected
> + * hierarchical behavior: parent's memory.low value is limiting
> + * children, unprotected memory is reclaimed first and cgroups,
> + * which are not using their guarantee do not affect actual memory
> + * distribution.
> + *
> + * For example, if there are memcgs A, A/B, A/C, A/D and A/E:
> + *
> + *     A      A/memory.low = 2G, A/memory.current = 6G
> + *    //\\
> + *   BC  DE   B/memory.low = 3G  B/memory.current = 2G
> + *            C/memory.low = 1G  C/memory.current = 2G
> + *            D/memory.low = 0   D/memory.current = 2G
> + *            E/memory.low = 10G E/memory.current = 0
> + *
> + * and the memory pressure is applied, the following memory distribution
> + * is expected (approximately):
> + *
> + *     A/memory.current = 2G
> + *
> + *     B/memory.current = 1.3G
> + *     C/memory.current = 0.6G
> + *     D/memory.current = 0
> + *     E/memory.current = 0
> + *
> + * These calculations require constant tracking of the actual low usages
> + * (see propagate_protected()), as well as recursive calculation of

           propagate_low_usage()

> + * effective memory.low values. But as we do call mem_cgroup_low()
> + * path for each memory cgroup top-down from the reclaim,
> + * it's possible to optimize this part, and save calculated elow
> + * for next usage. This part is intentionally racy, but it's ok,
> + * as memory.low is a best-effort mechanism.
>   */
>  bool mem_cgroup_low(struct mem_cgroup *root, struct mem_cgroup *memcg)
>  {
> +	unsigned long usage, low_usage, siblings_low_usage;
> +	unsigned long elow, parent_elow;
> +	struct mem_cgroup *parent;
> +
>  	if (mem_cgroup_disabled())
>  		return false;
>  
> @@ -5650,12 +5683,31 @@ bool mem_cgroup_low(struct mem_cgroup *root, struct mem_cgroup *memcg)
>  	if (memcg == root)
>  		return false;
>  
> -	for (; memcg != root; memcg = parent_mem_cgroup(memcg)) {
> -		if (page_counter_read(&memcg->memory) >= memcg->low)
> -			return false;
> -	}
> +	elow = memcg->memory.low;
> +	usage = page_counter_read(&memcg->memory);
>  
> -	return true;
> +	parent = parent_mem_cgroup(memcg);
> +	if (parent == root)
> +		goto exit;

This is odd newlining. Group the variable lookups instead and separate
them from the parent == root branch?

> +	parent_elow = READ_ONCE(parent->memory.elow);
> +	elow = min(elow, parent_elow);
> +
> +	if (!elow || !parent_elow)
> +		goto exit;

Like here ^

> +	low_usage = min(usage, memcg->memory.low);
> +	siblings_low_usage = atomic_long_read(
> +		&parent->memory.children_low_usage);
> +	if (!low_usage || !siblings_low_usage)
> +		goto exit;

Then this the same way.

> +	elow = min(elow, parent_elow * low_usage / siblings_low_usage);
> +
> +exit:
> +	memcg->memory.elow = elow;
> +
> +	return usage < elow;

These empty lines seem unnecessary, the label line is already a visual
break in the code flow.

> @@ -13,6 +13,34 @@
>  #include <linux/bug.h>
>  #include <asm/page.h>
>  
> +static void propagate_low_usage(struct page_counter *c, unsigned long usage)
> +{
> +	unsigned long low_usage, old;
> +	long delta;
> +
> +	if (!c->parent)
> +		return;
> +
> +	if (!c->low && !atomic_long_read(&c->low_usage))
> +		return;
> +
> +	if (usage <= c->low)
> +		low_usage = usage;
> +	else
> +		low_usage = 0;
> +
> +	old = atomic_long_xchg(&c->low_usage, low_usage);
> +	delta = low_usage - old;
> +	if (delta)
> +		atomic_long_add(delta, &c->parent->children_low_usage);
> +}
> +
> +void page_counter_set_low(struct page_counter *c, unsigned long nr_pages)
> +{
> +	c->low = nr_pages;
> +	propagate_low_usage(c, atomic_long_read(&c->count));

Actually I think I messed this up in my draft. When one level in the
tree changes its usage or low setting, the low usage needs to be
propagated upward the tree. We do this for charge and try_charge, but
not here. page_counter_set_low() should have an ancestor walk.

Other than that, the patch looks great to me.
