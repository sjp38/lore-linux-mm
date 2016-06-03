Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 142D66B0267
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 05:17:14 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e3so38460054wme.3
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 02:17:14 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id v9si6396227wjw.43.2016.06.03.02.16.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 02:16:57 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id a20so10498300wma.3
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 02:16:57 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 10/10] mm, oom: hide mm which is shared with kthread or global init
Date: Fri,  3 Jun 2016 11:16:44 +0200
Message-Id: <1464945404-30157-11-git-send-email-mhocko@kernel.org>
In-Reply-To: <1464945404-30157-1-git-send-email-mhocko@kernel.org>
References: <1464945404-30157-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

The only case where the oom_reaper is not triggered for the oom victim
is when it shares the memory with a kernel thread (aka use_mm) or with
the global init. After "mm, oom: skip vforked tasks from being selected"
the victim cannot be a vforked task of the global init so we are left
with clone(CLONE_VM) (without CLONE_THREAD or CLONE_SIGHAND). use_mm users
are quite rare as well. In order to guarantee a forward progress for the
OOM killer make sure that this really rare cases will not get into the
way and hide the mm from the oom killer by setting MMF_OOM_REAPED flag
for it.

We cannot keep the TIF_MEMDIE for the victim so let's simply wait for a
while and then drop the flag for all victims except for the current task
which is guaranteed to be in the allocation path already and should be
able to use the memory reserve right away.

If the victim cannot terminate by then simply risk another oom victim
selection. Note that oom_scan_process_thread has to learn about this as
well and ignore the TIF_MEMDIE on the current task because memory reserve
might be already depleted and go on to other potential victims is the
only way forward. We could eventually panic if none of that helped and
there is no further victim left.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 33 ++++++++++++++++++++++++++++-----
 1 file changed, 28 insertions(+), 5 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 9a5cc12a479a..3a3b136ee9db 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -283,10 +283,19 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 
 	/*
 	 * This task already has access to memory reserves and is being killed.
-	 * Don't allow any other task to have access to the reserves.
+	 * Don't allow any other task to have access to the reserves unless
+	 * this is a current task which is clearly in the allocation path and
+	 * the access to memory reserves didn't help so we should rather try
+	 * to kill somebody else or panic on no oom victim than loop with no way
+	 * forward. Go with OOM_SCAN_OK rather than OOM_SCAN_CONTINUE to double
+	 * check MMF_OOM_REAPED in oom_badness() to make sure we've done
+	 * everything to reclaim memory.
 	 */
-	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims))
-		return OOM_SCAN_ABORT;
+	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims)) {
+		if (task != current)
+			return OOM_SCAN_ABORT;
+		return OOM_SCAN_OK;
+	}
 
 	/*
 	 * If task is allocating a lot of memory and has been marked to be
@@ -908,9 +917,14 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
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
 		if (p->signal->oom_score_adj == OOM_ADJUST_MIN)
@@ -922,8 +936,17 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	}
 	rcu_read_unlock();
 
-	if (can_oom_reap)
+	if (can_oom_reap) {
 		wake_oom_reaper(victim);
+	} else if (victim != current) {
+		/*
+		 * If we want to guarantee a forward progress we cannot keep
+		 * the oom victim TIF_MEMDIE here. Sleep for a while and then
+		 * drop the flag to make sure another victim can be selected.
+		 */
+		schedule_timeout_killable(HZ);
+		exit_oom_victim(victim);
+	}
 
 	mmdrop(mm);
 	put_task_struct(victim);
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
