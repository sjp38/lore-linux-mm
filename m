Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6DD7D440417
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 09:50:55 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id z184so2783667pgd.0
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 06:50:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a1si4119522pld.230.2017.11.08.06.50.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Nov 2017 06:50:54 -0800 (PST)
Date: Wed, 8 Nov 2017 15:50:51 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 3/5] mm,oom: Use ALLOC_OOM for OOM victim's last second
 allocation.
Message-ID: <20171108145051.4ah6i4cn3t7l2vrb@dhcp22.suse.cz>
References: <1510138908-6265-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1510138908-6265-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1510138908-6265-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Manish Jaggi <mjaggi@caviumnetworks.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Wed 08-11-17 20:01:46, Tetsuo Handa wrote:
> Manish Jaggi noticed that running LTP oom01/oom02 ltp tests with high core
> count causes random kernel panics when an OOM victim which consumed memory
> in a way the OOM reaper does not help was selected by the OOM killer [1].
> Since commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
> oom_reaped tasks") changed task_will_free_mem(current) in out_of_memory()
> to return false as soon as MMF_OOM_SKIP is set, many threads sharing the
> victim's mm were not able to try allocation from memory reserves after the
> OOM reaper gave up reclaiming memory.
> 
> Therefore, this patch allows OOM victims to use ALLOC_OOM watermark for
> last second allocation attempt.
> 
> [1] http://lkml.kernel.org/r/e6c83a26-1d59-4afd-55cf-04e58bdde188@caviumnetworks.com
> 
> Fixes: 696453e66630ad45 ("mm, oom: task_will_free_mem should skip oom_reaped tasks")
> Reported-by: Manish Jaggi <mjaggi@caviumnetworks.com>
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: David Rientjes <rientjes@google.com>

I do not like the changelog because it doesn't explain the race window
but the patch itself is OK. I have offered a better explanation [1] but
I will not really insist on my wording.
Acked-by: Michal Hocko <mhocko@suse.com>

[1] http://lkml.kernel.org/r/20171101135855.bqg2kuj6ao2cicqi@dhcp22.suse.cz

> ---
>  mm/page_alloc.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 764f24c..fbbc95a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4153,13 +4153,19 @@ struct page *alloc_pages_before_oomkill(const struct oom_control *oc)
>  	 * !__GFP_NORETRY allocation which will never fail due to oom_lock
>  	 * already held. And since this allocation attempt does not sleep,
>  	 * there is no reason we must use high watermark here.
> +	 * But anyway, make sure that OOM victims can try ALLOC_OOM watermark
> +	 * in case they haven't tried ALLOC_OOM watermark.
>  	 */
>  	int alloc_flags = ALLOC_CPUSET | ALLOC_WMARK_HIGH;
>  	gfp_t gfp_mask = oc->gfp_mask | __GFP_HARDWALL;
> +	int reserve_flags;
>  
>  	if (!oc->ac)
>  		return NULL;
>  	gfp_mask &= ~__GFP_DIRECT_RECLAIM;
> +	reserve_flags = __gfp_pfmemalloc_flags(gfp_mask);
> +	if (reserve_flags)
> +		alloc_flags = reserve_flags;
>  	return get_page_from_freelist(gfp_mask, oc->order, alloc_flags, oc->ac);
>  }
>  
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
