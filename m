Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id BFD846B0035
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 22:50:57 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id z10so1192409pdj.33
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 19:50:57 -0800 (PST)
Received: from mail-pb0-x234.google.com (mail-pb0-x234.google.com [2607:f8b0:400e:c01::234])
        by mx.google.com with ESMTPS id xf4si31316867pab.220.2014.02.05.19.50.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Feb 2014 19:50:56 -0800 (PST)
Received: by mail-pb0-f52.google.com with SMTP id jt11so1231000pbb.25
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 19:50:55 -0800 (PST)
Date: Wed, 5 Feb 2014 19:50:10 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: mmotm 2014-02-05 list_lru_add lockdep splat
Message-ID: <alpine.LSU.2.11.1402051944210.27326@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

======================================================
[ INFO: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected ]
3.14.0-rc1-mm1 #1 Not tainted
------------------------------------------------------
kswapd0/48 [HC0[0]:SC0[0]:HE0:SE1] is trying to acquire:
 (&(&lru->node[i].lock)->rlock){+.+.-.}, at: [<ffffffff81117064>] list_lru_add+0x80/0xf4

s already holding:
 (&(&mapping->tree_lock)->rlock){..-.-.}, at: [<ffffffff81108c63>] __remove_mapping+0x3b/0x12d
which would create a new lock dependency:
 (&(&mapping->tree_lock)->rlock){..-.-.} -> (&(&lru->node[i].lock)->rlock){+.+.-.}

pendency connects a SOFTIRQ-irq-safe lock:
 (&(&mapping->tree_lock)->rlock){..-.-.}
e SOFTIRQ-irq-safe at:
  [<ffffffff810bd9ea>] __lock_acquire+0x589/0x954
  [<ffffffff810be3f4>] lock_acquire+0x61/0x78
  [<ffffffff8159a015>] _raw_spin_lock_irqsave+0x3f/0x51
  [<ffffffff81105649>] test_clear_page_writeback+0x96/0x2a5
  [<ffffffff810fab96>] end_page_writeback+0x17/0x41
  [<ffffffff8117ac39>] end_buffer_async_write+0x12a/0x1aa
  [<ffffffff8117bc75>] end_bio_bh_io_sync+0x31/0x3c
  [<ffffffff8117f693>] bio_endio+0x50/0x6e
  [<ffffffff8122f398>] blk_update_request+0x16c/0x2fe
  [<ffffffff8122f541>] blk_update_bidi_request+0x17/0x65
  [<ffffffff8122f889>] blk_end_bidi_request+0x1a/0x56
  [<ffffffff8122f8d0>] blk_end_request+0xb/0xd
  [<ffffffff81384540>] scsi_io_completion+0x16f/0x474
  [<ffffffff8137ddb4>] scsi_finish_command+0xb6/0xbf
  [<ffffffff81384332>] scsi_softirq_done+0xe9/0xf0
  [<ffffffff81235239>] blk_done_softirq+0x79/0x8b
  [<ffffffff810833aa>] __do_softirq+0xf7/0x213
  [<ffffffff810836bd>] irq_exit+0x3d/0x92
  [<ffffffff810317d4>] do_IRQ+0xb3/0xcc
  [<ffffffff8159aaac>] ret_from_intr+0x0/0x13
  [<ffffffff810a31e8>] __might_sleep+0x71/0x198
  [<ffffffff815997ff>] console_conditional_schedule+0x20/0x27
  [<ffffffff812863b0>] fbcon_redraw.isra.20+0xee/0x15c
  [<ffffffff81286a3a>] fbcon_scroll+0x61c/0xba3
  [<ffffffff812d4a36>] scrup+0xc5/0xe0
  [<ffffffff812d4a7a>] lf+0x29/0x61
  [<ffffffff812d7409>] do_con_trol+0x162/0x129d
  [<ffffffff812d8cab>] do_con_write+0x767/0x7f4
  [<ffffffff812d8d72>] con_write+0xe/0x20
  [<ffffffff812c652d>] do_output_char+0x8b/0x1a6
  [<ffffffff812c71e5>] n_tty_write+0x2ab/0x3c8
  [<ffffffff812c3fe9>] tty_write+0x1a9/0x241
  [<ffffffff812c4109>] redirected_tty_write+0x88/0x91
  [<ffffffff81152702>] do_loop_readv_writev+0x43/0x72
  [<ffffffff81153840>] do_readv_writev+0xf7/0x1be
  [<ffffffff8115397c>] vfs_writev+0x32/0x46
  [<ffffffff81153a4d>] SyS_writev+0x44/0x78
  [<ffffffff8159b2e2>] system_call_fastpath+0x16/0x1b

q-unsafe lock:
 (&(&lru->node[i].lock)->rlock){+.+.-.}
e SOFTIRQ-irq-unsafe at:
...  [<ffffffff810bda61>] __lock_acquire+0x600/0x954
  [<ffffffff810be3f4>] lock_acquire+0x61/0x78
  [<ffffffff81599ef7>] _raw_spin_lock+0x34/0x41
  [<ffffffff81117064>] list_lru_add+0x80/0xf4
  [<ffffffff811652c4>] dput+0xb8/0x107
  [<ffffffff8115acfb>] path_put+0x11/0x1c
  [<ffffffff8115f6f3>] path_openat+0x4eb/0x58c
  [<ffffffff81160440>] do_filp_open+0x35/0x7a
  [<ffffffff811570f4>] open_exec+0x36/0xd7
  [<ffffffff81158b28>] do_execve_common.isra.33+0x280/0x6b4
  [<ffffffff81158f6f>] do_execve+0x13/0x15
  [<ffffffff810001ec>] try_to_run_init_process+0x24/0x49
  [<ffffffff81584e8b>] kernel_init+0xb9/0xff
  [<ffffffff8159b23c>] ret_from_fork+0x7c/0xb0

 might help us debug this:

 Possible interrupt unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(&(&lru->node[i].lock)->rlock);
                               local_irq_disable();
                               lock(&(&mapping->tree_lock)->rlock);
                               lock(&(&lru->node[i].lock)->rlock);
  <Interrupt>
    lock(&(&mapping->tree_lock)->rlock);

**

1 lock held by kswapd0/48:
 #0:  (&(&mapping->tree_lock)->rlock){..-.-.}, at: [<ffffffff81108c63>] __remove_mapping+0x3b/0x12d

s between SOFTIRQ-irq-safe lock and the holding lock:
-> (&(&mapping->tree_lock)->rlock){..-.-.} ops: 139535 {
   IN-SOFTIRQ-W at:
                    [<ffffffff810bd9ea>] __lock_acquire+0x589/0x954
                    [<ffffffff810be3f4>] lock_acquire+0x61/0x78
                    [<ffffffff8159a015>] _raw_spin_lock_irqsave+0x3f/0x51
                    [<ffffffff81105649>] test_clear_page_writeback+0x96/0x2a5
                    [<ffffffff810fab96>] end_page_writeback+0x17/0x41
                    [<ffffffff8117ac39>] end_buffer_async_write+0x12a/0x1aa
                    [<ffffffff8117bc75>] end_bio_bh_io_sync+0x31/0x3c
                    [<ffffffff8117f693>] bio_endio+0x50/0x6e
                    [<ffffffff8122f398>] blk_update_request+0x16c/0x2fe
                    [<ffffffff8122f541>] blk_update_bidi_request+0x17/0x65
                    [<ffffffff8122f889>] blk_end_bidi_request+0x1a/0x56
                    [<ffffffff8122f8d0>] blk_end_request+0xb/0xd
                    [<ffffffff81384540>] scsi_io_completion+0x16f/0x474
                    [<ffffffff8137ddb4>] scsi_finish_command+0xb6/0xbf
                    [<ffffffff81384332>] scsi_softirq_done+0xe9/0xf0
                    [<ffffffff81235239>] blk_done_softirq+0x79/0x8b
                    [<ffffffff810833aa>] __do_softirq+0xf7/0x213
                    [<ffffffff810836bd>] irq_exit+0x3d/0x92
                    [<ffffffff810317d4>] do_IRQ+0xb3/0xcc
                    [<ffffffff8159aaac>] ret_from_intr+0x0/0x13
                    [<ffffffff810a31e8>] __might_sleep+0x71/0x198
                    [<ffffffff815997ff>] console_conditional_schedule+0x20/0x27
                    [<ffffffff812863b0>] fbcon_redraw.isra.20+0xee/0x15c
                    [<ffffffff81286a3a>] fbcon_scroll+0x61c/0xba3
                    [<ffffffff812d4a36>] scrup+0xc5/0xe0
                    [<ffffffff812d4a7a>] lf+0x29/0x61
                    [<ffffffff812d7409>] do_con_trol+0x162/0x129d
                    [<ffffffff812d8cab>] do_con_write+0x767/0x7f4
                    [<ffffffff812d8d72>] con_write+0xe/0x20
                    [<ffffffff812c652d>] do_output_char+0x8b/0x1a6
                    [<ffffffff812c71e5>] n_tty_write+0x2ab/0x3c8
                    [<ffffffff812c3fe9>] tty_write+0x1a9/0x241
                    [<ffffffff812c4109>] redirected_tty_write+0x88/0x91
                    [<ffffffff81152702>] do_loop_readv_writev+0x43/0x72
                    [<ffffffff81153840>] do_readv_writev+0xf7/0x1be
                    [<ffffffff8115397c>] vfs_writev+0x32/0x46
                    [<ffffffff81153a4d>] SyS_writev+0x44/0x78
                    [<ffffffff8159b2e2>] system_call_fastpath+0x16/0x1b
   IN-RECLAIM_FS-W at:
                       [<ffffffff810bda90>] __lock_acquire+0x62f/0x954
                       [<ffffffff810be3f4>] lock_acquire+0x61/0x78
                       [<ffffffff8159a061>] _raw_spin_lock_irq+0x3a/0x47
                       [<ffffffff81108c63>] __remove_mapping+0x3b/0x12d
                       [<ffffffff8110a1b8>] shrink_page_list+0x6e7/0x8db
                       [<ffffffff8110a9ca>] shrink_inactive_list+0x24e/0x391
                       [<ffffffff8110b1b6>] shrink_lruvec+0x3e3/0x589
                       [<ffffffff8110b3bb>] shrink_zone+0x5f/0x159
                       [<ffffffff8110c09a>] balance_pgdat+0x32c/0x4fd
                       [<ffffffff8110c56f>] kswapd+0x304/0x331
                       [<ffffffff8109c7b9>] kthread+0xf1/0xf9
                       [<ffffffff8159b23c>] ret_from_fork+0x7c/0xb0
   INITIAL USE at:
                   [<ffffffff810bdaa8>] __lock_acquire+0x647/0x954
                   [<ffffffff810be3f4>] lock_acquire+0x61/0x78
                   [<ffffffff8159a061>] _raw_spin_lock_irq+0x3a/0x47
                   [<ffffffff8110e6ba>] shmem_add_to_page_cache.isra.25+0x7f/0x102
                   [<ffffffff8110ea91>] shmem_getpage_gfp+0x354/0x658
                   [<ffffffff8110ef4d>] shmem_read_mapping_page_gfp+0x2e/0x49
                   [<ffffffff81313f78>] i915_gem_object_get_pages_gtt+0xe9/0x417
                   [<ffffffff813103e4>] i915_gem_object_get_pages+0x59/0x85
                   [<ffffffff8131389e>] i915_gem_object_pin+0x22f/0x4e0
                   [<ffffffff81316899>] i915_gem_create_context+0x208/0x404
                   [<ffffffff81316d5e>] i915_gem_context_init+0x12e/0x1f0
                   [<ffffffff8131241b>] i915_gem_init+0xdc/0x19a
                   [<ffffffff81304949>] i915_driver_load+0xa28/0xd38
                   [<ffffffff812f0890>] drm_dev_register+0xd2/0x14a
                   [<ffffffff812f29e8>] drm_get_pci_dev+0x104/0x1d4
                   [<ffffffff8130195e>] i915_pci_probe+0x40/0x49
                   [<ffffffff81271813>] local_pci_probe+0x1f/0x51
                   [<ffffffff8127190b>] pci_device_probe+0xc6/0xec
                   [<ffffffff8136e28b>] driver_probe_device+0x90/0x19b
                   [<ffffffff8136e42a>] __driver_attach+0x5c/0x7e
                   [<ffffffff8136c9b3>] bus_for_each_dev+0x55/0x89
                   [<ffffffff8136df3a>] driver_attach+0x19/0x1b
                   [<ffffffff8136dae6>] bus_add_driver+0xec/0x1d3
                   [<ffffffff8136e975>] driver_register+0x89/0xc5
                   [<ffffffff81270fe5>] __pci_register_driver+0x58/0x5b
                   [<ffffffff812f2b1c>] drm_pci_init+0x64/0xe8
                   [<ffffffff8194b5cf>] i915_init+0x6a/0x6c
                   [<ffffffff81000290>] do_one_initcall+0x7f/0x10b
                   [<ffffffff81927e5c>] kernel_init_freeable+0x104/0x196
                   [<ffffffff81584ddb>] kernel_init+0x9/0xff
                   [<ffffffff8159b23c>] ret_from_fork+0x7c/0xb0
 }
 ... key      at: [<ffffffff8226dd20>] __key.30540+0x0/0x8
 ... acquired at:
   [<ffffffff810bb9e7>] check_irq_usage+0x54/0xa8
   [<ffffffff810bc2b7>] validate_chain.isra.22+0x87c/0xe96
   [<ffffffff810bdcbf>] __lock_acquire+0x85e/0x954
   [<ffffffff810be3f4>] lock_acquire+0x61/0x78
   [<ffffffff81599ef7>] _raw_spin_lock+0x34/0x41
   [<ffffffff81117064>] list_lru_add+0x80/0xf4
   [<ffffffff810fbe92>] __delete_from_page_cache+0x122/0x1cc
   [<ffffffff81108d1c>] __remove_mapping+0xf4/0x12d
   [<ffffffff8110a1b8>] shrink_page_list+0x6e7/0x8db
   [<ffffffff8110a9ca>] shrink_inactive_list+0x24e/0x391
   [<ffffffff8110b1b6>] shrink_lruvec+0x3e3/0x589
   [<ffffffff8110b3bb>] shrink_zone+0x5f/0x159
   [<ffffffff8110c09a>] balance_pgdat+0x32c/0x4fd
   [<ffffffff8110c56f>] kswapd+0x304/0x331
   [<ffffffff8109c7b9>] kthread+0xf1/0xf9
   [<ffffffff8159b23c>] ret_from_fork+0x7c/0xb0


s between the lock to be acquired and SOFTIRQ-irq-unsafe lock:
-> (&(&lru->node[i].lock)->rlock){+.+.-.} ops: 13037 {
   HARDIRQ-ON-W at:
                    [<ffffffff810bda40>] __lock_acquire+0x5df/0x954
                    [<ffffffff810be3f4>] lock_acquire+0x61/0x78
                    [<ffffffff81599ef7>] _raw_spin_lock+0x34/0x41
                    [<ffffffff81117064>] list_lru_add+0x80/0xf4
                    [<ffffffff811652c4>] dput+0xb8/0x107
                    [<ffffffff8115acfb>] path_put+0x11/0x1c
                    [<ffffffff8115f6f3>] path_openat+0x4eb/0x58c
                    [<ffffffff81160440>] do_filp_open+0x35/0x7a
                    [<ffffffff811570f4>] open_exec+0x36/0xd7
                    [<ffffffff81158b28>] do_execve_common.isra.33+0x280/0x6b4
                    [<ffffffff81158f6f>] do_execve+0x13/0x15
                    [<ffffffff810001ec>] try_to_run_init_process+0x24/0x49
                    [<ffffffff81584e8b>] kernel_init+0xb9/0xff
                    [<ffffffff8159b23c>] ret_from_fork+0x7c/0xb0
   SOFTIRQ-ON-W at:
                    [<ffffffff810bda61>] __lock_acquire+0x600/0x954
                    [<ffffffff810be3f4>] lock_acquire+0x61/0x78
                    [<ffffffff81599ef7>] _raw_spin_lock+0x34/0x41
                    [<ffffffff81117064>] list_lru_add+0x80/0xf4
                    [<ffffffff811652c4>] dput+0xb8/0x107
                    [<ffffffff8115acfb>] path_put+0x11/0x1c
                    [<ffffffff8115f6f3>] path_openat+0x4eb/0x58c
                    [<ffffffff81160440>] do_filp_open+0x35/0x7a
                    [<ffffffff811570f4>] open_exec+0x36/0xd7
                    [<ffffffff81158b28>] do_execve_common.isra.33+0x280/0x6b4
                    [<ffffffff81158f6f>] do_execve+0x13/0x15
                    [<ffffffff810001ec>] try_to_run_init_process+0x24/0x49
                    [<ffffffff81584e8b>] kernel_init+0xb9/0xff
                    [<ffffffff8159b23c>] ret_from_fork+0x7c/0xb0
   IN-RECLAIM_FS-W at:
                       [<ffffffff810bda90>] __lock_acquire+0x62f/0x954
                       [<ffffffff810be3f4>] lock_acquire+0x61/0x78
                       [<ffffffff81599ef7>] _raw_spin_lock+0x34/0x41
                       [<ffffffff811170f1>] list_lru_count_node+0x19/0x55
                       [<ffffffff811558b3>] super_cache_count+0x5f/0xb5
                       [<ffffffff81108a35>] shrink_slab_node+0x40/0x171
                       [<ffffffff8110946e>] shrink_slab+0x76/0x134
                       [<ffffffff8110c0d1>] balance_pgdat+0x363/0x4fd
                       [<ffffffff8110c56f>] kswapd+0x304/0x331
                       [<ffffffff8109c7b9>] kthread+0xf1/0xf9
                       [<ffffffff8159b23c>] ret_from_fork+0x7c/0xb0
   INITIAL USE at:
                   [<ffffffff810bdaa8>] __lock_acquire+0x647/0x954
                   [<ffffffff810be3f4>] lock_acquire+0x61/0x78
                   [<ffffffff81599ef7>] _raw_spin_lock+0x34/0x41
                   [<ffffffff81117064>] list_lru_add+0x80/0xf4
                   [<ffffffff811652c4>] dput+0xb8/0x107
                   [<ffffffff8115acfb>] path_put+0x11/0x1c
                   [<ffffffff8115f6f3>] path_openat+0x4eb/0x58c
                   [<ffffffff81160440>] do_filp_open+0x35/0x7a
                   [<ffffffff811570f4>] open_exec+0x36/0xd7
                   [<ffffffff81158b28>] do_execve_common.isra.33+0x280/0x6b4
                   [<ffffffff81158f6f>] do_execve+0x13/0x15
                   [<ffffffff810001ec>] try_to_run_init_process+0x24/0x49
                   [<ffffffff81584e8b>] kernel_init+0xb9/0xff
                   [<ffffffff8159b23c>] ret_from_fork+0x7c/0xb0
 }
 ... key      at: [<ffffffff82260bf0>] __key.17506+0x0/0x10
 ... acquired at:
   [<ffffffff810bb9e7>] check_irq_usage+0x54/0xa8
   [<ffffffff810bc2b7>] validate_chain.isra.22+0x87c/0xe96
   [<ffffffff810bdcbf>] __lock_acquire+0x85e/0x954
   [<ffffffff810be3f4>] lock_acquire+0x61/0x78
   [<ffffffff81599ef7>] _raw_spin_lock+0x34/0x41
   [<ffffffff81117064>] list_lru_add+0x80/0xf4
   [<ffffffff810fbe92>] __delete_from_page_cache+0x122/0x1cc
   [<ffffffff81108d1c>] __remove_mapping+0xf4/0x12d
   [<ffffffff8110a1b8>] shrink_page_list+0x6e7/0x8db
   [<ffffffff8110a9ca>] shrink_inactive_list+0x24e/0x391
   [<ffffffff8110b1b6>] shrink_lruvec+0x3e3/0x589
   [<ffffffff8110b3bb>] shrink_zone+0x5f/0x159
   [<ffffffff8110c09a>] balance_pgdat+0x32c/0x4fd
   [<ffffffff8110c56f>] kswapd+0x304/0x331
   [<ffffffff8109c7b9>] kthread+0xf1/0xf9
   [<ffffffff8159b23c>] ret_from_fork+0x7c/0xb0


:
CPU: 3 PID: 48 Comm: kswapd0 Not tainted 3.14.0-rc1-mm1 #1
Hardware name: LENOVO 4174EH1/4174EH1, BIOS 8CET51WW (1.31 ) 11/29/2011
 0000000000000000 ffff880029e37688 ffffffff8158f143 ffff880029e39428
 ffff880029e37780 ffffffff810bb982 0000000000000000 0000000000000000
 ffff880000000001 0000000400000006 ffffffff817dac97 ffff880029e376d0
Call Trace:
 [<ffffffff8158f143>] dump_stack+0x4e/0x7a
 [<ffffffff810bb982>] check_usage+0x591/0x5a2
 [<ffffffff810bb9e7>] check_irq_usage+0x54/0xa8
 [<ffffffff810bc2b7>] validate_chain.isra.22+0x87c/0xe96
 [<ffffffff810bdcbf>] __lock_acquire+0x85e/0x954
 [<ffffffff810be3f4>] lock_acquire+0x61/0x78
 [<ffffffff81117064>] ? list_lru_add+0x80/0xf4
 [<ffffffff81599ef7>] _raw_spin_lock+0x34/0x41
 [<ffffffff81117064>] ? list_lru_add+0x80/0xf4
 [<ffffffff81117064>] list_lru_add+0x80/0xf4
 [<ffffffff810fbe92>] __delete_from_page_cache+0x122/0x1cc
 [<ffffffff81108d1c>] __remove_mapping+0xf4/0x12d
 [<ffffffff8110a1b8>] shrink_page_list+0x6e7/0x8db
 [<ffffffff810bd182>] ? trace_hardirqs_on_caller+0x142/0x19e
 [<ffffffff8110a9ca>] shrink_inactive_list+0x24e/0x391
 [<ffffffff8110b1b6>] shrink_lruvec+0x3e3/0x589
 [<ffffffff8110b3bb>] shrink_zone+0x5f/0x159
 [<ffffffff8110c09a>] balance_pgdat+0x32c/0x4fd
 [<ffffffff8110c56f>] kswapd+0x304/0x331
 [<ffffffff810b5e6b>] ? abort_exclusive_wait+0x84/0x84
 [<ffffffff8110c26b>] ? balance_pgdat+0x4fd/0x4fd
 [<ffffffff8109c7b9>] kthread+0xf1/0xf9
 [<ffffffff8159a1bc>] ? _raw_spin_unlock_irq+0x27/0x46
 [<ffffffff8109c6c8>] ? kthread_stop+0x5a/0x5a
 [<ffffffff8159b23c>] ret_from_fork+0x7c/0xb0
 [<ffffffff8109c6c8>] ? kthread_stop+0x5a/0x5a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
