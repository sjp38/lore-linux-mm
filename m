Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 926726B003D
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 18:14:15 -0400 (EDT)
Message-ID: <49C17230.20109@goop.org>
Date: Wed, 18 Mar 2009 15:14:08 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: Question about x86/mm/gup.c's use of disabled interrupts
References: <49C148AF.5050601@goop.org> <49C16411.2040705@redhat.com> <49C1665A.4080707@goop.org> <49C16A48.4090303@redhat.com>
In-Reply-To: <49C16A48.4090303@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Xen-devel <xen-devel@lists.xensource.com>, Jan Beulich <jbeulich@novell.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Avi Kivity wrote:
> Jeremy Fitzhardinge wrote:
>>>> Disabling the interrupt will prevent the tlb flush IPI from coming 
>>>> in and flushing this cpu's tlb, but I don't see how it will prevent 
>>>> some other cpu from actually updating the pte in the pagetable, 
>>>> which is what we're concerned about here.  
>>>
>>> The thread that cleared the pte holds the pte lock and is now 
>>> waiting for the IPI.  The thread that wants to update the pte will 
>>> wait for the pte lock, thus also waits on the IPI and gup_fast()'s 
>>> local_irq_enable().  I think.
>>
>> But hasn't it already done the pte update at that point?
>>
>> (I think this conversation really is moot because the kernel never 
>> does P->P pte updates any more; its always P->N->P.)
>
> I thought you were concerned about cpu 0 doing a gup_fast(), cpu 1 
> doing P->N, and cpu 2 doing N->P.  In this case cpu 2 is waiting on 
> the pte lock.

The issue is that if cpu 0 is doing a gup_fast() and other cpus are 
doing P->P updates, then gup_fast() can potentially get a mix of old and 
new pte values - where P->P is any aggregate set of unsynchronized P->N 
and N->P operations on any number of other cpus.  Ah, but if every P->N 
is followed by a tlb flush, then disabling interrupts will hold off any 
following N->P, allowing gup_fast to get a consistent pte snapshot.

Hm, awkward if flush_tlb_others doesn't IPI...

> Won't stop munmap().

And I guess it does the tlb flush before freeing the pages, so disabling 
the interrupt helps here too.

Simplest fix is to make gup_get_pte() a pvop, but that does seem like 
putting a red flag in front of an inner-loop hotspot, or something...

The per-cpu tlb-flush exclusion flag might really be the way to go.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
