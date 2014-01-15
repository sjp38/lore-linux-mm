Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id D9FCB6B0039
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 10:01:46 -0500 (EST)
Received: by mail-ee0-f52.google.com with SMTP id e53so919124eek.39
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 07:01:46 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n47si8180169eef.199.2014.01.15.07.01.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Jan 2014 07:01:34 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 3/3] memcg,oom: do not check PF_EXITING and do not set TIF_MEMDIE
Date: Wed, 15 Jan 2014 16:01:08 +0100
Message-Id: <1389798068-19885-4-git-send-email-mhocko@suse.cz>
In-Reply-To: <1389798068-19885-1-git-send-email-mhocko@suse.cz>
References: <1389798068-19885-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

Memcg OOM handler mimics the global OOM handler heuristics. One of them
is to give a dying task (one with either fatal signals pending or
PF_EXITING set) access to memory reserves via TIF_MEMDIE flag. This is
not necessary though, because memory allocation has been already done
when it is charged against a memcg so we do not need to abuse the flag.

fatal_signal_pending check is a bit tricky because the current task might
have been killed during reclaim as an action done by vmpressure/thresholds
handlers and we would definitely want to prevent from OOM kill in such
situations.
The current check is incomplete, though, because it only works for
the current task because oom_scan_process_thread doesn't check for
fatal_signal_pending. oom_scan_process_thread is shared between
global and memcg OOM killer so we cannot simply abort scanning
for killed tasks. We can, instead, move the check downwards in
mem_cgroup_out_of_memory and break out from the tasks iteration loop
when a killed task is encountered. We could check for PF_EXITING as well
but it is dubious whether this would be helpful much more as a task
should exit quite quickly once it is scheduled.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 97ae5cf12f5e..ea9564895f54 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1761,16 +1761,6 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	unsigned int points = 0;
 	struct task_struct *chosen = NULL;
 
-	/*
-	 * If current has a pending SIGKILL or is exiting, then automatically
-	 * select it.  The goal is to allow it to allocate so that it may
-	 * quickly exit and free its memory.
-	 */
-	if (fatal_signal_pending(current)) {
-		set_thread_flag(TIF_MEMDIE);
-		return;
-	}
-
 	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, order, NULL);
 	totalpages = mem_cgroup_get_limit(memcg) >> PAGE_SHIFT ? : 1;
 	for_each_mem_cgroup_tree(iter, memcg) {
@@ -1779,6 +1769,16 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 
 		css_task_iter_start(&iter->css, &it);
 		while ((task = css_task_iter_next(&it))) {
+			/*
+			 * Killed tasks are selected automatically. The goal is
+			 * to give the task some more time to exit and release
+			 * the memory.
+			 * Unlike for the global OOM handler we do not need
+			 * access to memory reserves.
+			 */
+			if (fatal_signal_pending(task))
+				goto abort;
+
 			switch (oom_scan_process_thread(task, totalpages, NULL,
 							false)) {
 			case OOM_SCAN_SELECT:
@@ -1791,6 +1791,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 			case OOM_SCAN_CONTINUE:
 				continue;
 			case OOM_SCAN_ABORT:
+abort:
 				css_task_iter_end(&it);
 				mem_cgroup_iter_break(memcg, iter);
 				if (chosen)
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
