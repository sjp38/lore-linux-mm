MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Date: Sun, 10 Oct 1999 14:46:05 -0400 (EDT)
From: Rik Faith <faith@precisioninsight.com>
Subject: Re: MMIO regions
In-Reply-To: [Eric W. Biederman <ebiederm+eric@ccr.net>]     10 Oct 1999 09:03:11 -0500
References: <199910101124.HAA32129@light.alephnull.com>
	<m1emf3wbxc.fsf@alogconduit1ai.ccr.net>
Message-ID: <14336.53971.896012.84699@light.alephnull.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Rik Faith <faith@precisioninsight.com>, James Simmons <jsimmons@edgeglobal.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On     10 Oct 1999 09:03:11 -0500,
   Eric W. Biederman <ebiederm+eric@ccr.net> wrote:
> Rik Faith <faith@precisioninsight.com> writes:
> > The cooperative locking system used by the DRI (see
> > http://precisioninsight.com/dr/locking.html) allows direct-rendering
> > clients to perform fine-grain locking only when the MMIO region is actually
> > being written.  The overhead for this system is extremely low (about 2
> > instructions to lock, and 1 instruction to unlock).  Cooperative locking
> > like this allows several threads that all map the same MMIO region to run
> > simultaneously on an SMP system.
> 
> The difficulty is that all threads need to be run as root.
> Ouch!!!

No.  The DRI assumes that direct-rendering clients are running as non-root
users.  A direct-rendering client, with an open connection to the X server,
is allowed to mmap the MMIO region via a special device (additional
restrictions also apply).  For more information, please see "A Security
Analysis of the Direct Rendering Infrastructure"
(http://precisioninsight.com/dr/security.html).

> Personally I see 3 functional ways of making this work on buggy single
> threaded hardware.
> 
> 1)  Allow only one process to have the MMIO/Frame buffer regions faulted in 
> at a time.  As simultaneous frame buffer and MMIO writes are reported to 
> have hardware crashing side effects.

Faulting doesn't work on low-end (e.g., any PC-class hardware) because two
clients cannot intermingle their MMIO writes.

> 2) Convince user space to have dedicated drawing/rendering threads that
> are created with fork rather than clone.  Then these threads can be
> cautiously scheduled to work around buggy hardware.

We don't want to require that large existing OpenGL applications be
re-written for Linux -- we'd like them to be easily ported to Linux.  In
any case, I don't see how using processes instead of thread makes this
problem any easier.

> 3) Have a set of very low overhead syscalls that will manipulate MMIO,
> etc.  This might work in conjunction with 2 and have a fast path that just
> makes nothing else is running that could touch the frame buffer.
> (With Linux cheap syscalls this may be possible)

One of the advantages of "direct rendering" is that the clients talk
directly to the hardware.  Adding a syscall interface for MMIO will create
a significant performance hit (the whole reason for providing direct
rendering is performance -- if you add significant overhead in the
direct-rendering pathway, then you might as well just implement an
indirect-rendering solution).

> What someone (not me) needs to do is code up a multithreaded test
> application that shoots pictures to the screen, and needs these features.
> And run tests with multiple copies of said test application running.  On
> various kernel configurations to see if it will work and give acceptable
> performance.

The DRI has been implemented and is available in XFree86 3.9.15 (and up).
The DRI supports multiple simultaneous direct-rendering clients.

> Extending the current architecture with just X server needing to be
> trusted doesn't much worry me.  But we really need to find
> an alternative to encouraing SUID binary only games (and other
> intensive clients).

Just to clarify, the DRI does _not_ require that clients be SUID.



If you are interested in reading more about the DRI, there are several
high- and low-level design documents available from
http://precisioninsight.com/piinsights.html.

Those who are not familiar with the basic ideas and requirements for
direct-rendering should start with the following papers describing
implementations by SGI and HP:

[KBH95] Mark J. Kilgard, David Blythe, and Deanna Hohn. System Support for
OpenGL Direct Rendering.  Proceedings of Graphics Interface '95, Quebec
City, Quebec, May 1995. Available from
http://reality.sgi.com/mjk/direct/direct.html

[K97] Mark J. Kilgard.  Realizing OpenGL: Two Implementations of One
Architecture.  SIGGRAPH/Eurographics Workshop on Graphics Hardware, Los
Angeles, August 3-4, 1997. Avaialble from
http://reality.sgi.com/opengl/twoimps/twoimps.html

[LCPGH98] Kevin T. Lefebvre, Robert J. Casey, Michael, J. Phelps, Courtney
D. Goeltzenleuchter, and Donley B. Hoffman.  An Overview of the HP
OpenGL&reg; Software Architecture.  The Hewlett-Packard Journal, May 1998,
49(2): 9-18.  Available from
http://www.hp.com/hpj/98may/ma98a2.pdf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
