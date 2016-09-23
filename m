Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 22DFC6B0278
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 04:29:56 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v67so211872254pfv.1
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 01:29:56 -0700 (PDT)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTP id h64si6854524pfk.87.2016.09.23.01.29.53
        for <linux-mm@kvack.org>;
        Fri, 23 Sep 2016 01:29:55 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20160923081555.14645-1-mhocko@kernel.org>
In-Reply-To: <20160923081555.14645-1-mhocko@kernel.org>
Subject: Re: [PATCH] mm: warn about allocations which stall for too long
Date: Fri, 23 Sep 2016 16:29:36 +0800
Message-ID: <007901d21574$9ef82d60$dce88820$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, linux-mm@kvack.org
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'LKML' <linux-kernel@vger.kernel.org>, 'Michal Hocko' <mhocko@suse.com>

> 
> From: Michal Hocko <mhocko@suse.com>
> 
> Currently we do warn only about allocation failures but small
> allocations are basically nofail and they might loop in the page
> allocator for a long time.  Especially when the reclaim cannot make
> any progress - e.g. GFP_NOFS cannot invoke the oom killer and rely on
> a different context to make a forward progress in case there is a lot
> memory used by filesystems.
> 
> Give us at least a clue when something like this happens and warn about
> allocations which take more than 10s. Print the basic allocation context
> information along with the cumulative time spent in the allocation as
> well as the allocation stack. Repeat the warning after every 10 seconds so
> that we know that the problem is permanent rather than ephemeral.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
> 
> Hi,
> I am sending this as an RFC because I am not really sure what is the reasonable
> timeout when to warn. I went with 10s because that should be close to "for ever"
> from the user perspective. But maybe a shorter would be helpful as well?
> I didn't go with a tunable because I would rather not add a new one.
> 
> Thoughts? Ideas?
> 
>  mm/page_alloc.c | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5155485057cb..d5faab8aa94d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3485,6 +3485,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	enum compact_result compact_result;
>  	int compaction_retries = 0;
>  	int no_progress_loops = 0;
> +	unsigned long alloc_start = jiffies;
> +	unsigned int stall_timeout = 10 * HZ;
> 
>  	/*
>  	 * In the slowpath, we sanity check order to avoid ever trying to
> @@ -3659,6 +3661,15 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	else
>  		no_progress_loops++;
> 
> +	/* Make sure we know about allocations which stall for too long */
> +	if (!(gfp_mask & __GFP_NOWARN) && time_after(jiffies, alloc_start + stall_timeout)) {
> +		pr_warn("%s: page alloction stalls for %ums: order:%u mode:%#x(%pGg)\n",
> +				current->comm, jiffies_to_msecs(jiffies-alloc_start),

Better if pid is also printed.
> +				order, gfp_mask, &gfp_mask);
> +		stall_timeout += 10 * HZ;

Alternatively	 alloc_start = jiffies;

> +		dump_stack();
> +	}
> +
>  	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
>  				 did_some_progress > 0, no_progress_loops))
>  		goto retry;
> --
> 2.9.3
> 
thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
