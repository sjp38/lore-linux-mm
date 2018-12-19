Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5B4C28E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 14:00:29 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id p3so15319612plk.9
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 11:00:29 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id 26si16993336pgu.190.2018.12.19.11.00.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 11:00:28 -0800 (PST)
Subject: Re: [RFC PATCH 1/2] mm: swap: check if swap backing device is
 congested or not
References: <1545115948-25467-1-git-send-email-yang.shi@linux.alibaba.com>
 <6a51d47a-b87f-b0f1-4dae-843730dba698@linux.intel.com>
 <03462367-3f75-4907-8c5e-526a919e5cf3@linux.alibaba.com>
 <c0290c77-87ba-32bf-8ed0-d42a322d3d06@linux.intel.com>
 <606b73ed-da62-fdd1-71da-c4de7a02e837@linux.alibaba.com>
 <bc63155c-39b4-02b0-4045-da51022dbff5@linux.intel.com>
 <2df52dc3-ae66-0ab8-459e-49f49eaa569c@linux.alibaba.com>
From: Tim Chen <tim.c.chen@linux.intel.com>
Message-ID: <50e14a30-97bb-06c6-ae6a-74e6dc827713@linux.intel.com>
Date: Wed, 19 Dec 2018 11:00:27 -0800
MIME-Version: 1.0
In-Reply-To: <2df52dc3-ae66-0ab8-459e-49f49eaa569c@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>, ying.huang@intel.com, tim.c.chen@intel.com, minchan@kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/19/18 10:40 AM, Yang Shi wrote:
> 
> 

>>>> I don't think your dereference inode = si->swap_file->f_mapping->host
>>>> is always safe.  You should do it only when (si->flags & SWP_FS) is true.
>>> Do you mean it is not safe for swap partition?
>> The f_mapping may not be instantiated.  It is only done for SWP_FS.
> 
> Really? I saw the below calls in swapon:
> 
> swap_file = file_open_name(name, O_RDWR|O_LARGEFILE, 0);
> ...
> p->swap_file = swap_file;
> mapping = swap_file->f_mapping;
> inode = mapping->host;
> ...
> 
> Then the below code manipulates the inode.
> 
> And, trace shows file_open_name() does call blkdev_open if it is turning block device swap on. And, blkdev_open() would return instantiated address_space and inode.
> 
> Am I missing something?
> 

I was trying to limit the congestion logic for block devices backed swap.
So the check I had in mind should really be "si->flags & SWP_BLKDEV"
instead of si->flags & SWP_FS.  I was concerned that there could
be other use cases where the inode dereference is invalid.

Looking at the code a bit more, looks like swap_cluster_readahead is not
used for other special case swap usage (like page migration).  So
you would a proper swapfile and inode here.  But I think it is still
a good idea to have a check for SWP_BLKDEV in si->flags.

Thanks.

Tim
 
