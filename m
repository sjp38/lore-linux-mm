Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 74C4B8E0095
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 10:24:44 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id o17so10027950pgi.14
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 07:24:44 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b14si13326039plk.333.2018.12.11.07.24.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 07:24:43 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBBFDioI130587
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 10:24:42 -0500
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2padq7f544-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 10:24:10 -0500
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zaslonko@linux.bm.com>;
	Tue, 11 Dec 2018 15:23:15 -0000
Subject: Re: [PATCH 1/1] mm, memory_hotplug: Initialize struct pages for the
 full memory section
References: <20181210130712.30148-1-zaslonko@linux.ibm.com>
 <20181210130712.30148-2-zaslonko@linux.ibm.com>
 <20181210151005.xukiibwbb6ohqyex@master>
 <e515a37e-7510-12f3-d029-99ac147d93c6@linux.bm.com>
 <20181211015011.bcbugtm2v6j3ncpc@master>
From: Zaslonko Mikhail <zaslonko@linux.bm.com>
Date: Tue, 11 Dec 2018 16:23:05 +0100
MIME-Version: 1.0
In-Reply-To: <20181211015011.bcbugtm2v6j3ncpc@master>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <3dbbb746-d4b4-ea17-643a-5d63d4f7e239@linux.bm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Mikhail Zaslonko <zaslonko@linux.ibm.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, Pavel.Tatashin@microsoft.com, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com

Hello,

On 11.12.2018 02:50, Wei Yang wrote:
> On Mon, Dec 10, 2018 at 05:14:36PM +0100, Zaslonko Mikhail wrote:
>> Hello,
>>
>> On 10.12.2018 16:10, Wei Yang wrote:
>>> On Mon, Dec 10, 2018 at 02:07:12PM +0100, Mikhail Zaslonko wrote:
>>>> If memory end is not aligned with the sparse memory section boundary, the
>>>> mapping of such a section is only partly initialized. This may lead to
>>>> VM_BUG_ON due to uninitialized struct page access from
>>>> is_mem_section_removable() or test_pages_in_a_zone() function triggered by
>>>> memory_hotplug sysfs handlers:
>>>>
>>>> page:000003d082008000 is uninitialized and poisoned
>>>> page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
>>>> Call Trace:
>>>> ([<0000000000385b26>] test_pages_in_a_zone+0xde/0x160)
>>>>  [<00000000008f15c4>] show_valid_zones+0x5c/0x190
>>>>  [<00000000008cf9c4>] dev_attr_show+0x34/0x70
>>>>  [<0000000000463ad0>] sysfs_kf_seq_show+0xc8/0x148
>>>>  [<00000000003e4194>] seq_read+0x204/0x480
>>>>  [<00000000003b53ea>] __vfs_read+0x32/0x178
>>>>  [<00000000003b55b2>] vfs_read+0x82/0x138
>>>>  [<00000000003b5be2>] ksys_read+0x5a/0xb0
>>>>  [<0000000000b86ba0>] system_call+0xdc/0x2d8
>>>> Last Breaking-Event-Address:
>>>>  [<0000000000385b26>] test_pages_in_a_zone+0xde/0x160
>>>> Kernel panic - not syncing: Fatal exception: panic_on_oops
>>>>
>>>> Fix the problem by initializing the last memory section of the highest zone
>>>> in memmap_init_zone() till the very end, even if it goes beyond the zone
>>>> end.
>>>>
>>>> Signed-off-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
>>>> Reviewed-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
>>>> Cc: <stable@vger.kernel.org>
>>>> ---
>>>> mm/page_alloc.c | 15 +++++++++++++++
>>>> 1 file changed, 15 insertions(+)
>>>>
>>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>>> index 2ec9cc407216..41ef5508e5f1 100644
>>>> --- a/mm/page_alloc.c
>>>> +++ b/mm/page_alloc.c
>>>> @@ -5542,6 +5542,21 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>>>> 			cond_resched();
>>>> 		}
>>>> 	}
>>>> +#ifdef CONFIG_SPARSEMEM
>>>> +	/*
>>>> +	 * If there is no zone spanning the rest of the section
>>>> +	 * then we should at least initialize those pages. Otherwise we
>>>> +	 * could blow up on a poisoned page in some paths which depend
>>>> +	 * on full sections being initialized (e.g. memory hotplug).
>>>> +	 */
>>>> +	if (end_pfn == max_pfn) {
>>>> +		while (end_pfn % PAGES_PER_SECTION) {
>>>> +			__init_single_page(pfn_to_page(end_pfn), end_pfn, zone,
>>>> +					   nid);
>>>> +			end_pfn++;
>>>> +		}
>>>> +	}
>>>> +#endif
>>>
>>> If my understanding is correct, end_pfn is not a valid range.
>>>
>>> memmap_init_zone() initialize the range [start_pfn, start_pfn + size). I
>>> am afraid this will break the syntax. 
>>>
>>> And max_pfn is also not a valid one. For example, on x86,
>> I used pfn_max here to check for the highest zone. What would be a better way? 
>>
>>> update_end_of_memory_vars() will update max_pfn, which is calculated by:
>>>
>>>     end_pfn = PFN_UP(start + size);
>>>
>>> BTW, as you mentioned this apply to hotplug case. And then why this couldn't
>>> happen during boot up? What differ these two cases?
>>
>> Well, the pages left uninitialized during bootup (initial problem), but the panic itself takes 
>> place when we try to process memory_hotplug sysfs attributes (thus triggering sysfs handlers). 
>> You can find more details in the original thread:
>> https://marc.info/?t=153658306400001&r=1&w=2
>>
> 
> Thanks.
> 
> I took a look into the original thread and try to reproduce this on x86.
> 
> My step is:
> 
>   1. config page_poisoning
>   2. use kernel parameter mem=3075M
>   3. cat the last memory block device sysfs file removable
>      eg. when mem is 3075, cat memory9/removable
> 
> I don't see the Call trace. Do I miss something to reproduce it?
> 

No you don't. I guess there might be deviations depending on the architecture (I am on s390).
As I understand, memory block size is 384 Mb on your system and memory9 is the last block on the list?
BTW, do you have CONFIG_DEBUG_VM and CONFIG_DEBUG_VM_PGFLAGS on? 


>>>
>>>> }
>>>>
>>>> #ifdef CONFIG_ZONE_DEVICE
>>>> -- 
>>>> 2.16.4
>>>
>>
>> Thanks,
>> Mikhail Zaslonko
> 
