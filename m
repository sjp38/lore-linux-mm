Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4BFD36B0260
	for <linux-mm@kvack.org>; Tue, 31 May 2016 03:43:21 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id h68so59999158lfh.2
        for <linux-mm@kvack.org>; Tue, 31 May 2016 00:43:21 -0700 (PDT)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id lk7si49012745wjb.81.2016.05.31.00.43.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 00:43:19 -0700 (PDT)
Received: by mail-wm0-f41.google.com with SMTP id z87so95648426wmh.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 00:43:19 -0700 (PDT)
Date: Tue, 31 May 2016 09:43:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/6] mm, oom: kill all tasks sharing the mm
Message-ID: <20160531074318.GD26128@dhcp22.suse.cz>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
 <1464613556-16708-6-git-send-email-mhocko@kernel.org>
 <20160530181816.GA25480@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160530181816.GA25480@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 30-05-16 20:18:16, Oleg Nesterov wrote:
> On 05/30, Michal Hocko wrote:
> >
> > @@ -852,8 +852,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
> >  			continue;
> >  		if (same_thread_group(p, victim))
> >  			continue;
> > -		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||
> > -		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> > +		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p)) {
> >  			/*
> >  			 * We cannot use oom_reaper for the mm shared by this
> >  			 * process because it wouldn't get killed and so the
> > @@ -862,6 +861,11 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
> >  			can_oom_reap = false;
> >  			continue;
> >  		}
> > +		if (p->signal->oom_score_adj == OOM_ADJUST_MIN)
> > +			pr_warn("%s pid=%d shares mm with oom disabled %s pid=%d. Seems like misconfiguration, killing anyway!"
> > +					" Report at linux-mm@kvack.org\n",
> > +					victim->comm, task_pid_nr(victim),
> > +					p->comm, task_pid_nr(p));
> 
> Oh, yes, I personally do agree ;)
> 
> perhaps the is_global_init() == T case needs a warning too? the previous changes
> take care about vfork() from /sbin/init, so the only reason we can see it true
> is that /sbin/init shares the memory with a memory hog... Nevermind, forget.

I have another two patches waiting for this to settle and one of them
adds a warning to that path.

> This is a bit off-topic, but perhaps we can also change the PF_KTHREAD check later.
> Of course we should not try to kill this kthread, but can_oom_reap can be true in
> this case. A kernel thread which does use_mm() should handle the errors correctly
> if (say) get_user() fails because we unmap the memory.

I was worried that the kernel thread would see a zero page so this could
lead to a data corruption.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
