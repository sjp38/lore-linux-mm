Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7CD2F6B003D
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 14:11:37 -0500 (EST)
Message-ID: <499DAEE4.8010507@goop.org>
Date: Thu, 19 Feb 2009 11:11:32 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] vm_unmap_aliases: allow callers to inhibit TLB flush
References: <49416494.6040009@goop.org> <200902192254.31735.nickpiggin@yahoo.com.au> <499D90AE.7060102@goop.org> <200902200441.08541.nickpiggin@yahoo.com.au>
In-Reply-To: <200902200441.08541.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, Arjan van de Ven <arjan@linux.intel.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Then what is the point of the vm_unmap_aliases? If you are doing it
> for security it won't work because other CPUs might still be able
> to write through dangling TLBs. If you are not doing it for
> security then it does not need to be done at all.
>   

Xen will make sure any danging tlb entries are flushed before handing 
the page out to anyone else.

> Unless it is something strange that Xen does with the page table
> structure and you just need to get rid of those?
>   

Yeah.  A pte pointing at a page holds a reference on it, saying that it 
belongs to the domain.  You can't return it to Xen until the refcount is 0.

>> (Xen does something like this internally to either defer or avoid many
>> expensive tlb operations.)
>>
>>     
>>>> For Xen dom0, when someone does something like dma_alloc_coherent, we
>>>> allocate the memory as normal, and then swizzle the underlying physical
>>>> pages to be machine physically contiguous (vs contiguous pseudo-physical
>>>> guest memory), and within the addressable range for the device.  In
>>>> order to do that, we need to make sure the pages are only mapped by the
>>>> linear mapping, and there are no other aliases.
>>>>         
>>> These are just stale aliases that will no longer be operated on
>>> unless there is a kernel bug -- so can you just live with them,
>>> or is it a security issue of memory access escaping its domain?
>>>       
>> The underlying physical page is being exchanged, so the old page is
>> being returned to Xen's free page pool.  It will refuse to do the
>> exchange if the guest still has pagetable references to the page.
>>     
>
> But it refuses to do this because it is worried about dangling TLBs?
> Or some implementation detail that can't handle the page table
> entries?
>   

Right.  The actual pte pointing at the page hold the reference.  We need 
to drop all the references before doing the exchange.

> Hmm. Let's just try to establish that it is really required first.
>   

Well, its desireable anyway.  The using IPI for any kind of tlb flushing 
is pretty pessimal under Xen (or any virtual environment); Xen has a 
much better idea about which real cpus have stale tlb state for which vcpus.

> Or... what if we just allow a compile and/or boot time flag to direct
> that it does not want lazy vmap unmapping and it will just revert to
> synchronous unmapping? If Xen needs lots of flushing anyway it might
> not be a win anyway.
>   

That may be worth considering.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
