Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0D6456B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 18:08:17 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 17so280943377pfy.2
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 15:08:16 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s125si61544681pgs.40.2016.11.29.15.08.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 15:08:16 -0800 (PST)
Date: Tue, 29 Nov 2016 15:08:28 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Fix a NULL dereference crash while accessing
 bdev->bd_disk
Message-Id: <20161129150828.e0a4897160b9ee7301e5f554@linux-foundation.org>
In-Reply-To: <1480125982-8497-1-git-send-email-fangwei1@huawei.com>
References: <1480125982-8497-1-git-send-email-fangwei1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Fang <fangwei1@huawei.com>
Cc: jack@suse.cz, hannes@cmpxchg.org, hch@infradead.org, linux-mm@kvack.org, stable@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>

On Sat, 26 Nov 2016 10:06:22 +0800 Wei Fang <fangwei1@huawei.com> wrote:

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
> ...
>
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

This seems wrong to me.  If __blkdev_put() has got so deep into the
release process as to be zeroing out ->bd_disk then the blockdev's
inode shouldn't be visible to iterate_bdevs()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
