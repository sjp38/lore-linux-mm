Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id CC85E6B025E
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 08:14:49 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id l68so223705878wml.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 05:14:49 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id kh8si9851918wjb.218.2016.03.17.05.14.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Mar 2016 05:14:25 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id l124so8590345wmf.2
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 05:14:25 -0700 (PDT)
Date: Thu, 17 Mar 2016 13:14:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/5] oom, oom_reaper: disable oom_reaper for
 oom_kill_allocating_task
Message-ID: <20160317121422.GD26017@dhcp22.suse.cz>
References: <201602201132.EFG90182.FOVtSOJHFOLFQM@I-love.SAKURA.ne.jp>
 <20160222094105.GD17938@dhcp22.suse.cz>
 <201603152015.JAE86937.VFOLtQFOFJOSHM@I-love.SAKURA.ne.jp>
 <20160315114300.GC6108@dhcp22.suse.cz>
 <20160315115001.GE6108@dhcp22.suse.cz>
 <201603162016.EBJ05275.VHMFSOLJOFQtOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201603162016.EBJ05275.VHMFSOLJOFQtOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Wed 16-03-16 20:16:47, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > And just to prevent from a confusion. I mean waking up also when
> > fatal_signal_pending and we do not really go down to selecting an oom
> > victim. Which would be worth a separate patch on top of course.
> 
> I couldn't understand this part. The shortcut
> 
>         if (current->mm &&
>             (fatal_signal_pending(current) || task_will_free_mem(current))) {
>                 mark_oom_victim(current);
>                 return true;
>         }
> 
> is not used for !__GFP_FS && !__GFP_NOFAIL allocation requests. I think
> we might go down to selecting an oom victim by out_of_memory() calls by
> not-yet-killed processes.

I meant something like the following. It would need some more tweaks
of course but here is the idea at least.

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 23b8b06152be..09e54bc0976c 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -686,6 +686,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	task_lock(p);
 	if (p->mm && task_will_free_mem(p)) {
 		mark_oom_victim(p);
+		wake_oom_reaper(p);
 		task_unlock(p);
 		put_task_struct(p);
 		return;
@@ -869,10 +870,22 @@ bool out_of_memory(struct oom_control *oc)
 	if (current->mm &&
 	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
 		mark_oom_victim(current);
+		wake_oom_reaper(current);
 		return true;
 	}
 
 	/*
+	 * XXX: This is a weak reclaim context when FS metadata couldn't be
+	 * reclaimed and so triggering the OOM killer could be really pre
+	 * mature at this point. Traditionally have been looping in the page
+	 * allocator and hoping for somebody else to make a forward progress
+	 * for us. It would be better to simply fail those requests but we
+	 * are not yet there so keep the tradition
+	 */
+	if (!(gfp_mask & __GFP_FS))
+		return true;
+
+	/*
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA) that may require different handling.
 	 */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d4d574dd0408..01121a89eb52 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2854,20 +2854,11 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 		/* The OOM killer does not needlessly kill tasks for lowmem */
 		if (ac->high_zoneidx < ZONE_NORMAL)
 			goto out;
-		/* The OOM killer does not compensate for IO-less reclaim */
-		if (!(gfp_mask & __GFP_FS)) {
-			/*
-			 * XXX: Page reclaim didn't yield anything,
-			 * and the OOM killer can't be invoked, but
-			 * keep looping as per tradition.
-			 *
-			 * But do not keep looping if oom_killer_disable()
-			 * was already called, for the system is trying to
-			 * enter a quiescent state during suspend.
-			 */
-			*did_some_progress = !oom_killer_disabled;
-			goto out;
-		}
+		/*
+		 * TODO once we are able to cope with GFP_NOFS allocation
+		 * failures more gracefully just return and fail the allocation
+		 * rather than trigger OOM
+		 */
 		if (pm_suspended_storage())
 			goto out;
 		/* The OOM killer may not free memory on a specific node */

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
