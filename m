Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 44B306B02BB
	for <linux-mm@kvack.org>; Fri, 22 May 2015 18:36:39 -0400 (EDT)
Received: by qgfa63 with SMTP id a63so17272973qgf.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:36:39 -0700 (PDT)
Received: from mail-qg0-x22f.google.com (mail-qg0-x22f.google.com. [2607:f8b0:400d:c04::22f])
        by mx.google.com with ESMTPS id f4si3927944qce.30.2015.05.22.15.36.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 15:36:38 -0700 (PDT)
Received: by qget53 with SMTP id t53so17183823qge.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:36:38 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 6/9] writeback: use unlocked_inode_to_wb transaction in inode_congested()
Date: Fri, 22 May 2015 18:36:20 -0400
Message-Id: <1432334183-6324-7-git-send-email-tj@kernel.org>
In-Reply-To: <1432334183-6324-1-git-send-email-tj@kernel.org>
References: <1432334183-6324-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

Similar to wb stat updates, inode_congested() accesses the associated
wb of an inode locklessly, which will break with foreign inode wb
switching.  This path updates inode_congested() to use unlocked inode
wb access transaction introduced by the previous patch.

Combined with the previous two patches, this makes all wb list and
access operations to be protected by either of inode->i_lock,
wb->list_lock, or mapping->tree_lock while wb switching is in
progress.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
---
 fs/fs-writeback.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 118e9c4..eb94b00 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -609,10 +609,18 @@ void wbc_account_io(struct writeback_control *wbc, struct page *page,
  */
 int inode_congested(struct inode *inode, int cong_bits)
 {
-	if (inode) {
-		struct bdi_writeback *wb = inode_to_wb(inode);
-		if (wb)
-			return wb_congested(wb, cong_bits);
+	/*
+	 * Once set, ->i_wb never becomes NULL while the inode is alive.
+	 * Start transaction iff ->i_wb is visible.
+	 */
+	if (inode && inode_to_wb(inode)) {
+		struct bdi_writeback *wb;
+		bool locked, congested;
+
+		wb = unlocked_inode_to_wb_begin(inode, &locked);
+		congested = wb_congested(wb, cong_bits);
+		unlocked_inode_to_wb_end(inode, locked);
+		return congested;
 	}
 
 	return wb_congested(&inode_to_bdi(inode)->wb, cong_bits);
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
