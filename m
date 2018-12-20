Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 546058E0004
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 20:05:59 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id bj3so48715plb.17
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 17:05:59 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id f5si6376597pfn.259.2018.12.19.17.05.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 17:05:56 -0800 (PST)
References: <1545115948-25467-1-git-send-email-yang.shi@linux.alibaba.com>
 <6a51d47a-b87f-b0f1-4dae-843730dba698@linux.intel.com>
 <03462367-3f75-4907-8c5e-526a919e5cf3@linux.alibaba.com>
 <c0290c77-87ba-32bf-8ed0-d42a322d3d06@linux.intel.com>
 <606b73ed-da62-fdd1-71da-c4de7a02e837@linux.alibaba.com>
 <bc63155c-39b4-02b0-4045-da51022dbff5@linux.intel.com>
 <2df52dc3-ae66-0ab8-459e-49f49eaa569c@linux.alibaba.com>
 <50e14a30-97bb-06c6-ae6a-74e6dc827713@linux.intel.com>
 <385ffd4f-d903-6e2f-e80e-7d3797885c54@linux.alibaba.com>
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [RFC PATCH 1/2] mm: swap: check if swap backing device is
 congested or not
Message-ID: <ed458728-23ad-3cb1-6308-2e9679863e3c@linux.intel.com>
Date: Wed, 19 Dec 2018 17:05:54 -0800
MIME-Version: 1.0
In-Reply-To: <385ffd4f-d903-6e2f-e80e-7d3797885c54@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>, ying.huang@intel.com, tim.c.chen@intel.com, minchan@kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/19/18 3:48 PM, Yang Shi wrote:
> 
> 
> On 12/19/18 11:00 AM, Tim Chen wrote:
>> On 12/19/18 10:40 AM, Yang Shi wrote:
>>>
>>>>>> I don't think your dereference inode = si->swap_file->f_mapping->host
>>>>>> is always safe.  You should do it only when (si->flags & SWP_FS) is true.
>>>>> Do you mean it is not safe for swap partition?
>>>> The f_mapping may not be instantiated.  It is only done for SWP_FS.
>>> Really? I saw the below calls in swapon:
>>>
>>> swap_file = file_open_name(name, O_RDWR|O_LARGEFILE, 0);
>>> ...
>>> p->swap_file = swap_file;
>>> mapping = swap_file->f_mapping;
>>> inode = mapping->host;
>>> ...
>>>
>>> Then the below code manipulates the inode.
>>>
>>> And, trace shows file_open_name() does call blkdev_open if it is turning block device swap on. And, blkdev_open() would return instantiated address_space and inode.
>>>
>>> Am I missing something?
>>>
>> I was trying to limit the congestion logic for block devices backed swap.
>> So the check I had in mind should really be "si->flags & SWP_BLKDEV"
>> instead of si->flags & SWP_FS.  I was concerned that there could
>> be other use cases where the inode dereference is invalid.
>>
>> Looking at the code a bit more, looks like swap_cluster_readahead is not
>> used for other special case swap usage (like page migration).  So
>> you would a proper swapfile and inode here.  But I think it is still
> 
> Yes, just swap page fault and shmem calls this function. Actually, your above concern is valid if the inode were added into swap_address_space (address_space->host). I did this in my first attempt, and found out it may break some assumption in clear_page_dirty_for_io() and migration.
> 
> So, I made the patch as it is.
> 
>> a good idea to have a check for SWP_BLKDEV in si->flags.
> 
> I don't get your point why it should be block dev swap only. IMHO, block dev swap should be less likely fragmented and congested than swap file, right? Block dev swap could be a dedicated physical device, but swap file has to be with filesystem.
> 
> It sounds reasonable to me to have this check for swap file only. However, to be honest, it sounds not hurt to have both.
> 

Yes, I think we want to do it for both cases.

My original concern was that the backing store was not sitting on
a block device for some special case swap usage.  And si->swap_file->f_mapping->host
may fails to dereference to a host inode that's a valid block device.

It looks like on the call paths si->flags should either be SWP_BLKDEV or SWP_FS
on all the call paths. So si->swap_file->f_mapping->host should be valid
and your code is safe.

If we want to be paranoid we may do

	if (si->flags & (SWP_BLKDEV | SWP_FS)) {
		if (inode_read_congested(si->swap_file->f_mapping->host))
			goto skip;
	}

Thanks.

Tim
