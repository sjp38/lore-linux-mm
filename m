Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 2D64B6B0253
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 18:23:10 -0400 (EDT)
Received: by pacti10 with SMTP id ti10so1570236pac.0
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 15:23:09 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id rl7si139528pab.173.2015.08.26.15.23.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Aug 2015 15:23:09 -0700 (PDT)
Received: by pabzx8 with SMTP id zx8so1533061pab.1
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 15:23:09 -0700 (PDT)
Date: Wed, 26 Aug 2015 15:23:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] mm, oom: add global access to memory reserves on
 livelock
In-Reply-To: <20150826070127.GB25196@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1508261507270.2973@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1508201358490.607@chino.kir.corp.google.com> <20150821081745.GG23723@dhcp22.suse.cz> <alpine.DEB.2.10.1508241358230.32561@chino.kir.corp.google.com> <20150825142503.GE6285@dhcp22.suse.cz> <alpine.DEB.2.10.1508251635560.10653@chino.kir.corp.google.com>
 <20150826070127.GB25196@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Wed, 26 Aug 2015, Michal Hocko wrote:

> > Because the company I work for has far too many machines for that to be 
> > possible.
> 
> OK I can see that manual intervention for hundreds of machines is not
> practical. But not everybody is that large and there are users who might
> want to be be able to recover.
>  

If Andrew would prefer moving in a direction where all Linux users are 
required to have their admin use sysrq+f to manually trigger an oom kill, 
which may or may not resolve the livelock since there's no way to 
determine which process is holding the common mutex (or even which 
processes are currently allocating), in such situations, then we can carry 
this patch internally.  I disagree with that solution for upstream Linux.

> > If there is a holder of a mutex that then allocates gigabytes of memory, 
> > no amount of memory reserves is going to assist in resolving an oom killer 
> > livelock, whether that's partial access to memory reserves or full access 
> > to memory reserves.
> 
> Sure, but do we have something like that in the kernel? I would argue it
> would be terribly broken and a clear bug which should be fixed.
> 

This is also why my patch dumps the stack trace of both threads: so we can 
evaluate the memory allocation of threads holding shared mutexes.  If it 
is excessive, we can report that and show that it is a common offender and 
see if we can mitigate that.

The scenario described, the full or partial depletion of memory reserves, 
does not need to be induced by a single user.  We don't control the order 
in which the mutex is grabbed so it's multipled by the number of threads 
that grab it, allocate memory, and drop it before the victim has a chance 
to grab it.  In the past, the oom killer would also increase the 
scheduling priority of a victim so it tried to resolve issues like this 
faster.

> > Unless the oom watermark was higher than the lowest access to memory 
> > reserves other than ALLOC_NO_WATERMARKS, then no forward progress would be 
> > made in this scenario.  I think it would be better to give access to that 
> > crucial last page that may solve the livelock to make forward progress, or 
> > panic as a result of complete depletion of memory reserves.  That panic() 
> > is a very trivial patch that can be checked in the allocator slowpath and 
> > addresses a problem that already exists today.
> 
> The panicing the system is really trivial, no question about that. The
> question is whether that panic would be premature. And that is what
> I've tried to tell you.

My patch has defined that by OOM_EXPIRE_MSECS.  The premise is that an oom 
victim with full access to memory reserves should never take more than 5s 
to exit, which I consider a very long time.  If it's increased, we see 
userspace responsiveness issues with our processes that monitor system 
health which timeout.

Sure, it's always possible that a process that requires no mutexes that 
are held by allocators exits and frees a lot of memory 10s later, 5m 
later, etc, and the system can recover.  We have no guarntee of that 
happening, so the panic point needs to be defined where the VM gives up 
and it's unlikely anything can make forward progress.  My suggestion would 
be when memory reserves are fully depleted, but again, that is something 
that can be shown to happen today and is a separate issue.

> The patch I am referring to above gives the
> __GFP_NOFAIL request the full access to memory reserves (throttled by
> oom_lock) but it still failed temporarily. What is more important,
> though, this state wasn't permanent and the system recovered after short
> time so panicing at the time would be premature.
> 

I'm not addressing __GFP_NOFAIL in this patch, and __GFP_NOFAIL is not the 
pain point that this patch is addressing, so I consider it a different 
issue.  We don't allow atomic __GFP_NOFAIL allocations, so the context is 
really saying "I need this memory, and I'm willing to wait until it's 
available."  I only consider that to be significant to oom killer livelock 
if it is holding a mutex that the victim depends on to handle its SIGKILL.  
With my patch, that thread would also get access to memory reserves to 
make forward progress after the expiration has lapsed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
