Subject: Re: MMIO regions
References: <199910101124.HAA32129@light.alephnull.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 10 Oct 1999 09:03:11 -0500
In-Reply-To: Rik Faith's message of "Sun, 10 Oct 1999 07:24:58 -0400"
Message-ID: <m1emf3wbxc.fsf@alogconduit1ai.ccr.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik Faith <faith@precisioninsight.com>
Cc: James Simmons <jsimmons@edgeglobal.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik Faith <faith@precisioninsight.com> writes:

> On 7 Oct 99 19:40:32 GMT, James Simmons <jsimmons@edgeglobal.com> wrote:
> > On Mon, 4 Oct 1999, Stephen C. Tweedie wrote:
> > > On Mon, 4 Oct 1999 14:29:14 -0400 (EDT), James Simmons
> > > <jsimmons@edgeglobal.com> said:
[snip]
> If I understand what you are saying, there are serious performance
> implications for direct-rendering clients (in addition to the added
> scheduler overhead, which will negatively impact overall system
> performance).
> 
> I believe you are saying:
>     1) There are n processes, each of which has the MMIO region mmap'd.
>     2) The scheduler will only schedule one of these processes at a time,
>        even on an SMP system.  [I'm assuming this is what you mean by "in
>        use", since the scheduler can't know about actual MMIO writes -- it
>        has to assume that a mapped region is a region that is "in use",
>        even if it isn't (e.g., a threaded program may have the MMIO region
>        mapped in n-1 threads, but may only direct render in 1 thread).]
>
That was one idea.

There is the other side here.  Software is buggy and hardware is buggy.
If some buggy software forgets to take the lock (or messes it up),
and two apps hit the MMIO region at the same time.

BOOOMM!!!! your computer is toast.

The DRI approach looks good if:
   Your hardware is good enough it won't bring down the box, on cooperation failure.
   And hopefully it is good enough that after it gets scrabled by cooperation failure you
   can reset it.

> 
> The cooperative locking system used by the DRI (see
> http://precisioninsight.com/dr/locking.html) allows direct-rendering
> clients to perform fine-grain locking only when the MMIO region is actually
> being written.  The overhead for this system is extremely low (about 2
> instructions to lock, and 1 instruction to unlock).  Cooperative locking
> like this allows several threads that all map the same MMIO region to run
> simultaneously on an SMP system.

The difficulty is that all threads need to be run as root.
Ouch!!!


Personally I see 3 functional ways of making this work on buggy single threaded
hardware.

1)  Allow only one process to have the MMIO/Frame buffer regions faulted in 
at a time.  As simultaneous frame buffer and MMIO writes are reported to 
have hardware crashing side effects.

2) Convince user space to have dedicated drawing/rendering threads that
are created with fork rather than clone.  Then these threads can be cautiously
scheduled to work around buggy hardware.

3) Have a set of very low overhead syscalls that will manipulate MMIO,
etc.  This might work in conjunction with 2 and have a fast path that just
makes nothing else is running that could touch the frame buffer.
(With Linux cheap syscalls this may be possible)

The fundamental problem that makes this hard are:
1) It is very desireable to for this to work in a windowed environment with
many apps running simultaneously, (the X server wants to hand off some of the work).

2) The hardware is buggy so you must either:
    a) Have many trusted (SUID) clients.
    b) Have very clever work arounds that give high performance.
    c) Lose some performance.
         Either just the X server is trusted and you must tell it what to do,
         or some other way.

What someone (not me) needs to do is code up a multithreaded test application
that shoots pictures to the screen, and needs these features.  And run
tests with multiple copies of said test application running.  On
various kernel configurations to see if it will work and give
acceptable performance.

Extending the current architecture with just X server needing to be
trusted doesn't much worry me.  But we really need to find
an alternative to encouraing SUID binary only games (and other
intensive clients).

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
