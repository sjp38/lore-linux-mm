Date: Sun, 10 Oct 1999 07:24:58 -0400
Message-Id: <199910101124.HAA32129@light.alephnull.com>
From: Rik Faith <faith@precisioninsight.com>
Subject: Re: MMIO regions
In-reply-to: <Pine.LNX.4.10.9910061633250.29637-100000@imperial.edgeglobal.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 7 Oct 99 19:40:32 GMT, James Simmons <jsimmons@edgeglobal.com> wrote:
> On Mon, 4 Oct 1999, Stephen C. Tweedie wrote:
> > On Mon, 4 Oct 1999 14:29:14 -0400 (EDT), James Simmons
> > <jsimmons@edgeglobal.com> said:
> > 
> > > Okay. But none of this prevents a rogue app from hosing your system. Such
> > > a process doesn't have to bother with locks or semaphores. 
> > 
> > And we talked about this before.  You _can_ make such a guarantee, but
> > it is hideously expensive especially on SMP.  You either protect the
> > memory or the CPU against access by the other app, and that requires
> > either scheduler or VM interrupts between CPUs.
> 
> No VM stuff. I think the better approach is with the scheduler. The nice
> thing about the schedular is the schedular lock. I'm assuming durning
> is lock no other process on any CPU can be resceduled. Its during the lock
> that I can test to see if a process is using a MMIO region that already in
> use by another process. If it is then skip this process. If not weight
> this process with the others. If a process is slected to be the next
> executed process then lock the mmio region. 

If I understand what you are saying, there are serious performance
implications for direct-rendering clients (in addition to the added
scheduler overhead, which will negatively impact overall system
performance).

I believe you are saying:
    1) There are n processes, each of which has the MMIO region mmap'd.
    2) The scheduler will only schedule one of these processes at a time,
       even on an SMP system.  [I'm assuming this is what you mean by "in
       use", since the scheduler can't know about actual MMIO writes -- it
       has to assume that a mapped region is a region that is "in use",
       even if it isn't (e.g., a threaded program may have the MMIO region
       mapped in n-1 threads, but may only direct render in 1 thread).]

On MMIO-based graphics cards (i.e., those that do not use traditional DMA),
a direct-rendering client will intersperse relatively long periods of
computation with relatively short periods of MMIO writes.  In your scheme,
one of these clients will run for a whole time slice before the other one
runs (i.e., they will run in alternate time slices, even on an SMP system
with sufficient processors to run both simultaneously).  Because actual
MMIO writes take up a relatively small fraction of that time slice,
rendering performance will potentially decrease by a factor of 2 (or more,
if more CPUs are available).  This is significant, especially since many
high-end OpenGL applications are threaded and expect to be able to run
simultaneously on SMP systems.

The cooperative locking system used by the DRI (see
http://precisioninsight.com/dr/locking.html) allows direct-rendering
clients to perform fine-grain locking only when the MMIO region is actually
being written.  The overhead for this system is extremely low (about 2
instructions to lock, and 1 instruction to unlock).  Cooperative locking
like this allows several threads that all map the same MMIO region to run
simultaneously on an SMP system.

-- 
Rik Faith: faith@precisioninsight.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
