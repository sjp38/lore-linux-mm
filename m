Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9835F6B003D
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 13:32:15 -0400 (EDT)
Message-ID: <49C2818B.9060201@goop.org>
Date: Thu, 19 Mar 2009 10:31:55 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: Question about x86/mm/gup.c's use of disabled interrupts
References: <49C148AF.5050601@goop.org> <200903191232.05459.nickpiggin@yahoo.com.au>
In-Reply-To: <200903191232.05459.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Avi Kivity <avi@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Xen-devel <xen-devel@lists.xensource.com>, Jan Beulich <jbeulich@novell.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
>> Also, assuming that disabling the interrupt is enough to get the
>> guarantees we need here, there's a Xen problem because we don't use IPIs
>> for cross-cpu tlb flushes (well, it happens within Xen).  I'll have to
>> think a bit about how to deal with that, but I'm thinking that we could
>> add a per-cpu "tlb flushes blocked" flag, and maintain some kind of
>> per-cpu deferred tlb flush count so we can get around to doing the flush
>> eventually.
>>
>> But I want to make sure I understand the exact algorithm here.
>>     
>
> FWIW, powerpc actually can flush tlbs without IPIs, and it also has
> a gup_fast. powerpc RCU frees its page _tables_ so we can walk them,
> and then I use speculative page references in order to be able to
> take a reference on the page without having it pinned.
>   

Ah, interesting.  So disabling interrupts prevents the RCU free from 
happening, and non-atomic pte fetching is a non-issue.  So it doesn't 
address the PAE side of the problem.

> Turning gup_get_pte into a pvop would be a bit nasty because on !PAE
> it is just a single load, and even on PAE it is pretty cheap.
>   

Well, it wouldn't be too bad; for !PAE it would turn into something we 
could inline, so there'd be little to no cost.  For PAE it would be out 
of line, but a direct function call, which would be nicely cached and 
very predictable once we've gone through the the loop once (and for Xen 
I think I'd just make it a cmpxchg8b-based implementation, assuming that 
the tlb flush hypercall would offset the cost of making gup_fast a bit 
slower).

But it would be better if we can address it at a higher level.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
