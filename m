Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id D1A3F6B0292
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 19:03:00 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id n64so5247174qki.10
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 16:03:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s2sor1011852qti.139.2017.08.28.16.02.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Aug 2017 16:03:00 -0700 (PDT)
Date: Mon, 28 Aug 2017 16:02:56 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm: Use WQ_HIGHPRI for mm_percpu_wq.
Message-ID: <20170828230256.GF491396@devbig577.frc2.facebook.com>
References: <1503921210-4603-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170828121055.GI17097@dhcp22.suse.cz>
 <20170828170611.GV491396@devbig577.frc2.facebook.com>
 <201708290715.FEI21383.HSFOQtJOMVOFFL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708290715.FEI21383.HSFOQtJOMVOFFL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@suse.de, vbabka@suse.cz

Hello, Tetsuo.

On Tue, Aug 29, 2017 at 07:15:05AM +0900, Tetsuo Handa wrote:
> Isn't it any work item which does __GFP_DIRECT_RECLAIM && !__GFP_NORETRY memory
> allocation, for doing __GFP_DIRECT_RECLAIM && !__GFP_NORETRY memory allocation
> burns a lot of CPU cycles under memory pressure? In other words, won't we end up
> with setting WQ_CPU_INTENSIVE to almost all workqueues?

Ah, you're right.  It's the workers getting stuck in direct reclaim.

> > Well, there's one rescuer in the whole system and you'd need
> > nr_online_cpus kthreads if you wanna avoid constant cacheline
> > bouncing.
> 
> Excuse me, one rescuer kernel thread per each WQ_MEM_RECLAIM workqueue, doesn't it?

I meant that it isn't per-cpu.  If you use a kthread for it, that
kthread would be constantly bouncing around.

> My thought is to stop using WQ_MEM_RECLAIM workqueue for mm_percpu_wq and use a
> dedicated kernel thread like oom_reaper. Since the frequency of calling handler
> function seems to be once per a second for each online CPU, I thought switching
> cpumask for NR_CPUS times per a second is tolerable.

Hmm... all these is mostly because workqueue lost the "ignore
concurrency management" flag a while back while converting WQ_HIGHPRI
to mean high nice priority instead of the top of the queue w/o
concurrency management.  Resurrecting that shouldn't be too difficult.
I'll get back to you soon.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
