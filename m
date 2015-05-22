Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id F2F22829CE
	for <linux-mm@kvack.org>; Fri, 22 May 2015 17:15:14 -0400 (EDT)
Received: by qkgv12 with SMTP id v12so22230423qkg.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:14 -0700 (PDT)
Received: from mail-qk0-x22e.google.com (mail-qk0-x22e.google.com. [2607:f8b0:400d:c09::22e])
        by mx.google.com with ESMTPS id j19si3679129qgd.102.2015.05.22.14.15.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 14:15:13 -0700 (PDT)
Received: by qkgv12 with SMTP id v12so22230071qkg.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:13 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 30/51] writeback: implement and use inode_congested()
Date: Fri, 22 May 2015 17:13:44 -0400
Message-Id: <1432329245-5844-31-git-send-email-tj@kernel.org>
In-Reply-To: <1432329245-5844-1-git-send-email-tj@kernel.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

In several places, bdi_congested() and its wrappers are used to
determine whether more IOs should be issued.  With cgroup writeback
support, this question can't be answered solely based on the bdi
(backing_dev_info).  It's dependent on whether the filesystem and bdi
support cgroup writeback and the blkcg the inode is associated with.

This patch implements inode_congested() and its wrappers which take
@inode and determines the congestion state considering cgroup
writeback.  The new functions replace bdi_*congested() calls in places
where the query is about specific inode and task.

There are several filesystem users which also fit this criteria but
they should be updated when each filesystem implements cgroup
writeback support.

v2: Now that a given inode is associated with only one wb, congestion
    state can be determined independent from the asking task.  Drop
    @task.  Spotted by Vivek.  Also, converted to take @inode instead
    of @mapping and renamed to inode_congested().

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Vivek Goyal <vgoyal@redhat.com>
---
 fs/fs-writeback.c           | 29 +++++++++++++++++++++++++++++
 include/linux/backing-dev.h | 22 ++++++++++++++++++++++
 mm/fadvise.c                |  2 +-
 mm/readahead.c              |  2 +-
 mm/vmscan.c                 | 11 +++++------
 5 files changed, 58 insertions(+), 8 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 99a2440..7ec491b 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -142,6 +142,35 @@ static void __wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
 	wb_queue_work(wb, work);
 }
 
+#ifdef CONFIG_CGROUP_WRITEBACK
+
+/**
+ * inode_congested - test whether an inode is congested
+ * @inode: inode to test for congestion
+ * @cong_bits: mask of WB_[a]sync_congested bits to test
+ *
+ * Tests whether @inode is congested.  @cong_bits is the mask of congestion
+ * bits to test and the return value is the mask of set bits.
+ *
+ * If cgroup writeback is enabled for @inode, the congestion state is
+ * determined by whether the cgwb (cgroup bdi_writeback) for the blkcg
+ * associated with @inode is congested; otherwise, the root wb's congestion
+ * state is used.
+ */
+int inode_congested(struct inode *inode, int cong_bits)
+{
+	if (inode) {
+		struct bdi_writeback *wb = inode_to_wb(inode);
+		if (wb)
+			return wb_congested(wb, cong_bits);
+	}
+
+	return wb_congested(&inode_to_bdi(inode)->wb, cong_bits);
+}
+EXPORT_SYMBOL_GPL(inode_congested);
+
+#endif	/* CONFIG_CGROUP_WRITEBACK */
+
 /**
  * bdi_start_writeback - start writeback
  * @bdi: the backing device to write from
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 2c498a2..6f08821 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -230,6 +230,7 @@ struct bdi_writeback *wb_get_create(struct backing_dev_info *bdi,
 void __inode_attach_wb(struct inode *inode, struct page *page);
 void wb_memcg_offline(struct mem_cgroup *memcg);
 void wb_blkcg_offline(struct blkcg *blkcg);
+int inode_congested(struct inode *inode, int cong_bits);
 
 /**
  * inode_cgwb_enabled - test whether cgroup writeback is enabled on an inode
@@ -438,8 +439,29 @@ static inline void wb_blkcg_offline(struct blkcg *blkcg)
 {
 }
 
+static inline int inode_congested(struct inode *inode, int cong_bits)
+{
+	return wb_congested(&inode_to_bdi(inode)->wb, cong_bits);
+}
+
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
+static inline int inode_read_congested(struct inode *inode)
+{
+	return inode_congested(inode, 1 << WB_sync_congested);
+}
+
+static inline int inode_write_congested(struct inode *inode)
+{
+	return inode_congested(inode, 1 << WB_async_congested);
+}
+
+static inline int inode_rw_congested(struct inode *inode)
+{
+	return inode_congested(inode, (1 << WB_sync_congested) |
+				      (1 << WB_async_congested));
+}
+
 static inline int bdi_congested(struct backing_dev_info *bdi, int cong_bits)
 {
 	return wb_congested(&bdi->wb, cong_bits);
diff --git a/mm/fadvise.c b/mm/fadvise.c
index 4a3907c..b8a5bc6 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -115,7 +115,7 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
 	case POSIX_FADV_NOREUSE:
 		break;
 	case POSIX_FADV_DONTNEED:
-		if (!bdi_write_congested(bdi))
+		if (!inode_write_congested(mapping->host))
 			__filemap_fdatawrite_range(mapping, offset, endbyte,
 						   WB_SYNC_NONE);
 
diff --git a/mm/readahead.c b/mm/readahead.c
index 9356758..60cd846 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -541,7 +541,7 @@ page_cache_async_readahead(struct address_space *mapping,
 	/*
 	 * Defer asynchronous read-ahead on IO congestion.
 	 */
-	if (bdi_read_congested(inode_to_bdi(mapping->host)))
+	if (inode_read_congested(mapping->host))
 		return;
 
 	/* do read-ahead */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7582f9f..f463398 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -452,14 +452,13 @@ static inline int is_page_cache_freeable(struct page *page)
 	return page_count(page) - page_has_private(page) == 2;
 }
 
-static int may_write_to_queue(struct backing_dev_info *bdi,
-			      struct scan_control *sc)
+static int may_write_to_inode(struct inode *inode, struct scan_control *sc)
 {
 	if (current->flags & PF_SWAPWRITE)
 		return 1;
-	if (!bdi_write_congested(bdi))
+	if (!inode_write_congested(inode))
 		return 1;
-	if (bdi == current->backing_dev_info)
+	if (inode_to_bdi(inode) == current->backing_dev_info)
 		return 1;
 	return 0;
 }
@@ -538,7 +537,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 	}
 	if (mapping->a_ops->writepage == NULL)
 		return PAGE_ACTIVATE;
-	if (!may_write_to_queue(inode_to_bdi(mapping->host), sc))
+	if (!may_write_to_inode(mapping->host, sc))
 		return PAGE_KEEP;
 
 	if (clear_page_dirty_for_io(page)) {
@@ -924,7 +923,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 */
 		mapping = page_mapping(page);
 		if (((dirty || writeback) && mapping &&
-		     bdi_write_congested(inode_to_bdi(mapping->host))) ||
+		     inode_write_congested(mapping->host)) ||
 		    (writeback && PageReclaim(page)))
 			nr_congested++;
 
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
