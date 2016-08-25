Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id EBC6583093
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 06:03:45 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l4so30744353wml.0
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 03:03:45 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id yo5si10921806wjb.176.2016.08.25.03.03.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Aug 2016 03:03:39 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id o80so6662675wme.0
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 03:03:39 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH v2 9/9] oom, oom_reaper: allow to reap mm shared by the kthreads
Date: Thu, 25 Aug 2016 12:03:14 +0200
Message-Id: <1472119394-11342-10-git-send-email-mhocko@kernel.org>
In-Reply-To: <1472119394-11342-1-git-send-email-mhocko@kernel.org>
References: <1472119394-11342-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

oom reaper was skipped for an mm which is shared with the kernel thread
(aka use_mm()). The primary concern was that such a kthread might want
to read from the userspace memory and see zero page as a result of the
oom reaper action. This is no longer a problem after "mm: make sure that
kthreads will not refault oom reaped memory" because any attempt to
fault in when the MMF_UNSTABLE is set will result in SIGBUS and so the
target user should see an error. This means that we can finally allow
oom reaper also to tasks which share their mm with kthreads.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5a3ba96c8338..10f686969fc4 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -902,13 +902,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
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
@@ -916,6 +910,12 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
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
