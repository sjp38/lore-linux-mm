Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id B4B6D6B006C
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 17:29:03 -0500 (EST)
Received: by mail-ie0-f181.google.com with SMTP id tp5so9784060ieb.40
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 14:29:03 -0800 (PST)
Received: from mail-ie0-x234.google.com (mail-ie0-x234.google.com. [2607:f8b0:4001:c03::234])
        by mx.google.com with ESMTPS id 129si10365005ion.103.2014.11.24.14.29.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 14:29:02 -0800 (PST)
Received: by mail-ie0-f180.google.com with SMTP id rp18so9510155iec.25
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 14:29:02 -0800 (PST)
Date: Mon, 24 Nov 2014 14:29:00 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/5] mm: Introduce OOM kill timeout.
In-Reply-To: <20141124165032.GA11745@curandero.mameluci.net>
Message-ID: <alpine.DEB.2.10.1411241417250.7986@chino.kir.corp.google.com>
References: <201411231349.CAG78628.VFQFOtOSFJMOLH@I-love.SAKURA.ne.jp> <201411231350.DDH78622.LOtOQOFMFSHFJV@I-love.SAKURA.ne.jp> <20141124165032.GA11745@curandero.mameluci.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org

On Mon, 24 Nov 2014, Michal Hocko wrote:

> > The problem described above is one of phenomena which is triggered by
> > a vulnerability which exists since (if I didn't miss something)
> > Linux 2.0 (18 years ago). However, it is too difficult to backport
> > patches which fix the vulnerability.
> 
> What is the vulnerability?
> 

There have historically been issues when oom killed processes fail to 
exit, so this is probably trying to address one of those issues.

The most notable example is when an oom killed process is waiting on a 
lock that is held by another thread that is trying to allocate memory and 
looping indefinitely since reclaim fails and the oom killer keeps finding 
the oom killed process waiting to exit.  This is a consequence of the page 
allocator looping forever for small order allocations.  Memcg oom kills 
typically see this much more often when you do complete kmem accounting: 
any combination of mutex + kmalloc(GFP_KERNEL) becomes a potential 
livelock.  For the system oom killer, I would imagine this would be 
difficult to trigger since it would require a process holding the mutex to 
never be able to allocate memory.

The oom killer timeout is always an attractive remedy to this situation 
and gets proposed quite often.  Several problems: (1) you can needlessly 
panic the machine because no other processes are eligible for oom kill 
after declaring that the first oom kill victim cannot make progress, (2) 
it can lead to unnecessary oom killing if the oom kill victim can exit but 
hasn't be scheduled or is in the process of exiting, (3) you can easily 
turn the oom killer into a serial oom killer since there's no guarantee 
the next process that is chosen won't be affected by the same problem, and 
(4) this doesn't fix the problem if an oom disabled process is wedged 
trying to allocate memory while holding a mutex that others are waiting 
on.

The general approach has always been to fix the actual issue in whatever 
code is causing the wedge.  We lack specific examples in this changelog 
and I agree that it seems to be papering over issues that could otherwise 
be fixed, so I agree with your NACK.

> We had a kind of similar problem in Memory cgroup controller because the
> OOM was handled in the allocation path which might sit on many locks and
> had to wait for the victim . So waiting for OOM victim to finish would
> simply deadlock if the killed task was stuck on any of the locks held by
> memcg OOM killer. But this is not the case anymore (we are processing
> memcg OOM from the fault path).
> 

I'm painfully aware of it happening with complete kmem accounting, however 
:)  I'm sure you can imagine the scenario that is causes and unfortunately 
our complete support isn't upstream so there's no code that I can point 
to.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
