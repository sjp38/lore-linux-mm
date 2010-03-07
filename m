Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7D2236B0078
	for <linux-mm@kvack.org>; Sat,  6 Mar 2010 19:43:18 -0500 (EST)
Message-ID: <4B92F65A.5060305@kernel.org>
Date: Sat, 06 Mar 2010 16:42:02 -0800
From: Yinghai Lu <yinghai@kernel.org>
MIME-Version: 1.0
Subject: Re: please don't apply : bootmem: avoid DMA32 zone by default
References: <49b004811003041321g2567bac8yb73235be32a27e7c@mail.gmail.com>	<20100305032106.GA12065@cmpxchg.org>	<49b004811003042117n720f356h7e10997a1a783475@mail.gmail.com>	<4B915074.4020704@kernel.org>	<4B916BD6.8010701@kernel.org>	<4B91EBC6.6080509@kernel.org> <20100306162234.e2cc84fb.akpm@linux-foundation.org>
In-Reply-To: <20100306162234.e2cc84fb.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 03/06/2010 04:22 PM, Andrew Morton wrote:
> On Fri, 05 Mar 2010 21:44:38 -0800 Yinghai Lu <yinghai@kernel.org> wrote:
> 
>> On 03/05/2010 12:38 PM, Yinghai Lu wrote:
>>> if you don't want to drop
>>> |  bootmem: avoid DMA32 zone by default
>>>
>>> today mainline tree actually DO NOT need that patch according to print out ...
>>>
>>> please apply this one too.
>>>
>>> [PATCH] x86/bootmem: introduce bootmem_default_goal
>>>
>>> don't punish the 64bit systems with less 4G RAM.
>>> they should use _pa(MAX_DMA_ADDRESS) at first pass instead of failback...
>>
>> andrew,
>>
>> please drop Johannes' patch : bootmem: avoid DMA32 zone by default
> 
> I'd rather not.  That patch is said to fix a runtime problem which is
> present in 2.6.33 and hence we planned on backporting it into 2.6.33.x.

that patch make my box booting time from 215s to 265s.

should have better way to fix the problem:
just put the mem_map or the big chunk on high.
instead put everything above 4g.

some thing like
static void * __init_refok __earlyonly_bootmem_alloc(int node,
                                unsigned long size,
                                unsigned long align,
                                unsigned long goal)
{
        return __alloc_bootmem_node_high(NODE_DATA(node), size, align, goal);
}

void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,
                                   unsigned long align, unsigned long goal)
{
#ifdef MAX_DMA32_PFN
        unsigned long end_pfn;

        if (WARN_ON_ONCE(slab_is_available()))
                return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);

        /* update goal according ...MAX_DMA32_PFN */
        end_pfn = pgdat->node_start_pfn + pgdat->node_spanned_pages;

        if (end_pfn > MAX_DMA32_PFN + (128 >> (20 - PAGE_SHIFT)) &&
            (goal >> PAGE_SHIFT) < MAX_DMA32_PFN) {
                void *ptr;
                unsigned long new_goal;

                new_goal = MAX_DMA32_PFN << PAGE_SHIFT;
#ifdef CONFIG_NO_BOOTMEM
                ptr =  __alloc_memory_core_early(pgdat->node_id, size, align,
                                                 new_goal, -1ULL);
#else
                ptr = alloc_bootmem_core(pgdat->bdata, size, align,
                                                 new_goal, 0);
#endif
                if (ptr)
                        return ptr;
        }
#endif

        return __alloc_bootmem_node(pgdat, size, align, goal);

}


> 
> I don't have a clue what your patches do.  Can you tell us?

do use bootmem, and use early_res instead. 

you are on the to list...

please check...
http://lkml.org/lkml/2010/2/10/39
> 
> Earlier, Johannes wrote
> 
> : Humm, now that is a bit disappointing.  Because it means we will never
> : get rid of bootmem as long as it works for the other architectures. 
> : And your changeset just added ~900 lines of code, some of it being a
> : rather ugly compatibility layer in bootmem that I hoped could go away
> : again sooner than later.
> : 
> : I do not know what the upsides for x86 are from no longer using bootmem
> : but it would suck from a code maintainance point of view to get stuck
> : half way through this transition and have now TWO implementations of
> : the bootmem interface we would like to get rid of.
> 
> Which is a pretty good-sounding argument.  Perhaps we should be
> dropping your patches.
> 
> What patches _are_ these x86 bootmem changes, anyway?  Please identify
> them so people can take a look and see what they do.

http://lkml.org/lkml/2010/2/10/39

and you and linus, ingo, hpa, tglx on the To list.

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
