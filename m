Date: Mon, 3 Jul 2000 15:18:23 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: maximum memory limit
Message-ID: <20000703151823.D3284@redhat.com>
References: <Pine.LNX.4.10.10002081506290.626-100000@mirkwood.dummy.home> <200007020535.WAA07278@woensel.zeropage.com> <20000703113525.F2699@redhat.com> <20000703153213.B29421@pcep-jamie.cern.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000703153213.B29421@pcep-jamie.cern.ch>; from lk@tantalophile.demon.co.uk on Mon, Jul 03, 2000 at 03:32:13PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Raymond Nijssen <raymond@zeropage.com>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Jul 03, 2000 at 03:32:13PM +0200, Jamie Lokier wrote:

> There are lots of custom malloc libraries.  If you're going to teach
> Glibc something anyway, why not add a new mmap flag?

Because by the time glibc has been loaded, it's too late!  We need the
crt0.o stub to load libdl.so lower in memory or we have already
clobbered the address space irretrievably.  That's why Ben's proposal
for a per-process prctl() for the mmap base would seem to work well
--- you can just use floating mmaps and the kernel will automatically
place them somewhere that won't interfere with really large mallocs.

> One flag I think would be quite useful is MAP_NOCLOBBER|MAP_FIXED: there
> are times when I'd like to be able to _try_ mapping something at a fixed
> address, but fail if there is something mapped there already.

Good idea, but it doesn't help this problem.  

> As a natural extension, a map flag which says "try to map at the
> supplied address, but if there is an object there search for a big
> enough hole above the supplied address" would simultaneously be useful
> for malloc optimisations like you're suggesting, and pre-relocated
> shared libraries.  That would be MAP_NOCLOBBER without MAP_FIXED.

That's what non-MAP_FIXED mmaps already do.  From mmap.c:

	/* Obtain the address to map to. we verify (or select) it and
ensure
	 * that it represents a valid section of the address space.
	 */
	if (flags & MAP_FIXED) {
		if (addr & ~PAGE_MASK)
			return -EINVAL;
	} else {
		addr = get_unmapped_area(addr, len);
		if (!addr)
			return -ENOMEM;
	}

get_unmapped_area looks for the next unmapped area above addr,
with the start address defaulting to TASK_UNMAPPED_BASE only if
addr==0 going in.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
