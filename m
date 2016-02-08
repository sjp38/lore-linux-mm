Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id C1E2E830A0
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 10:34:53 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id yy13so75149457pab.3
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 07:34:53 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id s77si30726622pfs.76.2016.02.08.07.34.52
        for <linux-mm@kvack.org>;
        Mon, 08 Feb 2016 07:34:53 -0800 (PST)
Date: Mon, 8 Feb 2016 08:34:43 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 1/2] dax: pass bdev argument to dax_clear_blocks()
Message-ID: <20160208153443.GC2343@linux.intel.com>
References: <1454829553-29499-1-git-send-email-ross.zwisler@linux.intel.com>
 <1454829553-29499-2-git-send-email-ross.zwisler@linux.intel.com>
 <20160207220329.GK31407@dastard>
 <20160208014409.GA2343@linux.intel.com>
 <20160208051725.GM31407@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160208051725.GM31407@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, xfs@oss.sgi.com

On Mon, Feb 08, 2016 at 04:17:25PM +1100, Dave Chinner wrote:
> On Sun, Feb 07, 2016 at 06:44:09PM -0700, Ross Zwisler wrote:
> > On Mon, Feb 08, 2016 at 09:03:29AM +1100, Dave Chinner wrote:
> > > On Sun, Feb 07, 2016 at 12:19:12AM -0700, Ross Zwisler wrote:
> > > > dax_clear_blocks() needs a valid struct block_device and previously it was
> > > > using inode->i_sb->s_bdev in all cases.  This is correct for normal inodes
> > > > on mounted ext2, ext4 and XFS filesystems, but is incorrect for DAX raw
> > > > block devices and for XFS real-time devices.
> > > > 
> > > > Instead, have the caller pass in a struct block_device pointer which it
> > > > knows to be correct.
> > > ....
> > > > diff --git a/fs/xfs/xfs_bmap_util.c b/fs/xfs/xfs_bmap_util.c
> > > > index 07ef29b..f722ba2 100644
> > > > --- a/fs/xfs/xfs_bmap_util.c
> > > > +++ b/fs/xfs/xfs_bmap_util.c
> > > > @@ -73,9 +73,11 @@ xfs_zero_extent(
> > > >  	xfs_daddr_t	sector = xfs_fsb_to_db(ip, start_fsb);
> > > >  	sector_t	block = XFS_BB_TO_FSBT(mp, sector);
> > > >  	ssize_t		size = XFS_FSB_TO_B(mp, count_fsb);
> > > > +	struct inode	*inode = VFS_I(ip);
> > > >  
> > > >  	if (IS_DAX(VFS_I(ip)))
> > > > -		return dax_clear_blocks(VFS_I(ip), block, size);
> > > > +		return dax_clear_blocks(inode, xfs_find_bdev_for_inode(inode),
> > > > +				block, size);
> > > 
> > > Get rid of the local inode variable and use VFS_I(ip) like the code
> > > originally did. Do not change code that is unrelated to the
> > > modifcation being made, especially when it results in making
> > > the code an inconsistent mess of mixed pointer constructs....
> > 
> > The local 'inode' variable was added to avoid multiple calls for VFS_I() for
> > the same 'ip'.
> 
> My point is you didn't achieve that. The end result of your patch
> is:
> 
> 	struct inode	*inode = VFS_I(ip);
> 
> 	if (IS_DAX(VFS_I(ip)))
> 		return dax_clear_blocks(inode, xfs_find_bdev_for_inode(inode),
> 					block, size);
> 
> So now we have a local variable, but we still have 2 calls to
> VFS_I(ip). i.e. this makes the code harder to read and understand
> than before for no benefit.

*facepalm*  Yep, thanks for the correction.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
