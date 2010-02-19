Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5676D6B0078
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 08:48:52 -0500 (EST)
Date: Fri, 19 Feb 2010 13:48:33 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Kernel panic due to page migration accessing memory holes
Message-ID: <20100219134833.GE30258@csn.ul.ie>
References: <4B7C8DC2.3060004@codeaurora.org> <20100218100324.5e9e8f8c.kamezawa.hiroyu@jp.fujitsu.com> <4B7CF8C0.4050105@codeaurora.org> <20100218183604.95ee8c77.kamezawa.hiroyu@jp.fujitsu.com> <20100218100432.GA32626@csn.ul.ie> <4B7DEDB0.8030802@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4B7DEDB0.8030802@codeaurora.org>
Sender: owner-linux-mm@kvack.org
To: Michael Bohan <mbohan@codeaurora.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 18, 2010 at 05:47:28PM -0800, Michael Bohan wrote:
> On 2/18/2010 2:04 AM, Mel Gorman wrote:
>> On Thu, Feb 18, 2010 at 06:36:04PM +0900, KAMEZAWA Hiroyuki wrote:
>>    
>>>   [Fact]
>>>   - There are 2 banks of memory and a memory hole on your machine.
>>>     As
>>>           0x00200000 - 0x07D00000
>>>           0x40000000 - 0x43000000
>>>
>>>   - Each bancks are in the same zone.
>>>   - You use FLATMEM.
>>>   - You see panic in move_freepages().
>>>   - Your host's MAX_ORDER=11....buddy allocator's alignment is 0x400000
>>>     Then, it seems 1st bank is not algined.
>>>      
>> It's not and assumptions are made about it being aligned.
>>    
>
> Would it be prudent to have the ARM mm init code detect unaligned,  
> discontiguous banks and print a warning message if  
> CONFIG_ARCH_HAS_HOLES_MEMORYMODEL is not configured?  Should we take it  
> a step further and even BUG()?
>

I guess it wouldn't hurt. I wouldn't get too side-tracked though as it's
not the most important issue here.

>> ARM frees unused portions of memmap to save memory. It's why memmap_valid_within()
>> exists when CONFIG_ARCH_HAS_HOLES_MEMORYMODEL although previously only
>> reading /proc/pagetypeinfo cared.
>>
>> In that case, the FLATMEM memory map had unexpected holes which "never"
>> happens and that was the workaround. The problem here is that there are
>> unaligned zones but no pfn_valid() implementation that can identify
>> them as you'd have with SPARSEMEM. My expectation is that you are using
>> the pfn_valid() implementation from asm-generic
>>
>> #define pfn_valid(pfn)          ((pfn)<  max_mapnr)
>>
>> which is insufficient in your case.
>>    
>
> I am actually using the pfn_valid implementation FLATMEM in  
> arch/arm/include/asm/memory.h.  This one is very similar to the  
> asm-generic, and has no knowledge of the holes.
>

Same problem applies so.

>> I think it's more likely the at the memmap he is accessing has been
>> freed and is effectively random data.
>>
>>    
>
> I also think this is the case.
>
>> SPARSEMEM would give you an implementation of pfn_valid() that you could
>> use here. The choices that spring to mind are;
>>
>> 1. reduce MAX_ORDER so they are aligned (easiest)
>>    
>
> Is it safe to assume that reducing MAX_ORDER will hurt performance?
>

No, it does not necessarily reduce performance. In some circumstances it
might even help although I wouldn't chase after it.

Downside one is that some hash tables might be getting hurt if you have a
very large amount of memory (look for "hash table entries:" in dmesg after
booting to see what order is being used).

Downside two is that if some drivers require large contiguous memory
early in boot, they might be hurt by MAX_ORDER being lower. If you
require CONFIG_HUGETLB_PAGE, it might not be possible to reduce
MAX_ORDER depending on the size of the huge page.

>> 2. use SPARSEMEM (easy, but not necessary what you want to do, might
>> 	waste memory unless you drop MAX_ORDER as well)
>>    
>
> We intend to use SPARSEMEM, but we'd also like to maintain FLATMEM  
> compatibility for some configurations.  My guess is that there are other  
> ARM users that may want this support as well.
>
>> 3. implement a pfn_valid() that can handle the holes and set
>> 	CONFIG_HOLES_IN_ZONE so it's called in move_freepages() to
>> 	deal with the holes (should pass this by someone more familiar
>> 	with ARM than I)
>>    
>
> This option seems the best to me.  We should be able to implement an ARM  
> specific pfn_valid() that walks the ARM meminfo struct to ensure the pfn  
> is not within a hole.
>

Be sure to check your performance before and after. pfn_valid_within()
is used in a fair few places and you are likely enabling it.

> My only concern with this is a comment in __rmqueue_fallback() after  
> calling move_freepages_block()  that states "Claim the whole block if  
> over half of it is free".  Suppose only 1 MB is beyond the bank limit.   
> That means that over half of the pages of the 4 MB block will be  
> reported by move_freepages() as free -- but 1 MB of those pages are  
> invalid.  Won't this cause problems if these pages are assumed to be  
> part of an active block?
>

The only operation taking place there is updating a bitmap so I doubt
you'll hit snags there.

> It seems like we should have an additional check in  
> move_freepages_block() with pfn_valid_within() to check the last page in  
> the block (eg. end_pfn) before calling move_freepages_block().  If the  
> last page is not valid, then we shouldn't we return 0 as in the zone  
> span check? This will also skip the extra burden of checking each  
> individual page, when we already know the proposed range is invalid.
>

You don't know where the holes are going to be so it is paranod rather
than making assumptions about where architectures put holes.

> Assuming we did return 0 in this case, would that sub-block of pages  
> ever be usable for anything else, or would it be effectively wasted? 

They're still usable.

> If  
> this memory were wasted, then adjusting MAX_ORDER would have an  
> advantage in this sense -- ignoring any performance implications.
>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
