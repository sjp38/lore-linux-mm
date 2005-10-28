Date: Fri, 28 Oct 2005 16:20:40 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: munmap extremely slow even with untouched mapping.
In-Reply-To: <43620138.6060707@yahoo.com.au>
Message-ID: <Pine.LNX.4.61.0510281557440.3229@goblin.wat.veritas.com>
References: <20051028013738.GA19727@attica.americas.sgi.com>
 <43620138.6060707@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Robin Holt <holt@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 28 Oct 2005, Nick Piggin wrote:
> Robin Holt wrote:
> > 
> > I noticed that on ia64, the following simple program would take 24
> > seconds to complete.  Profiling revealed I was spending all that time
> > in unmap_vmas.  Looking over the function, I noticed that I would only
> > attempt 8 pages at a time (CONFIG_PREMPT).  I then thought through this
> > some more.  My particular application had one large mapping which was
> > never touched after being mmaped.
> 
> Ouch. I wonder why nobody's noticed this before. It really is
> horribly inefficient on sparse mappings, as you've noticed :(

Yes, it's a good observation from Robin.

It'll have been spoiling the exit speedup we expected from your
2.6.14 copy_page_range "Don't copy [faultable] ptes" fork speedup.

> I guess I prefer the following (compiled, untested) slight
> variant of your patch. Measuring work in terms of address range
> is fairly vague.... however, it may be the case that some
> architectures take a long time to flush a large range of TLBs?

I prefer your patch too.  But I'm not very interested in temporary
speedups relative to 2.6.14.  Attacking this is a job I'd put off
until after the page fault scalability changes, which make it much
easier to do a proper job.

But I'm still mulling over precisely what that proper job is.
Probably we allocate a buffer (with fallback of course) for the
page pointers, instead of using the per-cpu mmu_gather.

The point being, the reason for ZAP_BLOCK_SIZE, and its low value
when CONFIG_PREEMPT, is that zap_pte_range is liable to build up a
head of work (TLB flushing, swap freeing, page freeing) that had to
be done with preemption still disabled.  I'm aiming to do it with
with preemption enabled, and proper "do we need to break now?"
tests within zap_pte_range.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
