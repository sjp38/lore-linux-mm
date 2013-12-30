Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 791AD6B0038
	for <linux-mm@kvack.org>; Mon, 30 Dec 2013 08:46:00 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so11548475pab.6
        for <linux-mm@kvack.org>; Mon, 30 Dec 2013 05:46:00 -0800 (PST)
Received: from m59-178.qiye.163.com (m59-178.qiye.163.com. [123.58.178.59])
        by mx.google.com with ESMTP id k3si11859586pbb.84.2013.12.30.05.45.57
        for <linux-mm@kvack.org>;
        Mon, 30 Dec 2013 05:45:58 -0800 (PST)
From: Li Wang <liwang@ubuntukylin.com>
Subject: [PATCH 2/3] Add shrink_pagecache_parent
Date: Mon, 30 Dec 2013 21:45:17 +0800
Message-Id: <249cbd3edaa84dd58a0626780fb546ddf7c1dc11.1388409687.git.liwang@ubuntukylin.com>
In-Reply-To: <cover.1388409686.git.liwang@ubuntukylin.com>
References: <cover.1388409686.git.liwang@ubuntukylin.com>
In-Reply-To: <cover.1388409686.git.liwang@ubuntukylin.com>
References: <cover.1388409686.git.liwang@ubuntukylin.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, Zefan Li <lizefan@huawei.com>, Matthew Wilcox <matthew@wil.cx>, Li Wang <liwang@ubuntukylin.com>, Yunchuan Wen <yunchuanwen@ubuntukylin.com>

Analogous to shrink_dcache_parent except that it collects inodes.
It is not very appropriate to be put in dcache.c, but d_walk can only
be invoked from here.

Signed-off-by: Li Wang <liwang@ubuntukylin.com>
Signed-off-by: Yunchuan Wen <yunchuanwen@ubuntukylin.com>
---
 fs/dcache.c |   36 ++++++++++++++++++++++++++++++++++++
 1 file changed, 36 insertions(+)

diff --git a/fs/dcache.c b/fs/dcache.c
index 6055d61..0fc0f80 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1318,6 +1318,42 @@ void shrink_dcache_parent(struct dentry *parent)
 }
 EXPORT_SYMBOL(shrink_dcache_parent);
 
+static enum d_walk_ret gather_inode(void *data, struct dentry *dentry)
+{
+	struct list_head *list = data;
+	struct inode *inode = dentry->d_inode;
+
+	if ((inode == NULL) || ((!inode_owner_or_capable(inode)) &&
+				(!capable(CAP_SYS_ADMIN))))
+		goto out;
+	spin_lock(&inode->i_lock);
+	if ((inode->i_state & (I_FREEING|I_WILL_FREE|I_NEW)) ||
+		(inode->i_mapping->nrpages == 0) ||
+		(!list_empty(&inode->i_lru))) {
+			goto out_unlock;
+	}
+	__iget(inode);
+	list_add_tail(&inode->i_lru, list);
+out_unlock:
+	spin_unlock(&inode->i_lock);
+out:
+	return D_WALK_CONTINUE;
+}
+
+void shrink_pagecache_parent(struct dentry *parent)
+{
+	LIST_HEAD(list);
+	struct inode *inode, *next;
+
+	d_walk(parent, &list, gather_inode, NULL);
+	list_for_each_entry_safe(inode, next, &list, i_lru) {
+		list_del_init(&inode->i_lru);
+		invalidate_mapping_pages(inode->i_mapping, 0, -1);
+		iput(inode);
+	}
+}
+EXPORT_SYMBOL(shrink_pagecache_parent);
+
 static enum d_walk_ret umount_collect(void *_data, struct dentry *dentry)
 {
 	struct select_data *data = _data;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
