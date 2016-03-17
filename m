Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9FE576B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 10:34:22 -0400 (EDT)
Received: by mail-pf0-f181.google.com with SMTP id n5so123443290pfn.2
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 07:34:22 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id wu1si12855410pab.71.2016.03.17.07.34.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Mar 2016 07:34:21 -0700 (PDT)
Subject: Re: [PATCH 6/5] oom, oom_reaper: disable oom_reaper for oom_kill_allocating_task
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201603162016.EBJ05275.VHMFSOLJOFQtOF@I-love.SAKURA.ne.jp>
	<201603171949.FHE57319.SMFFtJOHOVOFLQ@I-love.SAKURA.ne.jp>
	<20160317121751.GE26017@dhcp22.suse.cz>
	<201603172200.CIE52148.QOVSOHJFMLOFtF@I-love.SAKURA.ne.jp>
	<20160317132335.GF26017@dhcp22.suse.cz>
In-Reply-To: <20160317132335.GF26017@dhcp22.suse.cz>
Message-Id: <201603172334.EGD54504.OLFQVJFOtMHFOS@I-love.SAKURA.ne.jp>
Date: Thu, 17 Mar 2016 23:34:13 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org

Michal Hocko wrote:
> On Thu 17-03-16 22:00:34, Tetsuo Handa wrote:
> [...]
> > If you worry about too much work for a single RCU, you can do like
> > what kmallocwd does. kmallocwd adds a marker to task_struct so that
> > kmallocwd can reliably resume reporting.
> 
> It is you who is trying to add a different debugging output so you
> should better make sure you won't swamp the user by something that might
> be not helpful after all by _default_. I would care much less if this
> was hidden by the debugging option like the current
> debug_show_all_locks.

Then, we can do something like this.

----------
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index affbb79..76b5c67 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -502,26 +502,20 @@ static void oom_reap_vmas(struct mm_struct *mm)
 		schedule_timeout_idle(HZ/10);
 
 	if (attempts > MAX_OOM_REAP_RETRIES) {
+#ifdef CONFIG_PROVE_LOCKING
 		struct task_struct *p;
 		struct task_struct *t;
+#endif
 
 		pr_info("oom_reaper: unable to reap memory\n");
-		rcu_read_lock();
+#ifdef CONFIG_PROVE_LOCKING
+		read_lock(&tasklist_lock);
 		for_each_process_thread(p, t) {
-			if (likely(t->mm != mm))
-				continue;
-			pr_info("oom_reaper: %s(%u) flags=0x%x%s%s%s%s\n",
-				t->comm, t->pid, t->flags,
-				(t->state & TASK_UNINTERRUPTIBLE) ?
-				" uninterruptible" : "",
-				(t->flags & PF_EXITING) ? " exiting" : "",
-				fatal_signal_pending(t) ? " dying" : "",
-				test_tsk_thread_flag(t, TIF_MEMDIE) ?
-				" victim" : "");
-			sched_show_task(t);
-			debug_show_held_locks(t);
+			if (t->mm == mm && t->state != TASK_RUNNING)
+				debug_show_held_locks(t);
 		}
-		rcu_read_unlock();
+		read_unlock(&tasklist_lock);
+#endif
 	}
 
 	/* Drop a reference taken by wake_oom_reaper */
----------

Strictly speaking, neither debug_show_all_locks() nor debug_show_held_locks()
are safe enough to guarantee that the system won't crash.

  commit 856848737bd944c1 "lockdep: fix debug_show_all_locks()"
  commit 82a1fcb90287052a "softlockup: automatically detect hung TASK_UNINTERRUPTIBLE tasks"

They are convenient but we should avoid using them if we care about
possibility of crash.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
