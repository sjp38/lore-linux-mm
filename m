Date: Mon, 3 Jul 2000 15:32:13 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: maximum memory limit
Message-ID: <20000703153213.B29421@pcep-jamie.cern.ch>
References: <Pine.LNX.4.10.10002081506290.626-100000@mirkwood.dummy.home> <200007020535.WAA07278@woensel.zeropage.com> <20000703113525.F2699@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000703113525.F2699@redhat.com>; from sct@redhat.com on Mon, Jul 03, 2000 at 11:35:25AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Raymond Nijssen <raymond@zeropage.com>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Stephen C. Tweedie wrote:
> libc can easily mmap /dev/zero in chunks of multiple MB at a time if
> it wants to, and can then dole out that memory as if it was a huge
> piece of the heap without kernel involvement.

Several allocators already do that (including GCC's), but Glibc doesn't
AFAIK.

> You cannot have an arbitrarily growable heap, AND an arbitrarily
> growable stack, AND have the kernel correctly guess where to place
> mmaps.
> 
> One answer may be to start mmaps down near the heap boundary, and to
> teach glibc to be more willing to use mmap() for even small mallocs.
> That may break custom malloc libraries but should give the best
> results for code which uses the standard glibc malloc: it doesn't
> artificially restrain the stack or the mmap area.  Anything
> relying directly on [s]brk will be affected, of course.

There are lots of custom malloc libraries.  If you're going to teach
Glibc something anyway, why not add a new mmap flag?

One flag I think would be quite useful is MAP_NOCLOBBER|MAP_FIXED: there
are times when I'd like to be able to _try_ mapping something at a fixed
address, but fail if there is something mapped there already.  Currently
it's necessary to parse /proc/self/maps, and that's far from thread
safe.

The obvious use is for pre-relocated shared libraries, which can run at
any address but will load faster and share more pages if loaded at a
specific address.  (Especially if they're non-PIC).

As a natural extension, a map flag which says "try to map at the
supplied address, but if there is an object there search for a big
enough hole above the supplied address" would simultaneously be useful
for malloc optimisations like you're suggesting, and pre-relocated
shared libraries.  That would be MAP_NOCLOBBER without MAP_FIXED.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
