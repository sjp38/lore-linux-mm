Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4D2F66B0038
	for <linux-mm@kvack.org>; Sun, 26 Mar 2017 04:37:19 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p81so15240228lfp.9
        for <linux-mm@kvack.org>; Sun, 26 Mar 2017 01:37:19 -0700 (PDT)
Received: from vps01.wiesinger.com ([2a02:25b0:aaaa:57a::affe:bade])
        by mx.google.com with ESMTPS id i15si4349626ljd.14.2017.03.26.01.37.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Mar 2017 01:37:17 -0700 (PDT)
Subject: Re: Still OOM problems with 4.9er/4.10er kernels
References: <20170302071721.GA32632@bbox>
 <feebcc24-2863-1bdf-e586-1ac9648b35ba@wiesinger.com>
 <20170316082714.GC30501@dhcp22.suse.cz>
 <20170316084733.GP802@shells.gnugeneration.com>
 <20170316090844.GG30501@dhcp22.suse.cz>
 <20170316092318.GQ802@shells.gnugeneration.com>
 <20170316093931.GH30501@dhcp22.suse.cz>
 <a65e4b73-5c97-d915-c79e-7df0771db823@wiesinger.com>
 <20170317171339.GA23957@dhcp22.suse.cz>
 <8cb1d796-aff3-0063-3ef8-880e76d437c0@wiesinger.com>
 <20170319151837.GD12414@dhcp22.suse.cz>
 <555d1f95-7c9e-2691-b14f-0260f90d23a9@wiesinger.com>
 <1489979147.4273.22.camel@gmx.de>
 <798104b6-091d-5415-2c51-8992b6b231e5@wiesinger.com>
 <1490080422.14658.39.camel@gmx.de>
 <1ce2621b-0573-0cc7-a1df-49d6c68df792@wiesinger.com>
 <1490258325.27756.42.camel@gmx.de>
From: Gerhard Wiesinger <lists@wiesinger.com>
Message-ID: <da13c3c7-b514-67b0-2eb9-6d6af277901b@wiesinger.com>
Date: Sun, 26 Mar 2017 10:36:53 +0200
MIME-Version: 1.0
In-Reply-To: <1490258325.27756.42.camel@gmx.de>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Galbraith <efault@gmx.de>, Michal Hocko <mhocko@kernel.org>
Cc: lkml@pengaru.com, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On 23.03.2017 09:38, Mike Galbraith wrote:
> On Thu, 2017-03-23 at 08:16 +0100, Gerhard Wiesinger wrote:
>> On 21.03.2017 08:13, Mike Galbraith wrote:
>>> On Tue, 2017-03-21 at 06:59 +0100, Gerhard Wiesinger wrote:
>>>
>>>> Is this the correct information?
>>> Incomplete, but enough to reiterate cgroup_disable=memory
>>> suggestion.
>>>
>> How to collect complete information?
> If Michal wants specifics, I suspect he'll ask.  I posted only to pass
> along a speck of information, and offer a test suggestion.. twice.

Still OOM with cgroup_disable=memory, kernel 
4.11.0-0.rc3.git0.2.fc26.x86_64,I set vm.min_free_kbytes = 10240 in 
these tests.
# Full config
grep "vm\." /etc/sysctl.d/*
/etc/sysctl.d/00-dirty_background_ratio.conf:vm.dirty_background_ratio = 3
/etc/sysctl.d/00-dirty_ratio.conf:vm.dirty_ratio = 15
/etc/sysctl.d/00-kernel-vm-min-free-kbyzes.conf:vm.min_free_kbytes = 10240
/etc/sysctl.d/00-overcommit_memory.conf:vm.overcommit_memory = 2
/etc/sysctl.d/00-overcommit_ratio.conf:vm.overcommit_ratio = 80
/etc/sysctl.d/00-swappiness.conf:vm.swappiness=10

[31880.623557] sa1: page allocation stalls for 10942ms, order:0, 
mode:0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null)
[31880.623623] sa1 cpuset=/ mems_allowed=0
[31880.623630] CPU: 1 PID: 17112 Comm: sa1 Not tainted 
4.11.0-0.rc3.git0.2.fc26.x86_64 #1
[31880.623724] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), 
BIOS 1.9.3 04/01/2014
[31880.623819] Call Trace:
[31880.623893]  dump_stack+0x63/0x84
[31880.623971]  warn_alloc+0x10c/0x1b0
[31880.624046]  __alloc_pages_slowpath+0x93d/0xe60
[31880.624142]  ? get_page_from_freelist+0x122/0xbf0
[31880.624225]  ? unmap_region+0xf7/0x130
[31880.624312]  __alloc_pages_nodemask+0x290/0x2b0
[31880.624388]  alloc_pages_vma+0xa0/0x2b0
[31880.624463]  __handle_mm_fault+0x4d0/0x1160
[31880.624550]  handle_mm_fault+0xb3/0x250
[31880.624628]  __do_page_fault+0x23f/0x4c0
[31880.624701]  trace_do_page_fault+0x41/0x120
[31880.624781]  do_async_page_fault+0x51/0xa0
[31880.624866]  async_page_fault+0x28/0x30
[31880.624941] RIP: 0033:0x7f9218d4914f
[31880.625032] RSP: 002b:00007ffe0d1376a8 EFLAGS: 00010206
[31880.625153] RAX: 00007f9218d2a314 RBX: 00007f9218f4e658 RCX: 
00007f9218d2a354
[31880.625235] RDX: 00000000000005ec RSI: 0000000000000000 RDI: 
00007f9218d2a314
[31880.625324] RBP: 00007ffe0d137950 R08: 00007f9218d2a900 R09: 
0000000000027000
[31880.625423] R10: 00007ffe0d1376e0 R11: 00007f9218d2a900 R12: 
0000000000000003
[31880.625505] R13: 00007ffe0d137a38 R14: 000000000000fd01 R15: 
0000000000000002
[31880.625688] Mem-Info:
[31880.625762] active_anon:36671 inactive_anon:36711 isolated_anon:88
                 active_file:1399 inactive_file:1410 isolated_file:0
                 unevictable:0 dirty:5 writeback:15 unstable:0
                 slab_reclaimable:3099 slab_unreclaimable:3558
                 mapped:2037 shmem:3 pagetables:3340 bounce:0
                 free:2972 free_pcp:102 free_cma:0
[31880.627334] Node 0 active_anon:146684kB inactive_anon:146816kB 
active_file:5596kB inactive_file:5572kB unevictable:0kB 
isolated(anon):368kB isolated(file):0kB mapped:8044kB dirty:20kB 
writeback:136kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 
12kB writeback_tmp:0kB unstable:0kB pages_scanned:82 all_unreclaimable? no
[31880.627606] Node 0 DMA free:1816kB min:440kB low:548kB high:656kB 
active_anon:5636kB inactive_anon:6844kB active_file:132kB 
inactive_file:148kB unevictable:0kB writepending:4kB present:15992kB 
managed:15908kB mlocked:0kB slab_reclaimable:284kB 
slab_unreclaimable:532kB kernel_stack:0kB pagetables:188kB bounce:0kB 
free_pcp:0kB local_pcp:0kB free_cma:0kB
[31880.627883] lowmem_reserve[]: 0 327 327 327 327
[31880.627959] Node 0 DMA32 free:10072kB min:9796kB low:12244kB 
high:14692kB active_anon:141048kB inactive_anon:140000kB 
active_file:5432kB inactive_file:5444kB unevictable:0kB 
writepending:152kB present:376688kB managed:353760kB mlocked:0kB 
slab_reclaimable:12112kB slab_unreclaimable:13700kB kernel_stack:2464kB 
pagetables:13172kB bounce:0kB free_pcp:504kB local_pcp:272kB free_cma:0kB
[31880.628334] lowmem_reserve[]: 0 0 0 0 0
[31880.629882] Node 0 DMA: 33*4kB (UME) 24*8kB (UM) 26*16kB (UME) 4*32kB 
(UME) 5*64kB (UME) 1*128kB (E) 2*256kB (M) 0*512kB 0*1024kB 0*2048kB 
0*4096kB = 1828kB
[31880.632255] Node 0 DMA32: 174*4kB (UMEH) 107*8kB (UMEH) 96*16kB 
(UMEH) 59*32kB (UME) 30*64kB (UMEH) 8*128kB (UEH) 8*256kB (UMEH) 1*512kB 
(E) 0*1024kB 0*2048kB 0*4096kB = 10480kB
[31880.634344] Node 0 hugepages_total=0 hugepages_free=0 
hugepages_surp=0 hugepages_size=2048kB
[31880.634346] 7276 total pagecache pages
[31880.635277] 4367 pages in swap cache
[31880.636206] Swap cache stats: add 5639999, delete 5635551, find 
6573228/8496821
[31880.637145] Free swap  = 973736kB
[31880.638038] Total swap = 2064380kB
[31880.638988] 98170 pages RAM
[31880.640309] 0 pages HighMem/MovableOnly
[31880.641791] 5753 pages reserved
[31880.642908] 0 pages cma reserved
[31880.643978] 0 pages hwpoisoned

Will try your suggestions with the custom build kernel.

Ciao,
Gerhard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
