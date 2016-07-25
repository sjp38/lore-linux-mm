Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1E8DF6B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 10:17:53 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p41so117847248lfi.0
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 07:17:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bn5si15119319wjd.182.2016.07.25.07.17.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jul 2016 07:17:51 -0700 (PDT)
Date: Mon, 25 Jul 2016 16:17:50 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 0/8] Change OOM killer to use list of mm_struct.
Message-ID: <20160725141749.GI9401@dhcp22.suse.cz>
References: <20160725084803.GE9401@dhcp22.suse.cz>
 <201607252007.BGI56224.SHVFLFOOFMJtOQ@I-love.SAKURA.ne.jp>
 <20160725112140.GF9401@dhcp22.suse.cz>
 <201607252047.CHG57343.JFSOHMFVOQFtLO@I-love.SAKURA.ne.jp>
 <20160725115900.GG9401@dhcp22.suse.cz>
 <201607252302.JFE86466.FOMFVFJOtSHQLO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607252302.JFE86466.FOMFVFJOtSHQLO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

On Mon 25-07-16 23:02:35, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Mon 25-07-16 20:47:03, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > On Mon 25-07-16 20:07:11, Tetsuo Handa wrote:
> > > > > Michal Hocko wrote:
> > > > > > > Are you planning to change the scope where the OOM victims can access memory
> > > > > > > reserves?
> > > > > > 
> > > > > > Yes. Because we know that there are some post exit_mm allocations and I
> > > > > > do not want to get back to PF_EXITING and other tricks...
> > > > > > 
> > > > > > > (1) If you plan to allow the OOM victims to access memory reserves until
> > > > > > >     TASK_DEAD, tsk_is_oom_victim() will be as trivial as
> > > > > > > 
> > > > > > > bool tsk_is_oom_victim(struct task_struct *task)
> > > > > > > {
> > > > > > > 	return task->signal->oom_mm;
> > > > > > > }
> > > > > > 
> > > > > > yes, exactly. That's what I've tried to say above. with the oom_mm this
> > > > > > is trivial to implement while mm lists will not help us much due to
> > > > > > their life time. This also means that we know about the oom victim until
> > > > > > it is unhashed and become invisible to the oom killer.
> > > > > 
> > > > > Then, what are advantages with allowing only OOM victims access to memory
> > > > > reserves after they left exit_mm()?
> > > > 
> > > > Because they might need it in order to move on... Say you want to close
> > > > all the files which might release considerable amount of memory or any
> > > > other post exit_mm() resources.
> > > 
> > > OOM victims might need memory reserves in order to move on, but non OOM victims
> > > might also need memory reserves in order to move on. And non OOM victims might
> > > be blocking OOM victims via locks.
> > 
> > Yes that might be true but OOM situations are rare events and quite
> > reduced in the scope. Considering all exiting tasks is more dangerous
> > because they might deplete those memory reserves easily.
> 
> Why do you assume that we grant all of memory reserves?

I've said deplete "those memory reserves". It would be just too easy to
exit many tasks at once and use up that memory.

> I'm suggesting that we grant portion of memory reserves.

Which doesn't solve anything because it will always be a finite resource
which can get depleted. This is basically the same as the oom victim
(ab)using reserves accept that OOM is much less likely and it is under
control of the kernel which task gets killed.

[...]
> > > > If we know that the currently allocating task is an OOM victim then
> > > > giving it access to memory reserves is preferable to selecting another
> > > > oom victim.
> > > 
> > > If we know that the currently allocating task is killed/exiting then
> > > giving it access to memory reserves is preferable to selecting another
> > > OOM victim.
> > 
> > I believe this is getting getting off topic. Can we get back to mm list
> > vs signal::oom_mm decision? I have expressed one aspect that would speak
> > for oom_mm as it provides a persistent and easy to detect oom victim
> > which would be tricky with the mm list approach. Could you name some
> > arguments which would speak for the mm list and would be a problem with
> > the other approach?
> 
> I thought we are talking about future plan. I didn't know you are asking for
> some arguments which would speak for the mm list.

I have brought the future plans just because one part of it might be
much easier to implement if we go with the signal struct based approach.
As there was no other tie breaker I felt like it could help us with the
decision.

> Since the mm list approach turned out that we after all need victim's
> task_struct in order to test eligibility of victim's mm, the signal::oom_mm
> approach will be easier to access both victim's task_struct and victim's mm
> than the mm list approach. I'm fine with signal::oom_mm approach regarding
> oom_scan_process_thread() part.

OK
 
> But I don't like use of ALLOC_NO_WATERMARKS by signal::oom_mm != NULL tasks
> after they passed exit_mm().

I am not proposing that now and we can discuss it later when an actual
patch exists. All I wanted to achieve now is to agree on the first step
and direction. If you are ok with the oom_mm approach and do not see any
strong reasons to prefer mm list based one then I will post my current
pile later this week. Then I would like to handle kthread gracefully. I
guess this would be more than enough for this cycle before actually
meddling with TIF_MEMDIE.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
