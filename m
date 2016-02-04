Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id BC22F4403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 11:31:21 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id p63so220133969wmp.1
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 08:31:21 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id c79si39037517wmh.120.2016.02.04.08.31.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 08:31:15 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id r129so12936263wmr.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 08:31:15 -0800 (PST)
Date: Thu, 4 Feb 2016 17:31:13 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/5] oom: clear TIF_MEMDIE after oom_reaper managed to
 unmap the address space
Message-ID: <20160204163113.GF14425@dhcp22.suse.cz>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
 <1454505240-23446-4-git-send-email-mhocko@kernel.org>
 <201602042322.IAG65142.MOOJHFSVLOQFFt@I-love.SAKURA.ne.jp>
 <20160204144319.GD14425@dhcp22.suse.cz>
 <201602050008.HEG12919.FFOMOHVtQFSLJO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602050008.HEG12919.FFOMOHVtQFSLJO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 05-02-16 00:08:25, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > > +	/*
> > > > +	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
> > > > +	 * reasonably reclaimable memory anymore. OOM killer can continue
> > > > +	 * by selecting other victim if unmapping hasn't led to any
> > > > +	 * improvements. This also means that selecting this task doesn't
> > > > +	 * make any sense.
> > > > +	 */
> > > > +	tsk->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
> > > > +	exit_oom_victim(tsk);
> > > 
> > > I noticed that updating only one thread group's oom_score_adj disables
> > > further wake_oom_reaper() calls due to rough-grained can_oom_reap check at
> > > 
> > >   p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN
> > > 
> > > in oom_kill_process(). I think we need to either update all thread groups'
> > > oom_score_adj using the reaped mm equally or use more fine-grained can_oom_reap
> > > check which ignores OOM_SCORE_ADJ_MIN if all threads in that thread group are
> > > dying or exiting.
> > 
> > I do not understand. Why would you want to reap the mm again when
> > this has been done already? The mm is shared, right?
> 
> The mm is shared between previous victim and next victim, but these victims
> are in different thread groups. The OOM killer selects next victim whose mm
> was already reaped due to sharing previous victim's memory.

OK, now I got your point. From your previous email it sounded like you
were talking about oom_reaper and its invocation which is was confusing.

> We don't want the OOM killer to select such next victim.

Yes, selecting such a task doesn't make much sense. It has been killed
so it has fatal_signal_pending. If it wanted to allocate it would get
TIF_MEMDIE already and it's address space has been reaped so there is
nothing to free left. These CLONE_VM without CLONE_SIGHAND is really
crazy combo, it is just causing troubles all over and I am not convinced
it is actually that helpful </rant>.


> Maybe set MMF_OOM_REAP_DONE on
> the previous victim's mm and check it instead of TIF_MEMDIE when selecting
> a victim? That will also avoid problems caused by clearing TIF_MEMDIE?

Hmm, it doesn't seem we are under MMF_ availabel bits pressure right now
so using the flag sounds like the easiest way to go. Then we even do not
have to play with OOM_SCORE_ADJ_MIN which might be updated from the
userspace after the oom reaper has done that. Care to send a patch?

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
