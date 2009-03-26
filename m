Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3922D6B003D
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 12:22:17 -0400 (EDT)
Message-ID: <49CBB989.2030608@goop.org>
Date: Thu, 26 Mar 2009 10:21:13 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: tlb_gather_mmu() and semantics of "fullmm"
References: <1238043674.25062.823.camel@pasglop> <Pine.LNX.4.64.0903261232060.27412@blonde.anvils>
In-Reply-To: <Pine.LNX.4.64.0903261232060.27412@blonde.anvils>
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, "David S. Miller" <davem@davemloft.net>, Zach Amsden <zach@vmware.com>, Alok Kataria <akataria@vmware.com>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Thu, 26 Mar 2009, Benjamin Herrenschmidt wrote:
>   
>> I'd like to clarify something about the semantics of the "full_mm_flush"
>> argument of tlb_gather_mmu().
>>
>> The reason is that it can either mean:
>>
>>  - All the mappings for that mm are being flushed
>>
>> or
>>
>>  - The above +plus+ the mm is dead and has no remaining user. IE, we
>> can relax some of the rules because we know the mappings cannot be
>> accessed concurrently, and thus the PTEs cannot be reloaded into the
>> TLB.
>>     
>
> No remaining user in the sense of no longer connected to any user task,
> but may still be active_mm on some cpus.
>   

Right.

>> If it means the later (which it does in practice today, since we only
>> call it from exit_mmap(), unless I missed an important detail), then I
>> could implement some optimisations in my own arch code, but more
>>     
>
> Yes, I'm pretty sure you can assume the latter.  The whole point
> of the "full mm" stuff (would have better been named "exit mm") is
> to allow optimizations, and I don't see what optimization there is to
> be made from knowing you're going the whole length of the mm; whereas
> optimizations can be made if you know nothing can happen in parallel.
>
> Cc'ed DaveM who introduced it for sparc64, and Zach and Jeremy
> who have delved there, in case they wish to disagree.
>   

Yes. The specific optimisation is that we don't need to worry about 
racing with anyone when fetching the A/D bits, so we can avoid using 
expensive atomic instructions.

>> importantly, I believe we might also be able to optimize the generic
>> (and x86) code to avoid flushing the TLB when the batch of pages fills
>> up, before freeing the pages.
>>     
>
> I'd be surprised if there are still such optimizations to be made:
> maybe a whole different strategy could be more efficient, but I'd be
> surprised if there's really a superfluous TLB flush to be tweaked away.
>   

Perhaps, but I think in some cases we're over-eager with tlb flushes. 
Often the thing we want to achieve is "we need a tlb flush before this 
vaddr is remapped", not "we need a tlb flush now"; any other incidental 
tlb flush would be enough to get the desired outcome. This may not be an 
issue for process-related flushes, but I'm thinking about things like vmap.

> Although it looks as if there's a TLB flush at the end of every batch,
> isn't that deceptive (on x86 anyway)?  I'm thinking that the first
> flush_tlb_mm() will end up calling leave_mm(), and the subsequent
> ones do nothing because the cpu_vm_mask is then empty.
>   

x86 tends to flush either single pages or everything, though the CPA 
code has its own tlb flush machinery to allow batched cross-cpu range 
flushing. Given that, there doesn't seem to be a lot for the tlb 
gathering machinery to do (especially not on process destruction).

> Hmm, but the cpu which is actually doing the flush_tlb_mm() calls
> leave_mm() without considering cpu_vm_mask: won't we get repeated
> unnecessary load_cr3(swapper_pg_dir)s from that?
>   
Yes, though it would mean clearing the current cpu from cpu_vm_mask, 
even though the mm is currently active. It would mean that we would be 
strictly defining the cpu_vm_mask to mean "cpus which may have stale 
usermode tlb entries". But even then, could we guarantee that the 
current cpu won't pick up stray entries due to speculation, etc? Still, 
repeatedly stomping the current cpu's tlb does seem like overkill...

For x86, at least, it would seem that the best strategy is to switch to 
init_mm before doing anything (including other cpus which may be lazily 
still pointing at the mm), then just tear the whole thing down without 
any subsequent flushing at all. The cost of doing a one-off the 
cross-cpu mm switch is going to be about the same as a single cross-cpu 
tlb flush, and certainly much better than repeated ones.

Also, why do we bother with zeroing out all the ptes if we're just about 
to free the pages anyway? zap_pte_range seems to do too much work for 
the "full_mm" case.


>> That would have the side effect of speeding up exit of large processes
>> by limiting the number of tlb flushes they do. Since the TLB would need
>> to be flushed only once at the end for archs that may carry more than
>> one context in their TLB, and possibly not at all on x86 since it
>> doesn't and the context isn't active any more.
>>     
>
> It's tempting to think that even that one TLB flush is one too many,
> given that the next user task to run on any cpu will have to load %cr3
> for its own address space.
>
> But I think that leaves a danger from speculative TLB loads by kernel
> threads, after the pagetables of the original mm have got freed and
> reused for something else: I think they would at least need to remain
> good pagetables until the last cpu's TLB has been flushed.
>   

Yes, I think the kernel goes to a fair amount of effort to make sure 
that the tlb is flushed before freeing pages, though I can't remember 
why (I seem to remember the Intel people doing the work, and it was some 
kind of architectural issue). I remember it was one of the problems with 
the old quicklist-based pagetable allocation.

And as I discovered last week, the x86 get_user_pages_fast() makes use 
of the tlb flush in a rather obscure way. When it is rampaging around in 
some process's pagetable, it disables interrupts so that if some other 
CPU starts freeing the pagetable it gets caught up waiting for the IPI 
to be handled (which causes us some heartburn because our cross-cpu tlb 
flushes don't send IPIs).

J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
