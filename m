Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6AE9D6B025F
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:30:38 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u190so131921904pfb.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:30:38 -0700 (PDT)
Received: from mail-pf0-f196.google.com (mail-pf0-f196.google.com. [209.85.192.196])
        by mx.google.com with ESMTPS id d68si11828586pfc.68.2016.04.14.07.30.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 07:30:36 -0700 (PDT)
Received: by mail-pf0-f196.google.com with SMTP id d184so7298203pfc.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:30:36 -0700 (PDT)
Date: Thu, 14 Apr 2016 16:30:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom_reaper: Use try_oom_reaper() for reapability test.
Message-ID: <20160414143031.GJ2850@dhcp22.suse.cz>
References: <1460631391-8628-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160414112146.GD2850@dhcp22.suse.cz>
 <201604142034.BIF60426.FLFMVOHOJQStOF@I-love.SAKURA.ne.jp>
 <20160414120106.GF2850@dhcp22.suse.cz>
 <20160414123448.GG2850@dhcp22.suse.cz>
 <201604142301.BJG51570.LFSOOVFMHJQtOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201604142301.BJG51570.LFSOOVFMHJQtOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, linux-mm@kvack.org

On Thu 14-04-16 23:01:41, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 14-04-16 20:34:18, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > [...]
> > > > The patch seems correct I just do not see any point in it because I do
> > > > not think it handles any real life situation. I basically consider any
> > > > workload where only _certain_ thread(s) or process(es) sharing the mm have
> > > > OOM_SCORE_ADJ_MIN set as invalid. Why should we care about those? This
> > > > requires root to cripple the system. Or am I missing a valid
> > > > configuration where this would make any sense?
> > > 
> > > Because __oom_reap_task() as of current linux.git marks only one of
> > > thread groups as OOM_SCORE_ADJ_MIN and happily disables further reaping
> > > (which I'm utilizing such behavior for catching bugs which occur under
> > > almost OOM situation).
> > 
> > I am not really sure I understand what you mean here. Let me try. You
> > have N tasks sharing the same mm. OOM killer selects one of them and
> > kills it, grants TIF_MEMDIE and schedules it for oom_reaper. Now the oom
> > reaper handles that task and marks it OOM_SCORE_ADJ_MIN. Others will
> > have fatal_signal_pending without OOM_SCORE_ADJ_MIN. The shared mm was
> > already reaped so there is not much left we can do about it. What now?
> 
> You finally understood what I mean here.

OK, good to know we are on the same page.

> Say, there are TG1 and TG2 sharing the same mm which are marked as
> OOM_SCORE_ADJ_MAX. First round of the OOM killer selects TG1 and sends
> SIGKILL to TG1 and TG2. The OOM reaper reaps memory via TG1 and marks
> TG1 as OOM_SCORE_ADJ_MIN and revokes TIF_MEMDIE from TG1. Then, next
> round of the OOM killer selects TG2 and sends SIGKILL to TG1 and TG2.
> But since TG1 is already marked as OOM_SCORE_ADJ_MIN by the OOM reaper,
> the OOM reaper is not called.

which doesn't matter because this mm has already been reaped and further
attempts are basically deemed to fail as well. This is the reason why I
completely failed to see your point previously. Because it is not the
oom reaper which makes the situation worse. We just never cared about
this possible case.

> This is a situation which the patch you show below will solve.

OK, great.

[...]

> Michal Hocko wrote:
> > On Thu 14-04-16 14:01:06, Michal Hocko wrote:
> > [...]
> > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > index 716759e3eaab..d5a4d08f2031 100644
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -286,6 +286,13 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
> > >  		return OOM_SCAN_CONTINUE;
> > >  
> > >  	/*
> > > +	 * mm of this task has already been reaped so it doesn't make any
> > > +	 * sense to select it as a new oom victim.
> > > +	 */
> > > +	if (test_bit(MMF_OOM_REAPED, &task->mm->flags))
> > > +		return OOM_SCAN_CONTINUE;
> > 
> > This will have to move to oom_badness to where we check for
> > OOM_SCORE_ADJ_MIN to catch the case where we try to sacrifice a child...
> 
> oom_badness() should return 0 if MMF_OOM_REAPED is set (please be careful
> with race task->mm becoming NULL).

This is what I ended up with. Patch below for the reference. I plan to
repost with other 3 posted recently in one series sometimes next week
hopefully.

> But oom_scan_process_thread() should not
> return OOM_SCAN_ABORT if one of threads in TG1 or TG2 still has TIF_MEMDIE
> (because it is possible that one of threads in TG1 or TG2 gets TIF_MEMDIE
> via the fatal_signal_pending(current) shortcut in out_of_memory()).

This would be a separate patch again. I still have to think how to deal
with this case but the most straightforward thing to do would be to simply
disable those shortcuts for crosss process shared mm-s. They are just
too weird and I do not think we want to support all the potential corner
cases and dropping an optimistic heuristic in the name of overal sanity
sounds as a good compromise to me.

---
