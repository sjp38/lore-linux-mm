Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A6FB76B004D
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 01:50:05 -0400 (EDT)
Date: Thu, 26 Mar 2009 22:57:44 -0700 (PDT)
Message-Id: <20090326.225744.250374539.davem@davemloft.net>
Subject: Re: tlb_gather_mmu() and semantics of "fullmm"
From: David Miller <davem@davemloft.net>
In-Reply-To: <1238133267.20197.56.camel@pasglop>
References: <1238132287.20197.47.camel@pasglop>
	<20090326.224433.150749170.davem@davemloft.net>
	<1238133267.20197.56.camel@pasglop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: benh@kernel.crashing.org
Cc: hugh@veritas.com, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, npiggin@suse.de, zach@vmware.com, jeremy@goop.org
List-ID: <linux-mm.kvack.org>

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 27 Mar 2009 16:54:27 +1100

> CPU 0 is running the context, task->mm == task->active_mm == your
> context. The CPU is in userspace happily churning things.
> 
> CPU 1 used to run it, not anymore, it's now running fancyfsd which
> is a kernel thread, but current->active_mm still points to that
> same context.
> 
> Because there's only one "real" user, mm_users is 1 (but mm_count is
> elevated, it's just that the presence on CPU 1 as active_mm has no
> effect on mm_count().
> 
> At this point, fancyfsd decides to invalidate a mapping currently mapped
> by that context, for example because a networked file has changed
> remotely or something like that, using unmap_mapping_ranges().
> 
> So CPU 1 goes into the zapping code, which eventually ends up calling
> flush_tlb_pending(). Your test will succeed, as current->active_mm is
> indeed the target mm for the flush, and mm_users is indeed 1. So you
> will -not- send an IPI to the other CPU, and CPU 0 will continue happily
> accessing the pages that should have been unmapped.
> 
> Or did I miss something ?

Good point.

Maybe it would work out correctly if I used current->mm?

Because if I tested it that way, only something really executing
in userland could force the cpumask bit clears.

Any kernel thread would flush the TLB if and when it switched
back into a real task using that mm.

Sound good?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
