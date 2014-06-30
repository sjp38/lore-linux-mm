Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id B1F346B0035
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 19:56:40 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id v10so9038096pde.20
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 16:56:40 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id cc3si24894419pad.47.2014.06.30.16.56.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Jun 2014 16:56:39 -0700 (PDT)
Received: by mail-pa0-f47.google.com with SMTP id kq14so9479978pab.20
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 16:56:39 -0700 (PDT)
Date: Mon, 30 Jun 2014 16:55:10 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: mm: memcontrol: rewrite uncharge API: problems
Message-ID: <alpine.LSU.2.11.1406301558090.4572@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Hannes,

Your rewrite of the memcg charge/uncharge API is bold and attractive,
but I'm having some problems with the way release_pages() now does
uncharging in I/O completion context.

At the bottom see the lockdep message I get when I start shmem swapping.
Which I have not begun to attempt to decipher (over to you!), but I do
see release_pages() mentioned in there (also i915, hope it's irrelevant).

Which was already worrying me on the PowerPC G5, when moving tasks from
one memcg to another and removing the old, while swapping and swappingoff
(I haven't tried much else actually, maybe it's much easier to reproduce).

I get "unable to handle kernel paging at 0x180" oops in __raw_spinlock <
res_counter_uncharge_until < mem_cgroup_uncharge_end < release_pages <
free_pages_and_swap_cache < tlb_flush_mmu_free < tlb_finish_mmu <
unmap_region < do_munmap (or from exit_mmap < mmput < do_exit).

I do have CONFIG_MEMCG_SWAP=y, and I think 0x180 corresponds to the
memsw res_counter spinlock, if memcg is NULL.  I don't understand why
usually the PowerPC: I did see something like it once on this x86 laptop,
maybe having lockdep in on this slows things down enough not to hit that.

I've stopped those crashes with patch below: the memcg_batch uncharging
was never designed for use from interrupts.  But I bet it needs more work:
to disable interrupts, or do something clever with atomics, or... over to
you again.

As it stands, I think an interrupt in the wrong place risks leaking
charges (but actually I see the reverse - kernel/res_counter.c:28!
underflow warnings; though I don't know if it's merely that the patch
lets the machine stay up long enough to reach those, or causes them).

Not-really-Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/memcontrol.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

--- 3.16-rc2-mm1/mm/memcontrol.c	2014-06-25 18:43:59.856588121 -0700
+++ linux/mm/memcontrol.c	2014-06-29 21:45:03.896588350 -0700
@@ -3636,12 +3636,11 @@ void mem_cgroup_uncharge_end(void)
 	if (!batch->do_batch)
 		return;
 
-	batch->do_batch--;
-	if (batch->do_batch) /* If stacked, do nothing. */
-		return;
+	if (batch->do_batch > 1) /* If stacked, do nothing. */
+		goto out;
 
 	if (!batch->memcg)
-		return;
+		goto out;
 	/*
 	 * This "batch->memcg" is valid without any css_get/put etc...
 	 * bacause we hide charges behind us.
@@ -3655,6 +3654,8 @@ void mem_cgroup_uncharge_end(void)
 	memcg_oom_recover(batch->memcg);
 	/* forget this pointer (for sanity check) */
 	batch->memcg = NULL;
+out:
+	batch->do_batch--;
 }
 
 #ifdef CONFIG_MEMCG_SWAP

And here's lockdep's little fortune cookie:

======================================================
[ INFO: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected ]
3.16.0-rc2-mm1 #3 Not tainted
------------------------------------------------------
cc1/2771 [HC0[0]:SC0[0]:HE0:SE1] is trying to acquire:
 (&(&rtpz->lock)->rlock){+.+.-.}, at: [<ffffffff811518b5>] memcg_check_events+0x17e/0x206
dd
and this task is already holding:
 (&(&zone->lru_lock)->rlock){..-.-.}, at: [<ffffffff8110da3f>] release_pages+0xe7/0x239
which would create a new lock dependency:
 (&(&zone->lru_lock)->rlock){..-.-.} -> (&(&rtpz->lock)->rlock){+.+.-.}

but this new dependency connects a SOFTIRQ-irq-safe lock:
 (&(&zone->lru_lock)->rlock){..-.-.}
... which became SOFTIRQ-irq-safe at:
  [<ffffffff810c201e>] __lock_acquire+0x59f/0x17e8
  [<ffffffff810c38a6>] lock_acquire+0x61/0x78
  [<ffffffff815bdfbd>] _raw_spin_lock_irqsave+0x3f/0x51
  [<ffffffff8110dc0e>] pagevec_lru_move_fn+0x7d/0xf6
  [<ffffffff8110dca4>] pagevec_move_tail+0x1d/0x2c
  [<ffffffff8110e298>] rotate_reclaimable_page+0xb2/0xd4
  [<ffffffff811018bf>] end_page_writeback+0x1c/0x45
  [<ffffffff81134400>] end_swap_bio_write+0x5c/0x69
  [<ffffffff8123473e>] bio_endio+0x50/0x6e
  [<ffffffff81238dee>] blk_update_request+0x163/0x255
  [<ffffffff81238ef7>] blk_update_bidi_request+0x17/0x65
  [<ffffffff81239242>] blk_end_bidi_request+0x1a/0x56
  [<ffffffff81239289>] blk_end_request+0xb/0xd
  [<ffffffff813a075a>] scsi_io_completion+0x16d/0x553
  [<ffffffff81399c0f>] scsi_finish_command+0xb6/0xbf
  [<ffffffff813a0564>] scsi_softirq_done+0xe9/0xf0
  [<ffffffff8123e8e5>] blk_done_softirq+0x79/0x8b
  [<ffffffff81088675>] __do_softirq+0xfc/0x21f
  [<ffffffff8108898f>] irq_exit+0x3d/0x92
  [<ffffffff81032379>] do_IRQ+0xcc/0xe5
  [<ffffffff815bf5ac>] ret_from_intr+0x0/0x13
  [<ffffffff81443ac0>] cpuidle_enter+0x12/0x14
  [<ffffffff810bb4e4>] cpu_startup_entry+0x187/0x243
  [<ffffffff815a90ab>] rest_init+0x12f/0x133
  [<ffffffff81970e7c>] start_kernel+0x396/0x3a3
  [<ffffffff81970489>] x86_64_start_reservations+0x2a/0x2c
  [<ffffffff81970552>] x86_64_start_kernel+0xc7/0xca

to a SOFTIRQ-irq-unsafe lock:
 (&(&rtpz->lock)->rlock){+.+.-.}
... which became SOFTIRQ-irq-unsafe at:
...  [<ffffffff810c2095>] __lock_acquire+0x616/0x17e8
  [<ffffffff810c38a6>] lock_acquire+0x61/0x78
  [<ffffffff815bde9f>] _raw_spin_lock+0x34/0x41
  [<ffffffff811518b5>] memcg_check_events+0x17e/0x206
  [<ffffffff811535bb>] commit_charge+0x260/0x26f
  [<ffffffff81157004>] mem_cgroup_commit_charge+0xb1/0xdb
  [<ffffffff81115b51>] shmem_getpage_gfp+0x400/0x6c2
  [<ffffffff81115ecc>] shmem_write_begin+0x33/0x35
  [<ffffffff81102a24>] generic_perform_write+0xb7/0x1a4
  [<ffffffff8110391e>] __generic_file_write_iter+0x25b/0x29b
  [<ffffffff81103999>] generic_file_write_iter+0x3b/0xa5
  [<ffffffff8115a115>] new_sync_write+0x7b/0x9f
  [<ffffffff8115a56c>] vfs_write+0xb5/0x169
  [<ffffffff8115ae1f>] SyS_write+0x45/0x8c
  [<ffffffff815bead2>] system_call_fastpath+0x16/0x1b

other info that might help us debug this:

 Possible interrupt unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(&(&rtpz->lock)->rlock);
                               local_irq_disable();
                               lock(&(&zone->lru_lock)->rlock);
                               lock(&(&rtpz->lock)->rlock);
  <Interrupt>
    lock(&(&zone->lru_lock)->rlock);

 *** DEADLOCK ***

1 lock held by cc1/2771:
 #0:  (&(&zone->lru_lock)->rlock){..-.-.}, at: [<ffffffff8110da3f>] release_pages+0xe7/0x239

the dependencies between SOFTIRQ-irq-safe lock and the holding lock:
-> (&(&zone->lru_lock)->rlock){..-.-.} ops: 413812 {
   IN-SOFTIRQ-W at:
                    [<ffffffff810c201e>] __lock_acquire+0x59f/0x17e8
                    [<ffffffff810c38a6>] lock_acquire+0x61/0x78
                    [<ffffffff815bdfbd>] _raw_spin_lock_irqsave+0x3f/0x51
                    [<ffffffff8110dc0e>] pagevec_lru_move_fn+0x7d/0xf6
                    [<ffffffff8110dca4>] pagevec_move_tail+0x1d/0x2c
                    [<ffffffff8110e298>] rotate_reclaimable_page+0xb2/0xd4
                    [<ffffffff811018bf>] end_page_writeback+0x1c/0x45
                    [<ffffffff81134400>] end_swap_bio_write+0x5c/0x69
                    [<ffffffff8123473e>] bio_endio+0x50/0x6e
                    [<ffffffff81238dee>] blk_update_request+0x163/0x255
                    [<ffffffff81238ef7>] blk_update_bidi_request+0x17/0x65
                    [<ffffffff81239242>] blk_end_bidi_request+0x1a/0x56
                    [<ffffffff81239289>] blk_end_request+0xb/0xd
                    [<ffffffff813a075a>] scsi_io_completion+0x16d/0x553
                    [<ffffffff81399c0f>] scsi_finish_command+0xb6/0xbf
                    [<ffffffff813a0564>] scsi_softirq_done+0xe9/0xf0
                    [<ffffffff8123e8e5>] blk_done_softirq+0x79/0x8b
                    [<ffffffff81088675>] __do_softirq+0xfc/0x21f
                    [<ffffffff8108898f>] irq_exit+0x3d/0x92
                    [<ffffffff81032379>] do_IRQ+0xcc/0xe5
                    [<ffffffff815bf5ac>] ret_from_intr+0x0/0x13
                    [<ffffffff81443ac0>] cpuidle_enter+0x12/0x14
                    [<ffffffff810bb4e4>] cpu_startup_entry+0x187/0x243
                    [<ffffffff815a90ab>] rest_init+0x12f/0x133
                    [<ffffffff81970e7c>] start_kernel+0x396/0x3a3
                    [<ffffffff81970489>] x86_64_start_reservations+0x2a/0x2c
                    [<ffffffff81970552>] x86_64_start_kernel+0xc7/0xca
   IN-RECLAIM_FS-W at:
                       [<ffffffff810c20c3>] __lock_acquire+0x644/0x17e8
                       [<ffffffff810c38a6>] lock_acquire+0x61/0x78
                       [<ffffffff815bdfbd>] _raw_spin_lock_irqsave+0x3f/0x51
                       [<ffffffff8110dc0e>] pagevec_lru_move_fn+0x7d/0xf6
                       [<ffffffff8110dca4>] pagevec_move_tail+0x1d/0x2c
                       [<ffffffff8110e66d>] lru_add_drain_cpu+0x4d/0xb3
                       [<ffffffff8110e783>] lru_add_drain+0x1a/0x37
                       [<ffffffff81111b95>] shrink_active_list+0x62/0x2cb
                       [<ffffffff81112eaa>] balance_pgdat+0x156/0x503
                       [<ffffffff8111355e>] kswapd+0x307/0x341
                       [<ffffffff810a1923>] kthread+0xf1/0xf9
                       [<ffffffff815bea2c>] ret_from_fork+0x7c/0xb0
   INITIAL USE at:
                   [<ffffffff810c20db>] __lock_acquire+0x65c/0x17e8
                   [<ffffffff810c38a6>] lock_acquire+0x61/0x78
                   [<ffffffff815bdfbd>] _raw_spin_lock_irqsave+0x3f/0x51
                   [<ffffffff8110dc0e>] pagevec_lru_move_fn+0x7d/0xf6
                   [<ffffffff8110dcc5>] __pagevec_lru_add+0x12/0x14
                   [<ffffffff8110dd37>] __lru_cache_add+0x70/0x9f
                   [<ffffffff8110e44e>] lru_cache_add_anon+0x14/0x16
                   [<ffffffff81115b5a>] shmem_getpage_gfp+0x409/0x6c2
                   [<ffffffff81115fcb>] shmem_read_mapping_page_gfp+0x2e/0x49
                   [<ffffffff8133168f>] i915_gem_object_get_pages_gtt+0xe5/0x3f9
                   [<ffffffff8132d66e>] i915_gem_object_get_pages+0x64/0x8f
                   [<ffffffff81330eaa>] i915_gem_object_pin+0x2a0/0x5af
                   [<ffffffff813408fb>] intel_init_ring_buffer+0x2ba/0x3e6
                   [<ffffffff8134323a>] intel_init_render_ring_buffer+0x38b/0x3a6
                   [<ffffffff8132faae>] i915_gem_init_hw+0x127/0x2c6
                   [<ffffffff8132fd57>] i915_gem_init+0x10a/0x189
                   [<ffffffff81381d0c>] i915_driver_load+0xb1b/0xde7
                   [<ffffffff812fff60>] drm_dev_register+0x7f/0xf8
                   [<ffffffff81302185>] drm_get_pci_dev+0xf7/0x1b4
                   [<ffffffff81311d2f>] i915_pci_probe+0x40/0x49
                   [<ffffffff8127dddd>] local_pci_probe+0x1f/0x51
                   [<ffffffff8127ded5>] pci_device_probe+0xc6/0xec
                   [<ffffffff81389720>] driver_probe_device+0x99/0x1b9
                   [<ffffffff813898d4>] __driver_attach+0x5c/0x7e
                   [<ffffffff81387e7f>] bus_for_each_dev+0x55/0x89
                   [<ffffffff813893f6>] driver_attach+0x19/0x1b
                   [<ffffffff81388fb2>] bus_add_driver+0xec/0x1d3
                   [<ffffffff81389e21>] driver_register+0x89/0xc5
                   [<ffffffff8127d48f>] __pci_register_driver+0x58/0x5b
                   [<ffffffff8130229b>] drm_pci_init+0x59/0xda
                   [<ffffffff8199497f>] i915_init+0x89/0x90
                   [<ffffffff8100030e>] do_one_initcall+0xea/0x18c
                   [<ffffffff81970f8d>] kernel_init_freeable+0x104/0x196
                   [<ffffffff815a90b8>] kernel_init+0x9/0xd5
                   [<ffffffff815bea2c>] ret_from_fork+0x7c/0xb0
 }
 ... key      at: [<ffffffff8273c920>] __key.37664+0x0/0x8
 ... acquired at:
   [<ffffffff810c0f1b>] check_irq_usage+0x54/0xa8
   [<ffffffff810c2b50>] __lock_acquire+0x10d1/0x17e8
   [<ffffffff810c38a6>] lock_acquire+0x61/0x78
   [<ffffffff815bde9f>] _raw_spin_lock+0x34/0x41
   [<ffffffff811518b5>] memcg_check_events+0x17e/0x206
   [<ffffffff811571aa>] mem_cgroup_uncharge+0xf6/0x1c0
   [<ffffffff8110db2a>] release_pages+0x1d2/0x239
   [<ffffffff81134ea2>] free_pages_and_swap_cache+0x72/0x8c
   [<ffffffff8112136f>] tlb_flush_mmu_free+0x21/0x3c
   [<ffffffff81121d5d>] tlb_flush_mmu+0x1b/0x1e
   [<ffffffff81121d6f>] tlb_finish_mmu+0xf/0x34
   [<ffffffff8112a968>] exit_mmap+0xb5/0x117
   [<ffffffff81081a9d>] mmput+0x52/0xce
   [<ffffffff81086842>] do_exit+0x355/0x9b7
   [<ffffffff81086f46>] do_group_exit+0x76/0xb5
   [<ffffffff81086f94>] __wake_up_parent+0x0/0x23
   [<ffffffff815bead2>] system_call_fastpath+0x16/0x1b


the dependencies between the lock to be acquired and SOFTIRQ-irq-unsafe lock:
-> (&(&rtpz->lock)->rlock){+.+.-.} ops: 2348 {
   HARDIRQ-ON-W at:
                    [<ffffffff810c2073>] __lock_acquire+0x5f4/0x17e8
                    [<ffffffff810c38a6>] lock_acquire+0x61/0x78
                    [<ffffffff815bde9f>] _raw_spin_lock+0x34/0x41
                    [<ffffffff811518b5>] memcg_check_events+0x17e/0x206
                    [<ffffffff811535bb>] commit_charge+0x260/0x26f
                    [<ffffffff81157004>] mem_cgroup_commit_charge+0xb1/0xdb
                    [<ffffffff81115b51>] shmem_getpage_gfp+0x400/0x6c2
                    [<ffffffff81115ecc>] shmem_write_begin+0x33/0x35
                    [<ffffffff81102a24>] generic_perform_write+0xb7/0x1a4
                    [<ffffffff8110391e>] __generic_file_write_iter+0x25b/0x29b
                    [<ffffffff81103999>] generic_file_write_iter+0x3b/0xa5
                    [<ffffffff8115a115>] new_sync_write+0x7b/0x9f
                    [<ffffffff8115a56c>] vfs_write+0xb5/0x169
                    [<ffffffff8115ae1f>] SyS_write+0x45/0x8c
                    [<ffffffff815bead2>] system_call_fastpath+0x16/0x1b
   SOFTIRQ-ON-W at:
                    [<ffffffff810c2095>] __lock_acquire+0x616/0x17e8
                    [<ffffffff810c38a6>] lock_acquire+0x61/0x78
                    [<ffffffff815bde9f>] _raw_spin_lock+0x34/0x41
                    [<ffffffff811518b5>] memcg_check_events+0x17e/0x206
                    [<ffffffff811535bb>] commit_charge+0x260/0x26f
                    [<ffffffff81157004>] mem_cgroup_commit_charge+0xb1/0xdb
                    [<ffffffff81115b51>] shmem_getpage_gfp+0x400/0x6c2
                    [<ffffffff81115ecc>] shmem_write_begin+0x33/0x35
                    [<ffffffff81102a24>] generic_perform_write+0xb7/0x1a4
                    [<ffffffff8110391e>] __generic_file_write_iter+0x25b/0x29b
                    [<ffffffff81103999>] generic_file_write_iter+0x3b/0xa5
                    [<ffffffff8115a115>] new_sync_write+0x7b/0x9f
                    [<ffffffff8115a56c>] vfs_write+0xb5/0x169
                    [<ffffffff8115ae1f>] SyS_write+0x45/0x8c
                    [<ffffffff815bead2>] system_call_fastpath+0x16/0x1b
   IN-RECLAIM_FS-W at:
                       [<ffffffff810c20c3>] __lock_acquire+0x644/0x17e8
                       [<ffffffff810c38a6>] lock_acquire+0x61/0x78
                       [<ffffffff815bde9f>] _raw_spin_lock+0x34/0x41
                       [<ffffffff81156311>] mem_cgroup_soft_limit_reclaim+0x80/0x6b9
                       [<ffffffff81112fc2>] balance_pgdat+0x26e/0x503
                       [<ffffffff8111355e>] kswapd+0x307/0x341
                       [<ffffffff810a1923>] kthread+0xf1/0xf9
                       [<ffffffff815bea2c>] ret_from_fork+0x7c/0xb0
   INITIAL USE at:
                   [<ffffffff810c20db>] __lock_acquire+0x65c/0x17e8
                   [<ffffffff810c38a6>] lock_acquire+0x61/0x78
                   [<ffffffff815bde9f>] _raw_spin_lock+0x34/0x41
                   [<ffffffff811518b5>] memcg_check_events+0x17e/0x206
                   [<ffffffff811535bb>] commit_charge+0x260/0x26f
                   [<ffffffff81157004>] mem_cgroup_commit_charge+0xb1/0xdb
                   [<ffffffff81115b51>] shmem_getpage_gfp+0x400/0x6c2
                   [<ffffffff81115ecc>] shmem_write_begin+0x33/0x35
                   [<ffffffff81102a24>] generic_perform_write+0xb7/0x1a4
                   [<ffffffff8110391e>] __generic_file_write_iter+0x25b/0x29b
                   [<ffffffff81103999>] generic_file_write_iter+0x3b/0xa5
                   [<ffffffff8115a115>] new_sync_write+0x7b/0x9f
                   [<ffffffff8115a56c>] vfs_write+0xb5/0x169
                   [<ffffffff8115ae1f>] SyS_write+0x45/0x8c
                   [<ffffffff815bead2>] system_call_fastpath+0x16/0x1b
 }
 ... key      at: [<ffffffff82747bf0>] __key.49479+0x0/0x8
 ... acquired at:
   [<ffffffff810c0f1b>] check_irq_usage+0x54/0xa8
   [<ffffffff810c2b50>] __lock_acquire+0x10d1/0x17e8
   [<ffffffff810c38a6>] lock_acquire+0x61/0x78
   [<ffffffff815bde9f>] _raw_spin_lock+0x34/0x41
   [<ffffffff811518b5>] memcg_check_events+0x17e/0x206
   [<ffffffff811571aa>] mem_cgroup_uncharge+0xf6/0x1c0
   [<ffffffff8110db2a>] release_pages+0x1d2/0x239
   [<ffffffff81134ea2>] free_pages_and_swap_cache+0x72/0x8c
   [<ffffffff8112136f>] tlb_flush_mmu_free+0x21/0x3c
   [<ffffffff81121d5d>] tlb_flush_mmu+0x1b/0x1e
   [<ffffffff81121d6f>] tlb_finish_mmu+0xf/0x34
   [<ffffffff8112a968>] exit_mmap+0xb5/0x117
   [<ffffffff81081a9d>] mmput+0x52/0xce
   [<ffffffff81086842>] do_exit+0x355/0x9b7
   [<ffffffff81086f46>] do_group_exit+0x76/0xb5
   [<ffffffff81086f94>] __wake_up_parent+0x0/0x23
   [<ffffffff815bead2>] system_call_fastpath+0x16/0x1b


stack backtrace:
CPU: 1 PID: 2771 Comm: cc1 Not tainted 3.16.0-rc2-mm1 #3
Hardware name: LENOVO 4174EH1/4174EH1, BIOS 8CET51WW (1.31 ) 11/29/2011
 0000000000000000 ffff88000fe77a18 ffffffff815b2b2f ffff880004b09868
 ffff88000fe77b10 ffffffff810c0eb6 0000000000000000 ffff880000000000
 ffff880000000001 0000000400000006 ffffffff81811f22 ffff88000fe77a60
Call Trace:
 [<ffffffff815b2b2f>] dump_stack+0x4e/0x7a
 [<ffffffff810c0eb6>] check_usage+0x591/0x5a2
 [<ffffffff81156261>] ? mem_cgroup_bad_page_check+0x15/0x1d
 [<ffffffff810c1809>] ? trace_hardirqs_on+0xd/0xf
 [<ffffffff815be16f>] ? _raw_spin_unlock_irq+0x32/0x46
 [<ffffffff810c0f1b>] check_irq_usage+0x54/0xa8
 [<ffffffff810c2b50>] __lock_acquire+0x10d1/0x17e8
 [<ffffffff810c38a6>] lock_acquire+0x61/0x78
 [<ffffffff811518b5>] ? memcg_check_events+0x17e/0x206
 [<ffffffff815bde9f>] _raw_spin_lock+0x34/0x41
 [<ffffffff811518b5>] ? memcg_check_events+0x17e/0x206
 [<ffffffff811518b5>] memcg_check_events+0x17e/0x206
 [<ffffffff811571aa>] mem_cgroup_uncharge+0xf6/0x1c0
 [<ffffffff8110db2a>] release_pages+0x1d2/0x239
 [<ffffffff81134ea2>] free_pages_and_swap_cache+0x72/0x8c
 [<ffffffff8112136f>] tlb_flush_mmu_free+0x21/0x3c
 [<ffffffff81121d5d>] tlb_flush_mmu+0x1b/0x1e
 [<ffffffff81121d6f>] tlb_finish_mmu+0xf/0x34
 [<ffffffff8112a968>] exit_mmap+0xb5/0x117
 [<ffffffff81081a9d>] mmput+0x52/0xce
 [<ffffffff81086842>] do_exit+0x355/0x9b7
 [<ffffffff815bf64e>] ? retint_swapgs+0xe/0x13
 [<ffffffff81086f46>] do_group_exit+0x76/0xb5
 [<ffffffff81086f94>] SyS_exit_group+0xf/0xf
 [<ffffffff815bead2>] system_call_fastpath+0x16/0x1b

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
