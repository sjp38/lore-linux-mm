Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 784C06B0035
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 06:02:36 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id q5so2870825wiv.13
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 03:02:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pu3si204650wjc.150.2014.04.09.03.02.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Apr 2014 03:02:35 -0700 (PDT)
Date: Wed, 9 Apr 2014 12:02:33 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v7 16/22] ext2: Remove ext2_aops_xip
Message-ID: <20140409100233.GI32103@quack.suse.cz>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <0b6512aa46a504459f41d3c609fc20c93d4a911a.1395591795.git.matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0b6512aa46a504459f41d3c609fc20c93d4a911a.1395591795.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

On Sun 23-03-14 15:08:42, Matthew Wilcox wrote:
> We shouldn't need a special address_space_operations any more
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
  Looks good. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza
> ---
>  fs/ext2/ext2.h  | 1 -
>  fs/ext2/inode.c | 7 +------
>  fs/ext2/namei.c | 4 ++--
>  3 files changed, 3 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/ext2/ext2.h b/fs/ext2/ext2.h
> index b30c3bd..b8b1c11 100644
> --- a/fs/ext2/ext2.h
> +++ b/fs/ext2/ext2.h
> @@ -793,7 +793,6 @@ extern const struct file_operations ext2_xip_file_operations;
>  
>  /* inode.c */
>  extern const struct address_space_operations ext2_aops;
> -extern const struct address_space_operations ext2_aops_xip;
>  extern const struct address_space_operations ext2_nobh_aops;
>  
>  /* namei.c */
> diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
> index 67124f0..7ca76da 100644
> --- a/fs/ext2/inode.c
> +++ b/fs/ext2/inode.c
> @@ -890,11 +890,6 @@ const struct address_space_operations ext2_aops = {
>  	.error_remove_page	= generic_error_remove_page,
>  };
>  
> -const struct address_space_operations ext2_aops_xip = {
> -	.bmap			= ext2_bmap,
> -	.direct_IO		= ext2_direct_IO,
> -};
> -
>  const struct address_space_operations ext2_nobh_aops = {
>  	.readpage		= ext2_readpage,
>  	.readpages		= ext2_readpages,
> @@ -1393,7 +1388,7 @@ struct inode *ext2_iget (struct super_block *sb, unsigned long ino)
>  	if (S_ISREG(inode->i_mode)) {
>  		inode->i_op = &ext2_file_inode_operations;
>  		if (test_opt(inode->i_sb, XIP)) {
> -			inode->i_mapping->a_ops = &ext2_aops_xip;
> +			inode->i_mapping->a_ops = &ext2_aops;
>  			inode->i_fop = &ext2_xip_file_operations;
>  		} else if (test_opt(inode->i_sb, NOBH)) {
>  			inode->i_mapping->a_ops = &ext2_nobh_aops;
> diff --git a/fs/ext2/namei.c b/fs/ext2/namei.c
> index 7ca803f..0db888c 100644
> --- a/fs/ext2/namei.c
> +++ b/fs/ext2/namei.c
> @@ -105,7 +105,7 @@ static int ext2_create (struct inode * dir, struct dentry * dentry, umode_t mode
>  
>  	inode->i_op = &ext2_file_inode_operations;
>  	if (test_opt(inode->i_sb, XIP)) {
> -		inode->i_mapping->a_ops = &ext2_aops_xip;
> +		inode->i_mapping->a_ops = &ext2_aops;
>  		inode->i_fop = &ext2_xip_file_operations;
>  	} else if (test_opt(inode->i_sb, NOBH)) {
>  		inode->i_mapping->a_ops = &ext2_nobh_aops;
> @@ -126,7 +126,7 @@ static int ext2_tmpfile(struct inode *dir, struct dentry *dentry, umode_t mode)
>  
>  	inode->i_op = &ext2_file_inode_operations;
>  	if (test_opt(inode->i_sb, XIP)) {
> -		inode->i_mapping->a_ops = &ext2_aops_xip;
> +		inode->i_mapping->a_ops = &ext2_aops;
>  		inode->i_fop = &ext2_xip_file_operations;
>  	} else if (test_opt(inode->i_sb, NOBH)) {
>  		inode->i_mapping->a_ops = &ext2_nobh_aops;
> -- 
> 1.9.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
