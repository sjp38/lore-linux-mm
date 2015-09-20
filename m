Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 08C1E6B0253
	for <linux-mm@kvack.org>; Sat, 19 Sep 2015 22:56:59 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so84541337pad.1
        for <linux-mm@kvack.org>; Sat, 19 Sep 2015 19:56:58 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id iq2si26552163pbb.50.2015.09.19.19.56.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 19 Sep 2015 19:56:58 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 3/3] mm,oom: Suppress unnecessary "sharing same memory" message.
Date: Sun, 20 Sep 2015 11:04:45 +0900
Message-Id: <1442714685-14002-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1442714685-14002-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1442714685-14002-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>

oom_kill_process() sends SIGKILL to other thread groups sharing
victim's mm. But printing

  "Kill process %d (%s) sharing same memory\n"

lines makes no sense if they already have pending SIGKILL.
This patch reduces the "Kill process" lines by printing
that line with info level only if SIGKILL is not pending.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 408aa8e..81962d7 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -579,9 +579,11 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 		    !(p->flags & PF_KTHREAD)) {
 			if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
 				continue;
+			if (fatal_signal_pending(p))
+				continue;
 
 			task_lock(p);	/* Protect ->comm from prctl() */
-			pr_err("Kill process %d (%s) sharing same memory\n",
+			pr_info("Kill process %d (%s) sharing same memory\n",
 				task_pid_nr(p), p->comm);
 			task_unlock(p);
 			do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
