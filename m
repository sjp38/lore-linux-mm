Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9F5AD6B026C
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 21:03:32 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id e12so1693593pga.5
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 18:03:32 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o2sor3658454pge.239.2018.01.10.18.03.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 18:03:31 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 11/38] vfs: Define usercopy region in names_cache slab caches
Date: Wed, 10 Jan 2018 18:02:43 -0800
Message-Id: <1515636190-24061-12-git-send-email-keescook@chromium.org>
In-Reply-To: <1515636190-24061-1-git-send-email-keescook@chromium.org>
References: <1515636190-24061-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-arch@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

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
index 92ad7a2168e1..9d7ee2de682c 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -3640,8 +3640,8 @@ void __init vfs_caches_init_early(void)
 
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
