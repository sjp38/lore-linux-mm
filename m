Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6A9876B0005
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 14:49:35 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ho8so33821831pac.2
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 11:49:35 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id q78si14362784pfa.198.2016.02.11.11.49.34
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 11:49:34 -0800 (PST)
Date: Thu, 11 Feb 2016 12:49:22 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 0/2] DAX bdev fixes - move flushing calls to FS
Message-ID: <20160211194922.GA5260@linux.intel.com>
References: <1455137336-28720-1-git-send-email-ross.zwisler@linux.intel.com>
 <20160211124304.GI21760@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160211124304.GI21760@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, xfs@oss.sgi.com

On Thu, Feb 11, 2016 at 01:43:04PM +0100, Jan Kara wrote:
> On Wed 10-02-16 13:48:54, Ross Zwisler wrote:
> > During testing of raw block devices + DAX I noticed that the struct
> > block_device that we were using for DAX operations was incorrect.  For the
> > fault handlers, etc. we can just get the correct bdev via get_block(),
> > which is passed in as a function pointer, but for the *sync code and for
> > sector zeroing we don't have access to get_block().  This is also an issue
> > for XFS real-time devices, whenever we get those working.
> > 
> > Patch one of this series fixes the DAX sector zeroing code by explicitly
> > passing in a valid struct block_device.
> > 
> > Patch two of this series fixes DAX *sync support by moving calls to
> > dax_writeback_mapping_range() out of filemap_write_and_wait_range() and
> > into the filesystem/block device ->writepages function so that it can
> > supply us with a valid block device. This also fixes DAX code to properly
> > flush caches in response to sync(2).
> > 
> > Thanks to Jan Kara for his initial draft of patch 2:
> > https://lkml.org/lkml/2016/2/9/485
> > 
> > Here are the changes that I've made to that patch:
> > 
> > 1) For DAX mappings, only return after calling
> > dax_writeback_mapping_range() if we encountered an error.  In the non-error
> > case we still need to write back normal pages, else we lose metadata
> > updates. 
> > 
> > 2) In dax_writeback_mapping_range(), move the new check for 
> >         if (!mapping->nrexceptional || wbc->sync_mode != WB_SYNC_ALL)
> > above the i_blkbits check.  In my testing I found cases where
> > dax_writeback_mapping_range() was called for inodes with i_blkbits !=
> > PAGE_SHIFT - I'm assuming these are internal metadata inodes?  They have no
> > exceptional DAX entries to flush, so we have no work to do, but if we
> > return error from the i_blkbits check we will fail the overall writeback
> > operation.  Please let me know if it seems wrong for us to be seeing inodes
> > set to use DAX but with i_blkbits != PAGE_SHIFT and I'll get more info.
> 
> So I'm wondering - how come S_DAX flag got set for inode where i_blkbis !=
> PAGE_SHIFT? That would seem to be a bug? I specifically ordered the checks
> like this to catch such issues.

I've isolated this one - this happens for all three filesystems (ext2, ext4 &
XFS), and does indeed have to do with the fact that S_DAX is set for
bdev->bd_inode.

Here is one failure path:

[  102.866637]  [<ffffffff81576d93>] dump_stack+0x85/0xc2
[  102.867101]  [<ffffffff812b9ee0>] dax_writeback_mapping_range+0x60/0xe0
[  102.867738]  [<ffffffff812a1d4f>] blkdev_writepages+0x3f/0x50
[  102.868272]  [<ffffffff811db011>] do_writepages+0x21/0x30
[  102.868784]  [<ffffffff811cb6a6>] __filemap_fdatawrite_range+0xc6/0x100
[  102.869378]  [<ffffffff811cb75a>] filemap_write_and_wait+0x4a/0xa0
[  102.869933]  [<ffffffff812a15e0>] set_blocksize+0x70/0xd0
[  102.870424]  [<ffffffff812a273d>] sb_set_blocksize+0x1d/0x50
[  102.870933]  [<ffffffff8132ac9b>] ext4_fill_super+0x75b/0x3360
[  102.871487]  [<ffffffff81583381>] ? vsnprintf+0x201/0x4c0
[  102.872005]  [<ffffffff815836d9>] ? snprintf+0x49/0x60
[  102.872499]  [<ffffffff81263010>] mount_bdev+0x180/0x1b0
[  102.872981]  [<ffffffff8132a540>] ? ext4_calculate_overhead+0x370/0x370
[  102.873580]  [<ffffffff8131ad95>] ext4_mount+0x15/0x20
[  102.874042]  [<ffffffff81263908>] mount_fs+0x38/0x170
[  102.874524]  [<ffffffff812839db>] vfs_kern_mount+0x6b/0x150
[  102.875041]  [<ffffffff8128670f>] do_mount+0x24f/0xe90
[  102.875508]  [<ffffffff81284444>] ? mntput+0x24/0x40
[  102.875958]  [<ffffffff812399ba>] ? __kmalloc_track_caller+0xea/0x240
[  102.876542]  [<ffffffff812862bc>] ? copy_mount_options+0x2c/0x210
[  102.877087]  [<ffffffff81287695>] SyS_mount+0x95/0xe0
[  102.877573]  [<ffffffff81a6af72>] entry_SYSCALL_64_fastpath+0x12/0x76

In set_blocksize() we are actually updating bdev->bd_inode->i_blkbits to be
12, but before that happens we do a sync_blockdev() with i_blkbits at 10,
which causes the failure.  This can be reproduced easily just by mounting an
ext2 or ext4 filesystem.

I think the plan of unsetting S_DAX on bdev->bd_inode when we mount will save
us from this, as long as we do it super early in the mount process.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
