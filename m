Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8C3C06B0035
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 18:30:21 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id et14so13363122pad.27
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 15:30:21 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id zf6si31278670pab.226.2014.07.02.15.30.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Jul 2014 15:30:20 -0700 (PDT)
Received: by mail-pa0-f46.google.com with SMTP id eu11so13230593pac.19
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 15:30:19 -0700 (PDT)
Date: Wed, 2 Jul 2014 15:28:49 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: memcontrol: rewrite uncharge API: problems
In-Reply-To: <20140702212004.GF1369@cmpxchg.org>
Message-ID: <alpine.LSU.2.11.1407021518120.8299@eggly.anvils>
References: <alpine.LSU.2.11.1406301558090.4572@eggly.anvils> <20140701174612.GC1369@cmpxchg.org> <20140702212004.GF1369@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2 Jul 2014, Johannes Weiner wrote:
> On Tue, Jul 01, 2014 at 01:46:12PM -0400, Johannes Weiner wrote:
> > Hi Hugh,
> > 
> > On Mon, Jun 30, 2014 at 04:55:10PM -0700, Hugh Dickins wrote:
> > > Hi Hannes,
> > > 
> > > Your rewrite of the memcg charge/uncharge API is bold and attractive,
> > > but I'm having some problems with the way release_pages() now does
> > > uncharging in I/O completion context.
> > 
> > Yes, I need to make the uncharge path IRQ-safe.  This looks doable.
> > 
> > > At the bottom see the lockdep message I get when I start shmem swapping.
> > > Which I have not begun to attempt to decipher (over to you!), but I do
> > > see release_pages() mentioned in there (also i915, hope it's irrelevant).
> > 
> > This seems to be about uncharge acquiring the IRQ-unsafe soft limit
> > tree lock while the outer release_pages() holds the IRQ-safe lru_lock.
> > A separate issue, AFAICS, that would also be fixed by IRQ-proofing the
> > uncharge path.
> > 
> > > Which was already worrying me on the PowerPC G5, when moving tasks from
> > > one memcg to another and removing the old, while swapping and swappingoff
> > > (I haven't tried much else actually, maybe it's much easier to reproduce).
> > > 
> > > I get "unable to handle kernel paging at 0x180" oops in __raw_spinlock <
> > > res_counter_uncharge_until < mem_cgroup_uncharge_end < release_pages <
> > > free_pages_and_swap_cache < tlb_flush_mmu_free < tlb_finish_mmu <
> > > unmap_region < do_munmap (or from exit_mmap < mmput < do_exit).
> > > 
> > > I do have CONFIG_MEMCG_SWAP=y, and I think 0x180 corresponds to the
> > > memsw res_counter spinlock, if memcg is NULL.  I don't understand why
> > > usually the PowerPC: I did see something like it once on this x86 laptop,
> > > maybe having lockdep in on this slows things down enough not to hit that.
> > > 
> > > I've stopped those crashes with patch below: the memcg_batch uncharging
> > > was never designed for use from interrupts.  But I bet it needs more work:
> > > to disable interrupts, or do something clever with atomics, or... over to
> > > you again.
> > 
> > I was convinced I had tested these changes with lockdep enabled, but
> > it must have been at an earlier stage while developing the series.
> > Otherwise, I should have gotten the same splat as you report.
> 
> Turns out this was because the soft limit was not set in my tests, and
> without soft limit excess that spinlock is never acquired.  I could
> reproduce it now.
> 
> > Thanks for the report, I hope to have something useful ASAP.
> 
> Could you give the following patch a spin?  I put it in the mmots
> stack on top of mm-memcontrol-rewrite-charge-api-fix-shmem_unuse-fix.

I'm just with the laptop until this evening.  I slapped it on top of
my 3.16-rc2-mm1 plus fixes (but obviously minus my memcg_batch one
- which incidentally continues to run without crashing on the G5),
and it quickly gave me this lockdep splat, which doesn't look very
different from the one before.

I see there's now an -rc3-mm1, I'll try it out on that in half an
hour... but unless I send word otherwise, assume that's the same.

======================================================
[ INFO: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected ]
3.16.0-rc2-mm1 #6 Not tainted
------------------------------------------------------
cc1/1272 [HC0[0]:SC0[0]:HE0:SE1] is trying to acquire:
 (&(&rtpz->lock)->rlock){+.+.-.}, at: [<ffffffff81151a4c>] memcg_check_events+0x174/0x1fe

and this task is already holding:
 (&(&zone->lru_lock)->rlock){..-.-.}, at: [<ffffffff8110da3f>] release_pages+0xe7/0x239
which would create a new lock dependency:
 (&(&zone->lru_lock)->rlock){..-.-.} -> (&(&rtpz->lock)->rlock){+.+.-.}

but this new dependency connects a SOFTIRQ-irq-safe lock:
 (&(&zone->lru_lock)->rlock){..-.-.}
... which became SOFTIRQ-irq-safe at:
  [<ffffffff810c201e>] __lock_acquire+0x59f/0x17e8
  [<ffffffff810c38a6>] lock_acquire+0x61/0x78
  [<ffffffff815be1e5>] _raw_spin_lock_irqsave+0x3f/0x51
  [<ffffffff8110dc0e>] pagevec_lru_move_fn+0x7d/0xf6
  [<ffffffff8110dca4>] pagevec_move_tail+0x1d/0x2c
  [<ffffffff8110e298>] rotate_reclaimable_page+0xb2/0xd4
  [<ffffffff811018bf>] end_page_writeback+0x1c/0x45
  [<ffffffff81134594>] end_swap_bio_write+0x5c/0x69
  [<ffffffff81234952>] bio_endio+0x50/0x6e
  [<ffffffff81239002>] blk_update_request+0x163/0x255
  [<ffffffff8123910b>] blk_update_bidi_request+0x17/0x65
  [<ffffffff81239456>] blk_end_bidi_request+0x1a/0x56
  [<ffffffff8123949d>] blk_end_request+0xb/0xd
  [<ffffffff813a097a>] scsi_io_completion+0x16d/0x553
  [<ffffffff81399e2f>] scsi_finish_command+0xb6/0xbf
  [<ffffffff813a0784>] scsi_softirq_done+0xe9/0xf0
  [<ffffffff8123eaf9>] blk_done_softirq+0x79/0x8b
  [<ffffffff81088675>] __do_softirq+0xfc/0x21f
  [<ffffffff8108898f>] irq_exit+0x3d/0x92
  [<ffffffff81032379>] do_IRQ+0xcc/0xe5
  [<ffffffff815bf7ec>] ret_from_intr+0x0/0x13
  [<ffffffff81145e78>] cache_alloc_debugcheck_after.isra.51+0x26/0x1ad
  [<ffffffff81147011>] kmem_cache_alloc+0x11f/0x171
  [<ffffffff81234a42>] bvec_alloc+0xa7/0xc7
  [<ffffffff81234b55>] bio_alloc_bioset+0xf3/0x17d
  [<ffffffff811c3a7a>] ext4_bio_write_page+0x1e2/0x2c8
  [<ffffffff811bcd89>] mpage_submit_page+0x5c/0x72
  [<ffffffff811bd28c>] mpage_map_and_submit_buffers+0x1a5/0x215
  [<ffffffff811c11de>] ext4_writepages+0x9dc/0xa1f
  [<ffffffff8110c389>] do_writepages+0x1c/0x2a
  [<ffffffff8117d218>] __writeback_single_inode+0x3c/0xee
  [<ffffffff8117da90>] writeback_sb_inodes+0x1c6/0x30b
  [<ffffffff8117dc44>] __writeback_inodes_wb+0x6f/0xb3
  [<ffffffff8117df27>] wb_writeback+0x101/0x195
  [<ffffffff8117e37d>] bdi_writeback_workfn+0x87/0x2a1
  [<ffffffff8109b122>] process_one_work+0x221/0x3c5
  [<ffffffff8109bdd5>] worker_thread+0x2ec/0x3ef
  [<ffffffff810a1923>] kthread+0xf1/0xf9
  [<ffffffff815bec6c>] ret_from_fork+0x7c/0xb0

to a SOFTIRQ-irq-unsafe lock:
 (&(&rtpz->lock)->rlock){+.+.-.}
... which became SOFTIRQ-irq-unsafe at:
...  [<ffffffff810c2095>] __lock_acquire+0x616/0x17e8
  [<ffffffff810c38a6>] lock_acquire+0x61/0x78
  [<ffffffff815be0c7>] _raw_spin_lock+0x34/0x41
  [<ffffffff811566ca>] mem_cgroup_soft_limit_reclaim+0x260/0x6b9
  [<ffffffff81113012>] balance_pgdat+0x26e/0x503
  [<ffffffff811135ae>] kswapd+0x307/0x341
  [<ffffffff810a1923>] kthread+0xf1/0xf9
  [<ffffffff815bec6c>] ret_from_fork+0x7c/0xb0

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

1 lock held by cc1/1272:
 #0:  (&(&zone->lru_lock)->rlock){..-.-.}, at: [<ffffffff8110da3f>] release_pages+0xe7/0x239

the dependencies between SOFTIRQ-irq-safe lock and the holding lock:
-> (&(&zone->lru_lock)->rlock){..-.-.} ops: 125969 {
   IN-SOFTIRQ-W at:
                    [<ffffffff810c201e>] __lock_acquire+0x59f/0x17e8
                    [<ffffffff810c38a6>] lock_acquire+0x61/0x78
                    [<ffffffff815be1e5>] _raw_spin_lock_irqsave+0x3f/0x51
                    [<ffffffff8110dc0e>] pagevec_lru_move_fn+0x7d/0xf6
                    [<ffffffff8110dca4>] pagevec_move_tail+0x1d/0x2c
                    [<ffffffff8110e298>] rotate_reclaimable_page+0xb2/0xd4
                    [<ffffffff811018bf>] end_page_writeback+0x1c/0x45
                    [<ffffffff81134594>] end_swap_bio_write+0x5c/0x69
                    [<ffffffff81234952>] bio_endio+0x50/0x6e
                    [<ffffffff81239002>] blk_update_request+0x163/0x255
                    [<ffffffff8123910b>] blk_update_bidi_request+0x17/0x65
                    [<ffffffff81239456>] blk_end_bidi_request+0x1a/0x56
                    [<ffffffff8123949d>] blk_end_request+0xb/0xd
                    [<ffffffff813a097a>] scsi_io_completion+0x16d/0x553
                    [<ffffffff81399e2f>] scsi_finish_command+0xb6/0xbf
                    [<ffffffff813a0784>] scsi_softirq_done+0xe9/0xf0
                    [<ffffffff8123eaf9>] blk_done_softirq+0x79/0x8b
                    [<ffffffff81088675>] __do_softirq+0xfc/0x21f
                    [<ffffffff8108898f>] irq_exit+0x3d/0x92
                    [<ffffffff81032379>] do_IRQ+0xcc/0xe5
                    [<ffffffff815bf7ec>] ret_from_intr+0x0/0x13
                    [<ffffffff81145e78>] cache_alloc_debugcheck_after.isra.51+0x26/0x1ad
                    [<ffffffff81147011>] kmem_cache_alloc+0x11f/0x171
                    [<ffffffff81234a42>] bvec_alloc+0xa7/0xc7
                    [<ffffffff81234b55>] bio_alloc_bioset+0xf3/0x17d
                    [<ffffffff811c3a7a>] ext4_bio_write_page+0x1e2/0x2c8
                    [<ffffffff811bcd89>] mpage_submit_page+0x5c/0x72
                    [<ffffffff811bd28c>] mpage_map_and_submit_buffers+0x1a5/0x215
                    [<ffffffff811c11de>] ext4_writepages+0x9dc/0xa1f
                    [<ffffffff8110c389>] do_writepages+0x1c/0x2a
                    [<ffffffff8117d218>] __writeback_single_inode+0x3c/0xee
                    [<ffffffff8117da90>] writeback_sb_inodes+0x1c6/0x30b
                    [<ffffffff8117dc44>] __writeback_inodes_wb+0x6f/0xb3
                    [<ffffffff8117df27>] wb_writeback+0x101/0x195
                    [<ffffffff8117e37d>] bdi_writeback_workfn+0x87/0x2a1
                    [<ffffffff8109b122>] process_one_work+0x221/0x3c5
                    [<ffffffff8109bdd5>] worker_thread+0x2ec/0x3ef
                    [<ffffffff810a1923>] kthread+0xf1/0xf9
                    [<ffffffff815bec6c>] ret_from_fork+0x7c/0xb0
   IN-RECLAIM_FS-W at:
                       [<ffffffff810c20c3>] __lock_acquire+0x644/0x17e8
                       [<ffffffff810c38a6>] lock_acquire+0x61/0x78
                       [<ffffffff815be1e5>] _raw_spin_lock_irqsave+0x3f/0x51
                       [<ffffffff8110dc0e>] pagevec_lru_move_fn+0x7d/0xf6
                       [<ffffffff8110dcc5>] __pagevec_lru_add+0x12/0x14
                       [<ffffffff8110e648>] lru_add_drain_cpu+0x28/0xb3
                       [<ffffffff8110e783>] lru_add_drain+0x1a/0x37
                       [<ffffffff81111be5>] shrink_active_list+0x62/0x2cb
                       [<ffffffff81112efa>] balance_pgdat+0x156/0x503
                       [<ffffffff811135ae>] kswapd+0x307/0x341
                       [<ffffffff810a1923>] kthread+0xf1/0xf9
                       [<ffffffff815bec6c>] ret_from_fork+0x7c/0xb0
   INITIAL USE at:
                   [<ffffffff810c20db>] __lock_acquire+0x65c/0x17e8
                   [<ffffffff810c38a6>] lock_acquire+0x61/0x78
                   [<ffffffff815be1e5>] _raw_spin_lock_irqsave+0x3f/0x51
                   [<ffffffff8110dc0e>] pagevec_lru_move_fn+0x7d/0xf6
                   [<ffffffff8110dcc5>] __pagevec_lru_add+0x12/0x14
                   [<ffffffff8110dd37>] __lru_cache_add+0x70/0x9f
                   [<ffffffff8110e44e>] lru_cache_add_anon+0x14/0x16
                   [<ffffffff81115b5c>] shmem_getpage_gfp+0x3be/0x68a
                   [<ffffffff81115f25>] shmem_read_mapping_page_gfp+0x2e/0x49
                   [<ffffffff813318af>] i915_gem_object_get_pages_gtt+0xe5/0x3f9
                   [<ffffffff8132d88e>] i915_gem_object_get_pages+0x64/0x8f
                   [<ffffffff813310ca>] i915_gem_object_pin+0x2a0/0x5af
                   [<ffffffff81340b1b>] intel_init_ring_buffer+0x2ba/0x3e6
                   [<ffffffff8134345a>] intel_init_render_ring_buffer+0x38b/0x3a6
                   [<ffffffff8132fcce>] i915_gem_init_hw+0x127/0x2c6
                   [<ffffffff8132ff77>] i915_gem_init+0x10a/0x189
                   [<ffffffff81381f2c>] i915_driver_load+0xb1b/0xde7
                   [<ffffffff81300180>] drm_dev_register+0x7f/0xf8
                   [<ffffffff813023a5>] drm_get_pci_dev+0xf7/0x1b4
                   [<ffffffff81311f4f>] i915_pci_probe+0x40/0x49
                   [<ffffffff8127dffd>] local_pci_probe+0x1f/0x51
                   [<ffffffff8127e0f5>] pci_device_probe+0xc6/0xec
                   [<ffffffff81389940>] driver_probe_device+0x99/0x1b9
                   [<ffffffff81389af4>] __driver_attach+0x5c/0x7e
                   [<ffffffff8138809f>] bus_for_each_dev+0x55/0x89
                   [<ffffffff81389616>] driver_attach+0x19/0x1b
                   [<ffffffff813891d2>] bus_add_driver+0xec/0x1d3
                   [<ffffffff8138a041>] driver_register+0x89/0xc5
                   [<ffffffff8127d6af>] __pci_register_driver+0x58/0x5b
                   [<ffffffff813024bb>] drm_pci_init+0x59/0xda
                   [<ffffffff8199497f>] i915_init+0x89/0x90
                   [<ffffffff8100030e>] do_one_initcall+0xea/0x18c
                   [<ffffffff81970f8d>] kernel_init_freeable+0x104/0x196
                   [<ffffffff815a92d8>] kernel_init+0x9/0xd5
                   [<ffffffff815bec6c>] ret_from_fork+0x7c/0xb0
 }
 ... key      at: [<ffffffff8273c920>] __key.37664+0x0/0x8
 ... acquired at:
   [<ffffffff810c0f1b>] check_irq_usage+0x54/0xa8
   [<ffffffff810c2b50>] __lock_acquire+0x10d1/0x17e8
   [<ffffffff810c38a6>] lock_acquire+0x61/0x78
   [<ffffffff815be1e5>] _raw_spin_lock_irqsave+0x3f/0x51
   [<ffffffff81151a4c>] memcg_check_events+0x174/0x1fe
   [<ffffffff81157384>] mem_cgroup_uncharge+0xfa/0x1fc
   [<ffffffff8110db2a>] release_pages+0x1d2/0x239
   [<ffffffff81135036>] free_pages_and_swap_cache+0x72/0x8c
   [<ffffffff81121503>] tlb_flush_mmu_free+0x21/0x3c
   [<ffffffff81121ef1>] tlb_flush_mmu+0x1b/0x1e
   [<ffffffff81121f03>] tlb_finish_mmu+0xf/0x34
   [<ffffffff8112aafc>] exit_mmap+0xb5/0x117
   [<ffffffff81081a9d>] mmput+0x52/0xce
   [<ffffffff81086842>] do_exit+0x355/0x9b7
   [<ffffffff81086f46>] do_group_exit+0x76/0xb5
   [<ffffffff81086f94>] __wake_up_parent+0x0/0x23
   [<ffffffff815bed12>] system_call_fastpath+0x16/0x1b


the dependencies between the lock to be acquired and SOFTIRQ-irq-unsafe lock:
-> (&(&rtpz->lock)->rlock){+.+.-.} ops: 857 {
   HARDIRQ-ON-W at:
                    [<ffffffff810c2073>] __lock_acquire+0x5f4/0x17e8
                    [<ffffffff810c38a6>] lock_acquire+0x61/0x78
                    [<ffffffff815be0c7>] _raw_spin_lock+0x34/0x41
                    [<ffffffff811566ca>] mem_cgroup_soft_limit_reclaim+0x260/0x6b9
                    [<ffffffff81113012>] balance_pgdat+0x26e/0x503
                    [<ffffffff811135ae>] kswapd+0x307/0x341
                    [<ffffffff810a1923>] kthread+0xf1/0xf9
                    [<ffffffff815bec6c>] ret_from_fork+0x7c/0xb0
   SOFTIRQ-ON-W at:
                    [<ffffffff810c2095>] __lock_acquire+0x616/0x17e8
                    [<ffffffff810c38a6>] lock_acquire+0x61/0x78
                    [<ffffffff815be0c7>] _raw_spin_lock+0x34/0x41
                    [<ffffffff811566ca>] mem_cgroup_soft_limit_reclaim+0x260/0x6b9
                    [<ffffffff81113012>] balance_pgdat+0x26e/0x503
                    [<ffffffff811135ae>] kswapd+0x307/0x341
                    [<ffffffff810a1923>] kthread+0xf1/0xf9
                    [<ffffffff815bec6c>] ret_from_fork+0x7c/0xb0
   IN-RECLAIM_FS-W at:
                       [<ffffffff810c20c3>] __lock_acquire+0x644/0x17e8
                       [<ffffffff810c38a6>] lock_acquire+0x61/0x78
                       [<ffffffff815be231>] _raw_spin_lock_irq+0x3a/0x47
                       [<ffffffff811564ea>] mem_cgroup_soft_limit_reclaim+0x80/0x6b9
                       [<ffffffff81113012>] balance_pgdat+0x26e/0x503
                       [<ffffffff811135ae>] kswapd+0x307/0x341
                       [<ffffffff810a1923>] kthread+0xf1/0xf9
                       [<ffffffff815bec6c>] ret_from_fork+0x7c/0xb0
   INITIAL USE at:
                   [<ffffffff810c20db>] __lock_acquire+0x65c/0x17e8
                   [<ffffffff810c38a6>] lock_acquire+0x61/0x78
                   [<ffffffff815be1e5>] _raw_spin_lock_irqsave+0x3f/0x51
                   [<ffffffff81151a4c>] memcg_check_events+0x174/0x1fe
                   [<ffffffff81153756>] commit_charge+0x260/0x26f
                   [<ffffffff811571da>] mem_cgroup_commit_charge+0xb1/0xdb
                   [<ffffffff81101535>] __add_to_page_cache_locked+0x205/0x23d
                   [<ffffffff8110159b>] add_to_page_cache_lru+0x20/0x63
                   [<ffffffff8118bbf5>] mpage_readpages+0x8c/0xfa
                   [<ffffffff811bccbb>] ext4_readpages+0x37/0x3e
                   [<ffffffff8110c95d>] __do_page_cache_readahead+0x1fa/0x27d
                   [<ffffffff8110cd5b>] ondemand_readahead+0x37b/0x38c
                   [<ffffffff8110ceaf>] page_cache_sync_readahead+0x38/0x3a
                   [<ffffffff811031d0>] generic_file_read_iter+0x1bd/0x588
                   [<ffffffff8115a28a>] new_sync_read+0x78/0x9c
                   [<ffffffff8115a630>] vfs_read+0x89/0x124
                   [<ffffffff8115afa7>] SyS_read+0x45/0x8c
                   [<ffffffff815bed12>] system_call_fastpath+0x16/0x1b
 }
 ... key      at: [<ffffffff82747bf0>] __key.49550+0x0/0x8
 ... acquired at:
   [<ffffffff810c0f1b>] check_irq_usage+0x54/0xa8
   [<ffffffff810c2b50>] __lock_acquire+0x10d1/0x17e8
   [<ffffffff810c38a6>] lock_acquire+0x61/0x78
   [<ffffffff815be1e5>] _raw_spin_lock_irqsave+0x3f/0x51
   [<ffffffff81151a4c>] memcg_check_events+0x174/0x1fe
   [<ffffffff81157384>] mem_cgroup_uncharge+0xfa/0x1fc
   [<ffffffff8110db2a>] release_pages+0x1d2/0x239
   [<ffffffff81135036>] free_pages_and_swap_cache+0x72/0x8c
   [<ffffffff81121503>] tlb_flush_mmu_free+0x21/0x3c
   [<ffffffff81121ef1>] tlb_flush_mmu+0x1b/0x1e
   [<ffffffff81121f03>] tlb_finish_mmu+0xf/0x34
   [<ffffffff8112aafc>] exit_mmap+0xb5/0x117
   [<ffffffff81081a9d>] mmput+0x52/0xce
   [<ffffffff81086842>] do_exit+0x355/0x9b7
   [<ffffffff81086f46>] do_group_exit+0x76/0xb5
   [<ffffffff81086f94>] __wake_up_parent+0x0/0x23
   [<ffffffff815bed12>] system_call_fastpath+0x16/0x1b


stack backtrace:
CPU: 0 PID: 1272 Comm: cc1 Not tainted 3.16.0-rc2-mm1 #6
Hardware name: LENOVO 4174EH1/4174EH1, BIOS 8CET51WW (1.31 ) 11/29/2011
 0000000000000000 ffff8800108f3a08 ffffffff815b2d51 ffff8800100f1268
 ffff8800108f3b00 ffffffff810c0eb6 0000000000000000 ffff880000000000
 ffffffff00000001 0000000400000006 ffffffff81811f0a ffff8800108f3a50
Call Trace:
 [<ffffffff815b2d51>] dump_stack+0x4e/0x7a
 [<ffffffff810c0eb6>] check_usage+0x591/0x5a2
 [<ffffffff81151317>] ? lookup_page_cgroup_used+0x9/0x19
 [<ffffffff810c0f1b>] check_irq_usage+0x54/0xa8
 [<ffffffff810c2b50>] __lock_acquire+0x10d1/0x17e8
 [<ffffffff810c38a6>] lock_acquire+0x61/0x78
 [<ffffffff81151a4c>] ? memcg_check_events+0x174/0x1fe
 [<ffffffff815be1e5>] _raw_spin_lock_irqsave+0x3f/0x51
 [<ffffffff81151a4c>] ? memcg_check_events+0x174/0x1fe
 [<ffffffff81151a4c>] memcg_check_events+0x174/0x1fe
 [<ffffffff81157384>] mem_cgroup_uncharge+0xfa/0x1fc
 [<ffffffff8110da3f>] ? release_pages+0xe7/0x239
 [<ffffffff8110db2a>] release_pages+0x1d2/0x239
 [<ffffffff81135036>] free_pages_and_swap_cache+0x72/0x8c
 [<ffffffff81121503>] tlb_flush_mmu_free+0x21/0x3c
 [<ffffffff81121ef1>] tlb_flush_mmu+0x1b/0x1e
 [<ffffffff81121f03>] tlb_finish_mmu+0xf/0x34
 [<ffffffff8112aafc>] exit_mmap+0xb5/0x117
 [<ffffffff81081a9d>] mmput+0x52/0xce
 [<ffffffff81086842>] do_exit+0x355/0x9b7
 [<ffffffff815bf88e>] ? retint_swapgs+0xe/0x13
 [<ffffffff81086f46>] do_group_exit+0x76/0xb5
 [<ffffffff81086f94>] SyS_exit_group+0xf/0xf
 [<ffffffff815bed12>] system_call_fastpath+0x16/0x1b

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
