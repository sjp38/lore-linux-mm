Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E14BF6B0047
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 12:02:43 -0500 (EST)
Message-ID: <499D90AE.7060102@goop.org>
Date: Thu, 19 Feb 2009 09:02:38 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] vm_unmap_aliases: allow callers to inhibit TLB flush
References: <49416494.6040009@goop.org> <200812301442.37654.nickpiggin@yahoo.com.au> <499B32E4.4080501@goop.org> <200902192254.31735.nickpiggin@yahoo.com.au>
In-Reply-To: <200902192254.31735.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, Arjan van de Ven <arjan@linux.intel.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> On Wednesday 18 February 2009 08:57:56 Jeremy Fitzhardinge wrote:
>   
>> Nick Piggin wrote:
>>     
>>> I have patches to move the tlb flushing to an asynchronous process
>>> context... but all tweaks to that (including flushing at vmap) are just
>>> variations on the existing flushing scheme and don't solve your problem,
>>> so I don't think we really need to change that for the moment (my patches
>>> are mainly for latency improvement and to allow vunmap to be usable from
>>> interrupt context).
>>>       
>> Hi Nick,
>>
>> I'm very interested in being able to call vm_unmap_aliases() from
>> interrupt context.  Does the work you mention here encompass that?
>>     
>
> No, and it can't because we can't do the global kernel tlb flush
> from interrupt context.
>
> There is basically no point in doing the vm_unmap_aliases from
> interrupt context without doing the global TLB flush as well,
> because you still cannot reuse the virtual memory, you still have
> possible aliases to it, and you still need to schedule a TLB flush
> at some point anyway.
>   

But that's only an issue when you actually do want to reuse the virtual 
address space.  Couldn't you set a flag saying "tlb flush needed", so 
when cpu X is about to use some of that address space, it flushes 
first?  Avoids the need for synchronous cross-cpu tlb flushes.  It 
assumes they're not currently using that address space, but I think that 
would indicate a bug anyway.

(Xen does something like this internally to either defer or avoid many 
expensive tlb operations.)

>> For Xen dom0, when someone does something like dma_alloc_coherent, we
>> allocate the memory as normal, and then swizzle the underlying physical
>> pages to be machine physically contiguous (vs contiguous pseudo-physical
>> guest memory), and within the addressable range for the device.  In
>> order to do that, we need to make sure the pages are only mapped by the
>> linear mapping, and there are no other aliases.
>>     
>
> These are just stale aliases that will no longer be operated on
> unless there is a kernel bug -- so can you just live with them,
> or is it a security issue of memory access escaping its domain?
>   

The underlying physical page is being exchanged, so the old page is 
being returned to Xen's free page pool.  It will refuse to do the 
exchange if the guest still has pagetable references to the page.


>> And since drivers are free to allocate dma memory at interrupt time,
>> this needs to happen at interrupt time too.
>>
>> (The tlb flush issue that started this read should be a non-issue for
>> Xen, at least, because all cross-cpu tlb flushes should happen via  a
>> hypercall rather than kernel-initiated IPIs, so there's no possibility
>> of deadlock.  Though I'll happily admit that taking advantage of the
>> implementation properties of a particular implementation is not very
>> pretty...)
>>     
>
> If it is really no other way around it, it would be possible to
> allow arch code to take advantage of this if it knows its TLB
> flush is interrupt safe.
>   

It's almost safe.  I've got this patch in my tree to tie up the 
flush_tlb_all loose end, though I won't claim its pretty.
