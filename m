Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A1BB96B0038
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 02:30:49 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id o3so30820599wjo.1
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 23:30:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hd4si62682173wjb.149.2016.11.29.23.30.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Nov 2016 23:30:48 -0800 (PST)
Date: Wed, 30 Nov 2016 08:30:45 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: Fix a NULL dereference crash while accessing
 bdev->bd_disk
Message-ID: <20161130073045.GA16667@quack2.suse.cz>
References: <1480125982-8497-1-git-send-email-fangwei1@huawei.com>
 <20161129150828.e0a4897160b9ee7301e5f554@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161129150828.e0a4897160b9ee7301e5f554@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wei Fang <fangwei1@huawei.com>, jack@suse.cz, hannes@cmpxchg.org, hch@infradead.org, linux-mm@kvack.org, stable@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>

On Tue 29-11-16 15:08:28, Andrew Morton wrote:
> On Sat, 26 Nov 2016 10:06:22 +0800 Wei Fang <fangwei1@huawei.com> wrote:
> 
> > ->bd_disk is assigned to NULL in __blkdev_put() when no one is holding
> > the bdev. After that, ->bd_inode still can be touched in the
> > blockdev_superblock->s_inodes list before the final iput. So iterate_bdevs()
> > can still get this inode, and start writeback on mapping dirty pages.
> > ->bd_disk will be dereferenced in mapping_cap_writeback_dirty() in this
> > case, and a NULL dereference crash will be triggered:
> > 
> > Unable to handle kernel NULL pointer dereference at virtual address 00000388
> > ...
> > [<ffff8000004cb1e4>] blk_get_backing_dev_info+0x1c/0x28
> > [<ffff8000001c879c>] __filemap_fdatawrite_range+0x54/0x98
> > [<ffff8000001c8804>] filemap_fdatawrite+0x24/0x2c
> > [<ffff80000027e7a4>] fdatawrite_one_bdev+0x20/0x28
> > [<ffff800000288b44>] iterate_bdevs+0xec/0x144
> > [<ffff80000027eb50>] sys_sync+0x84/0xd0
> > 
> > Since mapping_cap_writeback_dirty() is always return true about
> > block device inodes, no need to check it if the inode is a block
> > device inode.
> > 
> > ...
> >
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -334,8 +334,9 @@ int __filemap_fdatawrite_range(struct address_space *mapping, loff_t start,
> >  		.range_end = end,
> >  	};
> >  
> > -	if (!mapping_cap_writeback_dirty(mapping))
> > -		return 0;
> > +	if (!sb_is_blkdev_sb(mapping->host->i_sb))
> > +		if (!mapping_cap_writeback_dirty(mapping))
> > +			return 0;
> >  
> >  	wbc_attach_fdatawrite_inode(&wbc, mapping->host);
> >  	ret = do_writepages(mapping, &wbc);
> 
> This seems wrong to me.  If __blkdev_put() has got so deep into the
> release process as to be zeroing out ->bd_disk then the blockdev's
> inode shouldn't be visible to iterate_bdevs()?

That's the trouble with how block devices currently work. On last close of
the block device, the block device inode is detached from bd_disk and thus
from request_queue & bdi. bd_disk & company gets freed, inode stays (bdev
inode is referenced by inodes representing block device in the filesystem
which are referenced by dentries). This happens asynchronously wrt
iterate_bdevs() and inode_to_bdi() calls in general - any inode_to_bdi()
call on block device inode can oops if it happens to race with
__blkdev_put().  The use of inode_to_bdi() in mapping_cap_writeback_dirty()
from iterate_bdevs() is one such possibility - that is relatively easy to
fix by modifying iterate_bdevs() however it is not so easy to protect in
this way inode_to_bdi() calls in writeback happening periodically from the
flusher work.
								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
