Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1F4EF6B013F
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:26:55 -0500 (EST)
Received: by mail-qc0-f181.google.com with SMTP id m20so64450qcx.26
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:26:55 -0800 (PST)
Received: from mail-qg0-x229.google.com (mail-qg0-x229.google.com. [2607:f8b0:400d:c04::229])
        by mx.google.com with ESMTPS id j93si43917433qgj.24.2015.01.06.13.26.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:26:54 -0800 (PST)
Received: by mail-qg0-f41.google.com with SMTP id e89so80770qgf.0
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:26:53 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 14/45] writeback: implement backing_dev_info->tot_write_bandwidth
Date: Tue,  6 Jan 2015 16:25:51 -0500
Message-Id: <1420579582-8516-15-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>

cgroup writeback support needs to keep track of the sum of
avg_write_bandwidth of all wb's (bdi_writeback's) with dirty inodes to
distribute write workload.  This patch adds bdi->tot_write_bandwidth
and updates inode_wb_list_move_locked(), inode_wb_list_del_locked()
and wb_update_write_bandwidth() to adjust it as wb's gain and lose
dirty inodes and its avg_write_bandwidth gets updated.

As the update events are not synchronized with each other,
bdi->tot_write_bandwidth is an atomic_long_t.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c                | 7 ++++++-
 include/linux/backing-dev-defs.h | 2 ++
 mm/page-writeback.c              | 3 +++
 3 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 1718f5f..d41728b 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -312,6 +312,8 @@ static bool inode_wb_list_move_locked(struct inode *inode,
 		return false;
 	} else {
 		set_bit(WB_has_dirty_io, &wb->state);
+		atomic_long_add(wb->avg_write_bandwidth,
+				&wb->bdi->tot_write_bandwidth);
 		return true;
 	}
 }
@@ -332,8 +334,11 @@ static void inode_wb_list_del_locked(struct inode *inode,
 	list_del_init(&inode->i_wb_list);
 
 	if (wb_has_dirty_io(wb) && list_empty(&wb->b_dirty) &&
-	    list_empty(&wb->b_io) && list_empty(&wb->b_more_io))
+	    list_empty(&wb->b_io) && list_empty(&wb->b_more_io)) {
 		clear_bit(WB_has_dirty_io, &wb->state);
+		atomic_long_sub(wb->avg_write_bandwidth,
+				&wb->bdi->tot_write_bandwidth);
+	}
 }
 
 /*
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index d1c0bf4..e1f5f08 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -100,6 +100,8 @@ struct backing_dev_info {
 	unsigned int min_ratio;
 	unsigned int max_ratio, max_prop_frac;
 
+	atomic_long_t tot_write_bandwidth; /* sum of active avg_write_bw */
+
 	struct bdi_writeback wb; /* the root writeback info for this bdi */
 #ifdef CONFIG_CGROUP_WRITEBACK
 	struct radix_tree_root cgwb_tree; /* radix tree of !root cgroup wbs */
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index b115a57..176d0fb 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -879,6 +879,9 @@ static void wb_update_write_bandwidth(struct bdi_writeback *wb,
 		avg += (old - avg) >> 3;
 
 out:
+	if (wb_has_dirty_io(wb))
+		atomic_long_add(avg - wb->avg_write_bandwidth,
+				&wb->bdi->tot_write_bandwidth);
 	wb->write_bandwidth = bw;
 	wb->avg_write_bandwidth = avg;
 }
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
