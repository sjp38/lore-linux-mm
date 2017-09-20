Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5E5D36B028B
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 16:46:07 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id d8so7404150pgt.1
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 13:46:07 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b63sor2078025pga.289.2017.09.20.13.46.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 13:46:06 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 08/31] ext2: Define usercopy region in ext2_inode_cache slab cache
Date: Wed, 20 Sep 2017 13:45:14 -0700
Message-Id: <1505940337-79069-9-git-send-email-keescook@chromium.org>
In-Reply-To: <1505940337-79069-1-git-send-email-keescook@chromium.org>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

From: David Windsor <dave@nullcore.net>

The ext2 symlink pathnames, stored in struct ext2_inode_info.i_data and
therefore contained in the ext2_inode_cache slab cache, need to be copied
to/from userspace.

cache object allocation:
    fs/ext2/super.c:
        ext2_alloc_inode(...):
            struct ext2_inode_info *ei;
            ...
            ei = kmem_cache_alloc(ext2_inode_cachep, GFP_NOFS);
            ...
            return &ei->vfs_inode;

    fs/ext2/ext2.h:
        EXT2_I(struct inode *inode):
            return container_of(inode, struct ext2_inode_info, vfs_inode);

    fs/ext2/namei.c:
        ext2_symlink(...):
            ...
            inode->i_link = (char *)&EXT2_I(inode)->i_data;

example usage trace:
    readlink_copy+0x43/0x70
    vfs_readlink+0x62/0x110
    SyS_readlinkat+0x100/0x130

    fs/namei.c:
        readlink_copy(..., link):
            ...
            copy_to_user(..., link, len);

        (inlined into vfs_readlink)
        generic_readlink(dentry, ...):
            struct inode *inode = d_inode(dentry);
            const char *link = inode->i_link;
            ...
            readlink_copy(..., link);

In support of usercopy hardening, this patch defines a region in the
ext2_inode_cache slab cache in which userspace copy operations are
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
Cc: Jan Kara <jack@suse.com>
Cc: linux-ext4@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
Acked-by: Jan Kara <jack@suse.cz>
---
 fs/ext2/super.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/fs/ext2/super.c b/fs/ext2/super.c
index 1458706bd2ec..789c29987b36 100644
--- a/fs/ext2/super.c
+++ b/fs/ext2/super.c
@@ -220,11 +220,13 @@ static void init_once(void *foo)
 
 static int __init init_inodecache(void)
 {
-	ext2_inode_cachep = kmem_cache_create("ext2_inode_cache",
-					     sizeof(struct ext2_inode_info),
-					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD|SLAB_ACCOUNT),
-					     init_once);
+	ext2_inode_cachep = kmem_cache_create_usercopy("ext2_inode_cache",
+				sizeof(struct ext2_inode_info), 0,
+				(SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD|
+					SLAB_ACCOUNT),
+				offsetof(struct ext2_inode_info, i_data),
+				sizeof_field(struct ext2_inode_info, i_data),
+				init_once);
 	if (ext2_inode_cachep == NULL)
 		return -ENOMEM;
 	return 0;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
