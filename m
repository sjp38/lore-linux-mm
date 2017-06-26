Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6C6536B0292
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 11:32:34 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id o7so2614644ite.13
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:32:34 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 142si359979iof.155.2017.06.26.08.32.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 08:32:33 -0700 (PDT)
Date: Mon, 26 Jun 2017 08:22:41 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH v7 21/22] xfs: minimal conversion to errseq_t writeback
 error reporting
Message-ID: <20170626152241.GC4733@birch.djwong.org>
References: <20170616193427.13955-1-jlayton@redhat.com>
 <20170616193427.13955-22-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170616193427.13955-22-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

On Fri, Jun 16, 2017 at 03:34:26PM -0400, Jeff Layton wrote:
> Just check and advance the data errseq_t in struct file before
> before returning from fsync on normal files. Internal filemap_*
> callers are left as-is.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/xfs/xfs_file.c | 15 +++++++++++----
>  1 file changed, 11 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
> index 5fb5a0958a14..bc3b1575e8db 100644
> --- a/fs/xfs/xfs_file.c
> +++ b/fs/xfs/xfs_file.c
> @@ -134,7 +134,7 @@ xfs_file_fsync(
>  	struct inode		*inode = file->f_mapping->host;
>  	struct xfs_inode	*ip = XFS_I(inode);
>  	struct xfs_mount	*mp = ip->i_mount;
> -	int			error = 0;
> +	int			error = 0, err2;
>  	int			log_flushed = 0;
>  	xfs_lsn_t		lsn = 0;
>  
> @@ -142,10 +142,12 @@ xfs_file_fsync(
>  
>  	error = filemap_write_and_wait_range(inode->i_mapping, start, end);
>  	if (error)
> -		return error;
> +		goto out;
>  
> -	if (XFS_FORCED_SHUTDOWN(mp))
> -		return -EIO;
> +	if (XFS_FORCED_SHUTDOWN(mp)) {
> +		error = -EIO;
> +		goto out;
> +	}
>  
>  	xfs_iflags_clear(ip, XFS_ITRUNCATED);
>  
> @@ -197,6 +199,11 @@ xfs_file_fsync(
>  	    mp->m_logdev_targp == mp->m_ddev_targp)
>  		xfs_blkdev_issue_flush(mp->m_ddev_targp);
>  
> +out:
> +	err2 = filemap_report_wb_err(file);

Could we have a comment here to remind anyone reading the code a year
from now that filemap_report_wb_err has side effects?  Pre-coffee me was
wondering why we'd bother calling filemap_report_wb_err in the
XFS_FORCED_SHUTDOWN case, then remembered that it touches data
structures.

The first sentence of the commit message (really, the word 'advance')
added as a comment was adequate to remind me of the side effects.

Once that's added,
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> +	if (!error)
> +		error = err2;
> +
>  	return error;
>  }
>  
> -- 
> 2.13.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
