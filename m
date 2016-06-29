Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5665D6B0253
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 04:33:18 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a4so30376081lfa.1
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 01:33:18 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id h4si3578288wjg.171.2016.06.29.01.33.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jun 2016 01:33:16 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id a66so12413974wme.2
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 01:33:16 -0700 (PDT)
Date: Wed, 29 Jun 2016 10:33:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear
 TIF_MEMDIE
Message-ID: <20160629083314.GA27153@dhcp22.suse.cz>
References: <1466766121-8164-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160624215627.GA1148@redhat.com>
 <201606251444.EGJ69787.FtMOFJOLSHFQOV@I-love.SAKURA.ne.jp>
 <20160627092326.GD31799@dhcp22.suse.cz>
 <20160627103609.GE31799@dhcp22.suse.cz>
 <20160627155119.GA17686@redhat.com>
 <20160627160616.GN31799@dhcp22.suse.cz>
 <20160627175555.GA24370@redhat.com>
 <20160628101956.GA510@dhcp22.suse.cz>
 <20160629001353.GA9377@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160629001353.GA9377@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, vdavydov@virtuozzo.com, rientjes@google.com

On Wed 29-06-16 02:13:53, Oleg Nesterov wrote:
> Michal,
> 
> I am already sleeping, I'll try to reply to other parts of your email
> (and other emails) tomorrow, just some notes about the patch you propose.

Thanks!

> And cough sorry for noise... I personally hate-hate-hate every new "oom"
> member you and Tetsuo add into task/signal_struct ;)

I am not really happy about that either. I wish I could find a better
way...

> But not in this case, because I _think_ we need signal_struct->mm
> anyway in the long term.
> 
> So at first glance this patch makes sense, but unless I missed something
> (the patch doesn't apply I can be easily wrong),

This is on top of the current mmotm tree which contains other oom
changes.

[...]
> > +void mark_oom_victim(struct task_struct *tsk, struct mm_struct *mm)
> >  {
> >  	WARN_ON(oom_killer_disabled);
> >  	/* OOM killer might race with memcg OOM */
> >  	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
> >  		return;
> > +
> >  	atomic_inc(&tsk->signal->oom_victims);
> > +
> > +	/* oom_mm is bound to the signal struct life time */
> > +	if (!tsk->signal->oom_mm) {
> > +		atomic_inc(&mm->mm_count);
> > +		tsk->signal->oom_mm = mm;
> 
> Looks racy, but it is not because we rely on oom_lock? Perhaps a comment
> makes sense.

mark_oom_victim will be called only for the current or under the
task_lock so it should be stable. Except for...

> > @@ -838,8 +826,8 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
> >  	 * If the task is already exiting, don't alarm the sysadmin or kill
> >  	 * its children or threads, just set TIF_MEMDIE so it can die quickly
> >  	 */
> > -	if (task_will_free_mem(p)) {
> > -		mark_oom_victim(p);
> > +	if (mm && task_will_free_mem(p)) {
> > +		mark_oom_victim(p, mm);

This one. I didn't bother to cover it for the example patch but I have a
plan to address that. There are two possible ways. One is to pin
mm_count in oom_badness() so that we have a guarantee that it will not
get released from under us and the other one is to make
task_will_free_mem task_lock friendly and call this under the lock as we
used to.
 
> And this looks really racy at first glance. Suppose that this memory hog execs
> (this changes its ->mm) and then exits so that task_will_free_mem() == T, in
> this case "mm" has nothing to do with tsk->mm and it can be already freed.

Hmm, I didn't think about exec case. And I guess we have never cared
about that race. We just select a task and then kill it. The fact that
it is not sitting on the same memory anymore is silently ignored... But
I have to think about it more. I would be more worried about the use
after free.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
