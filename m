Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1154428024B
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 10:15:02 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id mi5so205488482pab.2
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 07:15:02 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id hr2si8135265pad.51.2016.09.23.07.15.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 23 Sep 2016 07:15:01 -0700 (PDT)
Subject: Re: [PATCH 1/1] lib/ioremap.c: avoid endless loop under ioremapping
 page unaligned ranges
References: <57E20A69.5010206@zoho.com>
 <20160922124735.GB11204@dhcp22.suse.cz>
 <35661a34-c3e0-0ec2-b58f-ee59bef4e4d4@zoho.com>
 <20160923084551.GG4478@dhcp22.suse.cz>
 <f9e708e1-121e-367e-1141-5470e5baffe5@zoho.com>
 <20160923124244.GN4478@dhcp22.suse.cz> <57E52762.9000702@zoho.com>
 <20160923133330.GO4478@dhcp22.suse.cz>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <d7408c4e-6fe1-f51c-0388-8636f4761ccd@zoho.com>
Date: Fri, 23 Sep 2016 22:14:40 +0800
MIME-Version: 1.0
In-Reply-To: <20160923133330.GO4478@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, tj@kernel.org, mingo@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

On 2016/9/23 21:33, Michal Hocko wrote:
> On Fri 23-09-16 21:00:18, zijun_hu wrote:
>> On 09/23/2016 08:42 PM, Michal Hocko wrote:
>>>>>> no, it don't work for many special case
>>>>>> for example, provided  PMD_SIZE=2M
>>>>>> mapping [0x1f8800, 0x208800) virtual range will be split to two ranges
>>>>>> [0x1f8800, 0x200000) and [0x200000,0x208800) and map them separately
>>>>>> the first range will cause dead loop
>>>>>
>>>>> I am not sure I see your point. How can we deadlock if _both_ addresses
>>>>> get aligned to the page boundary and how does PMD_SIZE make any
>>>>> difference.
>>>>>
>>>> i will take a example to illustrate my considerations
>>>> provided PUD_SIZE == 1G, PMD_SIZE == 2M, PAGE_SIZE == 4K
>>>> it is used by arm64 normally
>>>>
>>>> we want to map virtual range [0xffffffff_ffc08800, 0xffffffff_fffff800) by
>>>> ioremap_page_range(),ioremap_pmd_range() is called to map the range
>>>> finally, ioremap_pmd_range() will call
>>>> ioremap_pte_range(pmd, 0xffffffff_ffc08800, 0xffffffff_fffe0000) and
>>>> ioremap_pte_range(pmd, 0xffffffff_fffe0000, 0xffffffff fffff800) separately
>>>
>>> but those ranges are not aligned and it ioremap_page_range fix them up
>>> to _be_ aligned then there is no problem, right? So either I am missing
>>> something or we are talking past each other.
>>>
>> my complementary considerations are show below
>>
>> why not to round up the range start boundary to page aligned?
>> 1, it don't remain consistent with the original logic
>>    take map [0x1800, 0x4800) as example
>>    the original logic map range [0x1000, 0x2000), but rounding up start boundary
>>    don't mapping the range [0x1000, 0x2000)
> 
> just look at how we do that for the mmap...
okay
i don't familiar with mmap code very well now
it is okay to roundup start boundary to page aligned in order to keep consistent with Mmap code
if insane start boundary overflow is considered
> 
>> 2, the rounding up start boundary maybe cause overflow, consider start boundary =
>>    0xffffffff_fffff800  
> 
> this is just insane
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
