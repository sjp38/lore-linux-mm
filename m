From: Raymond Nijssen <raymond@zeropage.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14688.59956.433676.615914@woensel.zeropage.com>
Date: Mon, 3 Jul 2000 12:32:04 -0700 (PDT)
Subject: Re: maximum memory limit
In-Reply-To: <20000703113525.F2699@redhat.com>
References: <Pine.LNX.4.10.10002081506290.626-100000@mirkwood.dummy.home>
	<200007020535.WAA07278@woensel.zeropage.com>
	<20000703113525.F2699@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

::: "SCT" == Stephen C Tweedie <sct@redhat.com> writes:

 > Hi,
 > On Sat, Jul 01, 2000 at 10:35:51PM -0700, Raymond Nijssen wrote:

 >> > It would certainly be a good option if libc could allocate
 >> > new chunks of memory with mmap, or a combination of mmap and mremap.
 >> > mremap is functionally a good as brk but will let you work with
 >> > arbitrary areas of memory. 
 >> 
 >> The current implementation of malloc already does that to a limited extent.
 >> The reason why it doesn't go any further than that is because overreliance on
 >> mmap() puts all the burden on the kernel, and you're likely to severely
 >> fragment your memory map.  Remember, mmap has a pagesize resolution.

 > libc can easily mmap /dev/zero in chunks of multiple MB at a time if
 > it wants to, and can then dole out that memory as if it was a huge
 > piece of the heap without kernel involvement.

Sure enough, mmapping anonymous chunks is easy.
It is not easy to efficiently manage those chunks.

This fragmentation (these chunks are oftentimes not abutting -- you have
limited control over that) is hard to manage.  Make them big and you'll waste
tons of resources.  Make them small and you'll be unable to consolidate free
ranges to satisfy large requests.

Writing an efficient allocator is actually a pretty tough problem.  It has to
be fast, low-fragmenting, low administration overhead, low waste, etc.
Add to that the ability to co-exist with other sbrk()ing allocators, mmap()ing
routines and other complicating factors.
An erratic context makes those objectives so much harder to achieve.

Yes some workarounds can may be made to work.  They make nices excercises, but
it's still putting the horse behind the carriage.
There's no substitute for a large unadorned memory space.


 >> So how about getting rid of this memory map dichotomy?
 >> 
 >> The shared libs could be mapped from 3GB-max_stacksize downwards (rather than
 >> from 1GB upwards).
 >> 
 >> Is there any reason why this cannot be done?

 > You then break all programs which allocate large arrays on the stack.

Most programmers are wise enough not to assume a large stack.
For one because the stack has a fixed size on all major unices, typically 8MB
(Solaris) or 80MB (HP/UX). 

Does anybody know about programs requiring more than that?


 > You cannot have an arbitrarily growable heap, AND an arbitrarily
 > growable stack, AND have the kernel correctly guess where to place
 > mmaps.

Absolutely.   It's a matter of choosing which one to confine.

Practically it is better to confine the stack.

The rare exception for which the default max stacksize is not enough can be
resolved easily by a wrapper that sets a different resource limit.


 > One answer may be to start mmaps down near the heap boundary, and to
 > teach glibc to be more willing to use mmap() for even small mallocs.
 > That may break custom malloc libraries but should give the best
 > results for code which uses the standard glibc malloc: it doesn't
 > artificially restrain the stack or the mmap area.  Anything
 > relying directly on [s]brk will be affected, of course.

I don't understand this fear for limiting the stack:  in practice that just
isn't a problem.  If anything one should fear fragmenting the heap:  I have
seen many cases in which that is a severe problem.

YMMV of course, and if it does, please share your experiences.

-Raymond
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
