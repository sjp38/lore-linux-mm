Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id EA0626B02F4
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 10:18:28 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id o201so14160475wmg.3
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 07:18:28 -0700 (PDT)
Received: from mx1.molgen.mpg.de (mx3.molgen.mpg.de. [141.14.17.11])
        by mx.google.com with ESMTPS id i11si7861009edj.33.2017.08.14.07.18.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 07:18:27 -0700 (PDT)
Subject: Re: `page allocation failure: order:0` with ixgbe under high load
References: <0ef258fb-57ad-277c-fa34-31f1c41f80e0@molgen.mpg.de>
 <CAM_iQpVA1gSaLZct_wAwZLxUbQoH2Nby5NRSc=PDi2LPQFtxUA@mail.gmail.com>
From: Paul Menzel <pmenzel@molgen.mpg.de>
Message-ID: <b2fbc169-f02e-92a7-d341-5d40868fe4bd@molgen.mpg.de>
Date: Mon, 14 Aug 2017 16:18:26 +0200
MIME-Version: 1.0
In-Reply-To: <CAM_iQpVA1gSaLZct_wAwZLxUbQoH2Nby5NRSc=PDi2LPQFtxUA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, it+linux-mm@molgen.mpg.de

Dear Cong,


Thank you for the response.


On 08/11/17 19:51, Cong Wang wrote:

> On Fri, Aug 11, 2017 at 8:36 AM, Paul Menzel <pmenzel@molgen.mpg.de> wrote:

>> Stress-testing a Dell PowerEdge T630 (12x E5-2603 v4 @ 1.70GHz, 96.3 GB RAM)
>> with Linux 4.9.41 by writing 40 100 GB files in parallel from different
>> systems into an NFS exported directory, after some time Linux writes the
>> messages below.
> 
> We saw similar OOM for atomic allocations in RX.
>
>>> $ dmesg -T
>>> [a?|]
>>>
>>> [Fri Aug 11 16:51:47 2017] swapper/0: page allocation failure: order:0,
>>> mode:0x2080020(GFP_ATOMIC)
>>> [Fri Aug 11 16:51:47 2017] CPU: 0 PID: 0 Comm: swapper/0 Not tainted
>>> 4.9.41.mx64.169 #1
>>> [Fri Aug 11 16:51:47 2017] Hardware name: Dell Inc. PowerEdge T630/0NT78X,
>>> BIOS 2.4.2 01/09/2017
>>> [Fri Aug 11 16:51:47 2017]  ffff880c4fc03bd0 ffffffff813e31a6
>>> ffffffff81f341e8 0000000000000000
>>> [Fri Aug 11 16:51:47 2017]  ffff880c4fc03c50 ffffffff8113fedc
>>> 0208002000000011 ffffffff81f341e8
>>> [Fri Aug 11 16:51:47 2017]  ffff880c4fc03bf8 ffff880c00000010
>>> ffff880c4fc03c60 ffff880c4fc03c10
>>> [Fri Aug 11 16:51:47 2017] Call Trace:
>>> [Fri Aug 11 16:51:47 2017]  <IRQ>
>>> [Fri Aug 11 16:51:47 2017]  [<ffffffff813e31a6>] dump_stack+0x4d/0x67
>>> [Fri Aug 11 16:51:47 2017]  [<ffffffff8113fedc>] warn_alloc+0x11c/0x140
>>> [Fri Aug 11 16:51:47 2017]  [<ffffffff811403db>]
>>> __alloc_pages_nodemask+0x45b/0xe70
>>> [Fri Aug 11 16:51:47 2017]  [<ffffffff81140f6b>]
>>> __alloc_page_frag+0x17b/0x1a0
>>> [Fri Aug 11 16:51:47 2017]  [<ffffffff819dbebc>]
>>> __napi_alloc_skb+0xac/0xf0
>>> [Fri Aug 11 16:51:47 2017]  [<ffffffffa01f7263>]
>>> ixgbe_clean_rx_irq+0xf3/0x950 [ixgbe]
>>> [Fri Aug 11 16:51:47 2017]  [<ffffffff819d4df8>] ?
>>> skb_release_data+0xa8/0xd0
>>> [Fri Aug 11 16:51:47 2017]  [<ffffffffa01f886f>] ixgbe_poll+0x4df/0x7a0
>>> [ixgbe]
>>> [Fri Aug 11 16:51:47 2017]  [<ffffffff819ebfe9>] net_rx_action+0x1f9/0x340
>>> [Fri Aug 11 16:51:47 2017]  [<ffffffff81a9d2e8>] __do_softirq+0x88/0x29b
>>> [Fri Aug 11 16:51:47 2017]  [<ffffffff81064236>] irq_exit+0x76/0x80
>>> [Fri Aug 11 16:51:47 2017]  [<ffffffff81a9d093>] do_IRQ+0x63/0xf0
>>> [Fri Aug 11 16:51:47 2017]  [<ffffffff81a9b57f>]
>>> common_interrupt+0x7f/0x7f
>>> [Fri Aug 11 16:51:47 2017]  <EOI>
>>> [Fri Aug 11 16:51:47 2017]  [<ffffffff81a9a41d>] ? mwait_idle+0x6d/0x170
>>> [Fri Aug 11 16:51:47 2017]  [<ffffffff810283ef>] arch_cpu_idle+0xf/0x20
>>> [Fri Aug 11 16:51:47 2017]  [<ffffffff81a9a713>]
>>> default_idle_call+0x23/0x30
>>> [Fri Aug 11 16:51:47 2017]  [<ffffffff8109e435>]
>>> cpu_startup_entry+0x175/0x1e0
>>> [Fri Aug 11 16:51:47 2017]  [<ffffffff81a94fa7>] rest_init+0x77/0x80
>>> [Fri Aug 11 16:51:47 2017]  [<ffffffff8235fec3>] start_kernel+0x3b3/0x3c0
>>> [Fri Aug 11 16:51:47 2017]  [<ffffffff8235f28f>]
>>> x86_64_start_reservations+0x2a/0x2c
>>> [Fri Aug 11 16:51:47 2017]  [<ffffffff8235f3f9>]
>>> x86_64_start_kernel+0x168/0x176
>>> [Fri Aug 11 16:51:47 2017] Mem-Info:
>>> [Fri Aug 11 16:51:47 2017] active_anon:29369 inactive_anon:351
>>> isolated_anon:0
>>> [Fri Aug 11 16:51:47 2017]  active_file:22668707 inactive_file:1211442
>>> isolated_file:64
>>> [Fri Aug 11 16:51:47 2017]  unevictable:0 dirty:871455 writeback:10178
>>> unstable:0
>>> [Fri Aug 11 16:51:47 2017]  slab_reclaimable:527010
>>> slab_unreclaimable:35231
>>> [Fri Aug 11 16:51:47 2017]  mapped:3998 shmem:360 pagetables:1931 bounce:0
>>> [Fri Aug 11 16:51:47 2017]  free:53778 free_pcp:4689 free_cma:0
>>> [Fri Aug 11 16:51:47 2017] Node 0 active_anon:68492kB inactive_anon:1296kB
>>> active_file:44916512kB inactive_file:2415652kB unevictable:0kB
>>> isolated(anon):0kB isolated(file):128kB mapped:5448kB dirty:1750600kB
>>> writeback:24708kB shmem:1304kB writeback_tmp:0kB unstable:0kB
>>> pages_scanned:0 all_unreclaimable? no
>>> [Fri Aug 11 16:51:47 2017] Node 1 active_anon:48984kB inactive_anon:108kB
>>> active_file:45758316kB inactive_file:2430116kB unevictable:0kB
>>> isolated(anon):0kB isolated(file):128kB mapped:10544kB dirty:1735220kB
>>> writeback:16004kB shmem:136kB writeback_tmp:0kB unstable:0kB pages_scanned:0
>>> all_unreclaimable? no
>>> [Fri Aug 11 16:51:47 2017] Node 0 DMA free:15896kB min:4kB low:16kB
>>> high:28kB active_anon:0kB inactive_anon:0kB active_file:0kB
>>> inactive_file:0kB unevictable:0kB writepending:0kB present:15980kB
>>> managed:15896kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB
>>> kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB
>>> free_cma:0kB
>>> [Fri Aug 11 16:51:47 2017] lowmem_reserve[]: 0 1592 47927 47927
>>> [Fri Aug 11 16:51:47 2017] Node 0 DMA32 free:185436kB min:656kB low:2284kB
>>> high:3912kB active_anon:656kB inactive_anon:0kB active_file:1306260kB
>>> inactive_file:85160kB unevictable:0kB writepending:63324kB present:1985356kB
>>> managed:1640236kB mlocked:0kB slab_reclaimable:35744kB
>>> slab_unreclaimable:1268kB kernel_stack:252kB pagetables:28kB bounce:0kB
>>> free_pcp:6060kB local_pcp:544kB free_cma:0kB
>>> [Fri Aug 11 16:51:47 2017] lowmem_reserve[]: 0 0 46335 46335
>>> [Fri Aug 11 16:51:47 2017] Node 0 Normal free:6672kB min:19108kB
>>> low:66552kB high:113996kB active_anon:67836kB inactive_anon:1296kB
>>> active_file:43610252kB inactive_file:2330492kB unevictable:0kB
>>> writepending:1712224kB present:48234496kB managed:47447216kB mlocked:0kB
>>> slab_reclaimable:1085248kB slab_unreclaimable:75896kB kernel_stack:26424kB
>>> pagetables:2636kB bounce:0kB free_pcp:6652kB local_pcp:728kB free_cma:0kB
>>> [Fri Aug 11 16:51:47 2017] lowmem_reserve[]: 0 0 0 0
>>> [Fri Aug 11 16:51:47 2017] Node 1 Normal free:7108kB min:19952kB
>>> low:69492kB high:119032kB active_anon:48984kB inactive_anon:108kB
>>> active_file:45758316kB inactive_file:2430116kB unevictable:0kB
>>> writepending:1751708kB present:50331648kB managed:49543960kB mlocked:0kB
>>> slab_reclaimable:987048kB slab_unreclaimable:63760kB kernel_stack:28988kB
>>> pagetables:5060kB bounce:0kB free_pcp:6044kB local_pcp:560kB free_cma:0kB
>>> [Fri Aug 11 16:51:47 2017] lowmem_reserve[]: 0 0 0 0
>>> [Fri Aug 11 16:51:47 2017] Node 0 DMA: 0*4kB 1*8kB (U) 1*16kB (U) 0*32kB
>>> 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M)
>>> 3*4096kB (M) = 15896kB
>>> [Fri Aug 11 16:51:47 2017] Node 0 DMA32: 831*4kB (UME) 895*8kB (UME)
>>> 275*16kB (UME) 33*32kB (UME) 70*64kB (UME) 216*128kB (UME) 29*256kB (UM)
>>> 19*512kB (UM) 3*1024kB (UM) 5*2048kB (UE) 26*4096kB (UM) = 185028kB
>>> [Fri Aug 11 16:51:47 2017] Node 0 Normal: 1558*4kB (UM) 0*8kB 0*16kB
>>> 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 6232kB
>>> [Fri Aug 11 16:51:47 2017] Node 1 Normal: 121*4kB (ME) 768*8kB (M) 0*16kB
>>> 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 6628kB
>>> [Fri Aug 11 16:51:47 2017] Node 0 hugepages_total=0 hugepages_free=0
>>> hugepages_surp=0 hugepages_size=2048kB
>>> [Fri Aug 11 16:51:47 2017] Node 1 hugepages_total=0 hugepages_free=0
>>> hugepages_surp=0 hugepages_size=2048kB
>>> [Fri Aug 11 16:51:47 2017] 23880608 total pagecache pages
>>> [Fri Aug 11 16:51:47 2017] 23880608 total pagecache pages
>>> [Fri Aug 11 16:51:47 2017] 0 pages in swap cache
>>> [Fri Aug 11 16:51:47 2017] Swap cache stats: add 0, delete 0, find 0/0
>>> [Fri Aug 11 16:51:47 2017] Free swap  = 0kB
>>> [Fri Aug 11 16:51:47 2017] Total swap = 0kB
>>> [Fri Aug 11 16:51:47 2017] 25141870 pages RAM
>>> [Fri Aug 11 16:51:47 2017] 0 pages HighMem/MovableOnly
>>> [Fri Aug 11 16:51:47 2017] 480043 pages reserved
>>
>>> [a?|]
>>
>> Is that a problem with the network device module ixgbe?
>>
>> ```
>> 04:00.0 Ethernet controller: Intel Corporation Ethernet 10G 2P X520 Adapter
>> (rev 01)
>> 04:00.1 Ethernet controller: Intel Corporation Ethernet 10G 2P X520 Adapter
>> (rev 01)
>> ```
>>
>> Or should some parameters be tuned?
>>
>> ```
>> $ more /proc/sys/vm/min*
>> ::::::::::::::
>> /proc/sys/vm/min_free_kbytes
>> ::::::::::::::
>> 39726
> 
> 
> Can you try to increase this? Although it depends on your workload,
> 38M seems too small for a host with 96+G memory.

Increasing the value to 128 MB did not get rid of the warning. With 256 
MB we were unable to reproduce the warning.

>> ::::::::::::::
>> /proc/sys/vm/min_slab_ratio
>> ::::::::::::::
>> 5
>> ::::::::::::::
>> /proc/sys/vm/min_unmapped_ratio
>> ::::::::::::::
>> 1
>> ```
>>
>> There is quite some information about this on the WWW [1], but some suggest
>> that with recent Linux kernels, this shouldna??t happen, as memory get
>> defragmented.
> 
> 
> On the other hand, the allocation order is 0 anyway. ;)

Right. Coherent(?) memory is not needed for an order of 0.

In our case the memory is mainly occupied by the disk(?) buffer/cache, 
and not the real program. So there is plenty available. Shouldna??t the 
Linux kernel be able to deal with such situations, or is this exactly 
the use case, which the parameter `min_free_kbytes` is for?


Kind regards,

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
