Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8CC6D8E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 20:11:54 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id g12so5297789pll.22
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 17:11:54 -0800 (PST)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id x191si22955144pfd.220.2018.12.21.17.11.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Dec 2018 17:11:53 -0800 (PST)
Subject: Re: [v3 PATCH 1/2] mm: swap: check if swap backing device is
 congested or not
References: <1545428420-126557-1-git-send-email-yang.shi@linux.alibaba.com>
 <ead38fbf-50e4-e03c-48eb-c1666e78aeda@linux.intel.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <ea873cff-4aad-06a3-bdc1-ad011f11c7d2@linux.alibaba.com>
Date: Fri, 21 Dec 2018 17:09:07 -0800
MIME-Version: 1.0
In-Reply-To: <ead38fbf-50e4-e03c-48eb-c1666e78aeda@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>, ying.huang@intel.com, tim.c.chen@intel.com, minchan@kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 12/21/18 2:42 PM, Tim Chen wrote:
> On 12/21/18 1:40 PM, Yang Shi wrote:
>> Swap readahead would read in a few pages regardless if the underlying
>> device is busy or not.  It may incur long waiting time if the device is
>> congested, and it may also exacerbate the congestion.
>>
>> Use inode_read_congested() to check if the underlying device is busy or
>> not like what file page readahead does.  Get inode from swap_info_struct.
>> Although we can add inode information in swap_address_space
>> (address_space->host), it may lead some unexpected side effect, i.e.
>> it may break mapping_cap_account_dirty().  Using inode from
>> swap_info_struct seems simple and good enough.
>>
>> Just does the check in vma_cluster_readahead() since
>> swap_vma_readahead() is just used for non-rotational device which
>> much less likely has congestion than traditional HDD.
>>
>> Although swap slots may be consecutive on swap partition, it still may be
>> fragmented on swap file. This check would help to reduce excessive stall
>> for such case.
>>
>> Cc: Huang Ying <ying.huang@intel.com>
>> Cc: Tim Chen <tim.c.chen@intel.com>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>> ---
>> v3: Move inode deference under swap device type check per Tim Chen
>> v2: Check the swap device type per Tim Chen
>>
>>   mm/swap_state.c | 7 +++++++
>>   1 file changed, 7 insertions(+)
>>
>> diff --git a/mm/swap_state.c b/mm/swap_state.c
>> index fd2f21e..78d500e 100644
>> --- a/mm/swap_state.c
>> +++ b/mm/swap_state.c
>> @@ -538,11 +538,18 @@ struct page *swap_cluster_readahead(swp_entry_t entry, gfp_t gfp_mask,
>>   	bool do_poll = true, page_allocated;
>>   	struct vm_area_struct *vma = vmf->vma;
>>   	unsigned long addr = vmf->address;
>> +	struct inode *inode = NULL;
>>   
>>   	mask = swapin_nr_pages(offset) - 1;
>>   	if (!mask)
>>   		goto skip;
>>   
>> +	if (si->flags & (SWP_BLKDEV | SWP_FS)) {
>> +		inode = si->swap_file->f_mapping->host;
>> +		if (inode_read_congested(inode))
>> +			goto skip;
>> +	}
>> +
>>   	do_poll = false;
>>   	/* Read a page_cluster sized and aligned cluster around offset. */
>>   	start_offset = offset & ~mask;
>>
> Acked-by: Tim Chen <tim.c.chen@linux.intel.com>

Thanks. Happy holiday.
