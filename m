Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 582046B02FD
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 17:35:23 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r25so2418942pfk.11
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:35:23 -0700 (PDT)
Received: from mail-pg0-x233.google.com (mail-pg0-x233.google.com. [2607:f8b0:400e:c05::233])
        by mx.google.com with ESMTPS id m1si962360pgm.668.2017.08.28.14.35.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 14:35:22 -0700 (PDT)
Received: by mail-pg0-x233.google.com with SMTP id b8so4940688pgn.5
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:35:22 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2 07/30] ext4: Define usercopy region in ext4_inode_cache slab cache
Date: Mon, 28 Aug 2017 14:34:48 -0700
Message-Id: <1503956111-36652-8-git-send-email-keescook@chromium.org>
In-Reply-To: <1503956111-36652-1-git-send-email-keescook@chromium.org>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

From: David Windsor <dave@nullcore.net>

The ext4 symlink pathnames, stored in struct ext4_inode_info.i_data
and therefore contained in the ext4_inode_cache slab cache, need
to be copied to/from userspace.

cache object allocation:
    fs/ext4/super.c:
        ext4_alloc_inode(...):
            struct ext4_inode_info *ei;
            ...
            ei = kmem_cache_alloc(ext4_inode_cachep, GFP_NOFS);
            ...
            return &ei->vfs_inode;

    include/trace/events/ext4.h:
            #define EXT4_I(inode) \
                (container_of(inode, struct ext4_inode_info, vfs_inode))

    fs/ext4/namei.c:
        ext4_symlink(...):
            ...
            inode->i_link = (char *)&EXT4_I(inode)->i_data;

example usage trace:
    readlink_copy+0x43/0x70
    vfs_readlink+0x62/0x110
    SyS_readlinkat+0x100/0x130

    fs/namei.c:
        readlink_copy(..., link):
            ...
            copy_to_user(..., link, len)

        (inlined into vfs_readlink)
        generic_readlink(dentry, ...):
            struct inode *inode = d_inode(dentry);
            const char *link = inode->i_link;
            ...
            readlink_copy(..., link);

In support of usercopy hardening, this patch defines a region in the
ext4_inode_cache slab cache in which userspace copy operations are
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
Cc: "Theodore Ts'o" <tytso@mit.edu>
Cc: Andreas Dilger <adilger.kernel@dilger.ca>
Cc: linux-ext4@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 fs/ext4/super.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 0886fe82e9c4..79c3b1b11364 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1038,11 +1038,13 @@ static void init_once(void *foo)
 
 static int __init init_inodecache(void)
 {
-	ext4_inode_cachep = kmem_cache_create("ext4_inode_cache",
-					     sizeof(struct ext4_inode_info),
-					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD|SLAB_ACCOUNT),
-					     init_once);
+	ext4_inode_cachep = kmem_cache_create_usercopy("ext4_inode_cache",
+				sizeof(struct ext4_inode_info), 0,
+				(SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD|
+					SLAB_ACCOUNT),
+				offsetof(struct ext4_inode_info, i_data),
+				sizeof_field(struct ext4_inode_info, i_data),
+				init_once);
 	if (ext4_inode_cachep == NULL)
 		return -ENOMEM;
 	return 0;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
