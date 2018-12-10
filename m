Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2CD888E0001
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 02:46:56 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id f17so3781460edm.20
        for <linux-mm@kvack.org>; Sun, 09 Dec 2018 23:46:56 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d12si610585edv.158.2018.12.09.23.46.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Dec 2018 23:46:54 -0800 (PST)
Subject: Re: [PATCHv2] mm/pageblock: throw compiling time error if
 pageblock_bits can not hold MIGRATE_TYPES
References: <1544158388-20832-1-git-send-email-kernelfans@gmail.com>
 <7aa8d326-cffc-f2b6-2c03-01d9bd4c54b4@suse.cz>
 <CAFgQCTvvgGitdmNLUd8qr0wXt2uecWWssECDFyxMQVSuOW0KmQ@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c18f2fc5-b7df-3c51-80b9-94828b86754c@suse.cz>
Date: Mon, 10 Dec 2018 08:46:52 +0100
MIME-Version: 1.0
In-Reply-To: <CAFgQCTvvgGitdmNLUd8qr0wXt2uecWWssECDFyxMQVSuOW0KmQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Oscar Salvador <osalvador@suse.de>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>

On 12/10/18 4:15 AM, Pingfan Liu wrote:
> On Fri, Dec 7, 2018 at 3:36 PM Vlastimil Babka <vbabka@suse.cz> wrote:
>>
>> On 12/7/18 5:53 AM, Pingfan Liu wrote:
>>> Currently, NR_PAGEBLOCK_BITS and MIGRATE_TYPES are not associated by code.
>>> If someone adds extra migrate type, then he may forget to enlarge the
>>> NR_PAGEBLOCK_BITS. Hence it requires some way to fix.
>>> NR_PAGEBLOCK_BITS depends on MIGRATE_TYPES, while these macro
>>> spread on two different .h file with reverse dependency, it is a little
>>> hard to refer to MIGRATE_TYPES in pageblock-flag.h. This patch tries to
>>> remind such relation in compiling-time.
>>>
>>> Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>> Cc: Michal Hocko <mhocko@suse.com>
>>> Cc: Pavel Tatashin <pavel.tatashin@microsoft.com>
>>> Cc: Vlastimil Babka <vbabka@suse.cz>
>>> Cc: Oscar Salvador <osalvador@suse.de>
>>> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
>>> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>> Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>>> ---
>>>  include/linux/pageblock-flags.h | 5 +++--
>>>  mm/page_alloc.c                 | 3 ++-
>>>  2 files changed, 5 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/include/linux/pageblock-flags.h b/include/linux/pageblock-flags.h
>>> index 9132c5c..fe0aec4 100644
>>> --- a/include/linux/pageblock-flags.h
>>> +++ b/include/linux/pageblock-flags.h
>>> @@ -25,11 +25,12 @@
>>>
>>>  #include <linux/types.h>
>>>
>>> +#define PB_migratetype_bits 3
>>>  /* Bit indices that affect a whole block of pages */
>>>  enum pageblock_bits {
>>>       PB_migrate,
>>> -     PB_migrate_end = PB_migrate + 3 - 1,
>>> -                     /* 3 bits required for migrate types */
>>> +     PB_migrate_end = PB_migrate + PB_migratetype_bits - 1,
>>> +                     /* n bits required for migrate types */
>>>       PB_migrate_skip,/* If set the block is skipped by compaction */
>>>
>>>       /*
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index 2ec9cc4..1a22d8d 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -425,7 +425,8 @@ void set_pfnblock_flags_mask(struct page *page, unsigned long flags,
>>>       unsigned long bitidx, word_bitidx;
>>>       unsigned long old_word, word;
>>>
>>> -     BUILD_BUG_ON(NR_PAGEBLOCK_BITS != 4);
>>
>> Why delete this one? It's for something a bit different and also still
>> valid.
>>
> 
> I think it is dependent on PB_migratetype_bits (plus 1 dedicated bit
> for skip), hence the later one implies it.

No, NR_PAGEBLOCK_BITS simply to be 4 (or other number that can divide
the number of bits in a word with no remainder), or
set_pfnblock_flags_mask() will not function correctly.

>>> +     BUILD_BUG_ON(order_base_2(MIGRATE_TYPES)
>>> +             != (PB_migratetype_bits - 1));
>>
>> I think this should use the '>' operator. It's fine if there are less
> 
> If ">" is chosen, then it allows wasted bits. I had thought it is not
> the purpose of the design, hence disard the ">".

We do allow wasted bits, because we need NR_PAGEBLOCK_BITS to be 4 in
any case, as explained above.

> Otherwise, what about
> using warning on ">"?

I think it would be needed.

>> types than what can fit into 3 bits. AFAICS for !CONFIG_DMA and
>> !CONFIG_MEMORY_ISOLATION there are just 4 types that fit into 2 bits...
>>
> Oh, yes, you are right. How about this:
> #if defined(CONFIG_DMA) || defined(CONFIG_MEMORY_ISOLATION)
> #define PB_migratetype_bits 3
> #else
> #define PB_migratetype_bits 2
> #endif

I think it's not necessary. Really, we need to have 4 NR_PAGEBLOCK_BITS
with the current code, and this leaves us with 3 bits for migratetype.
The only thing to check is whether migratetypes fit into these 3 bits, IMHO.

> Thanks for your kindly review.
> 
> Regards,
> Pingfan
>>>
>>>       bitmap = get_pageblock_bitmap(page, pfn);
>>>       bitidx = pfn_to_bitidx(page, pfn);
>>>
>>
