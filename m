Date: Fri, 21 Jan 2000 22:22:05 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: [PATCH] 2.2.1{3,4,5} VM fix
In-Reply-To: <Pine.LNX.4.21.0001220309310.2341-100000@alpha.random>
Message-ID: <Pine.LNX.3.96.1000121220237.14221B-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Rik van Riel <riel@nl.linux.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 22 Jan 2000, Andrea Arcangeli wrote:

> On Fri, 21 Jan 2000, Rik van Riel wrote:
> 
> >On Fri, 21 Jan 2000, Andrea Arcangeli wrote:
> >
> >> Since 2.1.x all GFP_KERNEL allocations (not atomic) succeed too.
> >
> >Alan, I think we've located the bug that made 2.2 kernels
> >run completely out of memory :)
> 
> Yes, the fix is to kill the meaningless 1 second polling loop and to
> replace it with a proper wakeup. It has definitely nothing to do with
> GFP_KERNEL semantics.
> 
> 	ftp://ftp.*.kernel.org/pub/linux/kernel/people/andrea/patches/v2.2/2.2.14/atomic-allocations-2.gz
> 
> >Andrea, the last few pages are meant for ATOMIC and
> >PF_MEMALLOC allocations only, otherwise you'll get
> >deadlock situations.
> 
> Deadlock happens only due a bug in the caller. That has nothing to do with
> failed atomic allocations or with the MM core.

I think the deadlock being referred by Rik to is that of getting stuck
trying to allocate memory while trying to perform a swapout.  Sure, it's
rare now, but not on low memory machines.

> About your proposed change (as I just said), the semantic you want to
> change whith your diff that I am quoting here:
> 
> >-               if (!freed && !(gfp_mask & (__GFP_MED | __GFP_HIGH)))
> >+               if (!freed && !(gfp_mask & __GFP_HIGH))
> 
> makes a difference _only_ if the machine goes _OOM_ (so when
> try_to_free_pages fails) and that's completly _unrelated_ with the
> failed-atomic-allocation case we are talking about. If the machine is OOM
> it's perfectly normal that atomic allocations fails. That's expected.

Wrong.  I have to agree with Rik on this one: even during normal use, you
want to keep at least freepages.min pages reserved only for atomic memory
allocations.  We did this back in 2.0, even in 1.2, and for good reason:
if an interrupt comes along and needs to allocate memory, we do *not* want
to be calling do_try_to_free_pages from irq context -- it throws the
latency of the interrupt through the roof!  Keeping that small pool of
atomic-only memory around means that the machine can continue routing
packets while netscape is starting up and eating all your memory, without
needlessly dropping packets or adding latency.  It also means that there
are a few pages grace for helping to combat memory fragmentation, and
gives heavy NFS traffic a better chance at getting thru.

> You are basically making GFP_KERNEL equal to GFP_USER and that's wrong. It
> makes sense that allocation triggered by the kernel have access to the
> whole free memory available: kernel allocations have the same privilegies
> of atomic allocations. The reason atomic allocations are atomic is that
> they can't sleep, that's all. If they could sleep they would be GFP_KERNEL
> allocations instead. The only difference between the two, is that the
> non-atomic allocations will free memory themselfs before accessing _all_
> the free memory because they _can_ do that.

GFP_KERNEL for the normal case *is* equal to GFP_USER.  It's GFP_BUFFER
and GFP_ATOMIC that are special and need to have access to a normally
untouched pool of memory. 

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
