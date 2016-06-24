Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 850396B0005
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 08:39:57 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id l184so74738806lfl.3
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 05:39:57 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id m22si4049929wma.83.2016.06.24.05.39.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jun 2016 05:39:56 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id 187so4676559wmz.1
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 05:39:55 -0700 (PDT)
Date: Fri, 24 Jun 2016 14:39:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear
 TIF_MEMDIE
Message-ID: <20160624123953.GC20203@dhcp22.suse.cz>
References: <1466766121-8164-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466766121-8164-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, David Rientjes <rientjes@google.com>

On Fri 24-06-16 20:02:01, Tetsuo Handa wrote:
> Currently, the OOM reaper calls exit_oom_victim() on remote TIF_MEMDIE
> thread after an OOM reap attempt was made. This behavior is intended
> for allowing oom_scan_process_thread() to select next OOM victim by
> making atomic_read(&task->signal->oom_victims) == 0.
> 
> But since threads can be blocked for unbounded period at __mmput() from
> mmput() from exit_mm() from do_exit(), we can't risk the OOM reaper
> being blocked for unbounded period waiting for TIF_MEMDIE threads.
> Therefore, when we hit a situation that a TIF_MEMDIE thread which is
> the only thread of that thread group reached tsk->mm = NULL line in
> exit_mm() from do_exit() before __oom_reap_task() finds a mm via
> find_lock_task_mm(), oom_reap_task() does not wait for the TIF_MEMDIE
> thread to return from __mmput() and instead calls exit_oom_victim().
> 
> Patch "mm, oom: hide mm which is shared with kthread or global init"
> tried to avoid OOM livelock by setting MMF_OOM_REAPED, but it is racy
> because setting MMF_OOM_REAPED will not help when find_lock_task_mm()
> in oom_scan_process_thread() failed.

I haven't thought that through yet (I will wait for the monday fresh
brain) but wouldn't the following be sufficient?
---
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4c21f744daa6..72360d7284a6 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -295,7 +295,8 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 			if (test_bit(MMF_OOM_REAPED, &p->mm->flags))
 				ret = OOM_SCAN_CONTINUE;
 			task_unlock(p);
-		}
+		} else if (task->state == EXIT_ZOMBIE)
+			ret = OOM_SCAN_CONTINUE;
 
 		return ret;
 	}
@@ -592,14 +593,7 @@ static void oom_reap_task(struct task_struct *tsk)
 		debug_show_all_locks();
 	}
 
-	/*
-	 * Clear TIF_MEMDIE because the task shouldn't be sitting on a
-	 * reasonably reclaimable memory anymore or it is not a good candidate
-	 * for the oom victim right now because it cannot release its memory
-	 * itself nor by the oom reaper.
-	 */
 	tsk->oom_reaper_list = NULL;
-	exit_oom_victim(tsk);
 
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
