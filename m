Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 621A56B0338
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 19:36:53 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 132so49530169pgb.6
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:36:53 -0700 (PDT)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id c2si9380927pge.525.2017.06.19.16.36.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 16:36:52 -0700 (PDT)
Received: by mail-pf0-x22b.google.com with SMTP id s66so60755511pfs.1
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:36:52 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 09/23] ext4: define usercopy region in ext4_inode_cache slab cache
Date: Mon, 19 Jun 2017 16:36:23 -0700
Message-Id: <1497915397-93805-10-git-send-email-keescook@chromium.org>
In-Reply-To: <1497915397-93805-1-git-send-email-keescook@chromium.org>
References: <1497915397-93805-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: David Windsor <dave@nullcore.net>

The ext4 symlink pathnames, stored in struct ext4_inode_info.i_data
and therefore contained in the ext4_inode_cache slab cache, need
to be copied to/from userspace.

In support of usercopy hardening, this patch defines a region in
the ext4_inode_cache slab cache in which userspace copy operations
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
 fs/ext4/super.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index d37c81f327e7..bd92123cf1fc 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1031,11 +1031,13 @@ static void init_once(void *foo)
 
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
