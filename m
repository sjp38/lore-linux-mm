Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id CAF756B005A
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 17:25:03 -0400 (EDT)
Date: Wed, 22 Aug 2012 23:24:59 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 19/36] autonuma: memory follows CPU algorithm and
 task/mm_autonuma stats collection
Message-ID: <20120822212459.GC8107@redhat.com>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
 <1345647560-30387-20-git-send-email-aarcange@redhat.com>
 <m2sjbe7k93.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m2sjbe7k93.fsf@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Andi,

On Wed, Aug 22, 2012 at 01:19:04PM -0700, Andi Kleen wrote:
> Andrea Arcangeli <aarcange@redhat.com> writes:
> 
> > +/*
> > + * In this function we build a temporal CPU_node<->page relation by
> > + * using a two-stage autonuma_last_nid filter to remove short/unlikely
> > + * relations.
> > + *
> > + * Using P(p) ~ n_p / n_t as per frequentest probability, we can
> > + * equate a node's CPU usage of a particular page (n_p) per total
> > + * usage of this page (n_t) (in a given time-span) to a probability.
> > + *
> > + * Our periodic faults will then sample this probability and getting
> > + * the same result twice in a row, given these samples are fully
> > + * independent, is then given by P(n)^2, provided our sample period
> > + * is sufficiently short compared to the usage pattern.
> > + *
> > + * This quadric squishes small probabilities, making it less likely
> > + * we act on an unlikely CPU_node<->page relation.
> > + */
> 
> The code does not seem to do what the comment describes.

This comment seems quite accurate to me (btw I taken it from
sched-numa rewrite with minor changes).

By having a confirmation through periodic samples that the memory
access happens twice in a row from the same node we increase the
probability of doing worthwhile memory migrations and we diminish the
risk of worthless migration as result of false relations/sharing.

> > +static inline bool last_nid_set(struct page *page, int this_nid)
> > +{
> > +	bool ret = true;
> > +	int autonuma_last_nid = ACCESS_ONCE(page->autonuma_last_nid);
> > +	VM_BUG_ON(this_nid < 0);
> > +	VM_BUG_ON(this_nid >= MAX_NUMNODES);
> > +	if (autonuma_last_nid >= 0 && autonuma_last_nid != this_nid) {
> > +		int migrate_nid = ACCESS_ONCE(page->autonuma_migrate_nid);
> > +		if (migrate_nid >= 0)
> > +			__autonuma_migrate_page_remove(page);
> > +		ret = false;
> > +	}
> > +	if (autonuma_last_nid != this_nid)
> > +		ACCESS_ONCE(page->autonuma_last_nid) = this_nid;
> > +	return ret;
> > +}
> > +
> > +		/*
> > +		 * Take the lock with irqs disabled to avoid a lock
> > +		 * inversion with the lru_lock. The lru_lock is taken
> > +		 * before the autonuma_migrate_lock in
> > +		 * split_huge_page. If we didn't disable irqs, the
> > +		 * lru_lock could be taken by interrupts after we have
> > +		 * obtained the autonuma_migrate_lock here.
> > +		 */
> 
> Which interrupt code takes the lru_lock? That sounds like a bug.

Disabling irqs around lru_lock was an optimization to avoid increasing
the hold time of the lock when all critical sections were short after
the isolation code. Now it's used to rotate lrus at I/O completion too.

end_page_writeback -> rotate_reclaimable_page -> pagevec_move_tail

=========================================================
[ INFO: possible irq lock inversion dependency detected ]
3.6.0-rc2+ #46 Not tainted
---------------------------------------------------------
numa01/7725 just changed the state of lock:
 (&(&zone->lru_lock)->rlock){..-.-.}, at: [<ffffffff81106e5e>] pagevec_lru_move_fn+0x9e/0x110
but this lock took another, SOFTIRQ-unsafe lock in the past:
 (&(&pgdat->autonuma_lock)->rlock){+.+.-.}

and interrupts could create inverse lock ordering between them.


other info that might help us debug this:
 Possible interrupt unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(&(&pgdat->autonuma_lock)->rlock);
                               local_irq_disable();
                               lock(&(&zone->lru_lock)->rlock);
                               lock(&(&pgdat->autonuma_lock)->rlock);
  <Interrupt>
    lock(&(&zone->lru_lock)->rlock);

 *** DEADLOCK ***

2 locks held by numa01/7725:
 #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff815527f1>] do_page_fault+0x121/0x520
 #1:  (rcu_read_lock){.+.+..}, at: [<ffffffff81153ee8>] __mem_cgroup_try_charge+0x348/0xbb0

the shortest dependencies between 2nd lock and 1st lock:
 -> (&(&pgdat->autonuma_lock)->rlock){+.+.-.} ops: 7031259 {
    HARDIRQ-ON-W at:
                      [<ffffffff810b9e6f>] mark_held_locks+0x5f/0x140
                      [<ffffffff810ba002>] trace_hardirqs_on_caller+0xb2/0x1a0
                      [<ffffffff810ba0fd>] trace_hardirqs_on+0xd/0x10
                      [<ffffffff8113de49>] knuma_migrated+0x259/0xab0
                      [<ffffffff8107fdd6>] kthread+0xb6/0xc0
                      [<ffffffff81557204>] kernel_thread_helper+0x4/0x10
    SOFTIRQ-ON-W at:
                      [<ffffffff810b9e6f>] mark_held_locks+0x5f/0x140
                      [<ffffffff810ba05d>] trace_hardirqs_on_caller+0x10d/0x1a0
                      [<ffffffff810ba0fd>] trace_hardirqs_on+0xd/0x10
                      [<ffffffff8113de49>] knuma_migrated+0x259/0xab0
                      [<ffffffff8107fdd6>] kthread+0xb6/0xc0
                      [<ffffffff81557204>] kernel_thread_helper+0x4/0x10
    IN-RECLAIM_FS-W at:
                         [<ffffffff810b78f4>] __lock_acquire+0x5c4/0x1dd0
                         [<ffffffff810b9682>] lock_acquire+0x62/0x80
                         [<ffffffff8154de9b>] _raw_spin_lock+0x3b/0x50
                         [<ffffffff8113dafd>] __autonuma_migrate_page_remove+0xdd/0x1d0
                         [<ffffffff81101483>] free_pages_prepare+0xe3/0x190
                         [<ffffffff811016b4>] free_hot_cold_page+0x44/0x1d0
                         [<ffffffff81101a6e>] free_hot_cold_page_list+0x3e/0x60
                         [<ffffffff81106d81>] release_pages+0x1f1/0x230
                         [<ffffffff81106eb0>] pagevec_lru_move_fn+0xf0/0x110
                         [<ffffffff81106ee7>] __pagevec_lru_add+0x17/0x20
                         [<ffffffff8110780b>] lru_add_drain_cpu+0x9b/0x130
                         [<ffffffff81107969>] lru_add_drain+0x29/0x40
                         [<ffffffff8110add5>] shrink_active_list+0x65/0x340
                         [<ffffffff8110c483>] balance_pgdat+0x323/0x890
                         [<ffffffff8110cbb3>] kswapd+0x1c3/0x340
                         [<ffffffff8107fdd6>] kthread+0xb6/0xc0
                         [<ffffffff81557204>] kernel_thread_helper+0x4/0x10
    INITIAL USE at:
                     [<ffffffff810b762f>] __lock_acquire+0x2ff/0x1dd0
                     [<ffffffff810b9682>] lock_acquire+0x62/0x80
                     [<ffffffff8154de9b>] _raw_spin_lock+0x3b/0x50
                     [<ffffffff8113e95b>] numa_hinting_fault+0x2bb/0x5b0
                     [<ffffffff8113ee9d>] __pmd_numa_fixup+0x1cd/0x200
                     [<ffffffff8111de08>] handle_mm_fault+0x2c8/0x380
                     [<ffffffff8155285e>] do_page_fault+0x18e/0x520
                     [<ffffffff8154ed85>] page_fault+0x25/0x30
                     [<ffffffff81172d7c>] sys_poll+0x6c/0x100
                     [<ffffffff815560b9>] system_call_fastpath+0x16/0x1b
  }
  ... key      at: [<ffffffff8220b968>] __key.16051+0x0/0x18
  ... acquired at:
   [<ffffffff810b9682>] lock_acquire+0x62/0x80
   [<ffffffff8154de9b>] _raw_spin_lock+0x3b/0x50
   [<ffffffff8113d929>] autonuma_migrate_split_huge_page+0x119/0x210
   [<ffffffff8114c897>] split_huge_page+0x267/0x7f0
   [<ffffffff8113df52>] knuma_migrated+0x362/0xab0
   [<ffffffff8107fdd6>] kthread+0xb6/0xc0
   [<ffffffff81557204>] kernel_thread_helper+0x4/0x10

-> (&(&zone->lru_lock)->rlock){..-.-.} ops: 10130605 {
   IN-SOFTIRQ-W at:
                    [<ffffffff810b7a95>] __lock_acquire+0x765/0x1dd0
                    [<ffffffff810b9682>] lock_acquire+0x62/0x80
                    [<ffffffff8154dfe3>] _raw_spin_lock_irqsave+0x53/0x70
                    [<ffffffff81106e5e>] pagevec_lru_move_fn+0x9e/0x110
                    [<ffffffff81106faf>] pagevec_move_tail+0x1f/0x30
                    [<ffffffff811074fd>] rotate_reclaimable_page+0xdd/0x100
                    [<ffffffff810f90ad>] end_page_writeback+0x4d/0x60
                    [<ffffffff8112f21b>] end_swap_bio_write+0x2b/0x80
                    [<ffffffff8118f9d8>] bio_endio+0x18/0x30
                    [<ffffffff8124970b>] req_bio_endio.clone.53+0x8b/0xd0
                    [<ffffffff81249840>] blk_update_request+0xf0/0x5a0
                    [<ffffffff81249d1f>] blk_update_bidi_request+0x2f/0x90
                    [<ffffffff81249daa>] blk_end_bidi_request+0x2a/0x80
                    [<ffffffff81249e3b>] blk_end_request+0xb/0x10
                    [<ffffffff81349e27>] scsi_io_completion+0x97/0x640
                    [<ffffffff8134238e>] scsi_finish_command+0xbe/0xf0
                    [<ffffffff81349c1f>] scsi_softirq_done+0x9f/0x130
                    [<ffffffff8124fee2>] blk_done_softirq+0x82/0xa0
                    [<ffffffff81064278>] __do_softirq+0xc8/0x180
                    [<ffffffff815572fc>] call_softirq+0x1c/0x30
                    [<ffffffff81004375>] do_softirq+0xa5/0xe0
                    [<ffffffff8106462e>] irq_exit+0x9e/0xc0
                    [<ffffffff8102330f>] smp_call_function_single_interrupt+0x2f/0x40
                    [<ffffffff81556d6f>] call_function_single_interrupt+0x6f/0x80
                    [<ffffffff8114ff6e>] mem_cgroup_from_task+0x4e/0xd0
                    [<ffffffff81153f5d>] __mem_cgroup_try_charge+0x3bd/0xbb0
                    [<ffffffff81154e54>] mem_cgroup_charge_common+0x64/0xc0
                    [<ffffffff811554c1>] mem_cgroup_newpage_charge+0x31/0x40
                    [<ffffffff8111d5fa>] handle_pte_fault+0x70a/0xa90
                    [<ffffffff8111dd93>] handle_mm_fault+0x253/0x380
                    [<ffffffff8155285e>] do_page_fault+0x18e/0x520
                    [<ffffffff8154ed85>] page_fault+0x25/0x30
   IN-RECLAIM_FS-W at:
                       [<ffffffff810b78f4>] __lock_acquire+0x5c4/0x1dd0
                       [<ffffffff810b9682>] lock_acquire+0x62/0x80
                       [<ffffffff8154dfe3>] _raw_spin_lock_irqsave+0x53/0x70
                       [<ffffffff81106e5e>] pagevec_lru_move_fn+0x9e/0x110
                       [<ffffffff81106ee7>] __pagevec_lru_add+0x17/0x20
                       [<ffffffff8110780b>] lru_add_drain_cpu+0x9b/0x130
                       [<ffffffff81107969>] lru_add_drain+0x29/0x40
                       [<ffffffff8110add5>] shrink_active_list+0x65/0x340
                       [<ffffffff8110c483>] balance_pgdat+0x323/0x890
                       [<ffffffff8110cbb3>] kswapd+0x1c3/0x340
                       [<ffffffff8107fdd6>] kthread+0xb6/0xc0
                       [<ffffffff81557204>] kernel_thread_helper+0x4/0x10
   INITIAL USE at:
                   [<ffffffff810b762f>] __lock_acquire+0x2ff/0x1dd0
                   [<ffffffff810b9682>] lock_acquire+0x62/0x80
                   [<ffffffff8154dfe3>] _raw_spin_lock_irqsave+0x53/0x70
                   [<ffffffff81106e5e>] pagevec_lru_move_fn+0x9e/0x110
                   [<ffffffff81106ee7>] __pagevec_lru_add+0x17/0x20
                   [<ffffffff8110780b>] lru_add_drain_cpu+0x9b/0x130
                   [<ffffffff81107969>] lru_add_drain+0x29/0x40
                   [<ffffffff81107991>] __pagevec_release+0x11/0x30
                   [<ffffffff81108454>] truncate_inode_pages_range+0x344/0x4b0
                   [<ffffffff81108640>] truncate_inode_pages+0x10/0x20
                   [<ffffffff811926da>] kill_bdev+0x2a/0x40
                   [<ffffffff81192aff>] __blkdev_put+0x6f/0x1d0
                   [<ffffffff81192cbb>] blkdev_put+0x5b/0x170
                   [<ffffffff81253cfa>] add_disk+0x41a/0x4a0
                   [<ffffffff81355290>] sd_probe_async+0x120/0x1d0
                   [<ffffffff8108800d>] async_run_entry_fn+0x7d/0x180
                   [<ffffffff810777ff>] process_one_work+0x19f/0x510
                   [<ffffffff8107a7e7>] worker_thread+0x1a7/0x4b0
                   [<ffffffff8107fdd6>] kthread+0xb6/0xc0
                   [<ffffffff81557204>] kernel_thread_helper+0x4/0x10
 }
 ... key      at: [<ffffffff822094c8>] __key.34621+0x0/0x8
 ... acquired at:
   [<ffffffff810b5fde>] check_usage_forwards+0x8e/0x110
   [<ffffffff810b6ed6>] mark_lock+0x1d6/0x630
   [<ffffffff810b7a95>] __lock_acquire+0x765/0x1dd0
   [<ffffffff810b9682>] lock_acquire+0x62/0x80
   [<ffffffff8154dfe3>] _raw_spin_lock_irqsave+0x53/0x70
   [<ffffffff81106e5e>] pagevec_lru_move_fn+0x9e/0x110
   [<ffffffff81106faf>] pagevec_move_tail+0x1f/0x30
   [<ffffffff811074fd>] rotate_reclaimable_page+0xdd/0x100
   [<ffffffff810f90ad>] end_page_writeback+0x4d/0x60
   [<ffffffff8112f21b>] end_swap_bio_write+0x2b/0x80
   [<ffffffff8118f9d8>] bio_endio+0x18/0x30
   [<ffffffff8124970b>] req_bio_endio.clone.53+0x8b/0xd0
   [<ffffffff81249840>] blk_update_request+0xf0/0x5a0
   [<ffffffff81249d1f>] blk_update_bidi_request+0x2f/0x90
   [<ffffffff81249daa>] blk_end_bidi_request+0x2a/0x80
   [<ffffffff81249e3b>] blk_end_request+0xb/0x10
   [<ffffffff81349e27>] scsi_io_completion+0x97/0x640
   [<ffffffff8134238e>] scsi_finish_command+0xbe/0xf0
   [<ffffffff81349c1f>] scsi_softirq_done+0x9f/0x130
   [<ffffffff8124fee2>] blk_done_softirq+0x82/0xa0
   [<ffffffff81064278>] __do_softirq+0xc8/0x180
   [<ffffffff815572fc>] call_softirq+0x1c/0x30
   [<ffffffff81004375>] do_softirq+0xa5/0xe0
   [<ffffffff8106462e>] irq_exit+0x9e/0xc0
   [<ffffffff8102330f>] smp_call_function_single_interrupt+0x2f/0x40
   [<ffffffff81556d6f>] call_function_single_interrupt+0x6f/0x80
   [<ffffffff8114ff6e>] mem_cgroup_from_task+0x4e/0xd0
   [<ffffffff81153f5d>] __mem_cgroup_try_charge+0x3bd/0xbb0
   [<ffffffff81154e54>] mem_cgroup_charge_common+0x64/0xc0
   [<ffffffff811554c1>] mem_cgroup_newpage_charge+0x31/0x40
   [<ffffffff8111d5fa>] handle_pte_fault+0x70a/0xa90
   [<ffffffff8111dd93>] handle_mm_fault+0x253/0x380
   [<ffffffff8155285e>] do_page_fault+0x18e/0x520
   [<ffffffff8154ed85>] page_fault+0x25/0x30


stack backtrace:
Pid: 7725, comm: numa01 Not tainted 3.6.0-rc2+ #46
Call Trace:
 <IRQ>  [<ffffffff810b5f06>] print_irq_inversion_bug+0x1c6/0x210
 [<ffffffff810b5f50>] ? print_irq_inversion_bug+0x210/0x210
 [<ffffffff810b5fde>] check_usage_forwards+0x8e/0x110
 [<ffffffff810b6ed6>] mark_lock+0x1d6/0x630
 [<ffffffff810b7a95>] __lock_acquire+0x765/0x1dd0
 [<ffffffff810fb790>] ? mempool_alloc_slab+0x10/0x20
 [<ffffffff811465cb>] ? kmem_cache_alloc+0xbb/0x1b0
 [<ffffffff810b9682>] lock_acquire+0x62/0x80
 [<ffffffff81106e5e>] ? pagevec_lru_move_fn+0x9e/0x110
 [<ffffffff8154dfe3>] _raw_spin_lock_irqsave+0x53/0x70
 [<ffffffff81106e5e>] ? pagevec_lru_move_fn+0x9e/0x110
 [<ffffffff81106e5e>] pagevec_lru_move_fn+0x9e/0x110
 [<ffffffff81106400>] ? __pagevec_lru_add_fn+0x130/0x130
 [<ffffffff81106faf>] pagevec_move_tail+0x1f/0x30
 [<ffffffff811074fd>] rotate_reclaimable_page+0xdd/0x100
 [<ffffffff810f90ad>] end_page_writeback+0x4d/0x60
 [<ffffffff81349592>] ? scsi_request_fn+0xa2/0x4b0
 [<ffffffff8112f21b>] end_swap_bio_write+0x2b/0x80
 [<ffffffff8118f9d8>] bio_endio+0x18/0x30
 [<ffffffff8124970b>] req_bio_endio.clone.53+0x8b/0xd0
 [<ffffffff81249840>] blk_update_request+0xf0/0x5a0
 [<ffffffff81249a7a>] ? blk_update_request+0x32a/0x5a0
 [<ffffffff81249d1f>] blk_update_bidi_request+0x2f/0x90
 [<ffffffff81249daa>] blk_end_bidi_request+0x2a/0x80
 [<ffffffff81249e3b>] blk_end_request+0xb/0x10
 [<ffffffff81349e27>] scsi_io_completion+0x97/0x640
 [<ffffffff8134238e>] scsi_finish_command+0xbe/0xf0
 [<ffffffff81349c1f>] scsi_softirq_done+0x9f/0x130
 [<ffffffff8124fee2>] blk_done_softirq+0x82/0xa0
 [<ffffffff81064278>] __do_softirq+0xc8/0x180
 [<ffffffff810b4b5d>] ? trace_hardirqs_off+0xd/0x10
 [<ffffffff815572fc>] call_softirq+0x1c/0x30
 [<ffffffff81004375>] do_softirq+0xa5/0xe0
 [<ffffffff8106462e>] irq_exit+0x9e/0xc0
 [<ffffffff8102330f>] smp_call_function_single_interrupt+0x2f/0x40
 [<ffffffff81556d6f>] call_function_single_interrupt+0x6f/0x80
 <EOI>  [<ffffffff8107c699>] ? debug_lockdep_rcu_enabled+0x29/0x40
 [<ffffffff8114ff6e>] mem_cgroup_from_task+0x4e/0xd0
 [<ffffffff81153f5d>] __mem_cgroup_try_charge+0x3bd/0xbb0
 [<ffffffff81153ee8>] ? __mem_cgroup_try_charge+0x348/0xbb0
 [<ffffffff81154e54>] mem_cgroup_charge_common+0x64/0xc0
 [<ffffffff811554c1>] mem_cgroup_newpage_charge+0x31/0x40
 [<ffffffff8111d5fa>] handle_pte_fault+0x70a/0xa90
 [<ffffffff81101875>] ? __free_pages+0x35/0x40
 [<ffffffff8111dd93>] handle_mm_fault+0x253/0x380
 [<ffffffff8155285e>] do_page_fault+0x18e/0x520
 [<ffffffff812693de>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff810dff0f>] ? rcu_irq_exit+0x7f/0xd0
 [<ffffffff8154eb70>] ? retint_restore_args+0x13/0x13
 [<ffffffff8126941d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
 [<ffffffff8154ed85>] page_fault+0x25/0x30

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
