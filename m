Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 125BA6B0038
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 10:00:59 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id r10so5454139pdi.38
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 07:00:59 -0800 (PST)
Received: from m59-178.qiye.163.com (m59-178.qiye.163.com. [123.58.178.59])
        by mx.google.com with ESMTP id zq7si9159202pac.43.2013.12.16.07.00.57
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 07:00:58 -0800 (PST)
From: Li Wang <liwang@ubuntukylin.com>
Subject: [PATCH 4/5] VFS: Add shrink_pagecache_parent
Date: Mon, 16 Dec 2013 07:00:08 -0800
Message-Id: <2545525b8fff4d00a574c2230cd1e772785ec1d2.1387205337.git.liwang@ubuntukylin.com>
In-Reply-To: <cover.1387205337.git.liwang@ubuntukylin.com>
References: <cover.1387205337.git.liwang@ubuntukylin.com>
In-Reply-To: <cover.1387205337.git.liwang@ubuntukylin.com>
References: <cover.1387205337.git.liwang@ubuntukylin.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Sage Weil <sage@inktank.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Li Wang <liwang@ubuntukylin.com>, Yunchuan Wen <yunchuanwen@ubuntukylin.com>

Analogous to shrink_dcache_parent except that it collects inodes.
It is not very appropriate to be put in dcache.c, but d_walk can only
be invoked from here.

Signed-off-by: Li Wang <liwang@ubuntukylin.com>
Signed-off-by: Yunchuan Wen <yunchuanwen@ubuntukylin.com>
---
 fs/dcache.c |   35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/fs/dcache.c b/fs/dcache.c
index 4bdb300..bcbfd0d 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1318,6 +1318,41 @@ void shrink_dcache_parent(struct dentry *parent)
 }
 EXPORT_SYMBOL(shrink_dcache_parent);
 
+static enum d_walk_ret gather_inode(void *data, struct dentry *dentry)
+{
+	struct list_head *list = data;
+	struct inode *inode = dentry->d_inode;
+
+	if (inode == NULL)
+		goto out;
+	spin_lock(&inode->i_lock);
+	if ((inode->i_state & (I_FREEING|I_WILL_FREE|I_NEW)) ||
+	(inode->i_mapping->nrpages == 0) ||
+		(!list_empty(&inode->i_lru))) {
+		goto out_unlock;
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
