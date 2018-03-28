Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id A0D096B002F
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 06:42:51 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id i9-v6so1128000oth.3
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 03:42:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w19-v6sor1432741otw.190.2018.03.28.03.42.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Mar 2018 03:42:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <113cb8cf-7c59-4fbb-5ad2-4ae6eeb1193c@gmail.com>
References: <1521894282-6454-1-git-send-email-hejianet@gmail.com>
 <1521894282-6454-2-git-send-email-hejianet@gmail.com> <CACjP9X-zvGa5OQpuJ1bUp+V=_eTOUDLfKkT1sbT84k5zJz=epA@mail.gmail.com>
 <113cb8cf-7c59-4fbb-5ad2-4ae6eeb1193c@gmail.com>
From: Daniel Vacek <neelx@redhat.com>
Date: Wed, 28 Mar 2018 12:42:49 +0200
Message-ID: <CACjP9X8_=ZsM9fK51+EdTGLLq2izfBBaGnPiPbuBV2TYPhEPyA@mail.gmail.com>
Subject: Re: [PATCH v2 1/5] mm: page_alloc: remain memblock_next_valid_pfn()
 when CONFIG_HAVE_ARCH_PFN_VALID is enable
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, Vlastimil Babka <vbabka@suse.cz>, open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, James Morse <james.morse@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steve Capper <steve.capper@arm.com>, x86@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Jia He <jia.he@hxt-semitech.com>

On Wed, Mar 28, 2018 at 11:26 AM, Jia He <hejianet@gmail.com> wrote:
>
>
> On 3/28/2018 12:52 AM, Daniel Vacek Wrote:
>>
>> On Sat, Mar 24, 2018 at 1:24 PM, Jia He <hejianet@gmail.com> wrote:
>>>
>>> Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
>>> where possible") optimized the loop in memmap_init_zone(). But it causes
>>> possible panic bug. So Daniel Vacek reverted it later.
>>>
>>> But memblock_next_valid_pfn is valid when CONFIG_HAVE_ARCH_PFN_VALID is
>>> enabled. And as verified by Eugeniu Rosca, arm can benifit from this
>>> commit. So remain the memblock_next_valid_pfn.
>>
>> It is not dependent on CONFIG_HAVE_ARCH_PFN_VALID option but on
>> arm(64) implementation of pfn_valid() function, IIUC. So it should
>> really be moved from generic source file to arm specific location. I'd
>> say somewhere close to the pfn_valid() implementation. Such as to
>> arch/arm{,64}/mm/ init.c-ish?
>>
>> --nX
>
> Hi Daniel
> I didn't catch the reason why "It is not dependent on
> CONFIG_HAVE_ARCH_PFN_VALID option but
> on arm(64) implementation of pfn_valid() function"? Can you explain more
> about it? Thanks

Arm implementation of pfn_valid() is actually based on memblock as
HAVE_MEMBLOCK is mandatory for arm so memblock is guaranteed to always
be available, IIUC. Correct me if I am wrong here.
With that said, you are fine with using memblock to skip gaps and
finding next valid frame.

Though the generic version of pfn_valid() is based on mem sections and
memblock_next_valid_pfn() does not always return the next valid one
but skips more resulting in some valid frames to be skipped (as if
they were invalid). And that's why kernel was eventually crashing on
some !arm machines.

Now, if any other architecture defines CONFIG_HAVE_ARCH_PFN_VALID and
implements it's own version of pfn_valid(), there is no guarantee that
it will be based on memblock data or somehow equivalent to the arm
implementation, right?

At this moment only arm implements CONFIG_HAVE_ARCH_PFN_VALID. Maybe
it could be generalized to something like CONFIG_MEMBLOCK_PFN_VALID
and moved to generic code. And then you can base your changes on that.
But I am not sure if that is possible.

> What's your thought if I changed the codes as followed?
> in include/linux/memblock.h
> #ifdef CONFIG_HAVE_ARCH_PFN_VALID
> extern unsigned long memblock_next_valid_pfn(unsigned long pfn);
> #else
> #define memblock_next_valid_pfn(pfn) (pfn + 1)
> #endif

I think I'd rather do something like this:

                if (!early_pfn_valid(pfn)) {
                        pfn = skip_to_last_invalid_pfn(pfn);
                        continue;
                }

And than for arm define:

#if (defined CONFIG_HAVE_MEMBLOCK) && (defined CONFIG_HAVE_ARCH_PFN_VALID)
#define skip_to_last_invalid_pfn(pfn) (memblock_next_valid_pfn(pfn,
&early_idx) - 1)
#endif

And for the generic fallback:

#ifndef skip_to_last_invalid_pfn
#define skip_to_last_invalid_pfn(pfn) (pfn)
#endif

--nX

> Cheers,
> Jia
>
>>
>>> Signed-off-by: Jia He <jia.he@hxt-semitech.com>
>>> ---
>>>   include/linux/memblock.h |  4 ++++
>>>   mm/memblock.c            | 29 +++++++++++++++++++++++++++++
>>>   mm/page_alloc.c          | 11 ++++++++++-
>>>   3 files changed, 43 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
>>> index 0257aee..efbbe4b 100644
>>> --- a/include/linux/memblock.h
>>> +++ b/include/linux/memblock.h
>>> @@ -203,6 +203,10 @@ void __next_mem_pfn_range(int *idx, int nid,
>>> unsigned long *out_start_pfn,
>>>               i >= 0; __next_mem_pfn_range(&i, nid, p_start, p_end,
>>> p_nid))
>>>   #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>>>
>>> +#ifdef CONFIG_HAVE_ARCH_PFN_VALID
>>> +unsigned long memblock_next_valid_pfn(unsigned long pfn);
>>> +#endif
>>> +
>>>   /**
>>>    * for_each_free_mem_range - iterate through free memblock areas
>>>    * @i: u64 used as loop variable
>>> diff --git a/mm/memblock.c b/mm/memblock.c
>>> index ba7c878..bea5a9c 100644
>>> --- a/mm/memblock.c
>>> +++ b/mm/memblock.c
>>> @@ -1102,6 +1102,35 @@ void __init_memblock __next_mem_pfn_range(int
>>> *idx, int nid,
>>>                  *out_nid = r->nid;
>>>   }
>>>
>>> +#ifdef CONFIG_HAVE_ARCH_PFN_VALID
>>> +unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn)
>>> +{
>>> +       struct memblock_type *type = &memblock.memory;
>>> +       unsigned int right = type->cnt;
>>> +       unsigned int mid, left = 0;
>>> +       phys_addr_t addr = PFN_PHYS(++pfn);
>>> +
>>> +       do {
>>> +               mid = (right + left) / 2;
>>> +
>>> +               if (addr < type->regions[mid].base)
>>> +                       right = mid;
>>> +               else if (addr >= (type->regions[mid].base +
>>> +                                 type->regions[mid].size))
>>> +                       left = mid + 1;
>>> +               else {
>>> +                       /* addr is within the region, so pfn is valid */
>>> +                       return pfn;
>>> +               }
>>> +       } while (left < right);
>>> +
>>> +       if (right == type->cnt)
>>> +               return -1UL;
>>> +       else
>>> +               return PHYS_PFN(type->regions[right].base);
>>> +}
>>> +#endif /*CONFIG_HAVE_ARCH_PFN_VALID*/
>>> +
>>>   /**
>>>    * memblock_set_node - set node ID on memblock regions
>>>    * @base: base of area to set node ID for
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index c19f5ac..2a967f7 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -5483,8 +5483,17 @@ void __meminit memmap_init_zone(unsigned long
>>> size, int nid, unsigned long zone,
>>>                  if (context != MEMMAP_EARLY)
>>>                          goto not_early;
>>>
>>> -               if (!early_pfn_valid(pfn))
>>> +               if (!early_pfn_valid(pfn)) {
>>> +#if (defined CONFIG_HAVE_MEMBLOCK) && (defined
>>> CONFIG_HAVE_ARCH_PFN_VALID)
>>> +                       /*
>>> +                        * Skip to the pfn preceding the next valid one
>>> (or
>>> +                        * end_pfn), such that we hit a valid pfn (or
>>> end_pfn)
>>> +                        * on our next iteration of the loop.
>>> +                        */
>>> +                       pfn = memblock_next_valid_pfn(pfn) - 1;
>>> +#endif
>>>                          continue;
>>> +               }
>>>                  if (!early_pfn_in_nid(pfn, nid))
>>>                          continue;
>>>                  if (!update_defer_init(pgdat, pfn, end_pfn,
>>> &nr_initialised))
>>> --
>>> 2.7.4
>>>
>
> --
> Cheers,
> Jia
>
