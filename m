Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A1FC06B0069
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 05:07:22 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id bk3so19613308wjc.4
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 02:07:22 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jd4si22876201wjb.273.2016.11.28.02.07.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Nov 2016 02:07:21 -0800 (PST)
Date: Mon, 28 Nov 2016 11:07:18 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: Fix a NULL dereference crash while accessing
 bdev->bd_disk
Message-ID: <20161128100718.GD2590@quack2.suse.cz>
References: <1480125982-8497-1-git-send-email-fangwei1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1480125982-8497-1-git-send-email-fangwei1@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Fang <fangwei1@huawei.com>
Cc: akpm@linux-foundation.org, jack@suse.cz, hannes@cmpxchg.org, hch@infradead.org, linux-mm@kvack.org, stable@vger.kernel.org, Jens Axboe <axboe@kernel.dk>, Tejun Heo <tj@kernel.org>

On Sat 26-11-16 10:06:22, Wei Fang wrote:
> ->bd_disk is assigned to NULL in __blkdev_put() when no one is holding
> the bdev. After that, ->bd_inode still can be touched in the
> blockdev_superblock->s_inodes list before the final iput. So iterate_bdevs()
> can still get this inode, and start writeback on mapping dirty pages.
> ->bd_disk will be dereferenced in mapping_cap_writeback_dirty() in this
> case, and a NULL dereference crash will be triggered:
> 
> Unable to handle kernel NULL pointer dereference at virtual address 00000388
> ...
> [<ffff8000004cb1e4>] blk_get_backing_dev_info+0x1c/0x28
> [<ffff8000001c879c>] __filemap_fdatawrite_range+0x54/0x98
> [<ffff8000001c8804>] filemap_fdatawrite+0x24/0x2c
> [<ffff80000027e7a4>] fdatawrite_one_bdev+0x20/0x28
> [<ffff800000288b44>] iterate_bdevs+0xec/0x144
> [<ffff80000027eb50>] sys_sync+0x84/0xd0
> 
> Since mapping_cap_writeback_dirty() is always return true about
> block device inodes, no need to check it if the inode is a block
> device inode.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Wei Fang <fangwei1@huawei.com>

Good catch but I don't like sprinkling checks like this into the writeback
code and furthermore we don't want to call into writeback code when block
device is in the process of being destroyed which is what would happen with
your patch. That is a bug waiting to happen...

As I'm looking into the code, we need a serialization between bdev writeback
and blkdev_put(). That should be doable if we use writeback_single_inode()
for writing bdev inode instead of simple filemap_fdatawrite() and then use
inode_wait_for_writeback() in blkdev_put() but it needs some careful
thought.

Frankly that whole idea of tearing block devices down on last close is a
major headache and keeps biting us. I'm wondering whether it is still worth
it these days...

								Honza

> ---
>  mm/filemap.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 235021e..d607677 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -334,8 +334,9 @@ int __filemap_fdatawrite_range(struct address_space *mapping, loff_t start,
>  		.range_end = end,
>  	};
>  
> -	if (!mapping_cap_writeback_dirty(mapping))
> -		return 0;
> +	if (!sb_is_blkdev_sb(mapping->host->i_sb))
> +		if (!mapping_cap_writeback_dirty(mapping))
> +			return 0;
>  
>  	wbc_attach_fdatawrite_inode(&wbc, mapping->host);
>  	ret = do_writepages(mapping, &wbc);
> -- 
> 2.4.11
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
