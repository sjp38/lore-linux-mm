Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 79C866B0055
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 02:30:21 -0500 (EST)
Message-ID: <49A25086.30606@goop.org>
Date: Sun, 22 Feb 2009 23:30:14 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] vm_unmap_aliases: allow callers to inhibit TLB flush
References: <49416494.6040009@goop.org> <200902200441.08541.nickpiggin@yahoo.com.au> <499DAEE4.8010507@goop.org> <200902231514.01965.nickpiggin@yahoo.com.au>
In-Reply-To: <200902231514.01965.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, Arjan van de Ven <arjan@linux.intel.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> On Friday 20 February 2009 06:11:32 Jeremy Fitzhardinge wrote:
>   
>> Nick Piggin wrote:
>>     
>>> Then what is the point of the vm_unmap_aliases? If you are doing it
>>> for security it won't work because other CPUs might still be able
>>> to write through dangling TLBs. If you are not doing it for
>>> security then it does not need to be done at all.
>>>       
>> Xen will make sure any danging tlb entries are flushed before handing
>> the page out to anyone else.
>>
>>     
>>> Unless it is something strange that Xen does with the page table
>>> structure and you just need to get rid of those?
>>>       
>> Yeah.  A pte pointing at a page holds a reference on it, saying that it
>> belongs to the domain.  You can't return it to Xen until the refcount is 0.
>>     
>
> OK. Then I will remember to find some time to get the interrupt
> safe patches working. I wonder why you can't just return it to
> Xen when (or have Xen hold it somewhere until) the refcount
> reaches 0?
>   

It would still need to allocate a page in the meantime, which could fail 
because the domain has hit its hard memory limit (which will be the 
common case, because a domain generally starts with its full compliment 
of memory).   The nice thing about the exchange is that there's no 
accounting to take into account.

>>> Or... what if we just allow a compile and/or boot time flag to direct
>>> that it does not want lazy vmap unmapping and it will just revert to
>>> synchronous unmapping? If Xen needs lots of flushing anyway it might
>>> not be a win anyway.
>>>       
>> That may be worth considering.
>>     
>
> ... in the meantime, shall we just do this for Xen? It is probably
> safer and may end up with no worse performance on Xen anyway. If
> we get more vmap users and it becomes important, you could look at
> more sophisticated ways of doing this. Eg. a page could be flagged
> if it potentially has lazy vmaps.
>   

OK.  Do you want to do the patch, or shall I?

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
