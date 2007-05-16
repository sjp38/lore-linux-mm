Date: Thu, 17 May 2007 00:19:26 +0100
Subject: Re: [PATCH 5/5] Mark page cache pages as __GFP_PAGECACHE instead of __GFP_MOVABLE
Message-ID: <20070516231926.GA7340@skynet.ie>
References: <20070516230110.10314.85884.sendpatchset@skynet.skynet.ie> <20070516230250.10314.85751.sendpatchset@skynet.skynet.ie> <Pine.LNX.4.64.0705161613280.12119@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705161613280.12119@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (16/05/07 16:14), Christoph Lameter didst pronounce:
> On Thu, 17 May 2007, Mel Gorman wrote:
> 
> > diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc1-mm1-025_gfphighuser/fs/block_dev.c linux-2.6.22-rc1-mm1-030_pagecache_mark/fs/block_dev.c
> > --- linux-2.6.22-rc1-mm1-025_gfphighuser/fs/block_dev.c	2007-05-16 10:54:18.000000000 +0100
> > +++ linux-2.6.22-rc1-mm1-030_pagecache_mark/fs/block_dev.c	2007-05-16 23:07:30.000000000 +0100
> > @@ -576,7 +576,7 @@ struct block_device *bdget(dev_t dev)
> >  		inode->i_rdev = dev;
> >  		inode->i_bdev = bdev;
> >  		inode->i_data.a_ops = &def_blk_aops;
> > -		mapping_set_gfp_mask(&inode->i_data, GFP_USER|__GFP_MOVABLE);
> > +		mapping_set_gfp_mask(&inode->i_data, GFP_USER);
> >  		inode->i_data.backing_dev_info = &default_backing_dev_info;
> >  		spin_lock(&bdev_lock);
> >  		list_add(&bdev->bd_list, &all_bdevs);
> > diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc1-mm1-025_gfphighuser/fs/buffer.c linux-2.6.22-rc1-mm1-030_pagecache_mark/fs/buffer.c
> > --- linux-2.6.22-rc1-mm1-025_gfphighuser/fs/buffer.c	2007-05-16 22:55:50.000000000 +0100
> > +++ linux-2.6.22-rc1-mm1-030_pagecache_mark/fs/buffer.c	2007-05-16 23:07:30.000000000 +0100
> > @@ -1009,7 +1009,7 @@ grow_dev_page(struct block_device *bdev,
> >  	struct buffer_head *bh;
> >  
> >  	page = find_or_create_page(inode->i_mapping, index,
> > -					GFP_NOFS|__GFP_RECLAIMABLE);
> > +					GFP_NOFS_PAGECACHE);
> >  	if (!page)
> >  		return NULL;
> >  
> 
> We still have the contrast here. Should fs/block_dev.c not have 
> GFP_PAGECACHE?

It's not clear where, if anywhere, that pages allocated using the
mapping_set_gfp_mask() from bdget() end up on an LRU or become otherwise
movable. Hence, I removed the flag until such time as I am sure.

> But you could leave it and then my patch could fix this 
> up.
> 

Perfect.

> Otherwise
> 
> Acked-by: Christoph Lameter <clameter@sgi.com>

Thanks.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
