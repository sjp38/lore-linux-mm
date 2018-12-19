Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id F12328E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 13:41:45 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id t143so7462273itc.9
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 10:41:45 -0800 (PST)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id j20si3263322itk.110.2018.12.19.10.41.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 10:41:44 -0800 (PST)
Subject: Re: [RFC PATCH 1/2] mm: swap: check if swap backing device is
 congested or not
References: <1545115948-25467-1-git-send-email-yang.shi@linux.alibaba.com>
 <6a51d47a-b87f-b0f1-4dae-843730dba698@linux.intel.com>
 <03462367-3f75-4907-8c5e-526a919e5cf3@linux.alibaba.com>
 <c0290c77-87ba-32bf-8ed0-d42a322d3d06@linux.intel.com>
 <606b73ed-da62-fdd1-71da-c4de7a02e837@linux.alibaba.com>
 <bc63155c-39b4-02b0-4045-da51022dbff5@linux.intel.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <2df52dc3-ae66-0ab8-459e-49f49eaa569c@linux.alibaba.com>
Date: Wed, 19 Dec 2018 10:40:16 -0800
MIME-Version: 1.0
In-Reply-To: <bc63155c-39b4-02b0-4045-da51022dbff5@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>, ying.huang@intel.com, tim.c.chen@intel.com, minchan@kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 12/19/18 9:28 AM, Tim Chen wrote:
> On 12/18/18 9:56 PM, Yang Shi wrote:
>>
>> On 12/18/18 4:16 PM, Tim Chen wrote:
>>> On 12/18/18 3:43 PM, Yang Shi wrote:
>>>> On 12/18/18 11:29 AM, Tim Chen wrote:
>>>>> On 12/17/18 10:52 PM, Yang Shi wrote:
>>>>>
>>>>>> diff --git a/mm/swap_state.c b/mm/swap_state.c
>>>>>> index fd2f21e..7cc3c29 100644
>>>>>> --- a/mm/swap_state.c
>>>>>> +++ b/mm/swap_state.c
>>>>>> @@ -538,11 +538,15 @@ struct page *swap_cluster_readahead(swp_entry_t entry, gfp_t gfp_mask,
>>>>>>         bool do_poll = true, page_allocated;
>>>>>>         struct vm_area_struct *vma = vmf->vma;
>>>>>>         unsigned long addr = vmf->address;
>>>>>> +    struct inode *inode = si->swap_file->f_mapping->host;
>>>>>>           mask = swapin_nr_pages(offset) - 1;
>>>>>>         if (!mask)
>>>>>>             goto skip;
>>>>>>     
>>>>> Shmem will also be using this function and I don't think the inode_read_congested
>>>>> logic is relevant for that case.
>>>> IMHO, shmem is also relevant. As long as it is trying to readahead from swap, it should check if the underlying device is busy or not regardless of shmem or anon page.
>>>>
>>> I don't think your dereference inode = si->swap_file->f_mapping->host
>>> is always safe.  You should do it only when (si->flags & SWP_FS) is true.
>> Do you mean it is not safe for swap partition?
> The f_mapping may not be instantiated.  It is only done for SWP_FS.

Really? I saw the below calls in swapon:

swap_file = file_open_name(name, O_RDWR|O_LARGEFILE, 0);
...
p->swap_file = swap_file;
mapping = swap_file->f_mapping;
inode = mapping->host;
...

Then the below code manipulates the inode.

And, trace shows file_open_name() does call blkdev_open if it is turning 
block device swap on. And, blkdev_open() would return instantiated 
address_space and inode.

Am I missing something?

Thanks,
Yang

>
> Tim
>
