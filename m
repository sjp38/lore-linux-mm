Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id EE8036B0269
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 08:44:20 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id js8so27046828lbc.2
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 05:44:20 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id z7si15704630wmb.54.2016.06.20.05.44.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 05:44:02 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id c82so10858665wme.3
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 05:44:02 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 10/10] mm, oom: hide mm which is shared with kthread or global init
Date: Mon, 20 Jun 2016 14:43:48 +0200
Message-Id: <1466426628-15074-11-git-send-email-mhocko@kernel.org>
In-Reply-To: <1466426628-15074-1-git-send-email-mhocko@kernel.org>
References: <1466426628-15074-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

The only case where the oom_reaper is not triggered for the oom victim
is when it shares the memory with a kernel thread (aka use_mm) or with
the global init. After "mm, oom: skip vforked tasks from being selected"
the victim cannot be a vforked task of the global init so we are left
with clone(CLONE_VM) (without CLONE_SIGHAND). use_mm() users are quite
rare as well.

In order to guarantee a forward progress for the OOM killer make
sure that this really rare cases will not get into the way and hide
the mm from the oom killer by setting MMF_OOM_REAPED flag for it.
oom_scan_process_thread will ignore any TIF_MEMDIE task if it has
MMF_OOM_REAPED flag set to catch these oom victims.

After this patch we should guarantee a forward progress for the OOM
killer even when the selected victim is sharing memory with a kernel
thread or global init.

Changes since v1
- do not exit_oom_victim because oom_scan_process_thread will handle
  those which couldn't terminate in time. exit_oom_victim is not safe
  wrt. oom_disable synchronization.

Acked-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 25 +++++++++++++++++++++----
 1 file changed, 21 insertions(+), 4 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index bfddc93ccd34..4c21f744daa6 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -283,10 +283,22 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 
 	/*
 	 * This task already has access to memory reserves and is being killed.
-	 * Don't allow any other task to have access to the reserves.
+	 * Don't allow any other task to have access to the reserves unless
+	 * the task has MMF_OOM_REAPED because chances that it would release
+	 * any memory is quite low.
 	 */
-	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims))
-		return OOM_SCAN_ABORT;
+	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims)) {
+		struct task_struct *p = find_lock_task_mm(task);
+		enum oom_scan_t ret = OOM_SCAN_ABORT;
+
+		if (p) {
+			if (test_bit(MMF_OOM_REAPED, &p->mm->flags))
+				ret = OOM_SCAN_CONTINUE;
+			task_unlock(p);
+		}
+
+		return ret;
+	}
 
 	/*
 	 * If task is allocating a lot of memory and has been marked to be
@@ -913,9 +925,14 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			/*
 			 * We cannot use oom_reaper for the mm shared by this
 			 * process because it wouldn't get killed and so the
-			 * memory might be still used.
+			 * memory might be still used. Hide the mm from the oom
+			 * killer to guarantee OOM forward progress.
 			 */
 			can_oom_reap = false;
+			set_bit(MMF_OOM_REAPED, &mm->flags);
+			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
+					task_pid_nr(victim), victim->comm,
+					task_pid_nr(p), p->comm);
 			continue;
 		}
 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
