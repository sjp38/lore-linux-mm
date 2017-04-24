Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id A9FFC6B02E1
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:06:50 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 67so69730196ite.6
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 06:06:50 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id v35si9631881ota.24.2017.04.24.06.06.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Apr 2017 06:06:48 -0700 (PDT)
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170309180540.GA8678@cmpxchg.org>
	<20170310102010.GD3753@dhcp22.suse.cz>
	<201703102044.DBJ04626.FLVMFOQOJtOFHS@I-love.SAKURA.ne.jp>
	<201704231924.GDF05718.LQSMtJOOFOFHFV@I-love.SAKURA.ne.jp>
	<20170424123936.GA6152@redhat.com>
In-Reply-To: <20170424123936.GA6152@redhat.com>
Message-Id: <201704242206.IEF52621.HFJLFFtOSVOQMO@I-love.SAKURA.ne.jp>
Date: Mon, 24 Apr 2017 22:06:32 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sgruszka@redhat.com
Cc: mhocko@kernel.org, hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com

Stanislaw Gruszka wrote:
> On Sun, Apr 23, 2017 at 07:24:21PM +0900, Tetsuo Handa wrote:
> > On 2017/03/10 20:44, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > >> I am definitely not against. There is no reason to rush the patch in.
> > > 
> > > I don't hurry if we can check using watchdog whether this problem is occurring
> > > in the real world. I have to test corner cases because watchdog is missing.
> > > 
> > Ping?
> > 
> > This problem can occur even immediately after the first invocation of
> > the OOM killer. I believe this problem can occur in the real world.
> > When are we going to apply this patch or watchdog patch?
> > 
> > ----------------------------------------
> > [    0.000000] Linux version 4.11.0-rc7-next-20170421+ (root@ccsecurity) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-11) (GCC) ) #588 SMP Sun Apr 23 17:38:02 JST 2017
> > [    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-4.11.0-rc7-next-20170421+ root=UUID=17c3c28f-a70a-4666-95fa-ecf6acd901e4 ro vconsole.keymap=jp106 crashkernel=256M vconsole.font=latarcyrheb-sun16 security=none sysrq_always_enabled console=ttyS0,115200n8 console=tty0 LANG=en_US.UTF-8 debug_guardpage_minorder=1
> 
> Are you debugging memory corruption problem?

No. Just a random testing trying to find how we can avoid flooding of
warn_alloc_stall() warning messages while also avoiding ratelimiting.

> 
> FWIW, if you use debug_guardpage_minorder= you can expect any
> allocation memory problems. This option is intended to debug
> memory corruption bugs and it shrinks available memory in 
> artificial way. Taking that, I don't think justifying any
> patch, by problem happened when debug_guardpage_minorder= is 
> used, is reasonable.
>  
> Stanislaw

This problem occurs without debug_guardpage_minorder= parameter and

----------
[    0.000000] Linux version 4.11.0-rc7-next-20170421+ (root@ccsecurity) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-11) (GCC) ) #588 SMP Sun Apr 23 17:38:02 JST 2017
[    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-4.11.0-rc7-next-20170421+ root=UUID=17c3c28f-a70a-4666-95fa-ecf6acd901e4 ro vconsole.keymap=jp106 vconsole.font=latarcyrheb-sun16 security=none sysrq_always_enabled console=ttyS0,115200n8 console=tty0 LANG=en_US.UTF-8
(...snipped...)
CentOS Linux 7 (Core)
Kernel 4.11.0-rc7-next-20170421+ on an x86_64

ccsecurity login: [   31.882531] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   32.550187] Ebtables v2.0 registered
[   32.730371] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   32.926518] IPv6: ADDRCONF(NETDEV_UP): ens32: link is not ready
[   32.928310] e1000: ens32 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
[   32.930960] IPv6: ADDRCONF(NETDEV_CHANGE): ens32: link becomes ready
[   33.741378] Netfilter messages via NETLINK v0.30.
[   33.807350] ip_set: protocol 6
[   37.581002] nf_conntrack: default automatic helper assignment has been turned off for security reasons and CT-based  firewall rule not found. Use the iptables CT target to attach helpers instead.
[   38.072689] IPv6: ADDRCONF(NETDEV_UP): ens35: link is not ready
[   38.074419] e1000: ens35 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
[   38.077222] IPv6: ADDRCONF(NETDEV_CHANGE): ens35: link becomes ready
[   92.753140] gmain invoked oom-killer: gfp_mask=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), nodemask=(null),  order=0, oom_score_adj=0
[   92.763445] gmain cpuset=/ mems_allowed=0
[   92.767634] CPU: 2 PID: 2733 Comm: gmain Not tainted 4.11.0-rc7-next-20170421+ #588
[   92.773624] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   92.781790] Call Trace:
[   92.782630]  ? dump_stack+0x5c/0x7d
[   92.783902]  ? dump_header+0x97/0x233
[   92.785427]  ? ktime_get+0x30/0x90
[   92.786390]  ? delayacct_end+0x35/0x60
[   92.787433]  ? do_try_to_free_pages+0x2ca/0x370
[   92.789157]  ? oom_kill_process+0x223/0x3e0
[   92.790502]  ? has_capability_noaudit+0x17/0x20
[   92.791761]  ? oom_badness+0xeb/0x160
[   92.792783]  ? out_of_memory+0x10b/0x490
[   92.793872]  ? __alloc_pages_slowpath+0x701/0x8e2
[   92.795603]  ? __alloc_pages_nodemask+0x1ed/0x210
[   92.796902]  ? alloc_pages_current+0x7a/0x100
[   92.798115]  ? filemap_fault+0x2e9/0x5e0
[   92.799204]  ? filemap_map_pages+0x185/0x3a0
[   92.800402]  ? xfs_filemap_fault+0x2f/0x50 [xfs]
[   92.801678]  ? __do_fault+0x15/0x70
[   92.802651]  ? __handle_mm_fault+0xb0f/0x11e0
[   92.805141]  ? handle_mm_fault+0xc5/0x220
[   92.807261]  ? __do_page_fault+0x21e/0x4b0
[   92.809203]  ? do_page_fault+0x2b/0x70
[   92.811018]  ? do_syscall_64+0x137/0x140
[   92.812554]  ? page_fault+0x28/0x30
[   92.813855] Mem-Info:
[   92.815009] active_anon:437483 inactive_anon:2097 isolated_anon:0
[   92.815009]  active_file:0 inactive_file:104 isolated_file:41
[   92.815009]  unevictable:0 dirty:10 writeback:0 unstable:0
[   92.815009]  slab_reclaimable:2439 slab_unreclaimable:11018
[   92.815009]  mapped:405 shmem:2162 pagetables:8704 bounce:0
[   92.815009]  free:13168 free_pcp:58 free_cma:0
[   92.825444] Node 0 active_anon:1749932kB inactive_anon:8388kB active_file:0kB inactive_file:592kB unevictable:0kB isolated(anon):0kB isolated(file):164kB mapped:1620kB dirty:40kB writeback:0kB shmem:8648kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 1519616kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[   92.832175] Node 0 DMA free:8148kB min:352kB low:440kB high:528kB active_anon:7696kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:28kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   92.840217] lowmem_reserve[]: 0 1952 1952 1952
[   92.841799] Node 0 DMA32 free:45028kB min:44700kB low:55872kB high:67044kB active_anon:1742236kB inactive_anon:8388kB active_file:0kB inactive_file:992kB unevictable:0kB writepending:40kB present:2080640kB managed:2018376kB mlocked:0kB slab_reclaimable:9756kB slab_unreclaimable:44040kB kernel_stack:22192kB pagetables:34788kB bounce:0kB free_pcp:672kB local_pcp:0kB free_cma:0kB
[   92.850458] lowmem_reserve[]: 0 0 0 0
[   92.851881] Node 0 DMA: 1*4kB (U) 0*8kB 1*16kB (M) 2*32kB (UM) 2*64kB (UM) 2*128kB (UM) 2*256kB (UM) 0*512kB 1*1024kB (U) 1*2048kB (M) 1*4096kB (M) = 8148kB
[   92.855530] Node 0 DMA32: 1023*4kB (UME) 591*8kB (UME) 220*16kB (UME) 223*32kB (UME) 156*64kB (UME) 38*128kB (UME) 12*256kB (UME) 10*512kB (UME) 2*1024kB (M) 0*2048kB 0*4096kB = 44564kB
[   92.860735] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[   92.863216] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   92.865714] 2994 total pagecache pages
[   92.867201] 0 pages in swap cache
[   92.868575] Swap cache stats: add 0, delete 0, find 0/0
[   92.870309] Free swap  = 0kB
[   92.871579] Total swap = 0kB
[   92.873000] 524157 pages RAM
[   92.874351] 0 pages HighMem/MovableOnly
[   92.875809] 15587 pages reserved
[   92.877151] 0 pages cma reserved
[   92.878513] 0 pages hwpoisoned
[   92.879948] Out of memory: Kill process 2983 (a.out) score 998 or sacrifice child
[   92.882182] Killed process 2983 (a.out) total-vm:4172kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[   92.886190] oom_reaper: reaped process 2983 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[   96.072996] a.out invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null),  order=0, oom_score_adj=0
[   96.076683] a.out cpuset=/ mems_allowed=0
[   96.078329] CPU: 3 PID: 2982 Comm: a.out Not tainted 4.11.0-rc7-next-20170421+ #588
[   96.080583] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   96.083254] Call Trace:
[   96.084404]  ? dump_stack+0x5c/0x7d
[   96.085855]  ? dump_header+0x97/0x233
[   96.087393]  ? oom_kill_process+0x223/0x3e0
[   96.089059]  ? has_capability_noaudit+0x17/0x20
[   96.090567]  ? oom_badness+0xeb/0x160
[   96.092133]  ? out_of_memory+0x10b/0x490
[   96.093920]  ? __alloc_pages_slowpath+0x701/0x8e2
[   96.095732]  ? __alloc_pages_nodemask+0x1ed/0x210
[   96.097544]  ? alloc_pages_vma+0x9f/0x220
[   96.099133]  ? __handle_mm_fault+0xc22/0x11e0
[   96.100668]  ? handle_mm_fault+0xc5/0x220
[   96.102387]  ? __do_page_fault+0x21e/0x4b0
[   96.103824]  ? do_page_fault+0x2b/0x70
[   96.105351]  ? page_fault+0x28/0x30
[   96.106759] Mem-Info:
[   96.107908] active_anon:438003 inactive_anon:2097 isolated_anon:0
[   96.107908]  active_file:91 inactive_file:265 isolated_file:6
[   96.107908]  unevictable:0 dirty:1 writeback:121 unstable:0
[   96.107908]  slab_reclaimable:2439 slab_unreclaimable:11273
[   96.107908]  mapped:382 shmem:2162 pagetables:8698 bounce:0
[   96.107908]  free:13166 free_pcp:0 free_cma:0
[   96.119325] Node 0 active_anon:1752012kB inactive_anon:8388kB active_file:364kB inactive_file:1060kB unevictable:0kB isolated(anon):0kB isolated(file):24kB mapped:1528kB dirty:4kB writeback:484kB shmem:8648kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 1519616kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[   96.125753] Node 0 DMA free:8148kB min:352kB low:440kB high:528kB active_anon:7696kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:28kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   96.133203] lowmem_reserve[]: 0 1952 1952 1952
[   96.135013] Node 0 DMA32 free:44516kB min:44700kB low:55872kB high:67044kB active_anon:1743720kB inactive_anon:8388kB active_file:336kB inactive_file:792kB unevictable:0kB writepending:488kB present:2080640kB managed:2018376kB mlocked:0kB slab_reclaimable:9756kB slab_unreclaimable:45060kB kernel_stack:22192kB pagetables:34764kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   96.143814] lowmem_reserve[]: 0 0 0 0
[   96.145371] Node 0 DMA: 1*4kB (U) 0*8kB 1*16kB (M) 2*32kB (UM) 2*64kB (UM) 2*128kB (UM) 2*256kB (UM) 0*512kB 1*1024kB (U) 1*2048kB (M) 1*4096kB (M) = 8148kB
[   96.148956] Node 0 DMA32: 1052*4kB (UME) 599*8kB (UME) 212*16kB (UME) 237*32kB (UME) 155*64kB (UME) 39*128kB (UME) 12*256kB (UME) 10*512kB (UME) 2*1024kB (M) 0*2048kB 0*4096kB = 45128kB
[   96.153861] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[   96.156374] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   96.158817] 2598 total pagecache pages
[   96.160434] 0 pages in swap cache
[   96.161904] Swap cache stats: add 0, delete 0, find 0/0
[   96.163762] Free swap  = 0kB
[   96.165142] Total swap = 0kB
[   96.166507] 524157 pages RAM
[   96.167839] 0 pages HighMem/MovableOnly
[   96.169374] 15587 pages reserved
[   96.170834] 0 pages cma reserved
[   96.172247] 0 pages hwpoisoned
[   96.173569] Out of memory: Kill process 2984 (a.out) score 998 or sacrifice child
[   96.176242] Killed process 2984 (a.out) total-vm:4172kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[   96.182342] oom_reaper: reaped process 2984 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  242.498498] sysrq: SysRq : Show State
[  242.503329]   task                        PC stack   pid father
[  242.509822] systemd         D    0     1      0 0x00000000
[  242.515791] Call Trace:
[  242.519807]  ? __schedule+0x1d2/0x5a0
[  242.526263]  ? schedule+0x2d/0x80
[  242.530940]  ? schedule_timeout+0x16d/0x240
[  242.536135]  ? del_timer_sync+0x40/0x40
[  242.541458]  ? io_schedule_timeout+0x14/0x40
[  242.543661]  ? congestion_wait+0x79/0xd0
[  242.545748]  ? prepare_to_wait_event+0xf0/0xf0
[  242.548051]  ? shrink_inactive_list+0x388/0x3d0
[  242.550323]  ? shrink_node_memcg+0x33a/0x740
[  242.552505]  ? _cond_resched+0x10/0x20
[  242.554743]  ? _cond_resched+0x10/0x20
[  242.556952]  ? shrink_node+0xe0/0x320
[  242.558962]  ? do_try_to_free_pages+0xdc/0x370
[  242.561168]  ? try_to_free_pages+0xbe/0x100
[  242.563309]  ? __alloc_pages_slowpath+0x387/0x8e2
[  242.565581]  ? __wake_up_common+0x4c/0x80
[  242.567759]  ? __alloc_pages_nodemask+0x1ed/0x210
[  242.570064]  ? alloc_pages_current+0x7a/0x100
[  242.572092]  ? __do_page_cache_readahead+0xe9/0x250
[  242.573707]  ? radix_tree_lookup_slot+0x1e/0x50
[  242.575081]  ? find_get_entry+0x14/0x100
[  242.576414]  ? pagecache_get_page+0x21/0x200
[  242.577678]  ? filemap_fault+0x23a/0x5e0
[  242.578859]  ? filemap_map_pages+0x185/0x3a0
[  242.580093]  ? xfs_filemap_fault+0x2f/0x50 [xfs]
[  242.581398]  ? __do_fault+0x15/0x70
[  242.582468]  ? __handle_mm_fault+0xb0f/0x11e0
[  242.583665]  ? ep_ptable_queue_proc+0x90/0x90
[  242.584831]  ? handle_mm_fault+0xc5/0x220
[  242.585993]  ? __do_page_fault+0x21e/0x4b0
[  242.587257]  ? do_page_fault+0x2b/0x70
[  242.589145]  ? page_fault+0x28/0x30
(...snipped...)
[  243.105826] kswapd0         D    0    51      2 0x00000000
[  243.107344] Call Trace:
[  243.108113]  ? __schedule+0x1d2/0x5a0
[  243.109114]  ? schedule+0x2d/0x80
[  243.110052]  ? schedule_timeout+0x192/0x240
[  243.111190]  ? check_preempt_curr+0x7f/0x90
[  243.112260]  ? __down_common+0xc0/0x128
[  243.113329]  ? down+0x36/0x40
[  243.114296]  ? xfs_buf_lock+0x1d/0x40 [xfs]
[  243.115473]  ? _xfs_buf_find+0x2ad/0x580 [xfs]
[  243.116785]  ? xfs_buf_get_map+0x1d/0x140 [xfs]
[  243.118052]  ? xfs_buf_read_map+0x23/0xd0 [xfs]
[  243.119310]  ? xfs_trans_read_buf_map+0xe5/0x2f0 [xfs]
[  243.120655]  ? _cond_resched+0x10/0x20
[  243.122831]  ? xfs_read_agf+0x8d/0x120 [xfs]
[  243.124181]  ? xfs_alloc_read_agf+0x39/0x130 [xfs]
[  243.125616]  ? xfs_alloc_fix_freelist+0x369/0x430 [xfs]
[  243.127093]  ? __radix_tree_lookup+0x80/0xf0
[  243.128235]  ? __radix_tree_lookup+0x80/0xf0
[  243.129357]  ? xfs_alloc_vextent+0x148/0x460 [xfs]
[  243.130596]  ? xfs_bmap_btalloc+0x45e/0x8a0 [xfs]
[  243.131804]  ? xfs_bmapi_write+0x768/0x1250 [xfs]
[  243.133032]  ? kmem_cache_alloc+0x11c/0x130
[  243.134160]  ? xfs_iomap_write_allocate+0x175/0x360 [xfs]
[  243.135503]  ? xfs_map_blocks+0x181/0x230 [xfs]
[  243.136802]  ? xfs_do_writepage+0x1db/0x630 [xfs]
[  243.138030]  ? xfs_vm_writepage+0x31/0x70 [xfs]
[  243.139396]  ? pageout.isra.47+0x188/0x280
[  243.140490]  ? shrink_page_list+0x79d/0xbb0
[  243.141619]  ? shrink_inactive_list+0x1c2/0x3d0
[  243.142831]  ? radix_tree_gang_lookup_tag+0xe3/0x160
[  243.144072]  ? shrink_node_memcg+0x33a/0x740
[  243.145188]  ? _cond_resched+0x10/0x20
[  243.146410]  ? _cond_resched+0x10/0x20
[  243.147746]  ? shrink_node+0xe0/0x320
[  243.148754]  ? kswapd+0x2b4/0x660
[  243.149691]  ? kthread+0xf2/0x130
[  243.150690]  ? mem_cgroup_shrink_node+0xb0/0xb0
[  243.151887]  ? kthread_park+0x60/0x60
[  243.152909]  ? ret_from_fork+0x26/0x40
(...snipped...)
[  273.216540] Showing busy workqueues and worker pools:
[  273.218084] workqueue events_freezable_power_: flags=0x84
[  273.219707]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
[  273.221259]     in-flight: 381:disk_events_workfn
[  273.222576] workqueue writeback: flags=0x4e
[  273.223721]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[  273.225240]     in-flight: 344:wb_workfn wb_workfn
[  273.227485] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 63 17
[  273.229266] pool 256: cpus=0-127 flags=0x4 nice=0 hung=180s workers=34 idle: 343 342 341 340 339 338 337 336 335 334 333 332 331 329 330 328 327 326 325 324 323 322 321 320 319 318 317 248 280 53 345 5 348
[  340.690056] sysrq: SysRq : Resetting
----------

this problem also occurs with only 4 parallel writers.

----------
[    0.000000] Linux version 4.11.0-rc7-next-20170421+ (root@ccsecurity) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-11) (GCC) ) #588 SMP Sun Apr 23 17:38:02 JST 2017
[    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-4.11.0-rc7-next-20170421+ root=UUID=17c3c28f-a70a-4666-95fa-ecf6acd901e4 ro vconsole.keymap=jp106 crashkernel=256M vconsole.font=latarcyrheb-sun16 security=none sysrq_always_enabled console=ttyS0,115200n8 console=tty0 LANG=en_US.UTF-8 debug_guardpage_minorder=1
(...snipped...)
[  383.692506] Out of memory: Kill process 3391 (a.out) score 999 or sacrifice child
[  383.694476] Killed process 3391 (a.out) total-vm:4172kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  383.699008] oom_reaper: reaped process 3391 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  445.711383] sysrq: SysRq : Show State
[  445.718193]   task                        PC stack   pid father
(...snipped...)
[  446.272860] kswapd0         D    0    51      2 0x00000000
[  446.274148] Call Trace:
[  446.274890]  ? __schedule+0x1d2/0x5a0
[  446.275847]  ? schedule+0x2d/0x80
[  446.276736]  ? rwsem_down_read_failed+0x108/0x180
[  446.278223]  ? call_rwsem_down_read_failed+0x14/0x30
[  446.280076]  ? down_read+0x17/0x30
[  446.281297]  ? xfs_map_blocks+0x8f/0x230 [xfs]
[  446.282685]  ? xfs_do_writepage+0x1db/0x630 [xfs]
[  446.283985]  ? xfs_vm_writepage+0x31/0x70 [xfs]
[  446.285124]  ? pageout.isra.47+0x188/0x280
[  446.286192]  ? shrink_page_list+0x79d/0xbb0
[  446.287296]  ? shrink_inactive_list+0x1c2/0x3d0
[  446.288442]  ? radix_tree_gang_lookup_tag+0xe3/0x160
[  446.289808]  ? shrink_node_memcg+0x33a/0x740
[  446.291027]  ? _cond_resched+0x10/0x20
[  446.292038]  ? _cond_resched+0x10/0x20
[  446.293089]  ? shrink_node+0xe0/0x320
[  446.294069]  ? kswapd+0x2b4/0x660
[  446.295036]  ? kthread+0xf2/0x130
[  446.296211]  ? mem_cgroup_shrink_node+0xb0/0xb0
[  446.297367]  ? kthread_park+0x60/0x60
[  446.298353]  ? ret_from_fork+0x26/0x40
(...snipped...)
[  448.285791] a.out           D    0  3387   2847 0x00000080
[  448.287194] Call Trace:
[  448.287975]  ? __schedule+0x1d2/0x5a0
[  448.288975]  ? schedule+0x2d/0x80
[  448.289910]  ? schedule_timeout+0x16d/0x240
[  448.291072]  ? del_timer_sync+0x40/0x40
[  448.292097]  ? io_schedule_timeout+0x14/0x40
[  448.293294]  ? congestion_wait+0x79/0xd0
[  448.294327]  ? prepare_to_wait_event+0xf0/0xf0
[  448.295476]  ? shrink_inactive_list+0x388/0x3d0
[  448.296650]  ? shrink_node_memcg+0x33a/0x740
[  448.298016]  ? _cond_resched+0x10/0x20
[  448.299027]  ? _cond_resched+0x10/0x20
[  448.300032]  ? shrink_node+0xe0/0x320
[  448.301068]  ? do_try_to_free_pages+0xdc/0x370
[  448.302247]  ? try_to_free_pages+0xbe/0x100
[  448.303325]  ? __alloc_pages_slowpath+0x387/0x8e2
[  448.304492]  ? __lock_page_or_retry+0x1b8/0x300
[  448.305628]  ? __alloc_pages_nodemask+0x1ed/0x210
[  448.306809]  ? alloc_pages_vma+0x9f/0x220
[  448.307874]  ? __handle_mm_fault+0xc22/0x11e0
[  448.308984]  ? handle_mm_fault+0xc5/0x220
[  448.310228]  ? __do_page_fault+0x21e/0x4b0
[  448.311500]  ? do_page_fault+0x2b/0x70
[  448.312609]  ? page_fault+0x28/0x30
[  448.313926] a.out           D    0  3388   3387 0x00000086
[  448.315461] Call Trace:
[  448.316339]  ? __schedule+0x1d2/0x5a0
[  448.317348]  ? schedule+0x2d/0x80
[  448.318291]  ? schedule_timeout+0x192/0x240
[  448.319372]  ? sched_clock_cpu+0xc/0xa0
[  448.320417]  ? __down_common+0xc0/0x128
[  448.321583]  ? down+0x36/0x40
[  448.322463]  ? xfs_buf_lock+0x1d/0x40 [xfs]
[  448.323572]  ? _xfs_buf_find+0x2ad/0x580 [xfs]
[  448.324698]  ? xfs_buf_get_map+0x1d/0x140 [xfs]
[  448.325885]  ? xfs_buf_read_map+0x23/0xd0 [xfs]
[  448.327045]  ? xfs_trans_read_buf_map+0xe5/0x2f0 [xfs]
[  448.328303]  ? xfs_read_agf+0x8d/0x120 [xfs]
[  448.329384]  ? xfs_trans_read_buf_map+0x178/0x2f0 [xfs]
[  448.330906]  ? xfs_alloc_read_agf+0x39/0x130 [xfs]
[  448.332401]  ? xfs_alloc_fix_freelist+0x369/0x430 [xfs]
[  448.333738]  ? xfs_btree_rec_addr+0x9/0x10 [xfs]
[  448.335180]  ? _cond_resched+0x10/0x20
[  448.336628]  ? __kmalloc+0x114/0x180
[  448.337783]  ? xfs_buf_rele+0x57/0x3b0 [xfs]
[  448.339143]  ? __radix_tree_lookup+0x80/0xf0
[  448.340406]  ? xfs_free_extent_fix_freelist+0x67/0xc0 [xfs]
[  448.341889]  ? xfs_free_extent+0x6f/0x210 [xfs]
[  448.343210]  ? xfs_trans_free_extent+0x27/0x90 [xfs]
[  448.344565]  ? xfs_extent_free_finish_item+0x1c/0x30 [xfs]
[  448.346042]  ? xfs_defer_finish+0x125/0x280 [xfs]
[  448.348145]  ? xfs_itruncate_extents+0x1a2/0x3c0 [xfs]
[  448.349999]  ? xfs_free_eofblocks+0x1c5/0x230 [xfs]
[  448.351680]  ? xfs_release+0x135/0x160 [xfs]
[  448.353278]  ? __fput+0xc8/0x1c0
[  448.354355]  ? task_work_run+0x6e/0x90
[  448.355646]  ? do_exit+0x2b6/0xab0
[  448.356761]  ? do_group_exit+0x34/0xa0
[  448.357901]  ? get_signal+0x17c/0x4f0
[  448.359039]  ? __do_fault+0x15/0x70
[  448.360139]  ? do_signal+0x31/0x610
[  448.361238]  ? handle_mm_fault+0xc5/0x220
[  448.362487]  ? __do_page_fault+0x21e/0x4b0
[  448.363752]  ? exit_to_usermode_loop+0x35/0x70
[  448.365109]  ? prepare_exit_to_usermode+0x39/0x40
[  448.366475]  ? retint_user+0x8/0x13
[  448.367640] a.out           D    0  3389   3387 0x00000086
[  448.369260] Call Trace:
[  448.370151]  ? __schedule+0x1d2/0x5a0
[  448.371220]  ? schedule+0x2d/0x80
[  448.372181]  ? schedule_timeout+0x16d/0x240
[  448.373277]  ? del_timer_sync+0x40/0x40
[  448.374309]  ? io_schedule_timeout+0x14/0x40
[  448.375414]  ? congestion_wait+0x79/0xd0
[  448.376460]  ? prepare_to_wait_event+0xf0/0xf0
[  448.377590]  ? shrink_inactive_list+0x388/0x3d0
[  448.378788]  ? pick_next_task_fair+0x39c/0x480
[  448.380269]  ? shrink_node_memcg+0x33a/0x740
[  448.381981]  ? mem_cgroup_iter+0x127/0x2b0
[  448.383266]  ? shrink_node+0xe0/0x320
[  448.384342]  ? do_try_to_free_pages+0xdc/0x370
[  448.385569]  ? try_to_free_pages+0xbe/0x100
[  448.386680]  ? __alloc_pages_slowpath+0x387/0x8e2
[  448.387909]  ? __alloc_pages_nodemask+0x1ed/0x210
[  448.389163]  ? alloc_pages_current+0x7a/0x100
[  448.390369]  ? xfs_buf_allocate_memory+0x16a/0x2ad [xfs]
[  448.391731]  ? xfs_buf_get_map+0xeb/0x140 [xfs]
[  448.392931]  ? xfs_buf_read_map+0x23/0xd0 [xfs]
[  448.394114]  ? xfs_trans_read_buf_map+0xe5/0x2f0 [xfs]
[  448.395421]  ? xfs_btree_read_buf_block.constprop.37+0x72/0xc0 [xfs]
[  448.397007]  ? xfs_btree_lookup_get_block+0x7f/0x160 [xfs]
[  448.398671]  ? xfs_btree_lookup+0xc9/0x3f0 [xfs]
[  448.399927]  ? xfs_bmap_del_extent+0x1a0/0xbb0 [xfs]
[  448.401357]  ? __xfs_bunmapi+0x3bb/0xb70 [xfs]
[  448.402679]  ? xfs_bunmapi+0x26/0x40 [xfs]
[  448.403907]  ? xfs_itruncate_extents+0x18a/0x3c0 [xfs]
[  448.405339]  ? xfs_free_eofblocks+0x1c5/0x230 [xfs]
[  448.406688]  ? xfs_release+0x135/0x160 [xfs]
[  448.407911]  ? __fput+0xc8/0x1c0
[  448.408939]  ? task_work_run+0x6e/0x90
[  448.410061]  ? do_exit+0x2b6/0xab0
[  448.411156]  ? do_group_exit+0x34/0xa0
[  448.412301]  ? get_signal+0x17c/0x4f0
[  448.413526]  ? __do_fault+0x15/0x70
[  448.415066]  ? do_signal+0x31/0x610
[  448.416174]  ? handle_mm_fault+0xc5/0x220
[  448.417490]  ? __do_page_fault+0x21e/0x4b0
[  448.418729]  ? exit_to_usermode_loop+0x35/0x70
[  448.419976]  ? prepare_exit_to_usermode+0x39/0x40
[  448.421336]  ? retint_user+0x8/0x13
[  448.422414] a.out           D    0  3391   3387 0x00000086
[  448.423873] Call Trace:
[  448.424755]  ? __schedule+0x1d2/0x5a0
[  448.425857]  ? schedule+0x2d/0x80
[  448.426918]  ? schedule_timeout+0x192/0x240
[  448.428143]  ? mempool_alloc+0x64/0x170
[  448.429318]  ? __down_common+0xc0/0x128
[  448.430401]  ? down+0x36/0x40
[  448.431561]  ? xfs_buf_lock+0x1d/0x40 [xfs]
[  448.432727]  ? _xfs_buf_find+0x2ad/0x580 [xfs]
[  448.433976]  ? xfs_buf_get_map+0x1d/0x140 [xfs]
[  448.435216]  ? xfs_buf_read_map+0x23/0xd0 [xfs]
[  448.436545]  ? xfs_trans_read_buf_map+0xe5/0x2f0 [xfs]
[  448.437901]  ? xfs_read_agf+0x8d/0x120 [xfs]
[  448.439111]  ? xfs_trans_read_buf_map+0x178/0x2f0 [xfs]
[  448.440624]  ? xfs_alloc_read_agf+0x39/0x130 [xfs]
[  448.441958]  ? xfs_alloc_fix_freelist+0x369/0x430 [xfs]
[  448.443524]  ? xfs_btree_rec_addr+0x9/0x10 [xfs]
[  448.444800]  ? _cond_resched+0x10/0x20
[  448.445933]  ? __kmalloc+0x114/0x180
[  448.447319]  ? xfs_buf_rele+0x57/0x3b0 [xfs]
[  448.448657]  ? __radix_tree_lookup+0x80/0xf0
[  448.449934]  ? xfs_free_extent_fix_freelist+0x67/0xc0 [xfs]
[  448.451445]  ? xfs_free_extent+0x6f/0x210 [xfs]
[  448.452608]  ? xfs_trans_free_extent+0x27/0x90 [xfs]
[  448.453874]  ? xfs_extent_free_finish_item+0x1c/0x30 [xfs]
[  448.455203]  ? xfs_defer_finish+0x125/0x280 [xfs]
[  448.456410]  ? xfs_itruncate_extents+0x1a2/0x3c0 [xfs]
[  448.457682]  ? xfs_free_eofblocks+0x1c5/0x230 [xfs]
[  448.458937]  ? xfs_release+0x135/0x160 [xfs]
[  448.460060]  ? __fput+0xc8/0x1c0
[  448.461081]  ? task_work_run+0x6e/0x90
[  448.462103]  ? do_exit+0x2b6/0xab0
[  448.463064]  ? do_group_exit+0x34/0xa0
[  448.464347]  ? get_signal+0x17c/0x4f0
[  448.465402]  ? do_signal+0x31/0x610
[  448.466373]  ? xfs_file_write_iter+0x88/0x120 [xfs]
[  448.467614]  ? __vfs_write+0xe5/0x140
[  448.468613]  ? exit_to_usermode_loop+0x35/0x70
[  448.469747]  ? do_syscall_64+0x12a/0x140
[  448.470827]  ? entry_SYSCALL64_slow_path+0x25/0x25
[  448.472399] a.out           D    0  3392   3387 0x00000080
[  448.473757] Call Trace:
[  448.474567]  ? __schedule+0x1d2/0x5a0
[  448.475598]  ? schedule+0x2d/0x80
[  448.476566]  ? schedule_timeout+0x16d/0x240
[  448.477688]  ? del_timer_sync+0x40/0x40
[  448.478709]  ? io_schedule_timeout+0x14/0x40
[  448.480159]  ? congestion_wait+0x79/0xd0
[  448.481998]  ? prepare_to_wait_event+0xf0/0xf0
[  448.483679]  ? shrink_inactive_list+0x388/0x3d0
[  448.485113]  ? shrink_node_memcg+0x33a/0x740
[  448.486310]  ? xfs_reclaim_inodes_count+0x2d/0x40 [xfs]
[  448.487609]  ? mem_cgroup_iter+0x127/0x2b0
[  448.488719]  ? shrink_node+0xe0/0x320
[  448.489747]  ? do_try_to_free_pages+0xdc/0x370
[  448.490926]  ? try_to_free_pages+0xbe/0x100
[  448.492122]  ? __alloc_pages_slowpath+0x387/0x8e2
[  448.493347]  ? __alloc_pages_nodemask+0x1ed/0x210
[  448.494633]  ? alloc_pages_current+0x7a/0x100
[  448.495800]  ? xfs_buf_allocate_memory+0x16a/0x2ad [xfs]
[  448.497170]  ? xfs_buf_get_map+0xeb/0x140 [xfs]
[  448.498710]  ? xfs_buf_read_map+0x23/0xd0 [xfs]
[  448.499861]  ? xfs_trans_read_buf_map+0xe5/0x2f0 [xfs]
[  448.501200]  ? xfs_btree_read_buf_block.constprop.37+0x72/0xc0 [xfs]
[  448.502698]  ? xfs_btree_lookup_get_block+0x7f/0x160 [xfs]
[  448.504021]  ? xfs_btree_lookup+0xc9/0x3f0 [xfs]
[  448.505242]  ? xfs_iext_remove_direct+0x64/0xd0 [xfs]
[  448.506495]  ? xfs_bmap_add_extent_delay_real+0x4f9/0x18e0 [xfs]
[  448.507930]  ? _cond_resched+0x10/0x20
[  448.508972]  ? kmem_cache_alloc+0x11c/0x130
[  448.510132]  ? kmem_zone_alloc+0x84/0xf0 [xfs]
[  448.511366]  ? xfs_bmapi_write+0x826/0x1250 [xfs]
[  448.512572]  ? kmem_cache_alloc+0x11c/0x130
[  448.514112]  ? xfs_iomap_write_allocate+0x175/0x360 [xfs]
[  448.515920]  ? xfs_map_blocks+0x181/0x230 [xfs]
[  448.517136]  ? xfs_do_writepage+0x1db/0x630 [xfs]
[  448.518381]  ? invalid_page_referenced_vma+0x80/0x80
[  448.519640]  ? write_cache_pages+0x205/0x400
[  448.520831]  ? xfs_vm_set_page_dirty+0x1c0/0x1c0 [xfs]
[  448.522203]  ? iomap_apply+0xe3/0x120
[  448.523271]  ? xfs_vm_writepages+0x5f/0xa0 [xfs]
[  448.524523]  ? __filemap_fdatawrite_range+0xc0/0xf0
[  448.525866]  ? filemap_write_and_wait_range+0x20/0x50
[  448.527157]  ? xfs_file_fsync+0x41/0x160 [xfs]
[  448.528319]  ? do_fsync+0x33/0x60
[  448.529273]  ? SyS_fsync+0x7/0x10
[  448.530267]  ? do_syscall_64+0x5c/0x140
[  448.531609]  ? entry_SYSCALL64_slow_path+0x25/0x25
(...snipped...)
[  580.304479] Showing busy workqueues and worker pools:
[  580.306114] workqueue events_freezable_power_: flags=0x84
[  580.307522]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  580.309059]     in-flight: 99:disk_events_workfn
[  580.310365] workqueue writeback: flags=0x4e
[  580.312273]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[  580.313966]     in-flight: 342:wb_workfn wb_workfn
[  580.316378] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=2s workers=3 idle: 24 3095
[  580.318281] pool 256: cpus=0-127 flags=0x4 nice=0 hung=198s workers=3 idle: 341 340
[  595.909943] sysrq: SysRq : Resetting
----------

This problem is very much dependent on timing, and warn_alloc_stall() cannot
catch this problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
