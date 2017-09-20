Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 34B636B0290
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 16:46:12 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 6so7424010pgh.0
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 13:46:12 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t61sor1298158plb.141.2017.09.20.13.46.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 13:46:10 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 11/31] exofs: Define usercopy region in exofs_inode_cache slab cache
Date: Wed, 20 Sep 2017 13:45:17 -0700
Message-Id: <1505940337-79069-12-git-send-email-keescook@chromium.org>
In-Reply-To: <1505940337-79069-1-git-send-email-keescook@chromium.org>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Boaz Harrosh <ooo@electrozaur.com>, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

From: David Windsor <dave@nullcore.net>

The exofs short symlink names, stored in struct exofs_i_info.i_data and
therefore contained in the exofs_inode_cache slab cache, need to be copied
to/from userspace.

cache object allocation:
    fs/exofs/super.c:
        exofs_alloc_inode(...):
            ...
            oi = kmem_cache_alloc(exofs_inode_cachep, GFP_KERNEL);
            ...
            return &oi->vfs_inode;

    fs/exofs/namei.c:
        exofs_symlink(...):
            ...
            inode->i_link = (char *)oi->i_data;

example usage trace:
    readlink_copy+0x43/0x70
    vfs_readlink+0x62/0x110
    SyS_readlinkat+0x100/0x130

    fs/namei.c:
        readlink_copy(..., link):
            ...
            copy_to_user(..., link, len);

        (inlined in vfs_readlink)
        generic_readlink(dentry, ...):
            struct inode *inode = d_inode(dentry);
            const char *link = inode->i_link;
            ...
            readlink_copy(..., link);

In support of usercopy hardening, this patch defines a region in the
exofs_inode_cache slab cache in which userspace copy operations are
allowed.

This region is known as the slab cache's usercopy region. Slab caches can
now check that each copy operation involving cache-managed memory falls
entirely within the slab's usercopy region.

This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: adjust commit log, provide usage trace]
Cc: Boaz Harrosh <ooo@electrozaur.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 fs/exofs/super.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/exofs/super.c b/fs/exofs/super.c
index 819624cfc8da..e5c532875bb7 100644
--- a/fs/exofs/super.c
+++ b/fs/exofs/super.c
@@ -192,10 +192,13 @@ static void exofs_init_once(void *foo)
  */
 static int init_inodecache(void)
 {
-	exofs_inode_cachep = kmem_cache_create("exofs_inode_cache",
+	exofs_inode_cachep = kmem_cache_create_usercopy("exofs_inode_cache",
 				sizeof(struct exofs_i_info), 0,
 				SLAB_RECLAIM_ACCOUNT | SLAB_MEM_SPREAD |
-				SLAB_ACCOUNT, exofs_init_once);
+				SLAB_ACCOUNT,
+				offsetof(struct exofs_i_info, i_data),
+				sizeof_field(struct exofs_i_info, i_data),
+				exofs_init_once);
 	if (exofs_inode_cachep == NULL)
 		return -ENOMEM;
 	return 0;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
