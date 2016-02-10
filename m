Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id BF5C26B0258
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 18:44:04 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id q63so19758949pfb.0
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 15:44:04 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id 21si8161942pfj.62.2016.02.10.15.44.03
        for <linux-mm@kvack.org>;
        Wed, 10 Feb 2016 15:44:04 -0800 (PST)
Date: Thu, 11 Feb 2016 10:44:00 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 2/2] dax: move writeback calls into the filesystems
Message-ID: <20160210234400.GQ14668@dastard>
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
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, xfs@oss.sgi.com, Jan Kara <jack@suse.cz>

On Wed, Feb 10, 2016 at 03:43:40PM -0700, Ross Zwisler wrote:
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

Hmmm - the ext2 filesystem metadata uses the block device page cache
to buffer inode writeback, and so writeback doesn't occur until
sync_blockdev() is called.

But the data access should be through the ext2 inode address space,
not the block device address space, so DAX flushing occurs in
ext2_writepages. So how is the block device inode being marked as
a DAX inode?

If it is being marked as a DAX inode, how is this valid when the
filesystem metadata uses bufferheads and requires struct pages to be
found in the block device mapping tree?  e.g. mkfs writes the
metadata into the bdev via DAX, resulting in an DAX exceptional
entry in the bdev radix tree, then __bread_gfp() comes along to read
the same metadata after mount and expects to find pages in the
blockdev radix tree?

FWIW, this seems to be specifically a block device inode issue,
though, not something that affects regular files in a filesystem.
i.e. filesystem inodes can only be either DAX or non-DAX, and so
there is no mixed mode flushing required, right?

> Changing this so we always call generic_writepages() even in the
> DAX case solved the xfstest failures. 
> 
> If this sounds incorrect, please let me know and I'll go and
> gather more data.

It seems to me that there's a problem here with DAX on block device
inodes, but not for the filesystem mappings. At minimum, the block
device needs a bloody big comment explaining this landmine so people
don't forget why it is a special snowflake...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
