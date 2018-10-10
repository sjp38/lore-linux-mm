Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id C43666B0003
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 19:13:44 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id f59-v6so5029889plb.5
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 16:13:44 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id w24-v6si558979pgi.313.2018.10.10.16.13.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 16:13:43 -0700 (PDT)
Date: Wed, 10 Oct 2018 16:13:39 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 05/25] vfs: check file ranges before cloning files
Message-ID: <20181010231339.GA6701@magnolia>
References: <153913023835.32295.13962696655740190941.stgit@magnolia>
 <153913027326.32295.7601238218404639876.stgit@magnolia>
 <20181010230639.GN6311@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181010230639.GN6311@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, ocfs2-devel@oss.oracle.com

On Thu, Oct 11, 2018 at 10:06:39AM +1100, Dave Chinner wrote:
> On Tue, Oct 09, 2018 at 05:11:13PM -0700, Darrick J. Wong wrote:
> > From: Darrick J. Wong <darrick.wong@oracle.com>
> > 
> > Move the file range checks from vfs_clone_file_prep into a separate
> > generic_remap_checks function so that all the checks are collected in a
> > central location.  This forms the basis for adding more checks from
> > generic_write_checks that will make cloning's input checking more
> > consistent with write input checking.
> > 
> > Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> > Reviewed-by: Christoph Hellwig <hch@lst.de>
> ....
> > --- a/fs/read_write.c
> > +++ b/fs/read_write.c
> > @@ -1717,12 +1717,12 @@ static int clone_verify_area(struct file *file, loff_t pos, u64 len, bool write)
> >   * Returns: 0 for "nothing to clone", 1 for "something to clone", or
> >   * the usual negative error code.
> >   */
> > -int vfs_clone_file_prep_inodes(struct inode *inode_in, loff_t pos_in,
> > -			       struct inode *inode_out, loff_t pos_out,
> > -			       u64 *len, bool is_dedupe)
> > +int vfs_clone_file_prep(struct file *file_in, loff_t pos_in,
> > +			struct file *file_out, loff_t pos_out,
> > +			u64 *len, bool is_dedupe)
> >  {
> > -	loff_t bs = inode_out->i_sb->s_blocksize;
> > -	loff_t blen;
> > +	struct inode *inode_in = file_inode(file_in);
> > +	struct inode *inode_out = file_inode(file_out);
> >  	loff_t isize;
> >  	bool same_inode = (inode_in == inode_out);
> >  	int ret;
> > @@ -1740,10 +1740,7 @@ int vfs_clone_file_prep_inodes(struct inode *inode_in, loff_t pos_in,
> >  	if (!S_ISREG(inode_in->i_mode) || !S_ISREG(inode_out->i_mode))
> >  		return -EINVAL;
> >  
> > -	/* Are we going all the way to the end? */
> >  	isize = i_size_read(inode_in);
> > -	if (isize == 0)
> > -		return 0;
> 
> This looks like a change of behaviour. Instead of skipping zero
> legnth source files and returning success, this will now return
> -EINVAL as other checks fail? That needs to be documented in the
> commit message if it's intentional and a valid change to make...

Meh, I'll make another patch.  btrfs has never had this behavior.

$ ls /mnt/a
-rw-r--r-- 1 root root 0 Oct 10 16:10 /mnt/a
$ xfs_io -f -c 'reflink /mnt/a 1000000 0 4096' /mnt/b
XFS_IOC_CLONE_RANGE: Invalid argument

So it's a bug in the vfs prep functions.

--D

> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com
