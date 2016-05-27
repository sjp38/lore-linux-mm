Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 346DE6B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 09:18:57 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w143so167092234oiw.3
        for <linux-mm@kvack.org>; Fri, 27 May 2016 06:18:57 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 21si13759327otd.3.2016.05.27.06.18.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 May 2016 06:18:56 -0700 (PDT)
Subject: Re: [RFC PATCH] mm, oom_reaper: do not attempt to reap a task morethan twice
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1464276476-25136-1-git-send-email-mhocko@kernel.org>
	<201605271931.AGD82810.QFOFOOFLMVtHSJ@I-love.SAKURA.ne.jp>
	<20160527122308.GJ27686@dhcp22.suse.cz>
In-Reply-To: <20160527122308.GJ27686@dhcp22.suse.cz>
Message-Id: <201605272218.JID39544.tFOQHJOMVFLOSF@I-love.SAKURA.ne.jp>
Date: Fri, 27 May 2016 22:18:42 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, oleg@redhat.com, vdavydov@parallels.com

Michal Hocko wrote:
> On Fri 27-05-16 19:31:19, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > Hi,
> > > I believe that after [1] and this patch we can reasonably expect that
> > > the risk of the oom lockups is so low that we do not need to employ
> > > timeout based solutions. I am sending this as an RFC because there still
> > > might be better ways to accomplish the similar effect. I just like this
> > > one because it is nicely grafted into the oom reaper which will now be
> > > invoked for basically all oom victims.
> > > 
> > > [1] http://lkml.kernel.org/r/1464266415-15558-1-git-send-email-mhocko@kernel.org
> > 
> > I still cannot agree with "we do not need to employ timeout based solutions".
> > 
> > While it is true that OOM-reap is per "struct mm_struct" action, we don't
> > need to change user visible oom_score_adj interface by [1] in order to
> > enforce OOM-kill being per "struct mm_struct" action.
> 
> We want to change the oom_score_adj behavior for the pure consistency I
> believe.

Is it an agreed conclusion rather than your will? Did userspace developers ack?

> 
> [...]
> 
> > Yes, commit 449d777d7ad6d7f9 ("mm, oom_reaper: clear TIF_MEMDIE for all tasks
> > queued for oom_reaper") which went to Linux 4.7-rc1 will clear TIF_MEMDIE and
> > decrement task->signal->oom_victims even if __oom_reap_task() cannot reap
> > so that oom_scan_process_thread() will not return OOM_SCAN_ABORT forever.
> > But still, such unlocking depends on an assumption that wake_oom_reaper() is
> > always called.
> 
> which is practically the case. The only real exception are use_mm()
> users. I want to look at those but I guess they need a special handling.
> 
> > What we need to have is "always call wake_oom_reaper() in order to let the
> > OOM reaper clear TIF_MEMDIE and mark as no longer OOM-killable" or "ignore
> > TIF_MEMDIE after some timeout". As you hate timeout, I propose below patch
> > instead of [1] and your "[RFC PATCH] mm, oom_reaper: do not attempt to reap
> > a task more than twice".
> [...]
> > @@ -849,22 +867,18 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
> >  			continue;
> >  		if (same_thread_group(p, victim))
> >  			continue;
> > -		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||
> > -		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> > -			/*
> > -			 * We cannot use oom_reaper for the mm shared by this
> > -			 * process because it wouldn't get killed and so the
> > -			 * memory might be still used.
> > -			 */
> > -			can_oom_reap = false;
> > +		if (unlikely(p->flags & PF_KTHREAD))
> >  			continue;
> > -		}
> > +		if (is_global_init(p))
> > +			continue;
> > +		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> > +			continue;
> > +
> >  		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
> >  	}
> >  	rcu_read_unlock();
> >  
> > -	if (can_oom_reap)
> > -		wake_oom_reaper(victim);
> > +	wake_oom_reaper(victim);
> >  
> >  	mmdrop(mm);
> >  	put_task_struct(victim);
> 
> So this is the biggest change to my approach. And I think it is
> incorrect because you cannot simply reap the memory when you have active
> users of that memory potentially.

I don't reap the memory when I have active users of that memory potentially.
I do below check. I'm calling wake_oom_reaper() in order to guarantee that
oom_reap_task() shall clear TIF_MEMDIE and drop oom_victims.

@@ -483,7 +527,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
 
 	task_unlock(p);
 
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!mm_is_reapable(mm) || !down_read_trylock(&mm->mmap_sem)) {
 		ret = false;
 		goto unlock_oom;
 	}

>                                   Shared with global init is just non
> existant problem. Such a system would be crippled enough to not bother.

See commit a2b829d95958da20 ("mm/oom_kill.c: avoid attempting to kill init
sharing same memory"). My patch simply rolled back to that commit, and
hands over the duty of clearing TIF_MEMDIE and dropping oom_victims to
the OOM reaper's code provided by commit 449d777d7ad6d7f9 ("mm, oom_reaper:
clear TIF_MEMDIE for all tasks queued for oom_reaper").

> But use_mm is potentially real and I believe we should find some way
> around it and even not consider such tasks. Fortunately we do not have
> many users of use_mm in the kernel and most users will not use them.

I don't know why use_mm() becomes a problem because I do above check
just before trying to reap that memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
