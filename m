Date: Sun, 10 Oct 1999 10:21:24 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: MMIO regions
In-Reply-To: <199910101124.HAA32129@light.alephnull.com>
Message-ID: <Pine.LNX.4.10.9910101003260.29982-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik Faith <faith@precisioninsight.com>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

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
> On MMIO-based graphics cards (i.e., those that do not use traditional DMA),
> a direct-rendering client will intersperse relatively long periods of
> computation with relatively short periods of MMIO writes.  In your scheme,
> one of these clients will run for a whole time slice before the other one
> runs (i.e., they will run in alternate time slices, even on an SMP system
> with sufficient processors to run both simultaneously).  Because actual
> MMIO writes take up a relatively small fraction of that time slice,
> rendering performance will potentially decrease by a factor of 2 (or more,
> if more CPUs are available).  This is significant, especially since many
> high-end OpenGL applications are threaded and expect to be able to run
> simultaneously on SMP systems.
>

I notice this when I was playing with my code. Also I realized regular
kernel semaphores are not going to be able to give you hard realtime
guarantees that are needed. Even the regular interrupt handling is just
not good enough. A good example is VBL. With ordinary interrupt handling
it takes a enormous amount of time to get to the interrput handler. The
effect gets worst under a very highly loaded machine. The tearing effect
gets worst. Its not unusual for a graphics program to create a high load
either. So actually I'm designing a hard realtime schedular that does
this. The regular schedular is not going to cut the mustard. Plus this
gives a enormous performace boost no matter what the load. Someone
familiar with IRIX told me thats what SGI does to optimize their systems.
Also you can have the following 


Data-> accel engine
                  context switch 
                        other data->accel engine.

This would confuss most cards. With a realtime handler you can make sure
that a accel command is finished then allow a context switch.

> The cooperative locking system used by the DRI (see
> http://precisioninsight.com/dr/locking.html) allows direct-rendering
> clients to perform fine-grain locking only when the MMIO region is actually
> being written.  The overhead for this system is extremely low (about 2
> instructions to lock, and 1 instruction to unlock).  Cooperative locking
> like this allows several threads that all map the same MMIO region to run
> simultaneously on an SMP system.

I'm familar with the system.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
