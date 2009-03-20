Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7E0896B003D
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 01:07:36 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e9.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n2K4wZOt008522
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 00:58:35 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2K57Y6Q151364
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 01:07:34 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2K52BLv001889
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 01:07:34 -0400
Date: Thu, 19 Mar 2009 21:40:29 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Question about x86/mm/gup.c's use of disabled interrupts
Message-ID: <20090320044029.GD6807@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <49C148AF.5050601@goop.org> <200903191232.05459.nickpiggin@yahoo.com.au> <49C2818B.9060201@goop.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49C2818B.9060201@goop.org>
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Avi Kivity <avi@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Xen-devel <xen-devel@lists.xensource.com>, Jan Beulich <jbeulich@novell.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 19, 2009 at 10:31:55AM -0700, Jeremy Fitzhardinge wrote:
> Nick Piggin wrote:
>>> Also, assuming that disabling the interrupt is enough to get the
>>> guarantees we need here, there's a Xen problem because we don't use IPIs
>>> for cross-cpu tlb flushes (well, it happens within Xen).  I'll have to
>>> think a bit about how to deal with that, but I'm thinking that we could
>>> add a per-cpu "tlb flushes blocked" flag, and maintain some kind of
>>> per-cpu deferred tlb flush count so we can get around to doing the flush
>>> eventually.
>>>
>>> But I want to make sure I understand the exact algorithm here.
>>
>> FWIW, powerpc actually can flush tlbs without IPIs, and it also has
>> a gup_fast. powerpc RCU frees its page _tables_ so we can walk them,
>> and then I use speculative page references in order to be able to
>> take a reference on the page without having it pinned.
>
> Ah, interesting.  So disabling interrupts prevents the RCU free from 
> happening, and non-atomic pte fetching is a non-issue.  So it doesn't 
> address the PAE side of the problem.

This would be rcu_sched, correct?

							Thanx, Paul

>> Turning gup_get_pte into a pvop would be a bit nasty because on !PAE
>> it is just a single load, and even on PAE it is pretty cheap.
>>   
>
> Well, it wouldn't be too bad; for !PAE it would turn into something we 
> could inline, so there'd be little to no cost.  For PAE it would be out of 
> line, but a direct function call, which would be nicely cached and very 
> predictable once we've gone through the the loop once (and for Xen I think 
> I'd just make it a cmpxchg8b-based implementation, assuming that the tlb 
> flush hypercall would offset the cost of making gup_fast a bit slower).
>
> But it would be better if we can address it at a higher level.
>
>    J
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
