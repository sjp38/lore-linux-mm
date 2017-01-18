Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5DD466B0260
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 05:10:07 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id 104so4515734otd.0
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 02:10:07 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id q9si1916480oif.317.2017.01.18.02.10.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 02:10:06 -0800 (PST)
Message-ID: <587F3EEF.1030100@huawei.com>
Date: Wed, 18 Jan 2017 18:09:51 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: respect pre-allocated storage mapping for memmap
References: <1484573885-54353-1-git-send-email-zhongjiang@huawei.com> <20170117102532.GH19699@dhcp22.suse.cz> <587E22F2.7060809@huawei.com> <CAPcyv4j75n6LzrW=j+ehtGBksj_F32RAE4uLQna3wp4y-MOSKw@mail.gmail.com>
In-Reply-To: <CAPcyv4j75n6LzrW=j+ehtGBksj_F32RAE4uLQna3wp4y-MOSKw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>

On 2017/1/18 1:15, Dan Williams wrote:
> On Tue, Jan 17, 2017 at 5:58 AM, zhong jiang <zhongjiang@huawei.com> wrote:
>> On 2017/1/17 18:25, Michal Hocko wrote:
>>> On Mon 16-01-17 21:38:05, zhongjiang wrote:
>>>> From: zhong jiang <zhongjiang@huawei.com>
>>>>
>>>> At present, we skip the reservation storage by the driver for
>>>> the zone_dvice. but the free pages set aside for the memmap is
>>>> ignored. And since the free pages is only used as the memmap,
>>>> so we can also skip the corresponding pages.
>>> I have really hard time to understand what this patch does and why it
>>> matters.  Could you please rephrase the changelog to state, the problem,
>>> how it affects users and what is the fix please?
>>>
>>   Hi, Michal
>>
>>   The patch maybe incorrect if free pages for memmap mapping is accouted for zone_device.
>>   I am just a little confusing about the implement.  it maybe simple and  stupid.
> The patch is incorrect, the struct page initialization starts
> immediately after altmap->reserve.
>
>>   first pfn for dev_mappage come from vmem_altmap_offset, and free pages reserved for
>>   memmap mapping need to be accounted. I do not know the meaning.
>>
>>   Another issue is in sparse_remove_one_section.  A section belongs to  zone_device is not
>>   always need to consider the  map_offset. is it right ?  From pfn_first to end , that section
>>   should no need to consider the map_offet.
> No that's not right. devm_memremap_pages() will specify the full
> physical address range that was initially hotplugged. At removal time
> the first page of the memmap starts at pfn_to_page(phys_start_pfn +
> map_offset).
>
> However, I always need to remind myself of these rules every time I
> read the code, so the documentation needs improvement.
 The rules ensure that (reserve + free) need to less than one section size.
 if it is so, or we add WARNON to explicitly the limits.


 Thanks
 zhongjiang
> .
>
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
