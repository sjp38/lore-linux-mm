Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id C736A828E1
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 16:01:11 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id f89so133195373qtd.1
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 13:01:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s86si4150549qks.197.2016.06.29.13.01.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jun 2016 13:01:11 -0700 (PDT)
Date: Wed, 29 Jun 2016 22:01:08 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear
 TIF_MEMDIE
Message-ID: <20160629200108.GA19253@redhat.com>
References: <20160624215627.GA1148@redhat.com>
 <201606251444.EGJ69787.FtMOFJOLSHFQOV@I-love.SAKURA.ne.jp>
 <20160627092326.GD31799@dhcp22.suse.cz>
 <20160627103609.GE31799@dhcp22.suse.cz>
 <20160627155119.GA17686@redhat.com>
 <20160627160616.GN31799@dhcp22.suse.cz>
 <20160627175555.GA24370@redhat.com>
 <20160628101956.GA510@dhcp22.suse.cz>
 <20160629001353.GA9377@redhat.com>
 <20160629083314.GA27153@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160629083314.GA27153@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, vdavydov@virtuozzo.com, rientjes@google.com

On 06/29, Michal Hocko wrote:
>
> > > +void mark_oom_victim(struct task_struct *tsk, struct mm_struct *mm)
> > >  {
> > >  	WARN_ON(oom_killer_disabled);
> > >  	/* OOM killer might race with memcg OOM */
> > >  	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
> > >  		return;
> > > +
> > >  	atomic_inc(&tsk->signal->oom_victims);
> > > +
> > > +	/* oom_mm is bound to the signal struct life time */
> > > +	if (!tsk->signal->oom_mm) {
> > > +		atomic_inc(&mm->mm_count);
> > > +		tsk->signal->oom_mm = mm;
> >
> > Looks racy, but it is not because we rely on oom_lock? Perhaps a comment
> > makes sense.
>
> mark_oom_victim will be called only for the current or under the
> task_lock so it should be stable. Except for...

I meant that the code looks racy because 2 threads can see ->oom_mm == NULL
at the same time and in this case we have the extra atomic_inc(mm_count).
But I guess oom_lock saves us, so the code is correct but not clear.

> > > @@ -838,8 +826,8 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
> > >  	 * If the task is already exiting, don't alarm the sysadmin or kill
> > >  	 * its children or threads, just set TIF_MEMDIE so it can die quickly
> > >  	 */
> > > -	if (task_will_free_mem(p)) {
> > > -		mark_oom_victim(p);
> > > +	if (mm && task_will_free_mem(p)) {
> > > +		mark_oom_victim(p, mm);
>
> This one. I didn't bother to cover it for the example patch but I have a
> plan to address that. There are two possible ways. One is to pin
> mm_count in oom_badness() so that we have a guarantee that it will not

I thought about this too. And I think that select_bad_process() should even
return mm_struct or at least a task_lock'ed task for the start.

> > And this looks really racy at first glance. Suppose that this memory hog execs
> > (this changes its ->mm) and then exits so that task_will_free_mem() == T, in
> > this case "mm" has nothing to do with tsk->mm and it can be already freed.
>
> Hmm, I didn't think about exec case. And I guess we have never cared
> about that race. We just select a task and then kill it.

And I guess we want to fix this too, although this is not that important,
but this looks like a minor security problem.

And this is another indication that almost everything oom-kill.c does with
task_struct is wrong ;) Ideally It should only use task_struct to send the
SIGKILL, and now that we kill all users of victim->mm we can hopefully do
this later.

Btw, do we still need this list_for_each_entry(child, &t->children, sibling)
loop in oom_kill_process() ?

> I would be more worried about the use
> after free.

Yes, yes, this is what I meant.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
