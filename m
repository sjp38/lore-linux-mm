Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7CEF36B0268
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 15:57:04 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id t65so11117393pfe.22
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 12:57:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k7sor447339plt.93.2018.01.09.12.57.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jan 2018 12:57:03 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 16/36] ufs: Define usercopy region in ufs_inode_cache slab cache
Date: Tue,  9 Jan 2018 12:55:45 -0800
Message-Id: <1515531365-37423-17-git-send-email-keescook@chromium.org>
In-Reply-To: <1515531365-37423-1-git-send-email-keescook@chromium.org>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Evgeniy Dushistov <dushistov@mail.ru>, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

From: David Windsor <dave@nullcore.net>

The ufs symlink pathnames, stored in struct ufs_inode_info.i_u1.i_symlink
and therefore contained in the ufs_inode_cache slab cache, need to be
copied to/from userspace.

cache object allocation:
    fs/ufs/super.c:
        ufs_alloc_inode(...):
            ...
            ei = kmem_cache_alloc(ufs_inode_cachep, GFP_NOFS);
            ...
            return &ei->vfs_inode;

    fs/ufs/ufs.h:
        UFS_I(struct inode *inode):
            return container_of(inode, struct ufs_inode_info, vfs_inode);

    fs/ufs/namei.c:
        ufs_symlink(...):
            ...
            inode->i_link = (char *)UFS_I(inode)->i_u1.i_symlink;

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
ufs_inode_cache slab cache in which userspace copy operations are allowed.

This region is known as the slab cache's usercopy region. Slab caches
can now check that each dynamically sized copy operation involving
cache-managed memory falls entirely within the slab's usercopy region.

This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: adjust commit log, provide usage trace]
Cc: Evgeniy Dushistov <dushistov@mail.ru>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 fs/ufs/super.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/ufs/super.c b/fs/ufs/super.c
index 4d497e9c6883..652a77702aec 100644
--- a/fs/ufs/super.c
+++ b/fs/ufs/super.c
@@ -1466,11 +1466,14 @@ static void init_once(void *foo)
 
 static int __init init_inodecache(void)
 {
-	ufs_inode_cachep = kmem_cache_create("ufs_inode_cache",
-					     sizeof(struct ufs_inode_info),
-					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD|SLAB_ACCOUNT),
-					     init_once);
+	ufs_inode_cachep = kmem_cache_create_usercopy("ufs_inode_cache",
+				sizeof(struct ufs_inode_info), 0,
+				(SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD|
+					SLAB_ACCOUNT),
+				offsetof(struct ufs_inode_info, i_u1.i_symlink),
+				sizeof_field(struct ufs_inode_info,
+					i_u1.i_symlink),
+				init_once);
 	if (ufs_inode_cachep == NULL)
 		return -ENOMEM;
 	return 0;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
