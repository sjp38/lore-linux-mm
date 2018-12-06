Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 41D7A6B791C
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 04:00:15 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id n68so22233262qkn.8
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 01:00:15 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t64si4142642qka.35.2018.12.06.01.00.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 01:00:13 -0800 (PST)
Subject: Re: [PATCH 1/2] mm, pageblock: make sure pageblock won't exceed
 mem_sectioin
References: <20181205091905.27727-1-richard.weiyang@gmail.com>
 <20181205111513.GA23260@techsingularity.net>
 <20181205120820.3gbhfvxgmclvj3wu@master>
 <20181205153733.GB23260@techsingularity.net>
 <20181205223121.p6ecogd7itotiosn@master>
From: David Hildenbrand <david@redhat.com>
Message-ID: <268397e6-de82-4810-a10f-26244afe9351@redhat.com>
Date: Thu, 6 Dec 2018 10:00:05 +0100
MIME-Version: 1.0
In-Reply-To: <20181205223121.p6ecogd7itotiosn@master>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On 05.12.18 23:31, Wei Yang wrote:
> On Wed, Dec 05, 2018 at 03:37:33PM +0000, Mel Gorman wrote:
>> On Wed, Dec 05, 2018 at 12:08:20PM +0000, Wei Yang wrote:
>>> On Wed, Dec 05, 2018 at 11:15:13AM +0000, Mel Gorman wrote:
>>>> On Wed, Dec 05, 2018 at 05:19:04PM +0800, Wei Yang wrote:
>>>>> When SPARSEMEM is used, there is an indication that pageblock is not
>>>>> allowed to exceed one mem_section. Current code doesn't have this
>>>>> constrain explicitly.
>>>>>
>>>>> This patch adds this to make sure it won't.
>>>>>
>>>>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>>>>
>>>> Is this even possible? This would imply that the section size is smaller
>>>> than max order which would be quite a crazy selection for a sparesemem
>>>> section size. A lot of assumptions on the validity of PFNs within a
>>>> max-order boundary would be broken with such a section size. I'd be
>>>> surprised if such a setup could even boot, let alone run.
>>>
>>> pageblock_order has two definitions.
>>>
>>>     #define pageblock_order        HUGETLB_PAGE_ORDER
>>>
>>>     #define pageblock_order        (MAX_ORDER-1)
>>>
>>> If CONFIG_HUGETLB_PAGE is not enabled, pageblock_order is related to
>>> MAX_ORDER, which ensures it is smaller than section size.
>>>
>>> If CONFIG_HUGETLB_PAGE is enabled, pageblock_order is not related to
>>> MAX_ORDER. I don't see HUGETLB_PAGE_ORDER is ensured to be less than
>>> section size. Maybe I missed it?
>>>
>>
>> HUGETLB_PAGE_ORDER is less than MAX_ORDER on the basis that normal huge
>> pages (not gigantic) pages are served from the buddy allocator which is
>> limited by MAX_ORDER.
>>
> 
> Maybe I am lost here, I got one possible definition on x86.
> 
> #define pageblock_order		HUGETLB_PAGE_ORDER
> #define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
> #define HPAGE_SHIFT		PMD_SHIFT
> #define PMD_SHIFT	PUD_SHIFT

PMD_SHIFT is usually 21

arch/x86/include/asm/pgtable-3level_types.h:#define PMD_SHIFT   21
arch/x86/include/asm/pgtable_64_types.h:#define PMD_SHIFT       21

Unless CONFIG_PGTABLE_LEVELS <= 2

Then include/asm-generic/pgtable-nopmd.h will be used in
arch/x86/include/asm/pgtable_types.h
	#define PMD_SHIFT	PUD_SHIFT

In that case, also include/asm-generic/pgtable-nopmd.h is uses
	#define PUD_SHIFT	P4D_SHIFT

... include/asm-generic/pgtable-nop4d.h
	#define P4D_SHIFT	PGDIR_SHIFT


And that would be
arch/x86/include/asm/pgtable-2level_types.h:#define PGDIR_SHIFT 22

If I am not wrong.

So we would have pageblock_order = (22 - 12) = 10


> #define PUD_SHIFT	30
> 
> This leads to pageblock_order = (30 - 12) = 18 > MAX_ORDER  ?
> 
> What you mentioned sounds reasonable. A huge page should be less than
> MAX_ORDER, otherwise page allocator couldn't handle it. But I don't see
> the connection between MAX_ORDER and HUGETLB_PAGE_ORDER. Do we need to
> add a check on this? Or it already has similar contrain in code, but I
> missed it?
> 
>> -- 
>> Mel Gorman
>> SUSE Labs
> 


-- 

Thanks,

David / dhildenb
