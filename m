Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0190A6B0311
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 19:36:50 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q78so114509739pfj.9
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:36:49 -0700 (PDT)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id 27si9446527pgy.522.2017.06.19.16.36.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 16:36:49 -0700 (PDT)
Received: by mail-pf0-x229.google.com with SMTP id x63so60695352pff.3
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:36:49 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 05/23] befs: define usercopy region in befs_inode_cache slab cache
Date: Mon, 19 Jun 2017 16:36:19 -0700
Message-Id: <1497915397-93805-6-git-send-email-keescook@chromium.org>
In-Reply-To: <1497915397-93805-1-git-send-email-keescook@chromium.org>
References: <1497915397-93805-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: David Windsor <dave@nullcore.net>

The befs symlink pathnames, stored in struct befs_inode_info.i_data.symlink
and therefore contained in the befs_inode_cache slab cache, need to be
copied to/from userspace.

In support of usercopy hardening, this patch defines a region in
the befs_inode_cache slab cache in which userspace copy operations
are allowed.

This region is known as the slab cache's usercopy region.  Slab
caches can now check that each copy operation involving cache-managed
memory falls entirely within the slab's usercopy region.

This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: adjust commit log]
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 fs/befs/linuxvfs.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/befs/linuxvfs.c b/fs/befs/linuxvfs.c
index 63e7c4760bfb..893607591805 100644
--- a/fs/befs/linuxvfs.c
+++ b/fs/befs/linuxvfs.c
@@ -442,11 +442,15 @@ static struct inode *befs_iget(struct super_block *sb, unsigned long ino)
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
