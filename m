Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9588A6B0283
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 15:57:22 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id a9so8147463pgf.12
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 12:57:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f13sor3006237pgu.303.2018.01.09.12.57.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jan 2018 12:57:21 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 07/36] dcache: Define usercopy region in dentry_cache slab cache
Date: Tue,  9 Jan 2018 12:55:36 -0800
Message-Id: <1515531365-37423-8-git-send-email-keescook@chromium.org>
In-Reply-To: <1515531365-37423-1-git-send-email-keescook@chromium.org>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-arch@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

From: David Windsor <dave@nullcore.net>

When a dentry name is short enough, it can be stored directly in the
dentry itself (instead in a separate kmalloc allocation). These dentry
short names, stored in struct dentry.d_iname and therefore contained in
the dentry_cache slab cache, need to be coped to userspace.

cache object allocation:
    fs/dcache.c:
        __d_alloc(...):
            ...
            dentry = kmem_cache_alloc(dentry_cache, ...);
            ...
            dentry->d_name.name = dentry->d_iname;

example usage trace:
    filldir+0xb0/0x140
    dcache_readdir+0x82/0x170
    iterate_dir+0x142/0x1b0
    SyS_getdents+0xb5/0x160

    fs/readdir.c:
        (called via ctx.actor by dir_emit)
        filldir(..., const char *name, ...):
            ...
            copy_to_user(..., name, namlen)

    fs/libfs.c:
        dcache_readdir(...):
            ...
            next = next_positive(dentry, p, 1)
            ...
            dir_emit(..., next->d_name.name, ...)

In support of usercopy hardening, this patch defines a region in the
dentry_cache slab cache in which userspace copy operations are allowed.

This region is known as the slab cache's usercopy region. Slab caches can
now check that each dynamic copy operation involving cache-managed memory
falls entirely within the slab's usercopy region.

This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: adjust hunks for kmalloc-specific things moved later]
[kees: adjust commit log, provide usage trace]
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 fs/dcache.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 5c7df1df81ff..92ad7a2168e1 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -3601,8 +3601,9 @@ static void __init dcache_init(void)
 	 * but it is probably not worth it because of the cache nature
 	 * of the dcache.
 	 */
-	dentry_cache = KMEM_CACHE(dentry,
-		SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD|SLAB_ACCOUNT);
+	dentry_cache = KMEM_CACHE_USERCOPY(dentry,
+		SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD|SLAB_ACCOUNT,
+		d_iname);
 
 	/* Hash may have been set up in dcache_init_early */
 	if (!hashdist)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
