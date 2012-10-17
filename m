Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 526926B0068
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 18:12:16 -0400 (EDT)
Date: Wed, 17 Oct 2012 15:12:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 06/14] memcg: kmem controller infrastructure
Message-Id: <20121017151214.e3d2aa3b.akpm@linux-foundation.org>
In-Reply-To: <1350382611-20579-7-git-send-email-glommer@parallels.com>
References: <1350382611-20579-1-git-send-email-glommer@parallels.com>
	<1350382611-20579-7-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Tue, 16 Oct 2012 14:16:43 +0400
Glauber Costa <glommer@parallels.com> wrote:

> This patch introduces infrastructure for tracking kernel memory pages to
> a given memcg. This will happen whenever the caller includes the flag
> __GFP_KMEMCG flag, and the task belong to a memcg other than the root.
> 
> In memcontrol.h those functions are wrapped in inline acessors.  The
> idea is to later on, patch those with static branches, so we don't incur
> any overhead when no mem cgroups with limited kmem are being used.
> 
> Users of this functionality shall interact with the memcg core code
> through the following functions:
> 
> memcg_kmem_newpage_charge: will return true if the group can handle the
>                            allocation. At this point, struct page is not
>                            yet allocated.
> 
> memcg_kmem_commit_charge: will either revert the charge, if struct page
>                           allocation failed, or embed memcg information
>                           into page_cgroup.
> 
> memcg_kmem_uncharge_page: called at free time, will revert the charge.
> 
> ...
>
> +static __always_inline bool
> +memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **memcg, int order)
> +{
> +	if (!memcg_kmem_enabled())
> +		return true;
> +
> +	/*
> +	 * __GFP_NOFAIL allocations will move on even if charging is not
> +	 * possible. Therefore we don't even try, and have this allocation
> +	 * unaccounted. We could in theory charge it with
> +	 * res_counter_charge_nofail, but we hope those allocations are rare,
> +	 * and won't be worth the trouble.
> +	 */
> +	if (!(gfp & __GFP_KMEMCG) || (gfp & __GFP_NOFAIL))
> +		return true;
> +	if (in_interrupt() || (!current->mm) || (current->flags & PF_KTHREAD))
> +		return true;
> +
> +	/* If the test is dying, just let it go. */
> +        if (unlikely(test_thread_flag(TIF_MEMDIE)
> +                     || fatal_signal_pending(current)))
> +		return true;
> +
> +	return __memcg_kmem_newpage_charge(gfp, memcg, order);
> +}

That's a big function!  Why was it __always_inline?  I'd have thought
it would be better to move the code after memcg_kmem_enabled() out of
line.

Do we actually need to test PF_KTHREAD when current->mm == NULL? 
Perhaps because of aio threads whcih temporarily adopt a userspace mm?

> +/**
> + * memcg_kmem_uncharge_page: uncharge pages from memcg
> + * @page: pointer to struct page being freed
> + * @order: allocation order.
> + *
> + * there is no need to specify memcg here, since it is embedded in page_cgroup
> + */
> +static __always_inline void
> +memcg_kmem_uncharge_page(struct page *page, int order)
> +{
> +	if (memcg_kmem_enabled())
> +		__memcg_kmem_uncharge_page(page, order);
> +}
> +
> +/**
> + * memcg_kmem_commit_charge: embeds correct memcg in a page
> + * @page: pointer to struct page recently allocated
> + * @memcg: the memcg structure we charged against
> + * @order: allocation order.
> + *
> + * Needs to be called after memcg_kmem_newpage_charge, regardless of success or
> + * failure of the allocation. if @page is NULL, this function will revert the
> + * charges. Otherwise, it will commit the memcg given by @memcg to the
> + * corresponding page_cgroup.
> + */
> +static __always_inline void
> +memcg_kmem_commit_charge(struct page *page, struct mem_cgroup *memcg, int order)
> +{
> +	if (memcg_kmem_enabled() && memcg)
> +		__memcg_kmem_commit_charge(page, memcg, order);
> +}

I suspect the __always_inline's here are to do with static branch
trickery.  A code comment is warranted if so?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
