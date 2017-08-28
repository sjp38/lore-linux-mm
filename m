Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 45C166B03A1
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 17:35:26 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r62so2457800pfj.5
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:35:26 -0700 (PDT)
Received: from mail-pg0-x230.google.com (mail-pg0-x230.google.com. [2607:f8b0:400e:c05::230])
        by mx.google.com with ESMTPS id g8si986466pgr.332.2017.08.28.14.35.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 14:35:25 -0700 (PDT)
Received: by mail-pg0-x230.google.com with SMTP id 83so4928636pgb.4
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:35:25 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2 12/30] orangefs: Define usercopy region in orangefs_inode_cache slab cache
Date: Mon, 28 Aug 2017 14:34:53 -0700
Message-Id: <1503956111-36652-13-git-send-email-keescook@chromium.org>
In-Reply-To: <1503956111-36652-1-git-send-email-keescook@chromium.org>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Mike Marshall <hubcap@omnibond.com>, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

From: David Windsor <dave@nullcore.net>

orangefs symlink pathnames, stored in struct orangefs_inode_s.link_target
and therefore contained in the orangefs_inode_cache, need to be copied
to/from userspace.

cache object allocation:
    fs/orangefs/super.c:
        orangefs_alloc_inode(...):
            ...
            orangefs_inode = kmem_cache_alloc(orangefs_inode_cache, ...);
            ...
            return &orangefs_inode->vfs_inode;

    fs/orangefs/orangefs-utils.c:
        exofs_symlink(...):
            ...
            inode->i_link = orangefs_inode->link_target;

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
orangefs_inode_cache slab cache in which userspace copy operations are
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
Cc: Mike Marshall <hubcap@omnibond.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 fs/orangefs/super.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/orangefs/super.c b/fs/orangefs/super.c
index 5a1bed6c8c6a..c67b91239730 100644
--- a/fs/orangefs/super.c
+++ b/fs/orangefs/super.c
@@ -626,11 +626,16 @@ void orangefs_kill_sb(struct super_block *sb)
 
 int orangefs_inode_cache_initialize(void)
 {
-	orangefs_inode_cache = kmem_cache_create("orangefs_inode_cache",
-					      sizeof(struct orangefs_inode_s),
-					      0,
-					      ORANGEFS_CACHE_CREATE_FLAGS,
-					      orangefs_inode_cache_ctor);
+	orangefs_inode_cache = kmem_cache_create_usercopy(
+					"orangefs_inode_cache",
+					sizeof(struct orangefs_inode_s),
+					0,
+					ORANGEFS_CACHE_CREATE_FLAGS,
+					offsetof(struct orangefs_inode_s,
+						link_target),
+					sizeof_field(struct orangefs_inode_s,
+						link_target),
+					orangefs_inode_cache_ctor);
 
 	if (!orangefs_inode_cache) {
 		gossip_err("Cannot create orangefs_inode_cache\n");
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
