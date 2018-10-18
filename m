Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B50856B0003
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 00:37:39 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id t28-v6so14977180pfk.21
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 21:37:39 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id v23-v6si19116345ply.196.2018.10.17.21.37.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 21:37:38 -0700 (PDT)
Date: Wed, 17 Oct 2018 21:37:24 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 04/29] vfs: strengthen checking of file range inputs to
 generic_remap_checks
Message-ID: <20181018043724.GS28243@magnolia>
References: <153981625504.5568.2708520119290577378.stgit@magnolia>
 <153981628292.5568.2466587869276881561.stgit@magnolia>
 <20181018004156.GA12386@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018004156.GA12386@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, ocfs2-devel@oss.oracle.com

On Thu, Oct 18, 2018 at 01:41:56AM +0100, Al Viro wrote:
> On Wed, Oct 17, 2018 at 03:44:43PM -0700, Darrick J. Wong wrote:
> > +static int generic_access_check_limits(struct file *file, loff_t pos,
> > +				       loff_t *count)
> > +{
> > +	struct inode *inode = file->f_mapping->host;
> > +
> > +	/* Don't exceed the LFS limits. */
> > +	if (unlikely(pos + *count > MAX_NON_LFS &&
> > +				!(file->f_flags & O_LARGEFILE))) {
> > +		if (pos >= MAX_NON_LFS)
> > +			return -EFBIG;
> > +		*count = min(*count, (loff_t)MAX_NON_LFS - pos);
> 
> 	Can that can be different from MAX_NON_LFS - pos?
> 
> > +	}
> > +
> > +	/*
> > +	 * Don't operate on ranges the page cache doesn't support.
> > +	 *
> > +	 * If we have written data it becomes a short write.  If we have
> > +	 * exceeded without writing data we send a signal and return EFBIG.
> > +	 * Linus frestrict idea will clean these up nicely..
> > +	 */
> > +	if (unlikely(pos >= inode->i_sb->s_maxbytes))
> > +		return -EFBIG;
> > +
> > +	*count = min(*count, inode->i_sb->s_maxbytes - pos);
> > +	return 0;
> > +}
> 
> Anyway, I would rather do this here:
> 
> 	struct inode *inode = file->f_mapping->host;
> 	loff_t max_size = inode->i_sb->s_maxbytes;
> 
> 	if (!(file->f_flags & O_LARGEFILE))
> 		max_size = MAX_NON_LFS;
> 
> 	if (unlikely(pos >= max_size))
> 		return -EFBIG;
> 	*count = min(*count, max_size - pos);
> 	return 0;

Sounds much better to me. :)

--D
