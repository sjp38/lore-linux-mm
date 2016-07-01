Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A73216B025E
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 05:26:54 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f126so13368337wma.3
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 02:26:54 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id yu6si2733516wjb.118.2016.07.01.02.26.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 02:26:53 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id 187so3863749wmz.1
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 02:26:53 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 2/6] oom, suspend: fix oom_killer_disable vs. pm suspend properly
Date: Fri,  1 Jul 2016 11:26:26 +0200
Message-Id: <1467365190-24640-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1467365190-24640-1-git-send-email-mhocko@kernel.org>
References: <1467365190-24640-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

74070542099c ("oom, suspend: fix oom_reaper vs. oom_killer_disable
race") has workaround an existing race between oom_killer_disable
and oom_reaper by adding another round of try_to_freeze_tasks after
the oom killer was disabled. This was an easiest thing to do for
a late 4.7 fix. Let's fix it properly now.

After "oom: keep mm of the killed task available" we no longer call
exit_oom_victim from the oom reaper so the race described in the above
commit doesn't exist anymore. Unfortunately this alone is not sufficient
for the oom_killer_disable usecase because now we do not have any
reliable way to reach exit_oom_victim (the victim might get stuck on a
way to exit for an unbounded amount of time). OOM killer can cope with
that by checking mm flags and move on to another victim but we cannot
do the same for oom_killer_disable as we would lose the guarantee of no
further interference of the victim with the rest of the system. What we
can do instead is to cap the maximum time the oom_killer_disable waits
for victims. The only current user of this function (pm suspend) already
has a concept of timeout for back off so we can reuse the same value
there.

Let's drop set_freezable for the oom_reaper kthread because it is no
longer needed as the reaper doesn't wake or thaw any processes.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/oom.h    |  2 +-
 kernel/power/process.c | 17 +++--------------
 mm/oom_kill.c          | 33 ++++++++++++++++++++-------------
 3 files changed, 24 insertions(+), 28 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 5bc0457ee3a8..eb44374a3f32 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -102,7 +102,7 @@ extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
 
 extern bool oom_killer_disabled;
-extern bool oom_killer_disable(void);
+extern bool oom_killer_disable(signed long timeout);
 extern void oom_killer_enable(void);
 
 extern struct task_struct *find_lock_task_mm(struct task_struct *p);
diff --git a/kernel/power/process.c b/kernel/power/process.c
index 0c2ee9761d57..2456f10c7326 100644
--- a/kernel/power/process.c
+++ b/kernel/power/process.c
@@ -141,23 +141,12 @@ int freeze_processes(void)
 	/*
 	 * Now that the whole userspace is frozen we need to disbale
 	 * the OOM killer to disallow any further interference with
-	 * killable tasks.
+	 * killable tasks. There is no guarantee oom victims will
+	 * ever reach a point they go away we have to wait with a timeout.
 	 */
-	if (!error && !oom_killer_disable())
+	if (!error && !oom_killer_disable(msecs_to_jiffies(freeze_timeout_msecs)))
 		error = -EBUSY;
 
-	/*
-	 * There is a hard to fix race between oom_reaper kernel thread
-	 * and oom_killer_disable. oom_reaper calls exit_oom_victim
-	 * before the victim reaches exit_mm so try to freeze all the tasks
-	 * again and catch such a left over task.
-	 */
-	if (!error) {
-		pr_info("Double checking all user space processes after OOM killer disable... ");
-		error = try_to_freeze_tasks(true);
-		pr_cont("\n");
-	}
-
 	if (error)
 		thaw_processes();
 	return error;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4ea4a649822d..4ac089cba353 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -583,8 +583,6 @@ static void oom_reap_task(struct task_struct *tsk)
 
 static int oom_reaper(void *unused)
 {
-	set_freezable();
-
 	while (true) {
 		struct task_struct *tsk = NULL;
 
@@ -683,10 +681,20 @@ void exit_oom_victim(struct task_struct *tsk)
 }
 
 /**
+ * oom_killer_enable - enable OOM killer
+ */
+void oom_killer_enable(void)
+{
+	oom_killer_disabled = false;
+}
+
+/**
  * oom_killer_disable - disable OOM killer
+ * @timeout: maximum timeout to wait for oom victims in jiffies
  *
  * Forces all page allocations to fail rather than trigger OOM killer.
- * Will block and wait until all OOM victims are killed.
+ * Will block and wait until all OOM victims are killed or the given
+ * timeout expires.
  *
  * The function cannot be called when there are runnable user tasks because
  * the userspace would see unexpected allocation failures as a result. Any
@@ -695,8 +703,10 @@ void exit_oom_victim(struct task_struct *tsk)
  * Returns true if successful and false if the OOM killer cannot be
  * disabled.
  */
-bool oom_killer_disable(void)
+bool oom_killer_disable(signed long timeout)
 {
+	signed long ret;
+
 	/*
 	 * Make sure to not race with an ongoing OOM killer. Check that the
 	 * current is not killed (possibly due to sharing the victim's memory).
@@ -706,19 +716,16 @@ bool oom_killer_disable(void)
 	oom_killer_disabled = true;
 	mutex_unlock(&oom_lock);
 
-	wait_event(oom_victims_wait, !atomic_read(&oom_victims));
+	ret = wait_event_interruptible_timeout(oom_victims_wait,
+			!atomic_read(&oom_victims), timeout);
+	if (ret <= 0) {
+		oom_killer_enable();
+		return false;
+	}
 
 	return true;
 }
 
-/**
- * oom_killer_enable - enable OOM killer
- */
-void oom_killer_enable(void)
-{
-	oom_killer_disabled = false;
-}
-
 static inline bool __task_will_free_mem(struct task_struct *task)
 {
 	struct signal_struct *sig = task->signal;
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
