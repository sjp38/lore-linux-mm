Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 5FC356B0038
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 08:29:30 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id p9so2743672lbv.35
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 05:29:29 -0700 (PDT)
Received: from mail.efficios.com (mail.efficios.com. [78.47.125.74])
        by mx.google.com with ESMTP id yn9si34661376lbb.10.2014.10.16.05.29.28
        for <linux-mm@kvack.org>;
        Thu, 16 Oct 2014 05:29:28 -0700 (PDT)
Date: Thu, 16 Oct 2014 14:29:08 +0200
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [PATCH v11 17/21] ext2: Remove ext2_aops_xip
Message-ID: <20141016122908.GO19075@thinkos.etherlink>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <1411677218-29146-18-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1411677218-29146-18-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 25-Sep-2014 04:33:34 PM, Matthew Wilcox wrote:
> We shouldn't need a special address_space_operations any more
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>

Reviewed-by: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>

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
> index 154cbcf..034fd42 100644
> --- a/fs/ext2/inode.c
> +++ b/fs/ext2/inode.c
> @@ -891,11 +891,6 @@ const struct address_space_operations ext2_aops = {
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
> @@ -1394,7 +1389,7 @@ struct inode *ext2_iget (struct super_block *sb, unsigned long ino)
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
> 2.1.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 

-- 
Mathieu Desnoyers
EfficiOS Inc.
http://www.efficios.com
Key fingerprint: 2A0B 4ED9 15F2 D3FA 45F5  B162 1728 0A97 8118 6ACF

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
