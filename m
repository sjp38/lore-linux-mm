Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0C8446B0253
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 09:55:53 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r18so4228714wmd.1
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 06:55:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y20si32681012wrb.312.2017.02.03.06.55.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Feb 2017 06:55:51 -0800 (PST)
Date: Fri, 3 Feb 2017 15:55:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages
 per zone
Message-ID: <20170203145548.GC19325@dhcp22.suse.cz>
References: <20170125130014.GO32377@dhcp22.suse.cz>
 <20170127144906.GB4148@dhcp22.suse.cz>
 <201701290027.AFB30799.FVtFLOOOJMSHQF@I-love.SAKURA.ne.jp>
 <20170130085546.GF8443@dhcp22.suse.cz>
 <20170202101415.GE22806@dhcp22.suse.cz>
 <201702031957.AGH86961.MLtOQVFOSHJFFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201702031957.AGH86961.MLtOQVFOSHJFFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hch@lst.de, mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>

[CC Petr]

On Fri 03-02-17 19:57:39, Tetsuo Handa wrote:
[...]
> (2) I got a lockdep warning. (A new false positive?)

Yes, I suspect this is a false possitive. I do not see how we can
deadlock. __alloc_pages_direct_reclaim calls drain_all_pages(NULL) which
means that a potential recursion to the page allocator during draining
would just bail out on the trylock. Maybe I am misinterpreting the
report though.

> [  243.036975] =====================================================
> [  243.042976] WARNING: RECLAIM_FS-safe -> RECLAIM_FS-unsafe lock order detected
> [  243.051211] 4.10.0-rc6-next-20170202 #46 Not tainted
> [  243.054619] -----------------------------------------------------
> [  243.057395] awk/8767 [HC0[0]:SC0[0]:HE1:SE1] is trying to acquire:
> [  243.060310]  (cpu_hotplug.dep_map){++++++}, at: [<ffffffff8108ddf2>] get_online_cpus+0x32/0x80
> [  243.063462] 
> [  243.063462] and this task is already holding:
> [  243.066851]  (&xfs_dir_ilock_class){++++-.}, at: [<ffffffffa02a4af4>] xfs_ilock+0x114/0x290 [xfs]
> [  243.069949] which would create a new lock dependency:
> [  243.072143]  (&xfs_dir_ilock_class){++++-.} -> (cpu_hotplug.dep_map){++++++}
> [  243.074789] 
> [  243.074789] but this new dependency connects a RECLAIM_FS-irq-safe lock:
> [  243.078735]  (&xfs_dir_ilock_class){++++-.}
> [  243.078739] 
> [  243.078739] ... which became RECLAIM_FS-irq-safe at:
> [  243.084175]   
> [  243.084180] [<ffffffff810ef934>] __lock_acquire+0x344/0x1bb0
> [  243.087257]   
> [  243.087261] [<ffffffff810f1840>] lock_acquire+0xe0/0x2a0
> [  243.090027]   
> [  243.090033] [<ffffffff810ea7e9>] down_write_nested+0x59/0xc0
> [  243.092838]   
> [  243.092888] [<ffffffffa02a4b2e>] xfs_ilock+0x14e/0x290 [xfs]
> [  243.095453]   
> [  243.095485] [<ffffffffa02986a5>] xfs_reclaim_inode+0x135/0x340 [xfs]
> [  243.098083]   
> [  243.098109] [<ffffffffa0298b7a>] xfs_reclaim_inodes_ag+0x2ca/0x4f0 [xfs]
> [  243.100668]   
> [  243.100692] [<ffffffffa029af9e>] xfs_reclaim_inodes_nr+0x2e/0x40 [xfs]
> [  243.103191]   
> [  243.103221] [<ffffffffa02b32c4>] xfs_fs_free_cached_objects+0x14/0x20 [xfs]
> [  243.105710]   
> [  243.105714] [<ffffffff81261dbc>] super_cache_scan+0x17c/0x190
> [  243.107947]   
> [  243.107950] [<ffffffff811d375a>] shrink_slab+0x29a/0x710
> [  243.110133]   
> [  243.110135] [<ffffffff811d876d>] shrink_node+0x23d/0x320
> [  243.112262]   
> [  243.112264] [<ffffffff811d9e24>] kswapd+0x354/0xa10
> [  243.114323]   
> [  243.114326] [<ffffffff810b5caa>] kthread+0x10a/0x140
> [  243.116448]   
> [  243.116452] [<ffffffff81715081>] ret_from_fork+0x31/0x40
> [  243.118692] 
> [  243.118692] to a RECLAIM_FS-irq-unsafe lock:
> [  243.120636]  (cpu_hotplug.dep_map){++++++}
> [  243.120638] 
> [  243.120638] ... which became RECLAIM_FS-irq-unsafe at:
> [  243.124021] ...
> [  243.124022]   
> [  243.124820] [<ffffffff810ef051>] mark_held_locks+0x71/0x90
> [  243.127033]   
> [  243.127035] [<ffffffff810f3405>] lockdep_trace_alloc+0xc5/0x110
> [  243.129228]   
> [  243.129231] [<ffffffff8122f8ca>] kmem_cache_alloc_node_trace+0x4a/0x410
> [  243.131534]   
> [  243.131536] [<ffffffff810ba350>] __smpboot_create_thread.part.3+0x30/0xf0
> [  243.133850]   
> [  243.133852] [<ffffffff810ba7a1>] smpboot_create_threads+0x61/0x90
> [  243.136113]   
> [  243.136119] [<ffffffff8108e2cb>] cpuhp_invoke_callback+0xbb/0xb70
> [  243.138319]   
> [  243.138320] [<ffffffff8108fc82>] cpuhp_up_callbacks+0x32/0xb0
> [  243.140479]   
> [  243.140480] [<ffffffff810900f4>] _cpu_up+0x84/0xf0
> [  243.142484]   
> [  243.142485] [<ffffffff810901e4>] do_cpu_up+0x84/0xd0
> [  243.144716]   
> [  243.144719] [<ffffffff8109023e>] cpu_up+0xe/0x10
> [  243.146684]   
> [  243.146687] [<ffffffff81f6f446>] smp_init+0xd5/0x141
> [  243.148755]   
> [  243.148758] [<ffffffff81f3f35b>] kernel_init_freeable+0x17d/0x2a7
> [  243.150932]   
> [  243.150936] [<ffffffff817048e9>] kernel_init+0x9/0x100
> [  243.153088]   
> [  243.153092] [<ffffffff81715081>] ret_from_fork+0x31/0x40
> [  243.155135] 
> [  243.155135] other info that might help us debug this:
> [  243.155135] 
> [  243.157724]  Possible interrupt unsafe locking scenario:
> [  243.157724] 
> [  243.159877]        CPU0                    CPU1
> [  243.161047]        ----                    ----
> [  243.162210]   lock(cpu_hotplug.dep_map);
> [  243.163279]                                local_irq_disable();
> [  243.164669]                                lock(&xfs_dir_ilock_class);
> [  243.166148]                                lock(cpu_hotplug.dep_map);
> [  243.167653]   <Interrupt>
> [  243.168594]     lock(&xfs_dir_ilock_class);
> [  243.169694] 
> [  243.169694]  *** DEADLOCK ***
> [  243.169694] 
> [  243.171864] 3 locks held by awk/8767:
> [  243.172872]  #0:  (&type->i_mutex_dir_key#3){++++++}, at: [<ffffffff8126e2dc>] path_openat+0x53c/0xa90
> [  243.174791]  #1:  (&xfs_dir_ilock_class){++++-.}, at: [<ffffffffa02a4af4>] xfs_ilock+0x114/0x290 [xfs]
> [  243.176899]  #2:  (pcpu_drain_mutex){+.+...}, at: [<ffffffff811bf39a>] drain_all_pages.part.80+0x1a/0x320
> [  243.178875] 
> [  243.178875] the dependencies between RECLAIM_FS-irq-safe lock and the holding lock:
> [  243.181262] -> (&xfs_dir_ilock_class){++++-.} ops: 17348 {
> [  243.182610]    HARDIRQ-ON-W at:
> [  243.183603]                     
> [  243.183606] [<ffffffff810efd84>] __lock_acquire+0x794/0x1bb0
> [  243.186056]                     
> [  243.186059] [<ffffffff810f1840>] lock_acquire+0xe0/0x2a0
> [  243.188419]                     
> [  243.188422] [<ffffffff810ea7e9>] down_write_nested+0x59/0xc0
> [  243.190909]                     
> [  243.190941] [<ffffffffa02a4b2e>] xfs_ilock+0x14e/0x290 [xfs]
> [  243.193257]                     
> [  243.193281] [<ffffffffa02a4c9b>] xfs_ilock_data_map_shared+0x2b/0x30 [xfs]
> [  243.195795]                     
> [  243.195814] [<ffffffffa02559f4>] xfs_dir_lookup+0xd4/0x1c0 [xfs]
> [  243.198204]                     
> [  243.198227] [<ffffffffa02a62ff>] xfs_lookup+0x7f/0x250 [xfs]
> [  243.200570]                     
> [  243.200593] [<ffffffffa02a1fcb>] xfs_vn_lookup+0x6b/0xb0 [xfs]
> [  243.203086]                     
> [  243.203089] [<ffffffff8126ce2c>] lookup_open+0x54c/0x790
> [  243.205417]                     
> [  243.205420] [<ffffffff8126e2fa>] path_openat+0x55a/0xa90
> [  243.207711]                     
> [  243.207713] [<ffffffff8126f9ec>] do_filp_open+0x8c/0x100
> [  243.210092]                     
> [  243.210095] [<ffffffff81263c41>] do_open_execat+0x71/0x180
> [  243.212427]                     
> [  243.212429] [<ffffffff812641b6>] open_exec+0x26/0x40
> [  243.214664]                     
> [  243.214668] [<ffffffff812c43ee>] load_elf_binary+0x2be/0x15f0
> [  243.217045]                     
> [  243.217048] [<ffffffff812644b0>] search_binary_handler+0x80/0x1e0
> [  243.219501]                     
> [  243.219503] [<ffffffff812663ca>] do_execveat_common.isra.40+0x68a/0xa00
> [  243.222056]                     
> [  243.222058] [<ffffffff81266767>] do_execve+0x27/0x30
> [  243.224471]                     
> [  243.224475] [<ffffffff812669c0>] SyS_execve+0x20/0x30
> [  243.226787]                     
> [  243.226790] [<ffffffff81003c17>] do_syscall_64+0x67/0x1f0
> [  243.229178]                     
> [  243.229182] [<ffffffff81714ec9>] return_from_SYSCALL_64+0x0/0x7a
> [  243.231695]    HARDIRQ-ON-R at:
> [  243.232709]                     
> [  243.232712] [<ffffffff810ef8c0>] __lock_acquire+0x2d0/0x1bb0
> [  243.235161]                     
> [  243.235164] [<ffffffff810f1840>] lock_acquire+0xe0/0x2a0
> [  243.237547]                     
> [  243.237551] [<ffffffff810ea672>] down_read_nested+0x52/0xb0
> [  243.239930]                     
> [  243.239962] [<ffffffffa02a4af4>] xfs_ilock+0x114/0x290 [xfs]
> [  243.242353]                     
> [  243.242385] [<ffffffffa02a4c9b>] xfs_ilock_data_map_shared+0x2b/0x30 [xfs]
> [  243.244978]                     
> [  243.244998] [<ffffffffa02559f4>] xfs_dir_lookup+0xd4/0x1c0 [xfs]
> [  243.247493]                     
> [  243.247515] [<ffffffffa02a62ff>] xfs_lookup+0x7f/0x250 [xfs]
> [  243.249910]                     
> [  243.249930] [<ffffffffa02a1fcb>] xfs_vn_lookup+0x6b/0xb0 [xfs]
> [  243.252407]                     
> [  243.252412] [<ffffffff8126902e>] lookup_slow+0x12e/0x220
> [  243.254747]                     
> [  243.254750] [<ffffffff8126d2c6>] walk_component+0x1a6/0x2b0
> [  243.257126]                     
> [  243.257128] [<ffffffff8126d55c>] link_path_walk+0x18c/0x580
> [  243.259495]                     
> [  243.259497] [<ffffffff8126de41>] path_openat+0xa1/0xa90
> [  243.261804]                     
> [  243.261806] [<ffffffff8126f9ec>] do_filp_open+0x8c/0x100
> [  243.264184]                     
> [  243.264188] [<ffffffff8125c0ea>] do_sys_open+0x13a/0x200
> [  243.266595]                     
> [  243.266599] [<ffffffff8125c1c9>] SyS_open+0x19/0x20
> [  243.268984]                     
> [  243.268989] [<ffffffff81714e01>] entry_SYSCALL_64_fastpath+0x1f/0xc2
> [  243.271702]    SOFTIRQ-ON-W at:
> [  243.272726]                     
> [  243.272729] [<ffffffff810ef8ed>] __lock_acquire+0x2fd/0x1bb0
> [  243.275109]                     
> [  243.275111] [<ffffffff810f1840>] lock_acquire+0xe0/0x2a0
> [  243.277426]                     
> [  243.277429] [<ffffffff810ea7e9>] down_write_nested+0x59/0xc0
> [  243.279790]                     
> [  243.279823] [<ffffffffa02a4b2e>] xfs_ilock+0x14e/0x290 [xfs]
> [  243.282192]                     
> [  243.282216] [<ffffffffa02a4c9b>] xfs_ilock_data_map_shared+0x2b/0x30 [xfs]
> [  243.284794]                     
> [  243.284816] [<ffffffffa02559f4>] xfs_dir_lookup+0xd4/0x1c0 [xfs]
> [  243.287259]                     
> [  243.287284] [<ffffffffa02a62ff>] xfs_lookup+0x7f/0x250 [xfs]
> [  243.289735]                     
> [  243.289763] [<ffffffffa02a1fcb>] xfs_vn_lookup+0x6b/0xb0 [xfs]
> [  243.292205]                     
> [  243.292208] [<ffffffff8126ce2c>] lookup_open+0x54c/0x790
> [  243.294555]                     
> [  243.294558] [<ffffffff8126e2fa>] path_openat+0x55a/0xa90
> [  243.296897]                     
> [  243.296900] [<ffffffff8126f9ec>] do_filp_open+0x8c/0x100
> [  243.299242]                     
> [  243.299244] [<ffffffff81263c41>] do_open_execat+0x71/0x180
> [  243.301754]                     
> [  243.301759] [<ffffffff812641b6>] open_exec+0x26/0x40
> [  243.304037]                     
> [  243.304042] [<ffffffff812c43ee>] load_elf_binary+0x2be/0x15f0
> [  243.306531]                     
> [  243.306534] [<ffffffff812644b0>] search_binary_handler+0x80/0x1e0
> [  243.308976]                     
> [  243.308979] [<ffffffff812663ca>] do_execveat_common.isra.40+0x68a/0xa00
> [  243.311506]                     
> [  243.311508] [<ffffffff81266767>] do_execve+0x27/0x30
> [  243.313777]                     
> [  243.313779] [<ffffffff812669c0>] SyS_execve+0x20/0x30
> [  243.316067]                     
> [  243.316070] [<ffffffff81003c17>] do_syscall_64+0x67/0x1f0
> [  243.318429]                     
> [  243.318434] [<ffffffff81714ec9>] return_from_SYSCALL_64+0x0/0x7a
> [  243.320884]    SOFTIRQ-ON-R at:
> [  243.321860]                     
> [  243.321862] [<ffffffff810ef8ed>] __lock_acquire+0x2fd/0x1bb0
> [  243.324251]                     
> [  243.324252] [<ffffffff810f1840>] lock_acquire+0xe0/0x2a0
> [  243.326601]                     
> [  243.326604] [<ffffffff810ea672>] down_read_nested+0x52/0xb0
> [  243.328966]                     
> [  243.328998] [<ffffffffa02a4af4>] xfs_ilock+0x114/0x290 [xfs]
> [  243.331384]                     
> [  243.331407] [<ffffffffa02a4c9b>] xfs_ilock_data_map_shared+0x2b/0x30 [xfs]
> [  243.333978]                     
> [  243.334001] [<ffffffffa02559f4>] xfs_dir_lookup+0xd4/0x1c0 [xfs]
> [  243.336492]                     
> [  243.336516] [<ffffffffa02a62ff>] xfs_lookup+0x7f/0x250 [xfs]
> [  243.338926]                     
> [  243.338948] [<ffffffffa02a1fcb>] xfs_vn_lookup+0x6b/0xb0 [xfs]
> [  243.341365]                     
> [  243.341368] [<ffffffff8126902e>] lookup_slow+0x12e/0x220
> [  243.343694]                     
> [  243.343696] [<ffffffff8126d2c6>] walk_component+0x1a6/0x2b0
> [  243.346074]                     
> [  243.346076] [<ffffffff8126d55c>] link_path_walk+0x18c/0x580
> [  243.348443]                     
> [  243.348444] [<ffffffff8126de41>] path_openat+0xa1/0xa90
> [  243.350753]                     
> [  243.350755] [<ffffffff8126f9ec>] do_filp_open+0x8c/0x100
> [  243.353240]                     
> [  243.353244] [<ffffffff8125c0ea>] do_sys_open+0x13a/0x200
> [  243.355581]                     
> [  243.355583] [<ffffffff8125c1c9>] SyS_open+0x19/0x20
> [  243.358015]                     
> [  243.358019] [<ffffffff81714e01>] entry_SYSCALL_64_fastpath+0x1f/0xc2
> [  243.360586]    IN-RECLAIM_FS-W at:
> [  243.361628]                        
> [  243.361630] [<ffffffff810ef934>] __lock_acquire+0x344/0x1bb0
> [  243.364273]                        
> [  243.364275] [<ffffffff810f1840>] lock_acquire+0xe0/0x2a0
> [  243.366710]                        
> [  243.366713] [<ffffffff810ea7e9>] down_write_nested+0x59/0xc0
> [  243.369153]                        
> [  243.369182] [<ffffffffa02a4b2e>] xfs_ilock+0x14e/0x290 [xfs]
> [  243.371597]                        
> [  243.371619] [<ffffffffa02986a5>] xfs_reclaim_inode+0x135/0x340 [xfs]
> [  243.374339]                        
> [  243.374366] [<ffffffffa0298b7a>] xfs_reclaim_inodes_ag+0x2ca/0x4f0 [xfs]
> [  243.377009]                        
> [  243.377032] [<ffffffffa029af9e>] xfs_reclaim_inodes_nr+0x2e/0x40 [xfs]
> [  243.379659]                        
> [  243.379686] [<ffffffffa02b32c4>] xfs_fs_free_cached_objects+0x14/0x20 [xfs]
> [  243.382349]                        
> [  243.382352] [<ffffffff81261dbc>] super_cache_scan+0x17c/0x190
> [  243.384907]                        
> [  243.384911] [<ffffffff811d375a>] shrink_slab+0x29a/0x710
> [  243.387690]                        
> [  243.387693] [<ffffffff811d876d>] shrink_node+0x23d/0x320
> [  243.390148]                        
> [  243.390150] [<ffffffff811d9e24>] kswapd+0x354/0xa10
> [  243.392517]                        
> [  243.392520] [<ffffffff810b5caa>] kthread+0x10a/0x140
> [  243.394851]                        
> [  243.394853] [<ffffffff81715081>] ret_from_fork+0x31/0x40
> [  243.397246]    INITIAL USE at:
> [  243.398227]                    
> [  243.398229] [<ffffffff810ef960>] __lock_acquire+0x370/0x1bb0
> [  243.400646]                    
> [  243.400648] [<ffffffff810f1840>] lock_acquire+0xe0/0x2a0
> [  243.402997]                    
> [  243.402999] [<ffffffff810ea672>] down_read_nested+0x52/0xb0
> [  243.405351]                    
> [  243.405397] [<ffffffffa02a4af4>] xfs_ilock+0x114/0x290 [xfs]
> [  243.407778]                    
> [  243.407799] [<ffffffffa02a4c9b>] xfs_ilock_data_map_shared+0x2b/0x30 [xfs]
> [  243.410364]                    
> [  243.410390] [<ffffffffa02559f4>] xfs_dir_lookup+0xd4/0x1c0 [xfs]
> [  243.412989]                    
> [  243.413011] [<ffffffffa02a62ff>] xfs_lookup+0x7f/0x250 [xfs]
> [  243.415416]                    
> [  243.415437] [<ffffffffa02a1fcb>] xfs_vn_lookup+0x6b/0xb0 [xfs]
> [  243.417871]                    
> [  243.417874] [<ffffffff8126902e>] lookup_slow+0x12e/0x220
> [  243.420641]                    
> [  243.420644] [<ffffffff8126d2c6>] walk_component+0x1a6/0x2b0
> [  243.423039]                    
> [  243.423041] [<ffffffff8126d55c>] link_path_walk+0x18c/0x580
> [  243.425553]                    
> [  243.425555] [<ffffffff8126de41>] path_openat+0xa1/0xa90
> [  243.427891]                    
> [  243.427892] [<ffffffff8126f9ec>] do_filp_open+0x8c/0x100
> [  243.430249]                    
> [  243.430251] [<ffffffff8125c0ea>] do_sys_open+0x13a/0x200
> [  243.432586]                    
> [  243.432588] [<ffffffff8125c1c9>] SyS_open+0x19/0x20
> [  243.434839]                    
> [  243.434843] [<ffffffff81714e01>] entry_SYSCALL_64_fastpath+0x1f/0xc2
> [  243.437343]  }
> [  243.438115]  ... key      at: [<ffffffffa031dfcc>] xfs_dir_ilock_class+0x0/0xfffffffffffc3f6e [xfs]
> [  243.440082]  ... acquired at:
> [  243.441047]    
> [  243.441049] [<ffffffff810ee7ea>] check_irq_usage+0x4a/0xb0
> [  243.443169]    
> [  243.443171] [<ffffffff810f0954>] __lock_acquire+0x1364/0x1bb0
> [  243.445366]    
> [  243.445368] [<ffffffff810f1840>] lock_acquire+0xe0/0x2a0
> [  243.447471]    
> [  243.447474] [<ffffffff8108de18>] get_online_cpus+0x58/0x80
> [  243.449601]    
> [  243.449604] [<ffffffff811bf3a7>] drain_all_pages.part.80+0x27/0x320
> [  243.452123]    
> [  243.452125] [<ffffffff811c2039>] drain_all_pages+0x19/0x20
> [  243.454264]    
> [  243.454266] [<ffffffff811c4854>] __alloc_pages_nodemask+0x784/0x1630
> [  243.456596]    
> [  243.456599] [<ffffffff8122e1bf>] cache_grow_begin+0xcf/0x630
> [  243.458774]    
> [  243.458776] [<ffffffff8122eb45>] fallback_alloc+0x1e5/0x290
> [  243.460952]    
> [  243.460955] [<ffffffff8122e955>] ____cache_alloc_node+0x235/0x240
> [  243.463199]    
> [  243.463201] [<ffffffff8122f30c>] kmem_cache_alloc+0x26c/0x3e0
> [  243.465482]    
> [  243.465510] [<ffffffffa02b9211>] kmem_zone_alloc+0x91/0x120 [xfs]
> [  243.467754]    
> [  243.467774] [<ffffffffa024e2f5>] xfs_da_state_alloc+0x15/0x20 [xfs]
> [  243.470083]    
> [  243.470101] [<ffffffffa025f333>] xfs_dir2_node_lookup+0x53/0x2b0 [xfs]
> [  243.472427]    
> [  243.472445] [<ffffffffa0255ac5>] xfs_dir_lookup+0x1a5/0x1c0 [xfs]
> [  243.474705]    
> [  243.474726] [<ffffffffa02a62ff>] xfs_lookup+0x7f/0x250 [xfs]
> [  243.476933]    
> [  243.476954] [<ffffffffa02a1fcb>] xfs_vn_lookup+0x6b/0xb0 [xfs]
> [  243.479178]    
> [  243.479180] [<ffffffff8126ce2c>] lookup_open+0x54c/0x790
> [  243.481350]    
> [  243.481352] [<ffffffff8126e2fa>] path_openat+0x55a/0xa90
> [  243.483907]    
> [  243.483910] [<ffffffff8126f9ec>] do_filp_open+0x8c/0x100
> [  243.486070]    
> [  243.486073] [<ffffffff8125c0ea>] do_sys_open+0x13a/0x200
> [  243.488334]    
> [  243.488338] [<ffffffff8125c1c9>] SyS_open+0x19/0x20
> [  243.490476]    
> [  243.490480] [<ffffffff81003c17>] do_syscall_64+0x67/0x1f0
> [  243.492619]    
> [  243.492623] [<ffffffff81714ec9>] return_from_SYSCALL_64+0x0/0x7a
> [  243.494864] 
> [  243.495618] 
> [  243.495618] the dependencies between the lock to be acquired
> [  243.495619]  and RECLAIM_FS-irq-unsafe lock:
> [  243.498973] -> (cpu_hotplug.dep_map){++++++} ops: 838 {
> [  243.500297]    HARDIRQ-ON-W at:
> [  243.501292]                     
> [  243.501295] [<ffffffff810efd84>] __lock_acquire+0x794/0x1bb0
> [  243.503718]                     
> [  243.503719] [<ffffffff810f1840>] lock_acquire+0xe0/0x2a0
> [  243.506059]                     
> [  243.506061] [<ffffffff8108ff5e>] cpu_hotplug_begin+0x6e/0xe0
> [  243.508471]                     
> [  243.508473] [<ffffffff8109009d>] _cpu_up+0x2d/0xf0
> [  243.510708]                     
> [  243.510709] [<ffffffff810901e4>] do_cpu_up+0x84/0xd0
> [  243.512997]                     
> [  243.512999] [<ffffffff8109023e>] cpu_up+0xe/0x10
> [  243.515556]                     
> [  243.515561] [<ffffffff81f6f446>] smp_init+0xd5/0x141
> [  243.517807]                     
> [  243.517810] [<ffffffff81f3f35b>] kernel_init_freeable+0x17d/0x2a7
> [  243.520271]                     
> [  243.520275] [<ffffffff817048e9>] kernel_init+0x9/0x100
> [  243.522538]                     
> [  243.522540] [<ffffffff81715081>] ret_from_fork+0x31/0x40
> [  243.524833]    HARDIRQ-ON-R at:
> [  243.525801]                     
> [  243.525803] [<ffffffff810ef8c0>] __lock_acquire+0x2d0/0x1bb0
> [  243.528152]                     
> [  243.528153] [<ffffffff810f1840>] lock_acquire+0xe0/0x2a0
> [  243.530416]                     
> [  243.530419] [<ffffffff8108de18>] get_online_cpus+0x58/0x80
> [  243.532696]                     
> [  243.532698] [<ffffffff811ec375>] kmem_cache_create+0x35/0x2d0
> [  243.535039]                     
> [  243.535041] [<ffffffff81f87d4a>] debug_objects_mem_init+0x48/0x5c5
> [  243.537451]                     
> [  243.537453] [<ffffffff81f3f108>] start_kernel+0x3ec/0x4c2
> [  243.539744]                     
> [  243.539746] [<ffffffff81f3e5d6>] x86_64_start_reservations+0x2a/0x2c
> [  243.542186]                     
> [  243.542188] [<ffffffff81f3e724>] x86_64_start_kernel+0x14c/0x16f
> [  243.544603]                     
> [  243.544605] [<ffffffff810001c4>] verify_cpu+0x0/0xfc
> [  243.547245]    SOFTIRQ-ON-W at:
> [  243.548241]                     
> [  243.548243] [<ffffffff810ef8ed>] __lock_acquire+0x2fd/0x1bb0
> [  243.550559]                     
> [  243.550561] [<ffffffff810f1840>] lock_acquire+0xe0/0x2a0
> [  243.552841]                     
> [  243.552842] [<ffffffff8108ff5e>] cpu_hotplug_begin+0x6e/0xe0
> [  243.555186]                     
> [  243.555187] [<ffffffff8109009d>] _cpu_up+0x2d/0xf0
> [  243.557404]                     
> [  243.557405] [<ffffffff810901e4>] do_cpu_up+0x84/0xd0
> [  243.559654]                     
> [  243.559656] [<ffffffff8109023e>] cpu_up+0xe/0x10
> [  243.561824]                     
> [  243.561827] [<ffffffff81f6f446>] smp_init+0xd5/0x141
> [  243.564048]                     
> [  243.564050] [<ffffffff81f3f35b>] kernel_init_freeable+0x17d/0x2a7
> [  243.566455]                     
> [  243.566457] [<ffffffff817048e9>] kernel_init+0x9/0x100
> [  243.568731]                     
> [  243.568733] [<ffffffff81715081>] ret_from_fork+0x31/0x40
> [  243.571014]    SOFTIRQ-ON-R at:
> [  243.571975]                     
> [  243.571976] [<ffffffff810ef8ed>] __lock_acquire+0x2fd/0x1bb0
> [  243.574328]                     
> [  243.574330] [<ffffffff810f1840>] lock_acquire+0xe0/0x2a0
> [  243.576610]                     
> [  243.576612] [<ffffffff8108de18>] get_online_cpus+0x58/0x80
> [  243.579161]                     
> [  243.579165] [<ffffffff811ec375>] kmem_cache_create+0x35/0x2d0
> [  243.581537]                     
> [  243.581539] [<ffffffff81f87d4a>] debug_objects_mem_init+0x48/0x5c5
> [  243.583982]                     
> [  243.583984] [<ffffffff81f3f108>] start_kernel+0x3ec/0x4c2
> [  243.586304]                     
> [  243.586306] [<ffffffff81f3e5d6>] x86_64_start_reservations+0x2a/0x2c
> [  243.588819]                     
> [  243.588821] [<ffffffff81f3e724>] x86_64_start_kernel+0x14c/0x16f
> [  243.591227]                     
> [  243.591229] [<ffffffff810001c4>] verify_cpu+0x0/0xfc
> [  243.593507]    RECLAIM_FS-ON-W at:
> [  243.594519]                        
> [  243.594520] [<ffffffff810ef051>] mark_held_locks+0x71/0x90
> [  243.596888]                        
> [  243.596895] [<ffffffff810f3405>] lockdep_trace_alloc+0xc5/0x110
> [  243.599331]                        
> [  243.599334] [<ffffffff8122f8ca>] kmem_cache_alloc_node_trace+0x4a/0x410
> [  243.601872]                        
> [  243.601874] [<ffffffff810ba350>] __smpboot_create_thread.part.3+0x30/0xf0
> [  243.604460]                        
> [  243.604461] [<ffffffff810ba7a1>] smpboot_create_threads+0x61/0x90
> [  243.606950]                        
> [  243.606952] [<ffffffff8108e2cb>] cpuhp_invoke_callback+0xbb/0xb70
> [  243.609463]                        
> [  243.609465] [<ffffffff8108fc82>] cpuhp_up_callbacks+0x32/0xb0
> [  243.612282]                        
> [  243.612285] [<ffffffff810900f4>] _cpu_up+0x84/0xf0
> [  243.614604]                        
> [  243.614606] [<ffffffff810901e4>] do_cpu_up+0x84/0xd0
> [  243.616929]                        
> [  243.616930] [<ffffffff8109023e>] cpu_up+0xe/0x10
> [  243.619208]                        
> [  243.619211] [<ffffffff81f6f446>] smp_init+0xd5/0x141
> [  243.621518]                        
> [  243.621520] [<ffffffff81f3f35b>] kernel_init_freeable+0x17d/0x2a7
> [  243.624018]                        
> [  243.624020] [<ffffffff817048e9>] kernel_init+0x9/0x100
> [  243.626374]                        
> [  243.626376] [<ffffffff81715081>] ret_from_fork+0x31/0x40
> [  243.628771]    RECLAIM_FS-ON-R at:
> [  243.629802]                        
> [  243.629803] [<ffffffff810ef051>] mark_held_locks+0x71/0x90
> [  243.632201]                        
> [  243.632203] [<ffffffff810f3405>] lockdep_trace_alloc+0xc5/0x110
> [  243.634692]                        
> [  243.634695] [<ffffffff8122f8ca>] kmem_cache_alloc_node_trace+0x4a/0x410
> [  243.637277]                        
> [  243.637279] [<ffffffff8100cbb4>] allocate_shared_regs+0x24/0x70
> [  243.639777]                        
> [  243.639779] [<ffffffff8100cc32>] intel_pmu_cpu_prepare+0x32/0x140
> [  243.643062]                        
> [  243.643066] [<ffffffff810053db>] x86_pmu_prepare_cpu+0x3b/0x40
> [  243.645553]                        
> [  243.645556] [<ffffffff8108e2cb>] cpuhp_invoke_callback+0xbb/0xb70
> [  243.648095]                        
> [  243.648097] [<ffffffff8108f29c>] cpuhp_issue_call+0xec/0x160
> [  243.650536]                        
> [  243.650539] [<ffffffff8108f6bb>] __cpuhp_setup_state+0x13b/0x1a0
> [  243.653126]                        
> [  243.653130] [<ffffffff81f427e9>] init_hw_perf_events+0x402/0x5b6
> [  243.655652]                        
> [  243.655655] [<ffffffff8100217c>] do_one_initcall+0x4c/0x1b0
> [  243.658127]                        
> [  243.658130] [<ffffffff81f3f333>] kernel_init_freeable+0x155/0x2a7
> [  243.660653]                        
> [  243.660656] [<ffffffff817048e9>] kernel_init+0x9/0x100
> [  243.663048]                        
> [  243.663050] [<ffffffff81715081>] ret_from_fork+0x31/0x40
> [  243.665436]    INITIAL USE at:
> [  243.666403]                    
> [  243.666405] [<ffffffff810ef960>] __lock_acquire+0x370/0x1bb0
> [  243.668790]                    
> [  243.668791] [<ffffffff810f1840>] lock_acquire+0xe0/0x2a0
> [  243.671093]                    
> [  243.671095] [<ffffffff8108de18>] get_online_cpus+0x58/0x80
> [  243.673455]                    
> [  243.673458] [<ffffffff8108f5be>] __cpuhp_setup_state+0x3e/0x1a0
> [  243.676126]                    
> [  243.676130] [<ffffffff81f7660e>] page_alloc_init+0x23/0x3a
> [  243.678510]                    
> [  243.678512] [<ffffffff81f3eebe>] start_kernel+0x1a2/0x4c2
> [  243.680851]                    
> [  243.680853] [<ffffffff81f3e5d6>] x86_64_start_reservations+0x2a/0x2c
> [  243.683367]                    
> [  243.683369] [<ffffffff81f3e724>] x86_64_start_kernel+0x14c/0x16f
> [  243.685812]                    
> [  243.685815] [<ffffffff810001c4>] verify_cpu+0x0/0xfc
> [  243.688133]  }
> [  243.688907]  ... key      at: [<ffffffff81c56848>] cpu_hotplug+0x108/0x140
> [  243.690542]  ... acquired at:
> [  243.691514]    
> [  243.691517] [<ffffffff810ee7ea>] check_irq_usage+0x4a/0xb0
> [  243.693655]    
> [  243.693656] [<ffffffff810f0954>] __lock_acquire+0x1364/0x1bb0
> [  243.695820]    
> [  243.695822] [<ffffffff810f1840>] lock_acquire+0xe0/0x2a0
> [  243.697926]    
> [  243.697929] [<ffffffff8108de18>] get_online_cpus+0x58/0x80
> [  243.700042]    
> [  243.700044] [<ffffffff811bf3a7>] drain_all_pages.part.80+0x27/0x320
> [  243.702285]    
> [  243.702286] [<ffffffff811c2039>] drain_all_pages+0x19/0x20
> [  243.704405]    
> [  243.704407] [<ffffffff811c4854>] __alloc_pages_nodemask+0x784/0x1630
> [  243.706721]    
> [  243.706724] [<ffffffff8122e1bf>] cache_grow_begin+0xcf/0x630
> [  243.708867]    
> [  243.708870] [<ffffffff8122eb45>] fallback_alloc+0x1e5/0x290
> [  243.711000]    
> [  243.711002] [<ffffffff8122e955>] ____cache_alloc_node+0x235/0x240
> [  243.713211]    
> [  243.713213] [<ffffffff8122f30c>] kmem_cache_alloc+0x26c/0x3e0
> [  243.715366]    
> [  243.715410] [<ffffffffa02b9211>] kmem_zone_alloc+0x91/0x120 [xfs]
> [  243.717625]    
> [  243.717644] [<ffffffffa024e2f5>] xfs_da_state_alloc+0x15/0x20 [xfs]
> [  243.719889]    
> [  243.719918] [<ffffffffa025f333>] xfs_dir2_node_lookup+0x53/0x2b0 [xfs]
> [  243.722224]    
> [  243.722242] [<ffffffffa0255ac5>] xfs_dir_lookup+0x1a5/0x1c0 [xfs]
> [  243.724493]    
> [  243.724514] [<ffffffffa02a62ff>] xfs_lookup+0x7f/0x250 [xfs]
> [  243.726690]    
> [  243.726710] [<ffffffffa02a1fcb>] xfs_vn_lookup+0x6b/0xb0 [xfs]
> [  243.728933]    
> [  243.728936] [<ffffffff8126ce2c>] lookup_open+0x54c/0x790
> [  243.731064]    
> [  243.731066] [<ffffffff8126e2fa>] path_openat+0x55a/0xa90
> [  243.733192]    
> [  243.733194] [<ffffffff8126f9ec>] do_filp_open+0x8c/0x100
> [  243.735312]    
> [  243.735315] [<ffffffff8125c0ea>] do_sys_open+0x13a/0x200
> [  243.737523]    
> [  243.737527] [<ffffffff8125c1c9>] SyS_open+0x19/0x20
> [  243.739577]    
> [  243.739579] [<ffffffff81003c17>] do_syscall_64+0x67/0x1f0
> [  243.741702]    
> [  243.741706] [<ffffffff81714ec9>] return_from_SYSCALL_64+0x0/0x7a
> [  243.743932] 
> [  243.744661] 
> [  243.744661] stack backtrace:
> [  243.746302] CPU: 1 PID: 8767 Comm: awk Not tainted 4.10.0-rc6-next-20170202 #46
> [  243.747963] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
> [  243.750166] Call Trace:
> [  243.751071]  dump_stack+0x85/0xc9
> [  243.752110]  check_usage+0x4f9/0x680
> [  243.753188]  check_irq_usage+0x4a/0xb0
> [  243.754280]  __lock_acquire+0x1364/0x1bb0
> [  243.755410]  lock_acquire+0xe0/0x2a0
> [  243.756467]  ? get_online_cpus+0x32/0x80
> [  243.757580]  get_online_cpus+0x58/0x80
> [  243.758664]  ? get_online_cpus+0x32/0x80
> [  243.759764]  drain_all_pages.part.80+0x27/0x320
> [  243.760972]  drain_all_pages+0x19/0x20
> [  243.762039]  __alloc_pages_nodemask+0x784/0x1630
> [  243.763249]  ? rcu_read_lock_sched_held+0x91/0xa0
> [  243.764466]  ? __alloc_pages_nodemask+0x2e6/0x1630
> [  243.765689]  ? mark_held_locks+0x71/0x90
> [  243.766780]  ? cache_grow_begin+0x4ac/0x630
> [  243.767912]  cache_grow_begin+0xcf/0x630
> [  243.768985]  ? ____cache_alloc_node+0x1bf/0x240
> [  243.770173]  fallback_alloc+0x1e5/0x290
> [  243.771233]  ____cache_alloc_node+0x235/0x240
> [  243.772403]  ? kmem_zone_alloc+0x91/0x120 [xfs]
> [  243.773576]  kmem_cache_alloc+0x26c/0x3e0
> [  243.774671]  kmem_zone_alloc+0x91/0x120 [xfs]
> [  243.775816]  xfs_da_state_alloc+0x15/0x20 [xfs]
> [  243.776989]  xfs_dir2_node_lookup+0x53/0x2b0 [xfs]
> [  243.778188]  xfs_dir_lookup+0x1a5/0x1c0 [xfs]
> [  243.779327]  xfs_lookup+0x7f/0x250 [xfs]
> [  243.780394]  xfs_vn_lookup+0x6b/0xb0 [xfs]
> [  243.781466]  lookup_open+0x54c/0x790
> [  243.782440]  path_openat+0x55a/0xa90
> [  243.783412]  do_filp_open+0x8c/0x100
> [  243.784377]  ? _raw_spin_unlock+0x22/0x30
> [  243.785418]  ? __alloc_fd+0xf2/0x210
> [  243.786378]  do_sys_open+0x13a/0x200
> [  243.787361]  SyS_open+0x19/0x20
> [  243.788252]  do_syscall_64+0x67/0x1f0
> [  243.789228]  entry_SYSCALL64_slow_path+0x25/0x25
> [  243.790347] RIP: 0033:0x7fcf8dda06c7
> [  243.791299] RSP: 002b:00007ffd883327b8 EFLAGS: 00000246 ORIG_RAX: 0000000000000002
> [  243.792895] RAX: ffffffffffffffda RBX: 00007ffd883328a8 RCX: 00007fcf8dda06c7
> [  243.794424] RDX: 00007fcf8dfa9148 RSI: 0000000000080000 RDI: 00007fcf8dfa6b08
> [  243.795949] RBP: 00007ffd88332810 R08: 00007ffd88332890 R09: 0000000000000000
> [  243.797480] R10: 00007fcf8dfa6b08 R11: 0000000000000246 R12: 0000000000000000
> [  243.799002] R13: 0000000000000000 R14: 0000000000000000 R15: 00007ffd88332890
> [  253.543441] awk invoked oom-killer: gfp_mask=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), nodemask=(null),  order=0, oom_score_adj=0
> [  253.546121] awk cpuset=/ mems_allowed=0
> [  253.547233] CPU: 3 PID: 8767 Comm: awk Not tainted 4.10.0-rc6-next-20170202 #46

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
