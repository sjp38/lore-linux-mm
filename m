Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4DD9D6B0033
	for <linux-mm@kvack.org>; Sat, 25 Nov 2017 23:32:55 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id q101so31776524ioi.12
        for <linux-mm@kvack.org>; Sat, 25 Nov 2017 20:32:55 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f80sor5398764ita.80.2017.11.25.20.32.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 25 Nov 2017 20:32:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201711261142.EIE82842.LFOtSHOFVOFJQM@I-love.SAKURA.ne.jp>
References: <1506592464-30962-1-git-send-email-laoar.shao@gmail.com>
 <cdfce9d0-9542-3fd1-098c-492d8d9efc11@I-love.SAKURA.ne.jp>
 <CALOAHbB05YJvVPRE0VsEDj+U7Wqv64XoGOQtpDP1a50mbpYXGg@mail.gmail.com> <201711261142.EIE82842.LFOtSHOFVOFJQM@I-love.SAKURA.ne.jp>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Sun, 26 Nov 2017 12:32:53 +0800
Message-ID: <CALOAHbCov=Dd7bYjL6+abiVu_WgT1ZmFN_TfLTs8A1jfw8=bOQ@mail.gmail.com>
Subject: Re: [PATCH] mm: print a warning once the vm dirtiness settings is illogical
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>, Linux MM <linux-mm@kvack.org>

2017-11-26 10:42 GMT+08:00 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp=
>:
> Yafang Shao wrote:
>> 2017-11-26 0:05 GMT+08:00 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.=
jp>:
>> > On 2017/09/28 18:54, Yafang Shao wrote:
>> >> The vm direct limit setting must be set greater than vm background
>> >> limit setting.
>> >> Otherwise we will print a warning to help the operator to figure
>> >> out that the vm dirtiness settings is in illogical state.
>> >>
>> >> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
>> >
>> > I got this warning by simple OOM killer flooding. Is this what you mea=
nt?
>> >
>>
>> This message is only printed when the vm dirtiness settings are illogic.
>> Pls. get the bellow four knobs and check whether they are set proper or =
not.
>>
>> vm.dirty_ratio
>> vm.dirty_bytes
>> vm.dirty_background_ratio
>> vm.dirty_background_bytes
>>
>> If these four valuses are set properly, this message should not be
>> printed when OOM happens.
>
> I didn't tune vm related values.
>
> ----------
> vm.admin_reserve_kbytes =3D 8192
> vm.block_dump =3D 0
> vm.compact_unevictable_allowed =3D 1
> vm.dirty_background_bytes =3D 0
> vm.dirty_background_ratio =3D 10
> vm.dirty_bytes =3D 0
> vm.dirty_expire_centisecs =3D 3000
> vm.dirty_ratio =3D 30
> vm.dirty_writeback_centisecs =3D 500
> vm.dirtytime_expire_seconds =3D 43200
> vm.drop_caches =3D 0
> vm.extfrag_threshold =3D 500
> vm.hugetlb_shm_group =3D 0
> vm.laptop_mode =3D 0
> vm.legacy_va_layout =3D 0
> vm.lowmem_reserve_ratio =3D 256   256     32
> vm.max_map_count =3D 65530
> vm.memory_failure_early_kill =3D 0
> vm.memory_failure_recovery =3D 1
> vm.min_free_kbytes =3D 67584
> vm.min_slab_ratio =3D 5
> vm.min_unmapped_ratio =3D 1
> vm.mmap_min_addr =3D 4096
> vm.mmap_rnd_bits =3D 28
> vm.mmap_rnd_compat_bits =3D 8
> vm.nr_hugepages =3D 0
> vm.nr_hugepages_mempolicy =3D 0
> vm.nr_overcommit_hugepages =3D 0
> vm.numa_stat =3D 1
> vm.numa_zonelist_order =3D Node
> vm.oom_dump_tasks =3D 0
> vm.oom_kill_allocating_task =3D 0
> vm.overcommit_kbytes =3D 0
> vm.overcommit_memory =3D 0
> vm.overcommit_ratio =3D 50
> vm.page-cluster =3D 3
> vm.panic_on_oom =3D 0
> vm.percpu_pagelist_fraction =3D 0
> vm.stat_interval =3D 1
> vm.swappiness =3D 30
> vm.user_reserve_kbytes =3D 116665
> vm.vfs_cache_pressure =3D 100
> vm.watermark_scale_factor =3D 10
> vm.zone_reclaim_mode =3D 0
> ----------
>

Then under these settings the message should not been printed.

>>
>> I have also verified your test code on my machine, but can not find
>> this message.
>>
>
> Not always printed. It is timing dependent.
>

I will try and analysis why this happen.

> ----------
> [  343.783160] a.out invoked oom-killer: gfp_mask=3D0x14200ca(GFP_HIGHUSE=
R_MOVABLE), nodemask=3D(null), order=3D0, oom_score_adj=3D1000
> [  343.793554] a.out cpuset=3D/ mems_allowed=3D0
> [  343.795437] CPU: 2 PID: 2930 Comm: a.out Not tainted 4.14.0-next-20171=
124+ #681
> [  343.798112] Hardware name: VMware, Inc. VMware Virtual Platform/440BX =
Desktop Reference Platform, BIOS 6.00 07/02/2015
> [  343.801348] Call Trace:
> [  343.802844]  dump_stack+0x5f/0x86
> [  343.804545]  dump_header+0x69/0x431
> [  343.806268]  oom_kill_process+0x294/0x670
> [  343.808042]  out_of_memory+0x423/0x5c0
> [  343.809701]  __alloc_pages_nodemask+0x11e2/0x1450
> [  343.811553]  filemap_fault+0x4b7/0x710
> [  343.813184]  __xfs_filemap_fault.constprop.0+0x68/0x210
> [  343.815129]  __do_fault+0x15/0xc0
> [  343.816625]  __handle_mm_fault+0xd7c/0x1390
> [  343.818315]  handle_mm_fault+0x173/0x330
> [  343.820051]  __do_page_fault+0x2a7/0x510
> [  343.821842]  do_page_fault+0x2c/0x2f0
> [  343.823376]  page_fault+0x22/0x30
> [  343.824834] RIP: 0033:0x7f12886f9840
> [  343.826302] RSP: 002b:00007ffdfa961828 EFLAGS: 00010246
> [  343.828075] RAX: 0000000000001000 RBX: 0000000000000003 RCX: 00007f128=
86f9840
> [  343.830324] RDX: 0000000000001000 RSI: 00000000006010a0 RDI: 000000000=
0000003
> [  343.832526] RBP: 0000000000000000 R08: 00007ffdfa961760 R09: 00007ffdf=
a9615a0
> [  343.834693] R10: 0000000000000008 R11: 0000000000000246 R12: 000000000=
040079d
> [  343.836825] R13: 00007ffdfa961930 R14: 0000000000000000 R15: 000000000=
0000000
> [  343.839058] Mem-Info:
> [  343.840557] active_anon:882238 inactive_anon:2091 isolated_anon:0
> [  343.840557]  active_file:27 inactive_file:0 isolated_file:0
> [  343.840557]  unevictable:0 dirty:2 writeback:0 unstable:0
> [  343.840557]  slab_reclaimable:6412 slab_unreclaimable:15971
> [  343.840557]  mapped:695 shmem:2162 pagetables:3290 bounce:0
> [  343.840557]  free:21394 free_pcp:1 free_cma:0
> [  343.851466] Node 0 active_anon:3528952kB inactive_anon:8364kB active_f=
ile:108kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(fil=
e):0kB mapped:2780kB dirty:8kB writeback:0kB shmem:8648kB shmem_thp: 0kB sh=
mem_pmdmapped: 0kB anon_thp: 2797568kB writeback_tmp:0kB unstable:0kB all_u=
nreclaimable? yes
> [  343.859073] Node 0 DMA free:14944kB min:284kB low:352kB high:420kB act=
ive_anon:928kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevicta=
ble:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel=
_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0k=
B
> [  343.866543] lowmem_reserve[]: 0 2708 3666 3666
> [  343.868345] Node 0 DMA32 free:53196kB min:49608kB low:62008kB high:744=
08kB active_anon:2713592kB inactive_anon:0kB active_file:100kB inactive_fil=
e:0kB unevictable:0kB writepending:0kB present:3129216kB managed:2773132kB =
mlocked:0kB kernel_stack:16kB pagetables:3372kB bounce:0kB free_pcp:0kB loc=
al_pcp:0kB free_cma:0kB
> [  343.877512] lowmem_reserve[]: 0 0 958 958
> [  343.878700] vm direct limit must be set greater than background limit.
> [  343.878706] vm direct limit must be set greater than background limit.
> [  343.878712] vm direct limit must be set greater than background limit.
> [  343.878718] vm direct limit must be set greater than background limit.
> [  343.878723] vm direct limit must be set greater than background limit.
> [  343.878728] vm direct limit must be set greater than background limit.
> [  343.878734] vm direct limit must be set greater than background limit.
> [  343.878739] vm direct limit must be set greater than background limit.
> [  343.878744] vm direct limit must be set greater than background limit.
> [  343.878749] vm direct limit must be set greater than background limit.
> [  343.878755] vm direct limit must be set greater than background limit.
> [  343.878760] vm direct limit must be set greater than background limit.
> [  343.878767] vm direct limit must be set greater than background limit.
> [  343.878772] vm direct limit must be set greater than background limit.
> [  343.878777] vm direct limit must be set greater than background limit.
> [  343.878782] vm direct limit must be set greater than background limit.
> [  343.878786] vm direct limit must be set greater than background limit.
> [  343.878791] vm direct limit must be set greater than background limit.
> [  343.878796] vm direct limit must be set greater than background limit.
> [  343.878800] vm direct limit must be set greater than background limit.
> [  343.878805] vm direct limit must be set greater than background limit.
> [  343.878809] vm direct limit must be set greater than background limit.
> [  343.878814] vm direct limit must be set greater than background limit.
> [  343.878818] vm direct limit must be set greater than background limit.
> [  343.878826] vm direct limit must be set greater than background limit.
> [  343.878831] vm direct limit must be set greater than background limit.
> [  343.878835] vm direct limit must be set greater than background limit.
> [  343.878840] vm direct limit must be set greater than background limit.
> [  343.878844] vm direct limit must be set greater than background limit.
> [  343.878848] vm direct limit must be set greater than background limit.
> [  343.878852] vm direct limit must be set greater than background limit.
> [  343.878856] vm direct limit must be set greater than background limit.
> [  343.878861] vm direct limit must be set greater than background limit.
> [  343.878865] vm direct limit must be set greater than background limit.
> [  343.878891] vm direct limit must be set greater than background limit.
> [  343.878897] vm direct limit must be set greater than background limit.
> [  343.878898] vm direct limit must be set greater than background limit.
> [  343.878915] vm direct limit must be set greater than background limit.
> [  343.956240] Node 0 Normal free:17796kB min:17684kB low:22104kB high:26=
524kB active_anon:815300kB inactive_anon:8364kB active_file:0kB inactive_fi=
le:4kB unevictable:0kB writepending:0kB present:1048576kB managed:981224kB =
mlocked:0kB kernel_stack:3632kB pagetables:9792kB bounce:0kB free_pcp:0kB l=
ocal_pcp:0kB free_cma:0kB
> [  343.963339] lowmem_reserve[]: 0 0 0 0
> [  343.964644] Node 0 DMA: 0*4kB 0*8kB 0*16kB 1*32kB (M) 3*64kB (UM) 1*12=
8kB (U) 1*256kB (U) 0*512kB 2*1024kB (UM) 0*2048kB 3*4096kB (ME) =3D 14944k=
B
> [  343.968026] Node 0 DMA32: 12*4kB (UM) 15*8kB (UM) 28*16kB (UM) 28*32kB=
 (UM) 12*64kB (UM) 21*128kB (UM) 14*256kB (UM) 12*512kB (UM) 24*1024kB (UM)=
 5*2048kB (E) 1*4096kB (E) =3D 53608kB
> [  343.972148] Node 0 Normal: 513*4kB (UME) 282*8kB (UME) 215*16kB (UME) =
128*32kB (UME) 41*64kB (UME) 12*128kB (UME) 3*256kB (M) 2*512kB (M) 0*1024k=
B 0*2048kB 0*4096kB =3D 17796kB
> [  343.976695] Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_su=
rp=3D0 hugepages_size=3D1048576kB
> [  343.979084] Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_su=
rp=3D0 hugepages_size=3D2048kB
> [  343.981469] 2290 total pagecache pages
> [  343.982709] 0 pages in swap cache
> [  343.983989] Swap cache stats: add 0, delete 0, find 0/0
> [  343.987118] Free swap  =3D 0kB
> [  343.988182] Total swap =3D 0kB
> [  343.990799] 1048445 pages RAM
> [  343.991844] 0 pages HighMem/MovableOnly
> [  343.994723] 105880 pages reserved
> [  343.995878] 0 pages hwpoisoned
> [  343.998745] Out of memory: Kill process 2929 (a.out) score 999 or sacr=
ifice child
> [  344.002681] Killed process 2929 (a.out) total-vm:4180kB, anon-rss:88kB=
, file-rss:0kB, shmem-rss:0kB
> ----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
