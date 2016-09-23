Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 95DD528024B
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 10:58:20 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c84so225989067pfj.2
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 07:58:20 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id c6si8116837pfj.136.2016.09.23.07.58.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 23 Sep 2016 07:58:19 -0700 (PDT)
Subject: Re: [PATCH 1/1] lib/ioremap.c: avoid endless loop under ioremapping
 page unaligned ranges
References: <57E20A69.5010206@zoho.com>
 <20160922124735.GB11204@dhcp22.suse.cz>
 <35661a34-c3e0-0ec2-b58f-ee59bef4e4d4@zoho.com>
 <20160923084551.GG4478@dhcp22.suse.cz>
 <f9e708e1-121e-367e-1141-5470e5baffe5@zoho.com>
 <20160923124244.GN4478@dhcp22.suse.cz> <57E52762.9000702@zoho.com>
 <20160923133330.GO4478@dhcp22.suse.cz>
 <d7408c4e-6fe1-f51c-0388-8636f4761ccd@zoho.com>
 <20160923142700.GS4478@dhcp22.suse.cz>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <b33641b2-7fd8-874e-1c30-9d96f095c2b0@zoho.com>
Date: Fri, 23 Sep 2016 22:58:03 +0800
MIME-Version: 1.0
In-Reply-To: <20160923142700.GS4478@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, tj@kernel.org, mingo@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

On 2016/9/23 22:27, Michal Hocko wrote:
> On Fri 23-09-16 22:14:40, zijun_hu wrote:
>> On 2016/9/23 21:33, Michal Hocko wrote:
>>> On Fri 23-09-16 21:00:18, zijun_hu wrote:
>>>> On 09/23/2016 08:42 PM, Michal Hocko wrote:
>>>>>>>> no, it don't work for many special case
>>>>>>>> for example, provided  PMD_SIZE=2M
>>>>>>>> mapping [0x1f8800, 0x208800) virtual range will be split to two ranges
>>>>>>>> [0x1f8800, 0x200000) and [0x200000,0x208800) and map them separately
>>>>>>>> the first range will cause dead loop
>>>>>>>
>>>>>>> I am not sure I see your point. How can we deadlock if _both_ addresses
>>>>>>> get aligned to the page boundary and how does PMD_SIZE make any
>>>>>>> difference.
>>>>>>>
>>>>>> i will take a example to illustrate my considerations
>>>>>> provided PUD_SIZE == 1G, PMD_SIZE == 2M, PAGE_SIZE == 4K
>>>>>> it is used by arm64 normally
>>>>>>
>>>>>> we want to map virtual range [0xffffffff_ffc08800, 0xffffffff_fffff800) by
>>>>>> ioremap_page_range(),ioremap_pmd_range() is called to map the range
>>>>>> finally, ioremap_pmd_range() will call
>>>>>> ioremap_pte_range(pmd, 0xffffffff_ffc08800, 0xffffffff_fffe0000) and
>>>>>> ioremap_pte_range(pmd, 0xffffffff_fffe0000, 0xffffffff fffff800) separately
>>>>>
>>>>> but those ranges are not aligned and it ioremap_page_range fix them up
>>>>> to _be_ aligned then there is no problem, right? So either I am missing
>>>>> something or we are talking past each other.
>>>>>
>>>> my complementary considerations are show below
>>>>
>>>> why not to round up the range start boundary to page aligned?
>>>> 1, it don't remain consistent with the original logic
>>>>    take map [0x1800, 0x4800) as example
>>>>    the original logic map range [0x1000, 0x2000), but rounding up start boundary
>>>>    don't mapping the range [0x1000, 0x2000)
>>>
>>> just look at how we do that for the mmap...
>>
>> okay
>> i don't familiar with mmap code very well now
> 
> mmap basically does addr &= PAGE_MASK (modulo mmap_min_addr) and
> len = PAGE_ALIGN(len).
> 
> this is [star, end) raher than [start, start+len) but you should get the
> point I guess.
> 
you are right
this patch is consistent with that you pointed

for map virtual range [0x80000800, 0x80007800) to physical area[0x20000800, 0x20007800)
it actually map range [0x80000000, 0x80008000) to physical area[0x20000000, 0x20008000)

maybe expanding range [0x80000800, 0x80007800) to [0x80000000, 0x80008000) is better than
shrinking to [0x80001000, 0x80007000) because the following reasons

1. if a user is mapping [0x80000800, 0x80007800) -> [0x20000800, 0x20007800), he/she expect to
access physical address 0x20000800 by virtual address 0x80000800, expanding range do the right
thing but shrinking will cause address fault

2. shrinking will cause not enough virtual range [0x80001000, 0x80007000) to mapping physical
area [0x20000800, 0x20007800)

3. this is no need to round up parameter end to page boundary to expand the end limit, it has less
modification for code

BTW
there are many page table operations to using this similar logic, maybe a universal fixing is used
to all, not just lib/ioremap.c or mm/vmalloc.c


 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
