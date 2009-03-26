Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 275106B003D
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 23:17:00 -0400 (EDT)
Subject: Re: tlb_gather_mmu() and semantics of "fullmm"
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.64.0903261232060.27412@blonde.anvils>
References: <1238043674.25062.823.camel@pasglop>
	 <Pine.LNX.4.64.0903261232060.27412@blonde.anvils>
Content-Type: text/plain
Date: Fri, 27 Mar 2009 09:33:44 +1100
Message-Id: <1238106824.16498.7.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, "David S. Miller" <davem@davemloft.net>, Zach Amsden <zach@vmware.com>, Jeremy Fitzhardinge <jeremy@goop.org>
List-ID: <linux-mm.kvack.org>


> No remaining user in the sense of no longer connected to any user task,
> but may still be active_mm on some cpus.

Right, I see, an Linus point about speculative TLB activity stands here,
though I suspect that is a non issue on SW loaded TLB processors for
example... 

I wonder how often we are in this situation and whether we could
optimize for the case when fullmm && mm_count == 1...
 
> I'd be surprised if there are still such optimizations to be made:
> maybe a whole different strategy could be more efficient, but I'd be
> surprised if there's really a superfluous TLB flush to be tweaked away.
> 
> Although it looks as if there's a TLB flush at the end of every batch,
> isn't that deceptive (on x86 anyway)?  I'm thinking that the first
> flush_tlb_mm() will end up calling leave_mm(), and the subsequent
> ones do nothing because the cpu_vm_mask is then empty.

Ok, well, that's a bit different on other archs like powerpc where we virtually
never remove bits from cpu_vm_mask... (though we probably could... to be looked
at).

> Hmm, but the cpu which is actually doing the flush_tlb_mm() calls
> leave_mm() without considering cpu_vm_mask: won't we get repeated
> unnecessary load_cr3(swapper_pg_dir)s from that?

That's x86 voodoo that I'll leave to you guys :-)

> It's tempting to think that even that one TLB flush is one too many,
> given that the next user task to run on any cpu will have to load %cr3
> for its own address space.

But we can't free the pages until we have flushed the TLB.

> But I think that leaves a danger from speculative TLB loads by kernel
> threads, after the pagetables of the original mm have got freed and
> reused for something else: I think they would at least need to remain
> good pagetables until the last cpu's TLB has been flushed.

Page tables being good is a separate problem. Pages themselves can't be
freed while a TLB potentially points to them, we agree on that.

> I suspect so, but please don't take my word for it: you've
> probably put more thought into asking than I have in answering.

Well, I'm thinking there may be ways to improve things a little bit but
that's no big deal right now.

Mostly the deal with SW loaded TLBs is that once it's been flushed once,
there should be no speculative access to worry about anymore and we can
switch the batch to 'fast mode' if fullmm is set, because those CPUs (at
least the ones I'm working with) can't take TLB miss interrupts as a
result of a speculative access.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
