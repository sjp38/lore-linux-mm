Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id C62556B0005
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 15:46:40 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id x65so35091780pfb.1
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 12:46:40 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id p90si14630071pfi.232.2016.02.11.12.46.38
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 12:46:39 -0800 (PST)
Date: Fri, 12 Feb 2016 07:46:35 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 2/2] dax: move writeback calls into the filesystems
Message-ID: <20160211204635.GI19486@dastard>
References: <1455137336-28720-1-git-send-email-ross.zwisler@linux.intel.com>
 <1455137336-28720-3-git-send-email-ross.zwisler@linux.intel.com>
 <20160210220312.GP14668@dastard>
 <20160210224340.GA30938@linux.intel.com>
 <20160211125044.GJ21760@quack.suse.cz>
 <CAPcyv4g60iOTd-ShBCfsK+B7xArcc5pWXWktNop53otDbUW-3g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4g60iOTd-ShBCfsK+B7xArcc5pWXWktNop53otDbUW-3g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, XFS Developers <xfs@oss.sgi.com>

On Thu, Feb 11, 2016 at 07:22:00AM -0800, Dan Williams wrote:
> On Thu, Feb 11, 2016 at 4:50 AM, Jan Kara <jack@suse.cz> wrote:
> > On Wed 10-02-16 15:43:40, Ross Zwisler wrote:
> >> On Thu, Feb 11, 2016 at 09:03:12AM +1100, Dave Chinner wrote:
> >> > On Wed, Feb 10, 2016 at 01:48:56PM -0700, Ross Zwisler wrote:
> >> > > Previously calls to dax_writeback_mapping_range() for all DAX filesystems
> >> > > (ext2, ext4 & xfs) were centralized in filemap_write_and_wait_range().
> >> > > dax_writeback_mapping_range() needs a struct block_device, and it used to
> >> > > get that from inode->i_sb->s_bdev.  This is correct for normal inodes
> >> > > mounted on ext2, ext4 and XFS filesystems, but is incorrect for DAX raw
> >> > > block devices and for XFS real-time files.
> >> > >
> >> > > Instead, call dax_writeback_mapping_range() directly from the filesystem
> >> > > ->writepages function so that it can supply us with a valid block
> >> > > device. This also fixes DAX code to properly flush caches in response to
> >> > > sync(2).
> >> > >
> >> > > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> >> > > Signed-off-by: Jan Kara <jack@suse.cz>
> >> > > ---
> >> > >  fs/block_dev.c      | 16 +++++++++++++++-
> >> > >  fs/dax.c            | 13 ++++++++-----
> >> > >  fs/ext2/inode.c     | 11 +++++++++++
> >> > >  fs/ext4/inode.c     |  7 +++++++
> >> > >  fs/xfs/xfs_aops.c   |  9 +++++++++
> >> > >  include/linux/dax.h |  6 ++++--
> >> > >  mm/filemap.c        | 12 ++++--------
> >> > >  7 files changed, 58 insertions(+), 16 deletions(-)
> >> > >
> >> > > diff --git a/fs/block_dev.c b/fs/block_dev.c
> >> > > index 39b3a17..fc01e43 100644
> >> > > --- a/fs/block_dev.c
> >> > > +++ b/fs/block_dev.c
> >> > > @@ -1693,13 +1693,27 @@ static int blkdev_releasepage(struct page *page, gfp_t wait)
> >> > >   return try_to_free_buffers(page);
> >> > >  }
> >> > >
> >> > > +static int blkdev_writepages(struct address_space *mapping,
> >> > > +                      struct writeback_control *wbc)
> >> > > +{
> >> > > + if (dax_mapping(mapping)) {
> >> > > +         struct block_device *bdev = I_BDEV(mapping->host);
> >> > > +         int error;
> >> > > +
> >> > > +         error = dax_writeback_mapping_range(mapping, bdev, wbc);
> >> > > +         if (error)
> >> > > +                 return error;
> >> > > + }
> >> > > + return generic_writepages(mapping, wbc);
> >> > > +}
> >> >
> >> > Can you remind of the reason for calling generic_writepages() on DAX
> >> > enabled address spaces?
> >>
> >> Sure.  The initial version of this patch didn't do this, and during testing I
> >> hit a bunch of xfstests failures.  In ext2 at least I believe these were
> >> happening because we were skipping the call into generic_writepages() for DAX
> >> inodes. Without a lot of data to back this up, my guess is that this is due
> >> to metadata inodes or something being marked as DAX (so dax_mapping(mapping)
> >> returns true), but having dirty page cache pages that need to be written back
> >> as part of the writeback.
> >>
> >> Changing this so we always call generic_writepages() even in the DAX case
> >> solved the xfstest failures.
> >>
> >> If this sounds incorrect, please let me know and I'll go and gather more data.
> >
> > So I think a more correct fix it to not set S_DAX for inodes that will have
> > any pagecache pages - e.g. don't set S_DAX for block device inodes when
> > filesystem is mounted on it (probably the easiest is to just refuse to
> > mount filesystem on block device which has S_DAX set).
> 
> I think we have a wider problem here.  See __blkdev_get, we set S_DAX
> on all block devices that have ->direct_access() and have a
> page-aligned starting address.

That's seeming like a premature optimisation to me now. I didn't
say anything at the time because I was busy with other things and it
didn't affect XFS.

> It seems to me we need to modify the
> metadata i/o paths to bypass the page cache,

XFS doesn't use the block device page cache for it's metadata - it
has it's own internal metadata cache structures and uses get_pages
or heap memory to back it's metadata. But that doesn't make mixing
DAX and pages in the block device mapping tree sane.

What you are missing here is that the underlying architecture of
journalling filesystems mean they can't use DAX for their metadata.
Modifications have to be buffered, because they have to be written
to the journal first before they are written back in place. IOWs, we
need to buffer changes in volatile memory for some time, and that
means we can't use DAX during transactional modifications.

And to put the final nail in that coffin, metadata in XFS can be
discontiguous multi-block objects - in those situations we vmap the
underlying pages so they appear to the code to be a contiguous
buffer, and that's something we can't do with DAX....

> or teach the fsync code
> how to flush populated data pages out of the radix.

That doesn't solve the problem. Filesystems free and reallocate
filesystem blocks without intermediate block device mapping
invalidation calls, so what is one minute a data block accessed by
DAX may become a metadata block that accessed via buffered IO.  It
all goes to crap very quickly....

However, I'd say fsync is not the place to address this. This block
device cache aliasing issue is supposed to be what
unmap_underlying_metadata() solves, right?

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
