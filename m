Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id D332990001C
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 10:08:13 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id n3so10665173wiv.5
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 07:08:13 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lt5si203997wjb.39.2014.10.08.07.08.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Oct 2014 07:08:12 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 3/3] OOM, PM: OOM killed task cannot escape PM suspend
Date: Wed,  8 Oct 2014 16:07:46 +0200
Message-Id: <1412777266-8251-4-git-send-email-mhocko@suse.cz>
In-Reply-To: <1412777266-8251-1-git-send-email-mhocko@suse.cz>
References: <1412777266-8251-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>
Cc: Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

PM freezer relies on having all tasks frozen by the time devices are
getting frozen so that no task will touch them while they are getting
frozen. But OOM killer is allowed to kill an already frozen task in
order to handle OOM situtation. In order to protect from late wake ups
OOM killer is disabled after all tasks are frozen. This, however, still
keeps a window open when a killed task didn't manage to die by the time
freeze_processes finishes.

Fix this race by checking all tasks after OOM killer has been disabled.
To prevent from useless check also introduce and check oom_kills count
which gets incremented when a task is killed by OOM killer. All the
tasks have to be checked only if the counter changes.

Fixes: f660daac474c6f (oom: thaw threads if oom killed thread is frozen before deferring)
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Rafael J. Wysocki <rjw@rjwysocki.net>
Cc: Tejun Heo <tj@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: stable@vger.kernel.org # 3.2+
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/oom.h    |  2 ++
 kernel/power/process.c | 31 ++++++++++++++++++++++++++++++-
 mm/oom_kill.c          | 14 ++++++++++++++
 3 files changed, 46 insertions(+), 1 deletion(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 647395a1a550..8927b6e443b5 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -50,6 +50,8 @@ static inline bool oom_task_origin(const struct task_struct *p)
 extern unsigned long oom_badness(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask,
 		unsigned long totalpages);
+
+extern int oom_kills_count(void);
 extern void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 			     unsigned int points, unsigned long totalpages,
 			     struct mem_cgroup *memcg, nodemask_t *nodemask,
diff --git a/kernel/power/process.c b/kernel/power/process.c
index 4ee194eb524b..6ccc2e10724d 100644
--- a/kernel/power/process.c
+++ b/kernel/power/process.c
@@ -118,6 +118,7 @@ static int try_to_freeze_tasks(bool user_only)
 int freeze_processes(void)
 {
 	int error;
+	int oom_kills_saved;
 
 	error = __usermodehelper_disable(UMH_FREEZING);
 	if (error)
@@ -131,12 +132,40 @@ int freeze_processes(void)
 
 	printk("Freezing user space processes ... ");
 	pm_freezing = true;
+	oom_kills_saved = oom_kills_count();
 	error = try_to_freeze_tasks(true);
 	if (!error) {
-		printk("done.");
 		__usermodehelper_set_disable_depth(UMH_DISABLED);
 		oom_killer_disable();
+
+		/*
+		 * There was a OOM kill while we were freezing tasks
+		 * and the killed task might be still on the way out
+		 * so we have to double check for race.
+		 */
+		if (oom_kills_count() != oom_kills_saved) {
+			struct task_struct *g, *p;
+
+			read_lock(&tasklist_lock);
+			do_each_thread(g, p) {
+				if (p == current || freezer_should_skip(p) ||
+				    frozen(p))
+					continue;
+				error = -EBUSY;
+				break;
+			} while_each_thread(g, p);
+			read_unlock(&tasklist_lock);
+
+			if (error) {
+				__usermodehelper_set_disable_depth(UMH_ENABLED);
+				oom_killer_enable();
+				printk("OOM in progress. ");
+				goto done;
+			}
+		}
+		printk("done.");
 	}
+done:
 	printk("\n");
 	BUG_ON(in_atomic());
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8975b983a82c..ca96b01f4d7e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -402,6 +402,18 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 		dump_tasks(memcg, nodemask);
 }
 
+/*
+ * Number of OOM killer invocations (including memcg OOM killer).
+ * Primarily used by PM freezer to check for potential races with
+ * OOM killed frozen task.
+ */
+static atomic_t oom_kills = ATOMIC_INIT(0);
+
+int oom_kills_count(void)
+{
+	return atomic_read(&oom_kills);
+}
+
 #define K(x) ((x) << (PAGE_SHIFT-10))
 /*
  * Must be called while holding a reference to p, which will be released upon
@@ -504,11 +516,13 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 			pr_err("Kill process %d (%s) sharing same memory\n",
 				task_pid_nr(p), p->comm);
 			task_unlock(p);
+			atomic_inc(&oom_kills);
 			do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
 		}
 	rcu_read_unlock();
 
 	set_tsk_thread_flag(victim, TIF_MEMDIE);
+	atomic_inc(&oom_kills);
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
 	put_task_struct(victim);
 }
-- 
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
