Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9F65F6B0275
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 05:34:58 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id u48so5991476qtc.3
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 02:34:58 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id m188si358934qkc.72.2017.09.21.02.34.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Sep 2017 02:34:57 -0700 (PDT)
Subject: Re: [PATCH v3 10/31] befs: Define usercopy region in befs_inode_cache
 slab cache
References: <1505940337-79069-1-git-send-email-keescook@chromium.org>
 <1505940337-79069-11-git-send-email-keescook@chromium.org>
From: Luis de Bethencourt <luisbg@kernel.org>
Message-ID: <89dd1d4e-9486-51a2-3500-ac85f947b145@kernel.org>
Date: Thu, 21 Sep 2017 10:34:55 +0100
MIME-Version: 1.0
In-Reply-To: <1505940337-79069-11-git-send-email-keescook@chromium.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org
Cc: David Windsor <dave@nullcore.net>, Salah Triki <salah.triki@gmail.com>, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

On 09/20/2017 09:45 PM, Kees Cook wrote:
> From: David Windsor <dave@nullcore.net>
> 
> befs symlink pathnames, stored in struct befs_inode_info.i_data.symlink
> and therefore contained in the befs_inode_cache slab cache, need to be
> copied to/from userspace.
> 
> cache object allocation:
>      fs/befs/linuxvfs.c:
>          befs_alloc_inode(...):
>              ...
>              bi = kmem_cache_alloc(befs_inode_cachep, GFP_KERNEL);
>              ...
>              return &bi->vfs_inode;
> 
>          befs_iget(...):
>              ...
>              strlcpy(befs_ino->i_data.symlink, raw_inode->data.symlink,
>                      BEFS_SYMLINK_LEN);
>              ...
>              inode->i_link = befs_ino->i_data.symlink;
> 
> example usage trace:
>      readlink_copy+0x43/0x70
>      vfs_readlink+0x62/0x110
>      SyS_readlinkat+0x100/0x130
> 
>      fs/namei.c:
>          readlink_copy(..., link):
>              ...
>              copy_to_user(..., link, len);
> 
>          (inlined in vfs_readlink)
>          generic_readlink(dentry, ...):
>              struct inode *inode = d_inode(dentry);
>              const char *link = inode->i_link;
>              ...
>              readlink_copy(..., link);
> 
> In support of usercopy hardening, this patch defines a region in the
> befs_inode_cache slab cache in which userspace copy operations are
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
> Cc: Luis de Bethencourt <luisbg@kernel.org>
> Cc: Salah Triki <salah.triki@gmail.com>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Acked-by: Luis de Bethencourt <luisbg@kernel.org>
> ---
>   fs/befs/linuxvfs.c | 14 +++++++++-----
>   1 file changed, 9 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/befs/linuxvfs.c b/fs/befs/linuxvfs.c
> index a92355cc453b..e5dcd26003dc 100644
> --- a/fs/befs/linuxvfs.c
> +++ b/fs/befs/linuxvfs.c
> @@ -444,11 +444,15 @@ static struct inode *befs_iget(struct super_block *sb, unsigned long ino)
>   static int __init
>   befs_init_inodecache(void)
>   {
> -	befs_inode_cachep = kmem_cache_create("befs_inode_cache",
> -					      sizeof (struct befs_inode_info),
> -					      0, (SLAB_RECLAIM_ACCOUNT|
> -						SLAB_MEM_SPREAD|SLAB_ACCOUNT),
> -					      init_once);
> +	befs_inode_cachep = kmem_cache_create_usercopy("befs_inode_cache",
> +				sizeof(struct befs_inode_info), 0,
> +				(SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD|
> +					SLAB_ACCOUNT),
> +				offsetof(struct befs_inode_info,
> +					i_data.symlink),
> +				sizeof_field(struct befs_inode_info,
> +					i_data.symlink),
> +				init_once);
>   	if (befs_inode_cachep == NULL)
>   		return -ENOMEM;
>   
> 

No changes in the befs patch in v3. It goes without saying I continue to 
Ack this.

Thanks Kees and David,
Luis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
