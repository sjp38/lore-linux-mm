Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8C95B6B0266
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 10:29:32 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id t65so5115784pfe.22
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 07:29:32 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id q75si3414337pfk.177.2017.11.30.07.29.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 07:29:31 -0800 (PST)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH v13 2/7] mm: implement mem_cgroup_scan_tasks() for the root memory cgroup
Date: Thu, 30 Nov 2017 15:28:19 +0000
Message-ID: <20171130152824.1591-3-guro@fb.com>
In-Reply-To: <20171130152824.1591-1-guro@fb.com>
References: <20171130152824.1591-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@vger.kernel.org
Cc: Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Implement mem_cgroup_scan_tasks() functionality for the root
memory cgroup to use this function for looking for a OOM victim
task in the root memory cgroup by the cgroup-ware OOM killer.

The root memory cgroup is treated as a leaf cgroup, so only tasks
which are directly belonging to the root cgroup are iterated over.

This patch doesn't introduce any functional change as
mem_cgroup_scan_tasks() is never called for the root memcg.
This is preparatory work for the cgroup-aware OOM killer,
which will use this function to iterate over tasks belonging
to the root memcg.

Signed-off-by: Roman Gushchin <guro@fb.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: David Rientjes <rientjes@google.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: kernel-team@fb.com
Cc: cgroups@vger.kernel.org
Cc: linux-doc@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
 mm/memcontrol.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a4aac306ebe3..55fbda60cef6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -888,7 +888,8 @@ static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
  * value, the function breaks the iteration loop and returns the value.
  * Otherwise, it will iterate over all tasks and return 0.
  *
- * This function must not be called for the root memory cgroup.
+ * If memcg is the root memory cgroup, this function will iterate only
+ * over tasks belonging directly to the root memory cgroup.
  */
 int mem_cgroup_scan_tasks(struct mem_cgroup *memcg,
 			  int (*fn)(struct task_struct *, void *), void *arg)
@@ -896,8 +897,6 @@ int mem_cgroup_scan_tasks(struct mem_cgroup *memcg,
 	struct mem_cgroup *iter;
 	int ret = 0;
 
-	BUG_ON(memcg == root_mem_cgroup);
-
 	for_each_mem_cgroup_tree(iter, memcg) {
 		struct css_task_iter it;
 		struct task_struct *task;
@@ -906,7 +905,7 @@ int mem_cgroup_scan_tasks(struct mem_cgroup *memcg,
 		while (!ret && (task = css_task_iter_next(&it)))
 			ret = fn(task, arg);
 		css_task_iter_end(&it);
-		if (ret) {
+		if (ret || memcg == root_mem_cgroup) {
 			mem_cgroup_iter_break(memcg, iter);
 			break;
 		}
-- 
2.14.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
