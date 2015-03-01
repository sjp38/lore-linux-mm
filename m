Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id CB3976B0032
	for <linux-mm@kvack.org>; Sun,  1 Mar 2015 14:38:52 -0500 (EST)
Received: by ykt10 with SMTP id 10so11595873ykt.1
        for <linux-mm@kvack.org>; Sun, 01 Mar 2015 11:38:52 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id 9si4905245ykv.125.2015.03.01.11.38.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Sun, 01 Mar 2015 11:38:51 -0800 (PST)
Date: Sun, 1 Mar 2015 14:36:35 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150301193635.GB3287@thunk.org>
References: <20150217225430.GJ4251@dastard>
 <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
 <20150221235227.GA25079@phnom.home.cmpxchg.org>
 <20150223004521.GK12722@dastard>
 <20150228162943.GA17989@phnom.home.cmpxchg.org>
 <20150228164158.GE5404@thunk.org>
 <20150228221558.GA23028@phnom.home.cmpxchg.org>
 <20150301134322.GA3287@thunk.org>
 <20150301161506.GA1854@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150301161506.GA1854@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Dave Chinner <david@fromorbit.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Sun, Mar 01, 2015 at 11:15:06AM -0500, Johannes Weiner wrote:
> 
> We had these lockups in cgroups with just a handful of threads, which
> all got stuck in the allocator and there was nobody left to volunteer
> unreclaimable memory.  When this was being addressed, we knew that the
> same can theoretically happen on the system-level but weren't aware of
> any reports.  Well now, here we are.

I think the "few threads in a small" cgroup problem is a little
difference, because in those cases very often the global system has
enough memory, and there is always the possibility that we might relax
the memory cgroup guarantees a little in order to allow forward
progress.

In fact, arguably this *is* the right thing to do, because we have
situations where (a) the VFS takes the directory mutex, (b) the
directory blocks have been pushed out of memory, and so (c) a system
call running in container with a small amount of memory and/or a small
amount of disk bandwidth allowed via its prop I/O settings ends up
taking a very long time for the directory blocks to be read into
memory.  If a high priority process, like say a cluster management
daemon, also tries to to read the same directory, it can end up
stalled for long enough for the software watchdog to take out the
entire machine from the cluster.

The hard problem here is that the lock is taken by the VFS, *before*
it calls into the file system specific layer, and so the VFS has no
idea (a) how much memory or disk bandwidth it needs, and (b) whether
it needs any memory or disk bandwidth in the first place in order to
service a directory lookup operation (most of the time, it doesn't).
So there may be situations where in the restricted cgroup, it would
useful for the file system to be able to say, "you know, we're holding
onto a lock and the fact that the disk controller is going to force
this low priority cgroup to wait over a minute for the I/O to even be
queued out to the disk, maybe we should make an exception and bust the
disk controller cgroup cap".

(There is a related problem where a cgroup with a low disk bandwidth
quota is slowing down writeback, and we are desperately short on
global memory, and where relaxing the disk bandwidth limit via some
kind of priority inheritance scheme would prevent "innocent" high,
proprity cgroups from having some of their processes get OOM-killed.
I suppose one could claim that the high priority cgroups tend to
belong to the sysadmin, who set the stupid disk bandwidth caps in the
first place, so there is a certain justice in having the high priority
processes getting OOM killed, but still, it would be nice if we could
do the right thing automatically.)


But in any case, some of these workarounds, where we relax a
particuarly tightly constrained cgroup limit, are obviously not going
to help when the entire system is low on memory.

> It really depends on what the goal here is.  You don't have to be
> perfectly accurate, but if you can give us a worst-case estimate we
> can actually guarantee forward progress and eliminate these lockups
> entirely, like in the block layer.  Sure, there will be bugs and the
> estimates won't be right from the start, but we can converge towards
> the right answer.  If the allocations which are allowed to dip into
> the reserves - the current nofail sites? - can be annotated with a gfp
> flag, we can easily verify the estimates by serving those sites
> exclusively from the private reserve pool and emit warnings when that
> runs dry.  We wouldn't even have to stress the system for that.
> 
> But there are legitimate concerns that this might never work.  For
> example, the requirements could be so unpredictable, or assessing them
> with reasonable accuracy could be so expensive, that the margin of
> error would make the worst case estimate too big to be useful.  Big
> enough that the reserves would harm well-behaved systems.  And if
> useful worst-case estimates are unattainable, I don't think we need to
> bother with reserves.  We can just stick with looping and OOM killing,
> that works most of the time, too.

I'm not sure that you want to reserve for the worst-case.  What might
work is if subsystems (probably primarily file systems) give you
estimates for the usual case and the worst case, and you reserve for
the something in between these two bounds.  In practice there will be
a huge number of file systems operations taking place in your typical
super-busy system, and if you reserve for the worst case, it probably
will be too much.  We need to make sure there is enough memory
available for some forward progress, and if we need to stall a few
operations with some sleeping loops, so be it.  So I don't think the
"heads up" mounts don't have to be strict reservations in the sense
that the memory will be available instantly without any sleeping or
looping.

I would also suggest that "reservations" be tied to a task struct and
not to some magic __GFP_* flag, since it's not just allocations done
by the file system, but also by the block device drivers, and if
certain write operations fail, the results will be catastrophic -- and
the block device can't tell whether a particular I/O operatoion must
succeed or we declare the file system as needing manual recovery and
potentially reboot the entire system, and an I/O operation where a
fail could be handled by reflecting ENOMEM back up to userspace.  The
difference is a property of the call stack, so the simplest way of
handing this is to store the reservation in the task struct, and let
the reservation get automatically returned to the system when a
particular process makes a transition from kernel space to user space.

The bottom line is that I agree that looping and OOM-killing works
most of the time, and so I'm happy with something that makes life a
little bit better and a little bit more predictable for the VM, if
that makes the system behave a bit more smoothly under high memory
pressures.  But at the same time, we don't want to make things too
complicated; whether that means that we don't try to achieve
perfection, or simply not worry about the global memory pressure
situation, and instead try to think about other solutions to handle
the "small number of threads in a container, and try to OOM kill a bit
less frequently, and instead force it to loop/sleep for a bit, and
then let a random foreground kernel thread in the container allow to
"borrow" a small amount of memory to hopefully let it make forward
progress, especially if it is holding locks, or is in the process of
exiting, etc.

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
