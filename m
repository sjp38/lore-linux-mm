Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6C8DC6B0279
	for <linux-mm@kvack.org>; Thu, 25 May 2017 02:12:17 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y106so18931383wrb.14
        for <linux-mm@kvack.org>; Wed, 24 May 2017 23:12:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m14si30174826edm.151.2017.05.24.23.12.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 May 2017 23:12:15 -0700 (PDT)
Subject: Re: [Question] Mlocked count will not be decreased
References: <a61701d8-3dce-51a2-5eaf-14de84425640@huawei.com>
 <85591559-2a99-f46b-7a5a-bc7affb53285@huawei.com>
 <93f1b063-6288-d109-117d-d3c1cf152a8e@suse.cz> <5925709F.1030105@huawei.com>
 <d354b321-0d11-4308-0b0e-aacef5a5e34b@suse.cz> <5925784E.802@huawei.com>
 <b41f2c9a-7e74-529f-2ec1-3d9ae369dcb5@suse.cz> <5926306F.2060205@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0fe03b7b-232e-5e90-b016-7b9b38f27e10@suse.cz>
Date: Thu, 25 May 2017 08:12:14 +0200
MIME-Version: 1.0
In-Reply-To: <5926306F.2060205@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, Kefeng Wang <wangkefeng.wang@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zhongjiang <zhongjiang@huawei.com>

On 05/25/2017 03:16 AM, Xishi Qiu wrote:
> On 2017/5/24 21:16, Vlastimil Babka wrote:
>>>>
>>>> I agree about yisheng's fix (but v2 didn't address my comments). I don't
>>>> think we should add the hunk below, as that deviates from the rest of
>>>> the design.
>>>
>>> Hi Vlastimil,
>>>
>>> The rest of the design is that mlock should always success here, right?
>>
>> The rest of the design allows a temporary disconnect between mlocked
>> flag and being placed on unevictable lru.
>>
>>> If we don't handle the fail case, the page will be in anon/file lru list
>>> later when call __pagevec_lru_add(), but NR_MLOCK increased,
>>> this is wrong, right?
>>
>> It's not wrong, the page cannot get evicted even if on wrong lru, so
>> effectively it's already mlocked. We would be underaccounting NR_MLOCK.
>>
> 
> Hi Vlastimil,
> 
> I'm not quite understand why the page cannot get evicted even if on wrong lru.
> __isolate_lru_page() will only skip PageUnevictable(page), but this flag has not
> been set, we only set PageMlocked.

The isolated page has to be unmapped from all vma's that map it. See
try_to_unmap_one() and this check:

                if (!(flags & TTU_IGNORE_MLOCK)) {
                        if (vma->vm_flags & VM_LOCKED) {
				...
				ret = false;

This VM_LOCKED is what actually controls if page is evictable. The rest
is optimization (separate lru list so we don't scan the pages in reclaim
if they can't be evicted anyway), and accounting (PageMlocked flag pages
counted as NR_MLOCK). That's why temporary inconsistency isn't a problem.


> Thanks,
> Xishi Qiu
> 
>>> Thanks,
>>> Xishi Qiu
>>>
>>>>
>>>> Thanks,
>>>> Vlastimil
>>>>
>>>>> diff --git a/mm/mlock.c b/mm/mlock.c
>>>>> index 3d3ee6c..ca2aeb9 100644
>>>>> --- a/mm/mlock.c
>>>>> +++ b/mm/mlock.c
>>>>> @@ -88,6 +88,11 @@ void mlock_vma_page(struct page *page)
>>>>>  		count_vm_event(UNEVICTABLE_PGMLOCKED);
>>>>>  		if (!isolate_lru_page(page))
>>>>>  			putback_lru_page(page);
>>>>> +		else {
>>>>> +			ClearPageMlocked(page);
>>>>> +			mod_zone_page_state(page_zone(page), NR_MLOCK,
>>>>> +					-hpage_nr_pages(page));
>>>>> +		}
>>>>>  	}
>>>>>  }
>>>>>
>>>>> Thanks,
>>>>> Xishi Qiu
>>>>>
>>>>
>>>>
>>>> .
>>>>
>>>
>>>
>>>
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>>
>>
>>
>> .
>>
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
