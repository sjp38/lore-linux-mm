Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id 04EAF6B015D
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:27:23 -0500 (EST)
Received: by mail-qc0-f176.google.com with SMTP id i17so77979qcy.7
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:22 -0800 (PST)
Received: from mail-qa0-x22f.google.com (mail-qa0-x22f.google.com. [2607:f8b0:400d:c00::22f])
        by mx.google.com with ESMTPS id k92si65711126qgk.87.2015.01.06.13.27.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:27:22 -0800 (PST)
Received: by mail-qa0-f47.google.com with SMTP id n4so214319qaq.6
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:21 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 29/45] writeback: move i_wb_list emptiness test into inode_wb_list_del() from its caller
Date: Tue,  6 Jan 2015 16:26:06 -0500
Message-Id: <1420579582-8516-30-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>

inode_wb_list_del() has one caller, evict(), which tests whether
inode->i_wb_list is empty before invoking the function.  With cgroup
writeback support, an inode may belong to multiple bdi_writeback's
rendering this test incorrect or at least insufficient.  This patch
moves the test into inode_wb_list_del() so that later patches can
update the logic in the function proper.

This does add a function call and jump when a clean inode is being
evicted but this shouldn't be anything noticeable and if it ever is
making that part an inline logic in fs/internal.h is easy.

This patch is pure code reorganization.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c | 3 +++
 fs/inode.c        | 4 +---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 4094d30..0fcdfe9 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -510,6 +510,9 @@ void inode_wb_list_del(struct inode *inode)
 	struct backing_dev_info *bdi = inode_to_bdi(inode);
 	struct bdi_writeback *wb = &bdi->wb;
 
+	if (list_empty(&inode->i_wb_list))
+		return;
+
 	spin_lock(&wb->list_lock);
 	inode_wb_list_del_locked(inode, wb);
 	spin_unlock(&wb->list_lock);
diff --git a/fs/inode.c b/fs/inode.c
index aa149e7..7fbfc00 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -536,9 +536,7 @@ static void evict(struct inode *inode)
 	BUG_ON(!(inode->i_state & I_FREEING));
 	BUG_ON(!list_empty(&inode->i_lru));
 
-	if (!list_empty(&inode->i_wb_list))
-		inode_wb_list_del(inode);
-
+	inode_wb_list_del(inode);
 	inode_sb_list_del(inode);
 
 	/*
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
