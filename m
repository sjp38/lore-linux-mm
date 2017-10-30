Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5CF4F6B0038
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 10:18:26 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id y7so6038154wmd.18
        for <linux-mm@kvack.org>; Mon, 30 Oct 2017 07:18:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i15si10021900wre.438.2017.10.30.07.18.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Oct 2017 07:18:19 -0700 (PDT)
Date: Mon, 30 Oct 2017 15:18:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Try last second allocation before and after
 selecting an OOM victim.
Message-ID: <20171030141815.lk76bfetmspf7f4x@dhcp22.suse.cz>
References: <1509178029-10156-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1509178029-10156-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Manish Jaggi <mjaggi@caviumnetworks.com>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Vlastimil Babka <vbabka@suse.cz>

On Sat 28-10-17 17:07:09, Tetsuo Handa wrote:
> This patch splits last second allocation attempt into two locations, once
> before selecting an OOM victim and again after selecting an OOM victim,
> and uses normal watermark for last second allocation attempts.

Why do we need both?

> As of linux-2.6.11, nothing prevented from concurrently calling
> out_of_memory(). TIF_MEMDIE test in select_bad_process() tried to avoid
> needless OOM killing. Thus, it was safe to do __GFP_DIRECT_RECLAIM
> allocation (apart from which watermark should be used) just before
> calling out_of_memory().
> 
> As of linux-2.6.24, try_set_zone_oom() was added to
> __alloc_pages_may_oom() by commit ff0ceb9deb6eb017 ("oom: serialize out
> of memory calls") which effectively started acting as a kind of today's
> mutex_trylock(&oom_lock).
> 
> As of linux-4.2, try_set_zone_oom() was replaced with oom_lock by
> commit dc56401fc9f25e8f ("mm: oom_kill: simplify OOM killer locking").
> At least by this time, it became no longer safe to do
> __GFP_DIRECT_RECLAIM allocation with oom_lock held.
> 
> And as of linux-4.13, last second allocation attempt stopped using
> __GFP_DIRECT_RECLAIM by commit e746bf730a76fe53 ("mm,page_alloc: don't
> call __node_reclaim() with oom_lock held.").
> 
> Therefore, there is no longer valid reason to use ALLOC_WMARK_HIGH for
> last second allocation attempt [1].

Another reason to use the high watermark as explained by Andrea was
"
: Elaborating the comment: the reason for the high wmark is to reduce
: the likelihood of livelocks and be sure to invoke the OOM killer, if
: we're still under pressure and reclaim just failed. The high wmark is
: used to be sure the failure of reclaim isn't going to be ignored. If
: using the min wmark like you propose there's risk of livelock or
: anyway of delayed OOM killer invocation.
"

How is that affected by changes in locking you discribe above?

> And this patch changes to do normal
> allocation attempt, with handling of ALLOC_OOM added in order to mitigate
> extra OOM victim selection problem reported by Manish Jaggi [2].
> 
> Doing really last second allocation attempt after selecting an OOM victim
> will also help the OOM reaper to start reclaiming memory without waiting
> for oom_lock to be released.

The changelog is much more obscure than it really needs to be. You fail
to explain _why_ we need this and and _what_ the actual problem is. You
are simply drowning in details here (btw. this is not the first time
your changelog has this issues). Try to focus on _what_ is the problem
_why_ do we care and _how_ are you addressing it.
 
[...]

> +struct page *alloc_pages_before_oomkill(struct oom_control *oc)
> +{
> +	/*
> +	 * Make sure that this allocation attempt shall not depend on
> +	 * __GFP_DIRECT_RECLAIM && !__GFP_NORETRY allocation, for the caller is
> +	 * already holding oom_lock.
> +	 */
> +	const gfp_t gfp_mask = oc->gfp_mask & ~__GFP_DIRECT_RECLAIM;
> +	struct alloc_context *ac = oc->ac;
> +	unsigned int alloc_flags = gfp_to_alloc_flags(gfp_mask);
> +	const int reserve_flags = __gfp_pfmemalloc_flags(gfp_mask);
> +
> +	/* Need to update zonelist if selected as OOM victim. */
> +	if (reserve_flags) {
> +		alloc_flags = reserve_flags;
> +		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
> +		ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
> +					ac->high_zoneidx, ac->nodemask);
> +	}

Why do we need this zone list rebuilding?

> +	return get_page_from_freelist(gfp_mask, oc->order, alloc_flags, ac);
> +}
> +
>  static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
>  		int preferred_nid, nodemask_t *nodemask,
>  		struct alloc_context *ac, gfp_t *alloc_mask,
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
