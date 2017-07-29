Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 536A26B0583
	for <linux-mm@kvack.org>; Sat, 29 Jul 2017 00:31:59 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id k72so154347156pfj.1
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 21:31:59 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id l81si13255917pfj.515.2017.07.28.21.31.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Jul 2017 21:31:57 -0700 (PDT)
Subject: Re: Possible race condition in oom-killer
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170728130723.GP2274@dhcp22.suse.cz>
	<201707282215.AGI69210.VFOHQFtOFSOJML@I-love.SAKURA.ne.jp>
	<20170728132952.GQ2274@dhcp22.suse.cz>
	<201707282255.BGI87015.FSFOVQtMOHLJFO@I-love.SAKURA.ne.jp>
	<20170728140706.GT2274@dhcp22.suse.cz>
In-Reply-To: <20170728140706.GT2274@dhcp22.suse.cz>
Message-Id: <201707291331.JGI18780.OtJVLFMHFOFSOQ@I-love.SAKURA.ne.jp>
Date: Sat, 29 Jul 2017 13:31:44 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: mjaggi@caviumnetworks.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Michal Hocko wrote:
> On Fri 28-07-17 22:55:51, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Fri 28-07-17 22:15:01, Tetsuo Handa wrote:
> > > > task_will_free_mem(current) in out_of_memory() returning false due to
> > > > MMF_OOM_SKIP already set allowed each thread sharing that mm to select a new
> > > > OOM victim. If task_will_free_mem(current) in out_of_memory() did not return
> > > > false, threads sharing MMF_OOM_SKIP mm would not have selected new victims
> > > > to the level where all OOM killable processes are killed and calls panic().
> > > 
> > > I am not sure I understand. Do you mean this?
> > 
> > Yes.
> > 
> > > ---
> > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > index 9e8b4f030c1c..671e4a4107d0 100644
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -779,13 +779,6 @@ static bool task_will_free_mem(struct task_struct *task)
> > >  	if (!__task_will_free_mem(task))
> > >  		return false;
> > >  
> > > -	/*
> > > -	 * This task has already been drained by the oom reaper so there are
> > > -	 * only small chances it will free some more
> > > -	 */
> > > -	if (test_bit(MMF_OOM_SKIP, &mm->flags))
> > > -		return false;
> > > -
> > >  	if (atomic_read(&mm->mm_users) <= 1)
> > >  		return true;
> > >  
> > > If yes I would have to think about this some more because that might
> > > have weird side effects (e.g. oom_victims counting after threads passed
> > > exit_oom_victim).
> > 
> > But this check should not be removed unconditionally. We should still return
> > false if returning true was not sufficient to solve the OOM situation, for
> > we need to select next OOM victim in that case.
> > 

I think that below one can manage this race condition.

---
 include/linux/sched.h |  1 +
 mm/oom_kill.c         | 21 ++++++++++++++-------
 2 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 0db4870..3fccf72 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -652,6 +652,7 @@ struct task_struct {
 	/* disallow userland-initiated cgroup migration */
 	unsigned			no_cgroup_migration:1;
 #endif
+	unsigned			oom_kill_free_check_raced:1;
 
 	unsigned long			atomic_flags; /* Flags requiring atomic access. */
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 9e8b4f0..a093193 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -779,13 +779,6 @@ static bool task_will_free_mem(struct task_struct *task)
 	if (!__task_will_free_mem(task))
 		return false;
 
-	/*
-	 * This task has already been drained by the oom reaper so there are
-	 * only small chances it will free some more
-	 */
-	if (test_bit(MMF_OOM_SKIP, &mm->flags))
-		return false;
-
 	if (atomic_read(&mm->mm_users) <= 1)
 		return true;
 
@@ -806,6 +799,20 @@ static bool task_will_free_mem(struct task_struct *task)
 	}
 	rcu_read_unlock();
 
+	/*
+	 * It is possible that current thread fails to try allocation from
+	 * memory reserves if the OOM reaper set MMF_OOM_SKIP on this mm before
+	 * current thread calls out_of_memory() in order to get TIF_MEMDIE.
+	 * In that case, allow current thread to try TIF_MEMDIE allocation
+	 * before start selecting next OOM victims.
+	 */
+	if (ret && test_bit(MMF_OOM_SKIP, &mm->flags)) {
+		if (task == current && !task->oom_kill_free_check_raced)
+			task->oom_kill_free_check_raced = true;
+		else
+			ret = false;
+	}
+
 	return ret;
 }
 
-- 
1.8.3.1

What is "oom_victims counting after threads passed exit_oom_victim" ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
