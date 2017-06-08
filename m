Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4F93A6B02B4
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 10:36:11 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k30so5095231wrc.9
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 07:36:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f123si5674479wme.116.2017.06.08.07.36.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Jun 2017 07:36:09 -0700 (PDT)
Date: Thu, 8 Jun 2017 16:36:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/2] mm, oom: do not trigger out_of_memory from the
 #PF
Message-ID: <20170608143606.GK19866@dhcp22.suse.cz>
References: <20170519112604.29090-1-mhocko@kernel.org>
 <20170519112604.29090-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170519112604.29090-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Does anybody see any problem with the patch or I can send it for the
inclusion?

On Fri 19-05-17 13:26:04, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Any allocation failure during the #PF path will return with VM_FAULT_OOM
> which in turn results in pagefault_out_of_memory. This can happen for
> 2 different reasons. a) Memcg is out of memory and we rely on
> mem_cgroup_oom_synchronize to perform the memcg OOM handling or b)
> normal allocation fails.
> 
> The later is quite problematic because allocation paths already trigger
> out_of_memory and the page allocator tries really hard to not fail
> allocations. Anyway, if the OOM killer has been already invoked there
> is no reason to invoke it again from the #PF path. Especially when the
> OOM condition might be gone by that time and we have no way to find out
> other than allocate.
> 
> Moreover if the allocation failed and the OOM killer hasn't been
> invoked then we are unlikely to do the right thing from the #PF context
> because we have already lost the allocation context and restictions and
> therefore might oom kill a task from a different NUMA domain.
> 
> An allocation might fail also when the current task is the oom victim
> and there are no memory reserves left and we should simply bail out
> from the #PF rather than invoking out_of_memory.
> 
> This all suggests that there is no legitimate reason to trigger
> out_of_memory from pagefault_out_of_memory so drop it. Just to be sure
> that no #PF path returns with VM_FAULT_OOM without allocation print a
> warning that this is happening before we restart the #PF.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/oom_kill.c | 23 ++++++++++-------------
>  1 file changed, 10 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 04c9143a8625..0f24bdfaadfd 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -1051,25 +1051,22 @@ bool out_of_memory(struct oom_control *oc)
>  }
>  
>  /*
> - * The pagefault handler calls here because it is out of memory, so kill a
> - * memory-hogging task. If oom_lock is held by somebody else, a parallel oom
> - * killing is already in progress so do nothing.
> + * The pagefault handler calls here because some allocation has failed. We have
> + * to take care of the memcg OOM here because this is the only safe context without
> + * any locks held but let the oom killer triggered from the allocation context care
> + * about the global OOM.
>   */
>  void pagefault_out_of_memory(void)
>  {
> -	struct oom_control oc = {
> -		.zonelist = NULL,
> -		.nodemask = NULL,
> -		.memcg = NULL,
> -		.gfp_mask = 0,
> -		.order = 0,
> -	};
> +	static DEFINE_RATELIMIT_STATE(pfoom_rs, DEFAULT_RATELIMIT_INTERVAL,
> +				      DEFAULT_RATELIMIT_BURST);
>  
>  	if (mem_cgroup_oom_synchronize(true))
>  		return;
>  
> -	if (!mutex_trylock(&oom_lock))
> +	if (fatal_signal_pending)
>  		return;
> -	out_of_memory(&oc);
> -	mutex_unlock(&oom_lock);
> +
> +	if (__ratelimit(&pfoom_rs))
> +		pr_warn("Huh VM_FAULT_OOM leaked out to the #PF handler. Retrying PF\n");
>  }
> -- 
> 2.11.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
