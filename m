Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C3E9D6B0047
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 21:03:34 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1J23U8u023715
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 19 Feb 2010 11:03:31 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8295945DE53
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 11:03:30 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 63CE845DE51
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 11:03:30 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 45694E18001
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 11:03:30 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E898B1DB803C
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 11:03:29 +0900 (JST)
Date: Fri, 19 Feb 2010 11:00:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Kernel panic due to page migration accessing memory holes
Message-Id: <20100219110003.dfe58df8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4B7DEDB0.8030802@codeaurora.org>
References: <4B7C8DC2.3060004@codeaurora.org>
	<20100218100324.5e9e8f8c.kamezawa.hiroyu@jp.fujitsu.com>
	<4B7CF8C0.4050105@codeaurora.org>
	<20100218183604.95ee8c77.kamezawa.hiroyu@jp.fujitsu.com>
	<20100218100432.GA32626@csn.ul.ie>
	<4B7DEDB0.8030802@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michael Bohan <mbohan@codeaurora.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Feb 2010 17:47:28 -0800
Michael Bohan <mbohan@codeaurora.org> wrote:

> On 2/18/2010 2:04 AM, Mel Gorman wrote:
> > On Thu, Feb 18, 2010 at 06:36:04PM +0900, KAMEZAWA Hiroyuki wrote:
> >    
> >>   [Fact]
> >>   - There are 2 banks of memory and a memory hole on your machine.
> >>     As
> >>           0x00200000 - 0x07D00000
> >>           0x40000000 - 0x43000000
> >>
> >>   - Each bancks are in the same zone.
> >>   - You use FLATMEM.
> >>   - You see panic in move_freepages().
> >>   - Your host's MAX_ORDER=11....buddy allocator's alignment is 0x400000
> >>     Then, it seems 1st bank is not algined.
> >>      
> > It's not and assumptions are made about it being aligned.
> >    
> 
> Would it be prudent to have the ARM mm init code detect unaligned, 
> discontiguous banks and print a warning message if 
> CONFIG_ARCH_HAS_HOLES_MEMORYMODEL is not configured?  Should we take it 
> a step further and even BUG()?
> 
> > ARM frees unused portions of memmap to save memory. It's why memmap_valid_within()
> > exists when CONFIG_ARCH_HAS_HOLES_MEMORYMODEL although previously only
> > reading /proc/pagetypeinfo cared.
> >
> > In that case, the FLATMEM memory map had unexpected holes which "never"
> > happens and that was the workaround. The problem here is that there are
> > unaligned zones but no pfn_valid() implementation that can identify
> > them as you'd have with SPARSEMEM. My expectation is that you are using
> > the pfn_valid() implementation from asm-generic
> >
> > #define pfn_valid(pfn)          ((pfn)<  max_mapnr)
> >
> > which is insufficient in your case.
> >    
> 
> I am actually using the pfn_valid implementation FLATMEM in 
> arch/arm/include/asm/memory.h.  This one is very similar to the 
> asm-generic, and has no knowledge of the holes.
> 
That means, in FLATMEM, memmaps are allocated for [start....max_pfn].
pfn_valid() isn't for "there is memor" but for "there is memmap".



> > I think it's more likely the at the memmap he is accessing has been
> > freed and is effectively random data.
> >
> >    
> 
> I also think this is the case.
> 
Then, plz check free_bootmem() at el doen't free pages in a memory hole.


> > SPARSEMEM would give you an implementation of pfn_valid() that you could
> > use here. The choices that spring to mind are;
> >
> > 1. reduce MAX_ORDER so they are aligned (easiest)
> >    
> 
> Is it safe to assume that reducing MAX_ORDER will hurt performance?
> 
> > 2. use SPARSEMEM (easy, but not necessary what you want to do, might
> > 	waste memory unless you drop MAX_ORDER as well)
> >    
> 
> We intend to use SPARSEMEM, but we'd also like to maintain FLATMEM 
> compatibility for some configurations.  My guess is that there are other 
> ARM users that may want this support as well.
> 
> > 3. implement a pfn_valid() that can handle the holes and set
> > 	CONFIG_HOLES_IN_ZONE so it's called in move_freepages() to
> > 	deal with the holes (should pass this by someone more familiar
> > 	with ARM than I)
> >    
> 
> This option seems the best to me.  We should be able to implement an ARM 
> specific pfn_valid() that walks the ARM meminfo struct to ensure the pfn 
> is not within a hole.
> 
> My only concern with this is a comment in __rmqueue_fallback() after 
> calling move_freepages_block()  that states "Claim the whole block if 
> over half of it is free".  Suppose only 1 MB is beyond the bank limit.  
> That means that over half of the pages of the 4 MB block will be 
> reported by move_freepages() as free -- but 1 MB of those pages are 
> invalid.  Won't this cause problems if these pages are assumed to be 
> part of an active block?
> 
memmap for memory holes should be marked as PG_reserved and never be freed
by free_bootmem(). Then, memmap for memory holes will not be in buddy allocator.

Again, pfn_valid() just show "there is memmap", not for "there is a valid page"


> It seems like we should have an additional check in 
> move_freepages_block() with pfn_valid_within() to check the last page in 
> the block (eg. end_pfn) before calling move_freepages_block().  If the 
> last page is not valid, then we shouldn't we return 0 as in the zone 
> span check?  This will also skip the extra burden of checking each 
> individual page, when we already know the proposed range is invalid.
> 
You don't need that. please check why PG_reserved for your memory holes
are not set.

> Assuming we did return 0 in this case, would that sub-block of pages 
> ever be usable for anything else, or would it be effectively wasted?  If 
> this memory were wasted, then adjusting MAX_ORDER would have an 
> advantage in this sense -- ignoring any performance implications.
> 

Even you do that, you have to fix "someone corrupts memory" or "someone
free PG_reserved memory" issue, anyway.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
