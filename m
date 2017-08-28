Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CE6A36B039F
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 17:35:26 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id m68so1173454pfj.6
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:35:26 -0700 (PDT)
Received: from mail-pg0-x231.google.com (mail-pg0-x231.google.com. [2607:f8b0:400e:c05::231])
        by mx.google.com with ESMTPS id s74si950326pfi.348.2017.08.28.14.35.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 14:35:25 -0700 (PDT)
Received: by mail-pg0-x231.google.com with SMTP id y15so5011663pgc.1
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:35:25 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2 11/30] exofs: Define usercopy region in exofs_inode_cache slab cache
Date: Mon, 28 Aug 2017 14:34:52 -0700
Message-Id: <1503956111-36652-12-git-send-email-keescook@chromium.org>
In-Reply-To: <1503956111-36652-1-git-send-email-keescook@chromium.org>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Boaz Harrosh <ooo@electrozaur.com>, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

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
