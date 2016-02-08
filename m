Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3BD0B8309E
	for <linux-mm@kvack.org>; Sun,  7 Feb 2016 20:44:21 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id ho8so65410617pac.2
        for <linux-mm@kvack.org>; Sun, 07 Feb 2016 17:44:21 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id w79si42695120pfi.99.2016.02.07.17.44.20
        for <linux-mm@kvack.org>;
        Sun, 07 Feb 2016 17:44:20 -0800 (PST)
Date: Sun, 7 Feb 2016 18:44:09 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 1/2] dax: pass bdev argument to dax_clear_blocks()
Message-ID: <20160208014409.GA2343@linux.intel.com>
References: <1454829553-29499-1-git-send-email-ross.zwisler@linux.intel.com>
 <1454829553-29499-2-git-send-email-ross.zwisler@linux.intel.com>
 <20160207220329.GK31407@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160207220329.GK31407@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, xfs@oss.sgi.com

On Mon, Feb 08, 2016 at 09:03:29AM +1100, Dave Chinner wrote:
> On Sun, Feb 07, 2016 at 12:19:12AM -0700, Ross Zwisler wrote:
> > dax_clear_blocks() needs a valid struct block_device and previously it was
> > using inode->i_sb->s_bdev in all cases.  This is correct for normal inodes
> > on mounted ext2, ext4 and XFS filesystems, but is incorrect for DAX raw
> > block devices and for XFS real-time devices.
> > 
> > Instead, have the caller pass in a struct block_device pointer which it
> > knows to be correct.
> ....
> > diff --git a/fs/xfs/xfs_bmap_util.c b/fs/xfs/xfs_bmap_util.c
> > index 07ef29b..f722ba2 100644
> > --- a/fs/xfs/xfs_bmap_util.c
> > +++ b/fs/xfs/xfs_bmap_util.c
> > @@ -73,9 +73,11 @@ xfs_zero_extent(
> >  	xfs_daddr_t	sector = xfs_fsb_to_db(ip, start_fsb);
> >  	sector_t	block = XFS_BB_TO_FSBT(mp, sector);
> >  	ssize_t		size = XFS_FSB_TO_B(mp, count_fsb);
> > +	struct inode	*inode = VFS_I(ip);
> >  
> >  	if (IS_DAX(VFS_I(ip)))
> > -		return dax_clear_blocks(VFS_I(ip), block, size);
> > +		return dax_clear_blocks(inode, xfs_find_bdev_for_inode(inode),
> > +				block, size);
> 
> Get rid of the local inode variable and use VFS_I(ip) like the code
> originally did. Do not change code that is unrelated to the
> modifcation being made, especially when it results in making
> the code an inconsistent mess of mixed pointer constructs....

The local 'inode' variable was added to avoid multiple calls for VFS_I() for
the same 'ip'.  That said, I'm happy to make the change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
