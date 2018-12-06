Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1280D6B7937
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 04:27:04 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id w185so22684904qka.9
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 01:27:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y52si6722108qty.161.2018.12.06.01.27.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 01:27:03 -0800 (PST)
Subject: Re: [PATCH 1/2] mm, pageblock: make sure pageblock won't exceed
 mem_sectioin
References: <20181205091905.27727-1-richard.weiyang@gmail.com>
 <20181205111513.GA23260@techsingularity.net>
 <20181205120820.3gbhfvxgmclvj3wu@master>
 <20181205153733.GB23260@techsingularity.net>
 <20181205223121.p6ecogd7itotiosn@master>
 <268397e6-de82-4810-a10f-26244afe9351@redhat.com>
 <20181206092112.sgcb4h6lpk6k7ab6@master>
From: David Hildenbrand <david@redhat.com>
Message-ID: <d06f7108-4d96-99de-0db4-ac043fdd4c26@redhat.com>
Date: Thu, 6 Dec 2018 10:26:55 +0100
MIME-Version: 1.0
In-Reply-To: <20181206092112.sgcb4h6lpk6k7ab6@master>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, akpm@linux-foundation.org

On 06.12.18 10:21, Wei Yang wrote:
> On Thu, Dec 06, 2018 at 10:00:05AM +0100, David Hildenbrand wrote:
>> On 05.12.18 23:31, Wei Yang wrote:
>>> On Wed, Dec 05, 2018 at 03:37:33PM +0000, Mel Gorman wrote:
>>>> On Wed, Dec 05, 2018 at 12:08:20PM +0000, Wei Yang wrote:
>>>>> On Wed, Dec 05, 2018 at 11:15:13AM +0000, Mel Gorman wrote:
>>>>>> On Wed, Dec 05, 2018 at 05:19:04PM +0800, Wei Yang wrote:
>>>>>>> When SPARSEMEM is used, there is an indication that pageblock is not
>>>>>>> allowed to exceed one mem_section. Current code doesn't have this
>>>>>>> constrain explicitly.
>>>>>>>
>>>>>>> This patch adds this to make sure it won't.
>>>>>>>
>>>>>>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>>>>>>
>>>>>> Is this even possible? This would imply that the section size is smaller
>>>>>> than max order which would be quite a crazy selection for a sparesemem
>>>>>> section size. A lot of assumptions on the validity of PFNs within a
>>>>>> max-order boundary would be broken with such a section size. I'd be
>>>>>> surprised if such a setup could even boot, let alone run.
>>>>>
>>>>> pageblock_order has two definitions.
>>>>>
>>>>>     #define pageblock_order        HUGETLB_PAGE_ORDER
>>>>>
>>>>>     #define pageblock_order        (MAX_ORDER-1)
>>>>>
>>>>> If CONFIG_HUGETLB_PAGE is not enabled, pageblock_order is related to
>>>>> MAX_ORDER, which ensures it is smaller than section size.
>>>>>
>>>>> If CONFIG_HUGETLB_PAGE is enabled, pageblock_order is not related to
>>>>> MAX_ORDER. I don't see HUGETLB_PAGE_ORDER is ensured to be less than
>>>>> section size. Maybe I missed it?
>>>>>
>>>>
>>>> HUGETLB_PAGE_ORDER is less than MAX_ORDER on the basis that normal huge
>>>> pages (not gigantic) pages are served from the buddy allocator which is
>>>> limited by MAX_ORDER.
>>>>
>>>
>>> Maybe I am lost here, I got one possible definition on x86.
>>>
>>> #define pageblock_order		HUGETLB_PAGE_ORDER
>>> #define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
>>> #define HPAGE_SHIFT		PMD_SHIFT
>>> #define PMD_SHIFT	PUD_SHIFT
>>
>> PMD_SHIFT is usually 21
>>
>> arch/x86/include/asm/pgtable-3level_types.h:#define PMD_SHIFT   21
>> arch/x86/include/asm/pgtable_64_types.h:#define PMD_SHIFT       21
>>
>> Unless CONFIG_PGTABLE_LEVELS <= 2
>>
>> Then include/asm-generic/pgtable-nopmd.h will be used in
>> arch/x86/include/asm/pgtable_types.h
>> 	#define PMD_SHIFT	PUD_SHIFT
>>
>> In that case, also include/asm-generic/pgtable-nopmd.h is uses
>> 	#define PUD_SHIFT	P4D_SHIFT
>>
>> ... include/asm-generic/pgtable-nop4d.h
>> 	#define P4D_SHIFT	PGDIR_SHIFT
>>
>>
>> And that would be
>> arch/x86/include/asm/pgtable-2level_types.h:#define PGDIR_SHIFT 22
>>
>> If I am not wrong.
>>
>> So we would have pageblock_order = (22 - 12) = 10
>>
> 
> Thank, David :-)
> 
> I think current configuration is correct, while all these digits are
> written by programmer.
> 
> My concern and suggestion is to add a compiler check to enforce this. So
> that we would avoid this situation if someone miss this constrain. Just
> as the check on MAX_ORDER and SECION_SIZE.

I am not completely against this, I rather wonder if it is needed
because I assume other things will break horribly in case this is
violated. And at that would only be helpful for somebody developing for
a new architecture/flavor.

As I am a friend of documenting things that are not obvious, I would
rather suggest to add a comment to the
	#define pageblock_order		HUGETLB_PAGE_ORDER
line, stating what we just learned.

/*
 * HUGETLB_PAGE_ORDER will always be smaller than MAX_ORDER, so that
 * huge (not gigantic) pages can be served from the buddy allocator.
 */


-- 

Thanks,

David / dhildenb
