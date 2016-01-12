Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4A4A8828DF
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 16:00:40 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id u188so272404795wmu.1
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 13:00:40 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id g206si33882775wmf.4.2016.01.12.13.00.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 13:00:37 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id u188so33314160wmu.0
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 13:00:37 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC 2/3] oom: Do not sacrifice already OOM killed children
Date: Tue, 12 Jan 2016 22:00:24 +0100
Message-Id: <1452632425-20191-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1452632425-20191-1-git-send-email-mhocko@kernel.org>
References: <1452632425-20191-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

oom_kill_process tries to sacrifice a children process of the selected
victim to safe as much work done as possible. This is all and good but
the current heuristic doesn't check the status of the children before
they are examined. So it might be possible that we will end up selecting
the same child all over again just because it cannot terminate.

Tetsuo Handa has reported exactly this when trying to use sysrq+f to
resolve an OOM situation:
[   86.767482] a.out invoked oom-killer: order=0, oom_score_adj=0, gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|GFP_ZERO)
[   86.769905] a.out cpuset=/ mems_allowed=0
[   86.771393] CPU: 2 PID: 9573 Comm: a.out Not tainted 4.4.0-next-20160112+ #279
(...snipped...)
[   86.874710] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
(...snipped...)
[   86.945286] [ 9573]  1000  9573   541717   402522     796       6        0             0 a.out
[   86.947457] [ 9574]  1000  9574     1078       21       7       3        0             0 a.out
[   86.949568] Out of memory: Kill process 9573 (a.out) score 908 or sacrifice child
[   86.951538] Killed process 9574 (a.out) total-vm:4312kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[   86.955296] systemd-journal invoked oom-killer: order=0, oom_score_adj=0, gfp_mask=0x24201ca(GFP_HIGHUSER_MOVABLE|GFP_COLD)
[   86.958035] systemd-journal cpuset=/ mems_allowed=0
(...snipped...)
[   87.128808] [ 9573]  1000  9573   541717   402522     796       6        0             0 a.out
[   87.130926] [ 9575]  1000  9574     1078        0       7       3        0             0 a.out
[   87.133055] Out of memory: Kill process 9573 (a.out) score 908 or sacrifice child
[   87.134989] Killed process 9575 (a.out) total-vm:4312kB, anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  116.979564] sysrq: SysRq : Manual OOM execution
[  116.984119] kworker/0:8 invoked oom-killer: order=-1, oom_score_adj=0, gfp_mask=0x24000c0(GFP_KERNEL)
[  116.986367] kworker/0:8 cpuset=/ mems_allowed=0
(...snipped...)
[  117.157045] [ 9573]  1000  9573   541717   402522     797       6        0             0 a.out
[  117.159191] [ 9575]  1000  9574     1078        0       7       3        0             0 a.out
[  117.161302] Out of memory: Kill process 9573 (a.out) score 908 or sacrifice child
[  117.163250] Killed process 9575 (a.out) total-vm:4312kB, anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  119.043685] sysrq: SysRq : Manual OOM execution
[  119.046239] kworker/0:8 invoked oom-killer: order=-1, oom_score_adj=0, gfp_mask=0x24000c0(GFP_KERNEL)
[  119.048453] kworker/0:8 cpuset=/ mems_allowed=0
(...snipped...)
[  119.215982] [ 9573]  1000  9573   541717   402522     797       6        0             0 a.out
[  119.218122] [ 9575]  1000  9574     1078        0       7       3        0             0 a.out
[  119.220237] Out of memory: Kill process 9573 (a.out) score 908 or sacrifice child
[  119.222129] Killed process 9575 (a.out) total-vm:4312kB, anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  120.179644] sysrq: SysRq : Manual OOM execution
[  120.206938] kworker/0:8 invoked oom-killer: order=-1, oom_score_adj=0, gfp_mask=0x24000c0(GFP_KERNEL)
[  120.209152] kworker/0:8 cpuset=/ mems_allowed=0
[  120.376821] [ 9573]  1000  9573   541717   402522     797       6        0             0 a.out
[  120.378924] [ 9575]  1000  9574     1078        0       7       3        0             0 a.out
[  120.381065] Out of memory: Kill process 9573 (a.out) score 908 or sacrifice child
[  120.382929] Killed process 9575 (a.out) total-vm:4312kB, anon-rss:0kB, file-rss:0kB, shmem-rss:0kB

This patch simply rules out all the children which are OOM victims
already or have fatal_signal_pending or they are exiting already. It
simply doesn't make any sense to kill such tasks if they have already
been killed and the OOM situation wasn't resolved as we had to select a
new OOM victim. This is true for both the regular and forced oom killer
invocation.

While we are there let's separate this specific logic into a separate
function.

Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 89 ++++++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 58 insertions(+), 31 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 2b9dc5129a89..8bca0b1e97f7 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -671,6 +671,63 @@ static bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
 }
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
+
+/*
+ * If any of victim's children has a different mm and is eligible for kill,
+ * the one with the highest oom_badness() score is sacrificed for its
+ * parent.  This attempts to lose the minimal amount of work done while
+ * still freeing memory.
+ */
+static struct task_struct *
+try_to_sacrifice_child(struct oom_control *oc, struct task_struct *victim,
+		       unsigned long totalpages, struct mem_cgroup *memcg)
+{
+	struct task_struct *child_victim = NULL;
+	unsigned int victim_points = 0;
+	struct task_struct *t;
+
+	read_lock(&tasklist_lock);
+	for_each_thread(victim, t) {
+		struct task_struct *child;
+
+		list_for_each_entry(child, &t->children, sibling) {
+			unsigned int child_points;
+
+			/*
+			 * Skip over already OOM killed children as this hasn't
+			 * helped to resolve the situation obviously.
+			 */
+			if (test_tsk_thread_flag(child, TIF_MEMDIE) ||
+					fatal_signal_pending(child) ||
+					task_will_free_mem(child))
+				continue;
+
+			if (process_shares_mm(child, victim->mm))
+				continue;
+
+			child_points = oom_badness(child, memcg, oc->nodemask,
+								totalpages);
+			if (child_points > victim_points) {
+				if (child_victim)
+					put_task_struct(child_victim);
+				child_victim = child;
+				victim_points = child_points;
+				get_task_struct(child_victim);
+			}
+		}
+	}
+	read_unlock(&tasklist_lock);
+
+	if (!child_victim)
+		goto out;
+
+	put_task_struct(victim);
+	victim = child_victim;
+
+out:
+	return victim;
+}
+
 /*
  * Must be called while holding a reference to p, which will be released upon
  * returning.
@@ -680,10 +737,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 		      struct mem_cgroup *memcg, const char *message)
 {
 	struct task_struct *victim = p;
-	struct task_struct *child;
-	struct task_struct *t;
 	struct mm_struct *mm;
-	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
 	bool can_oom_reap = true;
@@ -707,34 +761,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
 		message, task_pid_nr(p), p->comm, points);
 
-	/*
-	 * If any of p's children has a different mm and is eligible for kill,
-	 * the one with the highest oom_badness() score is sacrificed for its
-	 * parent.  This attempts to lose the minimal amount of work done while
-	 * still freeing memory.
-	 */
-	read_lock(&tasklist_lock);
-	for_each_thread(p, t) {
-		list_for_each_entry(child, &t->children, sibling) {
-			unsigned int child_points;
-
-			if (process_shares_mm(child, p->mm))
-				continue;
-			/*
-			 * oom_badness() returns 0 if the thread is unkillable
-			 */
-			child_points = oom_badness(child, memcg, oc->nodemask,
-								totalpages);
-			if (child_points > victim_points) {
-				put_task_struct(victim);
-				victim = child;
-				victim_points = child_points;
-				get_task_struct(victim);
-			}
-		}
-	}
-	read_unlock(&tasklist_lock);
-
+	victim = try_to_sacrifice_child(oc, victim, totalpages, memcg);
 	p = find_lock_task_mm(victim);
 	if (!p) {
 		put_task_struct(victim);
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
