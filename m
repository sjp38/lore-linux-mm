Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 115356B0178
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:27:51 -0500 (EST)
Received: by mail-qc0-f179.google.com with SMTP id c9so77216qcz.10
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:50 -0800 (PST)
Received: from mail-qg0-x236.google.com (mail-qg0-x236.google.com. [2607:f8b0:400d:c04::236])
        by mx.google.com with ESMTPS id v109si17945374qge.78.2015.01.06.13.27.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:27:50 -0800 (PST)
Received: by mail-qg0-f54.google.com with SMTP id l89so73604qgf.13
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:49 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 44/45] mpage: make __mpage_writepage() honor cgroup writeback
Date: Tue,  6 Jan 2015 16:26:21 -0500
Message-Id: <1420579582-8516-45-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>

__mpage_writepage() is used to implement mpage_writepages() which in
turn is used for ->writepages() of various filesystems.  All writeback
logic is now updated to handle cgroup writeback and the block cgroup
to issue IOs for is encoded in writeback_control and can be retrieved
using wbc_blkcg_css(); however, __mpage_writepage() currently ignores
the blkcg indicated by wbc and issues all bio's without explicit blkcg
association.

This patch updates __mpage_writepage() so that the issued bio's are
associated with wbc_blkcg_css().

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
---
 fs/mpage.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/mpage.c b/fs/mpage.c
index 587c7ed..84921b2 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -595,6 +595,8 @@ page_is_mapped:
 
 alloc_new:
 	if (bio == NULL) {
+		struct cgroup_subsys_state *blkcg_css;
+
 		if (first_unmapped == blocks_per_page) {
 			if (!bdev_write_page(bdev, blocks[0] << (blkbits - 9),
 								page, wbc)) {
@@ -606,6 +608,10 @@ alloc_new:
 				bio_get_nr_vecs(bdev), GFP_NOFS|__GFP_HIGH);
 		if (bio == NULL)
 			goto confused;
+
+		blkcg_css = wbc_blkcg_css(wbc);
+		if (blkcg_css)
+			bio_associate_blkcg(bio, blkcg_css);
 	}
 
 	/*
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
