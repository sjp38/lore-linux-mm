Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id E191A6B0255
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 08:32:44 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id a4so28205776wme.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 05:32:44 -0800 (PST)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id n5si40717893wma.70.2016.02.17.05.32.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 05:32:43 -0800 (PST)
Received: by mail-wm0-f48.google.com with SMTP id b205so155925092wmb.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 05:32:43 -0800 (PST)
Date: Wed, 17 Feb 2016 14:32:42 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/6] mm,oom: wait for OOM victims when using
 oom_kill_allocating_task == 1
Message-ID: <20160217133242.GJ29196@dhcp22.suse.cz>
References: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
 <201602171936.JDC18598.JHOFtLVOQSFMOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602171936.JDC18598.JHOFtLVOQSFMOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 17-02-16 19:36:36, Tetsuo Handa wrote:
> >From 0b36864d4100ecbdcaa2fc2d1927c9e270f1b629 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Wed, 17 Feb 2016 16:37:59 +0900
> Subject: [PATCH 6/6] mm,oom: wait for OOM victims when using oom_kill_allocating_task == 1
> 
> Currently, out_of_memory() does not wait for existing TIF_MEMDIE threads
> if /proc/sys/vm/oom_kill_allocating_task is set to 1. This can result in
> killing more OOM victims than needed. We can wait for the OOM reaper to
> reap memory used by existing TIF_MEMDIE threads if possible. If the OOM
> reaper is not available, the system will be kept OOM stalled until an
> OOM-unkillable thread does a GFP_FS allocation request and calls
> oom_kill_allocating_task == 0 path.
> 
> This patch changes oom_kill_allocating_task == 1 case to call
> select_bad_process() in order to wait for existing TIF_MEMDIE threads.

The primary motivation for oom_kill_allocating_task was to reduce the
overhead of select_bad_process. See fe071d7e8aae ("oom: add
oom_kill_allocating_task sysctl"). So this basically defeats the whole
purpose of the feature.

I am not user of this knob because it behaves absolutely randomly but
IMHO we should simply do something like the following. It would be more
compliant to the documentation and prevent from livelock which is
currently possible (albeit very unlikely) when a single task consimes
all the memory reserves and we keep looping over out_of_memory without
any progress.

But as I've said I have no idea whether somebody relies on the current
behavior so this is more of a thinking loudly than proposing an actual
patch at this point of time.
---
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 078e07ec0906..7de84fb2dd03 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -706,6 +706,9 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
 		message, task_pid_nr(p), p->comm, points);
 
+	if (sysctl_oom_kill_allocating_task)
+		goto kill;
+
 	/*
 	 * If any of p's children has a different mm and is eligible for kill,
 	 * the one with the highest oom_badness() score is sacrificed for its
@@ -734,6 +737,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	}
 	read_unlock(&tasklist_lock);
 
+kill:
 	p = find_lock_task_mm(victim);
 	if (!p) {
 		put_task_struct(victim);
@@ -888,6 +892,9 @@ bool out_of_memory(struct oom_control *oc)
 	if (sysctl_oom_kill_allocating_task && current->mm &&
 	    !oom_unkillable_task(current, NULL, oc->nodemask) &&
 	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
+		if (test_thread_flag(TIF_MEMDIE))
+			panic("Out of memory (oom_kill_allocating_task) not able to make a forward progress");
+
 		get_task_struct(current);
 		oom_kill_process(oc, current, 0, totalpages, NULL,
 				 "Out of memory (oom_kill_allocating_task)");
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
