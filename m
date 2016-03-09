Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 05B1C6B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 05:06:03 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id u190so7243854pfb.3
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 02:06:02 -0800 (PST)
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com. [209.85.192.179])
        by mx.google.com with ESMTPS id u10si11467525pfa.179.2016.03.09.02.06.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 02:06:02 -0800 (PST)
Received: by mail-pf0-f179.google.com with SMTP id x188so36563081pfb.2
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 02:06:02 -0800 (PST)
Date: Wed, 9 Mar 2016 11:05:58 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: drop unnecessary task_will_free_mem()
 check.
Message-ID: <20160309100558.GB27018@dhcp22.suse.cz>
References: <1457450110-6005-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1457450110-6005-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, vdavydov@virtuozzo.com, linux-mm@kvack.org

On Wed 09-03-16 00:15:10, Tetsuo Handa wrote:
> Since mem_cgroup_out_of_memory() is called by
> mem_cgroup_oom_synchronize(true) via pagefault_out_of_memory() via
> page fault, and possible allocations between setting PF_EXITING and
> calling exit_mm() are tty_audit_exit() and taskstats_exit() which will
> not trigger page fault, task_will_free_mem(current) in
> mem_cgroup_out_of_memory() is never true.

What about exit_robust_list called from mm_release?

Anyway I guess we can indeed remove the check because try_charge will
bypass the charge if we are exiting so we shouldn't even reach this path
with PF_EXITING. But I haven't double checked. The above changelog seems
to be incorrect, though.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/memcontrol.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ae8b81c..701bef1 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1254,11 +1254,11 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
> 	mutex_lock(&oom_lock);
>  
>  	/*
> -	 * If current has a pending SIGKILL or is exiting, then automatically
> -	 * select it.  The goal is to allow it to allocate so that it may
> -	 * quickly exit and free its memory.
> +	 * If current has a pending SIGKILL, then automatically select it.
> +	 * The goal is to allow it to allocate so that it may quickly exit
> +	 * and free its memory.
>  	 */
> -	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
> +	if (fatal_signal_pending(current)) {
>  		mark_oom_victim(current);
>  		goto unlock;
>  	}
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
