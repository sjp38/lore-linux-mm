Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 93B956B0266
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 10:39:26 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id x84so22069714oix.7
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 07:39:26 -0800 (PST)
Received: from mail-ot0-x22e.google.com (mail-ot0-x22e.google.com. [2607:f8b0:4003:c0f::22e])
        by mx.google.com with ESMTPS id e7si230749oig.172.2017.01.18.07.39.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 07:39:25 -0800 (PST)
Received: by mail-ot0-x22e.google.com with SMTP id 65so11314523otq.2
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 07:39:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <587F6D2A.1060602@huawei.com>
References: <1484573885-54353-1-git-send-email-zhongjiang@huawei.com>
 <20170117102532.GH19699@dhcp22.suse.cz> <587E22F2.7060809@huawei.com>
 <CAPcyv4j75n6LzrW=j+ehtGBksj_F32RAE4uLQna3wp4y-MOSKw@mail.gmail.com> <587F6D2A.1060602@huawei.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 18 Jan 2017 07:39:25 -0800
Message-ID: <CAPcyv4g-kk+mtz_7GUFB6FXJY2pVvtRPEmQiF2upDVYH0r+BEw@mail.gmail.com>
Subject: Re: [PATCH] mm: respect pre-allocated storage mapping for memmap
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>

On Wed, Jan 18, 2017 at 5:27 AM, zhong jiang <zhongjiang@huawei.com> wrote:
> On 2017/1/18 1:15, Dan Williams wrote:
>> On Tue, Jan 17, 2017 at 5:58 AM, zhong jiang <zhongjiang@huawei.com> wrote:
>>> On 2017/1/17 18:25, Michal Hocko wrote:
>>>> On Mon 16-01-17 21:38:05, zhongjiang wrote:
>>>>> From: zhong jiang <zhongjiang@huawei.com>
>>>>>
>>>>> At present, we skip the reservation storage by the driver for
>>>>> the zone_dvice. but the free pages set aside for the memmap is
>>>>> ignored. And since the free pages is only used as the memmap,
>>>>> so we can also skip the corresponding pages.
>>>> I have really hard time to understand what this patch does and why it
>>>> matters.  Could you please rephrase the changelog to state, the problem,
>>>> how it affects users and what is the fix please?
>>>>
>>>   Hi, Michal
>>>
>>>   The patch maybe incorrect if free pages for memmap mapping is accouted for zone_device.
>>>   I am just a little confusing about the implement.  it maybe simple and  stupid.
>> The patch is incorrect, the struct page initialization starts
>> immediately after altmap->reserve.
>>
>>>   first pfn for dev_mappage come from vmem_altmap_offset, and free pages reserved for
>>>   memmap mapping need to be accounted. I do not know the meaning.
>>>
>>>   Another issue is in sparse_remove_one_section.  A section belongs to  zone_device is not
>>>   always need to consider the  map_offset. is it right ?  From pfn_first to end , that section
>>>   should no need to consider the map_offet.
>> No that's not right. devm_memremap_pages() will specify the full
>> physical address range that was initially hotplugged. At removal time
>> the first page of the memmap starts at pfn_to_page(phys_start_pfn +
>> map_offset).
>>
>> However, I always need to remind myself of these rules every time I
>> read the code, so the documentation needs improvement.
>>
>> .
>>
> Addtional, if we just offline some of sectiones of dev_mappage. That will have question.
> Therefore,  we must offline the whole dev_mappages page that belongs to zone_device.
>
> is it right?  please
>

We never online ZONE_DEVICE memory so consequently it can never be
offlined. The only way to access the pages is via get_user_pages() of
a DAX mapping.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
