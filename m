Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id C88186B0032
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 20:36:46 -0400 (EDT)
Received: by igbzc4 with SMTP id zc4so46798985igb.0
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 17:36:46 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com. [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id 83si8352998iok.94.2015.06.10.17.36.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jun 2015 17:36:46 -0700 (PDT)
Received: by igbhj9 with SMTP id hj9so46170422igb.1
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 17:36:45 -0700 (PDT)
Date: Wed, 10 Jun 2015 17:36:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: always panic on OOM when panic_on_oom is
 configured
In-Reply-To: <20150610075221.GC4501@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1506101717340.1931@chino.kir.corp.google.com>
References: <1433159948-9912-1-git-send-email-mhocko@suse.cz> <alpine.DEB.2.10.1506041607020.16555@chino.kir.corp.google.com> <20150605111302.GB26113@dhcp22.suse.cz> <alpine.DEB.2.10.1506081242250.13272@chino.kir.corp.google.com> <20150608213218.GB18360@dhcp22.suse.cz>
 <alpine.DEB.2.10.1506081606500.17040@chino.kir.corp.google.com> <20150609094356.GB29057@dhcp22.suse.cz> <alpine.DEB.2.10.1506091516000.30516@chino.kir.corp.google.com> <20150610075221.GC4501@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, 10 Jun 2015, Michal Hocko wrote:

> > Not necessarily.  We pin a lot of memory with get_user_pages() and 
> > short-circuit it by checking for fatal_signal_pending() specifically for 
> > oom conditions.  This was done over six years ago by commit 4779280d1ea4 
> > ("mm: make get_user_pages() interruptible").  When such a process is 
> > faulting in memory, and it is killed by userspace as a result of an oom 
> > condition, it needs to be able to allocate (TIF_MEMDIE set by the oom 
> > killer due to SIGKILL), return to __get_user_pages(), abort, handle the 
> > signal, and exit.
> > 
> > I can't possibly make that any more clear.
> 
> Are you even reading what I've written? I will ask for the last
> time. What exactly prevents other allocation to trigger to oom path and
> panic the system before the killed task has a chance to terminate?
> 

If there are other threads that call into the oom killer that are not in 
the exit path or have a SIGKILL to handle, then the machine panics.  
That's the purpose of panic_on_oom: the kernel has no way to free memory 
without killing a process, so the admin has chosen to panic rather than 
wait for memory to become available, which may never happen.

This is how panic_on_oom has always worked.

> > Your patch causes that to instead panic the system if panic_on_oom is set.  
> > It's inappropriate and userspace breakage.  The fact that I don't 
> > personally use panic_on_oom is completely and utterly irrelevant.
> > 
> > There is absolutely nothing wrong with a process that has been killed 
> > either directly by userspace or as part of a group exit, or a process that 
> > is already in the exit path and needs to allocate memory to be able to 
> > free its memory, to get access to memory reserves.  That's not an oom 
> > condition, that's memory reserves.  Panic_on_oom has nothing to do with 
> > this scenario whatsoever.
> 
> It very much has and I have presented arguments about that which you
> didn't bother to comment on. TIF_MEMDIE is not a magic which will help a
> task to exit in all cases. It is a heuristic and it can fail.
> panic_on_oops is a hand break when things go wrong and you want to
> reduce your unresponsive time (read failover part in the documentation).
> 

Threads that have been oom killed and have TIF_MEMDIE set should exit.  
It's certainly a problem if they do not, since the oom killer relies on it 
and will defer forever until it does exit.  (We don't actually require 
that the thread fully exit, we just require that its memory is freed.)  If 
you're trying to address the issue that Tetsuo Handa brought up (strange, 
because you seemed to not want Tetsuo to talk), then that needs to be 
handled in a way that makes forward progress.  I suggested three methods 
for doing that in this thread that can be pursued to do that, but 
panicking the system is not one of them.

> > Panic_on_oom is not panic_when_reclaim_fails. 
> 
> OOM is when all other reclaim attempts fail. Jeez we are in
> out_of_memory how can this be potentially unclear to you? Yes oom killer
> path might use heuristics to reduce the impact of the OOM condition but
> once we are in this path _we_are_OOM_.
> 

Hmm, not exactly.  You can't make the same argument for GFP_ATOMIC 
allocations, for instance, where we don't have the ability to reclaim.  
They get access to a memory reserve so they may succeed in this context.  
In the case your patch is short-circuiting, a GFP_KERNEL allocation can 
fail to reclaim and then you've decided to panic rather than give an 
exiting thread access to memory reserves.  It's unnecessary.

(I personally don't care what you do or do not label "oom", I only care 
about panic vs. no-panic when the kernel has the ability to allow the 
allocation to succeed and make forward progress.)

Let me be clear: the issue that Tetsuo brings up is very real and serious.  
It exists for system memory as well as memcg.  Trying to address it with 
panic_on_oom is absurd.  It may be difficult to address, and require 
substantial VM work to fix, but panicking is not a solution and would lead 
to arbitrary machines in a very large fleet rebooting.  There's nothing 
the userspace programmer could have done differently to prevent it, this 
is solely a kernel issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
