Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 11EF66B0047
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 17:13:52 -0400 (EDT)
Message-ID: <49C16411.2040705@redhat.com>
Date: Wed, 18 Mar 2009 23:13:53 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Question about x86/mm/gup.c's use of disabled interrupts
References: <49C148AF.5050601@goop.org>
In-Reply-To: <49C148AF.5050601@goop.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Xen-devel <xen-devel@lists.xensource.com>, Jan Beulich <jbeulich@novell.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Jeremy Fitzhardinge wrote:
> Hi Nick,
>
> The comment in arch/x86/mm/gup.c:gup_get_pte() says:
>
>     [...] What
>      * we do have is the guarantee that a pte will only either go from 
> not
>      * present to present, or present to not present or both -- it 
> will not
>      * switch to a completely different present page without a TLB 
> flush in
>      * between; something that we are blocking by holding interrupts off.
>
>
> Disabling the interrupt will prevent the tlb flush IPI from coming in 
> and flushing this cpu's tlb, but I don't see how it will prevent some 
> other cpu from actually updating the pte in the pagetable, which is 
> what we're concerned about here.  

The thread that cleared the pte holds the pte lock and is now waiting 
for the IPI.  The thread that wants to update the pte will wait for the 
pte lock, thus also waits on the IPI and gup_fast()'s 
local_irq_enable().  I think.

> Is this the only reason to disable interrupts?  

Another comment says it also prevents pagetable teardown.

> Also, assuming that disabling the interrupt is enough to get the 
> guarantees we need here, there's a Xen problem because we don't use 
> IPIs for cross-cpu tlb flushes (well, it happens within Xen).  I'll 
> have to think a bit about how to deal with that, but I'm thinking that 
> we could add a per-cpu "tlb flushes blocked" flag, and maintain some 
> kind of per-cpu deferred tlb flush count so we can get around to doing 
> the flush eventually.

I was thinking about adding a hypercall for cross-vcpu tlb flushes.  
Guess I'll wait for you to clear up all the issues first.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
