Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EBEDE6B004D
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 01:47:51 -0400 (EDT)
Subject: Re: tlb_gather_mmu() and semantics of "fullmm"
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20090326.224433.150749170.davem@davemloft.net>
References: <1238106824.16498.7.camel@pasglop>
	 <20090326.220409.72126250.davem@davemloft.net>
	 <1238132287.20197.47.camel@pasglop>
	 <20090326.224433.150749170.davem@davemloft.net>
Content-Type: text/plain
Date: Fri, 27 Mar 2009 16:54:27 +1100
Message-Id: <1238133267.20197.56.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Miller <davem@davemloft.net>
Cc: hugh@veritas.com, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, npiggin@suse.de, zach@vmware.com, jeremy@goop.org
List-ID: <linux-mm.kvack.org>

On Thu, 2009-03-26 at 22:44 -0700, David Miller wrote:
> From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Date: Fri, 27 Mar 2009 16:38:07 +1100
> 
> > If you look at context_switch() in kernel/sched.c, it increments
> > mm_count when using the pevious guy's mm as the "active_mm" of a kernel
> > thread, not mm_user.
> 
> Yawn...

Yeah it's late over there :-)

> We unconditionally check if the CPU is set in the mask, even
> when the mm isn't changing.

Ok, so you do lazy flushing at context switch time, which is nice,
but I'm still wondering if the code you showed is right. Feel free
to reply tomorrow after a good night of sleep though :-)

The scenario I have in mind is as follow:

CPU 0 is running the context, task->mm == task->active_mm == your
context. The CPU is in userspace happily churning things.

CPU 1 used to run it, not anymore, it's now running fancyfsd which
is a kernel thread, but current->active_mm still points to that
same context.

Because there's only one "real" user, mm_users is 1 (but mm_count is
elevated, it's just that the presence on CPU 1 as active_mm has no
effect on mm_count().

At this point, fancyfsd decides to invalidate a mapping currently mapped
by that context, for example because a networked file has changed
remotely or something like that, using unmap_mapping_ranges().

So CPU 1 goes into the zapping code, which eventually ends up calling
flush_tlb_pending(). Your test will succeed, as current->active_mm is
indeed the target mm for the flush, and mm_users is indeed 1. So you
will -not- send an IPI to the other CPU, and CPU 0 will continue happily
accessing the pages that should have been unmapped.

Or did I miss something ?

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
