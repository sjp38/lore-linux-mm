Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 23A846B0005
	for <linux-mm@kvack.org>; Sun,  3 Jul 2016 09:21:53 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id v18so361248714qtv.0
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 06:21:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 144si1715934qkj.181.2016.07.03.06.21.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Jul 2016 06:21:52 -0700 (PDT)
Date: Sun, 3 Jul 2016 15:21:47 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear
 TIF_MEMDIE
Message-ID: <20160703132147.GA28267@redhat.com>
References: <20160627092326.GD31799@dhcp22.suse.cz>
 <20160627103609.GE31799@dhcp22.suse.cz>
 <20160627155119.GA17686@redhat.com>
 <20160627160616.GN31799@dhcp22.suse.cz>
 <20160627175555.GA24370@redhat.com>
 <20160628101956.GA510@dhcp22.suse.cz>
 <20160629001353.GA9377@redhat.com>
 <20160629083314.GA27153@dhcp22.suse.cz>
 <20160629200108.GA19253@redhat.com>
 <20160630075904.GC18783@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160630075904.GC18783@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, vdavydov@virtuozzo.com, rientjes@google.com

On 06/30, Michal Hocko wrote:
> On Wed 29-06-16 22:01:08, Oleg Nesterov wrote:
> > On 06/29, Michal Hocko wrote:
> > >
> > > > > +void mark_oom_victim(struct task_struct *tsk, struct mm_struct *mm)
> > > > >  {
> > > > >  	WARN_ON(oom_killer_disabled);
> > > > >  	/* OOM killer might race with memcg OOM */
> > > > >  	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
> > > > >  		return;
> > > > > +
> > > > >  	atomic_inc(&tsk->signal->oom_victims);
> > > > > +
> > > > > +	/* oom_mm is bound to the signal struct life time */
> > > > > +	if (!tsk->signal->oom_mm) {
> > > > > +		atomic_inc(&mm->mm_count);
> > > > > +		tsk->signal->oom_mm = mm;
> > > >
> > > > Looks racy, but it is not because we rely on oom_lock? Perhaps a comment
> > > > makes sense.
> > >
> > > mark_oom_victim will be called only for the current or under the
> > > task_lock so it should be stable. Except for...
> >
> > I meant that the code looks racy because 2 threads can see ->oom_mm == NULL
> > at the same time and in this case we have the extra atomic_inc(mm_count).
> > But I guess oom_lock saves us, so the code is correct but not clear.
>
> I have changed that to cmpxchg because lowmemory killer is called
> outside of oom_lock.

Hmm. I do not see anything in android/lowmemorykiller.c which can call
mark_oom_victim() ...

But if this is possible then perhaps we have more problems, note that the

	if (tsk == oom_reaper_list || tsk->oom_reaper_list)

check wake_oom_reaper() looks equally racy unless tsk is always current
without oom_lock.

And btw this check probably needs a comment too, we rely on SIGKILL sent
to this task before we do wake_oom_reaper(), or task_will_free_mem() == T.
Otherwise tsk->oom_reaper_list can be non-NULL if a victim forks before
exit, the child will have ->oom_reaper_list copied from parent by
dup_task_struct().

> > > Hmm, I didn't think about exec case. And I guess we have never cared
> > > about that race. We just select a task and then kill it.
> >
> > And I guess we want to fix this too, although this is not that important,
> > but this looks like a minor security problem.
>
> I am not sure I can see security implications but I agree this is less
> than optimal,

Well, just suppose that a memory hog execs a setuid application which does
something important, then we can kill it in some "inconsistent" state. Say,
after it created a file-lock which blocks other instances.

> albeit not critical. Killing a young process which didn't
> have much time to do a useful work doesn't seem that critical.

Yes, agreed, this is minor and very unlikely.

> > And this is another indication that almost everything oom-kill.c does with
> > task_struct is wrong ;) Ideally It should only use task_struct to send the
> > SIGKILL, and now that we kill all users of victim->mm we can hopefully do
> > this later.
>
> Hmm, so you think we should do s@victim@mm_victim@ and then do the
> for_each_process loop to kill all the tasks sharing that mm and kill
> them? We are doing that already so it doesn't sound that bad...

Yes, exactlty. But of course I am not sure about details.

>
> > Btw, do we still need this list_for_each_entry(child, &t->children, sibling)
> > loop in oom_kill_process() ?
>
> Well, to be honest, I don't know. This is a heuristic we have been doing
> for a long time. I do not know how many times it really matters. It can
> even be harmful in loads where children are created in the same pace OOM
> killer is killing them. Not sure how likely is that though...

And it is not clear to me why "child_points > victim_points" can be true if
the victim was chosen by select_bad_process() (to simplify the discussion,
lets ignore has_intersects_mems_allowed/etc).

> Let me think whether we can do something about that.

Perhaps it only makes sense if the caller is out_of_memory() ?  I mean the
sysctl_oom_kill_allocating_task branch. In this case it would nice to move
this list_for_each_entry(children) into another helper.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
