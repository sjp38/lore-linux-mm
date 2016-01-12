Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 242CC828DF
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 16:00:38 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id f206so340854705wmf.0
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 13:00:38 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id 134si30828888wmr.40.2016.01.12.13.00.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 13:00:36 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id f206so33370727wmf.2
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 13:00:36 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC 1/3] oom, sysrq: Skip over oom victims and killed tasks
Date: Tue, 12 Jan 2016 22:00:23 +0100
Message-Id: <1452632425-20191-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1452632425-20191-1-git-send-email-mhocko@kernel.org>
References: <1452632425-20191-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

When the OOM killer is issued by the administrator by sysrq+f it is
expected that a task will be killed to release the memory pressure.
Unlike the regular OOM killer the forced one doesn't abort when
there is an OOM victim selected. Instead oom_scan_process_thread
forces select_bad_process to check this thread. If this happens to be
the largest OOM hog then it will be selected again and the forced
OOM killer wouldn't make any change in case the current OOM victim
is not able terminate and free up resources it is sitting on.

This patch makes sure that the forced oom killer will skip over all
oom victims (with TIF_MEMDIE) and tasks with fatal_signal_pending
on basis that there is no guarantee those tasks are making progress
and there is no way to check they will ever make any. It is more
conservative to simply try another task.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index abefeeb42504..2b9dc5129a89 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -326,6 +326,17 @@ static struct task_struct *select_bad_process(struct oom_control *oc,
 		case OOM_SCAN_OK:
 			break;
 		};
+
+		/*
+		 * If we are doing sysrq+f then it doesn't make any sense to
+		 * check OOM victim or killed task because it might be stuck
+		 * and unable to terminate while the forced OOM might be the
+		 * only option left to get the system back to work.
+		 */
+		if (is_sysrq_oom(oc) && (test_tsk_thread_flag(p, TIF_MEMDIE) ||
+				fatal_signal_pending(p)))
+			continue;
+
 		points = oom_badness(p, NULL, oc->nodemask, totalpages);
 		if (!points || points < chosen_points)
 			continue;
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
