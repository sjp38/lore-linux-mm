Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7C2BA6B0006
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 21:22:30 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id s15-v6so7947221pgv.9
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 18:22:30 -0700 (PDT)
Received: from ipmail01.adl6.internode.on.net (ipmail01.adl6.internode.on.net. [150.101.137.136])
        by mx.google.com with ESMTP id r3-v6si26377692pga.321.2018.10.11.18.22.28
        for <linux-mm@kvack.org>;
        Thu, 11 Oct 2018 18:22:29 -0700 (PDT)
Date: Fri, 12 Oct 2018 12:22:26 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 24/25] xfs: support returning partial reflink results
Message-ID: <20181012012226.GT6311@dastard>
References: <153923113649.5546.9840926895953408273.stgit@magnolia>
 <153923131946.5546.5209673711907751253.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153923131946.5546.5209673711907751253.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

On Wed, Oct 10, 2018 at 09:15:19PM -0700, Darrick J. Wong wrote:
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
>  fs/xfs/xfs_reflink.c |   19 ++++++++++++++-----
>  fs/xfs/xfs_reflink.h |    2 +-
>  3 files changed, 16 insertions(+), 10 deletions(-)
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
> -	return ret < 0 ? ret : len;
>  }
>  
>  STATIC int
> diff --git a/fs/xfs/xfs_reflink.c b/fs/xfs/xfs_reflink.c
> index e1592e751cc2..12a1fe92454e 100644
> --- a/fs/xfs/xfs_reflink.c
> +++ b/fs/xfs/xfs_reflink.c
> @@ -1123,6 +1123,7 @@ xfs_reflink_remap_blocks(
>  	struct xfs_inode	*dest,
>  	xfs_fileoff_t		destoff,
>  	xfs_filblks_t		len,
> +	xfs_filblks_t		*remapped,
>  	xfs_off_t		new_isize)
>  {
>  	struct xfs_bmbt_irec	imap;
> @@ -1130,6 +1131,7 @@ xfs_reflink_remap_blocks(
>  	int			error = 0;
>  	xfs_filblks_t		range_len;
>  
> +	*remapped = 0;
>  	/* drange = (destoff, destoff + len); srange = (srcoff, srcoff + len) */
>  	while (len) {
>  		uint		lock_mode;
> @@ -1168,6 +1170,7 @@ xfs_reflink_remap_blocks(
>  		srcoff += range_len;
>  		destoff += range_len;
>  		len -= range_len;
> +		*remapped += range_len;
>  	}

So "remapped" is a block count? Can we call this something like
remap_len so it's obvious what it is tracking?

> @@ -1424,11 +1427,17 @@ xfs_reflink_remap_range(
>  
>  	trace_xfs_reflink_remap_range(src, pos_in, len, dest, pos_out);
>  
> +	if (len == 0) {
> +		ret = 0;
> +		goto out_unlock;
> +	}
> +
>  	dfsbno = XFS_B_TO_FSBT(mp, pos_out);
>  	sfsbno = XFS_B_TO_FSBT(mp, pos_in);
>  	fsblen = XFS_B_TO_FSB(mp, len);
>  	ret = xfs_reflink_remap_blocks(src, sfsbno, dest, dfsbno, fsblen,
> -			pos_out + len);
> +			&remapped, pos_out + len);
> +	remapped = min_t(int64_t, len, XFS_FSB_TO_B(mp, remapped));

So remapped is returned as a block count, then immediately converted
to a byte count? Can we return it as byte count so that we don't
have this weird unit conversion?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
