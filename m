Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id B00536B00FE
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 16:05:20 -0400 (EDT)
Received: by qgdy78 with SMTP id y78so15035919qgd.0
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:05:20 -0700 (PDT)
Received: from mail-qg0-x229.google.com (mail-qg0-x229.google.com. [2607:f8b0:400d:c04::229])
        by mx.google.com with ESMTPS id j4si5170447qga.33.2015.04.06.13.05.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Apr 2015 13:05:08 -0700 (PDT)
Received: by qgfi89 with SMTP id i89so15028559qgf.1
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:05:07 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 17/19] writeback: reset wb_domain->dirty_limit[_tstmp] when memcg domain size changes
Date: Mon,  6 Apr 2015 16:04:32 -0400
Message-Id: <1428350674-8303-18-git-send-email-tj@kernel.org>
In-Reply-To: <1428350674-8303-1-git-send-email-tj@kernel.org>
References: <1428350674-8303-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

The amount of available memory to a memcg wb_domain can change as
memcg configuration changes.  A domain's ->dirty_limit exists to
smooth out sudden drops in dirty threshold; however, when a domain's
size actually drops significantly, it hinders the dirty throttling
from adjusting to the new configuration leading to unexpected
behaviors including unnecessary OOM kills.

This patch resolves the issue by adding wb_domain_size_changed() which
resets ->dirty_limit[_tstmp] and making memcg call it on configuration
changes.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
---
 include/linux/writeback.h | 20 ++++++++++++++++++++
 mm/memcontrol.c           | 12 ++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index a9eb40f..5b86988 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -132,6 +132,26 @@ struct wb_domain {
 	unsigned long dirty_limit;
 };
 
+/**
+ * wb_domain_size_changed - memory available to a wb_domain has changed
+ * @dom: wb_domain of interest
+ *
+ * This function should be called when the amount of memory available to
+ * @dom has changed.  It resets @dom's dirty limit parameters to prevent
+ * the past values which don't match the current configuration from skewing
+ * dirty throttling.  Without this, when memory size of a wb_domain is
+ * greatly reduced, the dirty throttling logic may allow too many pages to
+ * be dirtied leading to consecutive unnecessary OOMs and may get stuck in
+ * that situation.
+ */
+static inline void wb_domain_size_changed(struct wb_domain *dom)
+{
+	spin_lock(&dom->lock);
+	dom->dirty_limit_tstamp = jiffies;
+	dom->dirty_limit = 0;
+	spin_unlock(&dom->lock);
+}
+
 /*
  * fs/fs-writeback.c
  */	
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2a74cf3..108acfc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4096,6 +4096,11 @@ static void memcg_wb_domain_exit(struct mem_cgroup *memcg)
 	wb_domain_exit(&memcg->cgwb_domain);
 }
 
+static void memcg_wb_domain_size_changed(struct mem_cgroup *memcg)
+{
+	wb_domain_size_changed(&memcg->cgwb_domain);
+}
+
 struct wb_domain *mem_cgroup_wb_domain(struct bdi_writeback *wb)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(wb->memcg_css);
@@ -4117,6 +4122,10 @@ static void memcg_wb_domain_exit(struct mem_cgroup *memcg)
 {
 }
 
+static void memcg_wb_domain_size_changed(struct mem_cgroup *memcg)
+{
+}
+
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
 /*
@@ -4715,6 +4724,7 @@ static void mem_cgroup_css_reset(struct cgroup_subsys_state *css)
 	memcg->low = 0;
 	memcg->high = PAGE_COUNTER_MAX;
 	memcg->soft_limit = PAGE_COUNTER_MAX;
+	memcg_wb_domain_size_changed(memcg);
 }
 
 #ifdef CONFIG_MMU
@@ -5347,6 +5357,7 @@ static ssize_t memory_high_write(struct kernfs_open_file *of,
 
 	memcg->high = high;
 
+	memcg_wb_domain_size_changed(memcg);
 	return nbytes;
 }
 
@@ -5379,6 +5390,7 @@ static ssize_t memory_max_write(struct kernfs_open_file *of,
 	if (err)
 		return err;
 
+	memcg_wb_domain_size_changed(memcg);
 	return nbytes;
 }
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
