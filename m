Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B3CF36B0553
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 09:55:59 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id a186so152123531pge.7
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 06:55:59 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 31si13204111plg.683.2017.07.28.06.55.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Jul 2017 06:55:58 -0700 (PDT)
Subject: Re: Possible race condition in oom-killer
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170728123235.GN2274@dhcp22.suse.cz>
	<46e1e3ee-af9a-4e67-8b4b-5cf21478ad21@I-love.SAKURA.ne.jp>
	<20170728130723.GP2274@dhcp22.suse.cz>
	<201707282215.AGI69210.VFOHQFtOFSOJML@I-love.SAKURA.ne.jp>
	<20170728132952.GQ2274@dhcp22.suse.cz>
In-Reply-To: <20170728132952.GQ2274@dhcp22.suse.cz>
Message-Id: <201707282255.BGI87015.FSFOVQtMOHLJFO@I-love.SAKURA.ne.jp>
Date: Fri, 28 Jul 2017 22:55:51 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: mjaggi@caviumnetworks.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Michal Hocko wrote:
> On Fri 28-07-17 22:15:01, Tetsuo Handa wrote:
> > task_will_free_mem(current) in out_of_memory() returning false due to
> > MMF_OOM_SKIP already set allowed each thread sharing that mm to select a new
> > OOM victim. If task_will_free_mem(current) in out_of_memory() did not return
> > false, threads sharing MMF_OOM_SKIP mm would not have selected new victims
> > to the level where all OOM killable processes are killed and calls panic().
> 
> I am not sure I understand. Do you mean this?

Yes.

> ---
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 9e8b4f030c1c..671e4a4107d0 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -779,13 +779,6 @@ static bool task_will_free_mem(struct task_struct *task)
>  	if (!__task_will_free_mem(task))
>  		return false;
>  
> -	/*
> -	 * This task has already been drained by the oom reaper so there are
> -	 * only small chances it will free some more
> -	 */
> -	if (test_bit(MMF_OOM_SKIP, &mm->flags))
> -		return false;
> -
>  	if (atomic_read(&mm->mm_users) <= 1)
>  		return true;
>  
> If yes I would have to think about this some more because that might
> have weird side effects (e.g. oom_victims counting after threads passed
> exit_oom_victim).

But this check should not be removed unconditionally. We should still return
false if returning true was not sufficient to solve the OOM situation, for
we need to select next OOM victim in that case.

> 
> Anyway the proper fix for this is to allow reaping mlocked pages.

Different approach is to set TIF_MEMDIE to all threads sharing the same
memory so that threads sharing MMF_OOM_SKIP mm do not need to call
out_of_memory() in order to get TIF_MEMDIE. 

Yet another apporach is to use __GFP_KILLABLE (we can start it as
best effort basis).

>                                                                   Is
> something other than the LTP test affected to give this more priority?
> Do we have other usecases where something mlocks the whole memory?

This panic was caused by 50 threads sharing MMF_OOM_SKIP mm exceeding
number of OOM killable processes. Whether memory is locked or not isn't
important. If a multi-threaded process which consumes little memory was
selected as an OOM victim (and reaped by the OOM reaper and MMF_OOM_SKIP
was set immediately), it might be still possible to select next OOM victims
needlessly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
