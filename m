Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0E71F280286
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:23:09 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id r1so4922351pgt.19
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:23:09 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id e62si3228073pfa.7.2018.01.17.12.23.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:23:07 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 95/99] f2fs: Convert gclist.iroot to XArray
Date: Wed, 17 Jan 2018 12:21:59 -0800
Message-Id: <20180117202203.19756-96-willy@infradead.org>
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Straightforward conversion.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/f2fs/gc.c | 14 +++++++-------
 fs/f2fs/gc.h |  2 +-
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/f2fs/gc.c b/fs/f2fs/gc.c
index aac1e02f75df..2b33068dc36b 100644
--- a/fs/f2fs/gc.c
+++ b/fs/f2fs/gc.c
@@ -417,7 +417,7 @@ static struct inode *find_gc_inode(struct gc_inode_list *gc_list, nid_t ino)
 {
 	struct inode_entry *ie;
 
-	ie = radix_tree_lookup(&gc_list->iroot, ino);
+	ie = xa_load(&gc_list->iroot, ino);
 	if (ie)
 		return ie->inode;
 	return NULL;
@@ -434,7 +434,7 @@ static void add_gc_inode(struct gc_inode_list *gc_list, struct inode *inode)
 	new_ie = f2fs_kmem_cache_alloc(inode_entry_slab, GFP_NOFS);
 	new_ie->inode = inode;
 
-	f2fs_radix_tree_insert(&gc_list->iroot, inode->i_ino, new_ie);
+	xa_store(&gc_list->iroot, inode->i_ino, new_ie, GFP_NOFS);
 	list_add_tail(&new_ie->list, &gc_list->ilist);
 }
 
@@ -442,7 +442,7 @@ static void put_gc_inode(struct gc_inode_list *gc_list)
 {
 	struct inode_entry *ie, *next_ie;
 	list_for_each_entry_safe(ie, next_ie, &gc_list->ilist, list) {
-		radix_tree_delete(&gc_list->iroot, ie->inode->i_ino);
+		xa_erase(&gc_list->iroot, ie->inode->i_ino);
 		iput(ie->inode);
 		list_del(&ie->list);
 		kmem_cache_free(inode_entry_slab, ie);
@@ -989,10 +989,10 @@ int f2fs_gc(struct f2fs_sb_info *sbi, bool sync,
 	int ret = 0;
 	struct cp_control cpc;
 	unsigned int init_segno = segno;
-	struct gc_inode_list gc_list = {
-		.ilist = LIST_HEAD_INIT(gc_list.ilist),
-		.iroot = RADIX_TREE_INIT(gc_list.iroot, GFP_NOFS),
-	};
+	struct gc_inode_list gc_list;
+
+	xa_init(&gc_list.iroot);
+	INIT_LIST_HEAD(&gc_list.ilist);
 
 	trace_f2fs_gc_begin(sbi->sb, sync, background,
 				get_pages(sbi, F2FS_DIRTY_NODES),
diff --git a/fs/f2fs/gc.h b/fs/f2fs/gc.h
index 9325191fab2d..769259b0a4f6 100644
--- a/fs/f2fs/gc.h
+++ b/fs/f2fs/gc.h
@@ -41,7 +41,7 @@ struct f2fs_gc_kthread {
 
 struct gc_inode_list {
 	struct list_head ilist;
-	struct radix_tree_root iroot;
+	struct xarray iroot;
 };
 
 /*
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
