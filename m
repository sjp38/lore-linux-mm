Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 355D56B02C6
	for <linux-mm@kvack.org>; Sun, 23 Apr 2017 06:24:40 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id x86so183757118ioe.5
        for <linux-mm@kvack.org>; Sun, 23 Apr 2017 03:24:40 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id q63si8239253itq.20.2017.04.23.03.24.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 23 Apr 2017 03:24:38 -0700 (PDT)
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170307133057.26182-1-mhocko@kernel.org>
	<1488916356.6405.4.camel@redhat.com>
	<20170309180540.GA8678@cmpxchg.org>
	<20170310102010.GD3753@dhcp22.suse.cz>
	<201703102044.DBJ04626.FLVMFOQOJtOFHS@I-love.SAKURA.ne.jp>
In-Reply-To: <201703102044.DBJ04626.FLVMFOQOJtOFHS@I-love.SAKURA.ne.jp>
Message-Id: <201704231924.GDF05718.LQSMtJOOFOFHFV@I-love.SAKURA.ne.jp>
Date: Sun, 23 Apr 2017 19:24:21 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, hannes@cmpxchg.org
Cc: riel@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, sgruszka@redhat.com

On 2017/03/10 20:44, Tetsuo Handa wrote:
> Michal Hocko wrote:
>> On Thu 09-03-17 13:05:40, Johannes Weiner wrote:
>>> On Tue, Mar 07, 2017 at 02:52:36PM -0500, Rik van Riel wrote:
>>>> It only does this to some extent.  If reclaim made
>>>> no progress, for example due to immediately bailing
>>>> out because the number of already isolated pages is
>>>> too high (due to many parallel reclaimers), the code
>>>> could hit the "no_progress_loops > MAX_RECLAIM_RETRIES"
>>>> test without ever looking at the number of reclaimable
>>>> pages.
>>>
>>> Hm, there is no early return there, actually. We bump the loop counter
>>> every time it happens, but then *do* look at the reclaimable pages.
>>>
>>>> Could that create problems if we have many concurrent
>>>> reclaimers?
>>>
>>> With increased concurrency, the likelihood of OOM will go up if we
>>> remove the unlimited wait for isolated pages, that much is true.
>>>
>>> I'm not sure that's a bad thing, however, because we want the OOM
>>> killer to be predictable and timely. So a reasonable wait time in
>>> between 0 and forever before an allocating thread gives up under
>>> extreme concurrency makes sense to me.
>>>
>>>> It may be OK, I just do not understand all the implications.
>>>>
>>>> I like the general direction your patch takes the code in,
>>>> but I would like to understand it better...
>>>
>>> I feel the same way. The throttling logic doesn't seem to be very well
>>> thought out at the moment, making it hard to reason about what happens
>>> in certain scenarios.
>>>
>>> In that sense, this patch isn't really an overall improvement to the
>>> way things work. It patches a hole that seems to be exploitable only
>>> from an artificial OOM torture test, at the risk of regressing high
>>> concurrency workloads that may or may not be artificial.
>>>
>>> Unless I'm mistaken, there doesn't seem to be a whole lot of urgency
>>> behind this patch. Can we think about a general model to deal with
>>> allocation concurrency? 
>>
>> I am definitely not against. There is no reason to rush the patch in.
> 
> I don't hurry if we can check using watchdog whether this problem is occurring
> in the real world. I have to test corner cases because watchdog is missing.
> 
Ping?

This problem can occur even immediately after the first invocation of
the OOM killer. I believe this problem can occur in the real world.
When are we going to apply this patch or watchdog patch?

----------------------------------------
[    0.000000] Linux version 4.11.0-rc7-next-20170421+ (root@ccsecurity) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-11) (GCC) ) #588 SMP Sun Apr 23 17:38:02 JST 2017
[    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-4.11.0-rc7-next-20170421+ root=UUID=17c3c28f-a70a-4666-95fa-ecf6acd901e4 ro vconsole.keymap=jp106 crashkernel=256M vconsole.font=latarcyrheb-sun16 security=none sysrq_always_enabled console=ttyS0,115200n8 console=tty0 LANG=en_US.UTF-8 debug_guardpage_minorder=1
(...snipped...)
CentOS Linux 7 (Core)
Kernel 4.11.0-rc7-next-20170421+ on an x86_64

ccsecurity login: [   32.406723] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   32.852917] Ebtables v2.0 registered
[   33.034402] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   33.467929] e1000: ens32 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
[   33.475728] IPv6: ADDRCONF(NETDEV_UP): ens32: link is not ready
[   33.478910] IPv6: ADDRCONF(NETDEV_CHANGE): ens32: link becomes ready
[   33.950365] Netfilter messages via NETLINK v0.30.
[   33.983449] ip_set: protocol 6
[   37.335966] e1000: ens35 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
[   37.337587] IPv6: ADDRCONF(NETDEV_UP): ens35: link is not ready
[   37.339925] IPv6: ADDRCONF(NETDEV_CHANGE): ens35: link becomes ready
[   39.940942] nf_conntrack: default automatic helper assignment has been turned off for security reasons and CT-based  firewall rule not found. Use the iptables CT target to attach helpers instead.
[   98.926202] a.out invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null),  order=0, oom_score_adj=0
[   98.932977] a.out cpuset=/ mems_allowed=0
[   98.934780] CPU: 1 PID: 2972 Comm: a.out Not tainted 4.11.0-rc7-next-20170421+ #588
[   98.937988] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   98.942193] Call Trace:
[   98.942942]  ? dump_stack+0x5c/0x7d
[   98.943907]  ? dump_header+0x97/0x233
[   98.945334]  ? ktime_get+0x30/0x90
[   98.946290]  ? delayacct_end+0x35/0x60
[   98.947319]  ? do_try_to_free_pages+0x2ca/0x370
[   98.948554]  ? oom_kill_process+0x223/0x3e0
[   98.949715]  ? has_capability_noaudit+0x17/0x20
[   98.950948]  ? oom_badness+0xeb/0x160
[   98.951962]  ? out_of_memory+0x10b/0x490
[   98.953030]  ? __alloc_pages_slowpath+0x701/0x8e2
[   98.954313]  ? __alloc_pages_nodemask+0x1ed/0x210
[   98.956242]  ? alloc_pages_vma+0x9f/0x220
[   98.957486]  ? __handle_mm_fault+0xc22/0x11e0
[   98.958673]  ? handle_mm_fault+0xc5/0x220
[   98.959766]  ? __do_page_fault+0x21e/0x4b0
[   98.960906]  ? do_page_fault+0x2b/0x70
[   98.961977]  ? page_fault+0x28/0x30
[   98.963861] Mem-Info:
[   98.965330] active_anon:372765 inactive_anon:2097 isolated_anon:0
[   98.965330]  active_file:182 inactive_file:214 isolated_file:32
[   98.965330]  unevictable:0 dirty:6 writeback:6 unstable:0
[   98.965330]  slab_reclaimable:2011 slab_unreclaimable:11291
[   98.965330]  mapped:623 shmem:2162 pagetables:8582 bounce:0
[   98.965330]  free:13278 free_pcp:117 free_cma:0
[   98.978473] Node 0 active_anon:1491060kB inactive_anon:8388kB active_file:728kB inactive_file:856kB unevictable:0kB isolated(anon):0kB isolated(file):128kB mapped:2492kB dirty:24kB writeback:24kB shmem:8648kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 1241088kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[   98.987555] Node 0 DMA free:7176kB min:408kB low:508kB high:608kB active_anon:8672kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:24kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   98.998904] lowmem_reserve[]: 0 1696 1696 1696
[   99.001205] Node 0 DMA32 free:45936kB min:44644kB low:55804kB high:66964kB active_anon:1482048kB inactive_anon:8388kB active_file:232kB inactive_file:1000kB unevictable:0kB writepending:48kB present:2080640kB managed:1756232kB mlocked:0kB slab_reclaimable:8044kB slab_unreclaimable:45132kB kernel_stack:22128kB pagetables:34304kB bounce:0kB free_pcp:700kB local_pcp:0kB free_cma:0kB
[   99.009428] lowmem_reserve[]: 0 0 0 0
[   99.010816] Node 0 DMA: 0*4kB 1*8kB (U) 0*16kB 2*32kB (UM) 1*64kB (U) 1*128kB (U) 1*256kB (U) 1*512kB (M) 2*1024kB (UM) 0*2048kB 1*4096kB (M) = 7176kB
[   99.014262] Node 0 DMA32: 909*4kB (UE) 548*8kB (UME) 190*16kB (UME) 99*32kB (UME) 37*64kB (UME) 14*128kB (UME) 5*256kB (UME) 3*512kB (E) 2*1024kB (UM) 1*2048kB (M) 5*4096kB (M) = 45780kB
[   99.018848] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[   99.021288] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   99.023758] 2752 total pagecache pages
[   99.025196] 0 pages in swap cache
[   99.026538] Swap cache stats: add 0, delete 0, find 0/0
[   99.028521] Free swap  = 0kB
[   99.029923] Total swap = 0kB
[   99.031212] 524157 pages RAM
[   99.032458] 0 pages HighMem/MovableOnly
[   99.033812] 81123 pages reserved
[   99.035255] 0 pages cma reserved
[   99.036729] 0 pages hwpoisoned
[   99.037898] Out of memory: Kill process 2973 (a.out) score 999 or sacrifice child
[   99.039902] Killed process 2973 (a.out) total-vm:4172kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[   99.043953] oom_reaper: reaped process 2973 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  173.285686] sysrq: SysRq : Show State
(...snipped...)
[  173.899630] kswapd0         D    0    51      2 0x00000000
[  173.900935] Call Trace:
[  173.901706]  ? __schedule+0x1d2/0x5a0
[  173.902906]  ? schedule+0x2d/0x80
[  173.904034]  ? schedule_timeout+0x192/0x240
[  173.905437]  ? __down_common+0xc0/0x128
[  173.906549]  ? down+0x36/0x40
[  173.907433]  ? xfs_buf_lock+0x1d/0x40 [xfs]
[  173.908574]  ? _xfs_buf_find+0x2ad/0x580 [xfs]
[  173.909734]  ? xfs_buf_get_map+0x1d/0x140 [xfs]
[  173.910886]  ? xfs_buf_read_map+0x23/0xd0 [xfs]
[  173.912045]  ? xfs_trans_read_buf_map+0xe5/0x2f0 [xfs]
[  173.913381]  ? xfs_read_agf+0x8d/0x120 [xfs]
[  173.914725]  ? xfs_alloc_read_agf+0x39/0x130 [xfs]
[  173.916225]  ? xfs_alloc_fix_freelist+0x369/0x430 [xfs]
[  173.917491]  ? __radix_tree_lookup+0x80/0xf0
[  173.918593]  ? __radix_tree_lookup+0x80/0xf0
[  173.920091]  ? xfs_alloc_vextent+0x148/0x460 [xfs]
[  173.921549]  ? xfs_bmap_btalloc+0x45e/0x8a0 [xfs]
[  173.922728]  ? xfs_bmapi_write+0x768/0x1250 [xfs]
[  173.923904]  ? kmem_cache_alloc+0x11c/0x130
[  173.925030]  ? xfs_iomap_write_allocate+0x175/0x360 [xfs]
[  173.926592]  ? xfs_map_blocks+0x181/0x230 [xfs]
[  173.927854]  ? xfs_do_writepage+0x1db/0x630 [xfs]
[  173.929046]  ? xfs_setfilesize_trans_alloc.isra.26+0x35/0x80 [xfs]
[  173.930665]  ? xfs_vm_writepage+0x31/0x70 [xfs]
[  173.931915]  ? pageout.isra.47+0x188/0x280
[  173.933005]  ? shrink_page_list+0x79d/0xbb0
[  173.934138]  ? shrink_inactive_list+0x1c2/0x3d0
[  173.935609]  ? radix_tree_gang_lookup_tag+0xe3/0x160
[  173.937100]  ? shrink_node_memcg+0x33a/0x740
[  173.938335]  ? _cond_resched+0x10/0x20
[  173.939443]  ? _cond_resched+0x10/0x20
[  173.940470]  ? shrink_node+0xe0/0x320
[  173.941483]  ? kswapd+0x2b4/0x660
[  173.942424]  ? kthread+0xf2/0x130
[  173.943396]  ? mem_cgroup_shrink_node+0xb0/0xb0
[  173.944578]  ? kthread_park+0x60/0x60
[  173.945613]  ? ret_from_fork+0x26/0x40
(...snipped...)
[  195.183281] Showing busy workqueues and worker pools:
[  195.184626] workqueue events_freezable_power_: flags=0x84
[  195.186013]   pwq 4: cpus=2 node=0 flags=0x0 nice=0 active=1/256
[  195.187596]     in-flight: 24:disk_events_workfn
[  195.188832] workqueue writeback: flags=0x4e
[  195.189919]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=1/256
[  195.191826]     in-flight: 370:wb_workfn
[  195.194105] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 129 63
[  195.195883] pool 256: cpus=0-127 flags=0x4 nice=0 hung=96s workers=31 idle: 371 369 368 367 366 365 364 363 362 361 360 359 358 357 356 355 354 353 352 351 350 349 348 347 346 249 253 5 53 372
[  243.365293] sysrq: SysRq : Resetting
----------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
