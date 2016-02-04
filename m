Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id 35B2644044D
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 10:08:42 -0500 (EST)
Received: by mail-oi0-f44.google.com with SMTP id j125so16966309oih.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 07:08:42 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y125si3884216oia.53.2016.02.04.07.08.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 Feb 2016 07:08:41 -0800 (PST)
Subject: Re: [PATCH 3/5] oom: clear TIF_MEMDIE after oom_reaper managed to unmap the address space
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
	<1454505240-23446-4-git-send-email-mhocko@kernel.org>
	<201602042322.IAG65142.MOOJHFSVLOQFFt@I-love.SAKURA.ne.jp>
	<20160204144319.GD14425@dhcp22.suse.cz>
In-Reply-To: <20160204144319.GD14425@dhcp22.suse.cz>
Message-Id: <201602050008.HEG12919.FFOMOHVtQFSLJO@I-love.SAKURA.ne.jp>
Date: Fri, 5 Feb 2016 00:08:25 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> > > +	/*
> > > +	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
> > > +	 * reasonably reclaimable memory anymore. OOM killer can continue
> > > +	 * by selecting other victim if unmapping hasn't led to any
> > > +	 * improvements. This also means that selecting this task doesn't
> > > +	 * make any sense.
> > > +	 */
> > > +	tsk->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
> > > +	exit_oom_victim(tsk);
> > 
> > I noticed that updating only one thread group's oom_score_adj disables
> > further wake_oom_reaper() calls due to rough-grained can_oom_reap check at
> > 
> >   p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN
> > 
> > in oom_kill_process(). I think we need to either update all thread groups'
> > oom_score_adj using the reaped mm equally or use more fine-grained can_oom_reap
> > check which ignores OOM_SCORE_ADJ_MIN if all threads in that thread group are
> > dying or exiting.
> 
> I do not understand. Why would you want to reap the mm again when
> this has been done already? The mm is shared, right?

The mm is shared between previous victim and next victim, but these victims
are in different thread groups. The OOM killer selects next victim whose mm
was already reaped due to sharing previous victim's memory. We don't want
the OOM killer to select such next victim. Maybe set MMF_OOM_REAP_DONE on
the previous victim's mm and check it instead of TIF_MEMDIE when selecting
a victim? That will also avoid problems caused by clearing TIF_MEMDIE?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
