Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9F9F36B40D0
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 09:51:09 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g18-v6so3982908edg.14
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 06:51:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r13-v6sor4793050eda.38.2018.08.27.06.51.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Aug 2018 06:51:08 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at should_reclaim_retry().
Date: Mon, 27 Aug 2018 15:51:01 +0200
Message-Id: <20180827135101.15700-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>

From: Michal Hocko <mhocko@suse.com>

Tetsuo Handa has reported that it is possible to bypass the short sleep
for PF_WQ_WORKER threads which was introduced by commit 373ccbe5927034b5
("mm, vmstat: allow WQ concurrency to discover memory reclaim doesn't make
any progress") and lock up the system if OOM.

The primary reason is that WQ_MEM_RECLAIM WQs are not guaranteed to
run even when they have a rescuer available. Those workers might be
essential for reclaim to make a forward progress, however. If we are
too unlucky all the allocations requests can get stuck waiting for a
WQ_MEM_RECLAIM work item and the system is essentially stuck in an OOM
condition without much hope to move on. Tetsuo has seen the reclaim
stuck on drain_local_pages_wq or xlog_cil_push_work (xfs). There might
be others.

Since should_reclaim_retry() should be a natural reschedule point,
let's do the short sleep for PF_WQ_WORKER threads unconditionally in
order to guarantee that other pending work items are started. This will
workaround this problem and it is less fragile than hunting down when
the sleep is missed. E.g. we used to have a sleeping point in the oom
path but this has been removed recently because it caused other issues.
Having a single sleeping point is more robust.

Reported-and-debugged-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Michal Hocko <mhocko@suse.com>
Cc: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>
---

Hi Andrew,
this has been previously posted [1] but it took quite some time to
finally understand the issue [2]. Can we push this to mmotm and
linux-next? I wouldn't hurry to merge this but the longer we have a
wider testing exposure the better.

Thanks!

[1] http://lkml.kernel.org/r/ca3da8b8-1bb5-c302-b190-fa6cebab58ca@I-love.SAKURA.ne.jp
[2] http://lkml.kernel.org/r/20180730145425.GE1206094@devbig004.ftw2.facebook.com

 mm/page_alloc.c | 34 ++++++++++++++++++----------------
 1 file changed, 18 insertions(+), 16 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e75865d58ba7..5fc5e500b5d0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3923,6 +3923,7 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 {
 	struct zone *zone;
 	struct zoneref *z;
+	bool ret = false;
 
 	/*
 	 * Costly allocations might have made a progress but this doesn't mean
@@ -3986,25 +3987,26 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 				}
 			}
 
-			/*
-			 * Memory allocation/reclaim might be called from a WQ
-			 * context and the current implementation of the WQ
-			 * concurrency control doesn't recognize that
-			 * a particular WQ is congested if the worker thread is
-			 * looping without ever sleeping. Therefore we have to
-			 * do a short sleep here rather than calling
-			 * cond_resched().
-			 */
-			if (current->flags & PF_WQ_WORKER)
-				schedule_timeout_uninterruptible(1);
-			else
-				cond_resched();
-
-			return true;
+			ret = true;
+			goto out;
 		}
 	}
 
-	return false;
+out:
+	/*
+	 * Memory allocation/reclaim might be called from a WQ
+	 * context and the current implementation of the WQ
+	 * concurrency control doesn't recognize that
+	 * a particular WQ is congested if the worker thread is
+	 * looping without ever sleeping. Therefore we have to
+	 * do a short sleep here rather than calling
+	 * cond_resched().
+	 */
+	if (current->flags & PF_WQ_WORKER)
+		schedule_timeout_uninterruptible(1);
+	else
+		cond_resched();
+	return ret;
 }
 
 static inline bool
-- 
2.18.0
