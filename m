Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id F336D6B0315
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 19:36:50 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id f185so125894252pgc.10
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:36:50 -0700 (PDT)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id r25si9031450pfg.401.2017.06.19.16.36.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 16:36:50 -0700 (PDT)
Received: by mail-pf0-x22f.google.com with SMTP id s66so60755160pfs.1
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:36:50 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 07/23] exofs: define usercopy region in exofs_inode_cache slab cache
Date: Mon, 19 Jun 2017 16:36:21 -0700
Message-Id: <1497915397-93805-8-git-send-email-keescook@chromium.org>
In-Reply-To: <1497915397-93805-1-git-send-email-keescook@chromium.org>
References: <1497915397-93805-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: David Windsor <dave@nullcore.net>

exofs short symlink names and device #'s, stored in struct
exofs_i_info.i_data and therefore contained in the exofs_inode_cache
slab cache, need to be copied to/from userspace.

In support of usercopy hardening, this patch defines a region in
the exofs_inode_cache slab cache in which userspace copy operations
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
