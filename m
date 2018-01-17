Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8506C280286
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:23:17 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id s22so3479817pfh.21
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:23:17 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id u2si5185724plj.712.2018.01.17.12.23.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:23:16 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 91/99] btrfs: Convert name_cache to XArray
Date: Wed, 17 Jan 2018 12:21:55 -0800
Message-Id: <20180117202203.19756-92-willy@infradead.org>
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

This is a very straightforward conversion.  The handling of collisions
in the namecache could be better handled with an hlist, but that's a
patch for another day.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/btrfs/send.c | 19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

diff --git a/fs/btrfs/send.c b/fs/btrfs/send.c
index 20d3300bd268..3891a8e958fa 100644
--- a/fs/btrfs/send.c
+++ b/fs/btrfs/send.c
@@ -23,7 +23,7 @@
 #include <linux/mount.h>
 #include <linux/xattr.h>
 #include <linux/posix_acl_xattr.h>
-#include <linux/radix-tree.h>
+#include <linux/xarray.h>
 #include <linux/vmalloc.h>
 #include <linux/string.h>
 #include <linux/compat.h>
@@ -118,7 +118,7 @@ struct send_ctx {
 	struct list_head new_refs;
 	struct list_head deleted_refs;
 
-	struct radix_tree_root name_cache;
+	struct xarray name_cache;
 	struct list_head name_cache_list;
 	int name_cache_size;
 
@@ -2021,8 +2021,7 @@ static int name_cache_insert(struct send_ctx *sctx,
 	int ret = 0;
 	struct list_head *nce_head;
 
-	nce_head = radix_tree_lookup(&sctx->name_cache,
-			(unsigned long)nce->ino);
+	nce_head = xa_load(&sctx->name_cache, (unsigned long)nce->ino);
 	if (!nce_head) {
 		nce_head = kmalloc(sizeof(*nce_head), GFP_KERNEL);
 		if (!nce_head) {
@@ -2031,7 +2030,8 @@ static int name_cache_insert(struct send_ctx *sctx,
 		}
 		INIT_LIST_HEAD(nce_head);
 
-		ret = radix_tree_insert(&sctx->name_cache, nce->ino, nce_head);
+		ret = xa_insert(&sctx->name_cache, nce->ino, nce_head,
+								GFP_KERNEL);
 		if (ret < 0) {
 			kfree(nce_head);
 			kfree(nce);
@@ -2050,8 +2050,7 @@ static void name_cache_delete(struct send_ctx *sctx,
 {
 	struct list_head *nce_head;
 
-	nce_head = radix_tree_lookup(&sctx->name_cache,
-			(unsigned long)nce->ino);
+	nce_head = xa_load(&sctx->name_cache, (unsigned long)nce->ino);
 	if (!nce_head) {
 		btrfs_err(sctx->send_root->fs_info,
 	      "name_cache_delete lookup failed ino %llu cache size %d, leaking memory",
@@ -2066,7 +2065,7 @@ static void name_cache_delete(struct send_ctx *sctx,
 	 * We may not get to the final release of nce_head if the lookup fails
 	 */
 	if (nce_head && list_empty(nce_head)) {
-		radix_tree_delete(&sctx->name_cache, (unsigned long)nce->ino);
+		xa_erase(&sctx->name_cache, (unsigned long)nce->ino);
 		kfree(nce_head);
 	}
 }
@@ -2077,7 +2076,7 @@ static struct name_cache_entry *name_cache_search(struct send_ctx *sctx,
 	struct list_head *nce_head;
 	struct name_cache_entry *cur;
 
-	nce_head = radix_tree_lookup(&sctx->name_cache, (unsigned long)ino);
+	nce_head = xa_load(&sctx->name_cache, (unsigned long)ino);
 	if (!nce_head)
 		return NULL;
 
@@ -6526,7 +6525,7 @@ long btrfs_ioctl_send(struct file *mnt_file, struct btrfs_ioctl_send_args *arg)
 
 	INIT_LIST_HEAD(&sctx->new_refs);
 	INIT_LIST_HEAD(&sctx->deleted_refs);
-	INIT_RADIX_TREE(&sctx->name_cache, GFP_KERNEL);
+	xa_init(&sctx->name_cache);
 	INIT_LIST_HEAD(&sctx->name_cache_list);
 
 	sctx->flags = arg->flags;
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
