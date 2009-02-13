Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EA9EE6B003D
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 12:41:59 -0500 (EST)
Message-ID: <4995B0E3.3050201@goop.org>
Date: Fri, 13 Feb 2009 09:41:55 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: disable preemption in apply_to_pte_range
References: <4994BCF0.30005@goop.org>	 <200902140030.59027.nickpiggin@yahoo.com.au>	 <1234534611.6519.109.camel@twins>	 <200902140130.31985.nickpiggin@yahoo.com.au> <1234535938.6519.118.camel@twins>
In-Reply-To: <1234535938.6519.118.camel@twins>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> If the lazy mmu code relies on per-cpu data, then it should be the lazy
> mmu's responsibility to ensure stuff is properly serialized. Eg. it
> should do get_cpu_var() and put_cpu_var().
>
> Those constructs can usually be converted to preemptable variants quite
> easily, as it clearly shows what data needs to be protected.
>   

At the moment the lazy update stuff is inherently cpu-affine.  The basic 
model is that you can amortize the cost of individual update operations 
(via hypercall, for example) by batching them up.  That batch is almost 
certainly a piece of percpu state (in Xen's case its maintained on the 
kernel side as per-cpu data, but in VMI it happens somewhere under their 
ABI), and so we can't allow switching to another cpu while lazy update 
mode is active.

Preemption is also problematic because if we're doing lazy updates and 
we switch to another task, it will likely get very confused if its 
pagetable updates get deferred until some arbitrary point in the future...

So at the moment, we just disable preemption, and take advantage of the 
existing work to make sure pagetable updates are not non-preemptible for 
too long.  This has been fine so far, because almost all the work on 
using lazy mmu updates has focused on usermode mappings.

But I can see how this is problematic from your perspective.  One thing 
we could consider is making the lazy mmu mode a per-task property, so if 
we get preempted we can flush any pending changes and safely switch to 
another task, and then reenable it when we get scheduled in again.  
(This may be already possible with the existing paravirt-ops hooks in 
switch_to.)

In this specific case, if the lazy mmu updates / non-preemptable section 
is really causing heartburn, we can just back it out for now.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
