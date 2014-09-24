Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 928FF6B0035
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 04:45:24 -0400 (EDT)
Received: by mail-la0-f45.google.com with SMTP id el20so3754313lab.4
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 01:45:23 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i1si21958048laf.41.2014.09.24.01.45.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 24 Sep 2014 01:45:22 -0700 (PDT)
Date: Wed, 24 Sep 2014 10:45:19 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2] ext4: Fix mmap data corruption when blocksize <
 pagesize
Message-ID: <20140924084519.GA21987@quack.suse.cz>
References: <1411484603-17756-1-git-send-email-jack@suse.cz>
 <1411484603-17756-3-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1411484603-17756-3-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, linux-ext4@vger.kernel.org, Ted Tso <tytso@mit.edu>, Jan Kara <jack@suse.cz>, xfs@oss.sgi.com

On Tue 23-09-14 17:03:23, Jan Kara wrote:
> Use block_create_hole() when hole is being created in a file so that
> ->page_mkwrite() will get called for the partial tail page if it is
> mmaped (see the first patch in the series for details).
  Just out of curiosity I did a change similar to this one for ext4 to XFS
and indeed it fixed generic/030 test failures for XFS with blocksize 1k.

								Honza

PS: I forgot to CC xfs list in the original posting. You can find the VFS
    patch e.g. at http://www.spinics.net/lists/linux-mm/msg78976.html

> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  fs/ext4/inode.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index 3aa26e9117c4..fdcb007c2c9e 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -4536,8 +4536,12 @@ int ext4_setattr(struct dentry *dentry, struct iattr *attr)
>  				ext4_orphan_del(NULL, inode);
>  				goto err_out;
>  			}
> -		} else
> +		} else {
> +			loff_t old_size = inode->i_size;
> +
>  			i_size_write(inode, attr->ia_size);
> +			block_create_hole(inode, old_size, inode->i_size);
> +		}
>  
>  		/*
>  		 * Blocks are going to be removed from the inode. Wait
> -- 
> 1.8.1.4
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
