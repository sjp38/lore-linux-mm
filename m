Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6A0E96B027B
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 04:36:56 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id o2so46532905wje.5
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 01:36:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o7si17756429wjw.219.2016.12.19.01.36.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Dec 2016 01:36:55 -0800 (PST)
Date: Fri, 16 Dec 2016 09:41:26 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 8/9] Revert "ext4: avoid deadlocks in the writeback path
 by using sb_getblk_gfp"
Message-ID: <20161216084126.GF26608@quack2.suse.cz>
References: <20161215140715.12732-1-mhocko@kernel.org>
 <20161215140715.12732-9-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161215140715.12732-9-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Thu 15-12-16 15:07:14, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> This reverts commit c45653c341f5c8a0ce19c8f0ad4678640849cb86 because
> sb_getblk_gfp is not really needed as
> sb_getblk
>   __getblk_gfp
>     __getblk_slow
>       grow_buffers
>         grow_dev_page
> 	  gfp_mask = mapping_gfp_constraint(inode->i_mapping, ~__GFP_FS) | gfp
> 
> so __GFP_FS is cleared unconditionally and therefore the above commit
> didn't have any real effect in fact.
> 
> This patch should not introduce any functional change. The main point
> of this change is to reduce explicit GFP_NOFS usage inside ext4 code to
> make the review of the remaining usage easier.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/ext4/extents.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/ext4/extents.c b/fs/ext4/extents.c
> index b1f8416923ab..ef815eb72389 100644
> --- a/fs/ext4/extents.c
> +++ b/fs/ext4/extents.c
> @@ -518,7 +518,7 @@ __read_extent_tree_block(const char *function, unsigned int line,
>  	struct buffer_head		*bh;
>  	int				err;
>  
> -	bh = sb_getblk_gfp(inode->i_sb, pblk, __GFP_MOVABLE | GFP_NOFS);
> +	bh = sb_getblk(inode->i_sb, pblk);
>  	if (unlikely(!bh))
>  		return ERR_PTR(-ENOMEM);
>  
> @@ -1096,7 +1096,7 @@ static int ext4_ext_split(handle_t *handle, struct inode *inode,
>  		err = -EFSCORRUPTED;
>  		goto cleanup;
>  	}
> -	bh = sb_getblk_gfp(inode->i_sb, newblock, __GFP_MOVABLE | GFP_NOFS);
> +	bh = sb_getblk(inode->i_sb, newblock);
>  	if (unlikely(!bh)) {
>  		err = -ENOMEM;
>  		goto cleanup;
> @@ -1290,7 +1290,7 @@ static int ext4_ext_grow_indepth(handle_t *handle, struct inode *inode,
>  	if (newblock == 0)
>  		return err;
>  
> -	bh = sb_getblk_gfp(inode->i_sb, newblock, __GFP_MOVABLE | GFP_NOFS);
> +	bh = sb_getblk(inode->i_sb, newblock);
>  	if (unlikely(!bh))
>  		return -ENOMEM;
>  	lock_buffer(bh);
> -- 
> 2.10.2
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
