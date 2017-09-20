Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8E0056B0287
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 16:46:04 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id j16so7368049pga.6
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 13:46:04 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l5sor1459919pli.3.2017.09.20.13.46.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 13:46:03 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 05/31] vfs: Define usercopy region in names_cache slab caches
Date: Wed, 20 Sep 2017 13:45:11 -0700
Message-Id: <1505940337-79069-6-git-send-email-keescook@chromium.org>
In-Reply-To: <1505940337-79069-1-git-send-email-keescook@chromium.org>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

From: David Windsor <dave@nullcore.net>

VFS pathnames are stored in the names_cache slab cache, either inline
or across an entire allocation entry (when approaching PATH_MAX). These
are copied to/from userspace, so they must be entirely whitelisted.

cache object allocation:
    include/linux/fs.h:
        #define __getname()    kmem_cache_alloc(names_cachep, GFP_KERNEL)

example usage trace:
    strncpy_from_user+0x4d/0x170
    getname_flags+0x6f/0x1f0
    user_path_at_empty+0x23/0x40
    do_mount+0x69/0xda0
    SyS_mount+0x83/0xd0

    fs/namei.c:
        getname_flags(...):
            ...
            result = __getname();
            ...
            kname = (char *)result->iname;
            result->name = kname;
            len = strncpy_from_user(kname, filename, EMBEDDED_NAME_MAX);
            ...
            if (unlikely(len == EMBEDDED_NAME_MAX)) {
                const size_t size = offsetof(struct filename, iname[1]);
                kname = (char *)result;

                result = kzalloc(size, GFP_KERNEL);
                ...
                result->name = kname;
                len = strncpy_from_user(kname, filename, PATH_MAX);

In support of usercopy hardening, this patch defines the entire cache
object in the names_cache slab cache as whitelisted, since it may entirely
hold name strings to be copied to/from userspace.

This patch is verbatim from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: adjust commit log, add usage trace]
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 fs/dcache.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 5f5e7c1fcf4b..34ef9a9169be 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -3642,8 +3642,8 @@ void __init vfs_caches_init_early(void)
 
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
