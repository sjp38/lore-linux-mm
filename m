Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 006926B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 05:13:11 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id fl4so92751136pad.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 02:13:10 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id hj1si12846430pac.235.2016.03.11.02.12.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 02:12:56 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH] mm: memcontrol: zap task_struct->memcg_oom_{gfp_mask,order}
Date: Fri, 11 Mar 2016 13:12:47 +0300
Message-ID: <1457691167-22756-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

These fields are used for dumping info about allocation that triggered
OOM. For cgroup this information doesn't make much sense, because OOM
killer is always invoked from page fault handler. It isn't worth the
space these fields occupy in the task_struct.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 include/linux/sched.h |  2 --
 mm/memcontrol.c       | 14 +++++---------
 2 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index ba8d8355c93a..626f5da5c43e 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1839,8 +1839,6 @@ struct task_struct {
 #endif
 #ifdef CONFIG_MEMCG
 	struct mem_cgroup *memcg_in_oom;
-	gfp_t memcg_oom_gfp_mask;
-	int memcg_oom_order;
 
 	/* number of pages to reclaim on returning to userland */
 	unsigned int memcg_nr_pages_over_high;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 36db05fa8acb..a217b1374c32 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1232,14 +1232,13 @@ static unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg)
 	return limit;
 }
 
-static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
-				     int order)
+static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg)
 {
 	struct oom_control oc = {
 		.zonelist = NULL,
 		.nodemask = NULL,
-		.gfp_mask = gfp_mask,
-		.order = order,
+		.gfp_mask = GFP_KERNEL,
+		.order = 0,
 	};
 	struct mem_cgroup *iter;
 	unsigned long chosen_points = 0;
@@ -1605,8 +1604,6 @@ static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
 	 */
 	css_get(&memcg->css);
 	current->memcg_in_oom = memcg;
-	current->memcg_oom_gfp_mask = mask;
-	current->memcg_oom_order = order;
 }
 
 /**
@@ -1656,8 +1653,7 @@ bool mem_cgroup_oom_synchronize(bool handle)
 	if (locked && !memcg->oom_kill_disable) {
 		mem_cgroup_unmark_under_oom(memcg);
 		finish_wait(&memcg_oom_waitq, &owait.wait);
-		mem_cgroup_out_of_memory(memcg, current->memcg_oom_gfp_mask,
-					 current->memcg_oom_order);
+		mem_cgroup_out_of_memory(memcg);
 	} else {
 		schedule();
 		mem_cgroup_unmark_under_oom(memcg);
@@ -5063,7 +5059,7 @@ static ssize_t memory_max_write(struct kernfs_open_file *of,
 		}
 
 		mem_cgroup_events(memcg, MEMCG_OOM, 1);
-		if (!mem_cgroup_out_of_memory(memcg, GFP_KERNEL, 0))
+		if (!mem_cgroup_out_of_memory(memcg))
 			break;
 	}
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
