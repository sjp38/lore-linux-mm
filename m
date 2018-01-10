Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 58DE26B0069
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 05:53:30 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id m12so6016514wrm.1
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 02:53:30 -0800 (PST)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id s48si347074eda.89.2018.01.10.02.53.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jan 2018 02:53:29 -0800 (PST)
Subject: Re: [PATCH 13/36] befs: Define usercopy region in befs_inode_cache
 slab cache
References: <1515531365-37423-1-git-send-email-keescook@chromium.org>
 <1515531365-37423-14-git-send-email-keescook@chromium.org>
From: Luis de Bethencourt <luisbg@kernel.org>
Message-ID: <490acc77-1198-e53e-c965-aef9c1ebf5fd@kernel.org>
Date: Wed, 10 Jan 2018 10:53:23 +0000
MIME-Version: 1.0
In-Reply-To: <1515531365-37423-14-git-send-email-keescook@chromium.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org
Cc: David Windsor <dave@nullcore.net>, Salah Triki <salah.triki@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

On 01/09/2018 08:55 PM, Kees Cook wrote:
> From: David Windsor <dave@nullcore.net>
> 
> befs symlink pathnames, stored in struct befs_inode_info.i_data.symlink
> and therefore contained in the befs_inode_cache slab cache, need to be
> copied to/from userspace.
> 
> cache object allocation:
>     fs/befs/linuxvfs.c:
>         befs_alloc_inode(...):
>             ...
>             bi = kmem_cache_alloc(befs_inode_cachep, GFP_KERNEL);
>             ...
>             return &bi->vfs_inode;
> 
>         befs_iget(...):
>             ...
>             strlcpy(befs_ino->i_data.symlink, raw_inode->data.symlink,
>                     BEFS_SYMLINK_LEN);
>             ...
>             inode->i_link = befs_ino->i_data.symlink;
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
>         (inlined in vfs_readlink)
>         generic_readlink(dentry, ...):
>             struct inode *inode = d_inode(dentry);
>             const char *link = inode->i_link;
>             ...
>             readlink_copy(..., link);
> 
> In support of usercopy hardening, this patch defines a region in the
> befs_inode_cache slab cache in which userspace copy operations are
> allowed.
> 
> This region is known as the slab cache's usercopy region. Slab caches
> can now check that each dynamically sized copy operation involving
> cache-managed memory falls entirely within the slab's usercopy region.
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
>  fs/befs/linuxvfs.c | 14 +++++++++-----
>  1 file changed, 9 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/befs/linuxvfs.c b/fs/befs/linuxvfs.c
> index ee236231cafa..af2832aaeec5 100644
> --- a/fs/befs/linuxvfs.c
> +++ b/fs/befs/linuxvfs.c
> @@ -444,11 +444,15 @@ static struct inode *befs_iget(struct super_block *sb, unsigned long ino)
>  static int __init
>  befs_init_inodecache(void)
>  {
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
>  	if (befs_inode_cachep == NULL)
>  		return -ENOMEM;
>  
> 

Hi Kees,

I've tested this and it works well.

You can have me as:
Signed-off-by, Tested-by, or the current Acked-by. Whatever you think is better.

Thanks for the great work. Your rock!

Luis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
