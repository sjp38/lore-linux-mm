Message-ID: <19990830233930.A948@rz.uni-duesseldorf.de>
Date: Mon, 30 Aug 1999 23:39:30 +0200
From: Andreas Beck <becka@rz.uni-duesseldorf.de>
Subject: Re: accel handling
References: <m1aer9je4i.fsf@alogconduit1ae.ccr.net> <Pine.LNX.4.10.9908301507530.5887-100000@imperial.edgeglobal.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.10.9908301507530.5887-100000@imperial.edgeglobal.com>; from James Simmons on Mon, Aug 30, 1999 at 03:18:40PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ggi-develop@eskimo.com, "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Marcus Sundberg <erammsu@kieraypc01.p.y.ki.era.ericsson.se>, "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org, FrameBuffer List <linux-fbdev@vuser.vu.union.edu>
List-ID: <linux-mm.kvack.org>

> > C) We could simply put all processes that have the frame buffer
> >    mapped to sleep during the interval that the accel enginge runs.

I am missing a little bit of context here, but I assume you are talking
about how to handle concurrent framebuffer and accelerator access.

I think there are two different cases for this problem:

1) If the access happens concurrently, the hardware will lock up. This is
unfortunately the case with some common boards like the S3 Virge.

In that situation mandatory locking of the two ressources is required
to keep the system stable. 

The only solution I see for that is unmapping the framebuffer for all
processes that have it mapped. I know that this is bad bad bad performance
wise, but I'm afraid we can't help it. I think it is a little more friendly
than to just halt all apps. They might just be doing innocent calculations
or something. It is early enough to halt them when they try to touch the
framebuffer, which will trigger a nopage exception, as it is unmapped.

Also note, that this is only a real issue on MP, as on single processor
systems, you are sure that no concurrent access is ongoing by just waiting
for the accel call to finish. depending on how quick that is expected, I'd
suggest to either busy wait on the accel call (for very quick ones) or to 
stop the applicatition and reschedule until the accel is done.

2) Concurrent access causes only "correctable" problems like a messed up
display.

In that case, I suggest to rely on a "advisory" locking scheme, that can be
implemented to be really quick using kernel-/usermode shared locks.

It requires that you "lock" the FB before accessing it, as well as the
accelerator. These two locks would be mutually exclusive, so accels are
blocked while FB is in use and vice versa. The advantage is, that you 
need no expensive map/unmap or other similar schemes. However it relies on
applications being benevolent and not holding locks for excessive amounts of
time or ignoring the locks.
As long as system stability is not affected (I.e. you can somehow still
kill off the malfunctioning program), I assume that to be acceptable, as it
isn't differnt from the situation on X today, where any client can seriously
mess up my display and limit my interaction potential with other apps
or the windowmanager by generating tons of windows right under the mouse
pointer or similar..

If you for some reason want a "lock override", as e.g. the X server might
want, if it has clients with DirectRendering style Fb access, this can be
done with kernel help, as the kernel can be asked to block everyone that
holds the FB lock. 

The accel lock is more tricky: _IF_ you want to allow userland accelerator
access for more than one process "simultaneously" (in the sense of processes
running timeshared, not necessarily SMP), you need to be able to save/restore 
the complete graphics engine state at scheduling time (or be able to 
influence scheduling).
The graphics engine has to be treated like sort of a coprocessor here.

This is often more tricky than it seems, as many cards have registers that
act differently on stuff like which registers have been _accessed_ before,
not necessarily what the complete dump of the regs is.

Unless you have a properly virtualizeable graphics board, I would not
recommend to have concurrent access to graphics engines. If the accel lock
is on, it is on. Tough luck. Fall back to software rendering or wait for the
lock to become free.
In that case doing the acceleration in some central entity (that can _track_
the card state) like a server process or a kernel driver is the better
solution.

> That it!!!! You gave me a idea. I just realize I have been thinking about
> it all wrong. Its not looking at if the framebuffer is being accessed but
> to keep track of all the processes that have mmap the framebuffer device.
> When the accel engine is ready to go we put all the processes that have
> /dev/fb mmapped to sleep no matter if its being access or not. 

That's kind of being rude to innocent processes, that might not even touch
the mmaped FB. I'd unmap and fault them to sleep, if they do access it.

> One thing that I would have to make sure that the same process thats being 
> put to sleep isn't also the one trying to use the accel engine.   

This is handled automatically by the scheme I describe above. Depending on
how you want to lay the stuff out exactly, it might be a good idea, to
_kill_ this process, if it tries to use accel and framebuffer concurrently.

CU, ANdy

-- 
= Andreas Beck                    |  Email :  <andreas.beck@ggi-project.org> =
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
