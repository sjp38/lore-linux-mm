Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 560ED6B02FA
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 19:36:48 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c12so4766309pfk.3
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:36:48 -0700 (PDT)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id y67si6005426pfy.16.2017.06.19.16.36.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 16:36:47 -0700 (PDT)
Received: by mail-pf0-x236.google.com with SMTP id c73so603835pfk.2
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:36:47 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 03/23] vfs: define usercopy region in names_cache slab caches
Date: Mon, 19 Jun 2017 16:36:17 -0700
Message-Id: <1497915397-93805-4-git-send-email-keescook@chromium.org>
In-Reply-To: <1497915397-93805-1-git-send-email-keescook@chromium.org>
References: <1497915397-93805-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: David Windsor <dave@nullcore.net>

vfs pathnames stored internally in inodes and contained in
the names_cache slab cache need to be copied to/from userspace.

In support of usercopy hardening, this patch defines the entire
cache object in the names_cache slab cache as whitelisted, since
it holds name strings to be copied to userspace.

This patch is verbatim from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: adjust commit log]
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 fs/dcache.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index cddf39777835..f7f3c4114baa 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -3616,8 +3616,8 @@ void __init vfs_caches_init_early(void)
 
 void __init vfs_caches_init(void)
 {
-	names_cachep = kmem_cache_create("names_cache", PATH_MAX, 0,
-			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
+	names_cachep = kmem_cache_create_usercopy("names_cache", PATH_MAX, 0,
+			SLAB_HWCACHE_ALIGN|SLAB_PANIC, 0, PATH_MAX, NULL);
 
 	dcache_init();
 	inode_init();
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
