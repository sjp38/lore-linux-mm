Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0B13B6B0028
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 14:22:00 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id d23so2744081wmd.1
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 11:21:59 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id l92si153069edl.455.2018.03.21.11.21.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 21 Mar 2018 11:21:58 -0700 (PDT)
Date: Wed, 21 Mar 2018 14:23:08 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC] mm: memory.low heirarchical behavior
Message-ID: <20180321182308.GA28232@cmpxchg.org>
References: <20180320223353.5673-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180320223353.5673-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Roman,

On Tue, Mar 20, 2018 at 10:33:53PM +0000, Roman Gushchin wrote:
> This patch aims to address an issue in current memory.low semantics,
> which makes it hard to use it in a hierarchy, where some leaf memory
> cgroups are more valuable than others.
> 
> For example, there are memcgs A, A/B, A/C, A/D and A/E:
> 
>   A      A/memory.low = 2G, A/memory.current = 6G
>  //\\
> BC  DE   B/memory.low = 3G  B/memory.usage = 2G
>          C/memory.low = 1G  C/memory.usage = 2G
>          D/memory.low = 0   D/memory.usage = 2G
> 	 E/memory.low = 10G E/memory.usage = 0
> 
> If we apply memory pressure, B, C and D are reclaimed at
> the same pace while A's usage exceeds 2G.
> This is obviously wrong, as B's usage is fully below B's memory.low,
> and C has 1G of protection as well.
> Also, A is pushed to the size, which is less than A's 2G memory.low,
> which is also wrong.
> 
> A simple bash script (provided below) can be used to reproduce
> the problem. Current results are:
>   A:    1430097920
>   A/B:  711929856
>   A/C:  717426688
>   A/D:  741376
>   A/E:  0

Yes, this is a problem. And the behavior with your patch looks much
preferable over the status quo.

> To address the issue a concept of effective memory.low is introduced.
> Effective memory.low is always equal or less than original memory.low.
> In a case, when there is no memory.low overcommittment (and also for
> top-level cgroups), these two values are equal.
> Otherwise it's a part of parent's effective memory.low, calculated as
> a cgroup's memory.low usage divided by sum of sibling's memory.low
> usages (under memory.low usage I mean the size of actually protected
> memory: memory.current if memory.current < memory.low, 0 otherwise).

This hurts my brain.

Why is memory.current == memory.low (which should fully protect
memory.current) a low usage of 0?

Why is memory.current > memory.low not a low usage of memory.low?

I.e. shouldn't this be low_usage = min(memory.current, memory.low)?

> It's necessary to track the actual usage, because otherwise an empty
> cgroup with memory.low set (A/E in my example) will affect actual
> memory distribution, which makes no sense.

Yep, that makes sense.

> Effective memory.low is always capped by memory.low, set by user.
> That means it's not possible to become a larger guarantee than
> memory.low set by a user, even if corresponding part of parent's
> guarantee is larger. This matches existing semantics.

That's a complicated sentence for an intuitive concept: yes, we
wouldn't expect a group's protected usage to exceed its own memory.low
setting just because the parent's is higher. I'd drop this part.

> Calculating effective memory.low can be done in the reclaim path,
> as we conveniently traversing the cgroup tree from top to bottom and
> check memory.low on each level. So, it's a perfect place to calculate
> effective memory low and save it to use it for children cgroups.
> 
> This also eliminates a need to traverse the cgroup tree from bottom
> to top each time to check if parent's guarantee is not exceeded.
> 
> Setting/resetting effective memory.low is intentionally racy, but
> it's fine and shouldn't lead to any significant differences in
> actual memory distribution.
> 
> With this patch applied results are matching the expectations:
>   A:    2146160640
>   A/B:  1427795968
>   A/C:  717705216
>   A/D:  659456
>   A/E:  0

Very cool results.

Below some comments on the implementation.

> @@ -180,8 +180,12 @@ struct mem_cgroup {
>  
>  	/* Normal memory consumption range */
>  	unsigned long low;
> +	unsigned long e_low;
>  	unsigned long high;

I wouldn't mix those. low and high are what the user configures, e_low
is an internal state we calculate and maintain for dynamic enforcing.

Keep e_low with the low_usage variables?

Also please drop the underscore. elow is easier on the eyes.

> +	atomic_long_t low_usage;
> +	atomic_long_t s_low_usage;

children_low_usage would be clearer, I think.

> @@ -1672,6 +1672,36 @@ void unlock_page_memcg(struct page *page)
>  }
>  EXPORT_SYMBOL(unlock_page_memcg);
>  
> +static void memcg_update_low(struct mem_cgroup *memcg)
> +{
> +	unsigned long usage, low_usage, prev_low_usage;
> +	struct mem_cgroup *parent;
> +	long delta;
> +
> +	do {
> +		parent = parent_mem_cgroup(memcg);
> +		if (!parent || mem_cgroup_is_root(parent))
> +			break;
> +
> +		if (!memcg->low && !atomic_long_read(&memcg->low_usage))
> +			break;
> +
> +		usage = page_counter_read(&memcg->memory);
> +		if (usage < memcg->low)
> +			low_usage = usage;
> +		else
> +			low_usage = 0;
> +
> +		prev_low_usage = atomic_long_xchg(&memcg->low_usage, low_usage);
> +		delta = low_usage - prev_low_usage;
> +		if (delta == 0)
> +			break;
> +
> +		atomic_long_add(delta, &parent->s_low_usage);
> +
> +	} while ((memcg = parent));
> +}

This code could use some comments ;)

Something that explains that we're tracking the combined usage of the
children and what we're using that information for.

The conceptual descriptions you have in the changelog should be in the
code somewher, to give a high level overview of how we're enforcing
the low settings hierarchically.

> @@ -1726,6 +1756,7 @@ static void drain_stock(struct memcg_stock_pcp *stock)
>  		page_counter_uncharge(&old->memory, stock->nr_pages);
>  		if (do_memsw_account())
>  			page_counter_uncharge(&old->memsw, stock->nr_pages);
> +		memcg_update_low(old);
>  		css_put_many(&old->css, stock->nr_pages);
>  		stock->nr_pages = 0;

The function is called every time the page counter changes and walks
up the hierarchy exactly the same. That is a good sign that the low
usage tracking should really be part of the page counter code itself.

I think you also have to call it when memory.low changes, as that may
increase or decrease low usage just as much as when usage changes.

> @@ -5650,12 +5688,29 @@ bool mem_cgroup_low(struct mem_cgroup *root, struct mem_cgroup *memcg)
>  	if (memcg == root)
>  		return false;
>  
> -	for (; memcg != root; memcg = parent_mem_cgroup(memcg)) {
> -		if (page_counter_read(&memcg->memory) >= memcg->low)
> -			return false;
> +	e_low = memcg->low;
> +	usage = page_counter_read(&memcg->memory);
> +
> +	parent = parent_mem_cgroup(memcg);
> +	if (mem_cgroup_is_root(parent))
> +		goto exit;

Shouldn't this test parent == root?

>
> +	p_e_low = parent->e_low;
> +	e_low = min(e_low, p_e_low);

These names need help! ;) elow and parent_elow?

> +	if (e_low && p_e_low) {
> +		low_usage = min(usage, memcg->low);
> +		s_low_usage = atomic_long_read(&parent->s_low_usage);

How about

		siblings_low_usage = atomic_long_read(&parent->children_low_usage);

It's a bit long, but much clearer. To keep the line short, you can
invert the branch with a goto exit and save one indentation level.

> +		if (!low_usage || !s_low_usage)
> +			goto exit;
> +
> +		e_low = min(e_low, p_e_low * low_usage / s_low_usage);
>  	}
>  
> -	return true;
> +exit:
> +	memcg->e_low = e_low;

The function has the name of a simple predicate tester, but because we
calculate effective low on the go it only works when used as part of a
topdown hierarchy walk. I cannot think of a good way of making this
less surprising, but please at least document this prominently.

Thanks!
