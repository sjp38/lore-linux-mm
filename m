Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 572CA6B7766
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 03:03:39 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id q11-v6so11852977oih.15
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 00:03:39 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id g8-v6si3149172oic.418.2018.09.06.00.03.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 00:03:37 -0700 (PDT)
Message-Id: <201809060703.w8673Kbs076435@www262.sakura.ne.jp>
Subject: Re: [PATCH] =?ISO-2022-JP?B?bW0scGFnZV9hbGxvYzogUEZfV1FfV09SS0VSIHRocmVh?=
 =?ISO-2022-JP?B?ZHMgbXVzdCBzbGVlcCBhdCBzaG91bGRfcmVjbGFpbV9yZXRyeSgpLg==?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Thu, 06 Sep 2018 16:03:20 +0900
References: <20180906055742.GL14951@dhcp22.suse.cz> 
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > I assert that we should fix af5679fbc669f31f.
> > 
> > If you can come up with reasonable patch which doesn't complicate the
> > code and it is a clear win for both this particular workload as well as
> > others then why not.
> 
> Why can't we do "at least MMF_OOM_SKIP should be set under the lock to
> prevent from races" ?
> 

Well, serializing setting of MMF_OOM_SKIP using oom_lock was not sufficient.
It seems that some more moment is needed for allowing last second allocation
attempt at __alloc_pages_may_oom() to succeed. We need to migrate to
"mm, oom: fix unnecessary killing of additional processes" thread.



[  702.895936] a.out invoked oom-killer: gfp_mask=0x6280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null), order=0, oom_score_adj=0
[  702.900717] a.out cpuset=/ mems_allowed=0
[  702.903210] CPU: 1 PID: 3359 Comm: a.out Tainted: G                T 4.19.0-rc2+ #692
[  702.906630] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[  702.910771] Call Trace:
[  702.912681]  dump_stack+0x85/0xcb
[  702.914918]  dump_header+0x69/0x2fe
[  702.917387]  ? _raw_spin_unlock_irqrestore+0x41/0x70
[  702.921267]  oom_kill_process+0x307/0x390
[  702.923809]  out_of_memory+0x2f3/0x5d0
[  702.926208]  __alloc_pages_slowpath+0xc01/0x1030
[  702.928817]  __alloc_pages_nodemask+0x333/0x390
[  702.931270]  alloc_pages_vma+0x77/0x1f0
[  702.933618]  __handle_mm_fault+0x81c/0xf40
[  702.935962]  handle_mm_fault+0x1b7/0x3c0
[  702.938215]  __do_page_fault+0x2a6/0x580
[  702.940481]  do_page_fault+0x32/0x270
[  702.942753]  ? page_fault+0x8/0x30
[  702.944860]  page_fault+0x1e/0x30
[  702.947138] RIP: 0033:0x4008d8
[  702.949722] Code: Bad RIP value.
[  702.952000] RSP: 002b:00007ffc21fd99c0 EFLAGS: 00010206
[  702.954570] RAX: 00007fb3457cc010 RBX: 0000000100000000 RCX: 0000000000000000
[  702.957631] RDX: 00000000b0b24000 RSI: 0000000000020000 RDI: 0000000200000050
[  702.960599] RBP: 00007fb3457cc010 R08: 0000000200001000 R09: 0000000000021000
[  702.963531] R10: 0000000000000022 R11: 0000000000001000 R12: 0000000000000006
[  702.966518] R13: 00007ffc21fd9ab0 R14: 0000000000000000 R15: 0000000000000000
[  702.971186] Mem-Info:
[  702.976959] active_anon:788641 inactive_anon:3457 isolated_anon:0
[  702.976959]  active_file:0 inactive_file:77 isolated_file:0
[  702.976959]  unevictable:0 dirty:0 writeback:0 unstable:0
[  702.976959]  slab_reclaimable:8152 slab_unreclaimable:24616
[  702.976959]  mapped:2806 shmem:3704 pagetables:4355 bounce:0
[  702.976959]  free:20831 free_pcp:136 free_cma:0
[  703.007374] Node 0 active_anon:3154564kB inactive_anon:13828kB active_file:304kB inactive_file:112kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:11028kB dirty:0kB writeback:0kB shmem:14816kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 2846720kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[  703.029994] Node 0 DMA free:13816kB min:308kB low:384kB high:460kB active_anon:1976kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15960kB managed:15876kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  703.055331] lowmem_reserve[]: 0 2717 3378 3378
[  703.062881] Node 0 DMA32 free:58152kB min:54108kB low:67632kB high:81156kB active_anon:2718364kB inactive_anon:12kB active_file:424kB inactive_file:852kB unevictable:0kB writepending:0kB present:3129152kB managed:2782296kB mlocked:0kB kernel_stack:352kB pagetables:388kB bounce:0kB free_pcp:728kB local_pcp:0kB free_cma:0kB
[  703.091529] lowmem_reserve[]: 0 0 661 661
[  703.096552] Node 0 Normal free:12900kB min:13164kB low:16452kB high:19740kB active_anon:434248kB inactive_anon:13816kB active_file:0kB inactive_file:48kB unevictable:0kB writepending:0kB present:1048576kB managed:676908kB mlocked:0kB kernel_stack:6720kB pagetables:17028kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  703.123046] lowmem_reserve[]: 0 0 0 0
[  703.127490] Node 0 DMA: 0*4kB 1*8kB (M) 1*16kB (U) 3*32kB (U) 4*64kB (UM) 1*128kB (U) 0*256kB 0*512kB 1*1024kB (U) 0*2048kB 3*4096kB (M) = 13816kB
[  703.134763] Node 0 DMA32: 85*4kB (UM) 59*8kB (UM) 61*16kB (UM) 65*32kB (UME) 47*64kB (UE) 44*128kB (UME) 41*256kB (UME) 27*512kB (UME) 20*1024kB (ME) 0*2048kB 0*4096kB = 57308kB
[  703.144076] Node 0 Normal: 119*4kB (UM) 69*8kB (UM) 156*16kB (UME) 179*32kB (UME) 44*64kB (UE) 9*128kB (UE) 1*256kB (E) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 13476kB
[  703.151746] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  703.156537] 3744 total pagecache pages
[  703.159017] 0 pages in swap cache
[  703.163209] Swap cache stats: add 0, delete 0, find 0/0
[  703.167254] Free swap  = 0kB
[  703.170577] Total swap = 0kB
[  703.173758] 1048422 pages RAM
[  703.176843] 0 pages HighMem/MovableOnly
[  703.180380] 179652 pages reserved
[  703.183718] 0 pages cma reserved
[  703.187160] 0 pages hwpoisoned
[  703.190058] Out of memory: Kill process 3359 (a.out) score 834 or sacrifice child
[  703.194707] Killed process 3359 (a.out) total-vm:4267252kB, anon-rss:2894908kB, file-rss:0kB, shmem-rss:0kB
[  703.203016] in:imjournal invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
[  703.231814] in:imjournal cpuset=/ mems_allowed=0
[  703.231824] CPU: 2 PID: 1001 Comm: in:imjournal Tainted: G                T 4.19.0-rc2+ #692
[  703.231825] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[  703.231826] Call Trace:
[  703.231834]  dump_stack+0x85/0xcb
[  703.231839]  dump_header+0x69/0x2fe
[  703.231844]  ? _raw_spin_unlock_irqrestore+0x41/0x70
[  703.252369]  oom_kill_process+0x307/0x390
[  703.252375]  out_of_memory+0x2f3/0x5d0
[  703.252379]  __alloc_pages_slowpath+0xc01/0x1030
[  703.252388]  __alloc_pages_nodemask+0x333/0x390
[  703.262608]  filemap_fault+0x465/0x910
[  703.262663]  ? xfs_ilock+0xbf/0x2b0 [xfs]
[  703.262690]  ? __xfs_filemap_fault+0x7d/0x2c0 [xfs]
[  703.262695]  ? down_read_nested+0x66/0xa0
[  703.262718]  __xfs_filemap_fault+0x8e/0x2c0 [xfs]
[  703.262727]  __do_fault+0x11/0x133
[  703.262730]  __handle_mm_fault+0xa57/0xf40
[  703.262736]  handle_mm_fault+0x1b7/0x3c0
[  703.262742]  __do_page_fault+0x2a6/0x580
[  703.262748]  do_page_fault+0x32/0x270
[  703.262754]  ? page_fault+0x8/0x30
[  703.262756]  page_fault+0x1e/0x30
[  703.262759] RIP: 0033:0x7f5f078f6e28
[  703.262765] Code: Bad RIP value.
[  703.262766] RSP: 002b:00007f5f05007c50 EFLAGS: 00010246
[  703.262768] RAX: 0000000000000300 RBX: 0000000000000009 RCX: 00007f5f05007d80
[  703.262769] RDX: 00000000000003dd RSI: 00007f5f07b1ca1a RDI: 00005596745e9bb0
[  703.262770] RBP: 00007f5f05007d70 R08: 0000000000000006 R09: 0000000000000078
[  703.262771] R10: 00005596745e9810 R11: 00007f5f082bb4a0 R12: 00007f5f05007d90
[  703.262772] R13: 00007f5f00035fc0 R14: 00007f5f0003c850 R15: 00007f5f0000d760
[  703.263679] Mem-Info:
[  703.263692] active_anon:243554 inactive_anon:3457 isolated_anon:0
[  703.263692]  active_file:53 inactive_file:4386 isolated_file:3
[  703.263692]  unevictable:0 dirty:0 writeback:0 unstable:0
[  703.263692]  slab_reclaimable:8152 slab_unreclaimable:24512
[  703.263692]  mapped:3730 shmem:3704 pagetables:3123 bounce:0
[  703.263692]  free:562331 free_pcp:502 free_cma:0
[  703.263698] Node 0 active_anon:974216kB inactive_anon:13828kB active_file:212kB inactive_file:17544kB unevictable:0kB isolated(anon):0kB isolated(file):12kB mapped:14920kB dirty:0kB writeback:0kB shmem:14816kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 305152kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[  703.263700] Node 0 DMA free:13816kB min:308kB low:384kB high:460kB active_anon:1976kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15960kB managed:15876kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  703.263705] lowmem_reserve[]: 0 2717 3378 3378
[  703.263712] Node 0 DMA32 free:2077084kB min:54108kB low:67632kB high:81156kB active_anon:696988kB inactive_anon:12kB active_file:252kB inactive_file:756kB unevictable:0kB writepending:0kB present:3129152kB managed:2782296kB mlocked:0kB kernel_stack:352kB pagetables:388kB bounce:0kB free_pcp:1328kB local_pcp:248kB free_cma:0kB
[  703.263716] lowmem_reserve[]: 0 0 661 661
[  703.263722] Node 0 Normal free:158424kB min:13164kB low:16452kB high:19740kB active_anon:275676kB inactive_anon:13816kB active_file:0kB inactive_file:16084kB unevictable:0kB writepending:0kB present:1048576kB managed:676908kB mlocked:0kB kernel_stack:6720kB pagetables:12100kB bounce:0kB free_pcp:680kB local_pcp:148kB free_cma:0kB
[  703.263726] lowmem_reserve[]: 0 0 0 0
[  703.263731] Node 0 DMA: 0*4kB 1*8kB (M) 1*16kB (U) 3*32kB (U) 4*64kB (UM) 1*128kB (U) 0*256kB 0*512kB 1*1024kB (U) 0*2048kB 3*4096kB (M) = 13816kB
[  703.263752] Node 0 DMA32: 122*4kB (UM) 83*8kB (UM) 56*16kB (UM) 70*32kB (UME) 47*64kB (UE) 46*128kB (UME) 41*256kB (UME) 27*512kB (UME) 20*1024kB (ME) 213*2048kB (M) 387*4096kB (M) = 2079360kB
[  703.263776] Node 0 Normal: 653*4kB (UM) 1495*8kB (UM) 1604*16kB (UME) 1069*32kB (UME) 278*64kB (UME) 147*128kB (UME) 85*256kB (ME) 6*512kB (M) 0*1024kB 7*2048kB (M) 2*4096kB (M) = 158412kB
[  703.263801] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  703.263802] 8221 total pagecache pages
[  703.263804] 0 pages in swap cache
[  703.263806] Swap cache stats: add 0, delete 0, find 0/0
[  703.263807] Free swap  = 0kB
[  703.263808] Total swap = 0kB
[  703.263810] 1048422 pages RAM
[  703.263811] 0 pages HighMem/MovableOnly
[  703.263812] 179652 pages reserved
[  703.263813] 0 pages cma reserved
[  703.263814] 0 pages hwpoisoned
[  703.263817] Out of memory: Kill process 1089 (java) score 52 or sacrifice child
[  703.264145] Killed process 1089 (java) total-vm:5555688kB, anon-rss:181976kB, file-rss:0kB, shmem-rss:0kB
[  703.300281] oom_reaper: reaped process 3359 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
