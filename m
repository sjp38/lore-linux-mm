Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 92E328E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 18:43:26 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id n17so16592040pfk.23
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 15:43:26 -0800 (PST)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id o21si12934560pgj.415.2018.12.18.15.43.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 15:43:25 -0800 (PST)
Subject: Re: [RFC PATCH 1/2] mm: swap: check if swap backing device is
 congested or not
References: <1545115948-25467-1-git-send-email-yang.shi@linux.alibaba.com>
 <6a51d47a-b87f-b0f1-4dae-843730dba698@linux.intel.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <03462367-3f75-4907-8c5e-526a919e5cf3@linux.alibaba.com>
Date: Tue, 18 Dec 2018 15:43:07 -0800
MIME-Version: 1.0
In-Reply-To: <6a51d47a-b87f-b0f1-4dae-843730dba698@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>, ying.huang@intel.com, tim.c.chen@intel.com, minchan@kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 12/18/18 11:29 AM, Tim Chen wrote:
> On 12/17/18 10:52 PM, Yang Shi wrote:
>
>> diff --git a/mm/swap_state.c b/mm/swap_state.c
>> index fd2f21e..7cc3c29 100644
>> --- a/mm/swap_state.c
>> +++ b/mm/swap_state.c
>> @@ -538,11 +538,15 @@ struct page *swap_cluster_readahead(swp_entry_t entry, gfp_t gfp_mask,
>>   	bool do_poll = true, page_allocated;
>>   	struct vm_area_struct *vma = vmf->vma;
>>   	unsigned long addr = vmf->address;
>> +	struct inode *inode = si->swap_file->f_mapping->host;
>>   
>>   	mask = swapin_nr_pages(offset) - 1;
>>   	if (!mask)
>>   		goto skip;
>>   
> Shmem will also be using this function and I don't think the inode_read_congested
> logic is relevant for that case.

IMHO, shmem is also relevant. As long as it is trying to readahead from 
swap, it should check if the underlying device is busy or not regardless 
of shmem or anon page.

Just like mem_cgroup_try_charge_delay(), which throttles swap rate for 
both swap page fault and shmem.

Thanks,
Yang

>
> So probably change the check to
>
> 	if (swp_type(entry) < nr_swapfiles &&
> 	    inode_read_congested(si->swap_file->f_mapping->host))
> 		goto skip;
> 		
>> +	if (inode_read_congested(inode))
>> +		goto skip;
>> +
>>   	do_poll = false;
>>   	/* Read a page_cluster sized and aligned cluster around offset. */
>>   	start_offset = offset & ~mask;
>>
> Thanks.
>
> Tim
