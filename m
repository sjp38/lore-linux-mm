Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id A4A506B0072
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 03:32:30 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 1/6] don't call cpuacct_charge in stop_task.c
Date: Tue, 20 Nov 2012 12:31:59 +0400
Message-Id: <1353400324-10897-2-git-send-email-glommer@parallels.com>
In-Reply-To: <1353400324-10897-1-git-send-email-glommer@parallels.com>
References: <1353400324-10897-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Balbir Singh <bsingharora@gmail.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Glauber Costa <glommer@parallels.com>, Mike Galbraith <mgalbraith@suse.de>, Thomas Gleixner <tglx@linutronix.de>

Commit 8f618968 changed stop_task to do the same bookkeping as the
other classes. However, the call to cpuacct_charge() doesn't affect
the scheduler decisions at all, and doesn't need to be moved over.

Moreover, being a kthread, the migration thread won't belong to any
cgroup anyway, rendering this call quite useless.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Mike Galbraith <mgalbraith@suse.de>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Thomas Gleixner <tglx@linutronix.de>
---
 kernel/sched/stop_task.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/kernel/sched/stop_task.c b/kernel/sched/stop_task.c
index da5eb5b..fda1cbe 100644
--- a/kernel/sched/stop_task.c
+++ b/kernel/sched/stop_task.c
@@ -68,7 +68,6 @@ static void put_prev_task_stop(struct rq *rq, struct task_struct *prev)
 	account_group_exec_runtime(curr, delta_exec);
 
 	curr->se.exec_start = rq->clock_task;
-	cpuacct_charge(curr, delta_exec);
 }
 
 static void task_tick_stop(struct rq *rq, struct task_struct *curr, int queued)
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
