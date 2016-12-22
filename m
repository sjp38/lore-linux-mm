Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4FEC228025E
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 14:27:57 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id xr1so67236498wjb.7
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 11:27:57 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cv5si32875112wjc.141.2016.12.22.11.27.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Dec 2016 11:27:56 -0800 (PST)
Date: Thu, 22 Dec 2016 20:27:53 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, oom_reaper: Update rationale comment for holding
 oom_lock.
Message-ID: <20161222192752.GC19898@dhcp22.suse.cz>
References: <1482411450-8097-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1482411450-8097-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On Thu 22-12-16 21:57:30, Tetsuo Handa wrote:
> Since commit 862e3073b3eed13f
> ("mm, oom: get rid of signal_struct::oom_victims")
> changed to wait until MMF_OOM_SKIP is set rather than wait while
> TIF_MEMDIE is set, rationale comment for commit e2fe14564d3316d1
> ("oom_reaper: close race with exiting task") needs to be updated.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/oom_kill.c | 15 +++------------
>  1 file changed, 3 insertions(+), 12 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index ec9f11d..6fd076b 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -470,18 +470,9 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  	bool ret = true;
>  
>  	/*
> -	 * We have to make sure to not race with the victim exit path
> -	 * and cause premature new oom victim selection:
> -	 * __oom_reap_task_mm		exit_mm
> -	 *   mmget_not_zero
> -	 *				  mmput
> -	 *				    atomic_dec_and_test
> -	 *				  exit_oom_victim
> -	 *				[...]
> -	 *				out_of_memory
> -	 *				  select_bad_process
> -	 *				    # no TIF_MEMDIE task selects new victim
> -	 *  unmap_page_range # frees some memory
> +	 * Make sure that other threads waiting for oom_lock at
> +	 * __alloc_pages_may_oom() are given a chance to call
> +	 * get_page_from_freelist() after MMF_OOM_SKIP is set.
>  	 */
>  	mutex_lock(&oom_lock);

I am not sure the comment clarifies things. I would either remove the
comment completely or write something like the below

	/*
	 * Exclude any oom actions while we are reaping the oom
	 * victim. This will save us from pointless searching of the
	 * new oom victim.
	 */

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
