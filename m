Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2A0766B00BF
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 16:58:04 -0500 (EST)
Message-ID: <499B32E4.4080501@goop.org>
Date: Tue, 17 Feb 2009 13:57:56 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] vm_unmap_aliases: allow callers to inhibit TLB flush
References: <49416494.6040009@goop.org> <200707241140.12945.nickpiggin@yahoo.com.au> <49470433.4050504@goop.org> <200812301442.37654.nickpiggin@yahoo.com.au>
In-Reply-To: <200812301442.37654.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, Arjan van de Ven <arjan@linux.intel.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> I have patches to move the tlb flushing to an asynchronous process context...
> but all tweaks to that (including flushing at vmap) are just variations on the
> existing flushing scheme and don't solve your problem, so I don't think we
> really need to change that for the moment (my patches are mainly for latency
> improvement and to allow vunmap to be usable from interrupt context).
>   

Hi Nick,

I'm very interested in being able to call vm_unmap_aliases() from 
interrupt context.  Does the work you mention here encompass that?

For Xen dom0, when someone does something like dma_alloc_coherent, we 
allocate the memory as normal, and then swizzle the underlying physical 
pages to be machine physically contiguous (vs contiguous pseudo-physical 
guest memory), and within the addressable range for the device.  In 
order to do that, we need to make sure the pages are only mapped by the 
linear mapping, and there are no other aliases.

And since drivers are free to allocate dma memory at interrupt time, 
this needs to happen at interrupt time too.

(The tlb flush issue that started this read should be a non-issue for 
Xen, at least, because all cross-cpu tlb flushes should happen via  a 
hypercall rather than kernel-initiated IPIs, so there's no possibility 
of deadlock.  Though I'll happily admit that taking advantage of the 
implementation properties of a particular implementation is not very 
pretty...)

Thanks,
    J


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
