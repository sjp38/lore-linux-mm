Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 9DCF16B0113
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 18:16:56 -0400 (EDT)
Message-Id: <20120328131153.227169439@intel.com>
Date: Wed, 28 Mar 2012 20:13:10 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH 2/6] blk-cgroup: account dirtied pages
References: <20120328121308.568545879@intel.com>
Content-Disposition: inline; filename=blk-cgroup-nr-dirtied.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>
Cc: Vivek Goyal <vgoyal@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Suresh Jayaraman <sjayaraman@suse.com>, Andrea Righi <andrea@betterlinux.com>, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>


Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 block/blk-cgroup.c         |    4 ++++
 include/linux/blk-cgroup.h |    1 +
 mm/page-writeback.c        |    6 ++++++
 3 files changed, 11 insertions(+)

--- linux-next.orig/block/blk-cgroup.c	2012-03-28 14:55:47.522142976 +0800
+++ linux-next/block/blk-cgroup.c	2012-03-28 15:39:46.722088815 +0800
@@ -1594,6 +1594,7 @@ static void blkiocg_destroy(struct cgrou
 
 	free_css_id(&blkio_subsys, &blkcg->css);
 	rcu_read_unlock();
+	percpu_counter_destroy(&blkcg->nr_dirtied);
 	if (blkcg != &blkio_root_cgroup)
 		kfree(blkcg);
 }
@@ -1619,6 +1620,9 @@ done:
 	INIT_HLIST_HEAD(&blkcg->blkg_list);
 
 	INIT_LIST_HEAD(&blkcg->policy_list);
+
+	percpu_counter_init(&blkcg->nr_dirtied, 0);
+
 	return &blkcg->css;
 }
 
--- linux-next.orig/include/linux/blk-cgroup.h	2012-03-28 14:55:47.530142977 +0800
+++ linux-next/include/linux/blk-cgroup.h	2012-03-28 15:40:27.754087973 +0800
@@ -117,6 +117,7 @@ struct blkio_cgroup {
 	spinlock_t lock;
 	struct hlist_head blkg_list;
 	struct list_head policy_list; /* list of blkio_policy_node */
+	struct percpu_counter nr_dirtied;
 };
 
 struct blkio_group_stats {
--- linux-next.orig/mm/page-writeback.c	2012-03-28 14:55:47.510142976 +0800
+++ linux-next/mm/page-writeback.c	2012-03-28 15:40:39.366087735 +0800
@@ -34,6 +34,7 @@
 #include <linux/syscalls.h>
 #include <linux/buffer_head.h> /* __set_page_dirty_buffers */
 #include <linux/pagevec.h>
+#include <linux/blk-cgroup.h>
 #include <trace/events/writeback.h>
 
 /*
@@ -1933,6 +1934,11 @@ int __set_page_dirty_no_writeback(struct
 void account_page_dirtied(struct page *page, struct address_space *mapping)
 {
 	if (mapping_cap_account_dirty(mapping)) {
+#ifdef CONFIG_BLK_DEV_THROTTLING
+		struct blkio_cgroup *blkcg = task_blkio_cgroup(current);
+		if (blkcg)
+			__percpu_counter_add(&blkcg->nr_dirtied, 1, BDI_STAT_BATCH);
+#endif
 		__inc_zone_page_state(page, NR_FILE_DIRTY);
 		__inc_zone_page_state(page, NR_DIRTIED);
 		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
