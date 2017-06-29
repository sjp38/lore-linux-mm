Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 20A786B0292
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 14:48:07 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id z5so3611281wmz.4
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 11:48:07 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id k186si9120555wmg.36.2017.06.29.11.48.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 11:48:05 -0700 (PDT)
Date: Thu, 29 Jun 2017 14:47:48 -0400
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v3 1/6] mm, oom: use oom_victims counter to synchronize oom
 victim selection
Message-ID: <20170629184748.GB27714@castle>
References: <1498079956-24467-1-git-send-email-guro@fb.com>
 <1498079956-24467-2-git-send-email-guro@fb.com>
 <201706220040.v5M0eSnK074332@www262.sakura.ne.jp>
 <20170622165858.GA30035@castle>
 <201706230537.IDB21366.SQHJVFOOFOMFLt@I-love.SAKURA.ne.jp>
 <201706230652.FDH69263.OtOLFSFMHFOQJV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <201706230652.FDH69263.OtOLFSFMHFOQJV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, mhocko@kernel.org, vdavydov.dev@gmail.com, hannes@cmpxchg.org, tj@kernel.org, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Jun 23, 2017 at 06:52:20AM +0900, Tetsuo Handa wrote:
> Tetsuo Handa wrote:
> > Roman Gushchin wrote:
> > > On Thu, Jun 22, 2017 at 09:40:28AM +0900, Tetsuo Handa wrote:
> > > > Roman Gushchin wrote:
> > > > > --- a/mm/oom_kill.c
> > > > > +++ b/mm/oom_kill.c
> > > > > @@ -992,6 +992,13 @@ bool out_of_memory(struct oom_control *oc)
> > > > >  	if (oom_killer_disabled)
> > > > >  		return false;
> > > > >  
> > > > > +	/*
> > > > > +	 * If there are oom victims in flight, we don't need to select
> > > > > +	 * a new victim.
> > > > > +	 */
> > > > > +	if (atomic_read(&oom_victims) > 0)
> > > > > +		return true;
> > > > > +
> > > > >  	if (!is_memcg_oom(oc)) {
> > > > >  		blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
> > > > >  		if (freed > 0)
> > > > 
> > > > The OOM reaper is not available for CONFIG_MMU=n kernels, and timeout based
> > > > giveup is not permitted, but a multithreaded process might be selected as
> > > > an OOM victim. Not setting TIF_MEMDIE to all threads sharing an OOM victim's
> > > > mm increases possibility of preventing some OOM victim thread from terminating
> > > > (e.g. one of them cannot leave __alloc_pages_slowpath() with mmap_sem held for
> > > > write due to waiting for the TIF_MEMDIE thread to call exit_oom_victim() when
> > > > the TIF_MEMDIE thread is waiting for the thread with mmap_sem held for write).
> > > 
> > > I agree, that CONFIG_MMU=n is a special case, and the proposed approach can't
> > > be used directly. But can you, please, why do you find the first  chunk wrong?
> > 
> > Since you are checking oom_victims before checking task_will_free_mem(current),
> > only one thread can get TIF_MEMDIE. This is where a multithreaded OOM victim without
> > the OOM reaper can get stuck forever.
> 
> Oops, I misinterpreted. This is where a multithreaded OOM victim with or without
> the OOM reaper can get stuck forever. Think about a process with two threads is
> selected by the OOM killer and only one of these two threads can get TIF_MEMDIE.
> 
>   Thread-1                 Thread-2                 The OOM killer           The OOM reaper
> 
>                            Calls down_write(&current->mm->mmap_sem).
>   Enters __alloc_pages_slowpath().
>                            Enters __alloc_pages_slowpath().
>   Takes oom_lock.
>   Calls out_of_memory().
>                                                     Selects Thread-1 as an OOM victim.
>   Gets SIGKILL.            Gets SIGKILL.
>   Gets TIF_MEMDIE.
>   Releases oom_lock.
>   Leaves __alloc_pages_slowpath() because Thread-1 has TIF_MEMDIE.
>                                                                              Takes oom_lock.
>                                                                              Will do nothing because down_read_trylock() fails.
>                                                                              Releases oom_lock.
>                                                                              Gives up and sets MMF_OOM_SKIP after one second.
>                            Takes oom_lock.
>                            Calls out_of_memory().
>                            Will not check MMF_OOM_SKIP because Thread-1 still has TIF_MEMDIE. // <= get stuck waiting for Thread-1.
>                            Releases oom_lock.
>                            Will not leave __alloc_pages_slowpath() because Thread-2 does not have TIF_MEMDIE.
>                            Will not call up_write(&current->mm->mmap_sem).
>   Reaches do_exit().
>   Calls down_read(&current->mm->mmap_sem) in exit_mm() in do_exit(). // <= get stuck waiting for Thread-2.
>   Will not call up_read(&current->mm->mmap_sem) in exit_mm() in do_exit().
>   Will not clear TIF_MEMDIE in exit_oom_victim() in exit_mm() in do_exit().

That's interesting... Does it mean, that we have to give an access to the reserves
to all threads to guarantee the forward progress?

What do you think about Michal's approach? He posted a link in the thread.

Thank you!

Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
