Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8E73D6B0279
	for <linux-mm@kvack.org>; Tue, 30 May 2017 22:36:59 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id s62so1303114pgc.2
        for <linux-mm@kvack.org>; Tue, 30 May 2017 19:36:59 -0700 (PDT)
Received: from mail-pg0-x234.google.com (mail-pg0-x234.google.com. [2607:f8b0:400e:c05::234])
        by mx.google.com with ESMTPS id p28si46649061pli.167.2017.05.30.19.36.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 19:36:58 -0700 (PDT)
Received: by mail-pg0-x234.google.com with SMTP id 8so880128pgc.2
        for <linux-mm@kvack.org>; Tue, 30 May 2017 19:36:57 -0700 (PDT)
Date: Tue, 30 May 2017 19:36:47 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: 4.12-rc jbd2 cpu_hotplug RECLAIM_FS lockdep splat
Message-ID: <alpine.LSU.2.11.1705301933510.11809@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-ext4@vger.kernel.org

I don't get this at all easily, but memcg reclaim on 4.12-rc does
eventually give me a lockdep splat, implicating jbd2 and cpu hotplug
and RECLAIM_FS - which sound like Michal territory to me, though of
course I can barely understand a word of the report: hope you can!

Hugh

[18874.045075] =====================================================
[18874.046735] WARNING: RECLAIM_FS-safe -> RECLAIM_FS-unsafe lock order detected
[18874.048443] 4.12.0-rc3 #2 Not tainted
[18874.050101] -----------------------------------------------------
[18874.051892] cc1/16472 [HC0[0]:SC0[0]:HE1:SE1] is trying to acquire:
[18874.053681]  (cpu_hotplug.dep_map){++++++}, at: [<ffffffff8109ff21>] get_online_cpus+0x29/0x71
[18874.055390] 
and this task is already holding:
[18874.058697]  (jbd2_handle){++++-.}, at: [<ffffffff81252744>] start_this_handle+0x328/0x3c0
[18874.060388] which would create a new lock dependency:
[18874.062066]  (jbd2_handle){++++-.} -> (cpu_hotplug.dep_map){++++++}
[18874.063824] 
but this new dependency connects a RECLAIM_FS-irq-safe lock:
[18874.067242]  (jbd2_handle){++++-.}
[18874.067246] 
... which became RECLAIM_FS-irq-safe at:
[18874.072517]   __lock_acquire+0x3f8/0x1526
[18874.074306]   lock_acquire+0x51/0x6c
[18874.076071]   jbd2_log_wait_commit+0x73/0x14b
[18874.077805]   jbd2_complete_transaction+0x8b/0x94
[18874.079384]   ext4_evict_inode+0xc5/0x3bc
[18874.080948]   evict+0xc4/0x179
[18874.082516]   dispose_list+0x42/0x65
[18874.084326]   prune_icache_sb+0x45/0x50
[18874.086010]   super_cache_scan+0x129/0x16e
[18874.087609]   shrink_slab+0x1e2/0x29c
[18874.089180]   shrink_node+0xfc/0x2cb
[18874.090793]   kswapd+0x4ac/0x600
[18874.092361]   kthread+0x12e/0x136
[18874.093998]   ret_from_fork+0x27/0x40
[18874.095567] 
to a RECLAIM_FS-irq-unsafe lock:
[18874.098728]  (cpu_hotplug.dep_map){++++++}
[18874.098732] 
... which became RECLAIM_FS-irq-unsafe at:
[18874.103495] ...
[18874.103501]   mark_held_locks+0x50/0x6e
[18874.106592]   lockdep_trace_alloc+0xc2/0xe5
[18874.108142]   kmem_cache_alloc_node+0x41/0x1b8
[18874.109701]   __smpboot_create_thread+0x53/0xe6
[18874.111315]   smpboot_create_threads+0x32/0x64
[18874.112859]   cpuhp_invoke_callback+0x4a/0xe6
[18874.114450]   cpuhp_up_callbacks+0x2e/0x7d
[18874.116085]   _cpu_up+0x87/0xb3
[18874.117470]   do_cpu_up+0x54/0x65
[18874.118934]   cpu_up+0xe/0x10
[18874.120374]   smp_init+0x4d/0xd3
[18874.121805]   kernel_init_freeable+0x7e/0x1a0
[18874.123205]   kernel_init+0x9/0xf3
[18874.124529]   ret_from_fork+0x27/0x40
[18874.125883] 
other info that might help us debug this:

[18874.130192]  Possible interrupt unsafe locking scenario:

[18874.133168]        CPU0                    CPU1
[18874.134597]        ----                    ----
[18874.136033]   lock(cpu_hotplug.dep_map);
[18874.137431]                                local_irq_disable();
[18874.138879]                                lock(jbd2_handle);
[18874.140353]                                lock(cpu_hotplug.dep_map);
[18874.141840]   <Interrupt>
[18874.143137]     lock(jbd2_handle);
[18874.144543] 
 *** DEADLOCK ***

[18874.148439] 3 locks held by cc1/16472:
[18874.149711]  #0:  (sb_writers#3){.+.+.+}, at: [<ffffffff811cb4b8>] touch_atime+0x36/0x9c
[18874.150936]  #1:  (jbd2_handle){++++-.}, at: [<ffffffff81252744>] start_this_handle+0x328/0x3c0
[18874.152214]  #2:  (percpu_charge_mutex){+.+...}, at: [<ffffffff811a08cd>] drain_all_stock+0x1c/0x137
[18874.153496] 
the dependencies between RECLAIM_FS-irq-safe lock and the holding lock:
[18874.156099] -> (jbd2_handle){++++-.} ops: 18040307 {
[18874.157531]    HARDIRQ-ON-W at:
[18874.158843]                     __lock_acquire+0x3a7/0x1526
[18874.160180]                     lock_acquire+0x51/0x6c
[18874.161487]                     jbd2_log_wait_commit+0x73/0x14b
[18874.162785]                     jbd2_complete_transaction+0x8b/0x94
[18874.164117]                     ext4_sync_file+0x22e/0x268
[18874.165479]                     vfs_fsync_range+0x82/0x94
[18874.166830]                     vfs_fsync+0x17/0x19
[18874.168221]                     do_fsync+0x28/0x49
[18874.169777]                     SyS_fsync+0xb/0xf
[18874.171088]                     entry_SYSCALL_64_fastpath+0x18/0xad
[18874.172377]    HARDIRQ-ON-R at:
[18874.173640]                     __lock_acquire+0x37e/0x1526
[18874.174989]                     lock_acquire+0x51/0x6c
[18874.176345]                     start_this_handle+0x386/0x3c0
[18874.177588]                     jbd2__journal_start+0xbe/0x14c
[18874.178498]                     __ext4_journal_start_sb+0x5a/0x65
[18874.179803]                     ext4_file_open+0xaa/0x1fa
[18874.181222]                     do_dentry_open.isra.19+0x17f/0x289
[18874.182501]                     vfs_open+0x54/0x5b
[18874.183484]                     path_openat+0x5ef/0x757
[18874.184602]                     do_filp_open+0x4a/0xa2
[18874.185942]                     do_sys_open+0x13b/0x1c8
[18874.187157]                     SyS_open+0x19/0x1b
[18874.188529]                     entry_SYSCALL_64_fastpath+0x18/0xad
[18874.189785]    SOFTIRQ-ON-W at:
[18874.191097]                     __lock_acquire+0x3c9/0x1526
[18874.192505]                     lock_acquire+0x51/0x6c
[18874.193879]                     jbd2_log_wait_commit+0x73/0x14b
[18874.195367]                     jbd2_complete_transaction+0x8b/0x94
[18874.196784]                     ext4_sync_file+0x22e/0x268
[18874.198246]                     vfs_fsync_range+0x82/0x94
[18874.199648]                     vfs_fsync+0x17/0x19
[18874.201100]                     do_fsync+0x28/0x49
[18874.202508]                     SyS_fsync+0xb/0xf
[18874.203917]                     entry_SYSCALL_64_fastpath+0x18/0xad
[18874.205347]    SOFTIRQ-ON-R at:
[18874.206772]                     __lock_acquire+0x3c9/0x1526
[18874.208216]                     lock_acquire+0x51/0x6c
[18874.209637]                     start_this_handle+0x386/0x3c0
[18874.211101]                     jbd2__journal_start+0xbe/0x14c
[18874.212569]                     __ext4_journal_start_sb+0x5a/0x65
[18874.214006]                     ext4_file_open+0xaa/0x1fa
[18874.215395]                     do_dentry_open.isra.19+0x17f/0x289
[18874.216772]                     vfs_open+0x54/0x5b
[18874.218160]                     path_openat+0x5ef/0x757
[18874.219486]                     do_filp_open+0x4a/0xa2
[18874.220917]                     do_sys_open+0x13b/0x1c8
[18874.222275]                     SyS_open+0x19/0x1b
[18874.223706]                     entry_SYSCALL_64_fastpath+0x18/0xad
[18874.225103]    IN-RECLAIM_FS-W at:
[18874.226499]                        __lock_acquire+0x3f8/0x1526
[18874.227833]                        lock_acquire+0x51/0x6c
[18874.229162]                        jbd2_log_wait_commit+0x73/0x14b
[18874.230524]                        jbd2_complete_transaction+0x8b/0x94
[18874.231842]                        ext4_evict_inode+0xc5/0x3bc
[18874.233149]                        evict+0xc4/0x179
[18874.234332]                        dispose_list+0x42/0x65
[18874.235640]                        prune_icache_sb+0x45/0x50
[18874.236913]                        super_cache_scan+0x129/0x16e
[18874.238009]                        shrink_slab+0x1e2/0x29c
[18874.239295]                        shrink_node+0xfc/0x2cb
[18874.240316]                        kswapd+0x4ac/0x600
[18874.241379]                        kthread+0x12e/0x136
[18874.242516]                        ret_from_fork+0x27/0x40
[18874.243805]    INITIAL USE at:
[18874.245132]                    __lock_acquire+0x410/0x1526
[18874.246437]                    lock_acquire+0x51/0x6c
[18874.247484]                    start_this_handle+0x386/0x3c0
[18874.248581]                    jbd2__journal_start+0xbe/0x14c
[18874.249871]                    __ext4_journal_start_sb+0x5a/0x65
[18874.251185]                    ext4_file_open+0xaa/0x1fa
[18874.252207]                    do_dentry_open.isra.19+0x17f/0x289
[18874.253113]                    vfs_open+0x54/0x5b
[18874.254186]                    path_openat+0x5ef/0x757
[18874.255499]                    do_filp_open+0x4a/0xa2
[18874.256805]                    do_sys_open+0x13b/0x1c8
[18874.258117]                    SyS_open+0x19/0x1b
[18874.259553]                    entry_SYSCALL_64_fastpath+0x18/0xad
[18874.260941]  }
[18874.262313]  ... key      at: [<ffffffff82a5cd48>] jbd2_trans_commit_key.37604+0x0/0x8
[18874.263715]  ... acquired at:
[18874.265121]    check_irq_usage+0x54/0xa8
[18874.266436]    __lock_acquire+0xef3/0x1526
[18874.267887]    lock_acquire+0x51/0x6c
[18874.269435]    get_online_cpus+0x4c/0x71
[18874.270961]    drain_all_stock+0x29/0x137
[18874.272279]    try_charge+0x276/0x8e9
[18874.273598]    mem_cgroup_try_charge+0x2d5/0x41f
[18874.275036]    __add_to_page_cache_locked+0xb2/0x1e4
[18874.275917]    add_to_page_cache_lru+0x4e/0xde
[18874.276791]    pagecache_get_page+0x1cb/0x264
[18874.277664]    __getblk_gfp+0x142/0x2cf
[18874.278636]    __breadahead+0xf/0x3d
[18874.279940]    __ext4_get_inode_loc+0x2c3/0x394
[18874.281277]    ext4_get_inode_loc+0x1b/0x1d
[18874.282530]    ext4_reserve_inode_write+0x35/0x9c
[18874.283848]    ext4_mark_inode_dirty+0x40/0x173
[18874.285208]    ext4_dirty_inode+0x43/0x5c
[18874.286476]    __mark_inode_dirty+0x2e/0x205
[18874.287778]    generic_update_time+0xa5/0xb4
[18874.289090]    touch_atime+0x7d/0x9c
[18874.290399]    do_generic_file_read+0x5a6/0x71f
[18874.291735]    generic_file_read_iter+0xcb/0xda
[18874.293168]    ext4_file_read_iter+0x2f/0x3e
[18874.294448]    __vfs_read+0xbf/0xe3
[18874.295762]    vfs_read+0x9b/0x11c
[18874.297087]    SyS_read+0x45/0x8b
[18874.298384]    entry_SYSCALL_64_fastpath+0x18/0xad

[18874.300947] 
the dependencies between the lock to be acquired
[18874.300948]  and RECLAIM_FS-irq-unsafe lock:
[18874.304806] -> (cpu_hotplug.dep_map){++++++} ops: 58002 {
[18874.306105]    HARDIRQ-ON-W at:
[18874.307416]                     __lock_acquire+0x3a7/0x1526
[18874.308841]                     lock_acquire+0x51/0x6c
[18874.310220]                     cpu_hotplug_begin+0x61/0xb4
[18874.311530]                     _cpu_up+0x2e/0xb3
[18874.312845]                     do_cpu_up+0x54/0x65
[18874.314132]                     cpu_up+0xe/0x10
[18874.315499]                     smp_init+0x4d/0xd3
[18874.317004]                     kernel_init_freeable+0x7e/0x1a0
[18874.318407]                     kernel_init+0x9/0xf3
[18874.319661]                     ret_from_fork+0x27/0x40
[18874.320964]    HARDIRQ-ON-R at:
[18874.322321]                     __lock_acquire+0x37e/0x1526
[18874.323605]                     lock_acquire+0x51/0x6c
[18874.324918]                     get_online_cpus+0x4c/0x71
[18874.326257]                     kmem_cache_create+0x27/0x1e3
[18874.327522]                     numa_policy_init+0x2d/0x1e9
[18874.328802]                     start_kernel+0x2e0/0x392
[18874.330112]                     x86_64_start_reservations+0x2a/0x2c
[18874.331419]                     x86_64_start_kernel+0xbb/0xbe
[18874.332671]                     verify_cpu+0x0/0xf1
[18874.333922]    SOFTIRQ-ON-W at:
[18874.335091]                     __lock_acquire+0x3c9/0x1526
[18874.336399]                     lock_acquire+0x51/0x6c
[18874.337546]                     cpu_hotplug_begin+0x61/0xb4
[18874.338912]                     _cpu_up+0x2e/0xb3
[18874.340239]                     do_cpu_up+0x54/0x65
[18874.341551]                     cpu_up+0xe/0x10
[18874.342883]                     smp_init+0x4d/0xd3
[18874.344122]                     kernel_init_freeable+0x7e/0x1a0
[18874.345340]                     kernel_init+0x9/0xf3
[18874.346578]                     ret_from_fork+0x27/0x40
[18874.347750]    SOFTIRQ-ON-R at:
[18874.348979]                     __lock_acquire+0x3c9/0x1526
[18874.350247]                     lock_acquire+0x51/0x6c
[18874.351436]                     get_online_cpus+0x4c/0x71
[18874.352830]                     kmem_cache_create+0x27/0x1e3
[18874.353993]                     numa_policy_init+0x2d/0x1e9
[18874.355191]                     start_kernel+0x2e0/0x392
[18874.356354]                     x86_64_start_reservations+0x2a/0x2c
[18874.357532]                     x86_64_start_kernel+0xbb/0xbe
[18874.358762]                     verify_cpu+0x0/0xf1
[18874.359836]    RECLAIM_FS-ON-W at:
[18874.360681]                        mark_held_locks+0x50/0x6e
[18874.361549]                        lockdep_trace_alloc+0xc2/0xe5
[18874.362548]                        kmem_cache_alloc_node+0x41/0x1b8
[18874.363747]                        __smpboot_create_thread+0x53/0xe6
[18874.364953]                        smpboot_create_threads+0x32/0x64
[18874.366182]                        cpuhp_invoke_callback+0x4a/0xe6
[18874.367607]                        cpuhp_up_callbacks+0x2e/0x7d
[18874.368945]                        _cpu_up+0x87/0xb3
[18874.370363]                        do_cpu_up+0x54/0x65
[18874.371613]                        cpu_up+0xe/0x10
[18874.372608]                        smp_init+0x4d/0xd3
[18874.373456]                        kernel_init_freeable+0x7e/0x1a0
[18874.374323]                        kernel_init+0x9/0xf3
[18874.375147]                        ret_from_fork+0x27/0x40
[18874.375962]    RECLAIM_FS-ON-R at:
[18874.376774]                        mark_held_locks+0x50/0x6e
[18874.377609]                        lockdep_trace_alloc+0xc2/0xe5
[18874.378451]                        kmem_cache_alloc_node+0x41/0x1b8
[18874.379669]                        allocate_shared_regs+0x2c/0x6e
[18874.381030]                        intel_pmu_cpu_prepare+0x40/0x10f
[18874.382313]                        x86_pmu_prepare_cpu+0x39/0x40
[18874.383628]                        cpuhp_invoke_callback+0x4a/0xe6
[18874.384498]                        cpuhp_issue_call+0xb9/0xcf
[18874.385357]                        __cpuhp_setup_state+0xd3/0x169
[18874.386220]                        init_hw_perf_events+0x432/0x521
[18874.387456]                        do_one_initcall+0x8b/0x136
[18874.388826]                        kernel_init_freeable+0x70/0x1a0
[18874.390212]                        kernel_init+0x9/0xf3
[18874.391739]                        ret_from_fork+0x27/0x40
[18874.392584]    INITIAL USE at:
[18874.393749]                    __lock_acquire+0x410/0x1526
[18874.394613]                    lock_acquire+0x51/0x6c
[18874.395464]                    get_online_cpus+0x4c/0x71
[18874.396422]                    __cpuhp_setup_state+0x3f/0x169
[18874.397777]                    page_alloc_init+0x23/0x2b
[18874.399107]                    start_kernel+0x12b/0x392
[18874.400321]                    x86_64_start_reservations+0x2a/0x2c
[18874.401708]                    x86_64_start_kernel+0xbb/0xbe
[18874.402947]                    verify_cpu+0x0/0xf1
[18874.403784]  }
[18874.404617]  ... key      at: [<ffffffff81c41db8>] cpu_hotplug+0xd8/0x100
[18874.405480]  ... acquired at:
[18874.406559]    check_irq_usage+0x54/0xa8
[18874.407798]    __lock_acquire+0xef3/0x1526
[18874.409036]    lock_acquire+0x51/0x6c
[18874.410279]    get_online_cpus+0x4c/0x71
[18874.411590]    drain_all_stock+0x29/0x137
[18874.412831]    try_charge+0x276/0x8e9
[18874.414121]    mem_cgroup_try_charge+0x2d5/0x41f
[18874.415369]    __add_to_page_cache_locked+0xb2/0x1e4
[18874.416701]    add_to_page_cache_lru+0x4e/0xde
[18874.417940]    pagecache_get_page+0x1cb/0x264
[18874.419177]    __getblk_gfp+0x142/0x2cf
[18874.420432]    __breadahead+0xf/0x3d
[18874.421707]    __ext4_get_inode_loc+0x2c3/0x394
[18874.422933]    ext4_get_inode_loc+0x1b/0x1d
[18874.424230]    ext4_reserve_inode_write+0x35/0x9c
[18874.425489]    ext4_mark_inode_dirty+0x40/0x173
[18874.426650]    ext4_dirty_inode+0x43/0x5c
[18874.427819]    __mark_inode_dirty+0x2e/0x205
[18874.428994]    generic_update_time+0xa5/0xb4
[18874.430174]    touch_atime+0x7d/0x9c
[18874.431420]    do_generic_file_read+0x5a6/0x71f
[18874.432692]    generic_file_read_iter+0xcb/0xda
[18874.434012]    ext4_file_read_iter+0x2f/0x3e
[18874.435455]    __vfs_read+0xbf/0xe3
[18874.436509]    vfs_read+0x9b/0x11c
[18874.437338]    SyS_read+0x45/0x8b
[18874.438162]    entry_SYSCALL_64_fastpath+0x18/0xad

[18874.439819] 
stack backtrace:
[18874.441421] CPU: 3 PID: 16472 Comm: cc1 Not tainted 4.12.0-rc3 #2
[18874.442251] Hardware name: LENOVO 4174EH1/4174EH1, BIOS 8CET51WW (1.31 ) 11/29/2011
[18874.443099] Call Trace:
[18874.443926]  dump_stack+0x67/0x90
[18874.444747]  check_usage+0x571/0x588
[18874.445566]  ? vmpressure+0x63/0x10c
[18874.446393]  check_irq_usage+0x54/0xa8
[18874.447222]  ? check_irq_usage+0x54/0xa8
[18874.448041]  __lock_acquire+0xef3/0x1526
[18874.448863]  lock_acquire+0x51/0x6c
[18874.449684]  ? lock_acquire+0x51/0x6c
[18874.450519]  ? get_online_cpus+0x29/0x71
[18874.451347]  get_online_cpus+0x4c/0x71
[18874.452166]  ? get_online_cpus+0x29/0x71
[18874.452986]  drain_all_stock+0x29/0x137
[18874.453801]  try_charge+0x276/0x8e9
[18874.454623]  ? get_mem_cgroup_from_mm+0xaa/0x268
[18874.455448]  mem_cgroup_try_charge+0x2d5/0x41f
[18874.456274]  __add_to_page_cache_locked+0xb2/0x1e4
[18874.457101]  add_to_page_cache_lru+0x4e/0xde
[18874.457919]  pagecache_get_page+0x1cb/0x264
[18874.458752]  __getblk_gfp+0x142/0x2cf
[18874.459583]  __breadahead+0xf/0x3d
[18874.460406]  __ext4_get_inode_loc+0x2c3/0x394
[18874.461230]  ext4_get_inode_loc+0x1b/0x1d
[18874.462043]  ext4_reserve_inode_write+0x35/0x9c
[18874.462863]  ext4_mark_inode_dirty+0x40/0x173
[18874.463679]  ext4_dirty_inode+0x43/0x5c
[18874.464511]  __mark_inode_dirty+0x2e/0x205
[18874.465343]  generic_update_time+0xa5/0xb4
[18874.466176]  touch_atime+0x7d/0x9c
[18874.466997]  do_generic_file_read+0x5a6/0x71f
[18874.467822]  ? __handle_mm_fault+0xc11/0xcd2
[18874.468644]  generic_file_read_iter+0xcb/0xda
[18874.469465]  ext4_file_read_iter+0x2f/0x3e
[18874.470289]  __vfs_read+0xbf/0xe3
[18874.471107]  vfs_read+0x9b/0x11c
[18874.471917]  SyS_read+0x45/0x8b
[18874.472705]  entry_SYSCALL_64_fastpath+0x18/0xad

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
