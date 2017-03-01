Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 59E946B0038
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 07:09:51 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id w37so16308343wrc.2
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 04:09:51 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 91si6352155wrk.214.2017.03.01.04.09.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Mar 2017 04:09:50 -0800 (PST)
Date: Wed, 1 Mar 2017 13:09:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] lockdep: Teach lockdep about memalloc_noio_save
Message-ID: <20170301120947.GE1124@dhcp22.suse.cz>
References: <1488367797-27278-1-git-send-email-nborisov@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1488367797-27278-1-git-send-email-nborisov@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <nborisov@suse.com>
Cc: peterz@infradead.org, linux-kernel@vger.kernel.org, vbabka.lkml@gmail.com, linux-mm@kvack.org, mingo@redhat.com

On Wed 01-03-17 13:29:57, Nikolay Borisov wrote:
> Commit 21caf2fc1931 ("mm: teach mm by current context info to not do I/O
> during memory allocation") added the memalloc_noio_(save|restore) functions
> to enable people to modify the MM behavior by disbaling I/O during memory
> allocation. This was further extended in Fixes: 934f3072c17c ("mm: clear 
> __GFP_FS when PF_MEMALLOC_NOIO is set"). memalloc_noio_* functions prevent 
> allocation paths recursing back into the filesystem without explicitly 
> changing the flags for every allocation site. However, lockdep hasn't been 
> keeping up with the changes and it entirely misses handling the memalloc_noio
> adjustments. Instead, it is left to the callers of __lockdep_trace_alloc to 
> call the functino after they have shaven the respective GFP flags. 

I would just add that this might lead to false positives and past the
example you have encountered.

> Let's fix this by making lockdep explicitly do the shaving of respective
> GFP flags. 
> 
> Fixes: 934f3072c17c ("mm: clear __GFP_FS when PF_MEMALLOC_NOIO is set")
> Signed-off-by: Nikolay Borisov <nborisov@suse.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  kernel/locking/lockdep.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> Changes since v2: 
> 	* Incorporate Michal's suggestion of using memalloc_noio_flags explicitly. 
> 	* Tune the commit message to make the problem statement a bit more
> 	descriptive. 
> 
> diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
> index 9812e5dd409e..565506c9e99c 100644
> --- a/kernel/locking/lockdep.c
> +++ b/kernel/locking/lockdep.c
> @@ -2861,6 +2861,8 @@ static void __lockdep_trace_alloc(gfp_t gfp_mask, unsigned long flags)
>  	if (unlikely(!debug_locks))
>  		return;
>  
> +	gfp_mask = memalloc_noio_flags(gfp_mask);
> +
>  	/* no reclaim without waiting on it */
>  	if (!(gfp_mask & __GFP_DIRECT_RECLAIM))
>  		return;
> @@ -3852,7 +3854,7 @@ EXPORT_SYMBOL_GPL(lock_unpin_lock);
>  
>  void lockdep_set_current_reclaim_state(gfp_t gfp_mask)
>  {
> -	current->lockdep_reclaim_gfp = gfp_mask;
> +	current->lockdep_reclaim_gfp = memalloc_noio_flags(gfp_mask);
>  }
>  
>  void lockdep_clear_current_reclaim_state(void)
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
