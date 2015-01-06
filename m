Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id A1B3E6B016D
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:27:38 -0500 (EST)
Received: by mail-qg0-f49.google.com with SMTP id f51so74404qge.8
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:38 -0800 (PST)
Received: from mail-qc0-x231.google.com (mail-qc0-x231.google.com. [2607:f8b0:400d:c01::231])
        by mx.google.com with ESMTPS id f16si42360615qaa.95.2015.01.06.13.27.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:27:37 -0800 (PST)
Received: by mail-qc0-f177.google.com with SMTP id x3so60247qcv.36
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:37 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 37/45] writeback: make writeback_control carry the inode_wb_link being served
Date: Tue,  6 Jan 2015 16:26:14 -0500
Message-Id: <1420579582-8516-38-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>

A wbc (writeback_control) is constructed at the beginning of writeback
and passed throughout the writeback path.  It serves as the control
structure carrying both in and out parameters for writeback of each
inode.  This patch adds wbc->iwbl so that it also carries the cgroup
writeback context.

wbc_set_iwbl(), which is called by writeback_sb_inodes() while kicking
off writeback of each inode, associates the wbc with the iwbl
(inode_wb_link) being serviced.  inode_writeback_iwbl() and
bdi_writeback_wb() are used to determine the iwbl from inode and wb
(bdi_writeback) from bdi being serviced considering wbc->iwbl.  If the
wbc has a specific iwbl associated with it, the iwbl is used to
determine them; otherwise, the root cgroup is assumed.

This allows accessing the current cgroup wb and iwbl being serviced
throughout the writeback path.  __writeback_single_inode(), which used
to assume the root iwbl, are updated to use inode_writeback_iwbl().
writeback_single_inode() now also uses inode_wirteback_iwbl() and
drops @wb and determines it using iwbl_to_wb() instead.  For
clear_page_dirty_for_io() which used to re-lookup the dirty wb using
page_cgwb_dirty(), a new function, clear_page_dirty_for_io_wbc() which
takes additional @wbc and uses bdi_writeback_wb(), is added.

This patch also adds wbc_blkcg_css() which determines whether the
current writebfffack is for a specific cgroup and which cgroup.  This
will be used by future patches.

This propagates the cgroup writeback context throughout most of
writeback path so that the cgroup specific data is accessible without
repeating lookups from page blkcg.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c           | 36 ++++++++++++++++++++------
 include/linux/backing-dev.h | 62 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/writeback.h   |  3 +++
 mm/page-writeback.c         | 21 ++++++++++++---
 4 files changed, 111 insertions(+), 11 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index dfcf5dd..562b75f 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -604,6 +604,21 @@ static void inode_icgwbls_del(struct inode *inode)
 	}
 }
 
+/**
+ * wbc_set_iwbl - associate a wbc with an iwbl
+ * @wbc: target writeback_control
+ * @iwbl: inode_wb_link to associate @wbc with
+ *
+ * Writeback for @iwbl is about to be performed with @wbc as the control
+ * structure.  Associate @wbc with @iwbl so that writeback implementation
+ * can retrieve @iwbl from @wbc.
+ */
+static inline void wbc_set_iwbl(struct writeback_control *wbc,
+				struct inode_wb_link *iwbl)
+{
+	wbc->iwbl = iwbl;
+}
+
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
 static void init_cgwb_dirty_page_context(struct dirty_context *dctx)
@@ -685,6 +700,11 @@ static void inode_icgwbls_del(struct inode *inode)
 {
 }
 
+static inline void wbc_set_iwbl(struct writeback_control *wbc,
+				struct inode_wb_link *iwbl)
+{
+}
+
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
 /**
@@ -1019,7 +1039,7 @@ static int
 __writeback_single_inode(struct inode *inode, struct writeback_control *wbc)
 {
 	struct address_space *mapping = inode->i_mapping;
-	struct inode_wb_link *iwbl = &inode->i_wb_link;
+	struct inode_wb_link *iwbl = inode_writeback_iwbl(inode, wbc);
 	long nr_to_write = wbc->nr_to_write;
 	unsigned dirty;
 	int ret;
@@ -1090,10 +1110,10 @@ __writeback_single_inode(struct inode *inode, struct writeback_control *wbc)
  * and does more profound writeback list handling in writeback_sb_inodes().
  */
 static int
-writeback_single_inode(struct inode *inode, struct bdi_writeback *wb,
-		       struct writeback_control *wbc)
+writeback_single_inode(struct inode *inode, struct writeback_control *wbc)
 {
-	struct inode_wb_link *iwbl = &inode->i_wb_link;
+	struct inode_wb_link *iwbl = inode_writeback_iwbl(inode, wbc);
+	struct bdi_writeback *wb = iwbl_to_wb(iwbl);
 	int ret = 0;
 
 	spin_lock(&inode->i_lock);
@@ -1222,6 +1242,8 @@ static long writeback_sb_inodes(struct super_block *sb,
 			break;
 		}
 
+		wbc_set_iwbl(&wbc, iwbl);
+
 		/*
 		 * Don't bother with new inodes or inodes being freed, first
 		 * kind does not need periodic writeout yet, and for the latter
@@ -2020,7 +2042,6 @@ EXPORT_SYMBOL(sync_inodes_sb);
  */
 int write_inode_now(struct inode *inode, int sync)
 {
-	struct bdi_writeback *wb = iwbl_to_wb(&inode->i_wb_link);
 	struct writeback_control wbc = {
 		.nr_to_write = LONG_MAX,
 		.sync_mode = sync ? WB_SYNC_ALL : WB_SYNC_NONE,
@@ -2032,7 +2053,7 @@ int write_inode_now(struct inode *inode, int sync)
 		wbc.nr_to_write = 0;
 
 	might_sleep();
-	return writeback_single_inode(inode, wb, &wbc);
+	return writeback_single_inode(inode, &wbc);
 }
 EXPORT_SYMBOL(write_inode_now);
 
@@ -2049,8 +2070,7 @@ EXPORT_SYMBOL(write_inode_now);
  */
 int sync_inode(struct inode *inode, struct writeback_control *wbc)
 {
-	return writeback_single_inode(inode, iwbl_to_wb(&inode->i_wb_link),
-				      wbc);
+	return writeback_single_inode(inode, wbc);
 }
 EXPORT_SYMBOL(sync_inode);
 
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 6c16d10..5a163fa 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -520,6 +520,50 @@ iwbl_lookup(struct inode *inode, struct cgroup_subsys_state *blkcg_css)
 	return iwbl;
 }
 
+/**
+ * inode_writeback_iwbl - determine the inode_wb_link under writeback
+ * @inode: inode under writeback
+ * @wbc: writeback_control in effect
+ *
+ * Called from code path which is writing back @inode with @wbc to
+ * determine the iwbl (inode_wb_link) this writeback is for.  Guaranteed to
+ * return a valid iwbl.
+ */
+static inline struct inode_wb_link *
+inode_writeback_iwbl(struct inode *inode, struct writeback_control *wbc)
+{
+	return wbc->iwbl ?: &inode->i_wb_link;
+}
+
+/**
+ * bdi_writeback_wb - determine the bdi_writeback under writeback
+ * @bdi: backing_dev_info under writeback
+ * @wbc: writeback_control in effect
+ *
+ * Called from code path which is writing back @bdi with @wbc to determine
+ * the wb (bdi_writebck) this writeback is for.  Guaranteed to return a
+ * valid wb.
+ */
+static inline struct bdi_writeback *
+bdi_writeback_wb(struct backing_dev_info *bdi, struct writeback_control *wbc)
+{
+	return wbc->iwbl ? iwbl_to_wb(wbc->iwbl) : &bdi->wb;
+}
+
+/**
+ * wbc_blkcg_css - return the blkcg_css associated with a wbc
+ * @wbc: writeback_control of interest
+ *
+ * Return the blkcg_css of the inode_wb_link @wbc is associated with.  If
+ * @wbc hasn't been associated with an iwbl using wbc_set_iwbl(), %NULL is
+ * returned.
+ */
+static inline struct cgroup_subsys_state *
+wbc_blkcg_css(struct writeback_control *wbc)
+{
+	return wbc->iwbl ? iwbl_to_wb(wbc->iwbl)->blkcg_css : NULL;
+}
+
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
 static inline bool mapping_cgwb_enabled(struct address_space *mapping)
@@ -596,6 +640,24 @@ iwbl_lookup(struct inode *inode, struct cgroup_subsys_state *blkcg_css)
 	return &inode->i_wb_link;
 }
 
+static inline struct inode_wb_link *
+inode_writeback_iwbl(struct inode *inode, struct writeback_control *wbc)
+{
+	return &inode->i_wb_link;
+}
+
+static inline struct bdi_writeback *
+bdi_writeback_wb(struct backing_dev_info *bdi, struct writeback_control *wbc)
+{
+	return &bdi->wb;
+}
+
+static inline struct cgroup_subsys_state *
+wbc_blkcg_css(struct writeback_control *wbc)
+{
+	return NULL;
+}
+
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
 static inline int mapping_read_congested(struct address_space *mapping,
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 75349bb..dad1953 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -84,6 +84,9 @@ struct writeback_control {
 	unsigned for_reclaim:1;		/* Invoked from the page allocator */
 	unsigned range_cyclic:1;	/* range_start is cyclic */
 	unsigned for_sync:1;		/* sync(2) WB_SYNC_ALL writeback */
+#ifdef CONFIG_CGROUP_WRITEBACK
+	struct inode_wb_link *iwbl;	/* iwbl this writeback is for */
+#endif
 };
 
 /*
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 4cf365c..3e31458 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -148,6 +148,9 @@ static struct timer_list writeout_period_timer =
 		TIMER_DEFERRED_INITIALIZER(writeout_period, 0, 0);
 static unsigned long writeout_period_time = 0;
 
+static int clear_page_dirty_for_io_wbc(struct page *page,
+				       struct writeback_control *wbc);
+
 /*
  * Length of period for aging writeout fractions of bdis. This is an
  * arbitrarily chosen number. The longer the period, the slower fractions will
@@ -1993,7 +1996,7 @@ continue_unlock:
 			}
 
 			BUG_ON(PageWriteback(page));
-			if (!clear_page_dirty_for_io(page))
+			if (!clear_page_dirty_for_io_wbc(page, wbc))
 				goto continue_unlock;
 
 			trace_wbc_writepage(wbc, mapping->backing_dev_info);
@@ -2326,7 +2329,8 @@ EXPORT_SYMBOL(set_page_dirty_lock);
  * This incoherency between the page's dirty flag and radix-tree tag is
  * unfortunate, but it only exists while the page is locked.
  */
-int clear_page_dirty_for_io(struct page *page)
+static int clear_page_dirty_for_io_wbc(struct page *page,
+				       struct writeback_control *wbc)
 {
 	struct address_space *mapping = page_mapping(page);
 
@@ -2369,7 +2373,8 @@ int clear_page_dirty_for_io(struct page *page)
 		 * exclusion.
 		 */
 		if (TestClearPageDirty(page)) {
-			struct bdi_writeback *wb = page_cgwb_dirty(page);
+			struct backing_dev_info *bdi = mapping->backing_dev_info;
+			struct bdi_writeback *wb = bdi_writeback_wb(bdi, wbc);
 
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			dec_wb_stat(wb, WB_RECLAIMABLE);
@@ -2380,6 +2385,16 @@ int clear_page_dirty_for_io(struct page *page)
 	}
 	return TestClearPageDirty(page);
 }
+
+int clear_page_dirty_for_io(struct page *page)
+{
+	struct writeback_control wbc = {
+		.sync_mode = WB_SYNC_ALL,
+		.nr_to_write = 1,
+	};
+
+	return clear_page_dirty_for_io_wbc(page, &wbc);
+}
 EXPORT_SYMBOL(clear_page_dirty_for_io);
 
 int test_clear_page_writeback(struct page *page)
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
