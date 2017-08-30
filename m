Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9703E6B0292
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 07:22:51 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id e9so11392005ywh.8
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 04:22:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i139si643287wmf.3.2017.08.30.04.22.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Aug 2017 04:22:49 -0700 (PDT)
Date: Wed, 30 Aug 2017 13:22:47 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 08/30] ext2: Define usercopy region in
 ext2_inode_cache slab cache
Message-ID: <20170830112247.GA30640@quack2.suse.cz>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
 <1503956111-36652-9-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1503956111-36652-9-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, David Windsor <dave@nullcore.net>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

On Mon 28-08-17 14:34:49, Kees Cook wrote:
> From: David Windsor <dave@nullcore.net>
> 
> The ext2 symlink pathnames, stored in struct ext2_inode_info.i_data and
> therefore contained in the ext2_inode_cache slab cache, need to be copied
> to/from userspace.
> 
> cache object allocation:
>     fs/ext2/super.c:
>         ext2_alloc_inode(...):
>             struct ext2_inode_info *ei;
>             ...
>             ei = kmem_cache_alloc(ext2_inode_cachep, GFP_NOFS);
>             ...
>             return &ei->vfs_inode;
> 
>     fs/ext2/ext2.h:
>         EXT2_I(struct inode *inode):
>             return container_of(inode, struct ext2_inode_info, vfs_inode);
> 
>     fs/ext2/namei.c:
>         ext2_symlink(...):
>             ...
>             inode->i_link = (char *)&EXT2_I(inode)->i_data;
> 
> example usage trace:
>     readlink_copy+0x43/0x70
>     vfs_readlink+0x62/0x110
>     SyS_readlinkat+0x100/0x130
> 
>     fs/namei.c:
>         readlink_copy(..., link):
>             ...
>             copy_to_user(..., link, len);
> 
>         (inlined into vfs_readlink)
>         generic_readlink(dentry, ...):
>             struct inode *inode = d_inode(dentry);
>             const char *link = inode->i_link;
>             ...
>             readlink_copy(..., link);
> 
> In support of usercopy hardening, this patch defines a region in the
> ext2_inode_cache slab cache in which userspace copy operations are
> allowed.
> 
> This region is known as the slab cache's usercopy region. Slab caches can
> now check that each copy operation involving cache-managed memory falls
> entirely within the slab's usercopy region.
> 
> This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
> whitelisting code in the last public patch of grsecurity/PaX based on my
> understanding of the code. Changes or omissions from the original code are
> mine and don't reflect the original grsecurity/PaX code.
> 
> Signed-off-by: David Windsor <dave@nullcore.net>
> [kees: adjust commit log, provide usage trace]
> Cc: Jan Kara <jack@suse.com>
> Cc: linux-ext4@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Looks good. You can add:

Acked-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/ext2/super.c | 12 +++++++-----
>  1 file changed, 7 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/ext2/super.c b/fs/ext2/super.c
> index 7b1bc9059863..670142cde59d 100644
> --- a/fs/ext2/super.c
> +++ b/fs/ext2/super.c
> @@ -219,11 +219,13 @@ static void init_once(void *foo)
>  
>  static int __init init_inodecache(void)
>  {
> -	ext2_inode_cachep = kmem_cache_create("ext2_inode_cache",
> -					     sizeof(struct ext2_inode_info),
> -					     0, (SLAB_RECLAIM_ACCOUNT|
> -						SLAB_MEM_SPREAD|SLAB_ACCOUNT),
> -					     init_once);
> +	ext2_inode_cachep = kmem_cache_create_usercopy("ext2_inode_cache",
> +				sizeof(struct ext2_inode_info), 0,
> +				(SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD|
> +					SLAB_ACCOUNT),
> +				offsetof(struct ext2_inode_info, i_data),
> +				sizeof_field(struct ext2_inode_info, i_data),
> +				init_once);
>  	if (ext2_inode_cachep == NULL)
>  		return -ENOMEM;
>  	return 0;
> -- 
> 2.7.4
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
