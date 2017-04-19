Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id E25DA6B03AC
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 09:21:20 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id h186so10415888ith.10
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 06:21:20 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0135.outbound.protection.outlook.com. [104.47.1.135])
        by mx.google.com with ESMTPS id w126si2687567pgb.193.2017.04.19.06.21.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 19 Apr 2017 06:21:19 -0700 (PDT)
Subject: Re: [PATCH 2/4] fs/block_dev: always invalidate cleancache in
 invalidate_bdev()
References: <20170414140753.16108-1-aryabinin@virtuozzo.com>
 <20170414140753.16108-3-aryabinin@virtuozzo.com>
 <705067e3-eb15-ce2a-cfc8-d048dfc8be4f@gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <b2c72883-d9a2-bfda-2cd3-ae9475922bc5@virtuozzo.com>
Date: Wed, 19 Apr 2017 16:22:42 +0300
MIME-Version: 1.0
In-Reply-To: <705067e3-eb15-ce2a-cfc8-d048dfc8be4f@gmail.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <n.borisov.lkml@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, Steve French <sfrench@samba.org>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>, Alexey Kuznetsov <kuznet@virtuozzo.com>, Christoph Hellwig <hch@lst.de>, v9fs-developer@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org

On 04/18/2017 09:51 PM, Nikolay Borisov wrote:
> 
> 
> On 14.04.2017 17:07, Andrey Ryabinin wrote:
>> invalidate_bdev() calls cleancache_invalidate_inode() iff ->nrpages != 0
>> which doen't make any sense.
>> Make invalidate_bdev() always invalidate cleancache data.
>>
>> Fixes: c515e1fd361c ("mm/fs: add hooks to support cleancache")
>> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> ---
>>  fs/block_dev.c | 11 +++++------
>>  1 file changed, 5 insertions(+), 6 deletions(-)
>>
>> diff --git a/fs/block_dev.c b/fs/block_dev.c
>> index e405d8e..7af4787 100644
>> --- a/fs/block_dev.c
>> +++ b/fs/block_dev.c
>> @@ -103,12 +103,11 @@ void invalidate_bdev(struct block_device *bdev)
>>  {
>>  	struct address_space *mapping = bdev->bd_inode->i_mapping;
>>  
>> -	if (mapping->nrpages == 0)
>> -		return;
>> -
>> -	invalidate_bh_lrus();
>> -	lru_add_drain_all();	/* make sure all lru add caches are flushed */
>> -	invalidate_mapping_pages(mapping, 0, -1);
>> +	if (mapping->nrpages) {
>> +		invalidate_bh_lrus();
>> +		lru_add_drain_all();	/* make sure all lru add caches are flushed */
>> +		invalidate_mapping_pages(mapping, 0, -1);
>> +	}
> 
> How is this different than the current code? You will only invalidate
> the mapping iff ->nrpages > 0 ( I assume it can't go down below 0) ?

The difference is that invalidate_bdev() now always calls cleancache_invalidate_inode()
(you won't see it in this diff, it's placed after this if(mapping->nrpages){} block,)

> Perhaps just remove the if altogether?
> 

Given that invalidate_mapping_pages() invalidates exceptional entries as well, it certainly doesn't look
right that we look only at mapping->nrpages and completely ignore ->nrexceptional.
So maybe removing if() would be a right thing to do. But I think that should be a separate patch as it would
fix a another bug probably introduced by commit 91b0abe36a7b ("mm + fs: store shadow entries in page cache")

My intention here was to fix only cleancache case.


>>  	/* 99% of the time, we don't need to flush the cleancache on the bdev.
>>  	 * But, for the strange corners, lets be cautious
>>  	 */
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
