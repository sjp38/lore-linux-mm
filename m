Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1E3846B0038
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 08:02:25 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so23311918pdj.3
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 05:02:24 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id x15si3618820pdj.61.2015.06.01.05.02.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 01 Jun 2015 05:02:23 -0700 (PDT)
Subject: Re: [PATCH] mm/oom: Suppress unnecessary "sharing same memory" message.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201505292140.JHE18273.SFFMJFHOtQLOVO@I-love.SAKURA.ne.jp>
	<20150529144922.GE22728@dhcp22.suse.cz>
	<201505300220.GCH51071.FVOOFOLQStJMFH@I-love.SAKURA.ne.jp>
	<201505312010.JJJ26561.FJOOVSQHLFOtMF@I-love.SAKURA.ne.jp>
	<20150601101646.GC7147@dhcp22.suse.cz>
In-Reply-To: <20150601101646.GC7147@dhcp22.suse.cz>
Message-Id: <201506012102.CBE60453.FOQtFJLFSHOOVM@I-love.SAKURA.ne.jp>
Date: Mon, 1 Jun 2015 21:02:20 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org

Michal Hocko wrote:
> On Sun 31-05-15 20:10:23, Tetsuo Handa wrote:
> [...]
> > By the way, I got two mumbles.
> > 
> > Is "If any of p's children has a different mm and is eligible for kill," logic
> > in oom_kill_process() really needed? Didn't select_bad_process() which was
> > called proior to calling oom_kill_process() already choose a best victim
> > using for_each_process_thread() ?
> 
> This tries to have smaller effect on the system. It tries to kill
> younger tasks because this might be and quite often is sufficient to
> resolve the OOM condition.
> 
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
> 
> -- 
> Michal Hocko
> SUSE Labs
> 
I see. Here is a patch.
mmput() may sleep. But oom_kill_process() is a sleep-able context, right?
----------------------------------------
>From 15afd1f40b132719c323e81d58064ff7115206f9 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Mon, 1 Jun 2015 20:54:14 +0900
Subject: [PATCH] mm,oom: Fix potentially killing unrelated process or
 depleting memory.

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

Likewise, move do_send_sig_info(SIGKILL, victim) to before
mark_oom_victim(victim) in case for_each_process() took very long time,
for the OOM victim can abuse ALLOC_NO_WATERMARKS by TIF_MEMDIE via e.g.
memset() in user space until SIGKILL is delivered.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index dff991e..5eb1e65 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -559,14 +559,17 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		victim = p;
 	}
 
-	/* mm cannot safely be dereferenced after task_unlock(victim) */
+	/* Get a reference to safely compare mm after task_unlock(victim) */
 	mm = victim->mm;
-	mark_oom_victim(victim);
+	atomic_inc(&mm->mm_users);
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
-		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
-		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
-		K(get_mm_counter(victim->mm, MM_FILEPAGES)));
+		task_pid_nr(victim), victim->comm, K(mm->total_vm),
+		K(get_mm_counter(mm, MM_ANONPAGES)),
+		K(get_mm_counter(mm, MM_FILEPAGES)));
 	task_unlock(victim);
+	/* Send SIGKILL before setting TIF_MEMDIE. */
+	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
+	mark_oom_victim(victim);
 
 	/*
 	 * Kill all user processes sharing victim->mm in other thread groups, if
@@ -592,7 +595,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		}
 	rcu_read_unlock();
 
-	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
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
