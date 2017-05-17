Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 41A806B02E1
	for <linux-mm@kvack.org>; Wed, 17 May 2017 15:43:50 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id j58so7556353qtc.2
        for <linux-mm@kvack.org>; Wed, 17 May 2017 12:43:50 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id i63si2431954qkf.87.2017.05.17.12.43.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 12:43:48 -0700 (PDT)
Date: Wed, 17 May 2017 20:43:16 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] mm,oom: fix oom invocation issues
Message-ID: <20170517194316.GA30517@castle>
References: <1495034780-9520-1-git-send-email-guro@fb.com>
 <20170517161446.GB20660@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170517161446.GB20660@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, kernel-team@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, May 17, 2017 at 06:14:46PM +0200, Michal Hocko wrote:
> On Wed 17-05-17 16:26:20, Roman Gushchin wrote:
> [...]
> > [   25.781882] Out of memory: Kill process 492 (allocate) score 899 or sacrifice child
> > [   25.783874] Killed process 492 (allocate) total-vm:2052368kB, anon-rss:1894576kB, file-rss:4kB, shmem-rss:0kB
> 
> Are there any oom_reaper messages? Could you provide the full kernel log
> please?

Sure. Sorry, it was too bulky, so I've cut the line about oom_reaper by mistake.
Here it is:
--------------------------------------------------------------------------------
[   25.721494] allocate invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null),  order=0, oom_score_adj=0
[   25.725658] allocate cpuset=/ mems_allowed=0
[   25.727033] CPU: 1 PID: 492 Comm: allocate Not tainted 4.12.0-rc1-mm1+ #181
[   25.729215] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
[   25.729598] Call Trace:
[   25.729598]  dump_stack+0x63/0x82
[   25.729598]  dump_header+0x97/0x21a
[   25.729598]  ? do_try_to_free_pages+0x2d7/0x360
[   25.729598]  ? security_capable_noaudit+0x45/0x60
[   25.729598]  oom_kill_process+0x219/0x3e0
[   25.729598]  out_of_memory+0x11d/0x480
[   25.729598]  __alloc_pages_slowpath+0xc84/0xd40
[   25.729598]  __alloc_pages_nodemask+0x245/0x260
[   25.729598]  alloc_pages_vma+0xa2/0x270
[   25.729598]  __handle_mm_fault+0xca9/0x10c0
[   25.729598]  handle_mm_fault+0xf3/0x210
[   25.729598]  __do_page_fault+0x240/0x4e0
[   25.729598]  trace_do_page_fault+0x37/0xe0
[   25.729598]  do_async_page_fault+0x19/0x70
[   25.729598]  async_page_fault+0x28/0x30
[   25.729598] RIP: 0033:0x400760
[   25.729598] RSP: 002b:00007ffe30dd9970 EFLAGS: 00010287
[   25.729598] RAX: 00007fd9bd760010 RBX: 0000000070800000 RCX: 0000000000000006
[   25.729598] RDX: 00007fd9c6d2a010 RSI: 000000000c801000 RDI: 0000000000000000
[   25.729598] RBP: 000000000c800000 R08: ffffffffffffffff R09: 0000000000000000
[   25.729598] R10: 00007fd9ba52a010 R11: 0000000000000246 R12: 00000000004007b0
[   25.729598] R13: 00007ffe30dd9a60 R14: 0000000000000000 R15: 0000000000000000
[   25.750476] Mem-Info:
[   25.750746] active_anon:487992 inactive_anon:51 isolated_anon:0
[   25.750746]  active_file:30 inactive_file:12 isolated_file:0
[   25.750746]  unevictable:0 dirty:30 writeback:0 unstable:0
[   25.750746]  slab_reclaimable:2834 slab_unreclaimable:2448
[   25.750746]  mapped:27 shmem:123 pagetables:1739 bounce:0
[   25.750746]  free:13239 free_pcp:0 free_cma:0
[   25.754758] Node 0 active_anon:1951968kB inactive_anon:204kB active_file:120kB inactive_file:48kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:108kB dirty:120kB writeback:0kB shmem:492kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 1726464kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[   25.757328] Node 0 DMA free:8256kB min:348kB low:432kB high:516kB active_anon:7588kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15908kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:8kB kernel_stack:0kB pagetables:24kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   25.759531] lowmem_reserve[]: 0 1981 1981 1981 1981
[   25.759892] Node 0 DMA32 free:44700kB min:44704kB low:55880kB high:67056kB active_anon:1944216kB inactive_anon:204kB active_file:592kB inactive_file:0kB unevictable:0kB writepending:304kB present:2080640kB managed:2031972kB mlocked:0kB slab_reclaimable:11336kB slab_unreclaimable:9784kB kernel_stack:1776kB pagetables:6932kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   25.762570] lowmem_reserve[]: 0 0 0 0 0
[   25.762867] Node 0 DMA: 2*4kB (UM) 1*8kB (M) 1*16kB (M) 1*32kB (U) 2*64kB (UM) 1*128kB (U) 1*256kB (U) 1*512kB (M) 1*1024kB (U) 1*2048kB (M) 1*4096kB (M) = 8256kB
[   25.763947] Node 0 DMA32: 319*4kB (UME) 192*8kB (UME) 81*16kB (UE) 32*32kB (UME) 13*64kB (UME) 81*128kB (UME) 43*256kB (M) 23*512kB (UME) 6*1024kB (UME) 0*2048kB 0*4096kB = 45260kB
[   25.765134] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   25.765752] 166 total pagecache pages
[   25.766025] 0 pages in swap cache
[   25.766273] Swap cache stats: add 0, delete 0, find 0/0
[   25.766658] Free swap  = 0kB
[   25.766874] Total swap = 0kB
[   25.767091] 524158 pages RAM
[   25.767308] 0 pages HighMem/MovableOnly
[   25.767602] 12188 pages reserved
[   25.767844] 0 pages cma reserved
[   25.768083] 0 pages hwpoisoned
[   25.768293] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[   25.768860] [  121]     0   121    25672      133      50       3        0             0 systemd-journal
[   25.769530] [  156]     0   156    11157      197      22       3        0         -1000 systemd-udevd
[   25.770206] [  206]     0   206    13896       99      29       3        0         -1000 auditd
[   25.770822] [  227]     0   227    11874      124      27       3        0             0 systemd-logind
[   25.771494] [  229]    81   229    11577      146      28       3        0          -900 dbus-daemon
[   25.772126] [  231]   997   231    27502      102      25       3        0             0 chronyd
[   25.772731] [  233]     0   233    61519     5239      85       3        0             0 firewalld
[   25.773345] [  238]     0   238   123495      529      74       4        0             0 NetworkManager
[   25.773988] [  265]     0   265    25117      231      52       3        0         -1000 sshd
[   25.774569] [  271]     0   271     6092      154      17       3        0             0 crond
[   25.775137] [  277]     0   277    11297       93      26       3        0             0 systemd-hostnam
[   25.775766] [  284]     0   284     1716       29       9       3        0             0 agetty
[   25.776342] [  285]     0   285     2030       34       9       4        0             0 agetty
[   25.776919] [  302]   998   302   133102     2578      58       3        0             0 polkitd
[   25.777505] [  394]     0   394    21785     3076      45       3        0             0 dhclient
[   25.778092] [  444]     0   444    36717      312      74       3        0             0 sshd
[   25.778744] [  446]     0   446    15966      223      36       3        0             0 systemd
[   25.779304] [  447]     0   447    23459      384      47       3        0             0 (sd-pam)
[   25.779877] [  451]     0   451    36717      316      72       3        0             0 sshd
[   25.780450] [  452]     0   452     3611      315      11       3        0             0 bash
[   25.781107] [  492]     0   492   513092   473645     934       5        0             0 allocate
[   25.781882] Out of memory: Kill process 492 (allocate) score 899 or sacrifice child
[   25.783874] Killed process 492 (allocate) total-vm:2052368kB, anon-rss:1894576kB, file-rss:4kB, shmem-rss:0kB
[   25.785680] allocate: page allocation failure: order:0, mode:0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null)
[   25.786797] allocate cpuset=/ mems_allowed=0
[   25.787246] CPU: 1 PID: 492 Comm: allocate Not tainted 4.12.0-rc1-mm1+ #181
[   25.787935] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
[   25.788867] Call Trace:
[   25.789119]  dump_stack+0x63/0x82
[   25.789451]  warn_alloc+0x114/0x1b0
[   25.789451]  __alloc_pages_slowpath+0xd32/0xd40
[   25.789451]  __alloc_pages_nodemask+0x245/0x260
[   25.789451]  alloc_pages_vma+0xa2/0x270
[   25.789451]  __handle_mm_fault+0xca9/0x10c0
[   25.789451]  handle_mm_fault+0xf3/0x210
[   25.789451]  __do_page_fault+0x240/0x4e0
[   25.789451]  trace_do_page_fault+0x37/0xe0
[   25.789451]  do_async_page_fault+0x19/0x70
[   25.789451]  async_page_fault+0x28/0x30
[   25.789451] RIP: 0033:0x400760
[   25.789451] RSP: 002b:00007ffe30dd9970 EFLAGS: 00010287
[   25.789451] RAX: 00007fd9bd760010 RBX: 0000000070800000 RCX: 0000000000000006
[   25.789451] RDX: 00007fd9c6d2a010 RSI: 000000000c801000 RDI: 0000000000000000
[   25.789451] RBP: 000000000c800000 R08: ffffffffffffffff R09: 0000000000000000
[   25.789451] R10: 00007fd9ba52a010 R11: 0000000000000246 R12: 00000000004007b0
[   25.789451] R13: 00007ffe30dd9a60 R14: 0000000000000000 R15: 0000000000000000
[   25.797570] Mem-Info:
[   25.797796] active_anon:476253 inactive_anon:51 isolated_anon:0
[   25.797796]  active_file:30 inactive_file:12 isolated_file:0
[   25.797796]  unevictable:0 dirty:30 writeback:0 unstable:0
[   25.797796]  slab_reclaimable:2578 slab_unreclaimable:2448
[   25.797796]  mapped:27 shmem:123 pagetables:1739 bounce:0
[   25.797796]  free:24856 free_pcp:174 free_cma:0
[   25.799701] Node 0 active_anon:1790620kB inactive_anon:204kB active_file:120kB inactive_file:48kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:108kB dirty:120kB writeback:0kB shmem:492kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 1662976kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
[   25.801880] Node 0 DMA free:15808kB min:348kB low:432kB high:516kB active_anon:36kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15908kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:8kB kernel_stack:0kB pagetables:24kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   25.804130] lowmem_reserve[]: 0 1981 1981 1981 1981
[   25.804499] Node 0 DMA32 free:251876kB min:44704kB low:55880kB high:67056kB active_anon:1737368kB inactive_anon:204kB active_file:592kB inactive_file:0kB unevictable:0kB writepending:304kB present:2080640kB managed:2031972kB mlocked:0kB slab_reclaimable:10312kB slab_unreclaimable:9784kB kernel_stack:1776kB pagetables:6932kB bounce:0kB free_pcp:700kB local_pcp:0kB free_cma:0kB
[   25.807087] lowmem_reserve[]: 0 0 0 0 0
[   25.807456] Node 0 DMA: 2*4kB (U) 2*8kB (U) 0*16kB 1*32kB (U) 1*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15864kB
[   25.808777] Node 0 DMA32: 2413*4kB (UME) 1622*8kB (UME) 1197*16kB (UME) 935*32kB (UME) 661*64kB (UME) 268*128kB (UME) 107*256kB (UM) 46*512kB (UME) 18*1024kB (UME) 7*2048kB (M) 143*4096kB (M) = 817748kB
[   25.810517] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   25.810868] oom_reaper: reaped process 492 (allocate), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[   25.812656] 290 total pagecache pages
[   25.813043] 0 pages in swap cache
[   25.813398] Swap cache stats: add 0, delete 0, find 0/0
[   25.813756] Free swap  = 0kB
[   25.813966] Total swap = 0kB
[   25.814249] 524158 pages RAM
[   25.814547] 0 pages HighMem/MovableOnly
[   25.814957] 12188 pages reserved
[   25.815791] 0 pages cma reserved
[   25.816993] 0 pages hwpoisoned
[   25.817589] allocate invoked oom-killer: gfp_mask=0x0(), nodemask=(null),  order=0, oom_score_adj=0
[   25.818821] allocate cpuset=/ mems_allowed=0
[   25.819259] CPU: 1 PID: 492 Comm: allocate Not tainted 4.12.0-rc1-mm1+ #181
[   25.819847] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
[   25.820549] Call Trace:
[   25.820733]  dump_stack+0x63/0x82
[   25.820961]  dump_header+0x97/0x21a
[   25.820961]  ? security_capable_noaudit+0x45/0x60
[   25.820961]  oom_kill_process+0x219/0x3e0
[   25.820961]  out_of_memory+0x11d/0x480
[   25.820961]  pagefault_out_of_memory+0x68/0x80
[   25.820961]  mm_fault_error+0x8f/0x190
[   25.820961]  ? handle_mm_fault+0xf3/0x210
[   25.820961]  __do_page_fault+0x4b2/0x4e0
[   25.820961]  trace_do_page_fault+0x37/0xe0
[   25.820961]  do_async_page_fault+0x19/0x70
[   25.820961]  async_page_fault+0x28/0x30
[   25.820961] RIP: 0033:0x400760
[   25.820961] RSP: 002b:00007ffe30dd9970 EFLAGS: 00010287
[   25.820961] RAX: 00007fd9bd760010 RBX: 0000000070800000 RCX: 0000000000000006
[   25.820961] RDX: 00007fd9c6d2a010 RSI: 000000000c801000 RDI: 0000000000000000
[   25.820961] RBP: 000000000c800000 R08: ffffffffffffffff R09: 0000000000000000
[   25.820961] R10: 00007fd9ba52a010 R11: 0000000000000246 R12: 00000000004007b0
[   25.820961] R13: 00007ffe30dd9a60 R14: 0000000000000000 R15: 0000000000000000
[   25.827189] Mem-Info:
[   25.827440] active_anon:14317 inactive_anon:51 isolated_anon:0
[   25.827440]  active_file:28 inactive_file:468 isolated_file:0
[   25.827440]  unevictable:0 dirty:12 writeback:1 unstable:0
[   25.827440]  slab_reclaimable:2559 slab_unreclaimable:2398
[   25.827440]  mapped:274 shmem:123 pagetables:902 bounce:0
[   25.827440]  free:487556 free_pcp:19 free_cma:0
[   25.829867] Node 0 active_anon:57268kB inactive_anon:204kB active_file:112kB inactive_file:2040kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:1180kB dirty:48kB writeback:4kB shmem:492kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 12288kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
[   25.832174] Node 0 DMA free:15864kB min:348kB low:432kB high:516kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15908kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:8kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   25.835358] lowmem_reserve[]: 0 1981 1981 1981 1981
[   25.835784] Node 0 DMA32 free:1934360kB min:44704kB low:55880kB high:67056kB active_anon:57104kB inactive_anon:204kB active_file:416kB inactive_file:2476kB unevictable:0kB writepending:424kB present:2080640kB managed:2031972kB mlocked:0kB slab_reclaimable:10236kB slab_unreclaimable:9584kB kernel_stack:1776kB pagetables:3604kB bounce:0kB free_pcp:144kB local_pcp:0kB free_cma:0kB
[   25.838014] lowmem_reserve[]: 0 0 0 0 0
[   25.838365] Node 0 DMA: 2*4kB (U) 2*8kB (U) 0*16kB 1*32kB (U) 1*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15864kB
[   25.839339] Node 0 DMA32: 1708*4kB (UME) 1431*8kB (UME) 1005*16kB (UME) 735*32kB (UME) 502*64kB (UME) 236*128kB (UME) 114*256kB (UM) 45*512kB (UME) 20*1024kB (UME) 10*2048kB (M) 420*4096kB (M) = 1933720kB
[   25.840727] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[   25.841463] 938 total pagecache pages
[   25.841800] 0 pages in swap cache
[   25.842110] Swap cache stats: add 0, delete 0, find 0/0
[   25.842613] Free swap  = 0kB
[   25.842936] Total swap = 0kB
[   25.843206] 524158 pages RAM
[   25.843542] 0 pages HighMem/MovableOnly
[   25.843949] 12188 pages reserved
[   25.844248] 0 pages cma reserved
[   25.844522] 0 pages hwpoisoned
[   25.844732] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[   25.845390] [  121]     0   121    25672      473      50       3        0             0 systemd-journal
[   25.846511] [  156]     0   156    11157      197      22       3        0         -1000 systemd-udevd
[   25.847471] [  206]     0   206    13896       99      29       3        0         -1000 auditd
[   25.848224] [  227]     0   227    11874      124      27       3        0             0 systemd-logind
[   25.850604] [  229]    81   229    11577      146      28       3        0          -900 dbus-daemon
[   25.852160] [  231]   997   231    27502      102      25       3        0             0 chronyd
[   25.852875] [  233]     0   233    61519     5239      85       3        0             0 firewalld
[   25.853578] [  238]     0   238   123495      529      74       4        0             0 NetworkManager
[   25.854327] [  265]     0   265    25117      231      52       3        0         -1000 sshd
[   25.855001] [  271]     0   271     6092      154      17       3        0             0 crond
[   25.855683] [  277]     0   277    11297       93      26       3        0             0 systemd-hostnam
[   25.856429] [  284]     0   284     1716       29       9       3        0             0 agetty
[   25.857130] [  285]     0   285     2030       34       9       4        0             0 agetty
[   25.857798] [  302]   998   302   133102     2578      58       3        0             0 polkitd
[   25.858500] [  394]     0   394    21785     3076      45       3        0             0 dhclient
[   25.859162] [  444]     0   444    36717      312      74       3        0             0 sshd
[   25.859803] [  446]     0   446    15966      223      36       3        0             0 systemd
[   25.860456] [  447]     0   447    23459      384      47       3        0             0 (sd-pam)
[   25.861101] [  451]     0   451    36717      316      72       3        0             0 sshd
[   25.861746] [  452]     0   452     3611      315      11       3        0             0 bash
[   25.862456] [  492]     0   492   513092        0      97       5        0             0 allocate
[   25.863078] Out of memory: Kill process 233 (firewalld) score 10 or sacrifice child
[   25.863634] Killed process 233 (firewalld) total-vm:246076kB, anon-rss:20956kB, file-rss:0kB, shmem-rss:0kB
--------------------------------------------------------------------------------

> 
> > <cut>
> > [   25.817589] allocate invoked oom-killer: gfp_mask=0x0(), nodemask=(null),  order=0, oom_score_adj=0
> > [   25.818821] allocate cpuset=/ mems_allowed=0
> > [   25.819259] CPU: 1 PID: 492 Comm: allocate Not tainted 4.12.0-rc1-mm1+ #181
> > [   25.819847] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
> > [   25.820549] Call Trace:
> > [   25.820733]  dump_stack+0x63/0x82
> > [   25.820961]  dump_header+0x97/0x21a
> > [   25.820961]  ? security_capable_noaudit+0x45/0x60
> > [   25.820961]  oom_kill_process+0x219/0x3e0
> > [   25.820961]  out_of_memory+0x11d/0x480
> 
> This is interesting. OOM usually happens from the page allocator path.
> Hitting it from here means that somebody has returned VM_FAULT_OOM. Who
> was that and is there any preceeding OOM before?

It looks to me that one pagefault is causing two OOMs.
One is called from page allocation path, second from
pagefault_out_of_memory().

> 
> > [   25.820961]  pagefault_out_of_memory+0x68/0x80
> > [   25.820961]  mm_fault_error+0x8f/0x190
> > [   25.820961]  ? handle_mm_fault+0xf3/0x210
> > [   25.820961]  __do_page_fault+0x4b2/0x4e0
> > [   25.820961]  trace_do_page_fault+0x37/0xe0
> > [   25.820961]  do_async_page_fault+0x19/0x70
> > [   25.820961]  async_page_fault+0x28/0x30
> > <cut>
> > [   25.863078] Out of memory: Kill process 233 (firewalld) score 10 or sacrifice child
> > [   25.863634] Killed process 233 (firewalld) total-vm:246076kB, anon-rss:20956kB, file-rss:0kB, shmem-rss:0kB
> > 
> > After some investigations I've found some issues:
> > 
> > 1) Prior to commit 1af8bb432695 ("mm, oom: fortify task_will_free_mem()"),
> >    if a process with a pending SIGKILL was calling out_of_memory(),
> >    it was always immediately selected as a victim.
> 
> Yes but this had its own issues. Mainly picking the same victim again
> without making a further progress.

That is why I've added this check into the pagefault_out_of_memory(),
rather than out_of_memory(), where it was earlier.

> 
> >    But now, after some changes, it's not always a case.
> >    If a process has been reaped at the moment, MMF_SKIP_FLAG is set,
> >    task_will_free_mem() will return false, and a new
> >    victim selection logic will be started.
> 
> right. The point is that it doesn't make any sense to consider such a
> task because it either cannot be reaped or it has been reaped and there
> is not much left to consider. It would be interesting to see what
> happened in your case.
> 
> >    This actually happens if a userspace pagefault causing an OOM.
> >    pagefault_out_of_memory() is called in a context of a faulting
> >    process after it has been selected as OOM victim (assuming, it
> >    has), and killed. With some probability (there is a race with
> >    oom_reaper thread) this process will be passed to the oom reaper
> >    again, or an innocent victim will be selected and killed.
> > 
> > 2) We clear up the task->oom_reaper_list before setting
> >    the MMF_OOM_SKIP flag, so there is a race.
> 
> I am not sure what you mean here. Why would a race matter?

oom_reaper_list pointer is zeroed before MMF_OOM_SKIP flag is set.
Inbetween this process can be selected again and added to the
oom reaper queue. It's not a big issue, still.

> 
> > 
> > 3) We skip the MMF_OOM_SKIP flag check in case of
> >    an sysrq-triggered OOM.
> 
> yes because we we always want to pick a new victim when sysrq is
> invoked.
> 
> > To address these issues, the following is proposed:
> > 1) If task is already an oom victim, skip out_of_memory() call
> >    from the pagefault_out_of_memory().
> 
> Hmm, this alone doesn't look all that bad. It would be better to simply
> let the task die than go over the oom handling. But I am still not sure
> what is going on in your case so I do not see how could this help.
>  
> > 2) Set the MMF_OOM_SKIP bit in wake_oom_reaper() before adding a
> >    process to the oom_reaper list. If it's already set, do nothing.
> >    Do not rely on tsk->oom_reaper_list value.
> 
> This is wrong. The sole purpose of MMF_OOM_SKIP is to let the oom
> selection logic know that this task is not interesting anymore. Setting
> it in wake_oom_reaper means it would be set _before_ the oom_reaper had
> any chance to free any memory from the task. So we would

But if have selected a task once, it has no way back.
Anyway it will be reaped or will quit by itself soon. Right?
So, under no circumstances we should consider choosing them
as an OOM victim again.
There are no reasons to calculate it's badness again, etc.

> 
> > 3) Check the MMF_OOM_SKIP even if OOM is triggered by a sysrq.
> 
> The code is a bit messy here but we do check MMF_OOM_SKIP in that case.
> We just do it in oom_badness(). So this is not needed, strictly
> speaking.
> 
> That being said I would like to here more about the cause of the OOM and
> the full dmesg would be interesting. The proposed setting of
> MMF_OOM_SKIP before the task is reaped is a nogo, though.

If so, how you will prevent putting a process again into the reaper list,
if it's already reaped?

> 1) would be
> acceptable I think but I would have to think about it some more.

Actually, the first problem is much more serious, as it leads
to a killing of second process.

The second one can lead only to a unnecessary wake up of
the oom reaper thread, which is not great, but acceptable.

Thank you!

Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
