Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 98DB16B003D
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 06:55:04 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH RFC] vm_unmap_aliases: allow callers to inhibit TLB flush
Date: Thu, 19 Feb 2009 22:54:30 +1100
References: <49416494.6040009@goop.org> <200812301442.37654.nickpiggin@yahoo.com.au> <499B32E4.4080501@goop.org>
In-Reply-To: <499B32E4.4080501@goop.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902192254.31735.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, Arjan van de Ven <arjan@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 18 February 2009 08:57:56 Jeremy Fitzhardinge wrote:
> Nick Piggin wrote:
> > I have patches to move the tlb flushing to an asynchronous process
> > context... but all tweaks to that (including flushing at vmap) are just
> > variations on the existing flushing scheme and don't solve your problem,
> > so I don't think we really need to change that for the moment (my patches
> > are mainly for latency improvement and to allow vunmap to be usable from
> > interrupt context).
>
> Hi Nick,
>
> I'm very interested in being able to call vm_unmap_aliases() from
> interrupt context.  Does the work you mention here encompass that?

No, and it can't because we can't do the global kernel tlb flush
from interrupt context.

There is basically no point in doing the vm_unmap_aliases from
interrupt context without doing the global TLB flush as well,
because you still cannot reuse the virtual memory, you still have
possible aliases to it, and you still need to schedule a TLB flush
at some point anyway.


> For Xen dom0, when someone does something like dma_alloc_coherent, we
> allocate the memory as normal, and then swizzle the underlying physical
> pages to be machine physically contiguous (vs contiguous pseudo-physical
> guest memory), and within the addressable range for the device.  In
> order to do that, we need to make sure the pages are only mapped by the
> linear mapping, and there are no other aliases.

These are just stale aliases that will no longer be operated on
unless there is a kernel bug -- so can you just live with them,
or is it a security issue of memory access escaping its domain?


> And since drivers are free to allocate dma memory at interrupt time,
> this needs to happen at interrupt time too.
>
> (The tlb flush issue that started this read should be a non-issue for
> Xen, at least, because all cross-cpu tlb flushes should happen via  a
> hypercall rather than kernel-initiated IPIs, so there's no possibility
> of deadlock.  Though I'll happily admit that taking advantage of the
> implementation properties of a particular implementation is not very
> pretty...)

If it is really no other way around it, it would be possible to
allow arch code to take advantage of this if it knows its TLB
flush is interrupt safe.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
