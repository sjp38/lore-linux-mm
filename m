Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1D2CF6B006E
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 04:20:09 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ey11so30997675pad.10
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 01:20:08 -0800 (PST)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id ke10si22387683pbc.235.2015.01.12.01.20.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 12 Jan 2015 01:20:07 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NI2004EV4S5LF10@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 12 Jan 2015 09:24:05 +0000 (GMT)
From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [PATCH 2/5] kernfs: convert node name allocation to kstrdup_const
Date: Mon, 12 Jan 2015 10:18:40 +0100
Message-id: <1421054323-14430-3-git-send-email-a.hajda@samsung.com>
In-reply-to: <1421054323-14430-1-git-send-email-a.hajda@samsung.com>
References: <1421054323-14430-1-git-send-email-a.hajda@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrzej Hajda <a.hajda@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, linux-kernel@vger.kernel.org, andi@firstfloor.org, andi@lisas.de, Mike Turquette <mturquette@linaro.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

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
