Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id CF9626B0292
	for <linux-mm@kvack.org>; Fri,  1 Sep 2017 10:29:25 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id w10so676893oie.1
        for <linux-mm@kvack.org>; Fri, 01 Sep 2017 07:29:25 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y125si208651oie.443.2017.09.01.07.29.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Sep 2017 07:29:23 -0700 (PDT)
Subject: Re: [PATCH] mm: Use WQ_HIGHPRI for mm_percpu_wq.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170831014610.GE491396@devbig577.frc2.facebook.com>
	<201708312352.CCC87558.OFMLOVtQOFJFHS@I-love.SAKURA.ne.jp>
	<20170831152523.nwdbjock6b6tams5@dhcp22.suse.cz>
	<201709010707.ABI69774.OLSVMOOFHFQJtF@I-love.SAKURA.ne.jp>
	<20170901134748.GC1599492@devbig577.frc2.facebook.com>
In-Reply-To: <20170901134748.GC1599492@devbig577.frc2.facebook.com>
Message-Id: <201709012329.EJF00526.MFFQtOVJFHOSLO@I-love.SAKURA.ne.jp>
Date: Fri, 1 Sep 2017 23:29:19 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org
Cc: mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@suse.de, vbabka@suse.cz

Tejun Heo wrote:
> On Fri, Sep 01, 2017 at 07:07:25AM +0900, Tetsuo Handa wrote:
> > cond_resched() from !PF_WQ_WORKER threads is sufficient for PF_WQ_WORKER threads to run.
> > But cond_resched() is not sufficient for rescuer threads to start processing a pending work.
> > An explicit scheduling (e.g. schedule_timeout_*()) by PF_WQ_WORKER threads is needed for
> > rescuer threads to start processing a pending work.
> 
> I'm not even sure this is the case.  Unless I'm mistaken, in your
> workqueue dumps, the available workers couldn't even leave idle which
> means that they likely didn't get scheduled at all.  It looks like
> genuine multi minute starvation by competing direct reclaims.  What's
> the load number like while these events are in progress?

I don't know the load number because the system is unresponsive due to global
OOM. All information I can collect is via printk() from SysRq. But I guess that
it is genuine multi minute starvation by competing direct reclaims, for
I ran 1024 threads on 4 or 8 CPUs / 4GB RAM / no swap in order to test heavy
memory pressure situation where WQ_MEM_RECLAIM mm_percpu_wq work will stay
pending when I check for SysRq-t.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
