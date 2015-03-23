Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6AF0282995
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 01:26:00 -0400 (EDT)
Received: by qgep97 with SMTP id p97so5997445qge.1
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 22:26:00 -0700 (PDT)
Received: from mail-qc0-x22f.google.com (mail-qc0-x22f.google.com. [2607:f8b0:400d:c01::22f])
        by mx.google.com with ESMTPS id w8si11308476qcn.34.2015.03.22.22.25.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 22:25:59 -0700 (PDT)
Received: by qcto4 with SMTP id o4so136981942qct.3
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 22:25:59 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 5/8] writeback: implement [locked_]inode_to_wb_and_lock_list()
Date: Mon, 23 Mar 2015 01:25:41 -0400
Message-Id: <1427088344-17542-6-git-send-email-tj@kernel.org>
In-Reply-To: <1427088344-17542-1-git-send-email-tj@kernel.org>
References: <1427088344-17542-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

cgroup writeback currently assumes that inode to wb association
doesn't change; however, with the planned foreign inode wb switching
mechanism, the association will change dynamically.

When an inode needs to be put on one of the IO lists of its wb, the
current code simply calls inode_to_wb() and locks the returned wb;
however, with the planned wb switching, the association may change
before locking the wb and may even get released.

This patch implements [locked_]inode_to_wb_and_lock_list() which pins
the associated wb while holding i_lock, releases it, acquires
wb->list_lock and verifies that the association hasn't changed
inbetween.  As the association will be protected by both locks among
other things, this guarantees that the wb is the inode's associated wb
until the list_lock is released.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
---
 fs/fs-writeback.c | 80 +++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 75 insertions(+), 5 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 478d26e..e888c4b 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -246,6 +246,56 @@ void __inode_attach_wb(struct inode *inode, struct page *page)
 }
 
 /**
+ * locked_inode_to_wb_and_lock_list - determine a locked inode's wb and lock it
+ * @inode: inode of interest with i_lock held
+ *
+ * Returns @inode's wb with its list_lock held.  @inode->i_lock must be
+ * held on entry and is released on return.  The returned wb is guaranteed
+ * to stay @inode's associated wb until its list_lock is released.
+ */
+static struct bdi_writeback *
+locked_inode_to_wb_and_lock_list(struct inode *inode)
+	__releases(&inode->i_lock)
+	__acquires(&wb->list_lock)
+{
+	while (true) {
+		struct bdi_writeback *wb = inode_to_wb(inode);
+
+		/*
+		 * inode_to_wb() association is protected by both
+		 * @inode->i_lock and @wb->list_lock but list_lock nests
+		 * outside i_lock.  Drop i_lock and verify that the
+		 * association hasn't changed after acquiring list_lock.
+		 */
+		wb_get(wb);
+		spin_unlock(&inode->i_lock);
+		spin_lock(&wb->list_lock);
+		wb_put(wb);		/* not gonna deref it anymore */
+
+		if (likely(wb == inode_to_wb(inode)))
+			return wb;	/* @inode already has ref */
+
+		spin_unlock(&wb->list_lock);
+		cpu_relax();
+		spin_lock(&inode->i_lock);
+	}
+}
+
+/**
+ * inode_to_wb_and_lock_list - determine an inode's wb and lock it
+ * @inode: inode of interest
+ *
+ * Same as locked_inode_to_wb_and_lock_list() but @inode->i_lock isn't held
+ * on entry.
+ */
+static struct bdi_writeback *inode_to_wb_and_lock_list(struct inode *inode)
+	__acquires(&wb->list_lock)
+{
+	spin_lock(&inode->i_lock);
+	return locked_inode_to_wb_and_lock_list(inode);
+}
+
+/**
  * wbc_attach_and_unlock_inode - associate wbc with target inode and unlock it
  * @wbc: writeback_control of interest
  * @inode: target inode
@@ -591,6 +641,27 @@ restart:
 
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
+static struct bdi_writeback *
+locked_inode_to_wb_and_lock_list(struct inode *inode)
+	__releases(&inode->i_lock)
+	__acquires(&wb->list_lock)
+{
+	struct bdi_writeback *wb = inode_to_wb(inode);
+
+	spin_unlock(&inode->i_lock);
+	spin_lock(&wb->list_lock);
+	return wb;
+}
+
+static struct bdi_writeback *inode_to_wb_and_lock_list(struct inode *inode)
+	__acquires(&wb->list_lock)
+{
+	struct bdi_writeback *wb = inode_to_wb(inode);
+
+	spin_lock(&wb->list_lock);
+	return wb;
+}
+
 static long wb_split_bdi_pages(struct bdi_writeback *wb, long nr_pages)
 {
 	return nr_pages;
@@ -666,9 +737,9 @@ void wb_start_background_writeback(struct bdi_writeback *wb)
  */
 void inode_wb_list_del(struct inode *inode)
 {
-	struct bdi_writeback *wb = inode_to_wb(inode);
+	struct bdi_writeback *wb;
 
-	spin_lock(&wb->list_lock);
+	wb = inode_to_wb_and_lock_list(inode);
 	inode_wb_list_del_locked(inode, wb);
 	spin_unlock(&wb->list_lock);
 }
@@ -1713,11 +1784,10 @@ void __mark_inode_dirty(struct inode *inode, int flags)
 		 * reposition it (that would break b_dirty time-ordering).
 		 */
 		if (!was_dirty) {
-			struct bdi_writeback *wb = inode_to_wb(inode);
+			struct bdi_writeback *wb;
 			bool wakeup_bdi = false;
 
-			spin_unlock(&inode->i_lock);
-			spin_lock(&wb->list_lock);
+			wb = locked_inode_to_wb_and_lock_list(inode);
 
 			WARN(bdi_cap_writeback_dirty(wb->bdi) &&
 			     !test_bit(WB_registered, &wb->state),
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
