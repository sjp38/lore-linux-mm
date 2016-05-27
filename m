Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 132C46B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 09:35:06 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id h68so17465734lfh.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 06:35:06 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id g184si12382098wmf.26.2016.05.27.06.35.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 06:35:04 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id q62so15012004wmg.3
        for <linux-mm@kvack.org>; Fri, 27 May 2016 06:35:04 -0700 (PDT)
Date: Fri, 27 May 2016 15:35:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom_reaper: do not attempt to reap a task
 morethan twice
Message-ID: <20160527133502.GN27686@dhcp22.suse.cz>
References: <1464276476-25136-1-git-send-email-mhocko@kernel.org>
 <201605271931.AGD82810.QFOFOOFLMVtHSJ@I-love.SAKURA.ne.jp>
 <20160527122308.GJ27686@dhcp22.suse.cz>
 <201605272218.JID39544.tFOQHJOMVFLOSF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201605272218.JID39544.tFOQHJOMVFLOSF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, oleg@redhat.com, vdavydov@parallels.com

On Fri 27-05-16 22:18:42, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Fri 27-05-16 19:31:19, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > Hi,
> > > > I believe that after [1] and this patch we can reasonably expect that
> > > > the risk of the oom lockups is so low that we do not need to employ
> > > > timeout based solutions. I am sending this as an RFC because there still
> > > > might be better ways to accomplish the similar effect. I just like this
> > > > one because it is nicely grafted into the oom reaper which will now be
> > > > invoked for basically all oom victims.
> > > > 
> > > > [1] http://lkml.kernel.org/r/1464266415-15558-1-git-send-email-mhocko@kernel.org
> > > 
> > > I still cannot agree with "we do not need to employ timeout based solutions".
> > > 
> > > While it is true that OOM-reap is per "struct mm_struct" action, we don't
> > > need to change user visible oom_score_adj interface by [1] in order to
> > > enforce OOM-kill being per "struct mm_struct" action.
> > 
> > We want to change the oom_score_adj behavior for the pure consistency I
> > believe.
> 
> Is it an agreed conclusion rather than your will? Did userspace developers ack?

If you think this is not the right approach then please comment as a
reply to the patch.

[...]

> > So this is the biggest change to my approach. And I think it is
> > incorrect because you cannot simply reap the memory when you have active
> > users of that memory potentially.
> 
> I don't reap the memory when I have active users of that memory potentially.
> I do below check. I'm calling wake_oom_reaper() in order to guarantee that
> oom_reap_task() shall clear TIF_MEMDIE and drop oom_victims.
> 
> @@ -483,7 +527,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
>  
>  	task_unlock(p);
>  
> -	if (!down_read_trylock(&mm->mmap_sem)) {
> +	if (!mm_is_reapable(mm) || !down_read_trylock(&mm->mmap_sem)) {
>  		ret = false;
>  		goto unlock_oom;
>  	}

OK, I've missed this part. So you just defer the decision to the oom
reaper while I am trying to solve that at oom_kill_process level.
We could very well do 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index bcb6d3b26c94..d9017b8c7300 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -813,6 +813,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			 * memory might be still used.
 			 */
 			can_oom_reap = false;
+			set_bit(MMF_OOM_REAPED, mm->flags);
 			continue;
 		}
 		if (p->signal->oom_score_adj == OOM_ADJUST_MIN)

with the same result. If you _really_ think that this would make a
difference I could live with that. But I am highly skeptical this
matters all that much.

> 
> >                                   Shared with global init is just non
> > existant problem. Such a system would be crippled enough to not bother.
> 
> See commit a2b829d95958da20 ("mm/oom_kill.c: avoid attempting to kill init
> sharing same memory").

Don't you think that a system where the largest memory consumer is the
global init is crippled terribly?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
