Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6C8E86B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 12:59:27 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z45so6172101wrb.13
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 09:59:27 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 69si2102520wra.135.2017.06.22.09.59.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 09:59:26 -0700 (PDT)
Date: Thu, 22 Jun 2017 17:58:58 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v3 1/6] mm, oom: use oom_victims counter to synchronize oom
 victim selection
Message-ID: <20170622165858.GA30035@castle>
References: <1498079956-24467-1-git-send-email-guro@fb.com>
 <1498079956-24467-2-git-send-email-guro@fb.com>
 <201706220040.v5M0eSnK074332@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <201706220040.v5M0eSnK074332@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jun 22, 2017 at 09:40:28AM +0900, Tetsuo Handa wrote:
> Roman Gushchin wrote:
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -992,6 +992,13 @@ bool out_of_memory(struct oom_control *oc)
> >  	if (oom_killer_disabled)
> >  		return false;
> >  
> > +	/*
> > +	 * If there are oom victims in flight, we don't need to select
> > +	 * a new victim.
> > +	 */
> > +	if (atomic_read(&oom_victims) > 0)
> > +		return true;
> > +
> >  	if (!is_memcg_oom(oc)) {
> >  		blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
> >  		if (freed > 0)
> 
> Above in this patch and below in patch 5 are wrong.
> 
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -665,7 +672,13 @@ static void mark_oom_victim(struct task_struct *tsk)
> >  	 * that TIF_MEMDIE tasks should be ignored.
> >  	 */
> >  	__thaw_task(tsk);
> > -	atomic_inc(&oom_victims);
> > +
> > +	/*
> > +	 * If there are no oom victims in flight,
> > +	 * give the task an access to the memory reserves.
> > +	 */
> > +	if (atomic_inc_return(&oom_victims) == 1)
> > +		set_tsk_thread_flag(tsk, TIF_MEMDIE);
> >  }
> >  
> >  /**
> 
> The OOM reaper is not available for CONFIG_MMU=n kernels, and timeout based
> giveup is not permitted, but a multithreaded process might be selected as
> an OOM victim. Not setting TIF_MEMDIE to all threads sharing an OOM victim's
> mm increases possibility of preventing some OOM victim thread from terminating
> (e.g. one of them cannot leave __alloc_pages_slowpath() with mmap_sem held for
> write due to waiting for the TIF_MEMDIE thread to call exit_oom_victim() when
> the TIF_MEMDIE thread is waiting for the thread with mmap_sem held for write).

I agree, that CONFIG_MMU=n is a special case, and the proposed approach can't
be used directly. But can you, please, why do you find the first  chunk wrong?
Basically, it's exactly what we do now: we increment oom_victims for every oom
victim, and every process decrements this counter during it's exit path.
If there is at least one existing victim, we will select it again, so it's just
an optimization. Am I missing something? Why should we start new victim selection
if there processes that will likely quit and release memory soon?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
