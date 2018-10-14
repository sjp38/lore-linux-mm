Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B7C9C6B0005
	for <linux-mm@kvack.org>; Sun, 14 Oct 2018 13:35:50 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id l1-v6so17608351pfb.7
        for <linux-mm@kvack.org>; Sun, 14 Oct 2018 10:35:50 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w24-v6si6960250pgi.313.2018.10.14.10.35.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 14 Oct 2018 10:35:49 -0700 (PDT)
Date: Sun, 14 Oct 2018 10:35:46 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 24/25] xfs: support returning partial reflink results
Message-ID: <20181014173546.GI30673@infradead.org>
References: <153938912912.8361.13446310416406388958.stgit@magnolia>
 <153938931226.8361.7365948775364411156.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153938931226.8361.7365948775364411156.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

On Fri, Oct 12, 2018 at 05:08:32PM -0700, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> Back when the XFS reflink code only supported clone_file_range, we were
> only able to return zero or negative error codes to userspace.  However,
> now that copy_file_range (which returns bytes copied) can use XFS'
> clone_file_range, we have the opportunity to return partial results.
> For example, if userspace sends a 1GB clone request and we run out of
> space halfway through, we at least can tell userspace that we completed
> 512M of that request like a regular write.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> ---
>  fs/xfs/xfs_file.c    |    5 +----
>  fs/xfs/xfs_reflink.c |   20 +++++++++++++++-----
>  fs/xfs/xfs_reflink.h |    2 +-
>  3 files changed, 17 insertions(+), 10 deletions(-)
> 
> 
> diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
> index bc9e94bcb7a3..b2b15b8dc4a1 100644
> --- a/fs/xfs/xfs_file.c
> +++ b/fs/xfs/xfs_file.c
> @@ -928,14 +928,11 @@ xfs_file_remap_range(
>  	loff_t		len,
>  	unsigned int	remap_flags)
>  {
> -	int		ret;
> -
>  	if (!remap_check_flags(remap_flags, RFR_SAME_DATA))
>  		return -EINVAL;
>  
> -	ret = xfs_reflink_remap_range(file_in, pos_in, file_out, pos_out,
> +	return xfs_reflink_remap_range(file_in, pos_in, file_out, pos_out,
>  			len, remap_flags);

Is there any reason not to merge xfs_file_remap_range and
xfs_reflink_remap_range at this point?

>  STATIC int
> diff --git a/fs/xfs/xfs_reflink.c b/fs/xfs/xfs_reflink.c
> index e1592e751cc2..66a8ddb9c058 100644
> --- a/fs/xfs/xfs_reflink.c
> +++ b/fs/xfs/xfs_reflink.c
> @@ -1123,6 +1123,7 @@ xfs_reflink_remap_blocks(
>  	struct xfs_inode	*dest,
>  	xfs_fileoff_t		destoff,
>  	xfs_filblks_t		len,
> +	xfs_filblks_t		*remapped_len,
>  	xfs_off_t		new_isize)
>  {
>  	struct xfs_bmbt_irec	imap;
> @@ -1130,6 +1131,7 @@ xfs_reflink_remap_blocks(
>  	int			error = 0;
>  	xfs_filblks_t		range_len;
>  
> +	*remapped_len = 0;
>  	/* drange = (destoff, destoff + len); srange = (srcoff, srcoff + len) */
>  	while (len) {
>  		uint		lock_mode;
> @@ -1168,6 +1170,7 @@ xfs_reflink_remap_blocks(
>  		srcoff += range_len;
>  		destoff += range_len;
>  		len -= range_len;
> +		*remapped_len += range_len;
>  	}
>  
>  	return 0;
> @@ -1391,7 +1394,7 @@ xfs_reflink_remap_prep(
>  /*
>   * Link a range of blocks from one file to another.
>   */
> -int
> +loff_t
>  xfs_reflink_remap_range(
>  	struct file		*file_in,
>  	loff_t			pos_in,
> @@ -1406,9 +1409,10 @@ xfs_reflink_remap_range(
>  	struct xfs_inode	*dest = XFS_I(inode_out);
>  	struct xfs_mount	*mp = src->i_mount;
>  	xfs_fileoff_t		sfsbno, dfsbno;
> -	xfs_filblks_t		fsblen;
> +	xfs_filblks_t		fsblen, remappedfsb = 0;
> +	loff_t			remapped_bytes = 0;
>  	xfs_extlen_t		cowextsize;
> -	ssize_t			ret;
> +	int			ret;
>  
>  	if (!xfs_sb_version_hasreflink(&mp->m_sb))
>  		return -EOPNOTSUPP;
> @@ -1424,11 +1428,17 @@ xfs_reflink_remap_range(
>  
>  	trace_xfs_reflink_remap_range(src, pos_in, len, dest, pos_out);
>  
> +	if (len == 0) {
> +		ret = 0;
> +		goto out_unlock;
> +	}

Looking at the final tree this looks like dead (and bogus) code:

	if (ret <= 0)
	        return ret;

        trace_xfs_reflink_remap_range(src, pos_in, len, dest, pos_out);

        if (len == 0) {
                ret = 0;
                goto out_unlock;
        }


> +
>  	dfsbno = XFS_B_TO_FSBT(mp, pos_out);
>  	sfsbno = XFS_B_TO_FSBT(mp, pos_in);
>  	fsblen = XFS_B_TO_FSB(mp, len);
>  	ret = xfs_reflink_remap_blocks(src, sfsbno, dest, dfsbno, fsblen,
> +			&remappedfsb, pos_out + len);
> +	remapped_bytes = min_t(int64_t, len, XFS_FSB_TO_B(mp, remappedfsb));
>  	if (ret)
>  		goto out_unlock;

Shouldn't we just follow the calling convention of the method here:

 negative return value:	error
 positive:		number of bytes handled
 
 Something like:

	done = xfs_reflink_remap_blocks(src, sfsbno, dest, dfsbno,
			fsblen, pos_out + len);
	if (done < 0) {
		xfs_reflink_remap_unlock(file_in, file_out);
		trace_xfs_reflink_remap_range_error(dest, done, _RET_IP_);
		return done;
	}

>  
> @@ -1451,7 +1461,7 @@ xfs_reflink_remap_range(
>  	xfs_reflink_remap_unlock(file_in, file_out);
>  	if (ret)
>  		trace_xfs_reflink_remap_range_error(dest, ret, _RET_IP_);

And then we can drop this conditional here.
