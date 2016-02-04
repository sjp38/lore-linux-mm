Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id F41F044044D
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 09:43:22 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id g62so7667471wme.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 06:43:22 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id g66si20759396wmc.19.2016.02.04.06.43.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 06:43:22 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id g62so750878wme.2
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 06:43:21 -0800 (PST)
Date: Thu, 4 Feb 2016 15:43:19 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/5] oom: clear TIF_MEMDIE after oom_reaper managed to
 unmap the address space
Message-ID: <20160204144319.GD14425@dhcp22.suse.cz>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
 <1454505240-23446-4-git-send-email-mhocko@kernel.org>
 <201602042322.IAG65142.MOOJHFSVLOQFFt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602042322.IAG65142.MOOJHFSVLOQFFt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 04-02-16 23:22:18, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > When oom_reaper manages to unmap all the eligible vmas there shouldn't
> > be much of the freable memory held by the oom victim left anymore so it
> > makes sense to clear the TIF_MEMDIE flag for the victim and allow the
> > OOM killer to select another task.
> 
> Just a confirmation. Is it safe to clear TIF_MEMDIE without reaching do_exit()
> with regard to freezing_slow_path()? Since clearing TIF_MEMDIE from the OOM
> reaper confuses
> 
>     wait_event(oom_victims_wait, !atomic_read(&oom_victims));
> 
> in oom_killer_disable(), I'm worrying that the freezing operation continues
> before the OOM victim which escaped the __refrigerator() actually releases
> memory. Does this cause consistency problem?

This is a good question! At first sight it seems this is not safe and we
might need to make the oom_reaper freezable so that it doesn't wake up
during suspend and interfere. Let me think about that.

> > +	/*
> > +	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
> > +	 * reasonably reclaimable memory anymore. OOM killer can continue
> > +	 * by selecting other victim if unmapping hasn't led to any
> > +	 * improvements. This also means that selecting this task doesn't
> > +	 * make any sense.
> > +	 */
> > +	tsk->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
> > +	exit_oom_victim(tsk);
> 
> I noticed that updating only one thread group's oom_score_adj disables
> further wake_oom_reaper() calls due to rough-grained can_oom_reap check at
> 
>   p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN
> 
> in oom_kill_process(). I think we need to either update all thread groups'
> oom_score_adj using the reaped mm equally or use more fine-grained can_oom_reap
> check which ignores OOM_SCORE_ADJ_MIN if all threads in that thread group are
> dying or exiting.

I do not understand. Why would you want to reap the mm again when
this has been done already? The mm is shared, right?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
