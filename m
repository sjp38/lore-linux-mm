Date: Mon, 3 Jul 2000 11:35:25 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: maximum memory limit
Message-ID: <20000703113525.F2699@redhat.com>
References: <Pine.LNX.4.10.10002081506290.626-100000@mirkwood.dummy.home> <200007020535.WAA07278@woensel.zeropage.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200007020535.WAA07278@woensel.zeropage.com>; from raymond@zeropage.com on Sat, Jul 01, 2000 at 10:35:51PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Raymond Nijssen <raymond@zeropage.com>
Cc: Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, Jul 01, 2000 at 10:35:51PM -0700, Raymond Nijssen wrote:

> > It would certainly be a good option if libc could allocate
> > new chunks of memory with mmap, or a combination of mmap and mremap.
> > mremap is functionally a good as brk but will let you work with
> > arbitrary areas of memory. 
> 
> The current implementation of malloc already does that to a limited extent.
> The reason why it doesn't go any further than that is because overreliance on
> mmap() puts all the burden on the kernel, and you're likely to severely
> fragment your memory map.  Remember, mmap has a pagesize resolution.

libc can easily mmap /dev/zero in chunks of multiple MB at a time if
it wants to, and can then dole out that memory as if it was a huge
piece of the heap without kernel involvement.

> So how about getting rid of this memory map dichotomy?
> 
> The shared libs could be mapped from 3GB-max_stacksize downwards (rather than
> from 1GB upwards).
> 
> Is there any reason why this cannot be done?

You then break all programs which allocate large arrays on the stack.

You cannot have an arbitrarily growable heap, AND an arbitrarily
growable stack, AND have the kernel correctly guess where to place
mmaps.

One answer may be to start mmaps down near the heap boundary, and to
teach glibc to be more willing to use mmap() for even small mallocs.
That may break custom malloc libraries but should give the best
results for code which uses the standard glibc malloc: it doesn't
artificially restrain the stack or the mmap area.  Anything
relying directly on [s]brk will be affected, of course.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
