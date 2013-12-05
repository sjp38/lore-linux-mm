Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f180.google.com (mail-ea0-f180.google.com [209.85.215.180])
	by kanga.kvack.org (Postfix) with ESMTP id E97466B0035
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 08:14:45 -0500 (EST)
Received: by mail-ea0-f180.google.com with SMTP id f15so11350555eak.39
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 05:14:45 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id m49si10823025eeg.31.2013.12.05.05.14.45
        for <linux-mm@kvack.org>;
        Thu, 05 Dec 2013 05:14:45 -0800 (PST)
Date: Thu, 5 Dec 2013 14:14:44 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/2] mm: memcg: do not allow task about to OOM kill to
 bypass the limit
Message-ID: <20131205131444.GC16711@dhcp22.suse.cz>
References: <1386197114-5317-1-git-send-email-hannes@cmpxchg.org>
 <1386197114-5317-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386197114-5317-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 04-12-13 17:45:14, Johannes Weiner wrote:
> 4942642080ea ("mm: memcg: handle non-error OOM situations more
> gracefully") allowed tasks that already entered a memcg OOM condition
> to bypass the memcg limit on subsequent allocation attempts hoping
> this would expedite finishing the page fault and executing the kill.
> 
> David Rientjes is worried that this breaks memcg isolation guarantees
> and since there is no evidence that the bypass actually speeds up
> fault processing just change it so that these subsequent charge
> attempts fail outright.  The notable exception being __GFP_NOFAIL
> charges which are required to bypass the limit regardless.
> 
> Reported-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

We want this in stable as well IMHO.
Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f6a63f5b3827..bf5e89457149 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2694,7 +2694,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  		goto bypass;
>  
>  	if (unlikely(task_in_memcg_oom(current)))
> -		goto bypass;
> +		goto nomem;
>  
>  	if (gfp_mask & __GFP_NOFAIL)
>  		oom = false;
> -- 
> 1.8.4.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
