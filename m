Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 871A9828E1
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 03:59:07 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c82so70798652wme.2
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 00:59:07 -0700 (PDT)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id d8si3011843wjq.12.2016.06.30.00.59.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jun 2016 00:59:06 -0700 (PDT)
Received: by mail-wm0-f43.google.com with SMTP id v199so209774229wmv.0
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 00:59:06 -0700 (PDT)
Date: Thu, 30 Jun 2016 09:59:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear
 TIF_MEMDIE
Message-ID: <20160630075904.GC18783@dhcp22.suse.cz>
References: <201606251444.EGJ69787.FtMOFJOLSHFQOV@I-love.SAKURA.ne.jp>
 <20160627092326.GD31799@dhcp22.suse.cz>
 <20160627103609.GE31799@dhcp22.suse.cz>
 <20160627155119.GA17686@redhat.com>
 <20160627160616.GN31799@dhcp22.suse.cz>
 <20160627175555.GA24370@redhat.com>
 <20160628101956.GA510@dhcp22.suse.cz>
 <20160629001353.GA9377@redhat.com>
 <20160629083314.GA27153@dhcp22.suse.cz>
 <20160629200108.GA19253@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160629200108.GA19253@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, vdavydov@virtuozzo.com, rientjes@google.com

On Wed 29-06-16 22:01:08, Oleg Nesterov wrote:
> On 06/29, Michal Hocko wrote:
> >
> > > > +void mark_oom_victim(struct task_struct *tsk, struct mm_struct *mm)
> > > >  {
> > > >  	WARN_ON(oom_killer_disabled);
> > > >  	/* OOM killer might race with memcg OOM */
> > > >  	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
> > > >  		return;
> > > > +
> > > >  	atomic_inc(&tsk->signal->oom_victims);
> > > > +
> > > > +	/* oom_mm is bound to the signal struct life time */
> > > > +	if (!tsk->signal->oom_mm) {
> > > > +		atomic_inc(&mm->mm_count);
> > > > +		tsk->signal->oom_mm = mm;
> > >
> > > Looks racy, but it is not because we rely on oom_lock? Perhaps a comment
> > > makes sense.
> >
> > mark_oom_victim will be called only for the current or under the
> > task_lock so it should be stable. Except for...
> 
> I meant that the code looks racy because 2 threads can see ->oom_mm == NULL
> at the same time and in this case we have the extra atomic_inc(mm_count).
> But I guess oom_lock saves us, so the code is correct but not clear.

I have changed that to cmpxchg because lowmemory killer is called
outside of oom_lock.

> > > > @@ -838,8 +826,8 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
> > > >  	 * If the task is already exiting, don't alarm the sysadmin or kill
> > > >  	 * its children or threads, just set TIF_MEMDIE so it can die quickly
> > > >  	 */
> > > > -	if (task_will_free_mem(p)) {
> > > > -		mark_oom_victim(p);
> > > > +	if (mm && task_will_free_mem(p)) {
> > > > +		mark_oom_victim(p, mm);
> >
> > This one. I didn't bother to cover it for the example patch but I have a
> > plan to address that. There are two possible ways. One is to pin
> > mm_count in oom_badness() so that we have a guarantee that it will not
> 
> I thought about this too. And I think that select_bad_process() should even
> return mm_struct or at least a task_lock'ed task for the start.

Yes that would be a plan if I pinned the mm struct in oom_badness. I
ended up using task_lock around task_will_free_mem so it should be goot
for now. Let's see whether we can be more clever about that later.

> > > And this looks really racy at first glance. Suppose that this memory hog execs
> > > (this changes its ->mm) and then exits so that task_will_free_mem() == T, in
> > > this case "mm" has nothing to do with tsk->mm and it can be already freed.
> >
> > Hmm, I didn't think about exec case. And I guess we have never cared
> > about that race. We just select a task and then kill it.
> 
> And I guess we want to fix this too, although this is not that important,
> but this looks like a minor security problem.

I am not sure I can see security implications but I agree this is less
than optimal, albeit not critical. Killing a young process which didn't
have much time to do a useful work doesn't seem that critical. It would
be much better to kill the real holder of the mm though!

> And this is another indication that almost everything oom-kill.c does with
> task_struct is wrong ;) Ideally It should only use task_struct to send the
> SIGKILL, and now that we kill all users of victim->mm we can hopefully do
> this later.

Hmm, so you think we should do s@victim@mm_victim@ and then do the
for_each_process loop to kill all the tasks sharing that mm and kill
them? We are doing that already so it doesn't sound that bad...

> Btw, do we still need this list_for_each_entry(child, &t->children, sibling)
> loop in oom_kill_process() ?

Well, to be honest, I don't know. This is a heuristic we have been doing
for a long time. I do not know how many times it really matters. It can
even be harmful in loads where children are created in the same pace OOM
killer is killing them. Not sure how likely is that though...
Let me think whether we can do something about that.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
