Message-ID: <41C4C5C2.5000607@yahoo.com.au>
Date: Sun, 19 Dec 2004 11:05:22 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 4/10] alternate 4-level page tables patches
References: <41C3D48F.8080006@yahoo.com.au> <41C3D4AE.7010502@yahoo.com.au> <41C3D4C8.1000508@yahoo.com.au> <41C3F2D6.6060107@yahoo.com.au> <20041218095050.GC338@wotan.suse.de> <41C40125.3060405@yahoo.com.au> <20041218110608.GJ771@holomorphy.com> <41C411BD.6090901@yahoo.com.au> <20041218113252.GK771@holomorphy.com> <41C41ACE.7060002@yahoo.com.au> <20041218124635.GL771@holomorphy.com>
In-Reply-To: <20041218124635.GL771@holomorphy.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andi Kleen <ak@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> William Lee Irwin III wrote:
> 
>>>If clear_page_tables() implemented perfect GC.
> 
> 
> On Sat, Dec 18, 2004 at 10:55:58PM +1100, Nick Piggin wrote:
> 
>>Oh... well it does perfectly free memory in the context of what ranges
>>have been previously cleared with clear_page_tables. So that doesn't
>>free you from the requirement of calling clear_page_tables at some
>>point.
>>I suspect though, you are referring to refcounting, in which case yes,
>>GC could probably be performed at unmap time, and clear_page_tables
>>could disappear. I still think it would be too costly to refcount down
>>to the pte_t level, especially SMP-wise.... but I'm just basing that
>>on a few minutes of thought, so - I don't really know.
> 
> 
> vmas are unmapped one-by-one during process destruction.
> 

Yeah but clear_page_tables isn't called for each vma that is unmapped
at exit time. Rather, one big one is called at the end - I suspect
this is usually more efficient.

> 
> William Lee Irwin III wrote:
> 
>>>Counterexamples would be illustrative.
> 
> 
> On Sat, Dec 18, 2004 at 10:55:58PM +1100, Nick Piggin wrote:
> 
>>Oh, just workloads where memory is fairly dense in virtual space, and
>>not shared (much). Non-oracle workloads, perhaps? :)
>>Seriously? On my typical desktop, I have 250MB used, of which 1MB is
>>page tables, I suspect this is a pretty typical ratio on desktops,
>>but I have less experience with high end database servers and that type
>>of stuff.
>>I was hoping you could provide an example rather than me a counter ;)
> 
> 
> Page replacement is largely irrelevant to databases. Administrators
> etc. rather go through pains to avoid page replacement and at some
> cost. They rather reclaim when page replacement occurs. More beneficial
> for databases would be increasing the multiprogramming level a system
> can maintain without page replacement or background data structure
> reclamation.  This is, of course, not to say that databases can
> tolerate leaks or effective leaks of kernel memory or data structures.
> 

OK. Well with the simple patch I've shown, we no longer 'leak' pagetables
(although the unmap-time cost may require moving to a partially refcounted
approach).

Does anyone know of workloads that have significant clear_page_tables
cost?

> Effective eviction of process data is far more pertinent to laptops and
> desktops, where every wasted pagetable page is another page of
> userspace program data that has to be swapped out and another write to
> a disk spun by a battery with a limited lifetime (though the timer is
> probably a larger concern wrt. battery life). Idle processes are likely
> to be the largest concern there. The kernel's memory footprint
> is always pure overhead, and pagetables are a very large part of it.
> 
> (a) idle bloatzilla
> (b) idle mutt
> (c) idle shells
> (d) numerous daemons started up by initscripts and rarely ever invoked
> 

Oh sure, but in those cases, the pagetables aren't such a big waste
of space, because memory access isn't too sparse, and you don't have
a huge amount of sharing (even executables, shared libraries - there
just aren't that many processes running to make page tables a large
fraction of resident memory).

So I'm not saying there are no savings to be had at all, but just that
maybe they aren't worth it (I don't know - maybe it is possible to do
a full refcounting implementation without adding fastpath overhead).

I mean, I've got 250MB used and only 1/250th of that is in pagetables.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
