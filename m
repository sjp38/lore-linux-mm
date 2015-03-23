Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id E3E7D8296B
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 01:08:19 -0400 (EDT)
Received: by qgep97 with SMTP id p97so5819278qge.1
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 22:08:19 -0700 (PDT)
Received: from mail-qc0-x229.google.com (mail-qc0-x229.google.com. [2607:f8b0:400d:c01::229])
        by mx.google.com with ESMTPS id g81si11172812qge.102.2015.03.22.22.08.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 22:08:19 -0700 (PDT)
Received: by qcbjx9 with SMTP id jx9so98132503qcb.0
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 22:08:18 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 15/18] writeback: implement memcg wb_domain
Date: Mon, 23 Mar 2015 01:07:44 -0400
Message-Id: <1427087267-16592-16-git-send-email-tj@kernel.org>
In-Reply-To: <1427087267-16592-1-git-send-email-tj@kernel.org>
References: <1427087267-16592-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

Dirtyable memory is distributed to a wb (bdi_writeback) according to
the relative bandwidth the wb is writing out in the whole system.
This distribution is global - each wb is measured against all other
wb's and gets the proportinately sized portion of the memory in the
whole system.

For cgroup writeback, the amount of dirtyable memory is scoped by
memcg and thus each wb would need to be measured and controlled in its
memcg.  IOW, a wb will belong to two writeback domains - the global
and memcg domains.

The previous patches laid the groundwork to support the two wb_domains
and this patch implements memcg wb_domain.  memcg->cgwb_domain is
initialized on css online and destroyed on css release,
wb->memcg_completions is added, and __wb_writeout_inc() is updated to
increment completions against both global and memcg wb_domains.

The following patches will update balance_dirty_pages() and its
subroutines to actually consider memcg wb_domain for throttling.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
---
 include/linux/backing-dev-defs.h |  1 +
 include/linux/memcontrol.h       | 12 +++++++++++-
 include/linux/writeback.h        |  3 +++
 mm/backing-dev.c                 |  9 ++++++++-
 mm/memcontrol.c                  | 39 +++++++++++++++++++++++++++++++++++++++
 mm/page-writeback.c              | 25 +++++++++++++++++++++++++
 6 files changed, 87 insertions(+), 2 deletions(-)

diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 97a92fa..8d470b7 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -118,6 +118,7 @@ struct bdi_writeback {
 
 #ifdef CONFIG_CGROUP_WRITEBACK
 	struct percpu_ref refcnt;	/* used only for !root wb's */
+	struct fprop_local_percpu memcg_completions;
 	struct cgroup_subsys_state *memcg_css; /* the associated memcg */
 	struct cgroup_subsys_state *blkcg_css; /* and blkcg */
 	struct list_head memcg_node;	/* anchored at memcg->cgwb_list */
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 662a953..e3177be 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -389,8 +389,18 @@ enum {
 };
 
 #ifdef CONFIG_CGROUP_WRITEBACK
+
 struct list_head *mem_cgroup_cgwb_list(struct mem_cgroup *memcg);
-#endif
+struct wb_domain *mem_cgroup_wb_domain(struct bdi_writeback *wb);
+
+#else	/* CONFIG_CGROUP_WRITEBACK */
+
+static inline struct wb_domain *mem_cgroup_wb_domain(struct bdi_writeback *wb)
+{
+	return NULL;
+}
+
+#endif	/* CONFIG_CGROUP_WRITEBACK */
 
 struct sock;
 #if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index fa6c3b4..e421625 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -167,6 +167,9 @@ static inline void laptop_sync_completion(void) { }
 void throttle_vm_writeout(gfp_t gfp_mask);
 bool zone_dirty_ok(struct zone *zone);
 int wb_domain_init(struct wb_domain *dom, gfp_t gfp);
+#ifdef CONFIG_CGROUP_WRITEBACK
+void wb_domain_exit(struct wb_domain *dom);
+#endif
 
 extern struct wb_domain global_wb_domain;
 
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 331e4d7..8828edf 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -483,6 +483,7 @@ static void cgwb_release_workfn(struct work_struct *work)
 	css_put(wb->blkcg_css);
 	wb_congested_put(wb->congested);
 
+	fprop_local_destroy_percpu(&wb->memcg_completions);
 	percpu_ref_exit(&wb->refcnt);
 	wb_exit(wb);
 	kfree_rcu(wb, rcu);
@@ -549,9 +550,13 @@ static int cgwb_create(struct backing_dev_info *bdi,
 	if (ret)
 		goto err_wb_exit;
 
+	ret = fprop_local_init_percpu(&wb->memcg_completions, gfp);
+	if (ret)
+		goto err_ref_exit;
+
 	wb->congested = wb_congested_get_create(bdi, blkcg_css->id, gfp);
 	if (!wb->congested)
-		goto err_ref_exit;
+		goto err_fprop_exit;
 
 	wb->memcg_css = memcg_css;
 	wb->blkcg_css = blkcg_css;
@@ -588,6 +593,8 @@ static int cgwb_create(struct backing_dev_info *bdi,
 
 err_put_congested:
 	wb_congested_put(wb->congested);
+err_fprop_exit:
+	fprop_local_destroy_percpu(&wb->memcg_completions);
 err_ref_exit:
 	percpu_ref_exit(&wb->refcnt);
 err_wb_exit:
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ab483e9..2a74cf3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -344,6 +344,7 @@ struct mem_cgroup {
 
 #ifdef CONFIG_CGROUP_WRITEBACK
 	struct list_head cgwb_list;
+	struct wb_domain cgwb_domain;
 #endif
 
 	/* List of events which userspace want to receive */
@@ -4085,6 +4086,37 @@ struct list_head *mem_cgroup_cgwb_list(struct mem_cgroup *memcg)
 	return &memcg->cgwb_list;
 }
 
+static int memcg_wb_domain_init(struct mem_cgroup *memcg, gfp_t gfp)
+{
+	return wb_domain_init(&memcg->cgwb_domain, gfp);
+}
+
+static void memcg_wb_domain_exit(struct mem_cgroup *memcg)
+{
+	wb_domain_exit(&memcg->cgwb_domain);
+}
+
+struct wb_domain *mem_cgroup_wb_domain(struct bdi_writeback *wb)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(wb->memcg_css);
+
+	if (!memcg->css.parent)
+		return NULL;
+
+	return &memcg->cgwb_domain;
+}
+
+#else	/* CONFIG_CGROUP_WRITEBACK */
+
+static int memcg_wb_domain_init(struct mem_cgroup *memcg, gfp_t gfp)
+{
+	return 0;
+}
+
+static void memcg_wb_domain_exit(struct mem_cgroup *memcg)
+{
+}
+
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
 /*
@@ -4471,9 +4503,15 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	memcg->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
 	if (!memcg->stat)
 		goto out_free;
+
+	if (memcg_wb_domain_init(memcg, GFP_KERNEL))
+		goto out_free_stat;
+
 	spin_lock_init(&memcg->pcp_counter_lock);
 	return memcg;
 
+out_free_stat:
+	free_percpu(memcg->stat);
 out_free:
 	kfree(memcg);
 	return NULL;
@@ -4500,6 +4538,7 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 		free_mem_cgroup_per_zone_info(memcg, node);
 
 	free_percpu(memcg->stat);
+	memcg_wb_domain_exit(memcg);
 	kfree(memcg);
 }
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 2626e6c..9ccd37e 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -171,6 +171,11 @@ static struct dirty_throttle_control *mdtc_gdtc(struct dirty_throttle_control *m
 	return mdtc->gdtc;
 }
 
+static struct fprop_local_percpu *wb_memcg_completions(struct bdi_writeback *wb)
+{
+	return &wb->memcg_completions;
+}
+
 static void wb_min_max_ratio(struct bdi_writeback *wb,
 			     unsigned long *minp, unsigned long *maxp)
 {
@@ -213,6 +218,11 @@ static struct dirty_throttle_control *mdtc_gdtc(struct dirty_throttle_control *m
 	return NULL;
 }
 
+static struct fprop_local_percpu *wb_memcg_completions(struct bdi_writeback *wb)
+{
+	return NULL;
+}
+
 static void wb_min_max_ratio(struct bdi_writeback *wb,
 			     unsigned long *minp, unsigned long *maxp)
 {
@@ -530,9 +540,16 @@ static void wb_domain_writeout_inc(struct wb_domain *dom,
  */
 static inline void __wb_writeout_inc(struct bdi_writeback *wb)
 {
+	struct wb_domain *cgdom;
+
 	__inc_wb_stat(wb, WB_WRITTEN);
 	wb_domain_writeout_inc(&global_wb_domain, &wb->completions,
 			       wb->bdi->max_prop_frac);
+
+	cgdom = mem_cgroup_wb_domain(wb);
+	if (cgdom)
+		wb_domain_writeout_inc(cgdom, wb_memcg_completions(wb),
+				       wb->bdi->max_prop_frac);
 }
 
 void wb_writeout_inc(struct bdi_writeback *wb)
@@ -583,6 +600,14 @@ int wb_domain_init(struct wb_domain *dom, gfp_t gfp)
 	return fprop_global_init(&dom->completions, gfp);
 }
 
+#ifdef CONFIG_CGROUP_WRITEBACK
+void wb_domain_exit(struct wb_domain *dom)
+{
+	del_timer_sync(&dom->period_timer);
+	fprop_global_destroy(&dom->completions);
+}
+#endif
+
 /*
  * bdi_min_ratio keeps the sum of the minimum dirty shares of all
  * registered backing devices, which, for obvious reasons, can not
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
