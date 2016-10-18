Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 33F106B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 03:20:10 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id l29so128483449pfg.7
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 00:20:10 -0700 (PDT)
Received: from szxga02-in.huawei.com ([119.145.14.65])
        by mx.google.com with ESMTP id 80si30933425pgc.325.2016.10.18.00.20.08
        for <linux-mm@kvack.org>;
        Tue, 18 Oct 2016 00:20:09 -0700 (PDT)
From: <zhouxianrong@huawei.com>
Subject: [PATCH] bdi flusher should not be throttled here when it fall into buddy slow path
Date: Tue, 18 Oct 2016 15:12:45 +0800
Message-ID: <1476774765-21130-1-git-send-email-zhouxianrong@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, mingo@redhat.com, peterz@infradead.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, mhocko@suse.com, vdavydov.dev@gmail.com, minchan@kernel.org, riel@redhat.com, zhouxianrong@huawei.com, zhouxiyu@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com, tuxiaobing@huawei.com

From: z00281421 <z00281421@notesmail.huawei.com>

bdi flusher may enter page alloc slow path due to writepage and kmalloc. 
in that case the flusher as a direct reclaimer should not be throttled here
because it can not to reclaim clean file pages or anaonymous pages
for next moment; furthermore writeback rate of dirty pages would be
slow down and other direct reclaimers and kswapd would be affected.
bdi flusher should be iosceduled by get_request rather than here.

Signed-off-by: z00281421 <z00281421@notesmail.huawei.com>
---
 fs/fs-writeback.c     |    4 ++--
 include/linux/sched.h |    1 +
 mm/vmscan.c           |   15 +++++++++++----
 3 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 05713a5..f6bf067 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1908,7 +1908,7 @@ void wb_workfn(struct work_struct *work)
 	long pages_written;
 
 	set_worker_desc("flush-%s", dev_name(wb->bdi->dev));
-	current->flags |= PF_SWAPWRITE;
+	current->flags |= (PF_SWAPWRITE | PF_BDI_FLUSHER | PF_LESS_THROTTLE);
 
 	if (likely(!current_is_workqueue_rescuer() ||
 		   !test_bit(WB_registered, &wb->state))) {
@@ -1938,7 +1938,7 @@ void wb_workfn(struct work_struct *work)
 	else if (wb_has_dirty_io(wb) && dirty_writeback_interval)
 		wb_wakeup_delayed(wb);
 
-	current->flags &= ~PF_SWAPWRITE;
+	current->flags &= ~(PF_SWAPWRITE | PF_BDI_FLUSHER | PF_LESS_THROTTLE);
 }
 
 /*
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 62c68e5..4bb70f2 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2232,6 +2232,7 @@ extern void thread_group_cputime_adjusted(struct task_struct *p, cputime_t *ut,
 #define PF_KTHREAD	0x00200000	/* I am a kernel thread */
 #define PF_RANDOMIZE	0x00400000	/* randomize virtual address space */
 #define PF_SWAPWRITE	0x00800000	/* Allowed to write to swap */
+#define PF_BDI_FLUSHER  0x01000000	/* I am bdi flusher */
 #define PF_NO_SETAFFINITY 0x04000000	/* Userland is not allowed to meddle with cpus_allowed */
 #define PF_MCE_EARLY    0x08000000      /* Early kill for mce process policy */
 #define PF_MUTEX_TESTER	0x20000000	/* Thread belongs to the rt mutex tester */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0fe8b71..492e9e7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1643,12 +1643,19 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
  * If a kernel thread (such as nfsd for loop-back mounts) services
  * a backing device by writing to the page cache it sets PF_LESS_THROTTLE.
  * In that case we should only throttle if the backing device it is
- * writing to is congested.  In other cases it is safe to throttle.
+ * writing to is congested.  another case is that bdi flusher could
+ * not be throttled here even though whose bdi is consgested.
+ * In other cases it is safe to throttle.
  */
-static int current_may_throttle(void)
+static bool current_may_throttle(void)
 {
-	return !(current->flags & PF_LESS_THROTTLE) ||
-		current->backing_dev_info == NULL ||
+	if (!(current->flags & PF_LESS_THROTTLE))
+		return true;
+
+	if (current->flags & PF_BDI_FLUSHER)
+		return false;
+
+	return current->backing_dev_info == NULL ||
 		bdi_write_congested(current->backing_dev_info);
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
