Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id EC575440417
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 11:24:30 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id l8so2684318wmg.7
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 08:24:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p4si3272252edd.470.2017.11.08.08.24.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Nov 2017 08:24:29 -0800 (PST)
Date: Wed, 8 Nov 2017 17:24:27 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 5/5] nommu,oom: Set MMF_OOM_SKIP without waiting for
 termination.
Message-ID: <20171108162427.3hstwbagywwjrh44@dhcp22.suse.cz>
References: <1510138908-6265-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1510138908-6265-5-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1510138908-6265-5-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>

On Wed 08-11-17 20:01:48, Tetsuo Handa wrote:
[...]
> @@ -829,7 +831,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
>  	unsigned int victim_points = 0;
>  	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
>  					      DEFAULT_RATELIMIT_BURST);
> -	bool can_oom_reap = true;
> +	bool can_oom_reap = IS_ENABLED(CONFIG_MMU);
>  
>  	/*
>  	 * If the task is already exiting, don't alarm the sysadmin or kill
> @@ -929,7 +931,6 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
>  			continue;
>  		if (is_global_init(p)) {
>  			can_oom_reap = false;
> -			set_bit(MMF_OOM_SKIP, &mm->flags);
>  			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
>  					task_pid_nr(victim), victim->comm,
>  					task_pid_nr(p), p->comm);
> @@ -947,6 +948,8 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
>  
>  	if (can_oom_reap)
>  		wake_oom_reaper(victim);
> +	else
> +		set_bit(MMF_OOM_SKIP, &mm->flags);
>  
>  	mmdrop(mm);
>  	put_task_struct(victim);

Also this looks completely broken. nommu kernels lose the premature oom
killing protection almost completely (they simply rely on the sleep
before dropping the oom_lock).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
