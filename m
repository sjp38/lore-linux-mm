Date: Tue, 26 Oct 1999 11:11:55 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: page faults
In-Reply-To: <m1ln8qcjcs.fsf@flinx.hidden>
Message-ID: <Pine.LNX.4.10.9910260959310.23940-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: "William J. Earl" <wje@cthulhu.engr.sgi.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 26 Oct 1999, Eric W. Biederman wrote:

> "William J. Earl" <wje@cthulhu.engr.sgi.com> writes:
> 
> > Eric W. Biederman writes:
> > ...
> >  > If the hardware cannot support two processors hitting the region simultaneously,
> >  > (support would be worst case the graphics would look strange)
> >  > you could have problems.
> > ...
> >       One could reasonably take the view that a threads-aware graphics library
> > should be thread-safe.  That is, if the hardware needs to have concurrent
> > threads in a single process serialize access to the hardware, then the 
> > library plugin for that hardware should do the required serialization.

This would require a rewrite of opengl since opengl is heavly threaded.
Yes in IRIX all processes and threads have have their own private
mappings. This is what makes the direct engine work under threaded apps
and non threaded apps for IRIX. Of course linux having shared mapping
between threads does present a barrier. Nothing that can't be solved :) 

> >       This of course the neglects the question of whether a broken
> > user-mode program could damage the hardware, but then a broken
> > single-threaded user-mode program, with no other programs using the
> > hardware, could just as easily damage the hardware.  That is, if the
> > hardware is not safe for direct access in general, threading does not
> > make it any less safe.
> 
> Except on logically ``single thread'' hardware. Which I have heard exists.
> Where the breakage point is simple writers hitting the harware at the
> same time.
> 
> And since James work seems to have been how to protect the world from
> broken hardware. . .

Since I'm talking about sgi machines here there doesn't exist a broken
hardware problem. Even with this case SGI ensures non simultaneous access
to the hardware by different processes. The reason being is the point of
/dev/gfx on SGI is to properly virtualize the graphics engine. This means 
that from the point of each process that process believes it has sole
access to the graphics engine and its does for the time slice of the
current process. Allowing two threads similtaneous access defeats the
whole point of virtualization. If you don't want to virtualize the accel
engine of any cards then you are better off writing just userland
libraries to handle this. Of course you have to put up with the headaches
of making sure all userland code using the accel engine talk to each other
so they don't step on each other toes (ie cooperative locking). Virtuialization
is my most important goal. If you have proper virtuailization then access
to broken hardware is not a problem then. Except in the case where the
hardware mapps dangerous registers with the accel registers to userland. 

> Also for the sgi hardware the design I believe is with the kernel
> doing all of the thread/porocess synchronization by mapping/unmapping
> the hardware.  That technique does not work on linux.

For linux yes the approach is to use the page fault handler to test to see
if a different process already has this mapping. If this is the case
revoke that mapping. Then map that into the current process address
space. See linux/drivers/sgi/char/graphics.c sgi_graphics_nopage to see
what I mean. IRIX does it differently. It truly virtualizes the graphics
engine. To the point where you don't need coperative locking. It
uses a schedular *HOOK* and the page fault handler to manage proper
virtualization. Lets give a few examples of what actually happens. Let
start with one app using the graphics engine. It causes a page fault and 
on the page fault locks the accel engine with a semaphore. Thus you only
have the cost at page fault time instead of unlocking and locking before
each MMIO region access. Now a second process wants to use the accel
engine while the first is using it. It faults and queues up on a
semaphore, and the next time the first process context switches, it
releases access to the graphics engine and the second process gets it's
mapping validated. The next time the first process resumes, the scheduling
hook make sure that the process doesn't have a valid mapping so that it
will fault the next time its tries to access the graphics engine. So this
is how IRIX does it. It does it quit well even on their monster machines
with 128 CPUs and 16 video cards. Now you are asking is the schedular
hook really needed. If you have a process that locks the MMIO regions
then does a sleep(60) you can't have it blocking all the other processes 
waiting for the graphcis engine. Now don't think is hook is a big
massive rewrite of the scehdular. It knows nothing about graphics
hardware. All it does is call a specific driver function if it needs
to. I know some people would go nuts seeing something about a
schedular change. Even a small one like this. This is the technique I
would like seen ported to linux.       




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
