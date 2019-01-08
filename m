Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0D46F8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 09:38:33 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c18so1661486edt.23
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 06:38:33 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s17si4804edr.396.2019.01.08.06.38.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 06:38:31 -0800 (PST)
Date: Tue, 8 Jan 2019 15:38:30 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/2] memcg: Facilitate termination of memcg OOM victims.
Message-ID: <20190108143830.GV31793@dhcp22.suse.cz>
References: <20190107143802.16847-1-mhocko@kernel.org>
 <a49e2b45-10b2-715c-7dcb-2eb7ec5d2cf2@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a49e2b45-10b2-715c-7dcb-2eb7ec5d2cf2@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 08-01-19 23:21:23, Tetsuo Handa wrote:
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> 
> If memcg OOM events in different domains are pending, already OOM-killed
> threads needlessly wait for pending memcg OOM events in different domains.
> An out_of_memory() call is slow because it involves printk(). With slow
> serial consoles, out_of_memory() might take more than a second. Therefore,
> allowing killed processes to quickly call mmput() from exit_mm() from
> do_exit() will help calling __mmput() (which can reclaim more memory than
> the OOM reaper can reclaim) quickly.

Can you post it separately out of this thread please? It is really a
separate topic and I do not want to end with back and forth without
making a further progress.
 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/memcontrol.c | 17 +++++++++++------
>  1 file changed, 11 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 90eb2e2..a7d3ba9 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1389,14 +1389,19 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	};
>  	bool ret = true;
>  
> -	mutex_lock(&oom_lock);
> -
>  	/*
> -	 * multi-threaded tasks might race with oom_reaper and gain
> -	 * MMF_OOM_SKIP before reaching out_of_memory which can lead
> -	 * to out_of_memory failure if the task is the last one in
> -	 * memcg which would be a false possitive failure reported
> +	 * Multi-threaded tasks might race with oom_reaper() and gain
> +	 * MMF_OOM_SKIP before reaching out_of_memory(). But if current
> +	 * thread was already killed or is ready to terminate, there is
> +	 * no need to call out_of_memory() nor wait for oom_reaoer() to
> +	 * set MMF_OOM_SKIP. These three checks minimize possibility of
> +	 * needlessly calling out_of_memory() and try to call exit_mm()
> +	 * as soon as possible.
>  	 */
> +	if (mutex_lock_killable(&oom_lock))
> +		return true;
> +	if (fatal_signal_pending(current))
> +		goto unlock;
>  	if (tsk_is_oom_victim(current))
>  		goto unlock;
>  
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs
