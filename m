Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 93B386B028D
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 16:46:09 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 6so7423845pgh.0
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 13:46:09 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v68sor2346628pfb.12.2017.09.20.13.46.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 13:46:08 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 10/31] befs: Define usercopy region in befs_inode_cache slab cache
Date: Wed, 20 Sep 2017 13:45:16 -0700
Message-Id: <1505940337-79069-11-git-send-email-keescook@chromium.org>
In-Reply-To: <1505940337-79069-1-git-send-email-keescook@chromium.org>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Luis de Bethencourt <luisbg@kernel.org>, Salah Triki <salah.triki@gmail.com>, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

From: David Windsor <dave@nullcore.net>

befs symlink pathnames, stored in struct befs_inode_info.i_data.symlink
and therefore contained in the befs_inode_cache slab cache, need to be
copied to/from userspace.

cache object allocation:
    fs/befs/linuxvfs.c:
        befs_alloc_inode(...):
            ...
            bi = kmem_cache_alloc(befs_inode_cachep, GFP_KERNEL);
            ...
            return &bi->vfs_inode;

        befs_iget(...):
            ...
            strlcpy(befs_ino->i_data.symlink, raw_inode->data.symlink,
                    BEFS_SYMLINK_LEN);
            ...
            inode->i_link = befs_ino->i_data.symlink;

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
befs_inode_cache slab cache in which userspace copy operations are
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
Cc: Luis de Bethencourt <luisbg@kernel.org>
Cc: Salah Triki <salah.triki@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Acked-by: Luis de Bethencourt <luisbg@kernel.org>
---
 fs/befs/linuxvfs.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/befs/linuxvfs.c b/fs/befs/linuxvfs.c
index a92355cc453b..e5dcd26003dc 100644
--- a/fs/befs/linuxvfs.c
+++ b/fs/befs/linuxvfs.c
@@ -444,11 +444,15 @@ static struct inode *befs_iget(struct super_block *sb, unsigned long ino)
 static int __init
 befs_init_inodecache(void)
 {
-	befs_inode_cachep = kmem_cache_create("befs_inode_cache",
-					      sizeof (struct befs_inode_info),
-					      0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD|SLAB_ACCOUNT),
-					      init_once);
+	befs_inode_cachep = kmem_cache_create_usercopy("befs_inode_cache",
+				sizeof(struct befs_inode_info), 0,
+				(SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD|
+					SLAB_ACCOUNT),
+				offsetof(struct befs_inode_info,
+					i_data.symlink),
+				sizeof_field(struct befs_inode_info,
+					i_data.symlink),
+				init_once);
 	if (befs_inode_cachep == NULL)
 		return -ENOMEM;
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
