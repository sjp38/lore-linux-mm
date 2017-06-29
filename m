Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1991C6B0292
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 16:13:39 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y62so96373823pfa.3
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 13:13:39 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id q2si4666210plh.464.2017.06.29.13.13.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Jun 2017 13:13:38 -0700 (PDT)
Subject: Re: [v3 1/6] mm, oom: use oom_victims counter to synchronize oom victim selection
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201706220040.v5M0eSnK074332@www262.sakura.ne.jp>
	<20170622165858.GA30035@castle>
	<201706230537.IDB21366.SQHJVFOOFOMFLt@I-love.SAKURA.ne.jp>
	<201706230652.FDH69263.OtOLFSFMHFOQJV@I-love.SAKURA.ne.jp>
	<20170629184748.GB27714@castle>
In-Reply-To: <20170629184748.GB27714@castle>
Message-Id: <201706300513.BGC60962.LQFJOOtMOFVFSH@I-love.SAKURA.ne.jp>
Date: Fri, 30 Jun 2017 05:13:13 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: guro@fb.com
Cc: linux-mm@kvack.org, mhocko@kernel.org, vdavydov.dev@gmail.com, hannes@cmpxchg.org, tj@kernel.org, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

Roman Gushchin wrote:
> On Fri, Jun 23, 2017 at 06:52:20AM +0900, Tetsuo Handa wrote:
> > Tetsuo Handa wrote:
> > Oops, I misinterpreted. This is where a multithreaded OOM victim with or without
> > the OOM reaper can get stuck forever. Think about a process with two threads is
> > selected by the OOM killer and only one of these two threads can get TIF_MEMDIE.
> > 
> >   Thread-1                 Thread-2                 The OOM killer           The OOM reaper
> > 
> >                            Calls down_write(&current->mm->mmap_sem).
> >   Enters __alloc_pages_slowpath().
> >                            Enters __alloc_pages_slowpath().
> >   Takes oom_lock.
> >   Calls out_of_memory().
> >                                                     Selects Thread-1 as an OOM victim.
> >   Gets SIGKILL.            Gets SIGKILL.
> >   Gets TIF_MEMDIE.
> >   Releases oom_lock.
> >   Leaves __alloc_pages_slowpath() because Thread-1 has TIF_MEMDIE.
> >                                                                              Takes oom_lock.
> >                                                                              Will do nothing because down_read_trylock() fails.
> >                                                                              Releases oom_lock.
> >                                                                              Gives up and sets MMF_OOM_SKIP after one second.
> >                            Takes oom_lock.
> >                            Calls out_of_memory().
> >                            Will not check MMF_OOM_SKIP because Thread-1 still has TIF_MEMDIE. // <= get stuck waiting for Thread-1.
> >                            Releases oom_lock.
> >                            Will not leave __alloc_pages_slowpath() because Thread-2 does not have TIF_MEMDIE.
> >                            Will not call up_write(&current->mm->mmap_sem).
> >   Reaches do_exit().
> >   Calls down_read(&current->mm->mmap_sem) in exit_mm() in do_exit(). // <= get stuck waiting for Thread-2.
> >   Will not call up_read(&current->mm->mmap_sem) in exit_mm() in do_exit().
> >   Will not clear TIF_MEMDIE in exit_oom_victim() in exit_mm() in do_exit().
> 
> That's interesting... Does it mean, that we have to give an access to the reserves
> to all threads to guarantee the forward progress?

Yes, for we don't have __GFP_KILLABLE flag.

> 
> What do you think about Michal's approach? He posted a link in the thread.

Please read that thread.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
