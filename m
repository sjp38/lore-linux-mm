Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id D60EB440441
	for <linux-mm@kvack.org>; Sat,  6 Feb 2016 09:33:37 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id is5so111348107obc.0
        for <linux-mm@kvack.org>; Sat, 06 Feb 2016 06:33:37 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id m128si12158451oig.50.2016.02.06.06.33.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 06 Feb 2016 06:33:36 -0800 (PST)
Subject: Re: [PATCH 3/5] oom: clear TIF_MEMDIE after oom_reaper managed to unmap the address space
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
	<1454505240-23446-4-git-send-email-mhocko@kernel.org>
	<201602042322.IAG65142.MOOJHFSVLOQFFt@I-love.SAKURA.ne.jp>
	<20160204144319.GD14425@dhcp22.suse.cz>
	<20160206064505.GB20537@dhcp22.suse.cz>
In-Reply-To: <20160206064505.GB20537@dhcp22.suse.cz>
Message-Id: <201602062333.CCI64980.MFJFFVOLtOOQSH@I-love.SAKURA.ne.jp>
Date: Sat, 6 Feb 2016 23:33:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Thu 04-02-16 15:43:19, Michal Hocko wrote:
> > On Thu 04-02-16 23:22:18, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > From: Michal Hocko <mhocko@suse.com>
> > > > 
> > > > When oom_reaper manages to unmap all the eligible vmas there shouldn't
> > > > be much of the freable memory held by the oom victim left anymore so it
> > > > makes sense to clear the TIF_MEMDIE flag for the victim and allow the
> > > > OOM killer to select another task.
> > > 
> > > Just a confirmation. Is it safe to clear TIF_MEMDIE without reaching do_exit()
> > > with regard to freezing_slow_path()? Since clearing TIF_MEMDIE from the OOM
> > > reaper confuses
> > > 
> > >     wait_event(oom_victims_wait, !atomic_read(&oom_victims));
> > > 
> > > in oom_killer_disable(), I'm worrying that the freezing operation continues
> > > before the OOM victim which escaped the __refrigerator() actually releases
> > > memory. Does this cause consistency problem?
> > 
> > This is a good question! At first sight it seems this is not safe and we
> > might need to make the oom_reaper freezable so that it doesn't wake up
> > during suspend and interfere. Let me think about that.
> 
> OK, I was thinking about it some more and it seems you are right here.
> oom_reaper as a kernel thread is not freezable automatically and so it
> might interfere after all the processes/kernel threads are considered
> frozen. Then it really might shut down TIF_MEMDIE too early and wake out
> oom_killer_disable. wait_event_freezable is not sufficient because the
> oom_reaper might running while the PM freezer is freezing tasks and it
> will miss it because it doesn't see it.

I'm not using PM freezer, but your answer is opposite to my guess.
I thought try_to_freeze_tasks(false) is called by freeze_kernel_threads()
after oom_killer_disable() succeeded, and try_to_freeze_tasks(false) will
freeze both userspace tasks (including OOM victims which got TIF_MEMDIE
cleared by the OOM reaper) and kernel threads (including the OOM reaper).
Thus, I was guessing that clearing TIF_MEMDIE without reaching do_exit() is
safe.

> 
> So I think we might need this. I am heading to vacation today and will
> be offline for the next week so I will prepare the full patch with the
> proper changelog after I get back:
> 
I can't judge whether we need this set_freezable().

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index ca61e6cfae52..7e9953a64489 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -521,6 +521,8 @@ static void oom_reap_task(struct task_struct *tsk)
>  
>  static int oom_reaper(void *unused)
>  {
> +	set_freezable();
> +
>  	while (true) {
>  		struct task_struct *tsk = NULL;
>  
> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
