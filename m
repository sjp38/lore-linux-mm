Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9CCBF6B003D
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 09:11:02 -0400 (EDT)
Date: Thu, 26 Mar 2009 14:08:17 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: tlb_gather_mmu() and semantics of "fullmm"
In-Reply-To: <1238043674.25062.823.camel@pasglop>
Message-ID: <Pine.LNX.4.64.0903261232060.27412@blonde.anvils>
References: <1238043674.25062.823.camel@pasglop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, "David S. Miller" <davem@davemloft.net>, Zach Amsden <zach@vmware.com>, Jeremy Fitzhardinge <jeremy@goop.org>
List-ID: <linux-mm.kvack.org>

On Thu, 26 Mar 2009, Benjamin Herrenschmidt wrote:
> 
> I'd like to clarify something about the semantics of the "full_mm_flush"
> argument of tlb_gather_mmu().
> 
> The reason is that it can either mean:
> 
>  - All the mappings for that mm are being flushed
> 
> or
> 
>  - The above +plus+ the mm is dead and has no remaining user. IE, we
> can relax some of the rules because we know the mappings cannot be
> accessed concurrently, and thus the PTEs cannot be reloaded into the
> TLB.

No remaining user in the sense of no longer connected to any user task,
but may still be active_mm on some cpus.

> 
> If it means the later (which it does in practice today, since we only
> call it from exit_mmap(), unless I missed an important detail), then I
> could implement some optimisations in my own arch code, but more

Yes, I'm pretty sure you can assume the latter.  The whole point
of the "full mm" stuff (would have better been named "exit mm") is
to allow optimizations, and I don't see what optimization there is to
be made from knowing you're going the whole length of the mm; whereas
optimizations can be made if you know nothing can happen in parallel.

Cc'ed DaveM who introduced it for sparc64, and Zach and Jeremy
who have delved there, in case they wish to disagree.

> importantly, I believe we might also be able to optimize the generic
> (and x86) code to avoid flushing the TLB when the batch of pages fills
> up, before freeing the pages.

I'd be surprised if there are still such optimizations to be made:
maybe a whole different strategy could be more efficient, but I'd be
surprised if there's really a superfluous TLB flush to be tweaked away.

Although it looks as if there's a TLB flush at the end of every batch,
isn't that deceptive (on x86 anyway)?  I'm thinking that the first
flush_tlb_mm() will end up calling leave_mm(), and the subsequent
ones do nothing because the cpu_vm_mask is then empty.

Hmm, but the cpu which is actually doing the flush_tlb_mm() calls
leave_mm() without considering cpu_vm_mask: won't we get repeated
unnecessary load_cr3(swapper_pg_dir)s from that?

> 
> That would have the side effect of speeding up exit of large processes
> by limiting the number of tlb flushes they do. Since the TLB would need
> to be flushed only once at the end for archs that may carry more than
> one context in their TLB, and possibly not at all on x86 since it
> doesn't and the context isn't active any more.

It's tempting to think that even that one TLB flush is one too many,
given that the next user task to run on any cpu will have to load %cr3
for its own address space.

But I think that leaves a danger from speculative TLB loads by kernel
threads, after the pagetables of the original mm have got freed and
reused for something else: I think they would at least need to remain
good pagetables until the last cpu's TLB has been flushed.

> 
> Or am I missing something ?

I suspect so, but please don't take my word for it: you've
probably put more thought into asking than I have in answering.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
