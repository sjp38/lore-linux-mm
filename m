Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id C768E6B0038
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 19:33:33 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so71176828igb.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 16:33:33 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id 4si1968igy.86.2015.09.21.16.33.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 16:33:33 -0700 (PDT)
Received: by padhy16 with SMTP id hy16so129622856pad.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 16:33:33 -0700 (PDT)
Date: Mon, 21 Sep 2015 16:33:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/oom_kill.c: don't kill TASK_UNINTERRUPTIBLE tasks
In-Reply-To: <201509192333.AGJ30797.OQOFLFSMJVFOtH@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1509211628050.27715@chino.kir.corp.google.com>
References: <20150917192204.GA2728@redhat.com> <alpine.DEB.2.11.1509181035180.11189@east.gentwo.org> <20150918162423.GA18136@redhat.com> <alpine.DEB.2.11.1509181200140.11964@east.gentwo.org> <20150919083218.GD28815@dhcp22.suse.cz>
 <201509192333.AGJ30797.OQOFLFSMJVFOtH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@kernel.org, cl@linux.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

On Sat, 19 Sep 2015, Tetsuo Handa wrote:

> I think that use of ALLOC_NO_WATERMARKS via TIF_MEMDIE is the underlying
> cause. ALLOC_NO_WATERMARKS via TIF_MEMDIE is intended for terminating the
> OOM victim task as soon as possible, but it turned out that it will not
> work if there is invisible lock dependency. Therefore, why not to give up
> "there should be only up to 1 TIF_MEMDIE task" rule?
> 

I don't see the connection between TIF_MEMDIE and ALLOC_NO_WATERMARKS 
being problematic.  It is simply the mechanism by which we give oom killed 
processes access to memory reserves if they need it.  I believe you are 
referring only to the oom killer stalling when it finds an oom victim.

> What this patch (and many others posted in various forms many times over
> past years) does is to give up "there should be only up to 1 TIF_MEMDIE
> task" rule. I think that we need to tolerate more than 1 TIF_MEMDIE tasks
> and somehow manage in a way memory reserves will not deplete.
> 

Your proposal, which I mostly agree with, tries to kill additional 
processes so that they allocate and drop the lock that the original victim 
depends on.  My approach, from 
http://marc.info/?l=linux-kernel&m=144010444913702, is the same, but 
without the killing.  It's unecessary to kill every process on the system 
that is depending on the same lock, and we can't know which processes are 
stalling on that lock and which are not.

I think it's much easier to simply identify such a situation where a 
process has not exited in a timely manner and then provide processes 
access to memory reserves without being killed.  We hope that the victim 
will have queued its mutex_lock() and allocators that are holding the lock 
will drop it after successfully utilizing memory reserves.

We can mitigate immediate depletion of memory reserves by requiring all 
allocators to reclaim (or compact) and calling the oom killer to identify 
the timeout before granting access to memory reserves for a single 
allocation before schedule_timeout_killable(1) and returning.

I don't know of any alternative solutions where we can guarantee that 
memory reserves cannot be depleted unless memory reserves are 100% of 
memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
