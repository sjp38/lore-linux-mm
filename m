From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] mm/vmscan: Do not block forever at shrink_inactive_list().
Date: Wed, 2 Jul 2014 21:40:52 +0900
Message-ID: <201407022140.BFJ13092.QVOSJtFMFHLOFO@I-love.SAKURA.ne.jp>
References: <6B2BA408B38BA1478B473C31C3D2074E31D59D8673@SV-EXCHANGE1.Corp.FC.LOCAL>
	<201405262045.CDG95893.HLFFOSFMQOVOJt@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.02.1406031442170.19491@chino.kir.corp.google.com>
	<201406052145.CIB35534.OQLVMSJFOHtFOF@I-love.SAKURA.ne.jp>
	<201406092053.AAD56799.FOOSLFHQJMVOtF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201406092053.AAD56799.FOOSLFHQJMVOtF@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
To: david@fromorbit.com
Cc: rientjes@google.com, Motohiro.Kosaki@us.fujitsu.com, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, fengguang.wu@intel.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fernando_b1@lab.ntt.co.jp
List-Id: linux-mm.kvack.org

Tetsuo Handa wrote:
> Here is a demo patch. If you can join analysis of why memory allocation
> function cannot return for more than 15 minutes under severe memory pressure,
> I'll invite you to private discussion in order to share steps for reproducing
> such memory pressure. A quick test says that memory reclaiming functions are
> too optimistic about reclaiming memory; they are needlessly called again and
> again and again with an assumption that some memory will be reclaimed within
> a few seconds. If I insert some delay, CPU usage during stalls can be reduced.

Here is a formal patch. This patch includes a test result of today's linux.git
tree with https://lkml.org/lkml/2014/5/29/673 applied, in order to find what
deadlock occurs next. The blocking delay on the mutex inside the ttm shrinker
has gone, but a kernel worker thread trying to perform a block I/O using
GFP_NOIO context is blocked for more than 10 minutes. I think this is not good.

---------- Start of patch ----------

>From c5274057bd71832fcf0baef64d43a49c20f29dbf Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 2 Jul 2014 09:34:51 +0900
Subject: [PATCH] mm: Remember ongoing memory allocation status.

When a stall by memory allocation problem occurs, printing how long
a thread blocked for memory allocation will be useful.

This patch allows remembering how many jiffies was spent for ongoing
__alloc_pages_nodemask() and reading it by printing backtrace and by
analyzing kdump.

Two examples are shown below. You can see that the GFP flags passed to
memory shrinker functions can be GFP_NOIO or GFP_NOFS. Therefore, when
writing memory shrinker functions, please be careful with dependency
inside shrinker functions. For example, unconditional use of GFP_KERNEL
may lead to deadlock. For another example, unconditional use of
blocking lock operations (e.g. mutex_lock()) which are called by
multiple different GFP contexts may lead to deadlock.

     kworker/2:2     R  running task        0   189      2 0x00000000
     MemAlloc: 624869 jiffies on 0x10
     Workqueue: events_freezable_power_ disk_events_workfn
      ffff880036eacfe0 000000004486d7e5 ffff88007fc83c48 ffffffff81090a3f
      ffff880036eacfe0 0000000000000000 ffff88007fc83c80 ffffffff81090b35
      ffff880036ead210 000000004486d7e5 ffffffff817bada0 0000000000000074
     Call Trace:
      [<ffffffff8158401f>] ? _raw_spin_lock+0x2f/0x50
      [<ffffffff81126b99>] list_lru_count_node+0x19/0x60
      [<ffffffff81171e10>] super_cache_count+0x50/0xd0
      [<ffffffff8111460a>] shrink_slab_node+0x3a/0x1b0
      [<ffffffff811683fc>] ? vmpressure+0x1c/0x80
      [<ffffffff811153f3>] shrink_slab+0x83/0x150
      [<ffffffff81118499>] do_try_to_free_pages+0x2f9/0x530
      [<ffffffff81118768>] try_to_free_pages+0x98/0xd0
      [<ffffffff8110e3f3>] __alloc_pages_nodemask+0x6e3/0xad0
      [<ffffffff8114b2b3>] alloc_pages_current+0xa3/0x170
      [<ffffffff81244d87>] bio_copy_user_iov+0x1c7/0x370
      [<ffffffff81244fc9>] bio_copy_kern+0x49/0xe0
      [<ffffffff8124ed4f>] blk_rq_map_kern+0x6f/0x130
      [<ffffffff81249273>] ? blk_get_request+0x83/0x140
      [<ffffffff81393381>] scsi_execute+0x131/0x160
      [<ffffffff81393484>] scsi_execute_req_flags+0x84/0xf0
      [<ffffffffa01b987c>] sr_check_events+0xbc/0x2d0 [sr_mod]
      [<ffffffffa018f173>] cdrom_check_events+0x13/0x30 [cdrom]
      [<ffffffffa01b9ced>] sr_block_check_events+0x2d/0x30 [sr_mod]
      [<ffffffff81258c75>] disk_check_events+0x55/0x1e0
      [<ffffffff81580e65>] ? _cond_resched+0x35/0x60
      [<ffffffff81258e11>] disk_events_workfn+0x11/0x20
      [<ffffffff8107d64f>] process_one_work+0x15f/0x3d0
      [<ffffffff8107de19>] worker_thread+0x119/0x620
      [<ffffffff8107dd00>] ? rescuer_thread+0x440/0x440
      [<ffffffff8108439c>] kthread+0xdc/0x100
      [<ffffffff810842c0>] ? kthread_create_on_node+0x1a0/0x1a0
      [<ffffffff8158483c>] ret_from_fork+0x7c/0xb0
      [<ffffffff810842c0>] ? kthread_create_on_node+0x1a0/0x1a0
    
     kworker/u16:2   R  running task        0 14009  13723 0x00000080
     MemAlloc: 624951 jiffies on 0x250
      0000000000000000 0000000000000100 0000000000000000 28f5c28f5c28f5c3
      0000000000001705 0000000000000060 0000000000000064 0000000000000064
      ffff880036dfea40 ffffffffffffff10 ffffffff8158401a 0000000000000010
     Call Trace:
      [<ffffffff8158401a>] ? _raw_spin_lock+0x2a/0x50
      [<ffffffff81126b99>] ? list_lru_count_node+0x19/0x60
      [<ffffffff81171e10>] ? super_cache_count+0x50/0xd0
      [<ffffffff8111460a>] ? shrink_slab_node+0x3a/0x1b0
      [<ffffffff811683fc>] ? vmpressure+0x1c/0x80
      [<ffffffff811153f3>] ? shrink_slab+0x83/0x150
      [<ffffffff81118499>] ? do_try_to_free_pages+0x2f9/0x530
      [<ffffffff81118768>] ? try_to_free_pages+0x98/0xd0
      [<ffffffff8110e3f3>] ? __alloc_pages_nodemask+0x6e3/0xad0
      [<ffffffff8114b2b3>] ? alloc_pages_current+0xa3/0x170
      [<ffffffffa0232755>] ? xfs_buf_allocate_memory+0x168/0x245 [xfs]
      [<ffffffffa01cc382>] ? xfs_buf_get_map+0xd2/0x130 [xfs]
      [<ffffffffa01cc964>] ? xfs_buf_read_map+0x24/0xc0 [xfs]
      [<ffffffffa0228609>] ? xfs_trans_read_buf_map+0xa9/0x330 [xfs]
      [<ffffffffa0217999>] ? xfs_imap_to_bp+0x69/0xf0 [xfs]
      [<ffffffffa0217e89>] ? xfs_iread+0x79/0x410 [xfs]
      [<ffffffffa01e35df>] ? kmem_zone_alloc+0x6f/0xf0 [xfs]
      [<ffffffffa01d3be3>] ? xfs_iget+0x1a3/0x510 [xfs]
      [<ffffffffa02121de>] ? xfs_lookup+0xbe/0xf0 [xfs]
      [<ffffffffa01d9023>] ? xfs_vn_lookup+0x73/0xc0 [xfs]
      [<ffffffff81178f88>] ? lookup_real+0x18/0x50
      [<ffffffff8117dced>] ? do_last+0x8bd/0xe90
      [<ffffffff8117adde>] ? link_path_walk+0x27e/0x8e0
      [<ffffffff8117e388>] ? path_openat+0xc8/0x6a0
      [<ffffffff8109700c>] ? select_task_rq_fair+0x3dc/0x7e0
      [<ffffffff8117fc18>] ? do_filp_open+0x48/0xb0
      [<ffffffff81154799>] ? kmem_cache_alloc+0x109/0x170
      [<ffffffff81208b51>] ? security_prepare_creds+0x11/0x20
      [<ffffffff811751ad>] ? do_open_exec+0x1d/0xe0
      [<ffffffff8117704d>] ? do_execve_common.isra.26+0x1bd/0x620
      [<ffffffff81154700>] ? kmem_cache_alloc+0x70/0x170
      [<ffffffff811774c3>] ? do_execve+0x13/0x20
      [<ffffffff81079ae7>] ? ____call_usermodehelper+0x117/0x1b0
      [<ffffffff81079b80>] ? ____call_usermodehelper+0x1b0/0x1b0
      [<ffffffff81079b99>] ? call_helper+0x19/0x20
      [<ffffffff8158483c>] ? ret_from_fork+0x7c/0xb0
      [<ffffffff81079b80>] ? ____call_usermodehelper+0x1b0/0x1b0

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/sched.h |  2 ++
 kernel/sched/core.c   | 11 +++++++++++
 mm/page_alloc.c       | 19 +++++++++++++++++--
 3 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 306f4f0..8b5edc7 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1655,6 +1655,8 @@ struct task_struct {
 	unsigned int	sequential_io;
 	unsigned int	sequential_io_avg;
 #endif
+	unsigned long memory_allocation_start_jiffies;
+	gfp_t memory_allocation_flags;
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 3bdf01b..0d1eb3e 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -4443,6 +4443,16 @@ out_unlock:
 	return retval;
 }
 
+static void print_memalloc_info(const struct task_struct *p)
+{
+	const unsigned long stamp = p->memory_allocation_start_jiffies;
+
+	if (likely(!stamp))
+		return;
+	printk(KERN_INFO "MemAlloc: %lu jiffies on 0x%x\n", jiffies - stamp,
+	       p->memory_allocation_flags);
+}
+
 static const char stat_nam[] = TASK_STATE_TO_CHAR_STR;
 
 void sched_show_task(struct task_struct *p)
@@ -4475,6 +4485,7 @@ void sched_show_task(struct task_struct *p)
 		task_pid_nr(p), ppid,
 		(unsigned long)task_thread_info(p)->flags);
 
+	print_memalloc_info(p);
 	print_worker_info(KERN_INFO, p);
 	show_stack(p, NULL);
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 20d17f8..cac0d32 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2721,6 +2721,17 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	unsigned int cpuset_mems_cookie;
 	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
 	int classzone_idx;
+	bool memory_allocation_recursion = false;
+	unsigned long *stamp = &current->memory_allocation_start_jiffies;
+
+	if (likely(!*stamp)) {
+		*stamp = jiffies;
+		if (unlikely(!*stamp))
+			(*stamp)--;
+		current->memory_allocation_flags = gfp_mask;
+	} else {
+		memory_allocation_recursion = true;
+	}
 
 	gfp_mask &= gfp_allowed_mask;
 
@@ -2729,7 +2740,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	might_sleep_if(gfp_mask & __GFP_WAIT);
 
 	if (should_fail_alloc_page(gfp_mask, order))
-		return NULL;
+		goto nopage;
 
 	/*
 	 * Check the zones suitable for the gfp_mask contain at least one
@@ -2737,7 +2748,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	 * of GFP_THISNODE and a memoryless node
 	 */
 	if (unlikely(!zonelist->_zonerefs->zone))
-		return NULL;
+		goto nopage;
 
 retry_cpuset:
 	cpuset_mems_cookie = read_mems_allowed_begin();
@@ -2799,6 +2810,10 @@ out:
 	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
 		goto retry_cpuset;
 
+nopage:
+	if (likely(!memory_allocation_recursion))
+		current->memory_allocation_start_jiffies = 0;
+
 	return page;
 }
 EXPORT_SYMBOL(__alloc_pages_nodemask);
-- 
1.8.3.1

---------- End of patch ----------

Above result is 2GB RAM and no swap space while below result is 2GB RAM and
4GB swap space.

If swap space is available, CPU usage during stalls tend to become 100% to
0% as waiting for disk I/O and congestion_wait() make processes sleep.

I succeeded to generate (so far only once) a CPU 0% stall that lasted for more
than 20 minutes blocked at congestion_wait() inside shrink_inactive_list().

    kthreadd        D ffff88007fcd31c0     0     2      0 0x00000000
    MemAlloc: 1374202 jiffies on 0x2000d0
     ffff88007c41f7c0 0000000000000046 ffff88007c4088e0 00000000000131c0
     ffff88007c41ffd8 00000000000131c0 ffff88007c46f360 0000000000000286
     ffff88007a14fc02 ffff88007c41f730 ffffffff81168040 ffffffff819cc300
    Call Trace:
     [<ffffffff81168040>] ? swap_cgroup_record+0x50/0x80
     [<ffffffff8106f766>] ? lock_timer_base.isra.26+0x26/0x50
     [<ffffffff81580b64>] schedule+0x24/0x70
     [<ffffffff8157ff26>] schedule_timeout+0x126/0x1c0
     [<ffffffff810be5d3>] ? ktime_get_ts+0x43/0xe0
     [<ffffffff8106f2c0>] ? add_timer_on+0xa0/0xa0
     [<ffffffff815810e6>] io_schedule_timeout+0x96/0xf0
     [<ffffffff8112123d>] congestion_wait+0x7d/0xd0
     [<ffffffff810a3da0>] ? __wake_up_sync+0x10/0x10
     [<ffffffff81116f0d>] shrink_inactive_list+0x37d/0x550
     [<ffffffff81117abb>] shrink_lruvec+0x52b/0x730
     [<ffffffff81117d54>] shrink_zone+0x94/0x1e0
     [<ffffffff811182c8>] do_try_to_free_pages+0x128/0x530
     [<ffffffff81118768>] try_to_free_pages+0x98/0xd0
     [<ffffffff8110e3f3>] __alloc_pages_nodemask+0x6e3/0xad0
     [<ffffffff8110e914>] alloc_kmem_pages_node+0x74/0x160
     [<ffffffff810617d5>] ? copy_process.part.32+0x125/0x1bb0
     [<ffffffff810617f6>] copy_process.part.32+0x146/0x1bb0
     [<ffffffff815805db>] ? __schedule+0x29b/0x800
     [<ffffffff810842c0>] ? kthread_create_on_node+0x1a0/0x1a0
     [<ffffffff81063427>] do_fork+0xd7/0x340
     [<ffffffff81091696>] ? set_cpus_allowed_ptr+0x76/0x120
     [<ffffffff810636b1>] kernel_thread+0x21/0x30
     [<ffffffff81084daa>] kthreadd+0x16a/0x1d0
     [<ffffffff81084c40>] ? kthread_create_on_cpu+0x60/0x60
     [<ffffffff8158483c>] ret_from_fork+0x7c/0xb0
     [<ffffffff81084c40>] ? kthread_create_on_cpu+0x60/0x60

    kswapd0         S ffff88007fc931c0     0    53      2 0x00000000
     ffff880079f17e10 0000000000000046 ffff88007c119aa0 00000000000131c0
     ffff880079f17fd8 00000000000131c0 ffff88007c46ea80 ffff880079f17dc0
     ffff880079f17dc0 0000000000000286 ffff88007c50c000 ffff880079f17d88
    Call Trace:
     [<ffffffff8106fc62>] ? try_to_del_timer_sync+0x52/0x80
     [<ffffffff8110a22c>] ? zone_watermark_ok_safe+0xac/0xc0
     [<ffffffff811150e9>] ? zone_balanced+0x19/0x50
     [<ffffffff811151ef>] ? pgdat_balanced+0xcf/0xf0
     [<ffffffff81580b64>] schedule+0x24/0x70
     [<ffffffff81119329>] kswapd+0x2f9/0x3c0
     [<ffffffff810a3da0>] ? __wake_up_sync+0x10/0x10
     [<ffffffff81119030>] ? balance_pgdat+0x640/0x640
     [<ffffffff8108439c>] kthread+0xdc/0x100
     [<ffffffff810842c0>] ? kthread_create_on_node+0x1a0/0x1a0
     [<ffffffff8158483c>] ret_from_fork+0x7c/0xb0
     [<ffffffff810842c0>] ? kthread_create_on_node+0x1a0/0x1a0

    kworker/u16:1   D ffff88007c11e1a0     0    65      2 0x00000000
    MemAlloc: 1455121 jiffies on 0x2000d0
    Workqueue: khelper __call_usermodehelper
     ffff880036c0b6b0 0000000000000046 ffff88007c11e1a0 00000000000131c0
     ffff880036c0bfd8 00000000000131c0 ffff88007c2091c0 ffff880036c0b668
     ffffea0001ff6a40 000000000000001d ffff88007cffec00 ffffea0001dfb000
    Call Trace:
     [<ffffffff8106f766>] ? lock_timer_base.isra.26+0x26/0x50
     [<ffffffff81580b64>] schedule+0x24/0x70
     [<ffffffff8157ff26>] schedule_timeout+0x126/0x1c0
     [<ffffffff810be5d3>] ? ktime_get_ts+0x43/0xe0
     [<ffffffff8106f2c0>] ? add_timer_on+0xa0/0xa0
     [<ffffffff815810e6>] io_schedule_timeout+0x96/0xf0
     [<ffffffff8112123d>] congestion_wait+0x7d/0xd0
     [<ffffffff810a3da0>] ? __wake_up_sync+0x10/0x10
     [<ffffffff81116f0d>] shrink_inactive_list+0x37d/0x550
     [<ffffffff81117abb>] shrink_lruvec+0x52b/0x730
     [<ffffffffa01d42d7>] ? xfs_reclaim_inodes_count+0x37/0x50 [xfs]
     [<ffffffffa01d42d7>] ? xfs_reclaim_inodes_count+0x37/0x50 [xfs]
     [<ffffffff81117d54>] shrink_zone+0x94/0x1e0
     [<ffffffff811182c8>] do_try_to_free_pages+0x128/0x530
     [<ffffffff81118768>] try_to_free_pages+0x98/0xd0
     [<ffffffff8110e3f3>] __alloc_pages_nodemask+0x6e3/0xad0
     [<ffffffff8110e914>] alloc_kmem_pages_node+0x74/0x160
     [<ffffffff810617d5>] ? copy_process.part.32+0x125/0x1bb0
     [<ffffffff810617f6>] copy_process.part.32+0x146/0x1bb0
     [<ffffffff81094255>] ? sched_clock_cpu+0x85/0xc0
     [<ffffffff8109b5ac>] ? put_prev_entity+0x2c/0x2c0
     [<ffffffff8100c5c4>] ? __switch_to+0xf4/0x5a0
     [<ffffffff81079b80>] ? ____call_usermodehelper+0x1b0/0x1b0
     [<ffffffff815805db>] ? __schedule+0x29b/0x800
     [<ffffffff81063427>] do_fork+0xd7/0x340
     [<ffffffffa0079a2b>] ? mpt_fault_reset_work+0x9b/0x45c [mptbase]
     [<ffffffff810636b1>] kernel_thread+0x21/0x30
     [<ffffffff81079bf9>] __call_usermodehelper+0x29/0x90
     [<ffffffff8107d64f>] process_one_work+0x15f/0x3d0
     [<ffffffff8107de19>] worker_thread+0x119/0x620
     [<ffffffff8107dd00>] ? rescuer_thread+0x440/0x440
     [<ffffffff8108439c>] kthread+0xdc/0x100
     [<ffffffff810842c0>] ? kthread_create_on_node+0x1a0/0x1a0
     [<ffffffff8158483c>] ret_from_fork+0x7c/0xb0
     [<ffffffff810842c0>] ? kthread_create_on_node+0x1a0/0x1a0

It seems to me that nobody was able to wake up kswapd. Therefore,
I think loops like

	while (unlikely(too_many_isolated(zone, file, sc))) {
		congestion_wait(BLK_RW_ASYNC, HZ/10);
	
		/* We are about to die and free our memory. Return now. */
		if (fatal_signal_pending(current))
			return SWAP_CLUSTER_MAX;
	}

which assume that somebody else shall wake up kswapd and kswapd shall perform
operations for making too_many_isolated() to return 0 is not good.
