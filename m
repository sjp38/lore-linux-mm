Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E483F6B003D
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 18:41:04 -0400 (EDT)
Message-ID: <49C17880.7080109@redhat.com>
Date: Thu, 19 Mar 2009 00:41:04 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Question about x86/mm/gup.c's use of disabled interrupts
References: <49C148AF.5050601@goop.org> <49C16411.2040705@redhat.com> <49C1665A.4080707@goop.org> <49C16A48.4090303@redhat.com> <49C17230.20109@goop.org>
In-Reply-To: <49C17230.20109@goop.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Xen-devel <xen-devel@lists.xensource.com>, Jan Beulich <jbeulich@novell.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Jeremy Fitzhardinge wrote:
>> I thought you were concerned about cpu 0 doing a gup_fast(), cpu 1 
>> doing P->N, and cpu 2 doing N->P.  In this case cpu 2 is waiting on 
>> the pte lock.
>
> The issue is that if cpu 0 is doing a gup_fast() and other cpus are 
> doing P->P updates, then gup_fast() can potentially get a mix of old 
> and new pte values - where P->P is any aggregate set of unsynchronized 
> P->N and N->P operations on any number of other cpus.  Ah, but if 
> every P->N is followed by a tlb flush, then disabling interrupts will 
> hold off any following N->P, allowing gup_fast to get a consistent pte 
> snapshot.
>

Right.

> Hm, awkward if flush_tlb_others doesn't IPI...
>

How can it avoid flushing the tlb on cpu [01]?  It's it's gup_fast()ing 
a pte, it may as well load it into the tlb.

>
> Simplest fix is to make gup_get_pte() a pvop, but that does seem like 
> putting a red flag in front of an inner-loop hotspot, or something...
>
> The per-cpu tlb-flush exclusion flag might really be the way to go.

I don't see how it will work, without changing Xen to look at the flag?

local_irq_disable() is used here to lock out a remote cpu, I don't see 
why deferring the flush helps.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
