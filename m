Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id B1CEF6B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 10:25:02 -0500 (EST)
Received: by wibbs8 with SMTP id bs8so983341wib.4
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 07:25:02 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fu13si4019822wic.47.2015.02.27.07.24.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Feb 2015 07:25:00 -0800 (PST)
Message-ID: <54F08C48.90205@suse.cz>
Date: Fri, 27 Feb 2015 16:24:56 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv2] mm: Don't offset memmap for flatmem
References: <1421804273-29947-1-git-send-email-lauraa@codeaurora.org> <1421888500-24364-1-git-send-email-lauraa@codeaurora.org> <20150122162021.aa861aeb53c22206a19ebbcb@linux-foundation.org> <54C196D0.6040900@codeaurora.org> <54C20EEC.1060809@suse.cz> <20150126155617.GA2395@suse.de> <54CA3202.8020609@suse.cz> <54D18319.40602@codeaurora.org> <54ECD6FE.5060503@codeaurora.org>
In-Reply-To: <54ECD6FE.5060503@codeaurora.org>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>, Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Srinivas Kandagatla <srinivas.kandagatla@linaro.org>, linux-arm-kernel@lists.infradead.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, ssantosh@kernel.org, Kevin Hilman <khilman@linaro.org>, Arnd Bergman <arnd@arndb.de>, Stephen Boyd <sboyd@codeaurora.org>, linux-mm@kvack.org, Kumar Gala <galak@codeaurora.org>

On 02/24/2015 08:54 PM, Laura Abbott wrote:
> Reviving this thread because I don't think it ever got resolved.
> 
> On 2/3/2015 6:25 PM, Laura Abbott wrote:
>> On 1/29/2015 5:13 AM, Vlastimil Babka wrote:
>>>>
>>>> I don't recall introducing ARCH_PFN_OFFSET, are you sure it was me?  I'm just
>>>> back today after been offline a week so didn't review the patch but IIRC,
>>>> ARCH_PFN_OFFSET deals with the case where physical memory does not start
>>>> at 0. Without the offset, virtual _PAGE_OFFSET would not physical page 0.
>>>> I don't recall it being related to the alignment of node 0 so if there
>>>> are crashes due to misalignment of node 0 and the fix is ARCH_PFN_OFFSET
>>>> related then I'm surprised.
>>>
>>> You're right that ARCH_PFN_OFFSET wasn't added by you, but by commit
>>> 467bc461d2 which was a bugfix to your commit c713216dee, which did
>>>  introduce the mem_map correction code, and after which the code looked like:
>>>
>>> mem_map = NODE_DATA(0)->node_mem_map;
>>> #ifdef CONFIG_ARCH_POPULATES_NODE_MAP
>>>                 if (page_to_pfn(mem_map) != pgdat->node_start_pfn)
>>>                         mem_map -= pgdat->node_start_pfn;
>>> #endif /* CONFIG_ARCH_POPULATES_NODE_MAP */
>>>
>>>
>>> It's from 2006 so I can't expect you remember the details, but I had some
>>>  trouble finding out what this does. I assume it makes sure that mem_map points
>>>  to struct page corresponding to pfn 0, because that's what translations using
>>>  mem_map expect.
>>> But pgdat->node_mem_map points to struct page corresponding to
>>>  pgdat->node_start_pfn, which might not be 0. So it subtracts node_start_pfn
>>>  to fix that. This is OK, as the node_mem_map is allocated (in this very
>>>  function) with padding so that it covers a MAX_ORDER_NR_PAGES aligned area
>>>  where node_mem_map may point to the middle of it.
>>>
>>> Commit 467bc461d2 fixed this in case the first pfn is not 0, but ARCH_PFN_OFFSET.
>>>  So mem_map points to struct page corresponding to pfn=ARCH_PFN_OFFSET, which
>>>  is OK. But I still have few doubts:
>>>
>>> 1) The "if (page_to_pfn(mem_map) != pgdat->node_start_pfn)" sort of silently
>>>  assumes that mem_map is allocated at the beginning of the node, i.e. at
>>>  pgdat->node_start_pfn. And the only reason for this if-condition to be true,
>>>  is that we haven't corrected the page_to_pfn translation, which uses mem_map.
>>>  Is this assumption always OK to do? Shouldn't the if-condition be instead about
>>>  pgdat->node_start_pfn not being aligned?
>>>
>>> 2) The #ifdef guard is about CONFIG_ARCH_POPULATES_NODE_MAP, which is nowadays  called  > CONFIG_HAVE_MEMBLOCK_NODE_MAP. But shouldn't it be #ifdef FLATMEM instead?
>>>  After all, we are correcting value of mem_map based on page_to_pfn code
>>> variant used on FLATMEM. arm doesn't define
>>> CONFIG_ARCH_POPULATES_NODE_MAP but apparently needs this correction.
>>>
>>
>> Just doing #ifdef FLATMEM doesn't work because ARCH_PFN_OFFSET doesn't
>> seem to be picked up properly for NOMMU arches properly. Probably just
>> missing a header somewhere.
>>
>>> 3) The node_mem_map allocation code aligns the allocation to MAX_ORDER_NR_PAGES,
>>>  so the offset between the start of the allocated map and where node_mem_map
>>>  points to will be up to MAX_ORDER_NR_PAGES.
>>> However, here we subtract (in current kernel) (pgdat->node_start_pfn - ARCH_PFN_OFFSET).
>>>  That looks like another silent assumption, that pgdat->node_start_pfn is always
>>>  between ARCH_PFN_OFFSET and ARCH_PFN_OFFSET + MAX_ORDER_NR_PAGES. If it were
>>>  larger, the mem_map correction would subtract too much and end up below what
>>>  was allocated for node_mem_map, no? The bug report behind this patch said that
>>>  first 2MB of memory was reserved using "no-map flag using DT". Unless this somehow
>>>  translates to ARCH_PFN_OFFSET at build time, we would underflow mem_map, right?
>>>  Maybe I'm just overly paranoid here and of course ARCH_PFN_OFFSET is determined
>>>  properly on arm...
>>>
>>> If anyone can confirm my doubts or point me to what I'm missing, thanks.
>>
>> ARCH_PFN_OFFSET should always be the lowest PFN in the system, otherwise
>> I think plenty of other things are broken given how many architectures
>> make this assumption. That said, I don't think subtracting ARCH_PFN_OFFSET
>> makes it obvious why the adjustment is being made.
>>
>> Thanks,
>> Laura
>>
> 
> I was incorrect before: it isn't just NOMMU but architectures that don't use
> asm-generic/memory_model.h which failed to compile. I could respin with

Hm I see, some architectures use own variant of page_to_pfn, that's why it's
being used in the if () check.

> more ifdefery around the ARCH_PFN_OFFSET if that sounds reasonable.

So I think your v2 might be correct already. Unless there's an architecture that
defines CONFIG_FLATMEM and not CONFIG_HAVE_MEMBLOCK_NODE_MAP and places memmap
somewhere else than pgdat->node_start_pfn, which would trigger the check for a
wrong reason after the patch.

Looks like arm is an arch that doesn't define CONFIG_HAVE_MEMBLOCK_NODE_MAP, yet
it defines ARCH_PFN_OFFSET. With your patch it would correct memmap by the
calculated offset, not the ARCH_PFN_OFFSET constant. Are these two the same
then? Should there be something like a VM_BUG_ON that ARCH_PFN_OFFSET (if it
exists) is indeed equal to the calculated offset? Or maybe a more general
VM_BUG_ON checking that after any correction we make, the (page_to_pfn(mem_map)
== pgdat->node_start_pfn) condition holds?

> Thanks,
> Laura
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
