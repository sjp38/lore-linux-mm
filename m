Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7CE756B003D
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 12:41:42 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH RFC] vm_unmap_aliases: allow callers to inhibit TLB flush
Date: Fri, 20 Feb 2009 04:41:07 +1100
References: <49416494.6040009@goop.org> <200902192254.31735.nickpiggin@yahoo.com.au> <499D90AE.7060102@goop.org>
In-Reply-To: <499D90AE.7060102@goop.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902200441.08541.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, Arjan van de Ven <arjan@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Friday 20 February 2009 04:02:38 Jeremy Fitzhardinge wrote:
> Nick Piggin wrote:
> > On Wednesday 18 February 2009 08:57:56 Jeremy Fitzhardinge wrote:
> >> Nick Piggin wrote:
> >>> I have patches to move the tlb flushing to an asynchronous process
> >>> context... but all tweaks to that (including flushing at vmap) are just
> >>> variations on the existing flushing scheme and don't solve your
> >>> problem, so I don't think we really need to change that for the moment
> >>> (my patches are mainly for latency improvement and to allow vunmap to
> >>> be usable from interrupt context).
> >>
> >> Hi Nick,
> >>
> >> I'm very interested in being able to call vm_unmap_aliases() from
> >> interrupt context.  Does the work you mention here encompass that?
> >
> > No, and it can't because we can't do the global kernel tlb flush
> > from interrupt context.
> >
> > There is basically no point in doing the vm_unmap_aliases from
> > interrupt context without doing the global TLB flush as well,
> > because you still cannot reuse the virtual memory, you still have
> > possible aliases to it, and you still need to schedule a TLB flush
> > at some point anyway.
>
> But that's only an issue when you actually do want to reuse the virtual
> address space.  Couldn't you set a flag saying "tlb flush needed", so
> when cpu X is about to use some of that address space, it flushes
> first?  Avoids the need for synchronous cross-cpu tlb flushes.  It
> assumes they're not currently using that address space, but I think that
> would indicate a bug anyway.

Then what is the point of the vm_unmap_aliases? If you are doing it
for security it won't work because other CPUs might still be able
to write through dangling TLBs. If you are not doing it for
security then it does not need to be done at all.

Unless it is something strange that Xen does with the page table
structure and you just need to get rid of those?


> (Xen does something like this internally to either defer or avoid many
> expensive tlb operations.)
>
> >> For Xen dom0, when someone does something like dma_alloc_coherent, we
> >> allocate the memory as normal, and then swizzle the underlying physical
> >> pages to be machine physically contiguous (vs contiguous pseudo-physical
> >> guest memory), and within the addressable range for the device.  In
> >> order to do that, we need to make sure the pages are only mapped by the
> >> linear mapping, and there are no other aliases.
> >
> > These are just stale aliases that will no longer be operated on
> > unless there is a kernel bug -- so can you just live with them,
> > or is it a security issue of memory access escaping its domain?
>
> The underlying physical page is being exchanged, so the old page is
> being returned to Xen's free page pool.  It will refuse to do the
> exchange if the guest still has pagetable references to the page.

But it refuses to do this because it is worried about dangling TLBs?
Or some implementation detail that can't handle the page table
entries?


> > If it is really no other way around it, it would be possible to
> > allow arch code to take advantage of this if it knows its TLB
> > flush is interrupt safe.
>
> It's almost safe.  I've got this patch in my tree to tie up the
> flush_tlb_all loose end, though I won't claim its pretty.

Hmm. Let's just try to establish that it is really required first.

Or... what if we just allow a compile and/or boot time flag to direct
that it does not want lazy vmap unmapping and it will just revert to
synchronous unmapping? If Xen needs lots of flushing anyway it might
not be a win anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
