Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B7C326B0253
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 09:05:48 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id f199so6374093qke.6
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 06:05:48 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 63si707294qkl.106.2017.10.05.06.05.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Oct 2017 06:05:47 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [v11 2/6] mm: implement mem_cgroup_scan_tasks() for the root memory cgroup
Date: Thu, 5 Oct 2017 14:04:50 +0100
Message-ID: <20171005130454.5590-3-guro@fb.com>
In-Reply-To: <20171005130454.5590-1-guro@fb.com>
References: <20171005130454.5590-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

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
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: David Rientjes <rientjes@google.com>
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
index c7410636fadf..41d71f665550 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -917,7 +917,8 @@ static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
  * value, the function breaks the iteration loop and returns the value.
  * Otherwise, it will iterate over all tasks and return 0.
  *
- * This function must not be called for the root memory cgroup.
+ * If memcg is the root memory cgroup, this function will iterate only
+ * over tasks belonging directly to the root memory cgroup.
  */
 int mem_cgroup_scan_tasks(struct mem_cgroup *memcg,
 			  int (*fn)(struct task_struct *, void *), void *arg)
@@ -925,8 +926,6 @@ int mem_cgroup_scan_tasks(struct mem_cgroup *memcg,
 	struct mem_cgroup *iter;
 	int ret = 0;
 
-	BUG_ON(memcg == root_mem_cgroup);
-
 	for_each_mem_cgroup_tree(iter, memcg) {
 		struct css_task_iter it;
 		struct task_struct *task;
@@ -935,7 +934,7 @@ int mem_cgroup_scan_tasks(struct mem_cgroup *memcg,
 		while (!ret && (task = css_task_iter_next(&it)))
 			ret = fn(task, arg);
 		css_task_iter_end(&it);
-		if (ret) {
+		if (ret || memcg == root_mem_cgroup) {
 			mem_cgroup_iter_break(memcg, iter);
 			break;
 		}
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
