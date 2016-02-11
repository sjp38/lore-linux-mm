Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f178.google.com (mail-yw0-f178.google.com [209.85.161.178])
	by kanga.kvack.org (Postfix) with ESMTP id CB524828E1
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 10:47:52 -0500 (EST)
Received: by mail-yw0-f178.google.com with SMTP id q190so42007341ywd.3
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 07:47:52 -0800 (PST)
Received: from mail-yk0-x235.google.com (mail-yk0-x235.google.com. [2607:f8b0:4002:c07::235])
        by mx.google.com with ESMTPS id l70si3751210ywb.45.2016.02.11.07.22.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Feb 2016 07:22:01 -0800 (PST)
Received: by mail-yk0-x235.google.com with SMTP id z7so21891170yka.3
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 07:22:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160211125044.GJ21760@quack.suse.cz>
References: <1455137336-28720-1-git-send-email-ross.zwisler@linux.intel.com>
	<1455137336-28720-3-git-send-email-ross.zwisler@linux.intel.com>
	<20160210220312.GP14668@dastard>
	<20160210224340.GA30938@linux.intel.com>
	<20160211125044.GJ21760@quack.suse.cz>
Date: Thu, 11 Feb 2016 07:22:00 -0800
Message-ID: <CAPcyv4g60iOTd-ShBCfsK+B7xArcc5pWXWktNop53otDbUW-3g@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] dax: move writeback calls into the filesystems
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Chinner <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, XFS Developers <xfs@oss.sgi.com>

On Thu, Feb 11, 2016 at 4:50 AM, Jan Kara <jack@suse.cz> wrote:
> On Wed 10-02-16 15:43:40, Ross Zwisler wrote:
>> On Thu, Feb 11, 2016 at 09:03:12AM +1100, Dave Chinner wrote:
>> > On Wed, Feb 10, 2016 at 01:48:56PM -0700, Ross Zwisler wrote:
>> > > Previously calls to dax_writeback_mapping_range() for all DAX filesystems
>> > > (ext2, ext4 & xfs) were centralized in filemap_write_and_wait_range().
>> > > dax_writeback_mapping_range() needs a struct block_device, and it used to
>> > > get that from inode->i_sb->s_bdev.  This is correct for normal inodes
>> > > mounted on ext2, ext4 and XFS filesystems, but is incorrect for DAX raw
>> > > block devices and for XFS real-time files.
>> > >
>> > > Instead, call dax_writeback_mapping_range() directly from the filesystem
>> > > ->writepages function so that it can supply us with a valid block
>> > > device. This also fixes DAX code to properly flush caches in response to
>> > > sync(2).
>> > >
>> > > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
>> > > Signed-off-by: Jan Kara <jack@suse.cz>
>> > > ---
>> > >  fs/block_dev.c      | 16 +++++++++++++++-
>> > >  fs/dax.c            | 13 ++++++++-----
>> > >  fs/ext2/inode.c     | 11 +++++++++++
>> > >  fs/ext4/inode.c     |  7 +++++++
>> > >  fs/xfs/xfs_aops.c   |  9 +++++++++
>> > >  include/linux/dax.h |  6 ++++--
>> > >  mm/filemap.c        | 12 ++++--------
>> > >  7 files changed, 58 insertions(+), 16 deletions(-)
>> > >
>> > > diff --git a/fs/block_dev.c b/fs/block_dev.c
>> > > index 39b3a17..fc01e43 100644
>> > > --- a/fs/block_dev.c
>> > > +++ b/fs/block_dev.c
>> > > @@ -1693,13 +1693,27 @@ static int blkdev_releasepage(struct page *page, gfp_t wait)
>> > >   return try_to_free_buffers(page);
>> > >  }
>> > >
>> > > +static int blkdev_writepages(struct address_space *mapping,
>> > > +                      struct writeback_control *wbc)
>> > > +{
>> > > + if (dax_mapping(mapping)) {
>> > > +         struct block_device *bdev = I_BDEV(mapping->host);
>> > > +         int error;
>> > > +
>> > > +         error = dax_writeback_mapping_range(mapping, bdev, wbc);
>> > > +         if (error)
>> > > +                 return error;
>> > > + }
>> > > + return generic_writepages(mapping, wbc);
>> > > +}
>> >
>> > Can you remind of the reason for calling generic_writepages() on DAX
>> > enabled address spaces?
>>
>> Sure.  The initial version of this patch didn't do this, and during testing I
>> hit a bunch of xfstests failures.  In ext2 at least I believe these were
>> happening because we were skipping the call into generic_writepages() for DAX
>> inodes. Without a lot of data to back this up, my guess is that this is due
>> to metadata inodes or something being marked as DAX (so dax_mapping(mapping)
>> returns true), but having dirty page cache pages that need to be written back
>> as part of the writeback.
>>
>> Changing this so we always call generic_writepages() even in the DAX case
>> solved the xfstest failures.
>>
>> If this sounds incorrect, please let me know and I'll go and gather more data.
>
> So I think a more correct fix it to not set S_DAX for inodes that will have
> any pagecache pages - e.g. don't set S_DAX for block device inodes when
> filesystem is mounted on it (probably the easiest is to just refuse to
> mount filesystem on block device which has S_DAX set).

I think we have a wider problem here.  See __blkdev_get, we set S_DAX
on all block devices that have ->direct_access() and have a
page-aligned starting address.  It seems to me we need to modify the
metadata i/o paths to bypass the page cache, or teach the fsync code
how to flush populated data pages out of the radix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
