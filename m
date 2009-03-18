Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 62D416B003D
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 17:40:04 -0400 (EDT)
Message-ID: <49C16A48.4090303@redhat.com>
Date: Wed, 18 Mar 2009 23:40:24 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Question about x86/mm/gup.c's use of disabled interrupts
References: <49C148AF.5050601@goop.org> <49C16411.2040705@redhat.com> <49C1665A.4080707@goop.org>
In-Reply-To: <49C1665A.4080707@goop.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Xen-devel <xen-devel@lists.xensource.com>, Jan Beulich <jbeulich@novell.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Jeremy Fitzhardinge wrote:
>>> Disabling the interrupt will prevent the tlb flush IPI from coming 
>>> in and flushing this cpu's tlb, but I don't see how it will prevent 
>>> some other cpu from actually updating the pte in the pagetable, 
>>> which is what we're concerned about here.  
>>
>> The thread that cleared the pte holds the pte lock and is now waiting 
>> for the IPI.  The thread that wants to update the pte will wait for 
>> the pte lock, thus also waits on the IPI and gup_fast()'s 
>> local_irq_enable().  I think.
>
> But hasn't it already done the pte update at that point?
>
> (I think this conversation really is moot because the kernel never 
> does P->P pte updates any more; its always P->N->P.)

I thought you were concerned about cpu 0 doing a gup_fast(), cpu 1 doing 
P->N, and cpu 2 doing N->P.  In this case cpu 2 is waiting on the pte lock.

>>> Is this the only reason to disable interrupts?  
>>
>> Another comment says it also prevents pagetable teardown.
>
> We could take a reference to the mm to get the same effect, no?
>

Won't stop munmap().

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
