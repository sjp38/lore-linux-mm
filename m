Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 41A916B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 08:52:13 -0500 (EST)
Received: by mail-ig0-f171.google.com with SMTP id y8so38904140igp.0
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 05:52:13 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id p62si21544789ioi.76.2016.02.19.05.52.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Feb 2016 05:52:12 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm: memcontrol: Pass NULL memcg for oom_badness() check.
Date: Fri, 19 Feb 2016 22:51:38 +0900
Message-Id: <1455889898-5659-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com, hannes@cmpxchg.org, mhocko@kernel.org, vdavydov@virtuozzo.com
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Currently, mem_cgroup_out_of_memory() is calling
oom_scan_process_thread(&oc, task, totalpages) which includes
a call to oom_unkillable_task(task, NULL, NULL) and then is
calling oom_badness(task, memcg, NULL, totalpages) which includes
a call to oom_unkillable_task(task, memcg, NULL).

Since for_each_mem_cgroup_tree() iterates on only tasks from the given
memcg hierarchy, there is no point with passing non-NULL memcg argument
to oom_unkillable_task() via oom_badness().

Replace memcg argument with NULL in order to save a call to
task_in_mem_cgroup(task, memcg) in oom_unkillable_task()
which is always true.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ae8b81c..3c96dd3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1290,7 +1290,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 			case OOM_SCAN_OK:
 				break;
 			};
-			points = oom_badness(task, memcg, NULL, totalpages);
+			points = oom_badness(task, NULL, NULL, totalpages);
 			if (!points || points < chosen_points)
 				continue;
 			/* Prefer thread group leaders for display purposes */
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
