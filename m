Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 96A056B003D
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 17:23:45 -0400 (EDT)
Message-ID: <49C1665A.4080707@goop.org>
Date: Wed, 18 Mar 2009 14:23:38 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: Question about x86/mm/gup.c's use of disabled interrupts
References: <49C148AF.5050601@goop.org> <49C16411.2040705@redhat.com>
In-Reply-To: <49C16411.2040705@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Xen-devel <xen-devel@lists.xensource.com>, Jan Beulich <jbeulich@novell.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Avi Kivity wrote:
> Jeremy Fitzhardinge wrote:
>> Disabling the interrupt will prevent the tlb flush IPI from coming in 
>> and flushing this cpu's tlb, but I don't see how it will prevent some 
>> other cpu from actually updating the pte in the pagetable, which is 
>> what we're concerned about here.  
>
> The thread that cleared the pte holds the pte lock and is now waiting 
> for the IPI.  The thread that wants to update the pte will wait for 
> the pte lock, thus also waits on the IPI and gup_fast()'s 
> local_irq_enable().  I think.

But hasn't it already done the pte update at that point?

(I think this conversation really is moot because the kernel never does 
P->P pte updates any more; its always P->N->P.)

>> Is this the only reason to disable interrupts?  
>
> Another comment says it also prevents pagetable teardown.

We could take a reference to the mm to get the same effect, no?

>> Also, assuming that disabling the interrupt is enough to get the 
>> guarantees we need here, there's a Xen problem because we don't use 
>> IPIs for cross-cpu tlb flushes (well, it happens within Xen).  I'll 
>> have to think a bit about how to deal with that, but I'm thinking 
>> that we could add a per-cpu "tlb flushes blocked" flag, and maintain 
>> some kind of per-cpu deferred tlb flush count so we can get around to 
>> doing the flush eventually.
>
> I was thinking about adding a hypercall for cross-vcpu tlb flushes.  
> Guess I'll wait for you to clear up all the issues first.

Typical...

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
