Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6CE5B440417
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 09:56:29 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id t139so2449625wmt.7
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 06:56:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g12si3408974edi.167.2017.11.08.06.56.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Nov 2017 06:56:28 -0800 (PST)
Date: Wed, 8 Nov 2017 15:56:26 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 5/5] nommu,oom: Set MMF_OOM_SKIP without waiting for
 termination.
Message-ID: <20171108145626.qrczy5gypfij5bf4@dhcp22.suse.cz>
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
> Commit 212925802454672e ("mm: oom: let oom_reap_task and exit_mmap run
> concurrently") moved the location of setting MMF_OOM_SKIP from __mmput()
> in kernel/fork.c (which is used by both MMU and !MMU) to exit_mm() in
> mm/mmap.c (which is used by MMU only). As a result, that commit required
> OOM victims in !MMU kernels to disappear from the task list in order to
> reenable the OOM killer, for !MMU kernels can no longer set MMF_OOM_SKIP
> (unless the OOM victim's mm is shared with global init process).

nack withtout demonstrating that the problem is real. It is true it
removes some lines but this is mostly this...
 
> While it would be possible to restore MMF_OOM_SKIP in __mmput() for !MMU
> kernels, let's forget about possibility of OOM livelock for !MMU kernels
> caused by failing to set MMF_OOM_SKIP, by setting MMF_OOM_SKIP at
> oom_kill_process(), for the invocation of the OOM killer is a rare event
> for !MMU systems from the beginning. By doing so, we can get rid of
> special treatment for !MMU case in commit cd04ae1e2dc8e365 ("mm, oom:
> do not rely on TIF_MEMDIE for memory reserves access"). And "mm,oom:
> Use ALLOC_OOM for OOM victim's last second allocation." will allow the
> OOM victim to try ALLOC_OOM (instead of ALLOC_NO_WATERMARKS) allocation
> before killing more OOM victims.
...
>  static bool oom_reserves_allowed(struct task_struct *tsk)
>  {
> -	if (!tsk_is_oom_victim(tsk))
> -		return false;
> -
> -	/*
> -	 * !MMU doesn't have oom reaper so give access to memory reserves
> -	 * only to the thread with TIF_MEMDIE set
> -	 */
> -	if (!IS_ENABLED(CONFIG_MMU) && !test_thread_flag(TIF_MEMDIE))
> -		return false;
> -
> -	return true;
> +	return tsk_is_oom_victim(tsk);
>  }

and the respective ALLOC_OOM change for nommu. The sole purpose of the
code was to prevent from potential problem pointed out by _you_ that
nommu doesn't have the oom reaper and as such we cannot rely on partial
oom reserves. So I am quite surprised that you no longer insist on
the nommu theoretical issue. AFAIR you insisted hard back then. I am not
really sure what has changed since then. I would love to ack a patch
which removes the conditional oom reserves handling with an explanation
why it is not a problem anymore.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
