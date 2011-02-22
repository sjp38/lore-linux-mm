Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 588FD8D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 12:13:45 -0500 (EST)
From: Andrea Righi <arighi@develer.com>
Subject: [PATCH 4/5] blk-throttle: track buffered and anonymous pages
Date: Tue, 22 Feb 2011 18:12:55 +0100
Message-Id: <1298394776-9957-5-git-send-email-arighi@develer.com>
In-Reply-To: <1298394776-9957-1-git-send-email-arighi@develer.com>
References: <1298394776-9957-1-git-send-email-arighi@develer.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Gui Jianfeng <guijianfeng@cn.fujitsu.com>, Ryo Tsuruta <ryov@valinux.co.jp>, Hirokazu Takahashi <taka@valinux.co.jp>, Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Righi <arighi@develer.com>

Add the tracking of buffered (writeback) and anonymous pages.

Dirty pages in the page cache can be processed asynchronously by the
per-bdi flusher kernel threads or by any other thread in the system,
according to the writeback policy.

For this reason the real writes to the underlying block devices may
occur in a different IO context respect to the task that originally
generated the dirty pages involved in the IO operation. This makes
the tracking and throttling of writeback IO more complicate respect to
the synchronous IO from the blkio controller's point of view.

The idea is to save the cgroup owner of each anonymous page and dirty
page in page cache. A page is associated to a cgroup the first time it
is dirtied in memory (for file cache pages) or when it is set as
swap-backed (for anonymous pages). This information is stored using the
page_cgroup functionality.

Then, at the block layer, it is possible to retrieve the throttle group
looking at the bio_page(bio). If the page was not explicitly associated
to any cgroup the IO operation is charged to the current task/cgroup, as
it was done by the previous implementation.

Signed-off-by: Andrea Righi <arighi@develer.com>
---
 block/blk-throttle.c   |   87 +++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/blkdev.h |   26 ++++++++++++++-
 2 files changed, 111 insertions(+), 2 deletions(-)

diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 9ad3d1e..a50ee04 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -8,6 +8,10 @@
 #include <linux/slab.h>
 #include <linux/blkdev.h>
 #include <linux/bio.h>
+#include <linux/memcontrol.h>
+#include <linux/mm_inline.h>
+#include <linux/pagemap.h>
+#include <linux/page_cgroup.h>
 #include <linux/blktrace_api.h>
 #include <linux/blk-cgroup.h>
 
@@ -221,6 +225,85 @@ done:
 	return tg;
 }
 
+static inline bool is_kernel_io(void)
+{
+	return !!(current->flags & (PF_KTHREAD | PF_KSWAPD | PF_MEMALLOC));
+}
+
+static int throtl_set_page_owner(struct page *page, struct mm_struct *mm)
+{
+	struct blkio_cgroup *blkcg;
+	unsigned short id = 0;
+
+	if (blkio_cgroup_disabled())
+		return 0;
+	if (!mm)
+		goto out;
+	rcu_read_lock();
+	blkcg = task_to_blkio_cgroup(rcu_dereference(mm->owner));
+	if (likely(blkcg))
+		id = css_id(&blkcg->css);
+	rcu_read_unlock();
+out:
+	return page_cgroup_set_owner(page, id);
+}
+
+int blk_throtl_set_anonpage_owner(struct page *page, struct mm_struct *mm)
+{
+	return throtl_set_page_owner(page, mm);
+}
+EXPORT_SYMBOL(blk_throtl_set_anonpage_owner);
+
+int blk_throtl_set_filepage_owner(struct page *page, struct mm_struct *mm)
+{
+	if (is_kernel_io() || !page_is_file_cache(page))
+		return 0;
+	return throtl_set_page_owner(page, mm);
+}
+EXPORT_SYMBOL(blk_throtl_set_filepage_owner);
+
+int blk_throtl_copy_page_owner(struct page *npage, struct page *opage)
+{
+	if (blkio_cgroup_disabled())
+		return 0;
+	return page_cgroup_copy_owner(npage, opage);
+}
+EXPORT_SYMBOL(blk_throtl_copy_page_owner);
+
+/*
+ * A helper function to get the throttle group from css id.
+ *
+ * NOTE: must be called under rcu_read_lock().
+ */
+static struct throtl_grp *throtl_tg_lookup(struct throtl_data *td, int id)
+{
+	struct cgroup_subsys_state *css;
+
+	if (!id)
+		return NULL;
+	css = css_lookup(&blkio_subsys, id);
+	if (!css)
+		return NULL;
+	return throtl_find_alloc_tg(td, css->cgroup);
+}
+
+static struct throtl_grp *
+throtl_get_tg_from_page(struct throtl_data *td, struct page *page)
+{
+	struct throtl_grp *tg;
+	int id;
+
+	if (unlikely(!page))
+		return NULL;
+	id = page_cgroup_get_owner(page);
+
+	rcu_read_lock();
+	tg = throtl_tg_lookup(td, id);
+	rcu_read_unlock();
+
+	return tg;
+}
+
 static struct throtl_grp * throtl_get_tg(struct throtl_data *td)
 {
 	struct cgroup *cgroup;
@@ -1000,7 +1083,9 @@ int blk_throtl_bio(struct request_queue *q, struct bio **biop)
 	}
 
 	spin_lock_irq(q->queue_lock);
-	tg = throtl_get_tg(td);
+	tg = throtl_get_tg_from_page(td, bio_page(bio));
+	if (!tg)
+		tg = throtl_get_tg(td);
 
 	if (tg->nr_queued[rw]) {
 		/*
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 4d18ff3..2d03dee 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -1136,10 +1136,34 @@ static inline uint64_t rq_io_start_time_ns(struct request *req)
 extern int blk_throtl_init(struct request_queue *q);
 extern void blk_throtl_exit(struct request_queue *q);
 extern int blk_throtl_bio(struct request_queue *q, struct bio **bio);
+extern int blk_throtl_set_anonpage_owner(struct page *page,
+				struct mm_struct *mm);
+extern int blk_throtl_set_filepage_owner(struct page *page,
+				struct mm_struct *mm);
+extern int blk_throtl_copy_page_owner(struct page *npage, struct page *opage);
 extern void throtl_schedule_delayed_work(struct request_queue *q, unsigned long delay);
 extern void throtl_shutdown_timer_wq(struct request_queue *q);
 #else /* CONFIG_BLK_DEV_THROTTLING */
-static inline int blk_throtl_bio(struct request_queue *q, struct bio **bio)
+static inline int
+blk_throtl_bio(struct request_queue *q, struct bio **bio)
+{
+	return 0;
+}
+
+static inline int
+blk_throtl_set_anonpage_owner(struct page *page, struct mm_struct *mm)
+{
+	return 0;
+}
+
+static inline int
+blk_throtl_set_filepage_owner(struct page *page, struct mm_struct *mm)
+{
+	return 0;
+}
+
+static inline int
+blk_throtl_copy_page_owner(struct page *npage, struct page *opage)
 {
 	return 0;
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
