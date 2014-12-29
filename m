Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4CD766B006E
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 09:50:15 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id z10so17450521pdj.28
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 06:50:15 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id wa6si11970162pab.88.2014.12.29.06.50.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 29 Dec 2014 06:50:13 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NHC00GSXMQGGG50@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 29 Dec 2014 14:54:16 +0000 (GMT)
From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [RFC PATCH 2/4] kernfs: use kstrdup_const for node name allocation
Date: Mon, 29 Dec 2014 15:48:28 +0100
Message-id: <1419864510-24834-3-git-send-email-a.hajda@samsung.com>
In-reply-to: <1419864510-24834-1-git-send-email-a.hajda@samsung.com>
References: <1419864510-24834-1-git-send-email-a.hajda@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrzej Hajda <a.hajda@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org

sysfs frequently performs duplication of strings located
in read-only memory section. Replacing kstrdup by kstrdup_const
allows to avoid such operations.

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
---
 fs/kernfs/dir.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/kernfs/dir.c b/fs/kernfs/dir.c
index 37989f0..259e92a 100644
--- a/fs/kernfs/dir.c
+++ b/fs/kernfs/dir.c
@@ -408,7 +408,7 @@ void kernfs_put(struct kernfs_node *kn)
 	if (kernfs_type(kn) == KERNFS_LINK)
 		kernfs_put(kn->symlink.target_kn);
 	if (!(kn->flags & KERNFS_STATIC_NAME))
-		kfree(kn->name);
+		kfree_const(kn->name);
 	if (kn->iattr) {
 		if (kn->iattr->ia_secdata)
 			security_release_secctx(kn->iattr->ia_secdata,
@@ -502,12 +502,12 @@ static struct kernfs_node *__kernfs_new_node(struct kernfs_root *root,
 					     const char *name, umode_t mode,
 					     unsigned flags)
 {
-	char *dup_name = NULL;
+	const char *dup_name = NULL;
 	struct kernfs_node *kn;
 	int ret;
 
 	if (!(flags & KERNFS_STATIC_NAME)) {
-		name = dup_name = kstrdup(name, GFP_KERNEL);
+		name = dup_name = kstrdup_const(name, GFP_KERNEL);
 		if (!name)
 			return NULL;
 	}
@@ -534,7 +534,7 @@ static struct kernfs_node *__kernfs_new_node(struct kernfs_root *root,
  err_out2:
 	kmem_cache_free(kernfs_node_cache, kn);
  err_out1:
-	kfree(dup_name);
+	kfree_const(dup_name);
 	return NULL;
 }
 
@@ -1260,7 +1260,7 @@ int kernfs_rename_ns(struct kernfs_node *kn, struct kernfs_node *new_parent,
 	/* rename kernfs_node */
 	if (strcmp(kn->name, new_name) != 0) {
 		error = -ENOMEM;
-		new_name = kstrdup(new_name, GFP_KERNEL);
+		new_name = kstrdup_const(new_name, GFP_KERNEL);
 		if (!new_name)
 			goto out;
 	} else {
@@ -1293,7 +1293,7 @@ int kernfs_rename_ns(struct kernfs_node *kn, struct kernfs_node *new_parent,
 	kernfs_link_sibling(kn);
 
 	kernfs_put(old_parent);
-	kfree(old_name);
+	kfree_const(old_name);
 
 	error = 0;
  out:
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
