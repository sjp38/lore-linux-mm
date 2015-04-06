Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 375356B0110
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 16:18:46 -0400 (EDT)
Received: by qkgx75 with SMTP id x75so31420873qkg.1
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:18:46 -0700 (PDT)
Received: from mail-qc0-x230.google.com (mail-qc0-x230.google.com. [2607:f8b0:400d:c01::230])
        by mx.google.com with ESMTPS id o91si5208835qko.40.2015.04.06.13.18.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Apr 2015 13:18:45 -0700 (PDT)
Received: by qcgx3 with SMTP id x3so15357106qcg.3
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:18:45 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 07/10] writeback: use unlocked_inode_to_wb transaction in inode_congested()
Date: Mon,  6 Apr 2015 16:18:25 -0400
Message-Id: <1428351508-8399-8-git-send-email-tj@kernel.org>
In-Reply-To: <1428351508-8399-1-git-send-email-tj@kernel.org>
References: <1428351508-8399-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

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
index 97fb7f3..ee65ff09 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -596,10 +596,18 @@ void wbc_account_io(struct writeback_control *wbc, struct page *page,
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
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
