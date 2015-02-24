Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2D30B6B0038
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 10:20:46 -0500 (EST)
Received: by yhaf73 with SMTP id f73so14447484yha.11
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 07:20:45 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id x186si10465709ykc.154.2015.02.24.07.20.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 24 Feb 2015 07:20:44 -0800 (PST)
Date: Tue, 24 Feb 2015 10:20:33 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150224152033.GA3782@thunk.org>
References: <20141230112158.GA15546@dhcp22.suse.cz>
 <201502162023.GGE26089.tJOOFQMFFHLOVS@I-love.SAKURA.ne.jp>
 <20150216154201.GA27295@phnom.home.cmpxchg.org>
 <201502172057.GCD09362.FtHQMVSLJOFFOO@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1502231347510.21127@chino.kir.corp.google.com>
 <201502242020.IDI64912.tOOQSVJFOFLHMF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201502242020.IDI64912.tOOQSVJFOFLHMF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, hannes@cmpxchg.org, mhocko@suse.cz, david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, fernando_b1@lab.ntt.co.jp

On Tue, Feb 24, 2015 at 08:20:11PM +0900, Tetsuo Handa wrote:
> > In a timeout based solution, this would be detected and another thread 
> > would be chosen for oom kill.  There's currently no way for the oom killer 
> > to select a process that isn't waiting for that same mutex, however.  If 
> > it does, then the process has been killed needlessly since it cannot make 
> > forward progress itself without grabbing the mutex.
> 
> Right. The OOM killer cannot understand that there is such lock dependency....

> The memory reserves are something like a balloon. To guarantee forward
> progress, the balloon must not become empty. All memory managing techniques
> except the OOM killer are trying to control "deflator of the balloon" via
> various throttling heuristics. On the other hand, the OOM killer is the only
> memory managing technique which is trying to control "inflator of the balloon"
> via several throttling heuristics.....

The mm developers have suggested in the past whether we could solve
problems by preallocating memory in advance.  Sometimes this is very
hard to do because we don't know exactly how much or if we need
memory, or in order to do this, we would need to completely
restructure the code because the memory allocation is happening deep
in the call stack, potentially in some other subsystem.

So I wonder if we can solve the problem by having a subsystem
reserving memory in advance of taking the mutexes.  We do something
like this in ext3/ext4 --- when we allocate a (sub-)transaction
handle, we give a worst case estimate of how many blocks we might need
to dirty under that handle, and if there isn't enough space in the
journal, we block in the start_handle() call while the current
transaction is closed, and the transaction handle will be attached to
the next transaction.

In the memory allocation scenario, it's a bit more complicated, since
the memory might be allocated in a slab that requires a higher-order
page allocation, but would it be sufficient if we do something rough
where the foreground kernel thread "reserves" a few pages before it
starts doing something that requires mutexes.  The reservation would
be reserved on an accounting basis, and kernel codepath which has
reserved pages would get priority over kernel threads running under a
task_struct which hsa not reserved pages.  If there the system doesn't
have enough pages available, then the reservation request would block
the process until more memory is available.

This wouldn't necessary help in cases where the memory is required for
cleaning dirty pages (although in those cases you really *do* want to
let the memory allocation succeed --- so maybe there should be a way
to hint to the mm subsystem that a memory allocation should be given
higher priority since it might help get the system out of the ham that
it is in).

However, for "normal" operations, where blocking a process who was
about to execute, say, a read(2) or a open(2) system call early,
*before* it takes some mutex, it owuld be good if we could provide a
certain amount of admission control when memory pressure is specially
high.

Would this be a viable strategy?

Even if this was a hint that wasn't perfect (i.e., it some cases a
kernel thread might end up requiring more pages than it had hinted,
which would not be considered fatal, although the excess requested
pages would be treated the same way as if no reservation was made at
all, meaning the memory allocation would be more likely to fail and a
GFP_NOFAIL allocation would loop for longer), I would think this could
only help us do a better job of "keeping the baloon from getting
completely deflated".

Cheers,

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
