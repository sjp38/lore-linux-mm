Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id D33D76B009A
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 10:08:11 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id m15so11543690wgh.4
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 07:08:11 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id el2si103103wjd.108.2014.10.08.07.08.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Oct 2014 07:08:11 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 1/3] freezer: check OOM kill while being frozen
Date: Wed,  8 Oct 2014 16:07:44 +0200
Message-Id: <1412777266-8251-2-git-send-email-mhocko@suse.cz>
In-Reply-To: <1412777266-8251-1-git-send-email-mhocko@suse.cz>
References: <1412777266-8251-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>
Cc: Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

From: Cong Wang <xiyou.wangcong@gmail.com>

Since f660daac474c6f (oom: thaw threads if oom killed thread is frozen
before deferring) OOM killer relies on being able to thaw a frozen task
to handle OOM situation but a3201227f803 (freezer: make freezing() test
freeze conditions in effect instead of TIF_FREEZE) has reorganized the
code and stopped clearing freeze flag in __thaw_task. This means that
the target task only wakes up and goes into the fridge again because the
freezing condition hasn't changed for it. This reintroduces the bug
fixed by f660daac474c6f.

Fix the issue by checking for TIF_MEMDIE thread flag and get away from
the fridge if it is set. oom_scan_process_thread doesn't have to check
for the frozen task anymore because do_send_sig_info will wake up the
thread and TIF_MEMDIE is already set by that time.

[mhocko@suse.cz: rewrote the changelog]
Fixes: a3201227f803 (freezer: make freezing() test freeze conditions in effect instead of TIF_FREEZE)
Cc: stable@vger.kernel.org # 3.3+
Cc: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Acked-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 kernel/freezer.c | 20 +++++++++++++++++---
 mm/oom_kill.c    |  2 --
 2 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/kernel/freezer.c b/kernel/freezer.c
index aa6a8aadb911..77ad6794b610 100644
--- a/kernel/freezer.c
+++ b/kernel/freezer.c
@@ -45,13 +45,28 @@ bool freezing_slow_path(struct task_struct *p)
 	if (pm_nosig_freezing || cgroup_freezing(p))
 		return true;
 
-	if (pm_freezing && !(p->flags & PF_KTHREAD))
+	if (!(p->flags & PF_KTHREAD))
 		return true;
 
 	return false;
 }
 EXPORT_SYMBOL(freezing_slow_path);
 
+static bool should_thaw_current(bool check_kthr_stop)
+{
+	if (!freezing(current))
+		return true;
+
+	if (check_kthr_stop && kthread_should_stop())
+		return true;
+
+	/* It might not be safe to check TIF_MEMDIE for pm freeze. */
+	if (cgroup_freezing(current) && test_thread_flag(TIF_MEMDIE))
+		return true;
+
+	return false;
+}
+
 /* Refrigerator is place where frozen processes are stored :-). */
 bool __refrigerator(bool check_kthr_stop)
 {
@@ -67,8 +82,7 @@ bool __refrigerator(bool check_kthr_stop)
 
 		spin_lock_irq(&freezer_lock);
 		current->flags |= PF_FROZEN;
-		if (!freezing(current) ||
-		    (check_kthr_stop && kthread_should_stop()))
+		if (should_thaw_current(check_kthr_stop))
 			current->flags &= ~PF_FROZEN;
 		spin_unlock_irq(&freezer_lock);
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index bbf405a3a18f..8975b983a82c 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -266,8 +266,6 @@ enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
 	 * Don't allow any other task to have access to the reserves.
 	 */
 	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
-		if (unlikely(frozen(task)))
-			__thaw_task(task);
 		if (!force_kill)
 			return OOM_SCAN_ABORT;
 	}
-- 
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
