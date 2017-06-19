Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 68A996B039F
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 19:43:19 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u36so105051217pgn.5
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:43:19 -0700 (PDT)
Received: from mail-pg0-x233.google.com (mail-pg0-x233.google.com. [2607:f8b0:400e:c05::233])
        by mx.google.com with ESMTPS id j3si9320745pgs.370.2017.06.19.16.43.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 16:43:18 -0700 (PDT)
Received: by mail-pg0-x233.google.com with SMTP id u62so35523989pgb.3
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:43:18 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 19/23] xfs: define usercopy region in xfs_inode slab cache
Date: Mon, 19 Jun 2017 16:36:33 -0700
Message-Id: <1497915397-93805-20-git-send-email-keescook@chromium.org>
In-Reply-To: <1497915397-93805-1-git-send-email-keescook@chromium.org>
References: <1497915397-93805-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: David Windsor <dave@nullcore.net>

XFS inline inode data, stored in struct xfs_inode_t.i_df.if_u2.if_inline_data
and therefore contained in the xfs_inode slab cache, needs to be copied
to/from userspace.

In support of usercopy hardening, this patch defines a region in
the xfs_inode slab cache in which userspace copy operations
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
 fs/xfs/kmem.h      | 10 ++++++++++
 fs/xfs/xfs_super.c |  7 +++++--
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/fs/xfs/kmem.h b/fs/xfs/kmem.h
index d6ea520162b2..b3f02b6226b3 100644
--- a/fs/xfs/kmem.h
+++ b/fs/xfs/kmem.h
@@ -100,6 +100,16 @@ kmem_zone_init_flags(int size, char *zone_name, unsigned long flags,
 	return kmem_cache_create(zone_name, size, 0, flags, construct);
 }
 
+static inline kmem_zone_t *
+kmem_zone_init_flags_usercopy(int size, char *zone_name, unsigned long flags,
+				size_t useroffset, size_t usersize,
+				void (*construct)(void *))
+{
+	return kmem_cache_create_usercopy(zone_name, size, 0, flags,
+				useroffset, usersize, construct);
+}
+
+
 static inline void
 kmem_zone_free(kmem_zone_t *zone, void *ptr)
 {
diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
index 455a575f101d..b6963baa3ac8 100644
--- a/fs/xfs/xfs_super.c
+++ b/fs/xfs/xfs_super.c
@@ -1828,9 +1828,12 @@ xfs_init_zones(void)
 		goto out_destroy_efd_zone;
 
 	xfs_inode_zone =
-		kmem_zone_init_flags(sizeof(xfs_inode_t), "xfs_inode",
+		kmem_zone_init_flags_usercopy(sizeof(xfs_inode_t), "xfs_inode",
 			KM_ZONE_HWALIGN | KM_ZONE_RECLAIM | KM_ZONE_SPREAD |
-			KM_ZONE_ACCOUNT, xfs_fs_inode_init_once);
+				KM_ZONE_ACCOUNT,
+			offsetof(xfs_inode_t, i_df.if_u2.if_inline_data),
+			sizeof_field(xfs_inode_t, i_df.if_u2.if_inline_data),
+			xfs_fs_inode_init_once);
 	if (!xfs_inode_zone)
 		goto out_destroy_efi_zone;
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
