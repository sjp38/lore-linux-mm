Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0CF366B0005
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 15:06:40 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id z8so151297652ywa.1
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 12:06:40 -0700 (PDT)
Received: from mail-yw0-x235.google.com (mail-yw0-x235.google.com. [2607:f8b0:4002:c05::235])
        by mx.google.com with ESMTPS id l125si1884625ywg.414.2016.07.21.12.06.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jul 2016 12:06:39 -0700 (PDT)
Received: by mail-yw0-x235.google.com with SMTP id u134so82811396ywg.3
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 12:06:39 -0700 (PDT)
Date: Thu, 21 Jul 2016 12:06:06 -0700
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH] mm: export filemap_check_errors() to modules
Message-ID: <20160721190606.GA1249@vader.DHCP.thefacebook.com>
References: <1469097618-3238-1-git-send-email-mszeredi@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1469097618-3238-1-git-send-email-mszeredi@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miklos Szeredi <mszeredi@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, Jaegeuk Kim <jaegeuk@kernel.org>

On Thu, Jul 21, 2016 at 12:40:18PM +0200, Miklos Szeredi wrote:
> And use it instead of opencoding in btrfs, f2fs and in fuse (coming up).
> 
> Signed-off-by: Miklos Szeredi <mszeredi@redhat.com>
> Cc: Chris Mason <clm@fb.com>
> Cc: Jaegeuk Kim <jaegeuk@kernel.org>
> ---
>  fs/btrfs/ctree.h    |  1 -
>  fs/btrfs/inode.c    | 15 ---------------
>  fs/btrfs/tree-log.c |  4 ++--
>  fs/f2fs/node.c      |  7 ++-----
>  include/linux/fs.h  |  1 +
>  mm/filemap.c        |  3 ++-
>  6 files changed, 7 insertions(+), 24 deletions(-)
> 
> diff --git a/fs/btrfs/ctree.h b/fs/btrfs/ctree.h
> index 4274a7bfdaed..425834193259 100644
> --- a/fs/btrfs/ctree.h
> +++ b/fs/btrfs/ctree.h
> @@ -3129,7 +3129,6 @@ int btrfs_prealloc_file_range_trans(struct inode *inode,
>  				    struct btrfs_trans_handle *trans, int mode,
>  				    u64 start, u64 num_bytes, u64 min_size,
>  				    loff_t actual_len, u64 *alloc_hint);
> -int btrfs_inode_check_errors(struct inode *inode);
>  extern const struct dentry_operations btrfs_dentry_operations;
>  #ifdef CONFIG_BTRFS_FS_RUN_SANITY_TESTS
>  void btrfs_test_inode_set_ops(struct inode *inode);
> diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
> index 4421954720b8..b22841625333 100644
> --- a/fs/btrfs/inode.c
> +++ b/fs/btrfs/inode.c
> @@ -10489,21 +10489,6 @@ out_inode:
>  
>  }
>  
> -/* Inspired by filemap_check_errors() */
> -int btrfs_inode_check_errors(struct inode *inode)
> -{
> -	int ret = 0;
> -
> -	if (test_bit(AS_ENOSPC, &inode->i_mapping->flags) &&
> -	    test_and_clear_bit(AS_ENOSPC, &inode->i_mapping->flags))
> -		ret = -ENOSPC;
> -	if (test_bit(AS_EIO, &inode->i_mapping->flags) &&
> -	    test_and_clear_bit(AS_EIO, &inode->i_mapping->flags))
> -		ret = -EIO;
> -
> -	return ret;
> -}
> -
>  static const struct inode_operations btrfs_dir_inode_operations = {
>  	.getattr	= btrfs_getattr,
>  	.lookup		= btrfs_lookup,
> diff --git a/fs/btrfs/tree-log.c b/fs/btrfs/tree-log.c
> index c05f69a8ec42..3c29b9357392 100644
> --- a/fs/btrfs/tree-log.c
> +++ b/fs/btrfs/tree-log.c
> @@ -3944,7 +3944,7 @@ static int wait_ordered_extents(struct btrfs_trans_handle *trans,
>  			 * i_mapping flags, so that the next fsync won't get
>  			 * an outdated io error too.
>  			 */
> -			btrfs_inode_check_errors(inode);
> +			filemap_check_errors(inode->i_mapping);
>  			*ordered_io_error = true;
>  			break;
>  		}
> @@ -4181,7 +4181,7 @@ static int btrfs_log_changed_extents(struct btrfs_trans_handle *trans,
>  	 * without writing to the log tree and the fsync must report the
>  	 * file data write error and not commit the current transaction.
>  	 */
> -	ret = btrfs_inode_check_errors(inode);
> +	ret = filemap_check_errors(inode->i_mapping);
>  	if (ret)
>  		ctx->io_err = ret;
>  process:

Btrfs part looks fine.

Reviewed-by: Omar Sandoval <osandov@fb.com>

-- 
Omar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
