Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C22956B0033
	for <linux-mm@kvack.org>; Sun,  5 Feb 2017 05:46:53 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id y143so76201125pfb.6
        for <linux-mm@kvack.org>; Sun, 05 Feb 2017 02:46:53 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g12si30623559pla.248.2017.02.05.02.46.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 05 Feb 2017 02:46:51 -0800 (PST)
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages per zone
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201701290027.AFB30799.FVtFLOOOJMSHQF@I-love.SAKURA.ne.jp>
	<20170130085546.GF8443@dhcp22.suse.cz>
	<20170202101415.GE22806@dhcp22.suse.cz>
	<201702031957.AGH86961.MLtOQVFOSHJFFO@I-love.SAKURA.ne.jp>
	<20170203145548.GC19325@dhcp22.suse.cz>
In-Reply-To: <20170203145548.GC19325@dhcp22.suse.cz>
Message-Id: <201702051943.CFB35412.OOSJVtLFOFQHMF@I-love.SAKURA.ne.jp>
Date: Sun, 5 Feb 2017 19:43:07 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: hch@lst.de, mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, peterz@infradead.org

Michal Hocko wrote:
> [CC Petr]
> 
> On Fri 03-02-17 19:57:39, Tetsuo Handa wrote:
> [...]
> > (2) I got a lockdep warning. (A new false positive?)
> 
> Yes, I suspect this is a false possitive. I do not see how we can
> deadlock. __alloc_pages_direct_reclaim calls drain_all_pages(NULL) which
> means that a potential recursion to the page allocator during draining
> would just bail out on the trylock. Maybe I am misinterpreting the
> report though.
> 

I got same warning with ext4. Maybe we need to check carefully.

[  511.215743] =====================================================
[  511.218003] WARNING: RECLAIM_FS-safe -> RECLAIM_FS-unsafe lock order detected
[  511.220031] 4.10.0-rc6-next-20170202+ #500 Not tainted
[  511.221689] -----------------------------------------------------
[  511.223579] a.out/49302 [HC0[0]:SC0[0]:HE1:SE1] is trying to acquire:
[  511.225533]  (cpu_hotplug.dep_map){++++++}, at: [<ffffffff810a1477>] get_online_cpus+0x37/0x80
[  511.227795] 
[  511.227795] and this task is already holding:
[  511.230082]  (jbd2_handle){++++-.}, at: [<ffffffff813a8be7>] start_this_handle+0x1a7/0x590
[  511.232592] which would create a new lock dependency:
[  511.234192]  (jbd2_handle){++++-.} -> (cpu_hotplug.dep_map){++++++}
[  511.235966] 
[  511.235966] but this new dependency connects a RECLAIM_FS-irq-safe lock:
[  511.238563]  (jbd2_handle){++++-.}
[  511.238564] 
[  511.238564] ... which became RECLAIM_FS-irq-safe at:
[  511.242078]   
[  511.242084] [<ffffffff811089db>] __lock_acquire+0x34b/0x1640
[  511.244492]   
[  511.244495] [<ffffffff8110a119>] lock_acquire+0xc9/0x250
[  511.246694]   
[  511.246697] [<ffffffff813b3525>] jbd2_log_wait_commit+0x55/0x1d0
[  511.249323]   
[  511.249328] [<ffffffff813b59b1>] jbd2_complete_transaction+0x71/0x90
[  511.252069]   
[  511.252074] [<ffffffff813592d6>] ext4_evict_inode+0x356/0x760
[  511.254753]   
[  511.254757] [<ffffffff812c9f61>] evict+0xd1/0x1a0
[  511.257062]   
[  511.257065] [<ffffffff812ca07d>] dispose_list+0x4d/0x80
[  511.259531]   
[  511.259535] [<ffffffff812cb3da>] prune_icache_sb+0x5a/0x80
[  511.261953]   
[  511.261957] [<ffffffff812acf41>] super_cache_scan+0x141/0x190
[  511.264540]   
[  511.264545] [<ffffffff812102ef>] shrink_slab+0x29f/0x6d0
[  511.267165]   
[  511.267171] [<ffffffff812154aa>] shrink_node+0x2fa/0x310
[  511.269455]   
[  511.269459] [<ffffffff812169d2>] kswapd+0x362/0x9b0
[  511.271831]   
[  511.271834] [<ffffffff810ca72f>] kthread+0x10f/0x150
[  511.274031]   
[  511.274035] [<ffffffff818531c1>] ret_from_fork+0x31/0x40
[  511.276216] 
[  511.276216] to a RECLAIM_FS-irq-unsafe lock:
[  511.278128]  (cpu_hotplug.dep_map){++++++}
[  511.278130] 
[  511.278130] ... which became RECLAIM_FS-irq-unsafe at:
[  511.281809] ...
[  511.281811]   
[  511.282598] [<ffffffff81108141>] mark_held_locks+0x71/0x90
[  511.284852]   
[  511.284854] [<ffffffff8110ab6f>] lockdep_trace_alloc+0x6f/0xd0
[  511.287215]   
[  511.287218] [<ffffffff812744c8>] kmem_cache_alloc_node_trace+0x48/0x3b0
[  511.289751]   
[  511.289755] [<ffffffff810cfa65>] __smpboot_create_thread.part.2+0x35/0xf0
[  511.292326]   
[  511.292329] [<ffffffff810d0026>] smpboot_create_threads+0x66/0x90
[  511.295025]   
[  511.295030] [<ffffffff810a2239>] cpuhp_invoke_callback+0x229/0x9e0
[  511.299245]   
[  511.299253] [<ffffffff810a2b57>] cpuhp_up_callbacks+0x37/0xb0
[  511.301889]   
[  511.301894] [<ffffffff810a37b9>] _cpu_up+0x89/0xf0
[  511.304270]   
[  511.304275] [<ffffffff810a38a5>] do_cpu_up+0x85/0xb0
[  511.306428]   
[  511.306431] [<ffffffff810a38e3>] cpu_up+0x13/0x20
[  511.308533]   
[  511.308535] [<ffffffff821eeee3>] smp_init+0x6b/0xcc
[  511.310710]   
[  511.310713] [<ffffffff821c3399>] kernel_init_freeable+0x17d/0x2ac
[  511.313232]   
[  511.313235] [<ffffffff81841b3e>] kernel_init+0xe/0x110
[  511.315616]   
[  511.315620] [<ffffffff818531c1>] ret_from_fork+0x31/0x40
[  511.317867] 
[  511.317867] other info that might help us debug this:
[  511.317867] 
[  511.320920]  Possible interrupt unsafe locking scenario:
[  511.320920] 
[  511.323218]        CPU0                    CPU1
[  511.324622]        ----                    ----
[  511.325973]   lock(cpu_hotplug.dep_map);
[  511.327246]                                local_irq_disable();
[  511.328870]                                lock(jbd2_handle);
[  511.330483]                                lock(cpu_hotplug.dep_map);
[  511.332259]   <Interrupt>
[  511.333187]     lock(jbd2_handle);
[  511.334304] 
[  511.334304]  *** DEADLOCK ***
[  511.334304] 
[  511.336749] 4 locks held by a.out/49302:
[  511.338129]  #0:  (sb_writers#8){.+.+.+}, at: [<ffffffff812d11d4>] mnt_want_write+0x24/0x50
[  511.340768]  #1:  (&type->i_mutex_dir_key#3){++++++}, at: [<ffffffff812ba06b>] path_openat+0x60b/0xd50
[  511.343744]  #2:  (jbd2_handle){++++-.}, at: [<ffffffff813a8be7>] start_this_handle+0x1a7/0x590
[  511.345743]  #3:  (pcpu_drain_mutex){+.+...}, at: [<ffffffff811fc96f>] drain_all_pages.part.89+0x1f/0x2c0
[  511.348605] 
[  511.348605] the dependencies between RECLAIM_FS-irq-safe lock and the holding lock:
[  511.351336] -> (jbd2_handle){++++-.} ops: 203220 {
[  511.352768]    HARDIRQ-ON-W at:
[  511.353827]                     
[  511.353833] [<ffffffff8110906e>] __lock_acquire+0x9de/0x1640
[  511.356489]                     
[  511.356492] [<ffffffff8110a119>] lock_acquire+0xc9/0x250
[  511.359063]                     
[  511.359067] [<ffffffff813b3525>] jbd2_log_wait_commit+0x55/0x1d0
[  511.361905]                     
[  511.361908] [<ffffffff813b59b1>] jbd2_complete_transaction+0x71/0x90
[  511.364560]                     
[  511.364563] [<ffffffff8134bec7>] ext4_sync_file+0x2e7/0x5e0
[  511.367362]                     
[  511.367367] [<ffffffff812e74ad>] vfs_fsync_range+0x3d/0xb0
[  511.369950]                     
[  511.369953] [<ffffffff812e757d>] do_fsync+0x3d/0x70
[  511.372400]                     
[  511.372402] [<ffffffff812e7840>] SyS_fsync+0x10/0x20
[  511.374821]                     
[  511.374824] [<ffffffff81003c3c>] do_syscall_64+0x6c/0x200
[  511.377422]                     
[  511.377425] [<ffffffff81853009>] return_from_SYSCALL_64+0x0/0x7a
[  511.380273]    HARDIRQ-ON-R at:
[  511.381791]                     
[  511.381815] [<ffffffff8110896d>] __lock_acquire+0x2dd/0x1640
[  511.384693]                     
[  511.384697] [<ffffffff8110a119>] lock_acquire+0xc9/0x250
[  511.387195]                     
[  511.387198] [<ffffffff813a8c65>] start_this_handle+0x225/0x590
[  511.389888]                     
[  511.389891] [<ffffffff813a9639>] jbd2__journal_start+0xe9/0x340
[  511.392522]                     
[  511.392525] [<ffffffff8138adaa>] __ext4_journal_start_sb+0x9a/0x240
[  511.395341]                     
[  511.395344] [<ffffffff8134af58>] ext4_file_open+0x188/0x230
[  511.397886]                     
[  511.397889] [<ffffffff812a53cb>] do_dentry_open+0x22b/0x340
[  511.400727]                     
[  511.400730] [<ffffffff812a6922>] vfs_open+0x52/0x80
[  511.403297]                     
[  511.403301] [<ffffffff812b9f02>] path_openat+0x4a2/0xd50
[  511.405752]                     
[  511.405755] [<ffffffff812bba51>] do_filp_open+0x91/0x100
[  511.408229]                     
[  511.408231] [<ffffffff812a6d44>] do_sys_open+0x124/0x210
[  511.410820]                     
[  511.410822] [<ffffffff812a6e4e>] SyS_open+0x1e/0x20
[  511.413158]                     
[  511.413161] [<ffffffff81852f41>] entry_SYSCALL_64_fastpath+0x1f/0xc2
[  511.416074]    SOFTIRQ-ON-W at:
[  511.417069]                     
[  511.417073] [<ffffffff81108996>] __lock_acquire+0x306/0x1640
[  511.419681]                     
[  511.419684] [<ffffffff8110a119>] lock_acquire+0xc9/0x250
[  511.422516]                     
[  511.422520] [<ffffffff813b3525>] jbd2_log_wait_commit+0x55/0x1d0
[  511.425157]                     
[  511.425160] [<ffffffff813b59b1>] jbd2_complete_transaction+0x71/0x90
[  511.427862]                     
[  511.427865] [<ffffffff8134bec7>] ext4_sync_file+0x2e7/0x5e0
[  511.430379]                     
[  511.430382] [<ffffffff812e74ad>] vfs_fsync_range+0x3d/0xb0
[  511.433412]                     
[  511.433418] [<ffffffff812e757d>] do_fsync+0x3d/0x70
[  511.436064]                     
[  511.436067] [<ffffffff812e7840>] SyS_fsync+0x10/0x20
[  511.438498]                     
[  511.438502] [<ffffffff81003c3c>] do_syscall_64+0x6c/0x200
[  511.441519]                     
[  511.441524] [<ffffffff81853009>] return_from_SYSCALL_64+0x0/0x7a
[  511.444325]    SOFTIRQ-ON-R at:
[  511.445358]                     
[  511.445362] [<ffffffff81108996>] __lock_acquire+0x306/0x1640
[  511.448298]                     
[  511.448312] [<ffffffff8110a119>] lock_acquire+0xc9/0x250
[  511.451096]                     
[  511.451100] [<ffffffff813a8c65>] start_this_handle+0x225/0x590
[  511.453784]                     
[  511.453786] [<ffffffff813a9639>] jbd2__journal_start+0xe9/0x340
[  511.456659]                     
[  511.456664] [<ffffffff8138adaa>] __ext4_journal_start_sb+0x9a/0x240
[  511.459638]                     
[  511.459643] [<ffffffff8134af58>] ext4_file_open+0x188/0x230
[  511.462384]                     
[  511.462389] [<ffffffff812a53cb>] do_dentry_open+0x22b/0x340
[  511.465550]                     
[  511.465558] [<ffffffff812a6922>] vfs_open+0x52/0x80
[  511.468141]                     
[  511.468145] [<ffffffff812b9f02>] path_openat+0x4a2/0xd50
[  511.470816]                     
[  511.470819] [<ffffffff812bba51>] do_filp_open+0x91/0x100
[  511.473441]                     
[  511.473443] [<ffffffff812a6d44>] do_sys_open+0x124/0x210
[  511.476079]                     
[  511.476081] [<ffffffff812a6e4e>] SyS_open+0x1e/0x20
[  511.478584]                     
[  511.478587] [<ffffffff81852f41>] entry_SYSCALL_64_fastpath+0x1f/0xc2
[  511.481394]    IN-RECLAIM_FS-W at:
[  511.482680]                        
[  511.482691] [<ffffffff811089db>] __lock_acquire+0x34b/0x1640
[  511.485262]                        
[  511.485264] [<ffffffff8110a119>] lock_acquire+0xc9/0x250
[  511.487862]                        
[  511.487865] [<ffffffff813b3525>] jbd2_log_wait_commit+0x55/0x1d0
[  511.490707]                        
[  511.490710] [<ffffffff813b59b1>] jbd2_complete_transaction+0x71/0x90
[  511.493524]                        
[  511.493527] [<ffffffff813592d6>] ext4_evict_inode+0x356/0x760
[  511.496251]                        
[  511.496255] [<ffffffff812c9f61>] evict+0xd1/0x1a0
[  511.498817]                        
[  511.498821] [<ffffffff812ca07d>] dispose_list+0x4d/0x80
[  511.501361]                        
[  511.501364] [<ffffffff812cb3da>] prune_icache_sb+0x5a/0x80
[  511.504069]                        
[  511.504072] [<ffffffff812acf41>] super_cache_scan+0x141/0x190
[  511.506890]                        
[  511.506895] [<ffffffff812102ef>] shrink_slab+0x29f/0x6d0
[  511.509465]                        
[  511.509467] [<ffffffff812154aa>] shrink_node+0x2fa/0x310
[  511.512228]                        
[  511.512233] [<ffffffff812169d2>] kswapd+0x362/0x9b0
[  511.514724]                        
[  511.514728] [<ffffffff810ca72f>] kthread+0x10f/0x150
[  511.517264]                        
[  511.517269] [<ffffffff818531c1>] ret_from_fork+0x31/0x40
[  511.519827]    INITIAL USE at:
[  511.520829]                    
[  511.520833] [<ffffffff811089ff>] __lock_acquire+0x36f/0x1640
[  511.523377]                    
[  511.523380] [<ffffffff8110a119>] lock_acquire+0xc9/0x250
[  511.525781]                    
[  511.525784] [<ffffffff813a8c65>] start_this_handle+0x225/0x590
[  511.528372]                    
[  511.528375] [<ffffffff813a9639>] jbd2__journal_start+0xe9/0x340
[  511.531138]                    
[  511.531141] [<ffffffff8138adaa>] __ext4_journal_start_sb+0x9a/0x240
[  511.533905]                    
[  511.533908] [<ffffffff8134af58>] ext4_file_open+0x188/0x230
[  511.536467]                    
[  511.536471] [<ffffffff812a53cb>] do_dentry_open+0x22b/0x340
[  511.538990]                    
[  511.538992] [<ffffffff812a6922>] vfs_open+0x52/0x80
[  511.541457]                    
[  511.541461] [<ffffffff812b9f02>] path_openat+0x4a2/0xd50
[  511.544036]                    
[  511.544039] [<ffffffff812bba51>] do_filp_open+0x91/0x100
[  511.546642]                    
[  511.546644] [<ffffffff812a6d44>] do_sys_open+0x124/0x210
[  511.549354]                    
[  511.549370] [<ffffffff812a6e4e>] SyS_open+0x1e/0x20
[  511.551781]                    
[  511.551784] [<ffffffff81852f41>] entry_SYSCALL_64_fastpath+0x1f/0xc2
[  511.554410]  }
[  511.555145]  ... key      at: [<ffffffff8335b518>] jbd2_trans_commit_key.48870+0x0/0x8
[  511.557051]  ... acquired at:
[  511.558047]    
[  511.558050] [<ffffffff81107d0a>] check_irq_usage+0x4a/0xb0
[  511.560268]    
[  511.560270] [<ffffffff8110950b>] __lock_acquire+0xe7b/0x1640
[  511.562536]    
[  511.562538] [<ffffffff8110a119>] lock_acquire+0xc9/0x250
[  511.564779]    
[  511.564783] [<ffffffff810a149d>] get_online_cpus+0x5d/0x80
[  511.567230]    
[  511.567234] [<ffffffff811fc97c>] drain_all_pages.part.89+0x2c/0x2c0
[  511.569585]    
[  511.569588] [<ffffffff812a1cfb>] __alloc_pages_slowpath+0x509/0xe36
[  511.572289]    
[  511.572292] [<ffffffff812018a2>] __alloc_pages_nodemask+0x382/0x3d0
[  511.574744]    
[  511.574747] [<ffffffff81265077>] alloc_pages_current+0x97/0x1b0
[  511.577103]    
[  511.577106] [<ffffffff811f22fd>] __page_cache_alloc+0x15d/0x1a0
[  511.579483]    
[  511.579486] [<ffffffff811f494a>] pagecache_get_page+0x5a/0x2b0
[  511.581935]    
[  511.581940] [<ffffffff812eca32>] __getblk_gfp+0x112/0x390
[  511.584220]    
[  511.584223] [<ffffffff813514ca>] __ext4_get_inode_loc+0x10a/0x560
[  511.586627]    
[  511.586630] [<ffffffff81353e50>] ext4_get_inode_loc+0x20/0x30
[  511.589802]    
[  511.589808] [<ffffffff81355ec6>] ext4_reserve_inode_write+0x26/0x90
[  511.592471]    
[  511.592476] [<ffffffff81355fbe>] ext4_mark_inode_dirty+0x8e/0x390
[  511.594926]    
[  511.594930] [<ffffffff8138325a>] ext4_ext_tree_init+0x3a/0x40
[  511.597306]    
[  511.597308] [<ffffffff8134eaaa>] __ext4_new_inode+0x12da/0x1540
[  511.599962]    
[  511.599969] [<ffffffff81363602>] ext4_create+0xd2/0x1a0
[  511.602484]    
[  511.602489] [<ffffffff812b9903>] lookup_open+0x653/0x7b0
[  511.604699]    
[  511.604701] [<ffffffff812ba086>] path_openat+0x626/0xd50
[  511.606890]    
[  511.606893] [<ffffffff812bba51>] do_filp_open+0x91/0x100
[  511.609097]    
[  511.609099] [<ffffffff812a6d44>] do_sys_open+0x124/0x210
[  511.611346]    
[  511.611348] [<ffffffff812a6e4e>] SyS_open+0x1e/0x20
[  511.613431]    
[  511.613434] [<ffffffff81003c3c>] do_syscall_64+0x6c/0x200
[  511.615967]    
[  511.615979] [<ffffffff81853009>] return_from_SYSCALL_64+0x0/0x7a
[  511.618303] 
[  511.619062] 
[  511.619062] the dependencies between the lock to be acquired
[  511.619063]  and RECLAIM_FS-irq-unsafe lock:
[  511.622794] -> (cpu_hotplug.dep_map){++++++} ops: 1130 {
[  511.624286]    HARDIRQ-ON-W at:
[  511.625479]                     
[  511.625485] [<ffffffff8110906e>] __lock_acquire+0x9de/0x1640
[  511.627957]                     
[  511.627959] [<ffffffff8110a119>] lock_acquire+0xc9/0x250
[  511.630609]                     
[  511.630612] [<ffffffff810a3603>] cpu_hotplug_begin+0x73/0xe0
[  511.633682]                     
[  511.633697] [<ffffffff810a3762>] _cpu_up+0x32/0xf0
[  511.636022]                     
[  511.636024] [<ffffffff810a38a5>] do_cpu_up+0x85/0xb0
[  511.638397]                     
[  511.638399] [<ffffffff810a38e3>] cpu_up+0x13/0x20
[  511.640852]                     
[  511.640866] [<ffffffff821eeee3>] smp_init+0x6b/0xcc
[  511.643507]                     
[  511.643511] [<ffffffff821c3399>] kernel_init_freeable+0x17d/0x2ac
[  511.646002]                     
[  511.646005] [<ffffffff81841b3e>] kernel_init+0xe/0x110
[  511.648600]                     
[  511.648611] [<ffffffff818531c1>] ret_from_fork+0x31/0x40
[  511.651115]    HARDIRQ-ON-R at:
[  511.652080]                     
[  511.652084] [<ffffffff8110896d>] __lock_acquire+0x2dd/0x1640
[  511.654554]                     
[  511.654557] [<ffffffff8110a119>] lock_acquire+0xc9/0x250
[  511.656983]                     
[  511.656986] [<ffffffff810a149d>] get_online_cpus+0x5d/0x80
[  511.659442]                     
[  511.659445] [<ffffffff8122a55a>] kmem_cache_create+0x3a/0x2d0
[  511.662336]                     
[  511.662342] [<ffffffff821fd151>] numa_policy_init+0x43/0x24a
[  511.665117]                     
[  511.665121] [<ffffffff821c313c>] start_kernel+0x3f6/0x4d6
[  511.667566]                     
[  511.667568] [<ffffffff821c25d6>] x86_64_start_reservations+0x2a/0x2c
[  511.670245]                     
[  511.670247] [<ffffffff821c2724>] x86_64_start_kernel+0x14c/0x16f
[  511.673050]                     
[  511.673054] [<ffffffff810001c4>] verify_cpu+0x0/0xfc
[  511.675400]    SOFTIRQ-ON-W at:
[  511.676405]                     
[  511.676408] [<ffffffff81108996>] __lock_acquire+0x306/0x1640
[  511.679556]                     
[  511.679563] [<ffffffff8110a119>] lock_acquire+0xc9/0x250
[  511.683155]                     
[  511.683164] [<ffffffff810a3603>] cpu_hotplug_begin+0x73/0xe0
[  511.686224]                     
[  511.686231] [<ffffffff810a3762>] _cpu_up+0x32/0xf0
[  511.689073]                     
[  511.689078] [<ffffffff810a38a5>] do_cpu_up+0x85/0xb0
[  511.691573]                     
[  511.691575] [<ffffffff810a38e3>] cpu_up+0x13/0x20
[  511.694007]                     
[  511.694010] [<ffffffff821eeee3>] smp_init+0x6b/0xcc
[  511.696524]                     
[  511.696528] [<ffffffff821c3399>] kernel_init_freeable+0x17d/0x2ac
[  511.699401]                     
[  511.699405] [<ffffffff81841b3e>] kernel_init+0xe/0x110
[  511.701956]                     
[  511.701959] [<ffffffff818531c1>] ret_from_fork+0x31/0x40
[  511.704520]    SOFTIRQ-ON-R at:
[  511.705530]                     
[  511.705534] [<ffffffff81108996>] __lock_acquire+0x306/0x1640
[  511.708036]                     
[  511.708038] [<ffffffff8110a119>] lock_acquire+0xc9/0x250
[  511.710516]                     
[  511.710518] [<ffffffff810a149d>] get_online_cpus+0x5d/0x80
[  511.713771]                     
[  511.713780] [<ffffffff8122a55a>] kmem_cache_create+0x3a/0x2d0
[  511.716681]                     
[  511.716688] [<ffffffff821fd151>] numa_policy_init+0x43/0x24a
[  511.719450]                     
[  511.719455] [<ffffffff821c313c>] start_kernel+0x3f6/0x4d6
[  511.722114]                     
[  511.722117] [<ffffffff821c25d6>] x86_64_start_reservations+0x2a/0x2c
[  511.724864]                     
[  511.724866] [<ffffffff821c2724>] x86_64_start_kernel+0x14c/0x16f
[  511.727552]                     
[  511.727555] [<ffffffff810001c4>] verify_cpu+0x0/0xfc
[  511.729936]    RECLAIM_FS-ON-W at:
[  511.731059]                        
[  511.731063] [<ffffffff81108141>] mark_held_locks+0x71/0x90
[  511.733851]                        
[  511.733857] [<ffffffff8110ab6f>] lockdep_trace_alloc+0x6f/0xd0
[  511.736601]                        
[  511.736604] [<ffffffff812744c8>] kmem_cache_alloc_node_trace+0x48/0x3b0
[  511.739325]                        
[  511.739329] [<ffffffff810cfa65>] __smpboot_create_thread.part.2+0x35/0xf0
[  511.742499]                        
[  511.742503] [<ffffffff810d0026>] smpboot_create_threads+0x66/0x90
[  511.745233]                        
[  511.745236] [<ffffffff810a2239>] cpuhp_invoke_callback+0x229/0x9e0
[  511.747909]                        
[  511.747911] [<ffffffff810a2b57>] cpuhp_up_callbacks+0x37/0xb0
[  511.750604]                        
[  511.750606] [<ffffffff810a37b9>] _cpu_up+0x89/0xf0
[  511.753180]                        
[  511.753182] [<ffffffff810a38a5>] do_cpu_up+0x85/0xb0
[  511.755982]                        
[  511.755986] [<ffffffff810a38e3>] cpu_up+0x13/0x20
[  511.758565]                        
[  511.758568] [<ffffffff821eeee3>] smp_init+0x6b/0xcc
[  511.761138]                        
[  511.761141] [<ffffffff821c3399>] kernel_init_freeable+0x17d/0x2ac
[  511.763877]                        
[  511.763881] [<ffffffff81841b3e>] kernel_init+0xe/0x110
[  511.766703]                        
[  511.766709] [<ffffffff818531c1>] ret_from_fork+0x31/0x40
[  511.769522]    RECLAIM_FS-ON-R at:
[  511.770730]                        
[  511.770735] [<ffffffff81108141>] mark_held_locks+0x71/0x90
[  511.773324]                        
[  511.773327] [<ffffffff8110ab6f>] lockdep_trace_alloc+0x6f/0xd0
[  511.775897]                        
[  511.775900] [<ffffffff812744c8>] kmem_cache_alloc_node_trace+0x48/0x3b0
[  511.778659]                        
[  511.778663] [<ffffffff8100d199>] allocate_shared_regs+0x29/0x70
[  511.781485]                        
[  511.781488] [<ffffffff8100d217>] intel_pmu_cpu_prepare+0x37/0x140
[  511.784574]                        
[  511.784578] [<ffffffff81005410>] x86_pmu_prepare_cpu+0x40/0x50
[  511.787169]                        
[  511.787172] [<ffffffff810a2239>] cpuhp_invoke_callback+0x229/0x9e0
[  511.789906]                        
[  511.789909] [<ffffffff810a2e42>] cpuhp_issue_call+0xe2/0x140
[  511.792625]                        
[  511.792628] [<ffffffff810a321d>] __cpuhp_setup_state+0x12d/0x190
[  511.795441]                        
[  511.795446] [<ffffffff821c59b1>] init_hw_perf_events+0x402/0x5b6
[  511.798187]                        
[  511.798190] [<ffffffff81002191>] do_one_initcall+0x51/0x1c0
[  511.801133]                        
[  511.801139] [<ffffffff821c3371>] kernel_init_freeable+0x155/0x2ac
[  511.803812]                        
[  511.803816] [<ffffffff81841b3e>] kernel_init+0xe/0x110
[  511.806381]                        
[  511.806385] [<ffffffff818531c1>] ret_from_fork+0x31/0x40
[  511.808849]    INITIAL USE at:
[  511.809876]                    
[  511.809881] [<ffffffff811089ff>] __lock_acquire+0x36f/0x1640
[  511.812607]                    
[  511.812610] [<ffffffff8110a119>] lock_acquire+0xc9/0x250
[  511.815088]                    
[  511.815092] [<ffffffff810a149d>] get_online_cpus+0x5d/0x80
[  511.817776]                    
[  511.817779] [<ffffffff810a3133>] __cpuhp_setup_state+0x43/0x190
[  511.820394]                    
[  511.820397] [<ffffffff821f756b>] page_alloc_init+0x23/0x3a
[  511.823000]                    
[  511.823003] [<ffffffff821c2ee8>] start_kernel+0x1a2/0x4d6
[  511.825495]                    
[  511.825497] [<ffffffff821c25d6>] x86_64_start_reservations+0x2a/0x2c
[  511.828158]                    
[  511.828160] [<ffffffff821c2724>] x86_64_start_kernel+0x14c/0x16f
[  511.830986]                    
[  511.830991] [<ffffffff810001c4>] verify_cpu+0x0/0xfc
[  511.833452]  }
[  511.834219]  ... key      at: [<ffffffff81e59b08>] cpu_hotplug+0x108/0x140
[  511.835931]  ... acquired at:
[  511.836924]    
[  511.836927] [<ffffffff81107d0a>] check_irq_usage+0x4a/0xb0
[  511.839589]    
[  511.839593] [<ffffffff8110950b>] __lock_acquire+0xe7b/0x1640
[  511.842158]    
[  511.842162] [<ffffffff8110a119>] lock_acquire+0xc9/0x250
[  511.844452]    
[  511.844454] [<ffffffff810a149d>] get_online_cpus+0x5d/0x80
[  511.846668]    
[  511.846671] [<ffffffff811fc97c>] drain_all_pages.part.89+0x2c/0x2c0
[  511.849257]    
[  511.849264] [<ffffffff812a1cfb>] __alloc_pages_slowpath+0x509/0xe36
[  511.852127]    
[  511.852132] [<ffffffff812018a2>] __alloc_pages_nodemask+0x382/0x3d0
[  511.854545]    
[  511.854549] [<ffffffff81265077>] alloc_pages_current+0x97/0x1b0
[  511.856942]    
[  511.856946] [<ffffffff811f22fd>] __page_cache_alloc+0x15d/0x1a0
[  511.859259]    
[  511.859262] [<ffffffff811f494a>] pagecache_get_page+0x5a/0x2b0
[  511.861595]    
[  511.861598] [<ffffffff812eca32>] __getblk_gfp+0x112/0x390
[  511.863893]    
[  511.863897] [<ffffffff813514ca>] __ext4_get_inode_loc+0x10a/0x560
[  511.866538]    
[  511.866542] [<ffffffff81353e50>] ext4_get_inode_loc+0x20/0x30
[  511.868929]    
[  511.868932] [<ffffffff81355ec6>] ext4_reserve_inode_write+0x26/0x90
[  511.871579]    
[  511.871584] [<ffffffff81355fbe>] ext4_mark_inode_dirty+0x8e/0x390
[  511.874088]    
[  511.874092] [<ffffffff8138325a>] ext4_ext_tree_init+0x3a/0x40
[  511.876398]    
[  511.876400] [<ffffffff8134eaaa>] __ext4_new_inode+0x12da/0x1540
[  511.878735]    
[  511.878737] [<ffffffff81363602>] ext4_create+0xd2/0x1a0
[  511.881170]    
[  511.881174] [<ffffffff812b9903>] lookup_open+0x653/0x7b0
[  511.883841]    
[  511.883848] [<ffffffff812ba086>] path_openat+0x626/0xd50
[  511.886058]    
[  511.886061] [<ffffffff812bba51>] do_filp_open+0x91/0x100
[  511.888285]    
[  511.888288] [<ffffffff812a6d44>] do_sys_open+0x124/0x210
[  511.890642]    
[  511.890644] [<ffffffff812a6e4e>] SyS_open+0x1e/0x20
[  511.892781]    
[  511.892784] [<ffffffff81003c3c>] do_syscall_64+0x6c/0x200
[  511.895050]    
[  511.895053] [<ffffffff81853009>] return_from_SYSCALL_64+0x0/0x7a
[  511.897382] 
[  511.898165] 
[  511.898165] stack backtrace:
[  511.900033] CPU: 0 PID: 49302 Comm: a.out Not tainted 4.10.0-rc6-next-20170202+ #500
[  511.901974] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  511.904851] Call Trace:
[  511.905789]  dump_stack+0x85/0xc9
[  511.906854]  check_usage+0x4ba/0x4d0
[  511.907984]  ? delayacct_end+0x56/0x60
[  511.909136]  check_irq_usage+0x4a/0xb0
[  511.910318]  __lock_acquire+0xe7b/0x1640
[  511.911470]  ? delayacct_end+0x56/0x60
[  511.912607]  lock_acquire+0xc9/0x250
[  511.913703]  ? get_online_cpus+0x37/0x80
[  511.914888]  get_online_cpus+0x5d/0x80
[  511.916137]  ? get_online_cpus+0x37/0x80
[  511.917287]  drain_all_pages.part.89+0x2c/0x2c0
[  511.918539]  __alloc_pages_slowpath+0x509/0xe36
[  511.919889]  __alloc_pages_nodemask+0x382/0x3d0
[  511.921673]  ? sched_clock_cpu+0x11/0xc0
[  511.922919]  alloc_pages_current+0x97/0x1b0
[  511.924123]  __page_cache_alloc+0x15d/0x1a0
[  511.925252]  pagecache_get_page+0x5a/0x2b0
[  511.926392]  __getblk_gfp+0x112/0x390
[  511.927524]  __ext4_get_inode_loc+0x10a/0x560
[  511.928723]  ? ext4_ext_tree_init+0x3a/0x40
[  511.929900]  ext4_get_inode_loc+0x20/0x30
[  511.931008]  ext4_reserve_inode_write+0x26/0x90
[  511.932370]  ? ext4_ext_tree_init+0x3a/0x40
[  511.933582]  ext4_mark_inode_dirty+0x8e/0x390
[  511.934807]  ext4_ext_tree_init+0x3a/0x40
[  511.935919]  __ext4_new_inode+0x12da/0x1540
[  511.937093]  ext4_create+0xd2/0x1a0
[  511.938106]  lookup_open+0x653/0x7b0
[  511.939108]  ? __wake_up+0x23/0x50
[  511.940131]  ? sched_clock+0x9/0x10
[  511.941184]  path_openat+0x626/0xd50
[  511.942194]  do_filp_open+0x91/0x100
[  511.943164]  ? _raw_spin_unlock+0x27/0x40
[  511.944335]  ? __alloc_fd+0xf7/0x210
[  511.945350]  do_sys_open+0x124/0x210
[  511.946333]  SyS_open+0x1e/0x20
[  511.947189]  do_syscall_64+0x6c/0x200
[  511.948208]  entry_SYSCALL64_slow_path+0x25/0x25
[  511.949587] RIP: 0033:0x7feb6a026a10
[  511.950555] RSP: 002b:00007ffce3579c88 EFLAGS: 00000246 ORIG_RAX: 0000000000000002
[  511.952261] RAX: ffffffffffffffda RBX: 0000000000000003 RCX: 00007feb6a026a10
[  511.953864] RDX: 0000000000000180 RSI: 0000000000004441 RDI: 00000000006010c0
[  511.955566] RBP: 0000000000000000 R08: 00007feb69f86938 R09: 000000000000000f
[  511.957231] R10: 0000000000000000 R11: 0000000000000246 R12: 000000000040083b
[  511.958864] R13: 00007ffce3579d90 R14: 0000000000000000 R15: 0000000000000000

Below one is also a loop. Maybe we can add __GFP_NOMEMALLOC to GFP_NOWAIT ?

[  257.781715] Out of memory: Kill process 5171 (a.out) score 842 or sacrifice child
[  257.784726] Killed process 5171 (a.out) total-vm:2177096kB, anon-rss:1476488kB, file-rss:4kB, shmem-rss:0kB
[  257.787691] a.out(5171): TIF_MEMDIE allocation: order=0 mode=0x1000200(GFP_NOWAIT|__GFP_NOWARN)
[  257.789789] CPU: 3 PID: 5171 Comm: a.out Not tainted 4.10.0-rc6-next-20170202+ #500
[  257.791784] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  257.794700] Call Trace:
[  257.795690]  dump_stack+0x85/0xc9
[  257.797224]  __alloc_pages_slowpath+0xacb/0xe36
[  257.798612]  __alloc_pages_nodemask+0x382/0x3d0
[  257.799942]  alloc_pages_current+0x97/0x1b0
[  257.801236]  __get_free_pages+0x14/0x50
[  257.802546]  __tlb_remove_page_size+0x70/0xd0
[  257.803810]  unmap_page_range+0x74b/0xa80
[  257.804992]  unmap_single_vma+0x81/0xf0
[  257.806131]  unmap_vmas+0x41/0x60
[  257.807179]  exit_mmap+0x97/0x150
[  257.808282]  ? __khugepaged_exit+0xe5/0x130
[  257.809594]  mmput+0x80/0x150
[  257.810566]  do_exit+0x2c0/0xd70
[  257.811609]  do_group_exit+0x4c/0xc0
[  257.813035]  get_signal+0x35f/0x9b0
[  257.814199]  do_signal+0x37/0x730
[  257.815215]  ? mutex_unlock+0x12/0x20
[  257.816285]  ? pagefault_out_of_memory+0x75/0x80
[  257.817872]  ? mm_fault_error+0x65/0x152
[  257.819027]  ? exit_to_usermode_loop+0x26/0x92
[  257.820277]  exit_to_usermode_loop+0x51/0x92
[  257.821480]  prepare_exit_to_usermode+0x7f/0x90
[  257.822756]  retint_user+0x8/0x23
[  257.823755] RIP: 0033:0x400780
[  257.824717] RSP: 002b:00007ffce4497640 EFLAGS: 00010206
[  257.826061] RAX: 000000005a1de000 RBX: 0000000080000000 RCX: 00007f11b8887650
[  257.827774] RDX: 0000000000000000 RSI: 00007ffce4497460 RDI: 00007ffce4497460
[  257.829770] RBP: 00007f10b89be010 R08: 00007ffce4497570 R09: 00007ffce44973b0
[  257.831714] R10: 0000000000000008 R11: 0000000000000246 R12: 0000000000000007
[  257.833447] R13: 00007f10b89be010 R14: 0000000000000000 R15: 0000000000000000

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
