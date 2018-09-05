Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5640A6B7350
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 09:21:43 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id l24-v6so6946457iok.21
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 06:21:43 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 189-v6si1273501iou.175.2018.09.05.06.21.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 06:21:41 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
 should_reclaim_retry().
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
References: <cb2d635c-c14d-c2cc-868a-d4c447364f0d@i-love.sakura.ne.jp>
 <alpine.DEB.2.21.1808231544001.150774@chino.kir.corp.google.com>
 <201808240031.w7O0V5hT019529@www262.sakura.ne.jp>
Message-ID: <195a512f-aecc-f8cf-f409-6c42ee924a8c@i-love.sakura.ne.jp>
Date: Wed, 5 Sep 2018 22:20:58 +0900
MIME-Version: 1.0
In-Reply-To: <201808240031.w7O0V5hT019529@www262.sakura.ne.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2018/08/24 9:31, Tetsuo Handa wrote:
> For now, I don't think we need to add af5679fbc669f31f to the list for
> CVE-2016-10723, for af5679fbc669f31f might cause premature next OOM victim
> selection (especially with CONFIG_PREEMPT=y kernels) due to
> 
>    __alloc_pages_may_oom():               oom_reap_task():
> 
>      mutex_trylock(&oom_lock) succeeds.
>      get_page_from_freelist() fails.
>      Preempted to other process.
>                                             oom_reap_task_mm() succeeds.
>                                             Sets MMF_OOM_SKIP.
>      Returned from preemption.
>      Finds that MMF_OOM_SKIP was already set.
>      Selects next OOM victim and kills it.
>      mutex_unlock(&oom_lock) is called.
> 
> race window like described as
> 
>     Tetsuo was arguing that at least MMF_OOM_SKIP should be set under the lock
>     to prevent from races when the page allocator didn't manage to get the
>     freed (reaped) memory in __alloc_pages_may_oom but it sees the flag later
>     on and move on to another victim.  Although this is possible in principle
>     let's wait for it to actually happen in real life before we make the
>     locking more complex again.
> 
> in that commit.
> 

Yes, that race window is real. We can needlessly select next OOM victim.
I think that af5679fbc669f31f was too optimistic.

[  278.147280] Out of memory: Kill process 9943 (a.out) score 919 or sacrifice child
[  278.148927] Killed process 9943 (a.out) total-vm:4267252kB, anon-rss:3430056kB, file-rss:0kB, shmem-rss:0kB
[  278.151586] vmtoolsd invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
[  278.156642] vmtoolsd cpuset=/ mems_allowed=0
[  278.158884] CPU: 2 PID: 8916 Comm: vmtoolsd Kdump: loaded Not tainted 4.19.0-rc2+ #465
[  278.162252] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[  278.165499] Call Trace:
[  278.166693]  dump_stack+0x99/0xdc
[  278.167922]  dump_header+0x70/0x2fa
[  278.169414] oom_reaper: reaped process 9943 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  278.169629]  ? _raw_spin_unlock_irqrestore+0x6a/0x8c
[  278.169633]  oom_kill_process+0x2ee/0x380
[  278.169635]  out_of_memory+0x136/0x540
[  278.169636]  ? out_of_memory+0x1fc/0x540
[  278.169640]  __alloc_pages_slowpath+0x986/0xce4
[  278.169641]  ? get_page_from_freelist+0x16b/0x1600
[  278.169646]  __alloc_pages_nodemask+0x398/0x3d0
[  278.180594]  alloc_pages_current+0x65/0xb0
[  278.182173]  __page_cache_alloc+0x154/0x190
[  278.184200]  ? pagecache_get_page+0x27/0x250
[  278.185410]  filemap_fault+0x4df/0x880
[  278.186282]  ? filemap_fault+0x31b/0x880
[  278.187395]  ? xfs_ilock+0x1bd/0x220
[  278.188264]  ? __xfs_filemap_fault+0x76/0x270
[  278.189268]  ? down_read_nested+0x48/0x80
[  278.190229]  ? xfs_ilock+0x1bd/0x220
[  278.191061]  __xfs_filemap_fault+0x89/0x270
[  278.192059]  xfs_filemap_fault+0x27/0x30
[  278.192967]  __do_fault+0x1f/0x70
[  278.193777]  __handle_mm_fault+0xfbd/0x1470
[  278.194743]  handle_mm_fault+0x1f2/0x400
[  278.195679]  ? handle_mm_fault+0x47/0x400
[  278.196618]  __do_page_fault+0x217/0x4b0
[  278.197504]  do_page_fault+0x3c/0x21e
[  278.198303]  ? page_fault+0x8/0x30
[  278.199092]  page_fault+0x1e/0x30
[  278.199821] RIP: 0033:0x7f2322ebbfb0
[  278.200605] Code: Bad RIP value.
[  278.201370] RSP: 002b:00007ffda96e7648 EFLAGS: 00010246
[  278.202518] RAX: 0000000000000000 RBX: 00007f23220f26b0 RCX: 0000000000000010
[  278.204280] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 00007f2321ecfb5b
[  278.205838] RBP: 0000000002504b70 R08: 00007f2321ecfb60 R09: 000000000250bd20
[  278.207426] R10: 383836312d646c69 R11: 0000000000000000 R12: 00007ffda96e76b0
[  278.208982] R13: 00007f2322ea8540 R14: 000000000250ba90 R15: 00007f2323173920
[  278.210840] Mem-Info:
[  278.211462] active_anon:18629 inactive_anon:2390 isolated_anon:0
[  278.211462]  active_file:19 inactive_file:1565 isolated_file:0
[  278.211462]  unevictable:0 dirty:0 writeback:0 unstable:0
[  278.211462]  slab_reclaimable:5820 slab_unreclaimable:8964
[  278.211462]  mapped:2128 shmem:2493 pagetables:1826 bounce:0
[  278.211462]  free:878043 free_pcp:909 free_cma:0
[  278.218830] Node 0 active_anon:74516kB inactive_anon:9560kB active_file:76kB inactive_file:6260kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:8512kB dirty:0kB writeback:0kB shmem:9972kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 43008kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
[  278.224997] Node 0 DMA free:15888kB min:288kB low:360kB high:432kB active_anon:32kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  278.230602] lowmem_reserve[]: 0 2663 3610 3610
[  278.231887] Node 0 DMA32 free:2746332kB min:49636kB low:62044kB high:74452kB active_anon:2536kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2749920kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:1500kB local_pcp:0kB free_cma:0kB
[  278.238291] lowmem_reserve[]: 0 0 947 947
[  278.239270] Node 0 Normal free:749952kB min:17652kB low:22064kB high:26476kB active_anon:72816kB inactive_anon:9560kB active_file:264kB inactive_file:5556kB unevictable:0kB writepending:4kB present:1048576kB managed:969932kB mlocked:0kB kernel_stack:5328kB pagetables:7092kB bounce:0kB free_pcp:2132kB local_pcp:64kB free_cma:0kB
[  278.245895] lowmem_reserve[]: 0 0 0 0
[  278.246820] Node 0 DMA: 0*4kB 0*8kB 0*16kB 1*32kB (U) 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15904kB
[  278.249659] Node 0 DMA32: 7*4kB (U) 8*8kB (UM) 8*16kB (U) 8*32kB (U) 8*64kB (U) 6*128kB (U) 7*256kB (UM) 7*512kB (UM) 3*1024kB (UM) 2*2048kB (M) 667*4096kB (UM) = 2746332kB
[  278.253054] Node 0 Normal: 4727*4kB (UME) 3423*8kB (UME) 1679*16kB (UME) 704*32kB (UME) 253*64kB (UME) 107*128kB (UME) 38*256kB (M) 16*512kB (M) 10*1024kB (M) 9*2048kB (M) 141*4096kB (M) = 749700kB
[  278.257158] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  278.259018] 4125 total pagecache pages
[  278.259896] 0 pages in swap cache
[  278.260745] Swap cache stats: add 0, delete 0, find 0/0
[  278.261934] Free swap  = 0kB
[  278.262750] Total swap = 0kB
[  278.263483] 1048445 pages RAM
[  278.264216] 0 pages HighMem/MovableOnly
[  278.265077] 114506 pages reserved
[  278.265971] Tasks state (memory values in pages):
[  278.267118] [  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name
[  278.269090] [   2846]     0  2846      267      171    32768        0             0 none
[  278.271221] [   4891]     0  4891     9772      856   110592        0             0 systemd-journal
[  278.273253] [   6610]     0  6610    10811      261   114688        0         -1000 systemd-udevd
[  278.275197] [   6709]     0  6709    13880      112   131072        0         -1000 auditd
[  278.277067] [   7388]     0  7388     3307       52    69632        0             0 rngd
[  278.278880] [   7393]     0  7393    24917      403   184320        0             0 VGAuthService
[  278.280864] [   7510]    70  7510    15043      102   155648        0             0 avahi-daemon
[  278.282898] [   7555]     0  7555     5420      372    81920        0             0 irqbalance
[  278.284836] [   7563]     0  7563     6597       83   102400        0             0 systemd-logind
[  278.286959] [   7565]    81  7565    14553      157   167936        0          -900 dbus-daemon
[  278.288985] [   8286]    70  8286    15010       98   151552        0             0 avahi-daemon
[  278.290958] [   8731]     0  8731    74697      999   270336        0             0 vmtoolsd
[  278.293008] [   8732]   999  8732   134787     1730   274432        0             0 polkitd
[  278.294906] [   8733]     0  8733    55931      467   274432        0             0 abrtd
[  278.296774] [   8734]     0  8734    55311      354   266240        0             0 abrt-watch-log
[  278.298839] [   8774]     0  8774    31573      155   106496        0             0 crond
[  278.300810] [   8790]     0  8790    89503     5482   421888        0             0 firewalld
[  278.302727] [   8916]     0  8916    45262      211   204800        0             0 vmtoolsd
[  278.304841] [   9230]     0  9230    26877      507   229376        0             0 dhclient
[  278.306733] [   9333]     0  9333    87236      451   528384        0             0 nmbd
[  278.308554] [   9334]     0  9334    28206      257   253952        0         -1000 sshd
[  278.310431] [   9335]     0  9335   143457     3260   430080        0             0 tuned
[  278.312278] [   9337]     0  9337    55682     2442   200704        0             0 rsyslogd
[  278.314188] [   9497]     0  9497    24276      170   233472        0             0 login
[  278.316038] [   9498]     0  9498    27525       33    73728        0             0 agetty
[  278.317918] [   9539]     0  9539   104864      581   659456        0             0 smbd
[  278.319738] [   9590]     0  9590   103799      555   610304        0             0 smbd-notifyd
[  278.321918] [   9591]     0  9591   103797      555   602112        0             0 cleanupd
[  278.323935] [   9592]     0  9592   104864      580   610304        0             0 lpqd
[  278.325835] [   9596]     0  9596    28894      129    90112        0             0 bash
[  278.327663] [   9639]     0  9639    28833      474   249856        0             0 sendmail
[  278.329550] [   9773]    51  9773    26644      411   229376        0             0 sendmail
[  278.331527] Out of memory: Kill process 8790 (firewalld) score 5 or sacrifice child
[  278.333267] Killed process 8790 (firewalld) total-vm:358012kB, anon-rss:21928kB, file-rss:0kB, shmem-rss:0kB
[  278.336430] oom_reaper: reaped process 8790 (firewalld), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
