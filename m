Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AB2BB6B037C
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 17:35:24 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id m68so1173333pfj.6
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:35:24 -0700 (PDT)
Received: from mail-pg0-x234.google.com (mail-pg0-x234.google.com. [2607:f8b0:400e:c05::234])
        by mx.google.com with ESMTPS id t134si964948pgc.350.2017.08.28.14.35.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 14:35:23 -0700 (PDT)
Received: by mail-pg0-x234.google.com with SMTP id y15so5011461pgc.1
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:35:23 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2 09/30] jfs: Define usercopy region in jfs_ip slab cache
Date: Mon, 28 Aug 2017 14:34:50 -0700
Message-Id: <1503956111-36652-10-git-send-email-keescook@chromium.org>
In-Reply-To: <1503956111-36652-1-git-send-email-keescook@chromium.org>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Dave Kleikamp <shaggy@kernel.org>, jfs-discussion@lists.sourceforge.net, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

From: David Windsor <dave@nullcore.net>

The jfs symlink pathnames, stored in struct jfs_inode_info.i_inline and
therefore contained in the jfs_ip slab cache, need to be copied to/from
userspace.

cache object allocation:
    fs/jfs/super.c:
        jfs_alloc_inode(...):
            ...
            jfs_inode = kmem_cache_alloc(jfs_inode_cachep, GFP_NOFS);
            ...
            return &jfs_inode->vfs_inode;

    fs/jfs/jfs_incore.h:
        JFS_IP(struct inode *inode):
            return container_of(inode, struct jfs_inode_info, vfs_inode);

    fs/jfs/inode.c:
        jfs_iget(...):
            ...
            inode->i_link = JFS_IP(inode)->i_inline;

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
jfs_ip slab cache in which userspace copy operations are allowed.

This region is known as the slab cache's usercopy region. Slab caches can
now check that each copy operation involving cache-managed memory falls
entirely within the slab's usercopy region.

This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: adjust commit log, provide usage trace]
Cc: Dave Kleikamp <shaggy@kernel.org>
Cc: jfs-discussion@lists.sourceforge.net
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 fs/jfs/super.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/jfs/super.c b/fs/jfs/super.c
index e8aad7d87b8c..10b958f49f57 100644
--- a/fs/jfs/super.c
+++ b/fs/jfs/super.c
@@ -972,9 +972,11 @@ static int __init init_jfs_fs(void)
 	int rc;
 
 	jfs_inode_cachep =
-	    kmem_cache_create("jfs_ip", sizeof(struct jfs_inode_info), 0,
-			    SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD|SLAB_ACCOUNT,
-			    init_once);
+	    kmem_cache_create_usercopy("jfs_ip", sizeof(struct jfs_inode_info),
+			0, SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD|SLAB_ACCOUNT,
+			offsetof(struct jfs_inode_info, i_inline),
+			sizeof_field(struct jfs_inode_info, i_inline),
+			init_once);
 	if (jfs_inode_cachep == NULL)
 		return -ENOMEM;
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
