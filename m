Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id A84196B0005
	for <linux-mm@kvack.org>; Fri, 20 May 2016 10:09:24 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id c9so51419342ioj.3
        for <linux-mm@kvack.org>; Fri, 20 May 2016 07:09:24 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id d3si5303493itb.76.2016.05.20.07.09.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 May 2016 07:09:21 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] memcg: fix mem_cgroup_out_of_memory() return value.
Date: Fri, 20 May 2016 23:08:47 +0900
Message-Id: <1463753327-5170-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@virtuozzo.com>

mem_cgroup_out_of_memory() is returning "true" if it finds a TIF_MEMDIE
task after an eligible task was found, "false" if it found a TIF_MEMDIE
task before an eligible task is found.

This difference confuses memory_max_write() which checks the return value
of mem_cgroup_out_of_memory(). Since memory_max_write() wants to continue
looping, mem_cgroup_out_of_memory() should return "true" in this case.

This patch sets a dummy pointer in order to return "true".

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/memcontrol.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b3f16ab..ab574d8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1302,6 +1302,8 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 				mem_cgroup_iter_break(memcg, iter);
 				if (chosen)
 					put_task_struct(chosen);
+				/* Set a dummy value to return "true". */
+				chosen = (void *) 1;
 				goto unlock;
 			case OOM_SCAN_OK:
 				break;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
