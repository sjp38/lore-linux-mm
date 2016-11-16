Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id A8AED6B0267
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 08:39:21 -0500 (EST)
Received: by mail-vk0-f71.google.com with SMTP id 192so116236948vkh.5
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 05:39:21 -0800 (PST)
Received: from mail-ua0-x243.google.com (mail-ua0-x243.google.com. [2607:f8b0:400c:c08::243])
        by mx.google.com with ESMTPS id y74si7005296vkd.57.2016.11.16.05.39.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 05:39:20 -0800 (PST)
Received: by mail-ua0-x243.google.com with SMTP id 20so11773450uak.0
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 05:39:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAJtFHUSka8nbaO5RNEcWVRi7VoQ7UORWkMu_7pNW3n_9iRRdew@mail.gmail.com>
References: <bug-186671-27@https.bugzilla.kernel.org/> <20161103115353.de87ff35756a4ca8b21d2c57@linux-foundation.org>
 <b5b0cef0-8482-e4de-cb81-69a4dd3410fb@suse.cz> <CAJtFHUQcJKSnyQ7t7-eDpiF2C+U23+iWpZ+X6fGEzN8qdbzmtA@mail.gmail.com>
 <a8cf869e-f527-9c65-d16d-ac70cf66472a@suse.cz> <CAJtFHUQgkvFaPdyRcoiV-m5hynDGo2qXfMXzZvGahoWp2LL_KA@mail.gmail.com>
 <bbcd6cb7-3b73-02e9-0409-4601a6f573f5@suse.cz> <CAJtFHUSka8nbaO5RNEcWVRi7VoQ7UORWkMu_7pNW3n_9iRRdew@mail.gmail.com>
From: E V <eliventer@gmail.com>
Date: Wed, 16 Nov 2016 08:39:19 -0500
Message-ID: <CAJtFHUTn9Ejvyj3vJkqnsLoa6gci104-TPu5viG=epfJ9Rk_qg@mail.gmail.com>
Subject: Re: [Bug 186671] New: OOM on system with just rsync running 32GB of
 ram 30GB of pagecache
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, linux-btrfs <linux-btrfs@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

System panic'd overnight running 4.9rc5 & rsync. Attached a photo of
the stack trace, and the 38 call traces in a 2 minute window shortly
before, to the bugzilla case for those not on it's e-mail list:

https://bugzilla.kernel.org/show_bug.cgi?id=186671

On Mon, Nov 14, 2016 at 3:56 PM, E V <eliventer@gmail.com> wrote:
> Pretty sure it was the system after the OOM just did a history search
> to check, though it is 3 days afterwards and several OOMs killed
> several processes in somewhat rapid succession, I just listed the 1st.
> I'll turn on CONFIG_DEBUG_VM and reboot again.
>
> On Mon, Nov 14, 2016 at 12:04 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>> On 11/14/2016 02:27 PM, E V wrote:
>>> System is an intel dual socket Xeon E5620, 7500/5520/5500/X58 ICH10
>>> family according to lspci. Anyways 4.8.4 OOM'd while I was gone. I'll
>>> download the current 4.9rc and reboot, but in the mean time here's
>>> xxd, vmstat & kern.log output:
>>> 8532039 0000000000000000
>>
>> Hmm this would suggest that the memory is mostly free. But not according
>> to vmstat. Is it possible you mistakenly provided the xxd from a fresh
>> boot, but vmstat from after the OOM?
>>
>> But sure, a page_count() of zero is a reason why __isolate_lru_page()
>> would fail due to its get_page_unless_zero(). The question is then how
>> could it drop to zero without being freed at the same time, as
>> put_page() does.
>>
>> I was going to suspect commit 83929372f6 and a page_ref_sub() it adds to
>> delete_from_page_cache(), but that's since 4.8 and you mention problems
>> since 4.7.
>>
>> Anyway it might be worth enabling CONFIG_DEBUG_VM as the relevant code
>> usually has VM_BUG_ONs.
>>
>> Vlastimil
>>
>>>    9324 0100000000000000
>>>    2226 0200000000000000
>>>     405 0300000000000000
>>>      80 0400000000000000
>>>      34 0500000000000000
>>>      48 0600000000000000
>>>      17 0700000000000000
>>>      17 0800000000000000
>>>      32 0900000000000000
>>>      19 0a00000000000000
>>>       1 0c00000000000000
>>>       1 0d00000000000000
>>>       1 0e00000000000000
>>>      12 1000000000000000
>>>       8 1100000000000000
>>>      32 1200000000000000
>>>      10 1300000000000000
>>>       2 1400000000000000
>>>      11 1500000000000000
>>>      12 1600000000000000
>>>       7 1700000000000000
>>>       3 1800000000000000
>>>       5 1900000000000000
>>>       6 1a00000000000000
>>>      11 1b00000000000000
>>>      22 1c00000000000000
>>>       3 1d00000000000000
>>>      19 1e00000000000000
>>>      21 1f00000000000000
>>>      18 2000000000000000
>>>      28 2100000000000000
>>>      40 2200000000000000
>>>      38 2300000000000000
>>>      85 2400000000000000
>>>      59 2500000000000000
>>>   40520 81ffffffffffffff
>>>
>>> /proc/vmstat:
>>> nr_free_pages 60965
>>> nr_zone_inactive_anon 4646
>>> nr_zone_active_anon 3265
>>> nr_zone_inactive_file 633882
>>> nr_zone_active_file 7017458
>>> nr_zone_unevictable 0
>>> nr_zone_write_pending 0
>>> nr_mlock 0
>>> nr_slab_reclaimable 299205
>>> nr_slab_unreclaimable 195497
>>> nr_page_table_pages 935
>>> nr_kernel_stack 4976
>>> nr_bounce 0
>>> numa_hit 3577063288
>>> numa_miss 541393191
>>> numa_foreign 541393191
>>> numa_interleave 19415
>>> numa_local 3577063288
>>> numa_other 0
>>> nr_free_cma 0
>>> nr_inactive_anon 4646
>>> nr_active_anon 3265
>>> nr_inactive_file 633882
>>> nr_active_file 7017458
>>> nr_unevictable 0
>>> nr_isolated_anon 0
>>> nr_isolated_file 0
>>> nr_pages_scanned 0
>>> workingset_refault 42685891
>>> workingset_activate 15247281
>>> workingset_nodereclaim 26375216
>>> nr_anon_pages 5067
>>> nr_mapped 5630
>>> nr_file_pages 7654746
>>> nr_dirty 0
>>> nr_writeback 0
>>> nr_writeback_temp 0
>>> nr_shmem 2504
>>> nr_shmem_hugepages 0
>>> nr_shmem_pmdmapped 0
>>> nr_anon_transparent_hugepages 0
>>> nr_unstable 0
>>> nr_vmscan_write 5243750485
>>> nr_vmscan_immediate_reclaim 4207633857
>>> nr_dirtied 1839143430
>>> nr_written 1832626107
>>> nr_dirty_threshold 1147728
>>> nr_dirty_background_threshold 151410
>>> pgpgin 166731189
>>> pgpgout 7328142335
>>> pswpin 98608
>>> pswpout 117794
>>> pgalloc_dma 29504
>>> pgalloc_dma32 1006726216
>>> pgalloc_normal 5275218188
>>> pgalloc_movable 0
>>> allocstall_dma 0
>>> allocstall_dma32 0
>>> allocstall_normal 36461
>>> allocstall_movable 5867
>>> pgskip_dma 0
>>> pgskip_dma32 0
>>> pgskip_normal 6417890
>>> pgskip_movable 0
>>> pgfree 6309223401
>>> pgactivate 35076483
>>> pgdeactivate 63556974
>>> pgfault 35753842
>>> pgmajfault 69126
>>> pglazyfreed 0
>>> pgrefill 70008598
>>> pgsteal_kswapd 3567289713
>>> pgsteal_direct 5878057
>>> pgscan_kswapd 9059309872
>>> pgscan_direct 4239367903
>>> pgscan_direct_throttle 0
>>> zone_reclaim_failed 0
>>> pginodesteal 102916
>>> slabs_scanned 460790262
>>> kswapd_inodesteal 9130243
>>> kswapd_low_wmark_hit_quickly 10634373
>>> kswapd_high_wmark_hit_quickly 7348173
>>> pageoutrun 18349115
>>> pgrotated 16291322
>>> drop_pagecache 0
>>> drop_slab 0
>>> pgmigrate_success 18912908
>>> pgmigrate_fail 63382146
>>> compact_migrate_scanned 2986269789
>>> compact_free_scanned 190451505123
>>> compact_isolated 109549437
>>> compact_stall 3544
>>> compact_fail 8
>>> compact_success 3536
>>> compact_daemon_wake 1403515
>>> htlb_buddy_alloc_success 0
>>> htlb_buddy_alloc_fail 0
>>> unevictable_pgs_culled 12473
>>> unevictable_pgs_scanned 0
>>> unevictable_pgs_rescued 11979
>>> unevictable_pgs_mlocked 14556
>>> unevictable_pgs_munlocked 14556
>>> unevictable_pgs_cleared 0
>>> unevictable_pgs_stranded 0
>>> thp_fault_alloc 0
>>> thp_fault_fallback 0
>>> thp_collapse_alloc 0
>>> thp_collapse_alloc_failed 0
>>> thp_file_alloc 0
>>> thp_file_mapped 0
>>> thp_split_page 0
>>> thp_split_page_failed 0
>>> thp_deferred_split_page 0
>>> thp_split_pmd 0
>>> thp_zero_page_alloc 0
>>> thp_zero_page_alloc_failed 0
>>>
>>> kern.log OOM message:
>>> [737778.724194] snmpd invoked oom-killer:
>>> gfp_mask=0x24200ca(GFP_HIGHUSER_MOVABLE), order=0, oom_score_adj=0
>>> [737778.724246] snmpd cpuset=/ mems_allowed=0-1
>>> [737778.724278] CPU: 15 PID: 2976 Comm: snmpd Tainted: G        W I     4.8.4 #1
>>> [737778.724352]  0000000000000000 ffffffff81292069 ffff88041e043c48
>>> ffff88041e043c48
>>> [737778.724403]  ffffffff8118d1f6 ffff88041dd70fc0 ffff88041e043c48
>>> 000000000136236f
>>> [737778.724454]  ffffffff8170e11e 0000000000000001 ffffffff8112a700
>>> 000000000000030f
>>> [737778.724505] Call Trace:
>>> [737778.724533]  [<ffffffff81292069>] ? dump_stack+0x46/0x5d
>>> [737778.727077]  [<ffffffff8118d1f6>] ? dump_header.isra.16+0x56/0x185
>>> [737778.727108]  [<ffffffff8112a700>] ? oom_kill_process+0x210/0x3c0
>>> [737778.727136]  [<ffffffff8112ac4b>] ? out_of_memory+0x34b/0x420
>>> [737778.727165]  [<ffffffff8112fcca>] ? __alloc_pages_nodemask+0xd9a/0xde0
>>> [737778.727195]  [<ffffffff811768e1>] ? alloc_pages_vma+0xc1/0x240
>>> [737778.727223]  [<ffffffff81126512>] ? pagecache_get_page+0x22/0x230
>>> [737778.727253]  [<ffffffff81169f44>] ? __read_swap_cache_async+0x104/0x180
>>> [737778.727282]  [<ffffffff81169fcf>] ? read_swap_cache_async+0xf/0x30
>>> [737778.727311]  [<ffffffff8116a0dc>] ? swapin_readahead+0xec/0x1a0
>>> [737778.727340]  [<ffffffff81156270>] ? do_swap_page+0x420/0x5c0
>>> [737778.727369]  [<ffffffff813f36d8>] ? SYSC_recvfrom+0xa8/0x110
>>> [737778.727397]  [<ffffffff81157a39>] ? handle_mm_fault+0x629/0xe30
>>> [737778.727426]  [<ffffffff81048fc5>] ? __do_page_fault+0x1b5/0x480
>>> [737778.727456]  [<ffffffff814fbaa2>] ? page_fault+0x22/0x30
>>> [737778.727497] Mem-Info:
>>> [737778.727524] active_anon:24 inactive_anon:49 isolated_anon:0
>>> [737778.727524]  active_file:6920154 inactive_file:798043 isolated_file:576
>>> [737778.727524]  unevictable:0 dirty:800528 writeback:1307 unstable:0
>>> [737778.727524]  slab_reclaimable:264367 slab_unreclaimable:193348
>>> [737778.727524]  mapped:4063 shmem:0 pagetables:1719 bounce:0
>>> [737778.727524]  free:39225 free_pcp:47 free_cma:0
>>> [737778.727677] Node 0 active_anon:16kB inactive_anon:76kB
>>> active_file:14249324kB inactive_file:1296908kB unevictable:0kB
>>> isolated(anon):0kB isolated(file):1920kB mapped:10432kB
>>> dirty:1308528kB writeback:0kB shmem:0kB shmem_thp: 0kB
>>> shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB
>>> pages_scanned:23557303 all_unreclaimable? yes
>>> [737778.727806] Node 1 active_anon:80kB inactive_anon:120kB
>>> active_file:13431292kB inactive_file:1895264kB unevictable:0kB
>>> isolated(anon):0kB isolated(file):384kB mapped:5820kB dirty:1893584kB
>>> writeback:5228kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB
>>> anon_thp: 0kB writeback_tmp:0kB unstable:0kB pages_scanned:25598673
>>> all_unreclaimable? yes
>>> [737778.727930] Node 0 Normal free:44864kB min:45192kB low:61736kB
>>> high:78280kB active_anon:16kB inactive_anon:76kB
>>> active_file:14249324kB inactive_file:1296908kB unevictable:0kB
>>> writepending:1308528kB present:16777216kB managed:16544856kB
>>> mlocked:0kB slab_reclaimable:562644kB slab_unreclaimable:317504kB
>>> kernel_stack:3840kB pagetables:3672kB bounce:0kB free_pcp:20kB
>>> local_pcp:0kB free_cma:0kB
>>> [737778.728066] lowmem_reserve[]: 0 0 0 0
>>> [737778.728100] Node 1 DMA free:15896kB min:40kB low:52kB high:64kB
>>> active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB
>>> unevictable:0kB writepending:0kB present:15996kB managed:15896kB
>>> mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB
>>> kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB
>>> free_cma:0kB
>>> [737778.728228] lowmem_reserve[]: 0 3216 16044 16044
>>> [737778.728263] Node 1 DMA32 free:60300kB min:8996kB low:12288kB
>>> high:15580kB active_anon:4kB inactive_anon:4kB active_file:2660988kB
>>> inactive_file:474956kB unevictable:0kB writepending:475116kB
>>> present:3378660kB managed:3304720kB mlocked:0kB
>>> slab_reclaimable:83612kB slab_unreclaimable:16668kB kernel_stack:320kB
>>> pagetables:16kB bounce:0kB free_pcp:4kB local_pcp:4kB free_cma:0kB
>>> [737778.728397] lowmem_reserve[]: 0 0 12827 12827
>>> [737778.728431] Node 1 Normal free:35840kB min:35876kB low:49008kB
>>> high:62140kB active_anon:76kB inactive_anon:116kB
>>> active_file:10770304kB inactive_file:1420308kB unevictable:0kB
>>> writepending:1423696kB present:13369344kB managed:13135424kB
>>> mlocked:0kB slab_reclaimable:411212kB slab_unreclaimable:439220kB
>>> kernel_stack:2864kB pagetables:3188kB bounce:0kB free_pcp:164kB
>>> local_pcp:36kB free_cma:0kB
>>> [737778.728568] lowmem_reserve[]: 0 0 0 0
>>> [737778.728601] Node 0 Normal: 11208*4kB (UME) 4*8kB (U) 0*16kB 0*32kB
>>> 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 44864kB
>>> [737778.728686] Node 1 DMA: 0*4kB 1*8kB (U) 1*16kB (U) 0*32kB 2*64kB
>>> (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB
>>> (M) = 15896kB
>>> [737778.728786] Node 1 DMA32: 11759*4kB (UME) 1658*8kB (UM) 0*16kB
>>> 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =
>>> 60300kB
>>> [737778.728875] Node 1 Normal: 7984*4kB (UME) 470*8kB (UME) 3*16kB (U)
>>> 3*32kB (UM) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB
>>> = 35840kB
>>> [737778.728973] Node 0 hugepages_total=0 hugepages_free=0
>>> hugepages_surp=0 hugepages_size=1048576kB
>>> [737778.729019] Node 0 hugepages_total=0 hugepages_free=0
>>> hugepages_surp=0 hugepages_size=2048kB
>>> [737778.729065] Node 1 hugepages_total=0 hugepages_free=0
>>> hugepages_surp=0 hugepages_size=1048576kB
>>> [737778.729111] Node 1 hugepages_total=0 hugepages_free=0
>>> hugepages_surp=0 hugepages_size=2048kB
>>> [737778.729156] 7718841 total pagecache pages
>>> [737778.729179] 68 pages in swap cache
>>> [737778.729202] Swap cache stats: add 193888, delete 193820, find 160188/213014
>>> [737778.729231] Free swap  = 48045076kB
>>> [737778.729254] Total swap = 48300028kB
>>> [737778.729277] 8385304 pages RAM
>>> [737778.729299] 0 pages HighMem/MovableOnly
>>> [737778.729322] 135080 pages reserved
>>> [737778.729344] 0 pages hwpoisoned
>>> [737778.729365] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds
>>> swapents oom_score_adj name
>>> [737778.729417] [ 1927]     0  1927     9941      447      22       3
>>>     299         -1000 systemd-udevd
>>> [737778.729465] [ 2812]     0  2812     9289      412      23       4
>>>     161             0 rpcbind
>>> [737778.729512] [ 2836]   102  2836     9320      414      23       3
>>>     151             0 rpc.statd
>>> [737778.729560] [ 2851]   104  2851   162257      276      75       3
>>>    7489             0 apt-cacher-ng
>>> [737778.729608] [ 2856]     0  2856    13796      345      31       3
>>>     167         -1000 sshd
>>> [737778.729655] [ 2857]     0  2857    64668      504      27       4
>>>     355             0 rsyslogd
>>> [737778.729702] [ 2858]     0  2858     6876      518      18       3
>>>      83             0 cron
>>> [737778.729748] [ 2859]     0  2859     4756      360      14       3
>>>      44             0 atd
>>> [737778.729795] [ 2860]     0  2860     7059      523      18       3
>>>     591             0 smartd
>>> [737778.729842] [ 2864]     0  2864     7082      559      19       4
>>>      96             0 systemd-logind
>>> [737778.729890] [ 2865]   106  2865    10563      528      24       3
>>>     110          -900 dbus-daemon
>>> [737778.729938] [ 2925]     0  2925     3604      421      12       3
>>>      38             0 agetty
>>> [737778.729985] [ 2974]     0  2974     4852      365      13       3
>>>      73             0 irqbalance
>>> [737778.730032] [ 2976]   105  2976    14299      496      29       3
>>>    1534             0 snmpd
>>> [737778.730078] [ 2992]     0  2992     3180      227      11       3
>>>      38             0 mcelog
>>> [737778.730125] [ 3095]     0  3095    26571      344      43       3
>>>     259             0 sfcbd
>>> [737778.730172] [ 3172]     0  3172    20392      261      40       3
>>>     236             0 sfcbd
>>> [737778.730219] [ 3248]     0  3248    22441        0      41       3
>>>     238             0 sfcbd
>>> [737778.730265] [ 3249]     0  3249    39376      155      44       3
>>>     357             0 sfcbd
>>> [737778.730312] [ 3450]     0  3450    39377      104      44       3
>>>     244             0 sfcbd
>>> [737778.730359] [ 3467]     0  3467    58324      301      46       3
>>>     284             0 sfcbd
>>> [737778.730405] [ 3548]     0  3548   262686      643      66       4
>>>    4097             0 dsm_sa_datamgrd
>>> [737778.730453] [ 3563]   101  3563    13312      403      29       3
>>>     162             0 exim4
>>> [737778.730499] [ 3576]   107  3576     7293      493      19       3
>>>     148             0 ntpd
>>> [737778.730546] [ 3585]     0  3585    61531      577     117       3
>>>     496             0 winbindd
>>> [737778.730593] [ 3586]     0  3586    61531      578     118       3
>>>     512             0 winbindd
>>> [737778.730640] [ 3651]     0  3651    48584      566      36       3
>>>     487             0 dsm_sa_eventmgr
>>> [737778.730688] [ 3674]     0  3674    99593      576      47       3
>>>    1402             0 dsm_sa_snmpd
>>> [737778.730736] [ 3717]     0  3717     7923      285      18       3
>>>     115             0 dsm_om_connsvcd
>>> [737778.730784] [ 3718]     0  3718   740234     1744     202       7
>>>   30685             0 dsm_om_connsvcd
>>> [737778.730832] [ 3736]     0  3736   178651        0      55       3
>>>    3789             0 dsm_sa_datamgrd
>>> [737778.730880] [ 4056]     0  4056    26472      498      57       3
>>>     252             0 sshd
>>> [737778.730926] [ 4060]  1000  4060     8973      501      23       3
>>>     184             0 systemd
>>> [737778.730973] [ 4061]  1000  4061    15702        0      34       4
>>>     612             0 (sd-pam)
>>> [737778.731020] [ 4063]  1000  4063    26472      158      54       3
>>>     260             0 sshd
>>> [737778.731067] [ 4064]  1000  4064     6041      739      16       3
>>>     686             0 bash
>>> [737778.731113] [ 4083]  1000  4083    16853      493      37       3
>>>     128             0 su
>>> [737778.731160] [ 4084]     0  4084     5501      756      15       3
>>>     160             0 bash
>>> [737778.731207] [15150]     0 15150     3309      678      10       3
>>>      57             0 run_mirror.sh
>>> [737778.731256] [24296]     0 24296     1450      139       8       3
>>>      23             0 flock
>>> [737778.731302] [24297]     0 24297     9576      622      22       3
>>>    3990             0 rsync
>>> [737778.731349] [24298]     0 24298     7552      541      18       3
>>>    1073             0 rsync
>>> [737778.731395] [24299]     0 24299     9522      401      22       3
>>>    2416             0 rsync
>>> [737778.731445] [25910]     0 25910    10257      522      23       3
>>>      81             0 systemd-journal
>>> [737778.731494] [25940]     0 25940    16365      617      37       3
>>>     126             0 cron
>>> [737778.731540] Out of memory: Kill process 3718 (dsm_om_connsvcd)
>>> score 1 or sacrifice child
>>> [737778.731644] Killed process 3718 (dsm_om_connsvcd)
>>> total-vm:2960936kB, anon-rss:0kB, file-rss:6976kB, shmem-rss:0kB
>>> [737778.768375] oom_reaper: reaped process 3718 (dsm_om_connsvcd), now
>>> anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
>>>
>>> On Fri, Nov 4, 2016 at 5:00 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>>>> On 11/04/2016 03:13 PM, E V wrote:
>>>>> After the system panic'd yesterday I booted back into 4.8.4 and
>>>>> restarted the rsync's. I'm away on vacation next week, so when I get
>>>>> back I'll get rc4 or rc5 and try again. In the mean time here's data
>>>>> from the system running 4.8.4 without problems for about a day. I'm
>>>>> not familiar with xxd and didn't see a -e option, so used -E:
>>>>> xxd -E -g8 -c8 /proc/kpagecount | cut -d" " -f2 | sort | uniq -c
>>>>> 8258633 0000000000000000
>>>>>  216440 0100000000000000
>>>>
>>>> The lack of -e means it's big endian, which is not a big issue. So here
>>>> most of memory is free, some pages have just one pin, and only
>>>> relatively few have more. The vmstats also doesn't show anything bad, so
>>>> we'll have to wait if something appears within the week, or after you
>>>> try 4.9 again. Thanks.
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
