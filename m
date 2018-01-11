Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 18DC16B0298
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 21:09:53 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id m7so1684213pgv.17
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 18:09:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k62sor3255718pga.119.2018.01.10.18.09.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 18:09:51 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 18/38] orangefs: Define usercopy region in orangefs_inode_cache slab cache
Date: Wed, 10 Jan 2018 18:02:50 -0800
Message-Id: <1515636190-24061-19-git-send-email-keescook@chromium.org>
In-Reply-To: <1515636190-24061-1-git-send-email-keescook@chromium.org>
References: <1515636190-24061-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Mike Marshall <hubcap@omnibond.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

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

This region is known as the slab cache's usercopy region. Slab caches
can now check that each dynamically sized copy operation involving
cache-managed memory falls entirely within the slab's usercopy region.

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
index 36f1390b5ed7..62d49e53061c 100644
--- a/fs/orangefs/super.c
+++ b/fs/orangefs/super.c
@@ -610,11 +610,16 @@ void orangefs_kill_sb(struct super_block *sb)
 
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
