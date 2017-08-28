Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BFF8A6B037C
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 17:35:25 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a2so2470053pfj.2
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:35:25 -0700 (PDT)
Received: from mail-pf0-x22c.google.com (mail-pf0-x22c.google.com. [2607:f8b0:400e:c00::22c])
        by mx.google.com with ESMTPS id e4si1074881plb.423.2017.08.28.14.35.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 14:35:24 -0700 (PDT)
Received: by mail-pf0-x22c.google.com with SMTP id r62so4721163pfj.0
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:35:24 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2 10/30] befs: Define usercopy region in befs_inode_cache slab cache
Date: Mon, 28 Aug 2017 14:34:51 -0700
Message-Id: <1503956111-36652-11-git-send-email-keescook@chromium.org>
In-Reply-To: <1503956111-36652-1-git-send-email-keescook@chromium.org>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Luis de Bethencourt <luisbg@kernel.org>, Salah Triki <salah.triki@gmail.com>, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

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
---
 fs/befs/linuxvfs.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/befs/linuxvfs.c b/fs/befs/linuxvfs.c
index 4a4a5a366158..1c2dcbee79dd 100644
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
