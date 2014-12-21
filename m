Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 5A82A6B0032
	for <linux-mm@kvack.org>; Sun, 21 Dec 2014 03:45:39 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fb1so4019707pad.13
        for <linux-mm@kvack.org>; Sun, 21 Dec 2014 00:45:38 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id l9si20988963pdn.39.2014.12.21.00.45.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 21 Dec 2014 00:45:37 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20141218153341.GB832@dhcp22.suse.cz>
	<201412192122.DJI13055.OOVSQLOtFHFFMJ@I-love.SAKURA.ne.jp>
	<20141220020331.GM1942@devil.localdomain>
	<201412202141.ADF87596.tOSLJHFFOOFMVQ@I-love.SAKURA.ne.jp>
	<20141220223504.GI15665@dastard>
In-Reply-To: <20141220223504.GI15665@dastard>
Message-Id: <201412211745.ECD69212.LQOFHtFOJMSOFV@I-love.SAKURA.ne.jp>
Date: Sun, 21 Dec 2014 17:45:32 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com
Cc: dchinner@redhat.com, mhocko@suse.cz, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

Thank you for detailed explanation.

Dave Chinner wrote:
> So, going back to the lockup, doesn't hte fact that so many
> processes are spinning in the shrinker tell you that there's a
> problem in that area? i.e. this:
> 
> [  398.861602]  [<ffffffff8159f814>] _cond_resched+0x24/0x40
> [  398.863195]  [<ffffffff81122119>] shrink_slab+0x139/0x150
> [  398.864799]  [<ffffffff811252bf>] do_try_to_free_pages+0x35f/0x4d0
> 
> tells me a shrinker is not making progress for some reason.  I'd
> suggest that you run some tracing to find out what shrinker it is
> stuck in. there are tracepoints in shrink_slab that will tell you
> what shrinker is iterating for long periods of time. i.e instead of
> ranting and pointing fingers at everyone, you need to keep digging
> until you know exactly where reclaim progress is stalling.

I checked using below patch that shrink_slab() is called for many times but
each call took 0 jiffies and freed 0 objects. I think shrink_slab() is merely
reported since it likely works as a location for yielding CPU resource.

----------
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 5e344bb..ac8b46a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1661,6 +1661,14 @@ struct task_struct {
 	unsigned int	sequential_io;
 	unsigned int	sequential_io_avg;
 #endif
+	/* Jiffies spent since the start of outermost memory allocation */
+	unsigned long gfp_start;
+	/* GFP flags passed to innermost memory allocation */
+	gfp_t gfp_flags;
+	/* # of shrink_slab() calls since outermost memory allocation. */
+	unsigned int shrink_slab_counter;
+	/* # of OOM-killer skipped. */
+	atomic_t oom_killer_skip_counter;
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 89e7283..26dcdf8 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -4522,6 +4522,22 @@ out_unlock:
 	return retval;
 }
 
+static void print_memalloc_info(const struct task_struct *p)
+{
+	const gfp_t gfp = p->gfp_flags & __GFP_WAIT;
+
+	/*
+	 * __alloc_pages_nodemask() doesn't use smp_wmb() between
+	 * updating ->gfp_start and ->gfp_flags. But reading stale
+	 * ->gfp_start value harms nothing but printing bogus duration.
+	 * Correct duration will be printed when this function is
+	 * called for the next time.
+	 */
+	if (unlikely(gfp))
+		printk(KERN_INFO "MemAlloc: %ld jiffies on 0x%x\n",
+		       jiffies - p->gfp_start, gfp);
+}
+
 static const char stat_nam[] = TASK_STATE_TO_CHAR_STR;
 
 void sched_show_task(struct task_struct *p)
@@ -4554,6 +4570,7 @@ void sched_show_task(struct task_struct *p)
 		task_pid_nr(p), ppid,
 		(unsigned long)task_thread_info(p)->flags);
 
+	print_memalloc_info(p);
 	print_worker_info(KERN_INFO, p);
 	show_stack(p, NULL);
 }
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5340f6b..5b014d0 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -319,6 +319,10 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 		case OOM_SCAN_CONTINUE:
 			continue;
 		case OOM_SCAN_ABORT:
+			if (atomic_inc_return(&p->oom_killer_skip_counter) % 1000 == 0)
+				printk(KERN_INFO "%s(%d) the OOM killer was skipped "
+				       "for %u times.\n", p->comm, p->pid,
+				       atomic_read(&p->oom_killer_skip_counter));
 			rcu_read_unlock();
 			return (struct task_struct *)(-1UL);
 		case OOM_SCAN_OK:
@@ -444,6 +448,10 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
 	 */
 	if (p->flags & PF_EXITING) {
+		if (atomic_inc_return(&p->oom_killer_skip_counter) % 1000 == 0)
+			printk(KERN_INFO "%s(%d) the OOM killer was skipped "
+			       "for %u times.\n", p->comm, p->pid,
+			       atomic_read(&p->oom_killer_skip_counter));
 		set_tsk_thread_flag(p, TIF_MEMDIE);
 		put_task_struct(p);
 		return;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 616a2c9..d1c872f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2790,6 +2790,13 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	unsigned int cpuset_mems_cookie;
 	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
 	int classzone_idx;
+	const gfp_t old_gfp_flags = current->gfp_flags;
+
+	if (!old_gfp_flags) {
+		current->gfp_start = jiffies;
+		current->shrink_slab_counter = 0;
+	}
+	current->gfp_flags = gfp_mask;
 
 	gfp_mask &= gfp_allowed_mask;
 
@@ -2798,7 +2805,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	might_sleep_if(gfp_mask & __GFP_WAIT);
 
 	if (should_fail_alloc_page(gfp_mask, order))
-		return NULL;
+		goto nopage;
 
 	/*
 	 * Check the zones suitable for the gfp_mask contain at least one
@@ -2806,7 +2813,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	 * of GFP_THISNODE and a memoryless node
 	 */
 	if (unlikely(!zonelist->_zonerefs->zone))
-		return NULL;
+		goto nopage;
 
 	if (IS_ENABLED(CONFIG_CMA) && migratetype == MIGRATE_MOVABLE)
 		alloc_flags |= ALLOC_CMA;
@@ -2850,6 +2857,9 @@ out:
 	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
 		goto retry_cpuset;
 
+nopage:
+	current->gfp_flags = old_gfp_flags;
+
 	return page;
 }
 EXPORT_SYMBOL(__alloc_pages_nodemask);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index dcb4707..5690f2d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -365,6 +365,7 @@ unsigned long shrink_slab(struct shrink_control *shrinkctl,
 {
 	struct shrinker *shrinker;
 	unsigned long freed = 0;
+	const unsigned long start = jiffies;
 
 	if (nr_pages_scanned == 0)
 		nr_pages_scanned = SWAP_CLUSTER_MAX;
@@ -397,6 +398,15 @@ unsigned long shrink_slab(struct shrink_control *shrinkctl,
 	}
 	up_read(&shrinker_rwsem);
 out:
+	{
+		struct task_struct *p = current;
+		if (++p->shrink_slab_counter % 100000 == 0)
+			printk(KERN_INFO "%s(%d) shrink_slab() was called for "
+			       "%u times. This time freed %lu object and took "
+			       "%lu jiffies. Spent %lu jiffies till now.\n",
+			       p->comm, p->pid, p->shrink_slab_counter, freed,
+			       jiffies - start, jiffies - p->gfp_start);
+	}
 	cond_resched();
 	return freed;
 }
----------

Traces from uptime > 484 seconds of
http://I-love.SAKURA.ne.jp/tmp/serial-20141221.txt.xz is a stalled case.
PID=12718 got SIGKILL for the first time when PID=12716 got SIGKILL with
TIF_MEMDIE at 484 sec. When PID=12717 got TIF_MEMDIE at 540 sec, the OOM
killer was skipped for 28000 times till 547 sec, but PID=12717 was able
to terminate because somebody has released enough memory for PID=12717 to
call exit_mm(). When PID=12718 got TIF_MEMDIE at 548 sec, the OOM killer was
skipped for 2059000 times till 983 sec, indicating that PID=12718 was not
able to terminate because nobody has released enough memory for PID=12718
to call exit_mm(). Is this interpretation correct?

> That's not an XFS problem - XFS relies on the memory reclaim
> subsystem being able to make progress. If the memory reclaim
> subsystem cannot make progress, then there's a bug in the memory
> reclaim subsystem, not a problem with the OOM killer.

Since trying to trigger the OOM killer means that memory reclaim subsystem
has gave up, the memory reclaim subsystem had been unable to find
reclaimable memory after PID=12718 got TIF_MEMDIE at 548 sec.
Is this interpretation correct?

And traces of PID=12718 after 548 sec remained unchanged.
Does this mean that there is a bug in the memory reclaim subsystem?

----------
[  799.490009] a.out           D ffff8800764918a0     0 12718      1 0x00100084
[  799.491903]  ffff880077d7fca8 0000000000000086 ffff880076491470 ffff880077d7ffd8
[  799.493924]  0000000000013640 0000000000013640 ffff8800358c8210 ffff880076491470
[  799.495938]  0000000000000000 ffff88007c8a3e48 ffff88007c8a3e4c ffff880076491470
[  799.497964] Call Trace:
[  799.498971]  [<ffffffff81618669>] schedule_preempt_disabled+0x29/0x70
[  799.500746]  [<ffffffff8161a555>] __mutex_lock_slowpath+0xb5/0x120
[  799.502402]  [<ffffffff8161a5e3>] mutex_lock+0x23/0x37
[  799.503944]  [<ffffffffa025fb47>] xfs_file_buffered_aio_write.isra.9+0x77/0x270 [xfs]
[  799.505939]  [<ffffffff8109e274>] ? finish_task_switch+0x54/0x150
[  799.507638]  [<ffffffffa025fdc3>] xfs_file_write_iter+0x83/0x130 [xfs]
[  799.509416]  [<ffffffff811ce76e>] new_sync_write+0x8e/0xd0
[  799.510990]  [<ffffffff811cf0f7>] vfs_write+0xb7/0x1f0
[  799.512484]  [<ffffffff81022d9c>] ? do_audit_syscall_entry+0x6c/0x70
[  799.514226]  [<ffffffff811cfbe5>] SyS_write+0x55/0xd0
[  799.515752]  [<ffffffff8161c9e9>] system_call_fastpath+0x12/0x17
(...snipped...)
[  954.595576] a.out           D ffff8800764918a0     0 12718      1 0x00100084
[  954.597544]  ffff880077d7fca8 0000000000000086 ffff880076491470 ffff880077d7ffd8
[  954.599565]  0000000000013640 0000000000013640 ffff8800358c8210 ffff880076491470
[  954.601634]  0000000000000000 ffff88007c8a3e48 ffff88007c8a3e4c ffff880076491470
[  954.604091] Call Trace:
[  954.607766]  [<ffffffff81618669>] schedule_preempt_disabled+0x29/0x70
[  954.609792]  [<ffffffff8161a555>] __mutex_lock_slowpath+0xb5/0x120
[  954.611644]  [<ffffffff8161a5e3>] mutex_lock+0x23/0x37
[  954.613256]  [<ffffffffa025fb47>] xfs_file_buffered_aio_write.isra.9+0x77/0x270 [xfs]
[  954.615261]  [<ffffffff8109e274>] ? finish_task_switch+0x54/0x150
[  954.616990]  [<ffffffffa025fdc3>] xfs_file_write_iter+0x83/0x130 [xfs]
[  954.619180]  [<ffffffff811ce76e>] new_sync_write+0x8e/0xd0
[  954.620798]  [<ffffffff811cf0f7>] vfs_write+0xb7/0x1f0
[  954.622345]  [<ffffffff81022d9c>] ? do_audit_syscall_entry+0x6c/0x70
[  954.624073]  [<ffffffff811cfbe5>] SyS_write+0x55/0xd0
[  954.625549]  [<ffffffff8161c9e9>] system_call_fastpath+0x12/0x17
----------

I guess __alloc_pages_direct_reclaim() returns NULL with did_some_progress > 0
so that __alloc_pages_may_oom() will not be called easily. As long as
try_to_free_pages() returns non-zero, __alloc_pages_direct_reclaim() might
return NULL with did_some_progress > 0. So, do_try_to_free_pages() is called
for many times and is likely to return non-zero. And when
__alloc_pages_may_oom() is called, TIF_MEMDIE is set on the thread waiting
for mutex_lock(&"struct inode"->i_mutex) at xfs_file_buffered_aio_write()
and I see no further progress.

I don't know where to examine next. Would you please teach me command line
for tracepoints to examine?


> That's a CDROM event through the SCSI stack via a raw scsi device.
> If you read the code you'd see that scsi_execute() is the function
> using __GFP_WAIT semantics. This has *absolutely nothing* to do with
> XFS, and clearly has nothing to do with anything related to the
> problem you are seeing.

Oops, sorry. I was misunderstanding that

[  907.336156]  [<ffffffffa01e29cc>] sr_check_events+0xbc/0x2e0 [sr_mod]
[  907.337893]  [<ffffffff8109834c>] ? put_prev_entity+0x2c/0x3b0
[  907.339539]  [<ffffffffa01d6177>] cdrom_check_events+0x17/0x30 [cdrom]
[  907.341289]  [<ffffffffa01e2e5d>] sr_block_check_events+0x2d/0x30 [sr_mod]

lines are garbage. But indeed there is a chain

  disk_check_events() =>
    disk->fops->check_events(disk, clearing) == sr_block_check_events() =>
      cdrom_check_events() =>
        cdrom_update_events() =>
          cdi->ops->check_events() == sr_check_events() =>
            sr_get_events() =>
              scsi_execute_req()

that indicates it is blocked at CDROM event.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
