Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 44CD86B0009
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 07:50:29 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id 128so19768363wmz.1
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 04:50:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u1si11859452wjz.147.2016.02.11.04.50.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Feb 2016 04:50:28 -0800 (PST)
Date: Thu, 11 Feb 2016 13:50:44 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 2/2] dax: move writeback calls into the filesystems
Message-ID: <20160211125044.GJ21760@quack.suse.cz>
References: <1455137336-28720-1-git-send-email-ross.zwisler@linux.intel.com>
 <1455137336-28720-3-git-send-email-ross.zwisler@linux.intel.com>
 <20160210220312.GP14668@dastard>
 <20160210224340.GA30938@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160210224340.GA30938@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, xfs@oss.sgi.com, Jan Kara <jack@suse.cz>

On Wed 10-02-16 15:43:40, Ross Zwisler wrote:
> On Thu, Feb 11, 2016 at 09:03:12AM +1100, Dave Chinner wrote:
> > On Wed, Feb 10, 2016 at 01:48:56PM -0700, Ross Zwisler wrote:
> > > Previously calls to dax_writeback_mapping_range() for all DAX filesystems
> > > (ext2, ext4 & xfs) were centralized in filemap_write_and_wait_range().
> > > dax_writeback_mapping_range() needs a struct block_device, and it used to
> > > get that from inode->i_sb->s_bdev.  This is correct for normal inodes
> > > mounted on ext2, ext4 and XFS filesystems, but is incorrect for DAX raw
> > > block devices and for XFS real-time files.
> > > 
> > > Instead, call dax_writeback_mapping_range() directly from the filesystem
> > > ->writepages function so that it can supply us with a valid block
> > > device. This also fixes DAX code to properly flush caches in response to
> > > sync(2).
> > > 
> > > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > > Signed-off-by: Jan Kara <jack@suse.cz>
> > > ---
> > >  fs/block_dev.c      | 16 +++++++++++++++-
> > >  fs/dax.c            | 13 ++++++++-----
> > >  fs/ext2/inode.c     | 11 +++++++++++
> > >  fs/ext4/inode.c     |  7 +++++++
> > >  fs/xfs/xfs_aops.c   |  9 +++++++++
> > >  include/linux/dax.h |  6 ++++--
> > >  mm/filemap.c        | 12 ++++--------
> > >  7 files changed, 58 insertions(+), 16 deletions(-)
> > > 
> > > diff --git a/fs/block_dev.c b/fs/block_dev.c
> > > index 39b3a17..fc01e43 100644
> > > --- a/fs/block_dev.c
> > > +++ b/fs/block_dev.c
> > > @@ -1693,13 +1693,27 @@ static int blkdev_releasepage(struct page *page, gfp_t wait)
> > >  	return try_to_free_buffers(page);
> > >  }
> > >  
> > > +static int blkdev_writepages(struct address_space *mapping,
> > > +			     struct writeback_control *wbc)
> > > +{
> > > +	if (dax_mapping(mapping)) {
> > > +		struct block_device *bdev = I_BDEV(mapping->host);
> > > +		int error;
> > > +
> > > +		error = dax_writeback_mapping_range(mapping, bdev, wbc);
> > > +		if (error)
> > > +			return error;
> > > +	}
> > > +	return generic_writepages(mapping, wbc);
> > > +}
> > 
> > Can you remind of the reason for calling generic_writepages() on DAX
> > enabled address spaces?
> 
> Sure.  The initial version of this patch didn't do this, and during testing I
> hit a bunch of xfstests failures.  In ext2 at least I believe these were
> happening because we were skipping the call into generic_writepages() for DAX
> inodes. Without a lot of data to back this up, my guess is that this is due
> to metadata inodes or something being marked as DAX (so dax_mapping(mapping)
> returns true), but having dirty page cache pages that need to be written back
> as part of the writeback.
> 
> Changing this so we always call generic_writepages() even in the DAX case
> solved the xfstest failures. 
> 
> If this sounds incorrect, please let me know and I'll go and gather more data.

So I think a more correct fix it to not set S_DAX for inodes that will have
any pagecache pages - e.g. don't set S_DAX for block device inodes when
filesystem is mounted on it (probably the easiest is to just refuse to
mount filesystem on block device which has S_DAX set).

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
