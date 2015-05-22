Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 316CE6B02A9
	for <linux-mm@kvack.org>; Fri, 22 May 2015 18:24:18 -0400 (EDT)
Received: by qgez61 with SMTP id z61so17118158qge.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:24:18 -0700 (PDT)
Received: from mail-qk0-x22d.google.com (mail-qk0-x22d.google.com. [2607:f8b0:400d:c09::22d])
        by mx.google.com with ESMTPS id o38si566985qkh.24.2015.05.22.15.24.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 15:24:12 -0700 (PDT)
Received: by qkdn188 with SMTP id n188so23422436qkd.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:24:11 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 17/19] writeback: reset wb_domain->dirty_limit[_tstmp] when memcg domain size changes
Date: Fri, 22 May 2015 18:23:34 -0400
Message-Id: <1432333416-6221-18-git-send-email-tj@kernel.org>
In-Reply-To: <1432333416-6221-1-git-send-email-tj@kernel.org>
References: <1432333416-6221-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

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
index 04a3786..3b73e97 100644
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
index 436fbc2..8fbd501 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3986,6 +3986,11 @@ static void memcg_wb_domain_exit(struct mem_cgroup *memcg)
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
@@ -4007,6 +4012,10 @@ static void memcg_wb_domain_exit(struct mem_cgroup *memcg)
 {
 }
 
+static void memcg_wb_domain_size_changed(struct mem_cgroup *memcg)
+{
+}
+
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
 /*
@@ -4605,6 +4614,7 @@ static void mem_cgroup_css_reset(struct cgroup_subsys_state *css)
 	memcg->low = 0;
 	memcg->high = PAGE_COUNTER_MAX;
 	memcg->soft_limit = PAGE_COUNTER_MAX;
+	memcg_wb_domain_size_changed(memcg);
 }
 
 #ifdef CONFIG_MMU
@@ -5342,6 +5352,7 @@ static ssize_t memory_high_write(struct kernfs_open_file *of,
 
 	memcg->high = high;
 
+	memcg_wb_domain_size_changed(memcg);
 	return nbytes;
 }
 
@@ -5374,6 +5385,7 @@ static ssize_t memory_max_write(struct kernfs_open_file *of,
 	if (err)
 		return err;
 
+	memcg_wb_domain_size_changed(memcg);
 	return nbytes;
 }
 
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
