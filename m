Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f45.google.com (mail-bk0-f45.google.com [209.85.214.45])
	by kanga.kvack.org (Postfix) with ESMTP id D22DF6B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 18:43:14 -0500 (EST)
Received: by mail-bk0-f45.google.com with SMTP id v16so943242bkz.32
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 15:43:14 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id lu3si3889180bkb.302.2014.01.15.15.43.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Jan 2014 15:43:13 -0800 (PST)
Date: Wed, 15 Jan 2014 18:43:08 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: oom_kill: revert 3% system memory bonus for privileged
 tasks
Message-ID: <20140115234308.GB4407@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

With a63d83f427fb ("oom: badness heuristic rewrite"), the OOM killer
tries to avoid killing privileged tasks by subtracting 3% of overall
memory (system or cgroup) from their per-task consumption.  But as a
result, all root tasks that consume less than 3% of overall memory are
considered equal, and so it only takes 33+ privileged tasks pushing
the system out of memory for the OOM killer to do something stupid and
kill sshd or dhclient.  For example, on a 32G machine it can't tell
the difference between the 1M agetty and the 10G fork bomb member.

The changelog describes this 3% boost as the equivalent to the global
overcommit limit being 3% higher for privileged tasks, but this is not
the same as discounting 3% of overall memory from _every privileged
task individually_ during OOM selection.

Revert back to the old priority boost of pretending root tasks are
only a quarter of their actual size.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/oom_kill.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1e4a600a6163..1b0011c3d9e2 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -166,11 +166,11 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	task_unlock(p);
 
 	/*
-	 * Root processes get 3% bonus, just like the __vm_enough_memory()
-	 * implementation used by LSMs.
+	 * Memory consumption being equal, prefer killing an
+	 * unprivileged task over a root task.
 	 */
 	if (has_capability_noaudit(p, CAP_SYS_ADMIN))
-		adj -= 30;
+		points /= 4;
 
 	/* Normalize to oom_score_adj units */
 	adj *= totalpages / 1000;
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
