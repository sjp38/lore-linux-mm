Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 476DC6B0009
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 16:33:06 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id g62so181768890wme.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 13:33:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h71si7306524wme.28.2016.02.17.13.33.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Feb 2016 13:33:05 -0800 (PST)
Date: Wed, 17 Feb 2016 22:33:25 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 2/6] ext2, ext4: only set S_DAX for regular inodes
Message-ID: <20160217213325.GH14140@quack.suse.cz>
References: <1455680059-20126-1-git-send-email-ross.zwisler@linux.intel.com>
 <1455680059-20126-3-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1455680059-20126-3-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Jens Axboe <axboe@kernel.dk>, Matthew Wilcox <willy@linux.intel.com>, linux-block@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, xfs@oss.sgi.com

On Tue 16-02-16 20:34:15, Ross Zwisler wrote:
> When S_DAX is set on an inode we assume that if there are pages attached
> to the mapping (mapping->nrpages != 0), those pages are clean zero pages
> that were used to service reads from holes.  Any dirty data associated with
> the inode should be in the form of DAX exceptional entries
> (mapping->nrexceptional) that is written back via
> dax_writeback_mapping_range().
> 
> With the current code, though, this isn't always true.  For example, ext2
> and ext4 directory inodes can have S_DAX set, but have their dirty data
> stored as dirty page cache entries.  For these types of inodes, having
> S_DAX set doesn't really make sense since their I/O doesn't actually happen
> through the DAX code path.
> 
> Instead, only allow S_DAX to be set for regular inodes for ext2 and ext4.
> This allows us to have strict DAX vs non-DAX paths in the writeback code.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/ext2/inode.c | 2 +-
>  fs/ext4/inode.c | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
> index 338eefd..27e2cdd 100644
> --- a/fs/ext2/inode.c
> +++ b/fs/ext2/inode.c
> @@ -1296,7 +1296,7 @@ void ext2_set_inode_flags(struct inode *inode)
>  		inode->i_flags |= S_NOATIME;
>  	if (flags & EXT2_DIRSYNC_FL)
>  		inode->i_flags |= S_DIRSYNC;
> -	if (test_opt(inode->i_sb, DAX))
> +	if (test_opt(inode->i_sb, DAX) && S_ISREG(inode->i_mode))
>  		inode->i_flags |= S_DAX;
>  }
>  
> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index 83bc8bf..7088aa5 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -4127,7 +4127,7 @@ void ext4_set_inode_flags(struct inode *inode)
>  		new_fl |= S_NOATIME;
>  	if (flags & EXT4_DIRSYNC_FL)
>  		new_fl |= S_DIRSYNC;
> -	if (test_opt(inode->i_sb, DAX))
> +	if (test_opt(inode->i_sb, DAX) && S_ISREG(inode->i_mode))
>  		new_fl |= S_DAX;
>  	inode_set_flags(inode, new_fl,
>  			S_SYNC|S_APPEND|S_IMMUTABLE|S_NOATIME|S_DIRSYNC|S_DAX);
> -- 
> 2.5.0
> 
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
