Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 197FF8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 19:59:05 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id p21so11759166iog.0
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 16:59:05 -0800 (PST)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id t82si11262294jad.2.2019.01.10.16.59.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 16:59:04 -0800 (PST)
Subject: Re: [v5 PATCH 1/2] mm: swap: check if swap backing device is
 congested or not
References: <1546543673-108536-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190110153147.1baf4c88bf0dd3b8a78aad08@linux-foundation.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <bbc7bda7-62d0-df1a-23ef-d369e865bdca@linux.alibaba.com>
Date: Thu, 10 Jan 2019 16:56:29 -0800
MIME-Version: 1.0
In-Reply-To: <20190110153147.1baf4c88bf0dd3b8a78aad08@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: ying.huang@intel.com, tim.c.chen@intel.com, minchan@kernel.org, daniel.m.jordan@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 1/10/19 3:31 PM, Andrew Morton wrote:
> On Fri,  4 Jan 2019 03:27:52 +0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
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
>> ...
>>
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
> I re-read your discussion with Tim and I must say the reasoning behind
> this test remain foggy.
>
> What goes wrong if we just remove it?

I saw Tim already answered this.

>
> What is the status of shmem swap readahead?

shmem swap readahead will be skipped too if the underlying device is 
congested.

>
> Can we at least get a comment in here which explains the reasoning?

How about like this:

diff --git a/mm/swap_state.c b/mm/swap_state.c
index 3f63bb7..85245fd 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -543,7 +543,8 @@ struct page *swap_cluster_readahead(swp_entry_t 
entry, gfp_t gfp_mask,
         if (!mask)
                 goto skip;

-       if (si->flags & (SWP_BLKDEV | SWP_FS)) {
+       /* Test swap type to make sure the dereference is safe */
+       if (likely(si->flags & (SWP_BLKDEV | SWP_FS))) {
                 struct inode *inode = si->swap_file->f_mapping->host;
                 if (inode_read_congested(inode))
                         goto skip;

Tim is worried about the deference might be not safe for some corner 
case, the corner cases sound unlikely by code inspection. So, added 
"likely" in the if statement.

Thanks,
Yang

>
> Thanks.
>
>> +		inode = si->swap_file->f_mapping->host;
>> +		if (inode_read_congested(inode))
>> +			goto skip;
>> +	}
>> +
>>   	do_poll = false;
>>   	/* Read a page_cluster sized and aligned cluster around offset. */
