Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id ADA2D8E0002
	for <linux-mm@kvack.org>; Sat, 15 Dec 2018 08:25:08 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c34so3950172edb.8
        for <linux-mm@kvack.org>; Sat, 15 Dec 2018 05:25:08 -0800 (PST)
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id f14si3115824edr.178.2018.12.15.05.25.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Dec 2018 05:25:06 -0800 (PST)
Subject: Re: [PATCH] squashfs: enable __GFP_FS in ->readpage to prevent hang
 in mem alloc
From: Hou Tao <houtao1@huawei.com>
References: <20181204020840.49576-1-houtao1@huawei.com>
 <4315acd7-f4b2-b11d-18d8-ab6ce63244b3@huawei.com>
 <9a6b1897-7b02-09d8-4103-d887a286dda3@huawei.com>
Message-ID: <81a996d7-ba4c-e5a0-d0ce-11951f1fd612@huawei.com>
Date: Sat, 15 Dec 2018 21:24:57 +0800
MIME-Version: 1.0
In-Reply-To: <9a6b1897-7b02-09d8-4103-d887a286dda3@huawei.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: phillip@squashfs.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

ping ?

On 2018/12/13 10:18, Hou Tao wrote:
> ping ?
> 
> On 2018/12/6 9:14, Hou Tao wrote:
>> ping ?
>>
>> On 2018/12/4 10:08, Hou Tao wrote:
>>> There is no need to disable __GFP_FS in ->readpage:
>>> * It's a read-only fs, so there will be no dirty/writeback page and
>>>   there will be no deadlock against the caller's locked page
>>> * It just allocates one page, so compaction will not be invoked
>>> * It doesn't take any inode lock, so the reclamation of inode will be fine
>>>
>>> And no __GFP_FS may lead to hang in __alloc_pages_slowpath() if a
>>> squashfs page fault occurs in the context of a memory hogger, because
>>> the hogger will not be killed due to the logic in __alloc_pages_may_oom().
>>>
>>> Signed-off-by: Hou Tao <houtao1@huawei.com>
>>> ---
>>>  fs/squashfs/file.c          |  3 ++-
>>>  fs/squashfs/file_direct.c   |  4 +++-
>>>  fs/squashfs/squashfs_fs_f.h | 25 +++++++++++++++++++++++++
>>>  3 files changed, 30 insertions(+), 2 deletions(-)
>>>  create mode 100644 fs/squashfs/squashfs_fs_f.h
>>>
>>> diff --git a/fs/squashfs/file.c b/fs/squashfs/file.c
>>> index f1c1430ae721..8603dda4a719 100644
>>> --- a/fs/squashfs/file.c
>>> +++ b/fs/squashfs/file.c
>>> @@ -51,6 +51,7 @@
>>>  #include "squashfs_fs.h"
>>>  #include "squashfs_fs_sb.h"
>>>  #include "squashfs_fs_i.h"
>>> +#include "squashfs_fs_f.h"
>>>  #include "squashfs.h"
>>>  
>>>  /*
>>> @@ -414,7 +415,7 @@ void squashfs_copy_cache(struct page *page, struct squashfs_cache_entry *buffer,
>>>  		TRACE("bytes %d, i %d, available_bytes %d\n", bytes, i, avail);
>>>  
>>>  		push_page = (i == page->index) ? page :
>>> -			grab_cache_page_nowait(page->mapping, i);
>>> +			squashfs_grab_cache_page_nowait(page->mapping, i);
>>>  
>>>  		if (!push_page)
>>>  			continue;
>>> diff --git a/fs/squashfs/file_direct.c b/fs/squashfs/file_direct.c
>>> index 80db1b86a27c..a0fdd6215348 100644
>>> --- a/fs/squashfs/file_direct.c
>>> +++ b/fs/squashfs/file_direct.c
>>> @@ -17,6 +17,7 @@
>>>  #include "squashfs_fs.h"
>>>  #include "squashfs_fs_sb.h"
>>>  #include "squashfs_fs_i.h"
>>> +#include "squashfs_fs_f.h"
>>>  #include "squashfs.h"
>>>  #include "page_actor.h"
>>>  
>>> @@ -60,7 +61,8 @@ int squashfs_readpage_block(struct page *target_page, u64 block, int bsize,
>>>  	/* Try to grab all the pages covered by the Squashfs block */
>>>  	for (missing_pages = 0, i = 0, n = start_index; i < pages; i++, n++) {
>>>  		page[i] = (n == target_page->index) ? target_page :
>>> -			grab_cache_page_nowait(target_page->mapping, n);
>>> +			squashfs_grab_cache_page_nowait(
>>> +					target_page->mapping, n);
>>>  
>>>  		if (page[i] == NULL) {
>>>  			missing_pages++;
>>> diff --git a/fs/squashfs/squashfs_fs_f.h b/fs/squashfs/squashfs_fs_f.h
>>> new file mode 100644
>>> index 000000000000..fc5fb7aeb27d
>>> --- /dev/null
>>> +++ b/fs/squashfs/squashfs_fs_f.h
>>> @@ -0,0 +1,25 @@
>>> +/* SPDX-License-Identifier: GPL-2.0 */
>>> +#ifndef SQUASHFS_FS_F
>>> +#define SQUASHFS_FS_F
>>> +
>>> +/*
>>> + * No need to use FGP_NOFS here:
>>> + * 1. It's a read-only fs, so there will be no dirty/writeback page and
>>> + *    there will be no deadlock against the caller's locked page.
>>> + * 2. It just allocates one page, so compaction will not be invoked.
>>> + * 3. It doesn't take any inode lock, so the reclamation of inode
>>> + *    will be fine.
>>> + *
>>> + * And GFP_NOFS may lead to infinite loop in __alloc_pages_slowpath() if a
>>> + * squashfs page fault occurs in the context of a memory hogger, because
>>> + * the hogger will not be killed due to the logic in __alloc_pages_may_oom().
>>> + */
>>> +static inline struct page *
>>> +squashfs_grab_cache_page_nowait(struct address_space *mapping, pgoff_t index)
>>> +{
>>> +	return pagecache_get_page(mapping, index,
>>> +			FGP_LOCK|FGP_CREAT|FGP_NOWAIT,
>>> +			mapping_gfp_mask(mapping));
>>> +}
>>> +#endif
>>> +
>>>
>>
>>
>> .
>>
> 
> 
> .
> 
