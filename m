Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5382A828DF
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 10:15:44 -0500 (EST)
Received: by mail-io0-f169.google.com with SMTP id z76so29411793iof.3
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 07:15:44 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id c21si5197149ioe.188.2016.03.08.07.15.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Mar 2016 07:15:43 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm: memcontrol: drop unnecessary task_will_free_mem() check.
Date: Wed,  9 Mar 2016 00:15:10 +0900
Message-Id: <1457450110-6005-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov@virtuozzo.com
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Since mem_cgroup_out_of_memory() is called by
mem_cgroup_oom_synchronize(true) via pagefault_out_of_memory() via
page fault, and possible allocations between setting PF_EXITING and
calling exit_mm() are tty_audit_exit() and taskstats_exit() which will
not trigger page fault, task_will_free_mem(current) in
mem_cgroup_out_of_memory() is never true.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/memcontrol.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ae8b81c..701bef1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1254,11 +1254,11 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	mutex_lock(&oom_lock);
 
 	/*
-	 * If current has a pending SIGKILL or is exiting, then automatically
-	 * select it.  The goal is to allow it to allocate so that it may
-	 * quickly exit and free its memory.
+	 * If current has a pending SIGKILL, then automatically select it.
+	 * The goal is to allow it to allocate so that it may quickly exit
+	 * and free its memory.
 	 */
-	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
+	if (fatal_signal_pending(current)) {
 		mark_oom_victim(current);
 		goto unlock;
 	}
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
