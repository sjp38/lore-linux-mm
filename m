Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0BB6C8E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 13:53:37 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id t10so4659297plo.13
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 10:53:37 -0800 (PST)
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id l8si572878pfc.98.2018.12.21.10.53.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Dec 2018 10:53:35 -0800 (PST)
Subject: Re: [v2 PATCH 1/2] mm: swap: check if swap backing device is
 congested or not
References: <1545351679-23596-1-git-send-email-yang.shi@linux.alibaba.com>
 <c3c77f08-f7af-7633-636d-c467759fbf20@linux.intel.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <6878473d-3d3a-bbab-e187-f618c17db044@linux.alibaba.com>
Date: Fri, 21 Dec 2018 10:51:11 -0800
MIME-Version: 1.0
In-Reply-To: <c3c77f08-f7af-7633-636d-c467759fbf20@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>, ying.huang@intel.com, tim.c.chen@intel.com, minchan@kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 12/21/18 10:34 AM, Tim Chen wrote:
> On 12/20/18 4:21 PM, Yang Shi wrote:
>
>> --- a/mm/swap_state.c
>> +++ b/mm/swap_state.c
>> @@ -538,11 +538,17 @@ struct page *swap_cluster_readahead(swp_entry_t entry, gfp_t gfp_mask,
>>   	bool do_poll = true, page_allocated;
>>   	struct vm_area_struct *vma = vmf->vma;
>>   	unsigned long addr = vmf->address;
>> +	struct inode *inode = si->swap_file->f_mapping->host;
>>   
>>   	mask = swapin_nr_pages(offset) - 1;
>>   	if (!mask)
>>   		goto skip;
>>   
>> +	if (si->flags & (SWP_BLKDEV | SWP_FS)) {
> Maybe move the inode dereference here:
>
> 		inode = si->swap_file->f_mapping->host;

Yes, it looks better since nobody deference inode except the below code. 
Will fix in v3.

Thanks,
Yang

>
>> +		if (inode_read_congested(inode))
>> +			goto skip;
>> +	}
>> +
> Thanks.
>
> Tim
