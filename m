Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id D92CC280298
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 06:08:43 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id x1so8271255plb.2
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 03:08:43 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i2si3668984pgt.354.2018.01.17.03.08.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Jan 2018 03:08:41 -0800 (PST)
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <CA+55aFwvgm+KKkRLaFsuAjTdfQooS=UaMScC0CbZQ9WnX_AF=g@mail.gmail.com>
	<201801160115.w0G1FOIG057203@www262.sakura.ne.jp>
	<CA+55aFxOn5n4O2JNaivi8rhDmeFhTQxEHD4xE33J9xOrFu=7kQ@mail.gmail.com>
	<201801170233.JDG21842.OFOJMQSHtOFFLV@I-love.SAKURA.ne.jp>
	<CA+55aFyxyjN0Mqnz66B4a0R+uR8DdfxdMhcg5rJVi8LwnpSRfA@mail.gmail.com>
In-Reply-To: <CA+55aFyxyjN0Mqnz66B4a0R+uR8DdfxdMhcg5rJVi8LwnpSRfA@mail.gmail.com>
Message-Id: <201801172008.CHH39543.FFtMHOOVSQJLFO@I-love.SAKURA.ne.jp>
Date: Wed, 17 Jan 2018 20:08:26 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, tony.luck@intel.com, vbabka@suse.cz, mhocko@kernel.org
Cc: dave.hansen@linux.intel.com, mingo@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

Linus Torvalds wrote:
> > It turned out that CONFIG_FLATMEM was irrelevant. I just did not hit it.
> 
> So have you actually been able to see the problem with FLATMEM, or is
> this based on the bisect? Because I really think the bisect is pretty
> much guaranteed to be wrong.

Oops, this "it" is "a different bug where bootup of qemu randomly hangs at

[    0.001000] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.003000] ..MP-BIOS bug: 8254 timer not connected to IO-APIC
[    0.003000] ...trying to set up timer (IRQ0) through the 8259A ...
[    0.003000] ..... (found apic 0 pin 2) ...
[    0.005000] ....... failed.
[    0.005000] ...trying to set up timer as Virtual Wire IRQ...
[   13.120000] random: crng init done

". This bug occurs with both CONFIG_FLATMEM=y or CONFIG_SPARSEMEM=y .



> On Tue, Jan 16, 2018 at 9:33 AM, Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
> >
> > Since I got a faster reproducer, I tried full bisection between 4.11 and 4.12-rc1.
> > But I have no idea why bisection arrives at c0332694903a37cf.
> 
> I don't think your reproducer is 100% reliable.
> 
> And bisection is great because it's very aggressive and optimal when
> it comes to testing. But that also implies that if *any* of the
> good/bad choices were incorrect, then the end result is pure garbage
> and isn't even *close* to the right commit.

OK. I missed the mark. I overlooked that 4.11 already has this problem.

----------
[   40.272926] BUG: unable to handle kernel paging request at f6d74b44
[   40.272934] IP: page_remove_rmap+0x7/0x2c0
[   40.272935] *pde = 3732c067 
[   40.272936] *pte = 36d74062 
[   40.272936] 
[   40.272938] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[   40.272939] Modules linked in: xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi serio_raw mptspi scsi_transport_spi mptscsih e1000 mptbase ata_piix libata
[   40.272952] CPU: 6 PID: 719 Comm: b.out Not tainted 4.11.0 #266
[   40.272952] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   40.272953] task: ef4c1e40 task.stack: ef578000
[   40.272955] EIP: page_remove_rmap+0x7/0x2c0
[   40.272956] EFLAGS: 00010246 CPU: 6
[   40.272957] EAX: f6d74b30 EBX: f6d74b30 ECX: 00000000 EDX: 00000000
[   40.272958] ESI: ef7d9640 EDI: 00000093 EBP: ef579a78 ESP: ef579a70
[   40.272959]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   40.272961] CR0: 80050033 CR2: f6d74b44 CR3: 2f4a8000 CR4: 000406d0
[   40.273046] Call Trace:
[   40.273050]  try_to_unmap_one+0x206/0x4f0
[   40.273055]  rmap_walk_file+0x13c/0x270
[   40.273057]  rmap_walk+0x32/0x60
[   40.273058]  try_to_unmap+0xad/0x150
[   40.273060]  ? page_remove_rmap+0x2c0/0x2c0
[   40.273062]  ? page_not_mapped+0x10/0x10
[   40.273063]  ? page_get_anon_vma+0x90/0x90
[   40.273066]  shrink_page_list+0x37a/0xd10
[   40.273069]  shrink_inactive_list+0x173/0x370
[   40.273072]  shrink_node_memcg+0x572/0x7d0
[   40.273074]  ? shrink_slab+0x1a0/0x2e0
[   40.273077]  shrink_node+0xb3/0x2c0
[   40.273079]  do_try_to_free_pages+0xb2/0x2b0
[   40.273081]  try_to_free_pages+0x1a4/0x2f0
[   40.273085]  ? schedule_timeout+0x142/0x200
[   40.273088]  __alloc_pages_slowpath+0x360/0x7e6
[   40.273091]  __alloc_pages_nodemask+0x1a4/0x1b0
[   40.273093]  do_anonymous_page+0xcb/0x500
[   40.273120]  ? xfs_filemap_fault+0x36/0x40 [xfs]
[   40.273122]  handle_mm_fault+0x52f/0x990
[   40.273125]  __do_page_fault+0x19c/0x460
[   40.273127]  ? __do_page_fault+0x460/0x460
[   40.273129]  do_page_fault+0x1a/0x20
[   40.273131]  common_exception+0x6c/0x72
[   40.273133] EIP: 0x8048437
[   40.273133] EFLAGS: 00010202 CPU: 6
[   40.273134] EAX: 001f8000 EBX: 7ff00000 ECX: 37803008 EDX: 00000000
[   40.273135] ESI: 7ff00000 EDI: 00000000 EBP: bfeffa68 ESP: bfeffa30
[   40.273137]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   40.273137] Code: ff ff ba 78 50 7a c1 89 d8 e8 a6 f8 fe ff 0f 0b 83 e8 01 e9 66 ff ff ff 8d b6 00 00 00 00 8d bf 00 00 00 00 55 89 e5 56 53 89 c3 <8b> 40 14 a8 01 0f 85 a4 01 00 00 89 d8 f6 40 04 01 74 5e 84 d2
[   40.273161] EIP: page_remove_rmap+0x7/0x2c0 SS:ESP: 0068:ef579a70
[   40.273162] CR2: 00000000f6d74b44
[   40.273164] ---[ end trace 902077077bed43fd ]---
----------

I needed to bisect between 4.10 and 4.11, and I got plausible culprit.

----------
# bad: [a351e9b9fc24e982ec2f0e76379a49826036da12] Linux 4.11
# good: [c470abd4fde40ea6a0846a2beab642a578c0b8cd] Linux 4.10
# good: [69973b830859bc6529a7a0468ba0d80ee5117826] Linux 4.9
# good: [c8d2bc9bc39ebea8437fd974fdbc21847bb897a3] Linux 4.8
# good: [523d939ef98fd712632d93a5a2b588e477a7565e] Linux 4.7
# good: [2dcd0af568b0cf583645c8a317dd12e344b1c72a] Linux 4.6
# good: [b562e44f507e863c6792946e4e1b1449fbbac85d] Linux 4.5
# good: [afd2ff9b7e1b367172f18ba7f693dfb62bdcb2dc] Linux 4.4
# good: [6a13feb9c82803e2b815eca72fa7a9f5561d7861] Linux 4.3
# good: [64291f7db5bd8150a74ad2036f1037e6a0428df2] Linux 4.2
# good: [b953c0d234bc72e8489d3bf51a276c5c4ec85345] Linux 4.1
# good: [39a8804455fb23f09157341d3ba7db6d7ae6ee76] Linux 4.0
git bisect start 'v4.11' 'v4.10' 'v4.9' 'v4.8' 'v4.7' 'v4.6' 'v4.5' 'v4.4' 'v4.3' 'v4.2' 'v4.1' 'v4.0' 'mm/'
# good: [1b096e5ae9f7181c770d59c6895f23a76c63adee] z3fold: extend compaction function
git bisect good 1b096e5ae9f7181c770d59c6895f23a76c63adee
# good: [8703e8a465b1e9cadc3680b4b1248f5987e54518] sched/headers: Prepare for new header dependencies before moving code to <linux/sched/user.h>
git bisect good 8703e8a465b1e9cadc3680b4b1248f5987e54518
# bad: [8fe3ccaed080a7804bc459c42e0419253973be92] Merge branch 'akpm' (patches from Andrew)
git bisect bad 8fe3ccaed080a7804bc459c42e0419253973be92
# good: [1827adb11ad26b2290dc9fe2aaf54976b2439865] Merge branch 'WIP.sched-core-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect good 1827adb11ad26b2290dc9fe2aaf54976b2439865
# bad: [8346242a7e32c4c93316684ad8f45473932586b9] rmap: fix NULL-pointer dereference on THP munlocking
git bisect bad 8346242a7e32c4c93316684ad8f45473932586b9
# bad: [ce9311cf95ad8baf044a014738d76973d93b739a] mm/vmstats: add thp_split_pud event for clarity
git bisect bad ce9311cf95ad8baf044a014738d76973d93b739a
# good: [590dce2d4934fb909b112cd80c80486362337744] Merge branch 'rebased-statx' of git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs
git bisect good 590dce2d4934fb909b112cd80c80486362337744
# bad: [b4fb8f66f1ae2e167d06c12d018025a8d4d3ba7e] mm, page_alloc: Add missing check for memory holes
git bisect bad b4fb8f66f1ae2e167d06c12d018025a8d4d3ba7e
# first bad commit: [b4fb8f66f1ae2e167d06c12d018025a8d4d3ba7e] mm, page_alloc: Add missing check for memory holes
----------

I haven't completed bisecting between b4fb8f66f1ae2e16 and c470abd4fde40ea6, but
b4fb8f66f1ae2e16 ("mm, page_alloc: Add missing check for memory holes") and
13ad59df67f19788 ("mm, page_alloc: avoid page_to_pfn() when merging buddies")
are talking about memory holes, which matches the situation that I'm trivially
hitting the bug if CONFIG_SPARSEMEM=y .

----------
# bad: [b4fb8f66f1ae2e167d06c12d018025a8d4d3ba7e] mm, page_alloc: Add missing check for memory holes
# good: [590dce2d4934fb909b112cd80c80486362337744] Merge branch 'rebased-statx' of git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs
# good: [1827adb11ad26b2290dc9fe2aaf54976b2439865] Merge branch 'WIP.sched-core-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
# good: [8703e8a465b1e9cadc3680b4b1248f5987e54518] sched/headers: Prepare for new header dependencies before moving code to <linux/sched/user.h>
# good: [1b096e5ae9f7181c770d59c6895f23a76c63adee] z3fold: extend compaction function
# good: [c470abd4fde40ea6a0846a2beab642a578c0b8cd] Linux 4.10
# good: [69973b830859bc6529a7a0468ba0d80ee5117826] Linux 4.9
# good: [c8d2bc9bc39ebea8437fd974fdbc21847bb897a3] Linux 4.8
# good: [523d939ef98fd712632d93a5a2b588e477a7565e] Linux 4.7
# good: [2dcd0af568b0cf583645c8a317dd12e344b1c72a] Linux 4.6
# good: [b562e44f507e863c6792946e4e1b1449fbbac85d] Linux 4.5
# good: [afd2ff9b7e1b367172f18ba7f693dfb62bdcb2dc] Linux 4.4
# good: [6a13feb9c82803e2b815eca72fa7a9f5561d7861] Linux 4.3
# good: [64291f7db5bd8150a74ad2036f1037e6a0428df2] Linux 4.2
# good: [b953c0d234bc72e8489d3bf51a276c5c4ec85345] Linux 4.1
# good: [39a8804455fb23f09157341d3ba7db6d7ae6ee76] Linux 4.0
# bad: [8a9172356f747dc3734cc8043a44bbe158f44749] Merge branch 'timers-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
# bad: [04bb94b13c02e9dbc92d622cddf88937127bd7ed] overlayfs: remove now unnecessary header file include
# bad: [bd0f9b356d00aa241ced36fb075a07041c28d3b8] sched/headers: fix up header file dependency on <linux/sched/signal.h>
# bad: [ec3b93ae0bf4742e9cbb40e1964129926c1464e0] Merge branch 'x86-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
----------

----------
[   30.997908] a.out invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null),  order=0, oom_score_adj=0
[   31.002850] CPU: 0 PID: 274 Comm: a.out Not tainted 4.11.0-rc1-00068-g8a91723 #341
[   31.005963] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   31.010320] Call Trace:
[   31.011391]  dump_stack+0x58/0x73
[   31.012774]  dump_header+0x92/0x202
[   31.014319]  ? ___ratelimit+0x83/0xf0
[   31.015854]  oom_kill_process+0x1e5/0x3b0
[   31.017682]  ? has_capability_noaudit+0x1f/0x30
[   31.019629]  ? oom_badness+0xcf/0x130
[   31.021182]  ? oom_evaluate_task+0x14/0xe0
[   31.022909]  out_of_memory+0xe1/0x280
[   31.024460]  __alloc_pages_nodemask+0x70d/0x9d0
[   31.026347]  ? vma_gap_callbacks_rotate+0x14/0x20
[   31.028292]  handle_mm_fault+0x599/0xd90
[   31.029926]  __do_page_fault+0x197/0x450
[   31.031480]  ? __do_page_fault+0x450/0x450
[   31.032999]  do_page_fault+0x1a/0x20
[   31.034639]  common_exception+0x6c/0x72
[   31.036266] EIP: 0x804858f
[   31.037430] EFLAGS: 00010202 CPU: 0
[   31.038921] EAX: 007bc000 EBX: 376aa008 ECX: 37e66008 EDX: 00000000
[   31.041530] ESI: 7ff00000 EDI: 00000000 EBP: bfcc7368 ESP: bfcc7330
[   31.044118]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   31.046387] Mem-Info:
[   31.047394] active_anon:656090 inactive_anon:0 isolated_anon:0
[   31.047394]  active_file:0 inactive_file:0 isolated_file:3
[   31.047394]  unevictable:0 dirty:0 writeback:0 unstable:0
[   31.047394]  slab_reclaimable:173 slab_unreclaimable:20805
[   31.047394]  mapped:4 shmem:0 pagetables:38151 bounce:0
[   31.047394]  free:31109 free_pcp:171 free_cma:0
[   31.060114] Node 0 active_anon:2624360kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):12kB mapped:16kB dirty:0kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB pages_scanned:151 all_unreclaimable? yes
[   31.071561] DMA free:12720kB min:788kB low:984kB high:1180kB active_anon:3196kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15916kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   31.080790] BUG: unable to handle kernel paging request at bc25106a
[   31.080799] IP: page_remove_rmap+0x17/0x260
[   31.080800] *pde = 00000000 
[   31.080801] 
[   31.080803] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[   31.080804] Modules linked in:
[   31.080807] CPU: 1 PID: 61 Comm: kswapd0 Not tainted 4.11.0-rc1-00068-g8a91723 #341
[   31.080808] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   31.080809] task: f517e300 task.stack: f5346000
[   31.080812] EIP: page_remove_rmap+0x17/0x260
[   31.080812] EFLAGS: 00010286 CPU: 1
[   31.080814] EAX: bc251066 EBX: f3f2dbf0 ECX: 01de4080 EDX: 00000000
[   31.080815] ESI: f3f2dbf0 EDI: f5970080 EBP: f5347c24 ESP: f5347c18
[   31.080816]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   31.080817] CR0: 80050033 CR2: bc25106a CR3: 0170f000 CR4: 000406d0
[   31.080897] Call Trace:
[   31.080902]  try_to_unmap_one+0x210/0x4b0
[   31.080905]  rmap_walk_file+0xf0/0x200
[   31.080907]  rmap_walk+0x32/0x60
[   31.080909]  try_to_unmap+0x95/0x120
[   31.080910]  ? page_remove_rmap+0x260/0x260
[   31.080912]  ? page_not_mapped+0x10/0x10
[   31.080914]  ? page_get_anon_vma+0x90/0x90
[   31.080916]  shrink_page_list+0x387/0xbf0
[   31.080919]  shrink_inactive_list+0x173/0x370
[   31.080921]  shrink_node_memcg+0x572/0x7d0
[   31.080924]  ? __list_lru_count_one.isra.7+0x14/0x40
[   31.080927]  ? tick_program_event+0x3b/0x70
[   31.080929]  shrink_node+0xb3/0x2c0
[   31.080931]  kswapd+0x27f/0x5a0
[   31.080935]  kthread+0xd1/0x100
[   31.080936]  ? mem_cgroup_shrink_node+0xa0/0xa0
[   31.080938]  ? kthread_park+0x70/0x70
[   31.080942]  ret_from_fork+0x21/0x2c
[   31.080943] Code: 83 e8 01 90 e9 7a ff ff ff 83 e8 01 e9 60 ff ff ff 8d 76 00 55 89 e5 56 53 89 c3 83 ec 04 8b 40 14 a8 01 0f 85 00 02 00 00 89 d8 <f6> 40 04 01 74 6b 84 d2 0f 85 3b 01 00 00 f0 83 43 0c ff 78 0c
[   31.080981] EIP: page_remove_rmap+0x17/0x260 SS:ESP: 0068:f5347c18
[   31.080981] CR2: 00000000bc25106a
[   31.080983] ---[ end trace 53061eeda268128d ]---
[   31.159021] lowmem_reserve[]: 0 827 3011 3011
[   31.160883] Normal free:111096kB min:42088kB low:52608kB high:63128kB active_anon:385820kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:892920kB managed:847288kB mlocked:0kB slab_reclaimable:692kB slab_unreclaimable:83220kB kernel_stack:74800kB pagetables:152604kB bounce:0kB free_pcp:680kB local_pcp:120kB free_cma:0kB
[   31.173443] lowmem_reserve[]: 0 0 17471 17471
[   31.175185] HighMem free:620kB min:512kB low:28284kB high:56056kB active_anon:2233384kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:2236360kB managed:2236360kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   31.186860] lowmem_reserve[]: 0 0 0 0
[   31.188445] DMA: 2*4kB (UM) 1*8kB (U) 0*16kB 1*32kB (U) 2*64kB (U) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 1*2048kB (U) 2*4096kB (M) = 12720kB
[   31.194038] Normal: 41*4kB (UME) 114*8kB (UME) 58*16kB (UE) 23*32kB (UME) 22*64kB (UME) 11*128kB (UME) 6*256kB (UM) 2*512kB (UE) 1*1024kB (U) 1*2048kB (E) 24*4096kB (M) = 109492kB
[   31.200324] HighMem: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[   31.204414] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=4096kB
[   31.207586] 3 total pagecache pages
[   31.209085] 0 pages in swap cache
[   31.210527] Swap cache stats: add 0, delete 0, find 0/0
[   31.212706] Free swap  = 0kB
[   31.213952] Total swap = 0kB
[   31.215203] 786318 pages RAM
[   31.216439] 559090 pages HighMem/MovableOnly
[   31.218281] 11427 pages reserved
[   31.219486] 0 pages cma reserved
[   31.220862] Out of memory: Kill process 129 (a.out) score 5 or sacrifice child
[   31.223843] Killed process 180 (a.out) total-vm:2108kB, anon-rss:56kB, file-rss:0kB, shmem-rss:0kB
[   31.231024] oom_reaper: reaped process 180 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
----------

Thus, I call for an attention by speculative execution. ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
