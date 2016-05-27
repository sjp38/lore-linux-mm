Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id C85756B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 12:25:06 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id p81so100397780itd.3
        for <linux-mm@kvack.org>; Fri, 27 May 2016 09:25:06 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 131si14288340oie.167.2016.05.27.09.25.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 May 2016 09:25:05 -0700 (PDT)
Subject: Re: [RFC PATCH] mm, oom_reaper: do not attempt to reap a task more than twice
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1464276476-25136-1-git-send-email-mhocko@kernel.org>
	<201605271931.AGD82810.QFOFOOFLMVtHSJ@I-love.SAKURA.ne.jp>
	<20160527122308.GJ27686@dhcp22.suse.cz>
	<201605272218.JID39544.tFOQHJOMVFLOSF@I-love.SAKURA.ne.jp>
	<20160527133502.GN27686@dhcp22.suse.cz>
In-Reply-To: <20160527133502.GN27686@dhcp22.suse.cz>
Message-Id: <201605280124.EJB71319.SHOtOVFFFQMOJL@I-love.SAKURA.ne.jp>
Date: Sat, 28 May 2016 01:24:51 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, oleg@redhat.com, vdavydov@parallels.com

Michal Hocko wrote:
> On Fri 27-05-16 22:18:42, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > So this is the biggest change to my approach. And I think it is
> > > incorrect because you cannot simply reap the memory when you have active
> > > users of that memory potentially.
> > 
> > I don't reap the memory when I have active users of that memory potentially.
> > I do below check. I'm calling wake_oom_reaper() in order to guarantee that
> > oom_reap_task() shall clear TIF_MEMDIE and drop oom_victims.
> > 
> > @@ -483,7 +527,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
> >  
> >  	task_unlock(p);
> >  
> > -	if (!down_read_trylock(&mm->mmap_sem)) {
> > +	if (!mm_is_reapable(mm) || !down_read_trylock(&mm->mmap_sem)) {
> >  		ret = false;
> >  		goto unlock_oom;
> >  	}
> 
> OK, I've missed this part. So you just defer the decision to the oom
> reaper while I am trying to solve that at oom_kill_process level.

Right.

> We could very well do 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index bcb6d3b26c94..d9017b8c7300 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -813,6 +813,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  			 * memory might be still used.
>  			 */
>  			can_oom_reap = false;
> +			set_bit(MMF_OOM_REAPED, mm->flags);
>  			continue;
>  		}
>  		if (p->signal->oom_score_adj == OOM_ADJUST_MIN)
> 
> with the same result. If you _really_ think that this would make a
> difference I could live with that. But I am highly skeptical this
> matters all that much.

It matters a lot. There is a "guarantee" difference.

Maybe this is something like top half and bottom half relationship?
The OOM killer context is the top half and the OOM reaper context is
the bottom half. "The top half always hands over to the bottom half"
can allow the bottom half to recover when something went wrong.
In your approach, the top half might not hand over to the bottom half.

I think the lines needed for the guarantee are something like

	rcu_read_lock();
	for_each_process(p) {
		if (!process_shares_mm(p, mm))
			continue;
		if (same_thread_group(p, victim))
			continue;
		/*
		 * It is not safe to reap memory used by global init or
		 * kernel threads.
		 */
		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p)) {
			set_bit(MMF_OOM_REAPED, mm->flags);
			continue;
		}
		/*
		 * Memory used by OOM_SCORE_ADJ_MIN is still OOM reapable
		 * if they are already killed or exiting. Just don't
		 * send SIGKILL.
		 */
		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
			continue;

		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
	}
	rcu_read_unlock();

	wake_oom_reaper(victim);

but doing set_bit(MMF_OOM_REAPED, mm->flags) here makes sense?

> > >                                   Shared with global init is just non
> > > existant problem. Such a system would be crippled enough to not bother.
> > 
> > See commit a2b829d95958da20 ("mm/oom_kill.c: avoid attempting to kill init
> > sharing same memory").
> 
> Don't you think that a system where the largest memory consumer is the
> global init is crippled terribly?

Why not?

PID=1 name=init RSS=100MB
  \
  +-- PID=102 name=child RSS=10MB (completed execve("child") 10 minutes ago)
  \
  +-- PID=103 name=child RSS=10MB (completed execve("child") 7 minutes ago)
  \
  +-- PID=104 name=child RSS=10MB (completed execve("child") 3 minutes ago)
  \
  +-- PID=105 name=init RSS=100MB (about to start execve("child") from vfork())

should be allowed, doesn't it?
There is no reason to exclude vfork()'ed child from OOM victim candidates.
We can't control how people run their userspace programs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
