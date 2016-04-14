Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2D5516B0005
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 08:01:14 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id d19so44674930lfb.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 05:01:14 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id km9si10648497wjb.149.2016.04.14.05.01.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 05:01:09 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id l6so22197956wml.3
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 05:01:09 -0700 (PDT)
Date: Thu, 14 Apr 2016 14:01:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom_reaper: Use try_oom_reaper() for reapability test.
Message-ID: <20160414120106.GF2850@dhcp22.suse.cz>
References: <1460631391-8628-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160414112146.GD2850@dhcp22.suse.cz>
 <201604142034.BIF60426.FLFMVOHOJQStOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201604142034.BIF60426.FLFMVOHOJQStOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, linux-mm@kvack.org

On Thu 14-04-16 20:34:18, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > The patch seems correct I just do not see any point in it because I do
> > not think it handles any real life situation. I basically consider any
> > workload where only _certain_ thread(s) or process(es) sharing the mm have
> > OOM_SCORE_ADJ_MIN set as invalid. Why should we care about those? This
> > requires root to cripple the system. Or am I missing a valid
> > configuration where this would make any sense?
> 
> Because __oom_reap_task() as of current linux.git marks only one of
> thread groups as OOM_SCORE_ADJ_MIN and happily disables further reaping
> (which I'm utilizing such behavior for catching bugs which occur under
> almost OOM situation).

I am not really sure I understand what you mean here. Let me try. You
have N tasks sharing the same mm. OOM killer selects one of them and
kills it, grants TIF_MEMDIE and schedules it for oom_reaper. Now the oom
reaper handles that task and marks it OOM_SCORE_ADJ_MIN. Others will
have fatal_signal_pending without OOM_SCORE_ADJ_MIN. The shared mm was
already reaped so there is not much left we can do about it. What now?

A different question is whether it makes any sense to pick a task with
oom reaped mm as a new victim. This would happen if either the memory
is not reapable much or the mm was quite small. I agree that we do not
handle this case now same as we haven't before. An mm specific flag
would handle that I believe. Something like the following. Is this what
you are worried about or am I still missing your point?
---
diff --git a/include/linux/sched.h b/include/linux/sched.h
index acfc32b30704..7bd0fa9db199 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -512,6 +512,7 @@ static inline int get_dumpable(struct mm_struct *mm)
 
 #define MMF_HAS_UPROBES		19	/* has uprobes */
 #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
+#define MMF_OOM_REAPED		21	/* mm has been already reaped */
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 716759e3eaab..d5a4d08f2031 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -286,6 +286,13 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 		return OOM_SCAN_CONTINUE;
 
 	/*
+	 * mm of this task has already been reaped so it doesn't make any
+	 * sense to select it as a new oom victim.
+	 */
+	if (test_bit(MMF_OOM_REAPED, &task->mm->flags))
+		return OOM_SCAN_CONTINUE;
+
+	/*
 	 * If task is allocating a lot of memory and has been marked to be
 	 * killed first if it triggers an oom, then select it.
 	 */
@@ -513,7 +520,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 * This task can be safely ignored because we cannot do much more
 	 * to release its memory.
 	 */
-	tsk->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
+	test_bit(MMF_OOM_REAPED, &mm->flags);
 out:
 	mmput(mm);
 	return ret;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
