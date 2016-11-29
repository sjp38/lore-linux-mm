Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8E76A6B0038
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 21:02:12 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id j92so275066944ioi.2
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 18:02:12 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id f67si42410990ioe.38.2016.11.28.18.02.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Nov 2016 18:02:11 -0800 (PST)
Subject: Re: [PATCH] mm: Fix a NULL dereference crash while accessing
 bdev->bd_disk
References: <1480125982-8497-1-git-send-email-fangwei1@huawei.com>
 <20161128100718.GD2590@quack2.suse.cz>
From: Wei Fang <fangwei1@huawei.com>
Message-ID: <583CE0C7.1040406@huawei.com>
Date: Tue, 29 Nov 2016 09:58:31 +0800
MIME-Version: 1.0
In-Reply-To: <20161128100718.GD2590@quack2.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, hch@infradead.org, linux-mm@kvack.org, stable@vger.kernel.org, Jens Axboe <axboe@kernel.dk>, Tejun Heo <tj@kernel.org>

Hi, Jan,

On 2016/11/28 18:07, Jan Kara wrote:
> Good catch but I don't like sprinkling checks like this into the writeback
> code and furthermore we don't want to call into writeback code when block
> device is in the process of being destroyed which is what would happen with
> your patch. That is a bug waiting to happen...

Agreed. Need another way to fix this problem. I looked through the
writeback cgroup code in __filemap_fdatawrite_range(), found if we
turn on CONFIG_CGROUP_WRITEBACK, a new crash will happen.

Thanks,
Wei

> As I'm looking into the code, we need a serialization between bdev writeback
> and blkdev_put(). That should be doable if we use writeback_single_inode()
> for writing bdev inode instead of simple filemap_fdatawrite() and then use
> inode_wait_for_writeback() in blkdev_put() but it needs some careful
> thought.
> 
> Frankly that whole idea of tearing block devices down on last close is a
> major headache and keeps biting us. I'm wondering whether it is still worth
> it these days...
> 
> 								Honza
> 
>> ---
>>  mm/filemap.c | 5 +++--
>>  1 file changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/filemap.c b/mm/filemap.c
>> index 235021e..d607677 100644
>> --- a/mm/filemap.c
>> +++ b/mm/filemap.c
>> @@ -334,8 +334,9 @@ int __filemap_fdatawrite_range(struct address_space *mapping, loff_t start,
>>  		.range_end = end,
>>  	};
>>  
>> -	if (!mapping_cap_writeback_dirty(mapping))
>> -		return 0;
>> +	if (!sb_is_blkdev_sb(mapping->host->i_sb))
>> +		if (!mapping_cap_writeback_dirty(mapping))
>> +			return 0;
>>  
>>  	wbc_attach_fdatawrite_inode(&wbc, mapping->host);
>>  	ret = do_writepages(mapping, &wbc);
>> -- 
>> 2.4.11
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
