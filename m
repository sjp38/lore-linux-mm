Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id A80E26B0038
	for <linux-mm@kvack.org>; Sun, 23 Aug 2015 03:18:19 -0400 (EDT)
Received: by pacti10 with SMTP id ti10so82877pac.0
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 00:18:19 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f11si21431947pdm.246.2015.08.23.00.18.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 23 Aug 2015 00:18:18 -0700 (PDT)
Subject: [REPOST] [PATCH 1/2] mm,oom: Fix potentially killing unrelated process.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201508231618.CEC87056.VLStMFFHOJQFOO@I-love.SAKURA.ne.jp>
Date: Sun, 23 Aug 2015 16:18:00 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, rientjes@google.com, hannes@cmpxchg.org
Cc: linux-mm@kvack.org

Quoting from http://www.spinics.net/lists/linux-mm/msg89346.html
> > Is "/* mm cannot safely be dereferenced after task_unlock(victim) */" true?
> > It seems to me that it should be "/* mm cannot safely be compared after
> > task_unlock(victim) */" because it is theoretically possible to have
> > 
> >   CPU 0                         CPU 1                   CPU 2
> >   task_unlock(victim);
> >                                 victim exits and releases mm.
> >                                 Usage count of the mm becomes 0 and thus released.
> >                                                         New mm is allocated and assigned to some thread.
> >   (p->mm == mm) matches the recreated mm and kill unrelated p.
> > 
> > sequence. We need to either get a reference to victim's mm before
> > task_unlock(victim) or do comparison before task_unlock(victim).
> 
> Hmm, I guess you are right. The race is theoretically possible,
> especially when there are many tasks when iterating over the list might
> take some time. reference to the mm would solve this. Care to send a
> patch?

Today I had a time to write this patch.

----------------------------------------

>From 2c5c4da4c9c5a124820f53f138c456e07c9248bb Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 31 Jul 2015 13:37:31 +0900
Subject: [PATCH 1/2] mm,oom: Fix potentially killing unrelated process.

At the for_each_process() loop in oom_kill_process(), we are comparing
address of OOM victim's mm without holding a reference to that mm.
If there are a lot of processes to compare or a lot of "Kill process
%d (%s) sharing same memory" messages to print, for_each_process() loop
could take very long time.

It is possible that meanwhile the OOM victim exits and releases its mm,
and then mm is allocated with the same address and assigned to some
unrelated process. When we hit such race, the unrelated process will be
killed by error. To make sure that the OOM victim's mm does not go away
until for_each_process() loop finishes, get a reference on the OOM
victim's mm before calling task_unlock(victim).

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1ecc0bc..5249e7e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -552,8 +552,9 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 		victim = p;
 	}
 
-	/* mm cannot safely be dereferenced after task_unlock(victim) */
+	/* Get a reference to safely compare mm after task_unlock(victim) */
 	mm = victim->mm;
+	atomic_inc(&mm->mm_users);
 	mark_oom_victim(victim);
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
 		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
@@ -586,6 +587,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	rcu_read_unlock();
 
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
+	mmput(mm);
 	put_task_struct(victim);
 }
 #undef K
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
