Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id CEB356B02E1
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 07:22:31 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id n131so115030189oif.23
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 04:22:31 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e196si11916161oib.292.2017.04.25.04.22.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Apr 2017 04:22:30 -0700 (PDT)
Received: from fsav404.sakura.ne.jp (fsav404.sakura.ne.jp [133.242.250.103])
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id v3PBMQxn088025
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 20:22:26 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from AQUA (softbank126227147111.bbtec.net [126.227.147.111])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id v3PBMQGs088022
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 20:22:26 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Subject: A pitfall of mempool?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201704252022.DFB26076.FMOQVFOtJOSFHL@I-love.SAKURA.ne.jp>
Date: Tue, 25 Apr 2017 20:22:26 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Today's testing showed an interesting lockup.

xfs_alloc_ioend() from xfs_add_to_ioend() by wb_workfn() requested
bio_alloc_bioset(GFP_NOFS) and entered into too_many_isolated() loop
waiting for kswapd inside mempool_alloc(). But xfs_alloc_ioend() from
xfs_add_to_ioend() by kswapd() also entered into mempool_alloc() and
was waiting for somebody to return to memory pool which wb_workfn() was
also waiting for. The result was a silent hang up explained at
http://lkml.kernel.org/r/20170307133057.26182-1-mhocko@kernel.org .

But why there was no memory in the memory pool?
Memory pool does not guarantee at least one memory is available?
I hope memory pool guarantees it.

Then, there was a race window that both wb_workfn() and kswapd() looked
at memory pool and found that the pool was empty, and somebody returned
memory to the pool after wb_workfn() entered into __alloc_pages_nodemask() ?

Then, why kswapd() cannot find returned memory? I can't tell whether kswapd()
was making progress...

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20170425.txt.xz .
----------
[    0.000000] Linux version 4.11.0-rc7-next-20170424 (root@localhost.localdomain) (gcc version 6.2.1 20160916 (Red Hat 6.2.1-3) (GCC) ) #88 SMP Tue Apr 25 17:04:45 JST 2017
[    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-4.11.0-rc7-next-20170424 root=UUID=98df1583-260a-423a-a193-182dade5d085 ro crashkernel=256M security=none sysrq_always_enabled console=ttyS0,115200n8 console=tty0 LANG=en_US.UTF-8

[  279.056280] kswapd0         D12368    60      2 0x00000000
[  279.058541] Call Trace:
[  279.059888]  __schedule+0x403/0x940
[  279.061442]  schedule+0x3d/0x90
[  279.062903]  schedule_timeout+0x23b/0x510
[  279.064764]  ? init_timer_on_stack_key+0x60/0x60
[  279.066737]  io_schedule_timeout+0x1e/0x50
[  279.068505]  ? io_schedule_timeout+0x1e/0x50
[  279.070397]  mempool_alloc+0x162/0x190
[  279.072105]  ? remove_wait_queue+0x70/0x70
[  279.073872]  bvec_alloc+0x90/0xf0
[  279.075394]  bio_alloc_bioset+0x17b/0x230
[  279.077181]  xfs_add_to_ioend+0x7b/0x260 [xfs]
[  279.079109]  xfs_do_writepage+0x3d9/0x8f0 [xfs]
[  279.081056]  ? clear_page_dirty_for_io+0xab/0x2c0
[  279.083077]  xfs_vm_writepage+0x3b/0x70 [xfs]
[  279.085019]  pageout.isra.55+0x1a0/0x430
[  279.086755]  shrink_page_list+0xa5b/0xce0
[  279.088510]  shrink_inactive_list+0x1ba/0x590
[  279.090430]  ? __list_lru_count_one.isra.2+0x22/0x70
[  279.092528]  shrink_node_memcg+0x378/0x750
[  279.094356]  shrink_node+0xe1/0x310
[  279.095916]  ? shrink_node+0xe1/0x310
[  279.097566]  kswapd+0x3eb/0x9d0
[  279.099008]  kthread+0x117/0x150
[  279.100514]  ? mem_cgroup_shrink_node+0x350/0x350
[  279.102563]  ? kthread_create_on_node+0x70/0x70
[  279.104560]  ret_from_fork+0x31/0x40

[  281.159433] kworker/u128:29 D10424   381      2 0x00000000
[  281.161730] Workqueue: writeback wb_workfn (flush-8:0)
[  281.163867] Call Trace:
[  281.165100]  __schedule+0x403/0x940
[  281.166690]  schedule+0x3d/0x90
[  281.168143]  schedule_timeout+0x23b/0x510
[  281.169967]  ? init_timer_on_stack_key+0x60/0x60
[  281.171998]  io_schedule_timeout+0x1e/0x50
[  281.174004]  ? io_schedule_timeout+0x1e/0x50
[  281.176070]  congestion_wait+0x86/0x210
[  281.177765]  ? remove_wait_queue+0x70/0x70
[  281.179623]  shrink_inactive_list+0x45e/0x590
[  281.181514]  ? __list_lru_count_one.isra.2+0x22/0x70
[  281.183599]  shrink_node_memcg+0x378/0x750
[  281.185483]  ? lock_acquire+0xfb/0x200
[  281.187161]  ? mem_cgroup_iter+0xa1/0x570
[  281.188911]  shrink_node+0xe1/0x310
[  281.190569]  ? shrink_node+0xe1/0x310
[  281.192226]  do_try_to_free_pages+0xef/0x370
[  281.194116]  try_to_free_pages+0x12c/0x370
[  281.195896]  __alloc_pages_slowpath+0x4d4/0x1110
[  281.197885]  __alloc_pages_nodemask+0x2dd/0x390
[  281.199927]  alloc_pages_current+0xa1/0x1f0
[  281.201780]  new_slab+0x2dc/0x680
[  281.203279]  ? free_object+0x19/0xa0
[  281.204908]  ___slab_alloc+0x443/0x640
[  281.206709]  ? mempool_alloc_slab+0x1d/0x30
[  281.208986]  ? mempool_alloc_slab+0x1d/0x30
[  281.210867]  __slab_alloc+0x51/0x90
[  281.212450]  ? __slab_alloc+0x51/0x90
[  281.214126]  ? mempool_alloc_slab+0x1d/0x30
[  281.215919]  kmem_cache_alloc+0x283/0x350
[  281.217717]  ? trace_hardirqs_on+0xd/0x10
[  281.219505]  mempool_alloc_slab+0x1d/0x30
[  281.221238]  mempool_alloc+0x77/0x190
[  281.222879]  ? remove_wait_queue+0x70/0x70
[  281.224769]  bvec_alloc+0x90/0xf0
[  281.226260]  bio_alloc_bioset+0x17b/0x230
[  281.228055]  xfs_add_to_ioend+0x7b/0x260 [xfs]
[  281.230015]  xfs_do_writepage+0x3d9/0x8f0 [xfs]
[  281.231988]  write_cache_pages+0x230/0x680
[  281.233768]  ? xfs_add_to_ioend+0x260/0x260 [xfs]
[  281.235800]  ? xfs_vm_writepages+0x48/0xa0 [xfs]
[  281.237863]  xfs_vm_writepages+0x6b/0xa0 [xfs]
[  281.239856]  do_writepages+0x21/0x30
[  281.241733]  __writeback_single_inode+0x68/0x7f0
[  281.244117]  ? _raw_spin_unlock+0x27/0x40
[  281.245860]  writeback_sb_inodes+0x328/0x700
[  281.247758]  __writeback_inodes_wb+0x92/0xc0
[  281.249655]  wb_writeback+0x3c0/0x5f0
[  281.251263]  wb_workfn+0xaf/0x650
[  281.252777]  ? wb_workfn+0xaf/0x650
[  281.254371]  ? process_one_work+0x1c2/0x690
[  281.256163]  process_one_work+0x250/0x690
[  281.257939]  worker_thread+0x4e/0x3b0
[  281.259701]  kthread+0x117/0x150
[  281.261150]  ? process_one_work+0x690/0x690
[  281.263018]  ? kthread_create_on_node+0x70/0x70
[  281.265005]  ret_from_fork+0x31/0x40

[  430.018312] kswapd0         D12368    60      2 0x00000000
[  430.020792] Call Trace:
[  430.022061]  __schedule+0x403/0x940
[  430.023623]  schedule+0x3d/0x90
[  430.025093]  schedule_timeout+0x23b/0x510
[  430.026921]  ? init_timer_on_stack_key+0x60/0x60
[  430.028912]  io_schedule_timeout+0x1e/0x50
[  430.030687]  ? io_schedule_timeout+0x1e/0x50
[  430.032594]  mempool_alloc+0x162/0x190
[  430.034299]  ? remove_wait_queue+0x70/0x70
[  430.036070]  bvec_alloc+0x90/0xf0
[  430.037673]  bio_alloc_bioset+0x17b/0x230
[  430.039736]  xfs_add_to_ioend+0x7b/0x260 [xfs]
[  430.042116]  xfs_do_writepage+0x3d9/0x8f0 [xfs]
[  430.044225]  ? clear_page_dirty_for_io+0xab/0x2c0
[  430.046533]  xfs_vm_writepage+0x3b/0x70 [xfs]
[  430.048640]  pageout.isra.55+0x1a0/0x430
[  430.050712]  shrink_page_list+0xa5b/0xce0
[  430.052586]  shrink_inactive_list+0x1ba/0x590
[  430.054538]  ? __list_lru_count_one.isra.2+0x22/0x70
[  430.056713]  shrink_node_memcg+0x378/0x750
[  430.058511]  shrink_node+0xe1/0x310
[  430.060147]  ? shrink_node+0xe1/0x310
[  430.061997]  kswapd+0x3eb/0x9d0
[  430.063435]  kthread+0x117/0x150
[  430.065150]  ? mem_cgroup_shrink_node+0x350/0x350
[  430.067476]  ? kthread_create_on_node+0x70/0x70
[  430.069452]  ret_from_fork+0x31/0x40

[  431.716061] kworker/u128:29 D10424   381      2 0x00000000
[  431.718359] Workqueue: writeback wb_workfn (flush-8:0)
[  431.720536] Call Trace:
[  431.721777]  __schedule+0x403/0x940
[  431.723343]  schedule+0x3d/0x90
[  431.724791]  schedule_timeout+0x23b/0x510
[  431.726612]  ? init_timer_on_stack_key+0x60/0x60
[  431.728573]  io_schedule_timeout+0x1e/0x50
[  431.730391]  ? io_schedule_timeout+0x1e/0x50
[  431.732283]  congestion_wait+0x86/0x210
[  431.734016]  ? remove_wait_queue+0x70/0x70
[  431.735794]  shrink_inactive_list+0x45e/0x590
[  431.737711]  ? __list_lru_count_one.isra.2+0x22/0x70
[  431.739837]  shrink_node_memcg+0x378/0x750
[  431.741666]  ? lock_acquire+0xfb/0x200
[  431.743322]  ? mem_cgroup_iter+0xa1/0x570
[  431.745129]  shrink_node+0xe1/0x310
[  431.746752]  ? shrink_node+0xe1/0x310
[  431.748379]  do_try_to_free_pages+0xef/0x370
[  431.750263]  try_to_free_pages+0x12c/0x370
[  431.752144]  __alloc_pages_slowpath+0x4d4/0x1110
[  431.754108]  __alloc_pages_nodemask+0x2dd/0x390
[  431.756031]  alloc_pages_current+0xa1/0x1f0
[  431.757860]  new_slab+0x2dc/0x680
[  431.759457]  ? free_object+0x19/0xa0
[  431.761049]  ___slab_alloc+0x443/0x640
[  431.762844]  ? mempool_alloc_slab+0x1d/0x30
[  431.764687]  ? mempool_alloc_slab+0x1d/0x30
[  431.766646]  __slab_alloc+0x51/0x90
[  431.768213]  ? __slab_alloc+0x51/0x90
[  431.769851]  ? mempool_alloc_slab+0x1d/0x30
[  431.771673]  kmem_cache_alloc+0x283/0x350
[  431.773430]  ? trace_hardirqs_on+0xd/0x10
[  431.775217]  mempool_alloc_slab+0x1d/0x30
[  431.777001]  mempool_alloc+0x77/0x190
[  431.778615]  ? remove_wait_queue+0x70/0x70
[  431.780454]  bvec_alloc+0x90/0xf0
[  431.781995]  bio_alloc_bioset+0x17b/0x230
[  431.783804]  xfs_add_to_ioend+0x7b/0x260 [xfs]
[  431.785708]  xfs_do_writepage+0x3d9/0x8f0 [xfs]
[  431.787691]  write_cache_pages+0x230/0x680
[  431.789519]  ? xfs_add_to_ioend+0x260/0x260 [xfs]
[  431.791561]  ? xfs_vm_writepages+0x48/0xa0 [xfs]
[  431.793546]  xfs_vm_writepages+0x6b/0xa0 [xfs]
[  431.796642]  do_writepages+0x21/0x30
[  431.798244]  __writeback_single_inode+0x68/0x7f0
[  431.800236]  ? _raw_spin_unlock+0x27/0x40
[  431.802043]  writeback_sb_inodes+0x328/0x700
[  431.803873]  __writeback_inodes_wb+0x92/0xc0
[  431.805693]  wb_writeback+0x3c0/0x5f0
[  431.807327]  wb_workfn+0xaf/0x650
[  431.808854]  ? wb_workfn+0xaf/0x650
[  431.810397]  ? process_one_work+0x1c2/0x690
[  431.812210]  process_one_work+0x250/0x690
[  431.813957]  worker_thread+0x4e/0x3b0
[  431.815561]  kthread+0x117/0x150
[  431.817055]  ? process_one_work+0x690/0x690
[  431.818867]  ? kthread_create_on_node+0x70/0x70
[  431.820775]  ret_from_fork+0x31/0x40
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
