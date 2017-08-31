Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 375C06B0292
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 18:07:33 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id u206so2216342oif.5
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 15:07:33 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w131si514677oig.434.2017.08.31.15.07.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 Aug 2017 15:07:31 -0700 (PDT)
Subject: Re: [PATCH] mm: Use WQ_HIGHPRI for mm_percpu_wq.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170829214104.GW491396@devbig577.frc2.facebook.com>
	<201708302251.GDI75812.OFOQSVJOFMHFLt@I-love.SAKURA.ne.jp>
	<20170831014610.GE491396@devbig577.frc2.facebook.com>
	<201708312352.CCC87558.OFMLOVtQOFJFHS@I-love.SAKURA.ne.jp>
	<20170831152523.nwdbjock6b6tams5@dhcp22.suse.cz>
In-Reply-To: <20170831152523.nwdbjock6b6tams5@dhcp22.suse.cz>
Message-Id: <201709010707.ABI69774.OLSVMOOFHFQJtF@I-love.SAKURA.ne.jp>
Date: Fri, 1 Sep 2017 07:07:25 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@suse.de, vbabka@suse.cz

Michal Hocko wrote:
> On Thu 31-08-17 23:52:57, Tetsuo Handa wrote:
> [...]
> > So, this pending state seems to be caused by many concurrent allocations by !PF_WQ_WORKER
> > threads consuming too much CPU time (because they only yield CPU time by many cond_resched()
> > and one schedule_timeout_uninterruptible(1)) enough to keep schedule_timeout_uninterruptible(1)
> > by PF_WQ_WORKER threads away for order of minutes. A sort of memory allocation dependency
> > observable in the form of CPU time starvation for the worker to wake up.
> 
> I do not understand this. Why is cond_resched from the user context
> insufficient to let runable kworkers to run?

cond_resched() from !PF_WQ_WORKER threads is sufficient for PF_WQ_WORKER threads to run.
But cond_resched() is not sufficient for rescuer threads to start processing a pending work.
An explicit scheduling (e.g. schedule_timeout_*()) by PF_WQ_WORKER threads is needed for
rescuer threads to start processing a pending work.

Since schedule_timeout_*() from PF_WQ_WORKER threads is called from very limited locations
(i.e. from should_reclaim_retry(), __alloc_pages_may_oom() and out_of_memory()), it can
take many seconds for PF_WQ_WORKER threads to reach such locations when many threads (both
PF_WQ_WORKER and !PF_WQ_WORKER) are constantly switching each other using cond_resched()
as a switching point. I think that if cond_resched() inside memory allocation path were
schedule_timeout_*(), PF_WQ_WORKER threads will be able to call schedule_timeout_*() more
quickly and allow rescuer threads to start processing a pending work faster than now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
