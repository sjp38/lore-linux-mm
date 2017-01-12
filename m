Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 56C356B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 23:32:15 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 80so24021911pfy.2
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 20:32:15 -0800 (PST)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id v9si7909394pfl.280.2017.01.11.20.32.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 20:32:14 -0800 (PST)
Received: by mail-pf0-x22b.google.com with SMTP id f144so5830874pfa.2
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 20:32:14 -0800 (PST)
Date: Wed, 11 Jan 2017 20:32:12 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, memcg: do not retry precharge charges
Message-ID: <alpine.DEB.2.10.1701112031250.94269@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

When memory.move_charge_at_immigrate is enabled and precharges are
depleted during move, mem_cgroup_move_charge_pte_range() will attempt to
increase the size of the precharge.

This livelocks if reclaim fails and if an oom killed process attached to
the destination memcg is trying to exit, which requires 
cgroup_threadgroup_rwsem, since we're holding the mutex (we also livelock
while holding mm->mmap_sem for read).

Prevent precharges from ever looping by setting __GFP_NORETRY.  This was
probably the intention of the GFP_KERNEL & ~__GFP_NORETRY, which is
pointless as written.

This also restructures mem_cgroup_wait_acct_move() since it is not
possible for mc.moving_task to be current.

Fixes: 0029e19ebf84 ("mm: memcontrol: remove explicit OOM parameter in charge path")
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/memcontrol.c | 32 +++++++++++++++++++-------------
 1 file changed, 19 insertions(+), 13 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1125,18 +1125,19 @@ static bool mem_cgroup_under_move(struct mem_cgroup *memcg)
 
 static bool mem_cgroup_wait_acct_move(struct mem_cgroup *memcg)
 {
-	if (mc.moving_task && current != mc.moving_task) {
-		if (mem_cgroup_under_move(memcg)) {
-			DEFINE_WAIT(wait);
-			prepare_to_wait(&mc.waitq, &wait, TASK_INTERRUPTIBLE);
-			/* moving charge context might have finished. */
-			if (mc.moving_task)
-				schedule();
-			finish_wait(&mc.waitq, &wait);
-			return true;
-		}
+	DEFINE_WAIT(wait);
+
+	if (likely(!mem_cgroup_under_move(memcg)))
+		return false;
+
+	prepare_to_wait(&mc.waitq, &wait, TASK_INTERRUPTIBLE);
+	/* moving charge context might have finished. */
+	if (mc.moving_task) {
+		WARN_ON_ONCE(mc.moving_task == current);
+		schedule();
 	}
-	return false;
+	finish_wait(&mc.waitq, &wait);
+	return true;
 }
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
@@ -4355,9 +4356,14 @@ static int mem_cgroup_do_precharge(unsigned long count)
 		return ret;
 	}
 
-	/* Try charges one by one with reclaim */
+	/*
+	 * Try charges one by one with reclaim, but do not retry.  This avoids
+	 * looping forever when try_charge() cannot reclaim memory and the oom
+	 * killer defers while waiting for a process to exit which is trying to
+	 * acquire cgroup_threadgroup_rwsem in the exit path.
+	 */
 	while (count--) {
-		ret = try_charge(mc.to, GFP_KERNEL & ~__GFP_NORETRY, 1);
+		ret = try_charge(mc.to, GFP_KERNEL | __GFP_NORETRY, 1);
 		if (ret)
 			return ret;
 		mc.precharge++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
