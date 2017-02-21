Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 777376B03A9
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 09:37:13 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f21so117318982pgi.4
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 06:37:13 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y5si22035296pgi.411.2017.02.21.06.37.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Feb 2017 06:37:11 -0800 (PST)
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages per zone
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201701290027.AFB30799.FVtFLOOOJMSHQF@I-love.SAKURA.ne.jp>
	<20170130085546.GF8443@dhcp22.suse.cz>
	<20170202101415.GE22806@dhcp22.suse.cz>
	<201702031957.AGH86961.MLtOQVFOSHJFFO@I-love.SAKURA.ne.jp>
	<20170221094034.GF15595@dhcp22.suse.cz>
In-Reply-To: <20170221094034.GF15595@dhcp22.suse.cz>
Message-Id: <201702212335.DJB30777.JOFMHSFtVLQOOF@I-love.SAKURA.ne.jp>
Date: Tue, 21 Feb 2017 23:35:07 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: david@fromorbit.com, dchinner@redhat.com, hch@lst.de, mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> OK, so it seems that all the distractions are handled now and linux-next
> should provide a reasonable base for testing. You said you weren't able
> to reproduce the original long stalls on too_many_isolated(). I would be
> still interested to see those oom reports and potential anomalies in the
> isolated counts before I send the patch for inclusion so your further
> testing would be more than appreciated. Also stalls > 10s without any
> previous occurrences would be interesting.

I confirmed that linux-next-20170221 with kmallocwd applied can reproduce
infinite too_many_isolated() loop problem. Please send your patches to linux-next.

Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20170221.txt.xz .
----------------------------------------
[ 1160.162013] Out of memory: Kill process 7523 (a.out) score 998 or sacrifice child
[ 1160.164422] Killed process 7523 (a.out) total-vm:4168kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[ 1160.169699] oom_reaper: reaped process 7523 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 1209.781787] MemAlloc-Info: stalling=32 dying=1 exiting=0 victim=1 oom_count=45896
[ 1209.790966] MemAlloc: kswapd0(67) flags=0xa60840 switches=51139 uninterruptible
[ 1209.799726] kswapd0         D10936    67      2 0x00000000
[ 1209.807326] Call Trace:
[ 1209.812581]  __schedule+0x336/0xe00
[ 1209.818599]  schedule+0x3d/0x90
[ 1209.823907]  schedule_timeout+0x26a/0x510
[ 1209.827218]  ? trace_hardirqs_on+0xd/0x10
[ 1209.830535]  __down_common+0xfb/0x131
[ 1209.833801]  ? _xfs_buf_find+0x2cb/0xc10 [xfs]
[ 1209.837372]  __down+0x1d/0x1f
[ 1209.840331]  down+0x41/0x50
[ 1209.843243]  xfs_buf_lock+0x64/0x370 [xfs]
[ 1209.846597]  _xfs_buf_find+0x2cb/0xc10 [xfs]
[ 1209.850031]  ? _xfs_buf_find+0xa4/0xc10 [xfs]
[ 1209.853514]  xfs_buf_get_map+0x2a/0x480 [xfs]
[ 1209.855831]  xfs_buf_read_map+0x2c/0x400 [xfs]
[ 1209.857388]  ? free_debug_processing+0x27d/0x2af
[ 1209.859037]  xfs_trans_read_buf_map+0x186/0x830 [xfs]
[ 1209.860707]  xfs_read_agf+0xc8/0x2b0 [xfs]
[ 1209.862184]  xfs_alloc_read_agf+0x7a/0x300 [xfs]
[ 1209.863728]  ? xfs_alloc_space_available+0x7b/0x120 [xfs]
[ 1209.865385]  xfs_alloc_fix_freelist+0x3bc/0x490 [xfs]
[ 1209.866974]  ? __radix_tree_lookup+0x84/0xf0
[ 1209.868374]  ? xfs_perag_get+0x1a0/0x310 [xfs]
[ 1209.869798]  ? xfs_perag_get+0x5/0x310 [xfs]
[ 1209.871288]  xfs_alloc_vextent+0x161/0xda0 [xfs]
[ 1209.872757]  xfs_bmap_btalloc+0x46c/0x8b0 [xfs]
[ 1209.874182]  ? save_stack_trace+0x1b/0x20
[ 1209.875542]  xfs_bmap_alloc+0x17/0x30 [xfs]
[ 1209.876847]  xfs_bmapi_write+0x74e/0x11d0 [xfs]
[ 1209.878190]  xfs_iomap_write_allocate+0x199/0x3a0 [xfs]
[ 1209.879632]  xfs_map_blocks+0x2cc/0x5a0 [xfs]
[ 1209.880909]  xfs_do_writepage+0x215/0x920 [xfs]
[ 1209.882255]  ? clear_page_dirty_for_io+0xb4/0x310
[ 1209.883598]  xfs_vm_writepage+0x3b/0x70 [xfs]
[ 1209.884841]  pageout.isra.54+0x1a4/0x460
[ 1209.886210]  shrink_page_list+0xa86/0xcf0
[ 1209.887441]  shrink_inactive_list+0x1c5/0x660
[ 1209.888682]  shrink_node_memcg+0x535/0x7f0
[ 1209.889975]  ? mem_cgroup_iter+0x14d/0x720
[ 1209.891197]  shrink_node+0xe1/0x310
[ 1209.892288]  kswapd+0x362/0x9b0
[ 1209.893308]  kthread+0x10f/0x150
[ 1209.894383]  ? mem_cgroup_shrink_node+0x3b0/0x3b0
[ 1209.895703]  ? kthread_create_on_node+0x70/0x70
[ 1209.896956]  ret_from_fork+0x31/0x40
[ 1209.898117] MemAlloc: systemd-journal(526) flags=0x400900 switches=33248 seq=121659 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=52772 uninterruptible
[ 1209.902154] systemd-journal D11240   526      1 0x00000000
[ 1209.903642] Call Trace:
[ 1209.904574]  __schedule+0x336/0xe00
[ 1209.905734]  schedule+0x3d/0x90
[ 1209.906817]  schedule_timeout+0x20d/0x510
[ 1209.908025]  ? prepare_to_wait+0x2b/0xc0
[ 1209.909268]  ? lock_timer_base+0xa0/0xa0
[ 1209.910460]  io_schedule_timeout+0x1e/0x50
[ 1209.911681]  congestion_wait+0x86/0x260
[ 1209.912853]  ? remove_wait_queue+0x60/0x60
[ 1209.914115]  shrink_inactive_list+0x5b4/0x660
[ 1209.915385]  ? __list_lru_count_one.isra.2+0x22/0x80
[ 1209.916768]  shrink_node_memcg+0x535/0x7f0
[ 1209.918173]  shrink_node+0xe1/0x310
[ 1209.919288]  do_try_to_free_pages+0xe1/0x300
[ 1209.920548]  try_to_free_pages+0x131/0x3f0
[ 1209.921827]  __alloc_pages_slowpath+0x3ec/0xd95
[ 1209.923137]  __alloc_pages_nodemask+0x3e4/0x460
[ 1209.924454]  ? __radix_tree_lookup+0x84/0xf0
[ 1209.925790]  alloc_pages_current+0x97/0x1b0
[ 1209.927021]  ? find_get_entry+0x5/0x300
[ 1209.928189]  __page_cache_alloc+0x15d/0x1a0
[ 1209.929471]  ? pagecache_get_page+0x2c/0x2b0
[ 1209.930716]  filemap_fault+0x4df/0x8b0
[ 1209.931867]  ? filemap_fault+0x373/0x8b0
[ 1209.933111]  ? xfs_ilock+0x22c/0x360 [xfs]
[ 1209.934510]  ? xfs_filemap_fault+0x64/0x1e0 [xfs]
[ 1209.935857]  ? down_read_nested+0x7b/0xc0
[ 1209.937123]  ? xfs_ilock+0x22c/0x360 [xfs]
[ 1209.938373]  xfs_filemap_fault+0x6c/0x1e0 [xfs]
[ 1209.939691]  __do_fault+0x1e/0xa0
[ 1209.940807]  ? _raw_spin_unlock+0x27/0x40
[ 1209.942002]  __handle_mm_fault+0xbb1/0xf40
[ 1209.943228]  ? mutex_unlock+0x12/0x20
[ 1209.944410]  ? devkmsg_read+0x15c/0x330
[ 1209.945912]  handle_mm_fault+0x16b/0x390
[ 1209.947297]  ? handle_mm_fault+0x49/0x390
[ 1209.948868]  __do_page_fault+0x24a/0x530
[ 1209.950351]  do_page_fault+0x30/0x80
[ 1209.951615]  page_fault+0x28/0x30
[ 1209.952724] RIP: 0033:0x556f398d623f
[ 1209.953834] RSP: 002b:00007fff1da75710 EFLAGS: 00010206
[ 1209.955273] RAX: 0000556f3b12b9d0 RBX: 0000000000000009 RCX: 0000000000000020
[ 1209.957117] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000000
[ 1209.958849] RBP: 00007fff1da759b0 R08: 0000000000000000 R09: 0000000000000000
[ 1209.960659] R10: 00000000ffffffc0 R11: 00007fdc0df4ef10 R12: 00007fff1da75f30
[ 1209.962397] R13: 00007fff1da78810 R14: 0000000000000009 R15: 0000000000000006
[ 1209.964204] MemAlloc: auditd(563) flags=0x400900 switches=6443 seq=774 gfp=0x142134a(GFP_NOFS|__GFP_HIGHMEM|__GFP_COLD|__GFP_NOWARN|__GFP_NORETRY|__GFP_HARDWALL|__GFP_MOVABLE) order=0 delay=16511 uninterruptible
[ 1209.969005] auditd          D12280   563      1 0x00000000
[ 1209.970503] Call Trace:
[ 1209.971436]  __schedule+0x336/0xe00
[ 1209.972621]  schedule+0x3d/0x90
[ 1209.973696]  schedule_timeout+0x20d/0x510
[ 1209.974910]  ? prepare_to_wait+0x2b/0xc0
[ 1209.976155]  ? lock_timer_base+0xa0/0xa0
[ 1209.977350]  io_schedule_timeout+0x1e/0x50
[ 1209.978597]  congestion_wait+0x86/0x260
[ 1209.979795]  ? remove_wait_queue+0x60/0x60
[ 1209.981020]  shrink_inactive_list+0x5b4/0x660
[ 1209.982290]  ? __list_lru_count_one.isra.2+0x22/0x80
[ 1209.983748]  shrink_node_memcg+0x535/0x7f0
[ 1209.985041]  ? mem_cgroup_iter+0x14d/0x720
[ 1209.986267]  shrink_node+0xe1/0x310
[ 1209.987424]  do_try_to_free_pages+0xe1/0x300
[ 1209.988705]  try_to_free_pages+0x131/0x3f0
[ 1209.989935]  __alloc_pages_slowpath+0x3ec/0xd95
[ 1209.991274]  __alloc_pages_nodemask+0x3e4/0x460
[ 1209.992601]  alloc_pages_current+0x97/0x1b0
[ 1209.993845]  __page_cache_alloc+0x15d/0x1a0
[ 1209.995120]  __do_page_cache_readahead+0x118/0x410
[ 1209.996535]  ? __do_page_cache_readahead+0x191/0x410
[ 1209.997946]  filemap_fault+0x35f/0x8b0
[ 1209.999199]  ? xfs_ilock+0x22c/0x360 [xfs]
[ 1210.000473]  ? xfs_filemap_fault+0x64/0x1e0 [xfs]
[ 1210.001843]  ? down_read_nested+0x7b/0xc0
[ 1210.003184]  ? xfs_ilock+0x22c/0x360 [xfs]
[ 1210.004471]  xfs_filemap_fault+0x6c/0x1e0 [xfs]
[ 1210.005792]  __do_fault+0x1e/0xa0
[ 1210.006925]  __handle_mm_fault+0xbb1/0xf40
[ 1210.008241]  ? ep_poll+0x2ea/0x3b0
[ 1210.009373]  handle_mm_fault+0x16b/0x390
[ 1210.010572]  ? handle_mm_fault+0x49/0x390
[ 1210.011818]  __do_page_fault+0x24a/0x530
[ 1210.013059]  ? wake_up_q+0x80/0x80
[ 1210.014176]  do_page_fault+0x30/0x80
[ 1210.015367]  page_fault+0x28/0x30
[ 1210.016473] RIP: 0033:0x7fcb0c838d13
[ 1210.017635] RSP: 002b:00007ffe275b95a0 EFLAGS: 00010293
[ 1210.019120] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 00007fcb0c838d13
[ 1210.020867] RDX: 0000000000000040 RSI: 0000559240b08d40 RDI: 0000000000000009
[ 1210.022769] RBP: 0000000000000000 R08: 00000000000cf8ba R09: 0000000000000001
[ 1210.024530] R10: 000000000000e95f R11: 0000000000000293 R12: 000055923fbe5e60
[ 1210.026308] R13: 0000000000000000 R14: 0000000000000000 R15: 000055923fbe5e60
[ 1210.028961] MemAlloc: vmtoolsd(723) flags=0x400900 switches=36213 seq=120979 gfp=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=52811 uninterruptible
[ 1210.032683] vmtoolsd        D11240   723      1 0x00000080
[ 1210.034316] Call Trace:
[ 1210.035340]  __schedule+0x336/0xe00
[ 1210.036444]  schedule+0x3d/0x90
[ 1210.037462]  schedule_timeout+0x20d/0x510
[ 1210.038694]  ? prepare_to_wait+0x2b/0xc0
[ 1210.039849]  ? lock_timer_base+0xa0/0xa0
[ 1210.041005]  io_schedule_timeout+0x1e/0x50
[ 1210.042435]  congestion_wait+0x86/0x260
[ 1210.043575]  ? remove_wait_queue+0x60/0x60
[ 1210.044763]  shrink_inactive_list+0x5b4/0x660
[ 1210.046058]  ? __list_lru_count_one.isra.2+0x22/0x80
[ 1210.047419]  shrink_node_memcg+0x535/0x7f0
[ 1210.048609]  shrink_node+0xe1/0x310
[ 1210.049688]  do_try_to_free_pages+0xe1/0x300
[ 1210.051183]  try_to_free_pages+0x131/0x3f0
[ 1210.052421]  __alloc_pages_slowpath+0x3ec/0xd95
[ 1210.053717]  __alloc_pages_nodemask+0x3e4/0x460
[ 1210.055025]  ? __radix_tree_lookup+0x84/0xf0
[ 1210.056264]  alloc_pages_current+0x97/0x1b0
[ 1210.057466]  ? find_get_entry+0x5/0x300
[ 1210.058695]  __page_cache_alloc+0x15d/0x1a0
[ 1210.059894]  ? pagecache_get_page+0x2c/0x2b0
[ 1210.061128]  filemap_fault+0x4df/0x8b0
[ 1210.062340]  ? filemap_fault+0x373/0x8b0
[ 1210.063545]  ? xfs_ilock+0x22c/0x360 [xfs]
[ 1210.064766]  ? xfs_filemap_fault+0x64/0x1e0 [xfs]
[ 1210.066135]  ? down_read_nested+0x7b/0xc0
[ 1210.067405]  ? xfs_ilock+0x22c/0x360 [xfs]
[ 1210.068706]  xfs_filemap_fault+0x6c/0x1e0 [xfs]
[ 1210.070021]  __do_fault+0x1e/0xa0
[ 1210.071102]  __handle_mm_fault+0xbb1/0xf40
[ 1210.072296]  handle_mm_fault+0x16b/0x390
[ 1210.073509]  ? handle_mm_fault+0x49/0x390
[ 1210.074683]  __do_page_fault+0x24a/0x530
[ 1210.075872]  do_page_fault+0x30/0x80
[ 1210.076974]  page_fault+0x28/0x30
[ 1210.078090] RIP: 0033:0x7f12e9fd6420
[ 1210.079193] RSP: 002b:00007ffee98ba498 EFLAGS: 00010202
[ 1210.080605] RAX: 00007f12de02e0fe RBX: 00007ffee98ba4b0 RCX: 00007ffee98ba590
[ 1210.082383] RDX: 00007f12de02e0fe RSI: 0000000000000001 RDI: 00007ffee98ba4b0
[ 1210.084177] RBP: 0000000000000080 R08: 0000000000000000 R09: 000000000000000a
[ 1210.086134] R10: 00007f12eb61a010 R11: 0000000000000000 R12: 0000000000000080
[ 1210.087850] R13: 0000000000000000 R14: 00007f12ea006770 R15: 00005580adf3abc0
(...snipped...)
[ 1210.640170] MemAlloc: a.out(7523) flags=0x420040 switches=90 uninterruptible dying victim
[ 1210.642426] a.out           D11496  7523   7376 0x00100084
[ 1210.643999] Call Trace:
[ 1210.644921]  __schedule+0x336/0xe00
[ 1210.646007]  ? trace_hardirqs_on_thunk+0x1a/0x1c
[ 1210.647328]  schedule+0x3d/0x90
[ 1210.648441]  schedule_timeout+0x26a/0x510
[ 1210.649619]  ? trace_hardirqs_on+0xd/0x10
[ 1210.650792]  __down_common+0xfb/0x131
[ 1210.652188]  ? _xfs_buf_find+0x2cb/0xc10 [xfs]
[ 1210.653480]  __down+0x1d/0x1f
[ 1210.654483]  down+0x41/0x50
[ 1210.655462]  xfs_buf_lock+0x64/0x370 [xfs]
[ 1210.656618]  _xfs_buf_find+0x2cb/0xc10 [xfs]
[ 1210.657823]  ? _xfs_buf_find+0xa4/0xc10 [xfs]
[ 1210.659028]  xfs_buf_get_map+0x2a/0x480 [xfs]
[ 1210.660284]  xfs_buf_read_map+0x2c/0x400 [xfs]
[ 1210.661490]  ? del_timer_sync+0xb5/0xe0
[ 1210.662630]  xfs_trans_read_buf_map+0x186/0x830 [xfs]
[ 1210.664009]  xfs_read_agf+0xc8/0x2b0 [xfs]
[ 1210.665171]  xfs_alloc_read_agf+0x7a/0x300 [xfs]
[ 1210.666441]  ? xfs_alloc_space_available+0x7b/0x120 [xfs]
[ 1210.667923]  xfs_alloc_fix_freelist+0x3bc/0x490 [xfs]
[ 1210.669402]  ? __radix_tree_lookup+0x84/0xf0
[ 1210.670645]  ? xfs_perag_get+0x1a0/0x310 [xfs]
[ 1210.671949]  ? xfs_perag_get+0x5/0x310 [xfs]
[ 1210.673145]  xfs_alloc_vextent+0x161/0xda0 [xfs]
[ 1210.674402]  xfs_bmap_btalloc+0x46c/0x8b0 [xfs]
[ 1210.675774]  ? save_stack_trace+0x1b/0x20
[ 1210.676961]  xfs_bmap_alloc+0x17/0x30 [xfs]
[ 1210.678202]  xfs_bmapi_write+0x74e/0x11d0 [xfs]
[ 1210.679544]  xfs_iomap_write_allocate+0x199/0x3a0 [xfs]
[ 1210.680995]  xfs_map_blocks+0x2cc/0x5a0 [xfs]
[ 1210.682245]  xfs_do_writepage+0x215/0x920 [xfs]
[ 1210.683742]  ? clear_page_dirty_for_io+0xb4/0x310
[ 1210.685125]  write_cache_pages+0x2cb/0x6b0
[ 1210.686408]  ? xfs_map_blocks+0x5a0/0x5a0 [xfs]
[ 1210.687774]  ? xfs_vm_writepages+0x48/0xa0 [xfs]
[ 1210.689111]  xfs_vm_writepages+0x6b/0xa0 [xfs]
[ 1210.690529]  do_writepages+0x21/0x40
[ 1210.691680]  __filemap_fdatawrite_range+0xc6/0x100
[ 1210.693021]  filemap_write_and_wait_range+0x2d/0x70
[ 1210.694444]  xfs_file_fsync+0x8b/0x310 [xfs]
[ 1210.695728]  vfs_fsync_range+0x3d/0xb0
[ 1210.696874]  ? __do_page_fault+0x272/0x530
[ 1210.698102]  do_fsync+0x3d/0x70
[ 1210.699200]  SyS_fsync+0x10/0x20
[ 1210.700267]  do_syscall_64+0x6c/0x200
[ 1210.701498]  entry_SYSCALL64_slow_path+0x25/0x25
[ 1210.702861] RIP: 0033:0x7f504b072d30
[ 1210.704014] RSP: 002b:00007fffcb8f7898 EFLAGS: 00000246 ORIG_RAX: 000000000000004a
[ 1210.705994] RAX: ffffffffffffffda RBX: 0000000000000003 RCX: 00007f504b072d30
[ 1210.707857] RDX: 000000000000000a RSI: 0000000000000000 RDI: 0000000000000003
[ 1210.709647] RBP: 0000000000000003 R08: 00007f504afcc938 R09: 000000000000000e
[ 1210.711632] R10: 00007fffcb8f7620 R11: 0000000000000246 R12: 0000000000400912
[ 1210.713520] R13: 00007fffcb8f79a0 R14: 0000000000000000 R15: 0000000000000000
(...snipped...)
[ 1212.195351] MemAlloc-Info: stalling=32 dying=1 exiting=0 victim=1 oom_count=45896
[ 1242.551629] MemAlloc-Info: stalling=36 dying=1 exiting=0 victim=1 oom_count=45896
(...snipped...)
[ 1245.149165] MemAlloc-Info: stalling=36 dying=1 exiting=0 victim=1 oom_count=45896
[ 1275.319189] MemAlloc-Info: stalling=40 dying=1 exiting=0 victim=1 oom_count=45896
(...snipped...)
[ 1278.241813] MemAlloc-Info: stalling=40 dying=1 exiting=0 victim=1 oom_count=45896
[ 1289.804580] sysrq: SysRq : Kill All Tasks
----------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
