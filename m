Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 406F56B007E
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 18:05:25 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id 124so23511477pfg.0
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 15:05:25 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z25si7629304pfa.170.2016.03.08.15.05.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Mar 2016 15:05:24 -0800 (PST)
Subject: Re: [PATCH] mm: memcontrol: drop unnecessary task_will_free_mem() check.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1457450110-6005-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160308181432.GA9091@cmpxchg.org>
In-Reply-To: <20160308181432.GA9091@cmpxchg.org>
Message-Id: <201603090805.FGE48462.tFJSLMOFHVOOQF@I-love.SAKURA.ne.jp>
Date: Wed, 9 Mar 2016 08:05:11 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: mhocko@kernel.org, vdavydov@virtuozzo.com, linux-mm@kvack.org

Johannes Weiner wrote:
> On Wed, Mar 09, 2016 at 12:15:10AM +0900, Tetsuo Handa wrote:
> > Since mem_cgroup_out_of_memory() is called by
> > mem_cgroup_oom_synchronize(true) via pagefault_out_of_memory() via
> > page fault, and possible allocations between setting PF_EXITING and
> > calling exit_mm() are tty_audit_exit() and taskstats_exit() which will
> > not trigger page fault, task_will_free_mem(current) in
> > mem_cgroup_out_of_memory() is never true.
> > 
> > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> 
> This opens us up to subtle bugs when somebody later changes the order
> and adds new possible allocation sites between the sequence points you
> describe above, or maybe adds other mem_cgroup_out_of_memory() callers.
> 
> It looks like a simplification, but it actually complicates things.
> 

If currently not needed, it should be removed. This is for a clarification.

Also, what is the reason we do not need below change?
I think there is a small race window because oom_killer_disabled needs to be
checked after oom_killer_disable() held oom_lock. Is it because all userspace
processes except current are frozen before oom_killer_disable() is called and
not-yet frozen threads (i.e. kernel threads) never call mem_cgroup_out_of_memory() ?

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ae8b81c..521cd33 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1253,6 +1253,10 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 
 	mutex_lock(&oom_lock);
 
+	/* Check if we raced with oom_killer_disable(). */
+	if (oom_killer_disabled)
+		goto unlock;
+
 	/*
 	 * If current has a pending SIGKILL or is exiting, then automatically
 	 * select it.  The goal is to allow it to allocate so that it may

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
