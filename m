Date: Sun, 14 Nov 1999 11:16:40 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: [patch] zoned-2.3.28-G5, zone-allocator, highmem, bootmem fixes
In-Reply-To: <19991114110625.A155@caffeine.ix.net.nz>
Message-ID: <Pine.LNX.4.10.9911141110480.1278-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Wedgwood <cw@f00f.org>
Cc: Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu, "Stephen C. Tweedie" <sct@redhat.com>, Christoph Rohland <hans-christoph.rohland@sap.com>
List-ID: <linux-mm.kvack.org>

On Sun, 14 Nov 1999, Chris Wedgwood wrote:

> > - modules should compile again.
> 
> you missed:

> +EXPORT_SYMBOL(zonelists);

whoops, thanks.

> > - cleaned up pgtable.h, split into lowlevel and highlevel parts, this
> >   fixes dependencies in mm.h & misc.c.
> 
> should asm-i386/pgtable include pgalloc.h? This is required for
> binfmt_aout but I don't think it is verr clean

> --- fs/binfmt_aout.c.orig	Sun Nov 14 10:39:17 1999
> +++ fs/binfmt_aout.c	Sun Nov 14 10:57:50 1999
>  #include <asm/pgtable.h>
> +#ifdef CONFIG_X86
> +#include <asm/pgalloc.h>
> +#endif

the solution is to:

 -#include <asm/pgtable.h>
 +#include <asm/pgalloc.h>

we do not want to put #ifdef CONFIG_X86-type of stuff into the main
kernel.

basically there are some 'low level' include files that need low-level
paging details, but do not have the highlevel structures defined like
struct mm. So i've split out all the highlevel code from pgtable.h (TLB
flushing and page table allocation) and have put it into pgalloc.h.
pgalloc.h includes pgtable.h.

> > - fixed boot task's swapper_pg_dir clearing
> 
> what else needs to be done to alloc the buffer cache to use the low
> 16MB? 

fallback from 'highmem => normalmem => dmamem' should work already.

> Oh, and on my laptop, performance is way down and it now swaps where
> it did not before... (looks like processes can't use the lower 16M
> either)

will have a look - i think we are simply out of balance somewhere, but
maybe it's something else. What i saw on 16MB is that kswapd is almost
constantly running, but process pages do get allocated in the lowest 16MB
as well.

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
