Date: Fri, 18 May 2007 10:23:05 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 5/5] Mark page cache pages as __GFP_PAGECACHE instead of
 __GFP_MOVABLE
In-Reply-To: <20070517123854.6cea6338.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0705181012090.17783@skynet.skynet.ie>
References: <20070517101022.3113.15456.sendpatchset@skynet.skynet.ie>
 <20070517101203.3113.81852.sendpatchset@skynet.skynet.ie>
 <20070517123854.6cea6338.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 17 May 2007, Andrew Morton wrote:

> On Thu, 17 May 2007 11:12:03 +0100 (IST)
> Mel Gorman <mel@csn.ul.ie> wrote:
>
>> --- linux-2.6.22-rc1-mm1-025_gfphighuser/fs/buffer.c	2007-05-16 22:55:50.000000000 +0100
>> +++ linux-2.6.22-rc1-mm1-030_pagecache_mark/fs/buffer.c	2007-05-16 23:07:30.000000000 +0100
>> @@ -1009,7 +1009,7 @@ grow_dev_page(struct block_device *bdev,
>>  	struct buffer_head *bh;
>>
>>  	page = find_or_create_page(inode->i_mapping, index,
>> -					GFP_NOFS|__GFP_RECLAIMABLE);
>> +					GFP_NOFS_PAGECACHE);
>>  	if (!page)
>>  		return NULL;
>>
>
> I ended up with
>
>        page = find_or_create_page(inode->i_mapping, index,
>                (mapping_gfp_mask(inode->i_mapping) & ~__GFP_FS)|__GFP_MOVABLE);
>
> here.
>

That looks like it'll work fine with respects to grouping by mobility but 
there is a slight functional difference worth noting. Specifically, the 
old code did not obey cpuset limits because __GFP_HARDWALL was not set. 
This change gets it's GFP mask from bdget() calling mapping_set_gfp_mask() 
which is GFP_USER and so will obey CPUSET limits. This new version looks 
more correct.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
