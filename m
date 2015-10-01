Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 83EEB82F71
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 08:13:51 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so82356417ioi.2
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 05:13:51 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j8si1980540igx.70.2015.10.01.05.13.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 01 Oct 2015 05:13:50 -0700 (PDT)
Subject: Re: can't oom-kill zap the victim's memory?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <alpine.DEB.2.10.1509281512330.13657@chino.kir.corp.google.com>
	<201509291657.HHD73972.MOFVSHQtOJFOLF@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.10.1509291547560.3375@chino.kir.corp.google.com>
	<201509301325.AAH13553.MOSVOOtHFFFQLJ@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.10.1509301404380.1148@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1509301404380.1148@chino.kir.corp.google.com>
Message-Id: <201510012113.HEA98301.SVFQOFtFOHLMOJ@I-love.SAKURA.ne.jp>
Date: Thu, 1 Oct 2015 21:13:38 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: mhocko@kernel.org, oleg@redhat.com, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

David Rientjes wrote:
> On Wed, 30 Sep 2015, Tetsuo Handa wrote:
> 
> > If we choose only 1 OOM victim, the possibility of hitting this memory
> > unmapping livelock is (say) 1%. But if we choose multiple OOM victims, the
> > possibility becomes (almost) 0%. And if we still hit this livelock even
> > after choosing many OOM victims, it is time to call panic().
> > 
> 
> Again, this is a fundamental disagreement between your approach of 
> randomly killing processes hoping that we target one that can make a quick 
> exit vs. my approach where we give threads access to memory reserves after 
> reclaim has failed in an oom livelock so they at least make forward 
> progress.  We're going around in circles.

I don't like that memory management subsystem shows an expectant attitude
when memory allocation is failing. There are many possible silent hang up
paths. And my customer's servers might be hitting such paths. But I can't
go in front of their servers and capture SysRq. Thus, I want to let memory
management subsystem try to recover automatically; at least emit some
diagnostic kernel messages automatically.

> 
> > (Well, do we need to change __alloc_pages_slowpath() that OOM victims do not
> > enter direct reclaim paths in order to avoid being blocked by unkillable fs
> > locks?)
> > 
> 
> OOM victims shouldn't need to enter reclaim, and there have been patches 
> before to abort reclaim if current has a pending SIGKILL,

Yes. shrink_inactive_list() and throttle_direct_reclaim() recognize
fatal_signal_pending() tasks.

>                                                           if they have 
> access to memory reserves.

What does this mean?

shrink_inactive_list() and throttle_direct_reclaim() do not check whether
OOM victims have access to memory reserves, do they?

We don't allow access to memory reserves by OOM victims without TIF_MEMDIE.
I think that we should favor kthread and dying threads over normal threads
at __alloc_pages_slowpath() but there is no response on
http://lkml.kernel.org/r/1442939668-4421-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp .

>                             Nothing prevents the victim from already being 
> in reclaim, however, when it is killed.

I think this is problematic because there are unkillable locks in reclaim
paths. The memory management subsystem reports nothing.

> 
> > > Perhaps this is an argument that we need to provide access to memory 
> > > reserves for threads even for !__GFP_WAIT and !__GFP_FS in such scenarios, 
> > > but I would wait to make that extension until we see it in practice.
> > 
> > I think that GFP_ATOMIC allocations already access memory reserves via
> > ALLOC_HIGH priority.
> > 
> 
> Yes, that's true.  It doesn't help for GFP_NOFS, however.  It may be 
> possible that GFP_ATOMIC reserves have been depleted or there is a 
> GFP_NOFS allocation that gets stuck looping forever that doesn't get the 
> ability to allocate without watermarks.

Why can't we emit some diagnostic kernel messages automatically?
Memory allocation requests which did not complete within e.g. 30 seconds
deserve possible memory allocation deadlock warning messages.

>                                          I'd wait to see it in practice 
> before making this extension since it relies on scanning the tasklist.
> 

Is this extension something like check_hung_uninterruptible_tasks()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
