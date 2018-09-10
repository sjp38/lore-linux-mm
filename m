Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A52B18E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 07:40:23 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h10-v6so7127732eda.9
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 04:40:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o2-v6si3446426edr.34.2018.09.10.04.40.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 04:40:22 -0700 (PDT)
Date: Mon, 10 Sep 2018 13:40:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm, oom: Fix unnecessary killing of additional
 processes.
Message-ID: <20180910114019.GF10951@dhcp22.suse.cz>
References: <1536382452-3443-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180910095433.GE10951@dhcp22.suse.cz>
 <2a35203b-4220-9758-b332-f10ce3604227@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2a35203b-4220-9758-b332-f10ce3604227@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Roman Gushchin <guro@fb.com>

On Mon 10-09-18 20:27:21, Tetsuo Handa wrote:
> On 2018/09/10 18:54, Michal Hocko wrote:
> > On Sat 08-09-18 13:54:12, Tetsuo Handa wrote:
> > [...]
> > 
> > I will not comment on the above because I have already done so and you
> > keep ignoring it so I will not waste my time again.
> 
> Then, your NACK no longer stands.

And how exactly have you reached that conclusion? Nothing has really
changed. Except you keep pushing this crap no matter what you keep
hearing. You obviously do not worry to put words into my mouth.

> >>   (2) sysctl_oom_kill_allocating_task path can be selected forever
> >>       because it did not check for MMF_OOM_SKIP.
> > 
> > Why is that a problem? sysctl_oom_kill_allocating_task doesn't have any
> > well defined semantic. It is a gross hack to save long and expensive oom
> > victim selection. If we were too strict we should even not allow anybody
> > else but an allocating task to be killed. So selecting it multiple times
> > doesn't sound harmful to me.
> 
> After current thread was selected as an OOM victim by that code path and
> the OOM reaper reaped current thread's memory, the OOM killer has to select
> next OOM victim,

And how have you reached this conclusion. What kind of "kill the
allocating task" semantic really implies this?

> for such situation means that current thread cannot bail
> out due to __GFP_NOFAIL allocation. That is, similar to what you ignored
> 
>   if (tsk_is_oom_victim(current) && !(oc->gfp_mask & __GFP_NOFAIL))
>       return true;
> 
> change. That is, when
> 
>   If current thread is an OOM victim, it is guaranteed to make forward
>   progress (unless __GFP_NOFAIL) by failing that allocation attempt after
>   trying memory reserves. The OOM path does not need to do anything at all.
> 
> failed due to __GFP_NOFAIL, sysctl_oom_kill_allocating_task has to select
> next OOM victim.

this doesn't make any sense

> >>   (3) CONFIG_MMU=n kernels might livelock because nobody except
> >>       is_global_init() case in __oom_kill_process() sets MMF_OOM_SKIP.
> > 
> > And now the obligatory question. Is this a real problem?
> 
> I SAID "POSSIBLE BUGS". You have never heard is not a proof that the problem
> is not occurring in the world. Not everybody is skillful enough to report
> OOM (or low memory) problems to you!

No, we are not making the code overly complex or convoluted for
theoretically possible issues we have never heard before.

> >> which prevent proof of "the forward progress guarantee"
> >> and adds one optimization
> >>
> >>   (4) oom_evaluate_task() was calling oom_unkillable_task() twice because
> >>       oom_evaluate_task() needs to check for !MMF_OOM_SKIP and
> >>       oom_task_origin() tasks before calling oom_badness().
> > 
> > ENOPARSE
> > 
> 
> Not difficult to parse at all.
> 
> oom_evaluate_task() {
> 
>   if (oom_unkillable_task(task, NULL, oc->nodemask))
>     goto next;
> 
>   if (!is_sysrq_oom(oc) && tsk_is_oom_victim(task)) {
>     if (test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags))
>       goto next;
>     goto abort;
>   }
> 
>   if (oom_task_origin(task)) {
>     points = ULONG_MAX;
>     goto select;
>   }
> 
>   points = oom_badness(task, NULL, oc->nodemask, oc->totalpages) {
> 
>     if (oom_unkillable_task(p, memcg, nodemask))
>       return 0;
> 
>   }
> }
> 
> By moving oom_task_origin() to inside oom_badness(), and
> by bringing !MMF_OOM_SKIP test earlier, we can eliminate
> 
>   oom_unkillable_task(task, NULL, oc->nodemask)
> 
> test in oom_evaluate_task().

And so what?

-- 
Michal Hocko
SUSE Labs
