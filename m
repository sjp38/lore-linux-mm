Date: Thu, 13 Apr 2000 02:35:28 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: Stack & policy
Message-ID: <20000413023528.D27244@pcep-jamie.cern.ch>
References: <Pine.LNX.3.95.1000412174014.810A-100000@ppp-pat138.tee.gr> <nnaeizpdfu.fsf@code.and.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <nnaeizpdfu.fsf@code.and.org>; from James Antill on Wed, Apr 12, 2000 at 11:05:25AM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Antill <james@and.org>
Cc: axanth@tee.gr, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

James Antill wrote:
> > Some time ago I posted a message about a kernel feature where the
> > application can request the vma->vm_start of its stack virtual memory area
> > in order to unmap part of the unused stack (esp - vma->vm_start).
> > 
> > Such a feature is very useful for an alternative programming technique.
> 
>  Have you seen jamie and chuck talking about madvise() flags ?
>  Just doing madvise(cur_stack, MADV_DONTNEED, cur_stack - end_stack)[1]
> after a function that uses alloca() or has a large auto should be
> a pretty simple addition to gcc (although you might not want to put it
> there).
> 
>  Those seem like a much better idea to me, as they can also be used in
> pthreads (much as I hate pthreads) and other bits of memory that has
> similar usage patterns.
>  This would also be much more likely to work on other OSes.

You'd use MADV_FREE, as it allows the app to reuse stack pages
immediately without the overhead of them being unmapped, remapped and
rezeroed -- if it reuses them before the kernel finds another use for
them.  The most efficiently place to put this call is probably in a
timer signal handler.

You still need to get the base of the mapped region though.  You can
parse /proc/self/maps for this :-)

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
