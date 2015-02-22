Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9545F6B0032
	for <linux-mm@kvack.org>; Sun, 22 Feb 2015 10:22:55 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id nt9so31666484obb.13
        for <linux-mm@kvack.org>; Sun, 22 Feb 2015 07:22:55 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a10si3478668obz.72.2015.02.22.07.22.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 22 Feb 2015 07:22:54 -0800 (PST)
Subject: __GFP_NOFAIL and oom_killer_disabled?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150219225217.GY12722@dastard>
	<201502201936.HBH34799.SOLFFFQtHOMOJV@I-love.SAKURA.ne.jp>
	<20150220231511.GH12722@dastard>
	<20150221032000.GC7922@thunk.org>
	<20150221011907.2d26c979.akpm@linux-foundation.org>
In-Reply-To: <20150221011907.2d26c979.akpm@linux-foundation.org>
Message-Id: <201502222348.GFH13009.LOHOMFVtFQSFOJ@I-love.SAKURA.ne.jp>
Date: Sun, 22 Feb 2015 23:48:01 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: akpm@linux-foundation.org, tytso@mit.edu, david@fromorbit.com, hannes@cmpxchg.org, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org

Andrew Morton wrote:
> And yes, I agree that sites such as xfs's kmem_alloc() should be
> passing __GFP_NOFAIL to tell the page allocator what's going on.  I
> don't think it matters a lot whether kmem_alloc() retains its retry
> loop.  If __GFP_NOFAIL is working correctly then it will never loop
> anyway...

__GFP_NOFAIL fails to work correctly if oom_killer_disabled == true.
I'm wondering how oom_killer_disable() interferes with __GFP_NOFAIL
allocation. We had race check after setting oom_killer_disabled to true
in 3.19.

---------- linux-3.19/kernel/power/process.c ----------
int freeze_processes(void)
{
(...snipped...)
        pm_wakeup_clear();
        printk("Freezing user space processes ... ");
        pm_freezing = true;
        oom_kills_saved = oom_kills_count();
        error = try_to_freeze_tasks(true);
        if (!error) {
                __usermodehelper_set_disable_depth(UMH_DISABLED);
                oom_killer_disable();

                /*
                 * There might have been an OOM kill while we were
                 * freezing tasks and the killed task might be still
                 * on the way out so we have to double check for race.
                 */
                if (oom_kills_count() != oom_kills_saved &&
                    !check_frozen_processes()) {
                        __usermodehelper_set_disable_depth(UMH_ENABLED);
                        printk("OOM in progress.");
                        error = -EBUSY;
                } else {
                        printk("done.");
                }
        }
(...snipped...)
}
---------- linux-3.19/kernel/power/process.c ----------

I worry that commit c32b3cbe0d067a9c "oom, PM: make OOM detection in
the freezer path raceless" might have opened a race window for
__alloc_pages_may_oom(__GFP_NOFAIL) allocation to fail when OOM killer
is disabled. I think something like

--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -789,7 +789,7 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	bool ret = false;
 
 	down_read(&oom_sem);
-	if (!oom_killer_disabled) {
+	if (!oom_killer_disabled || (gfp_mask & __GFP_NOFAIL)) {
 		__out_of_memory(zonelist, gfp_mask, order, nodemask, force_kill);
 		ret = true;
 	}

is needed. But such change can race with up_write() and wait_event() in
oom_killer_disable(). While the comment of oom_killer_disable() says
"The function cannot be called when there are runnable user tasks because
the userspace would see unexpected allocation failures as a result.",
aren't there still kernel threads which might do __GFP_NOFAIL allocations?
After all, don't we need to recheck after setting oom_killer_disabled to true?

---------- linux.git/kernel/power/process.c ----------
int freeze_processes(void)
{
(...snipped...)
        pm_wakeup_clear();
        pr_info("Freezing user space processes ... ");
        pm_freezing = true;
        error = try_to_freeze_tasks(true);
        if (!error) {
                __usermodehelper_set_disable_depth(UMH_DISABLED);
                pr_cont("done.");
        }
        pr_cont("\n");
        BUG_ON(in_atomic());

        /*
         * Now that the whole userspace is frozen we need to disbale
         * the OOM killer to disallow any further interference with
         * killable tasks.
         */
        if (!error && !oom_killer_disable())
                error = -EBUSY;
(...snipped...)
}
---------- linux.git/kernel/power/process.c ----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
