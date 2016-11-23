Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1A8656B0285
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 09:35:23 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id k19so24045534iod.4
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 06:35:23 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id c82si23947879iof.144.2016.11.23.06.35.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 Nov 2016 06:35:22 -0800 (PST)
Subject: Re: [RFC 2/2] mm, oom: do not enfore OOM killer for __GFP_NOFAIL automatically
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20161123064925.9716-1-mhocko@kernel.org>
	<20161123064925.9716-3-mhocko@kernel.org>
In-Reply-To: <20161123064925.9716-3-mhocko@kernel.org>
Message-Id: <201611232335.JFC30797.VOOtOMFJFHLQSF@I-love.SAKURA.ne.jp>
Date: Wed, 23 Nov 2016 23:35:10 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: vbabka@suse.cz, rientjes@google.com, hannes@cmpxchg.org, mgorman@suse.de, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mhocko@suse.com

Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> __alloc_pages_may_oom makes sure to skip the OOM killer depending on
> the allocation request. This includes lowmem requests, costly high
> order requests and others. For a long time __GFP_NOFAIL acted as an
> override for all those rules. This is not documented and it can be quite
> surprising as well. E.g. GFP_NOFS requests are not invoking the OOM
> killer but GFP_NOFS|__GFP_NOFAIL does so if we try to convert some of
> the existing open coded loops around allocator to nofail request (and we
> have done that in the past) then such a change would have a non trivial
> side effect which is not obvious. Note that the primary motivation for
> skipping the OOM killer is to prevent from pre-mature invocation.
> 
> The exception has been added by 82553a937f12 ("oom: invoke oom killer
> for __GFP_NOFAIL"). The changelog points out that the oom killer has to
> be invoked otherwise the request would be looping for ever. But this
> argument is rather weak because the OOM killer doesn't really guarantee
> any forward progress for those exceptional cases - e.g. it will hardly
> help to form costly order - I believe we certainly do not want to kill
> all processes and eventually panic the system just because there is a
> nasty driver asking for order-9 page with GFP_NOFAIL not realizing all
> the consequences - it is much better this request would loop for ever
> than the massive system disruption, lowmem is also highly unlikely to be
> freed during OOM killer and GFP_NOFS request could trigger while there
> is still a lot of memory pinned by filesystems.
> 
> This patch simply removes the __GFP_NOFAIL special case in order to have
> a more clear semantic without surprising side effects. Instead we do
> allow nofail requests to access memory reserves to move forward in both
> cases when the OOM killer is invoked and when it should be supressed.
> __alloc_pages_nowmark helper has been introduced for that purpose.

__alloc_pages_nowmark() likely works if order is 0, but there is no
guarantee that __alloc_pages_nowmark() can find order > 0 pages.
If __alloc_pages_nowmark() called by __GFP_NOFAIL could not find pages
with requested order due to fragmentation, __GFP_NOFAIL should invoke
the OOM killer. I believe that risking kill all processes and panic the
system eventually is better than __GFP_NOFAIL livelock.

I'm not happy that the caller cannot invoke the OOM killer unless __GFP_FS
or __GFP_NOFAIL is specified. I think we should get rid of the concept of
premature OOM killer invocation. That is, whenever requested pages cannot
be allocated and the caller does not want to fail, invoking the OOM killer
is no longer premature. Unfortunately, there seems to be cases where the
caller needs to use GFP_NOFS rather than GFP_KERNEL due to unclear dependency
between memory allocation by system calls and memory reclaim by filesystems.
But memory reclaim by filesystems are not the fault of userspace processes
which issued system calls. It is unfair to force legitimate processes to fail
system calls with ENOMEM when GFP_NOFS is used inside system calls instead of
killing memory hog processes using the OOM killer. The root cause is that we
blindly treat all memory allocation requests evenly using the same watermark
(with rough-grained exceptions such as __GFP_HIGH) and allow lower priority
memory allocations (e.g. memory for buffered writes) to consume memory to the
level where higher priority memory allocations (e.g. memory for disk I/O) has
to retry looping without invoking the OOM killer, instead of using different
watermarks based on purpose/importance/priority of individual memory
allocation requests so that higher priority memory allocations can invoke
the OOM killer.



> @@ -3725,6 +3738,14 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		 */
>  		WARN_ON_ONCE(order > PAGE_ALLOC_COSTLY_ORDER);
>  
> +		/*
> +		 * Help non-failing allocations by giving them access to memory
> +		 * reserves
> +		 */
> +		page = __alloc_pages_nowmark(gfp_mask, order, ac);
> +		if (page)
> +			goto got_pg;
> +

Should no_progress_loops be reset to 0 before retrying?

>  		cond_resched();
>  		goto retry;
>  	}
> -- 
> 2.10.2
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
