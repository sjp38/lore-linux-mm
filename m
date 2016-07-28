Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 855AD828E2
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 15:43:03 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l4so24933479wml.0
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 12:43:03 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id fs5si14658320wjb.260.2016.07.28.12.42.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 12:42:50 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id q128so12643805wma.1
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 12:42:50 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 10/10] oom, oom_reaper: allow to reap mm shared by the kthreads
Date: Thu, 28 Jul 2016 21:42:34 +0200
Message-Id: <1469734954-31247-11-git-send-email-mhocko@kernel.org>
In-Reply-To: <1469734954-31247-1-git-send-email-mhocko@kernel.org>
References: <1469734954-31247-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

oom reaper was skipped for an mm which is shared with the kernel thread
(aka use_mm()). The primary concern was that such a kthread might want
to read from the userspace memory and see zero page as a result of the
oom reaper action. This seems to be overly conservative because none of
the current use_mm() users need to do copy_from_user or get_user. aio
code used to rely on copy_from_user but this is long gone along with
use_mm() usage in fs/aio.c.

We currently have only 3 users in the kernel:
- ffs_user_copy_worker, ep_user_copy_worker only do copy_to_iter()
- vhost_worker needs to copy from userspace but it relies on the
  safe __get_user_mm, copy_from_user_mm resp. copy_from_iter_mm

Add a note to use_mm about the copy_from_user risk and allow the oom
killer to invoke the oom_reaper for mms shared with kthreads. This will
practically cause all the sane use cases to be reapable.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/mmu_context.c |  6 ++++++
 mm/oom_kill.c    | 14 +++++++-------
 2 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/mm/mmu_context.c b/mm/mmu_context.c
index f802c2d216a7..61a7a90250be 100644
--- a/mm/mmu_context.c
+++ b/mm/mmu_context.c
@@ -16,6 +16,12 @@
  *	mm context.
  *	(Note: this routine is intended to be called only
  *	from a kernel thread context)
+ *
+ *	Do not use copy_from_user/__get_user from this context
+ *	and use the safe copy_from_user_mm/__get_user_mm because
+ *	the address space might got reclaimed behind the back by
+ *	the oom_reaper so an unexpected zero page might be
+ *	encountered.
  */
 void use_mm(struct mm_struct *mm)
 {
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 6ccf63fbfc72..ca83b1706e13 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -894,13 +894,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			continue;
 		if (same_thread_group(p, victim))
 			continue;
-		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p)) {
-			/*
-			 * We cannot use oom_reaper for the mm shared by this
-			 * process because it wouldn't get killed and so the
-			 * memory might be still used. Hide the mm from the oom
-			 * killer to guarantee OOM forward progress.
-			 */
+		if (is_global_init(p)) {
 			can_oom_reap = false;
 			set_bit(MMF_OOM_SKIP, &mm->flags);
 			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
@@ -908,6 +902,12 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 					task_pid_nr(p), p->comm);
 			continue;
 		}
+		/*
+		 * No use_mm() user needs to read from the userspace so we are
+		 * ok to reap it.
+		 */
+		if (unlikely(p->flags & PF_KTHREAD))
+			continue;
 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
 	}
 	rcu_read_unlock();
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
