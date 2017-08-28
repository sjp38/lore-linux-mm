Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 40C836B025F
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 13:06:18 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id q38so3069164qte.4
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 10:06:18 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f74sor560463qka.15.2017.08.28.10.06.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Aug 2017 10:06:15 -0700 (PDT)
Date: Mon, 28 Aug 2017 10:06:11 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm: Use WQ_HIGHPRI for mm_percpu_wq.
Message-ID: <20170828170611.GV491396@devbig577.frc2.facebook.com>
References: <1503921210-4603-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170828121055.GI17097@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170828121055.GI17097@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>

Hello, Michal.

On Mon, Aug 28, 2017 at 02:10:56PM +0200, Michal Hocko wrote:
> I am not sure I understand how WQ_HIGHPRI actually helps. The work item
> will get served by a thread with higher priority and from a different
> pool than regular WQs. But what prevents the same issue as described
> above when the highprio pool gets congested? In other words what make
> WQ_HIGHPRI less prone to long stalls when we are under low memory
> situation and new workers cannot be allocated?

So, the problem wasn't new worker not getting allocated due to memory
pressure.  Rescuer can handle that.  The problem is that the regular
worker pool is occupied with something which is constantly in runnable
state - most likely writeback / reclaim, so the workqueue doesn't
schedule the other work items.

Setting WQ_HIGHPRI works as highpri worker pool isn't likely to be
contended that way but might not be the best solution.  The right
thing to do would be setting WQ_CPU_INTENSIVE on the work items which
can burn a lot of CPU cycles so that it doesn't get in the way of
other work items (workqueue should probably trigger a warning on these
work items too).

Tetuso, can you please try to find which work items are occupying the
worker pool for an extended period time under memory pressure and set
WQ_CPU_INTENSIVE on them?

> > If we do want to make
> > sure that work items on mm_percpu_wq workqueue are executed without delays,
> > we need to consider using kthread_workers instead of workqueue. (Or, maybe
> > somehow we can share one kthread with constantly manipulating cpumask?)
> 
> Hmm, that doesn't sound like a bad idea to me. We already have a rescuer
> thread that basically sits idle all the time so having a dedicated
> kernel thread will not be more expensive wrt. resources. So I think this
> is a more reasonable approach than playing with WQ_HIGHPRI which smells
> like a quite obscure workaround than a real fix to me.

Well, there's one rescuer in the whole system and you'd need
nr_online_cpus kthreads if you wanna avoid constant cacheline
bouncing.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
