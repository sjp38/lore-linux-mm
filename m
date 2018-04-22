Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Wang Long <wanglong19@meituan.com>
Subject: [PATCH v2] memcg: writeback: use memcg->cgwb_list directly
Date: Sun, 22 Apr 2018 22:09:33 +0800
Message-Id: <1524406173-212182-1-git-send-email-wanglong19@meituan.com>
Sender: linux-kernel-owner@vger.kernel.org
To: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com
Cc: aryabinin@virtuozzo.com, akpm@linux-foundation.org, wanglong19@meituan.com, khlebnikov@yandex-team.ru, xboe@kernel.dk, jack@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gthelen@google.com, tj@kernel.org
List-ID: <linux-mm.kvack.org>

mem_cgroup_cgwb_list is a very simple wrapper and it will
never be used outside of code under CONFIG_CGROUP_WRITEBACK.
so use memcg->cgwb_list directly.

Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Wang Long <wanglong19@meituan.com>
---
 include/linux/memcontrol.h | 1 -
 mm/backing-dev.c           | 4 ++--
 mm/memcontrol.c            | 5 -----
 3 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index d99b71b..c0056e0 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -1093,7 +1093,6 @@ static inline void dec_lruvec_page_state(struct page *page,
 
 #ifdef CONFIG_CGROUP_WRITEBACK
 
-struct list_head *mem_cgroup_cgwb_list(struct mem_cgroup *memcg);
 struct wb_domain *mem_cgroup_wb_domain(struct bdi_writeback *wb);
 void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
 			 unsigned long *pheadroom, unsigned long *pdirty,
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 023190c..0a48e05 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -555,7 +555,7 @@ static int cgwb_create(struct backing_dev_info *bdi,
 	memcg = mem_cgroup_from_css(memcg_css);
 	blkcg_css = cgroup_get_e_css(memcg_css->cgroup, &io_cgrp_subsys);
 	blkcg = css_to_blkcg(blkcg_css);
-	memcg_cgwb_list = mem_cgroup_cgwb_list(memcg);
+	memcg_cgwb_list = &memcg->cgwb_list;
 	blkcg_cgwb_list = &blkcg->cgwb_list;
 
 	/* look up again under lock and discard on blkcg mismatch */
@@ -734,7 +734,7 @@ static void cgwb_bdi_unregister(struct backing_dev_info *bdi)
  */
 void wb_memcg_offline(struct mem_cgroup *memcg)
 {
-	struct list_head *memcg_cgwb_list = mem_cgroup_cgwb_list(memcg);
+	struct list_head *memcg_cgwb_list = &memcg->cgwb_list;
 	struct bdi_writeback *wb, *next;
 
 	spin_lock_irq(&cgwb_lock);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e074f7c..d1adb9c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3562,11 +3562,6 @@ static int mem_cgroup_oom_control_write(struct cgroup_subsys_state *css,
 
 #ifdef CONFIG_CGROUP_WRITEBACK
 
-struct list_head *mem_cgroup_cgwb_list(struct mem_cgroup *memcg)
-{
-	return &memcg->cgwb_list;
-}
-
 static int memcg_wb_domain_init(struct mem_cgroup *memcg, gfp_t gfp)
 {
 	return wb_domain_init(&memcg->cgwb_domain, gfp);
-- 
1.8.3.1
