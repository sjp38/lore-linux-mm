Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 250826B025E
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 21:09:37 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id o9so1728558pgv.3
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 18:09:37 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q4sor5617017plk.72.2018.01.10.18.09.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 18:09:36 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 20/38] vxfs: Define usercopy region in vxfs_inode slab cache
Date: Wed, 10 Jan 2018 18:02:52 -0800
Message-Id: <1515636190-24061-21-git-send-email-keescook@chromium.org>
In-Reply-To: <1515636190-24061-1-git-send-email-keescook@chromium.org>
References: <1515636190-24061-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Christoph Hellwig <hch@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

From: David Windsor <dave@nullcore.net>

vxfs symlink pathnames, stored in struct vxfs_inode_info field
vii_immed.vi_immed and therefore contained in the vxfs_inode slab cache,
need to be copied to/from userspace.

cache object allocation:
    fs/freevxfs/vxfs_super.c:
        vxfs_alloc_inode(...):
            ...
            vi = kmem_cache_alloc(vxfs_inode_cachep, GFP_KERNEL);
            ...
            return &vi->vfs_inode;

    fs/freevxfs/vxfs_inode.c:
        cxfs_iget(...):
            ...
            inode->i_link = vip->vii_immed.vi_immed;

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
vxfs_inode slab cache in which userspace copy operations are allowed.

This region is known as the slab cache's usercopy region. Slab caches
can now check that each dynamically sized copy operation involving
cache-managed memory falls entirely within the slab's usercopy region.

This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: adjust commit log, provide usage trace]
Cc: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 fs/freevxfs/vxfs_super.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/freevxfs/vxfs_super.c b/fs/freevxfs/vxfs_super.c
index f989efa051a0..48b24bb50d02 100644
--- a/fs/freevxfs/vxfs_super.c
+++ b/fs/freevxfs/vxfs_super.c
@@ -332,9 +332,13 @@ vxfs_init(void)
 {
 	int rv;
 
-	vxfs_inode_cachep = kmem_cache_create("vxfs_inode",
+	vxfs_inode_cachep = kmem_cache_create_usercopy("vxfs_inode",
 			sizeof(struct vxfs_inode_info), 0,
-			SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD, NULL);
+			SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD,
+			offsetof(struct vxfs_inode_info, vii_immed.vi_immed),
+			sizeof_field(struct vxfs_inode_info,
+				vii_immed.vi_immed),
+			NULL);
 	if (!vxfs_inode_cachep)
 		return -ENOMEM;
 	rv = register_filesystem(&vxfs_fs_type);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
