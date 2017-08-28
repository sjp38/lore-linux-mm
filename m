Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C285B6B03B5
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 17:35:29 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a2so2470312pfj.2
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:35:29 -0700 (PDT)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id r7si1022656ple.569.2017.08.28.14.35.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 14:35:28 -0700 (PDT)
Received: by mail-pf0-x22a.google.com with SMTP id h75so4696429pfh.1
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:35:28 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2 13/30] ufs: Define usercopy region in ufs_inode_cache slab cache
Date: Mon, 28 Aug 2017 14:34:54 -0700
Message-Id: <1503956111-36652-14-git-send-email-keescook@chromium.org>
In-Reply-To: <1503956111-36652-1-git-send-email-keescook@chromium.org>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Evgeniy Dushistov <dushistov@mail.ru>, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

From: David Windsor <dave@nullcore.net>

The ufs symlink pathnames, stored in struct ufs_inode_info.i_u1.i_symlink
and therefore contained in the ufs_inode_cache slab cache, need to be
copied to/from userspace.

cache object allocation:
    fs/ufs/super.c:
        ufs_alloc_inode(...):
            ...
            ei = kmem_cache_alloc(ufs_inode_cachep, GFP_NOFS);
            ...
            return &ei->vfs_inode;

    fs/ufs/ufs.h:
        UFS_I(struct inode *inode):
            return container_of(inode, struct ufs_inode_info, vfs_inode);

    fs/ufs/namei.c:
        ufs_symlink(...):
            ...
            inode->i_link = (char *)UFS_I(inode)->i_u1.i_symlink;

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
ufs_inode_cache slab cache in which userspace copy operations are allowed.

This region is known as the slab cache's usercopy region. Slab caches can
now check that each copy operation involving cache-managed memory falls
entirely within the slab's usercopy region.

This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: adjust commit log, provide usage trace]
Cc: Evgeniy Dushistov <dushistov@mail.ru>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 fs/ufs/super.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/ufs/super.c b/fs/ufs/super.c
index 0a4f58a5073c..646f971067bc 100644
--- a/fs/ufs/super.c
+++ b/fs/ufs/super.c
@@ -1466,11 +1466,14 @@ static void init_once(void *foo)
 
 static int __init init_inodecache(void)
 {
-	ufs_inode_cachep = kmem_cache_create("ufs_inode_cache",
-					     sizeof(struct ufs_inode_info),
-					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD|SLAB_ACCOUNT),
-					     init_once);
+	ufs_inode_cachep = kmem_cache_create_usercopy("ufs_inode_cache",
+				sizeof(struct ufs_inode_info), 0,
+				(SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD|
+					SLAB_ACCOUNT),
+				offsetof(struct ufs_inode_info, i_u1.i_symlink),
+				sizeof_field(struct ufs_inode_info,
+					i_u1.i_symlink),
+				init_once);
 	if (ufs_inode_cachep == NULL)
 		return -ENOMEM;
 	return 0;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
