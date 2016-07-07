Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 27EE16B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 07:51:29 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id w130so9755225lfd.3
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 04:51:29 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id y200si3134603wme.141.2016.07.07.04.51.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 04:51:27 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id n127so2360544wme.0
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 04:51:27 -0700 (PDT)
Date: Thu, 7 Jul 2016 13:51:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear
 TIF_MEMDIE
Message-ID: <20160707115125.GJ5379@dhcp22.suse.cz>
References: <20160627103609.GE31799@dhcp22.suse.cz>
 <20160627155119.GA17686@redhat.com>
 <20160627160616.GN31799@dhcp22.suse.cz>
 <20160627175555.GA24370@redhat.com>
 <20160628101956.GA510@dhcp22.suse.cz>
 <20160629001353.GA9377@redhat.com>
 <20160629083314.GA27153@dhcp22.suse.cz>
 <20160629200108.GA19253@redhat.com>
 <20160630075904.GC18783@dhcp22.suse.cz>
 <20160703132147.GA28267@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160703132147.GA28267@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, vdavydov@virtuozzo.com, rientjes@google.com

On Sun 03-07-16 15:21:47, Oleg Nesterov wrote:
> On 06/30, Michal Hocko wrote:
> > On Wed 29-06-16 22:01:08, Oleg Nesterov wrote:
> > > On 06/29, Michal Hocko wrote:
> > > >
> > > > > > +void mark_oom_victim(struct task_struct *tsk, struct mm_struct *mm)
> > > > > >  {
> > > > > >  	WARN_ON(oom_killer_disabled);
> > > > > >  	/* OOM killer might race with memcg OOM */
> > > > > >  	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
> > > > > >  		return;
> > > > > > +
> > > > > >  	atomic_inc(&tsk->signal->oom_victims);
> > > > > > +
> > > > > > +	/* oom_mm is bound to the signal struct life time */
> > > > > > +	if (!tsk->signal->oom_mm) {
> > > > > > +		atomic_inc(&mm->mm_count);
> > > > > > +		tsk->signal->oom_mm = mm;
> > > > >
> > > > > Looks racy, but it is not because we rely on oom_lock? Perhaps a comment
> > > > > makes sense.
> > > >
> > > > mark_oom_victim will be called only for the current or under the
> > > > task_lock so it should be stable. Except for...
> > >
> > > I meant that the code looks racy because 2 threads can see ->oom_mm == NULL
> > > at the same time and in this case we have the extra atomic_inc(mm_count).
> > > But I guess oom_lock saves us, so the code is correct but not clear.
> >
> > I have changed that to cmpxchg because lowmemory killer is called
> > outside of oom_lock.
> 
> Hmm. I do not see anything in android/lowmemorykiller.c which can call
> mark_oom_victim() ...

I was just working on the pure mmotm tree and the lmk change was routed
via Greg. In short mark_oom_victim is no longer used out of oom proper.

> And btw this check probably needs a comment too, we rely on SIGKILL sent
> to this task before we do wake_oom_reaper(), or task_will_free_mem() == T.
> Otherwise tsk->oom_reaper_list can be non-NULL if a victim forks before
> exit, the child will have ->oom_reaper_list copied from parent by
> dup_task_struct().

Yes there is the dependency and probably worth a comment.

> > > > Hmm, I didn't think about exec case. And I guess we have never cared
> > > > about that race. We just select a task and then kill it.
> > >
> > > And I guess we want to fix this too, although this is not that important,
> > > but this looks like a minor security problem.
> >
> > I am not sure I can see security implications but I agree this is less
> > than optimal,
> 
> Well, just suppose that a memory hog execs a setuid application which does
> something important, then we can kill it in some "inconsistent" state. Say,
> after it created a file-lock which blocks other instances.

How that would differ from selecting and killing the suid application
right away?

[...]
> > > Btw, do we still need this list_for_each_entry(child, &t->children, sibling)
> > > loop in oom_kill_process() ?
> >
> > Well, to be honest, I don't know. This is a heuristic we have been doing
> > for a long time. I do not know how many times it really matters. It can
> > even be harmful in loads where children are created in the same pace OOM
> > killer is killing them. Not sure how likely is that though...
> 
> And it is not clear to me why "child_points > victim_points" can be true if
> the victim was chosen by select_bad_process() (to simplify the discussion,
> lets ignore has_intersects_mems_allowed/etc).

Because victim_points is a bit of misnomer. It doesn't have anything to
do with selected victim's score. victim_points is 0 before the loop.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
