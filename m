Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id A38536B00D3
	for <linux-mm@kvack.org>; Mon,  5 May 2014 19:34:07 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d49so1820552eek.4
        for <linux-mm@kvack.org>; Mon, 05 May 2014 16:34:06 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id z42si11596661eel.152.2014.05.05.16.34.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 05 May 2014 16:34:05 -0700 (PDT)
Date: Mon, 5 May 2014 19:33:58 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Bug 75101] New: [bisected] s2disk / hibernate blocks on "Saving
 506031 image data pages () ..."
Message-ID: <20140505233358.GC19914@cmpxchg.org>
Reply-To: I@cmpxchg.org
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oliver Winker <oliverml1@oli1170.net>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Maxim Patlasov <mpatlasov@parallels.com>, Fengguang Wu <fengguang.wu@intel.com>, Tejun Heo <tj@kernel.org>

Hi Oliver,

On Mon, May 05, 2014 at 11:00:13PM +0200, Oliver Winker wrote:
> Hello,
> 
> 1) Attached a full function-trace log + other SysRq outputs, see [1]
> attached.
> 
> I saw bdi_...() calls in the s2disk paths, but didn't check in detail 
> Probably more efficient when one of you guys looks directly.

Thanks, this looks interesting.  balance_dirty_pages() wakes up the
bdi_wq workqueue as it should:

[  249.148009]   s2disk-3327    2.... 48550413us : global_dirty_limits <-balance_dirty_pages_ratelimited
[  249.148009]   s2disk-3327    2.... 48550414us : global_dirtyable_memory <-global_dirty_limits
[  249.148009]   s2disk-3327    2.... 48550414us : writeback_in_progress <-balance_dirty_pages_ratelimited
[  249.148009]   s2disk-3327    2.... 48550414us : bdi_start_background_writeback <-balance_dirty_pages_ratelimited
[  249.148009]   s2disk-3327    2.... 48550414us : mod_delayed_work_on <-balance_dirty_pages_ratelimited
[  249.148009]   s2disk-3327    2.... 48550414us : try_to_grab_pending <-mod_delayed_work_on
[  249.148009]   s2disk-3327    2d... 48550414us : del_timer <-try_to_grab_pending
[  249.148009]   s2disk-3327    2d... 48550415us : get_work_pool <-try_to_grab_pending
[  249.148009]   s2disk-3327    2d... 48550415us : _raw_spin_lock <-try_to_grab_pending
[  249.148009]   s2disk-3327    2d... 48550415us : get_work_pwq <-try_to_grab_pending
[  249.148009]   s2disk-3327    2d... 48550415us : pwq_activate_delayed_work <-try_to_grab_pending
[  249.148009]   s2disk-3327    2d... 48550415us : get_work_pwq <-pwq_activate_delayed_work
[  249.148009]   s2disk-3327    2d... 48550415us : move_linked_works <-pwq_activate_delayed_work
[  249.148009]   s2disk-3327    2d... 48550415us : get_work_pwq <-try_to_grab_pending
[  249.148009]   s2disk-3327    2d... 48550416us : pwq_dec_nr_in_flight <-try_to_grab_pending
[  249.148009]   s2disk-3327    2d... 48550416us : __queue_delayed_work <-mod_delayed_work_on
[  249.148009]   s2disk-3327    2d... 48550416us : __queue_work <-mod_delayed_work_on
[  249.148009]   s2disk-3327    2d... 48550416us : get_work_pool <-__queue_work
[  249.148009]   s2disk-3327    2d... 48550416us : _raw_spin_lock <-__queue_work
[  249.148009]   s2disk-3327    2d... 48550416us : insert_work <-__queue_work
[  249.148009]   s2disk-3327    2d... 48550417us : get_pwq.isra.20 <-insert_work
[  249.148009]   s2disk-3327    2d... 48550417us : wake_up_worker <-__queue_work
[  249.148009]   s2disk-3327    2d... 48550417us : wake_up_process <-__queue_work
[  249.148009]   s2disk-3327    2d... 48550417us : try_to_wake_up <-__queue_work
[  249.148009]   s2disk-3327    2d... 48550417us : _raw_spin_lock_irqsave <-try_to_wake_up
[  249.148009]   s2disk-3327    2d... 48550417us : task_waking_fair <-try_to_wake_up
[  249.148009]   s2disk-3327    2d... 48550418us : select_task_rq_fair <-select_task_rq
[  249.148009]   s2disk-3327    2d... 48550418us : idle_cpu <-select_task_rq_fair
[  249.148009]   s2disk-3327    2d... 48550418us : idle_cpu <-select_task_rq_fair
[  249.148009]   s2disk-3327    2d... 48550418us : cpus_share_cache <-try_to_wake_up
[  249.148009]   s2disk-3327    2d... 48550418us : _raw_spin_lock <-try_to_wake_up
[  249.148009]   s2disk-3327    2d... 48550419us : ttwu_do_activate.constprop.100 <-try_to_wake_up
[  249.148009]   s2disk-3327    2d... 48550419us : activate_task <-ttwu_do_activate.constprop.100
[  249.148009]   s2disk-3327    2d... 48550419us : enqueue_task <-ttwu_do_activate.constprop.100
[  249.148009]   s2disk-3327    2d... 48550419us : update_rq_clock <-enqueue_task
[  249.148009]   s2disk-3327    2d... 48550419us : enqueue_task_fair <-ttwu_do_activate.constprop.100
[  249.148009]   s2disk-3327    2d... 48550419us : update_curr <-enqueue_task_fair
[  249.148009]   s2disk-3327    2d... 48550420us : update_min_vruntime <-update_curr
[  249.148009]   s2disk-3327    2d... 48550420us : __compute_runnable_contrib.part.55 <-update_entity_load_avg
[  249.148009]   s2disk-3327    2d... 48550420us : update_cfs_rq_blocked_load <-enqueue_task_fair
[  249.148009]   s2disk-3327    2d... 48550420us : account_entity_enqueue <-enqueue_task_fair
[  249.148009]   s2disk-3327    2d... 48550420us : update_cfs_shares <-enqueue_task_fair
[  249.148009]   s2disk-3327    2d... 48550420us : __enqueue_entity <-enqueue_task_fair
[  249.148009]   s2disk-3327    2d... 48550421us : hrtick_update <-ttwu_do_activate.constprop.100
[  249.148009]   s2disk-3327    2d... 48550421us : wq_worker_waking_up <-ttwu_do_activate.constprop.100
[  249.148009]   s2disk-3327    2d... 48550421us : kthread_data <-wq_worker_waking_up
[  249.148009]   s2disk-3327    2d... 48550421us : ttwu_do_wakeup <-try_to_wake_up
[  249.148009]   s2disk-3327    2d... 48550421us : check_preempt_curr <-ttwu_do_wakeup
[  249.148009]   s2disk-3327    2d... 48550421us : check_preempt_wakeup <-check_preempt_curr
[  249.148009]   s2disk-3327    2d... 48550422us : update_curr <-check_preempt_wakeup
[  249.148009]   s2disk-3327    2d... 48550422us : wakeup_preempt_entity.isra.53 <-check_preempt_wakeup
[  249.148009]   s2disk-3327    2d... 48550422us : _raw_spin_unlock_irqrestore <-try_to_wake_up
[  249.148009]   s2disk-3327    2.... 48550423us : bdi_dirty_limit <-bdi_dirty_limits
[  249.148009]   s2disk-3327    2d... 48550423us : _raw_spin_lock_irqsave <-__percpu_counter_sum
[  249.148009]   s2disk-3327    2d... 48550423us : _raw_spin_unlock_irqrestore <-__percpu_counter_sum
[  249.148009]   s2disk-3327    2d... 48550423us : _raw_spin_lock_irqsave <-__percpu_counter_sum
[  249.148009]   s2disk-3327    2d... 48550424us : _raw_spin_unlock_irqrestore <-__percpu_counter_sum
[  249.148009]   s2disk-3327    2.... 48550424us : bdi_position_ratio <-balance_dirty_pages_ratelimited
[  249.148009]   s2disk-3327    2.... 48550424us : io_schedule_timeout <-balance_dirty_pages_ratelimited
[  249.148009]   s2disk-3327    2.... 48550424us : __delayacct_blkio_start <-io_schedule_timeout
[  249.148009]   s2disk-3327    2.... 48550424us : ktime_get_ts <-io_schedule_timeout
[  249.148009]   s2disk-3327    2.... 48550424us : blk_flush_plug_list <-io_schedule_timeout
[  249.148009]   s2disk-3327    2.... 48550425us : schedule_timeout <-io_schedule_timeout
[  249.148009]   s2disk-3327    2.... 48550425us : lock_timer_base.isra.35 <-__mod_timer
[  249.148009]   s2disk-3327    2.... 48550425us : _raw_spin_lock_irqsave <-lock_timer_base.isra.35
[  249.148009]   s2disk-3327    2d... 48550425us : detach_if_pending <-__mod_timer
[  249.148009]   s2disk-3327    2d... 48550425us : idle_cpu <-__mod_timer
[  249.148009]   s2disk-3327    2d... 48550425us : internal_add_timer <-__mod_timer
[  249.148009]   s2disk-3327    2d... 48550425us : __internal_add_timer <-internal_add_timer
[  249.148009]   s2disk-3327    2d... 48550426us : _raw_spin_unlock_irqrestore <-__mod_timer
[  249.148009]   s2disk-3327    2.... 48550426us : schedule <-schedule_timeout
[  249.148009]   s2disk-3327    2.... 48550426us : __schedule <-schedule_timeout
[  249.148009]   s2disk-3327    2.... 48550426us : rcu_note_context_switch <-__schedule
[  249.148009]   s2disk-3327    2.... 48550426us : rcu_sched_qs <-rcu_note_context_switch
[  249.148009]   s2disk-3327    2.... 48550426us : _raw_spin_lock_irq <-__schedule
[  249.148009]   s2disk-3327    2d... 48550427us : deactivate_task <-__schedule
[  249.148009]   s2disk-3327    2d... 48550427us : dequeue_task <-__schedule
[  249.148009]   s2disk-3327    2d... 48550427us : update_rq_clock <-dequeue_task
[  249.148009]   s2disk-3327    2d... 48550427us : dequeue_task_fair <-__schedule
[  249.148009]   s2disk-3327    2d... 48550427us : update_curr <-dequeue_task_fair
[  249.148009]   s2disk-3327    2d... 48550427us : update_min_vruntime <-update_curr
[  249.148009]   s2disk-3327    2d... 48550427us : cpuacct_charge <-update_curr
[  249.148009]   s2disk-3327    2d... 48550428us : update_cfs_rq_blocked_load <-dequeue_task_fair
[  249.148009]   s2disk-3327    2d... 48550428us : clear_buddies <-dequeue_task_fair
[  249.148009]   s2disk-3327    2d... 48550428us : account_entity_dequeue <-dequeue_task_fair
[  249.148009]   s2disk-3327    2d... 48550428us : update_min_vruntime <-dequeue_task_fair
[  249.148009]   s2disk-3327    2d... 48550428us : update_cfs_shares <-dequeue_task_fair
[  249.148009]   s2disk-3327    2d... 48550428us : update_curr <-update_cfs_shares
[  249.148009]   s2disk-3327    2d... 48550429us : update_min_vruntime <-update_curr
[  249.148009]   s2disk-3327    2d... 48550429us : account_entity_dequeue <-update_cfs_shares
[  249.148009]   s2disk-3327    2d... 48550429us : account_entity_enqueue <-dequeue_task_fair
[  249.148009]   s2disk-3327    2d... 48550429us : update_curr <-dequeue_task_fair
[  249.148009]   s2disk-3327    2d... 48550429us : update_cfs_rq_blocked_load <-dequeue_task_fair
[  249.148009]   s2disk-3327    2d... 48550429us : clear_buddies <-dequeue_task_fair
[  249.148009]   s2disk-3327    2d... 48550429us : account_entity_dequeue <-dequeue_task_fair
[  249.148009]   s2disk-3327    2d... 48550430us : update_min_vruntime <-dequeue_task_fair
[  249.148009]   s2disk-3327    2d... 48550430us : update_cfs_shares <-dequeue_task_fair
[  249.148009]   s2disk-3327    2d... 48550430us : hrtick_update <-__schedule
[  249.148009]   s2disk-3327    2d... 48550430us : put_prev_task_fair <-__schedule
[  249.148009]   s2disk-3327    2d... 48550430us : pick_next_task_fair <-pick_next_task
[  249.148009]   s2disk-3327    2d... 48550430us : clear_buddies <-pick_next_task_fair
[  249.148009]   s2disk-3327    2d... 48550431us : __dequeue_entity <-pick_next_task_fair

but the worker wakeup doesn't actually do anything:

[  249.148009] kworker/-3466    2d... 48550431us : finish_task_switch <-__schedule
[  249.148009] kworker/-3466    2.... 48550431us : _raw_spin_lock_irq <-worker_thread
[  249.148009] kworker/-3466    2d... 48550431us : need_to_create_worker <-worker_thread
[  249.148009] kworker/-3466    2d... 48550432us : worker_enter_idle <-worker_thread
[  249.148009] kworker/-3466    2d... 48550432us : too_many_workers <-worker_enter_idle
[  249.148009] kworker/-3466    2.... 48550432us : schedule <-worker_thread
[  249.148009] kworker/-3466    2.... 48550432us : __schedule <-worker_thread

My suspicion is that this fails because the bdi_wq is frozen at this
point and so the flush work never runs until resume, whereas before my
patch the effective dirty limit was high enough so that image could be
written in one go without being throttled; followed by an fsync() that
then writes the pages in the context of the unfrozen s2disk.

Does this make sense?  Rafael?  Tejun?

> 2) /sys/kernel/debug/bdi/<dev>/stats
> 
> They are also in [1] - however the major/minors of my sdbX didn't
> match with the /sys/.../bdi/<dev>'s. So I just displayed them all.
> 
> 3) What is the estimated bandwith?
> 
> It's an Samsung SSD 840 PRO, in this system: Read: 237 MB/s, Write 265
> MB/s - see [2] (the faster writing is maybe due caching?)
> 
> 
> Just by curiosity: 
> 
> Can you also reproduce it ? ... since the test is quite simple. 
> Or is it something specific in my system here ?

I tried to reproduce it here but could never get to hang it in
balance_dirty_pages() like you did.

Thanks,
Johannes

> [1] Attached session.log.s2disk.20140505_2238.bz2
> - 18MiB uncompressed function-trace output + others 
> - The bdi outputs are also in there
> 
> [2] Rough bandwidth tests
> Read:
> ---
> gamix64:~# swapon -s 
> Filename                                Type            Size    Used    Priority
> /dev/sdb7                               partition       4193276 0       -1
> gamix64:~# dd if=/dev/sdb7 bs=1024 count=$[1024*1024*4] |pv >/dev/null
>    4GB 0:00:18 [ 226MB/s] [                                                     <=>                                                                                        ]4193280+0 records in
> 4193280+0 records out
> 
> 4293918720 bytes (4.3 GB) copied, 18.1509 s, 237 MB/s                                                                                                                       
> ---
> 
> Write:
> ---
> gamix64:~# dd if=/dev/zero bs=1024 count=$[1024*1024*4] |pv >/root/Test/test1.bin
> 4194304+0 records inMB/s] [                                          <=>                                                                                                   ]
> 4194304+0 records out
> 4294967296 bytes (4.3 GB) copied, 16.2039 s, 265 MB/s
>    4GB 0:00:15 [ 256MB/s] [                                             <=>                                                                                                ]
> ---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
