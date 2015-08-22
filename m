Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 910EB6B0038
	for <linux-mm@kvack.org>; Sat, 22 Aug 2015 03:05:29 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so31092874wid.0
        for <linux-mm@kvack.org>; Sat, 22 Aug 2015 00:05:29 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id go10si19926939wjc.165.2015.08.22.00.05.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 22 Aug 2015 00:05:27 -0700 (PDT)
Message-ID: <55D81F34.7020407@suse.cz>
Date: Sat, 22 Aug 2015 09:05:24 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: difficult to pinpoint exhaustion of swap between 4.2.0-rc6 and
 4.2.0-rc7
References: <55D4A462.3070505@internode.on.net> <55D58CEB.9070701@suse.cz> <55D6ECBD.60303@internode.on.net> <55D70D80.5060009@suse.cz> <55D71021.7030803@suse.cz> <55D7FF06.90404@internode.on.net>
In-Reply-To: <55D7FF06.90404@internode.on.net>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arthur Marsh <arthur.marsh@internode.on.net>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, DRI <dri-devel@lists.freedesktop.org>, Dave Airlie <airlied@gmail.com>, Alex Deucher <alexdeucher@gmail.com>

On 22.8.2015 6:48, Arthur Marsh wrote:
> 
> 
> Vlastimil Babka wrote on 21/08/15 21:18:
>> On 08/21/2015 01:37 PM, Vlastimil Babka wrote:
>>>
>>> That, said, looking at the memory values:
>>>
>>> rc6: Free+Buffers+A/I(Anon)+A/I(File)+Slab = 6769MB
>>> rc7: ...                                   = 4714MB
>>>
>>> That's 2GB unaccounted for.
>>
>> So one brute-force way to see who allocated those 2GB is to use the
>> page_owner debug feature. You need to enable CONFIG_PAGE_OWNER and then
>> follow the Usage part of Documentation/vm/page_owner.txt
>> If you can do that, please send the sorted_page_owner.txt for rc7 when
>> it's semi-nearing the exhausted swap. Then you could start doing a
>> comparison run with rc6, but maybe it will be easy to figure from the
>> rc7 log already. Thanks.
>>
> 
> Documentation/vm/page_owner.txt does not mention the need to do:
> 
> mount -t debugfs none /sys/kernel/debug

Ah, right...

> Having done that when about 1.5 GiB swap was in use, the output of 
> sorted_page_owner.txt with the rc7+ kernel starts with:
> 
> 699487 times:
> Page allocated via order 0, mask 0x280da
>   [<ffffffff8116147e>] __alloc_pages_nodemask+0x1de/0xb00
>   [<ffffffff8118d35b>] handle_mm_fault+0x11bb/0x1480
>   [<ffffffff8104c3e8>] __do_page_fault+0x178/0x480
>   [<ffffffff8104c71b>] do_page_fault+0x2b/0x40
>   [<ffffffff815b01a8>] page_fault+0x28/0x30
>   [<ffffffffffffffff>] 0xffffffffffffffff

That's userspace, that's fine.

> 457823 times:
> Page allocated via order 0, mask 0x202d0
>   [<ffffffff8116147e>] __alloc_pages_nodemask+0x1de/0xb00
>   [<ffffffff8100a844>] dma_generic_alloc_coherent+0xa4/0xf0
>   [<ffffffff810481fd>] x86_swiotlb_alloc_coherent+0x2d/0x60
>   [<ffffffff8100a5ae>] dma_alloc_attrs+0x4e/0x90
>   [<ffffffffa0427d72>] ttm_dma_populate+0x502/0x900 [ttm]
>   [<ffffffffa046bf26>] radeon_ttm_tt_populate+0x216/0x2b0 [radeon]
>   [<ffffffffa041dd74>] ttm_tt_bind+0x44/0x80 [ttm]
>   [<ffffffffa0420316>] ttm_bo_handle_move_mem+0x3b6/0x440 [ttm]

There. 1800MB of present RAM was allocated through ttm/radeon in rc7(+). And
apparently that doesn't happen with rc6.
The problem is, there were no commits between rc6 and rc7 in
drivers/gpu/drm/radeon/ or drivers/gpu/drm/ttm/. I'm CC'ing dri and some radeon
devs anyway. Please find the rest of this thread on lkml.

[...]

> 
> Also, once when attempting to do:
> 
> cat /sys/kernel/debug/page_owner > page_owner_full.txt
> 
> I received the following error:
> 
> 
> [18410.829060] cat: page allocation failure: order:5, mode:0x2040d0
> [18410.829068] CPU: 3 PID: 1732 Comm: cat Not tainted 4.2.0-rc7+ #1907
> [18410.829070] Hardware name: System manufacturer System Product 
> Name/M3A78 PRO, BIOS 1701    01/27/2011
> [18410.829073]  0000000000000005 ffff88001f4d7a58 ffffffff815a554d 
> 0000000000000034
> [18410.829078]  00000000002040d0 ffff88001f4d7ae8 ffffffff8115dedc 
> ffff8800360b4540
> [18410.829082]  0000000000000005 ffff8800360b4540 00000000002040d0 
> ffff88001f4d7bc0
> [18410.829085] Call Trace:
> [18410.829091]  [<ffffffff815a554d>] dump_stack+0x4f/0x7b
> [18410.829096]  [<ffffffff8115dedc>] warn_alloc_failed+0xdc/0x130
> [18410.829099]  [<ffffffff81161298>] ? 
> __alloc_pages_direct_compact+0xe8/0xf0
> [18410.829101]  [<ffffffff81161b31>] __alloc_pages_nodemask+0x891/0xb00
> [18410.829104]  [<ffffffff810aa375>] ? __lock_acquire+0xc05/0x1c70
> [18410.829107]  [<ffffffff811ad53b>] cache_alloc_refill+0x33b/0x5b0
> [18410.829110]  [<ffffffff811c1764>] ? print_page_owner+0x54/0x350
> [18410.829112]  [<ffffffff811adc7e>] __kmalloc+0x1be/0x330
> [18410.829114]  [<ffffffff811c1764>] print_page_owner+0x54/0x350
> [18410.829116]  [<ffffffff8115f786>] ? drain_pages_zone+0x76/0xa0
> [18410.829118]  [<ffffffff8115f860>] ? page_alloc_cpu_notify+0x50/0x50
> [18410.829119]  [<ffffffff8115f7cf>] ? drain_pages+0x1f/0x60
> [18410.829122]  [<ffffffff810a93c6>] ? trace_hardirqs_on_caller+0x136/0x1c0
> [18410.829123]  [<ffffffff8115f860>] ? page_alloc_cpu_notify+0x50/0x50
> [18410.829126]  [<ffffffff81084403>] ? preempt_count_sub+0x23/0x60
> [18410.829129]  [<ffffffff810eb58f>] ? on_each_cpu_mask+0x5f/0xd0
> [18410.829131]  [<ffffffff811c1bbf>] read_page_owner+0x15f/0x180
> [18410.829134]  [<ffffffff811c6ba3>] __vfs_read+0x23/0xd0
> [18410.829137]  [<ffffffff8126581b>] ? security_file_permission+0x9b/0xc0
> [18410.829139]  [<ffffffff811c71ba>] ? rw_verify_area+0x4a/0xe0
> [18410.829141]  [<ffffffff811c72dd>] vfs_read+0x8d/0x140
> [18410.829143]  [<ffffffff810acc51>] ? lockdep_sys_exit+0x1/0x90
> [18410.829146]  [<ffffffff811c7cbd>] SyS_read+0x4d/0xb0
> [18410.829149]  [<ffffffff815ae26e>] entry_SYSCALL_64_fastpath+0x12/0x76
> [18410.829151] Mem-Info:
> [18410.829157] active_anon:715055 inactive_anon:205953 isolated_anon:15
>                  active_file:215967 inactive_file:199708 isolated_file:0
>                  unevictable:5132 dirty:4186 writeback:5030 unstable:0
>                  slab_reclaimable:49019 slab_unreclaimable:28035
>                  mapped:168002 shmem:124895 pagetables:20296 bounce:0
>                  free:14378 free_pcp:127 free_cma:0
> [18410.829164] DMA free:15872kB min:20kB low:24kB high:28kB 
> active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB 
> unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15992kB 
> managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB 
> slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB 
> pagetables:0kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB 
> free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
> [18410.829166] lowmem_reserve[]: 0 2966 7692 7692
> [18410.829174] DMA32 free:28064kB min:4296kB low:5368kB high:6444kB 
> active_anon:1064284kB inactive_anon:359240kB active_file:348344kB 
> inactive_file:326552kB unevictable:9228kB isolated(anon):60kB 
> isolated(file):0kB present:3129024kB managed:3040444kB mlocked:9228kB 
> dirty:6408kB writeback:7312kB mapped:276504kB shmem:197144kB 
> slab_reclaimable:78148kB slab_unreclaimable:44692kB kernel_stack:5216kB 
> pagetables:33052kB unstable:0kB bounce:0kB free_pcp:24kB local_pcp:20kB 
> free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> [18410.829176] lowmem_reserve[]: 0 0 4725 4725
> [18410.829183] Normal free:13576kB min:6844kB low:8552kB high:10264kB 
> active_anon:1795936kB inactive_anon:464572kB active_file:515524kB 
> inactive_file:472280kB unevictable:11300kB isolated(anon):0kB 
> isolated(file):0kB present:4980736kB managed:4839416kB mlocked:11300kB 
> dirty:10336kB writeback:12808kB mapped:395504kB shmem:302436kB 
> slab_reclaimable:117928kB slab_unreclaimable:67448kB kernel_stack:7392kB 
> pagetables:48132kB unstable:0kB bounce:0kB free_pcp:484kB local_pcp:0kB 
> free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> [18410.829184] lowmem_reserve[]: 0 0 0 0
> [18410.829188] DMA: 0*4kB 0*8kB 0*16kB 2*32kB (U) 1*64kB (U) 1*128kB (U) 
> 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (EM) = 15872kB
> [18410.829201] DMA32: 1914*4kB (UEM) 835*8kB (UEM) 390*16kB (UEM) 
> 170*32kB (EM) 34*64kB (M) 1*128kB (M) 0*256kB 0*512kB 0*1024kB 0*2048kB 
> 0*4096kB = 28320kB
> [18410.829213] Normal: 1049*4kB (UEM) 511*8kB (UEM) 222*16kB (UEM) 
> 48*32kB (UM) 6*64kB (M) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 
> 0*4096kB = 13756kB
> [18410.829225] Node 0 hugepages_total=0 hugepages_free=0 
> hugepages_surp=0 hugepages_size=2048kB
> [18410.829226] 555867 total pagecache pages
> [18410.829228] 10431 pages in swap cache
> [18410.829229] Swap cache stats: add 395263, delete 384832, find 34692/49351
> [18410.829231] Free swap  = 2820524kB
> [18410.829232] Total swap = 4194288kB
> [18410.829275] 2031438 pages RAM
> [18410.829276] 0 pages HighMem/MovableOnly
> [18410.829277] 57497 pages reserved

OK we should look at this. It's annoying to rely on order-5 allocation when you
are debugging a memory leak issue. There should better be an order-0 fallback...

> I'll try to repeat the process with the 4.2.0-rc6 kernel also.

Hm I guess the memory stats for rc6 already rule out such high usage in ttm.

In rc7 it might be interesting to know how the page owner stats change after you
kill 1) the chrome/iceweasel processes, and then 2) the whole X. If the memory
is recovered, it might be not a full leak, but something like insufficient
shrinker response to memory pressure in the system.

Unless of course the drm devs have better ideas what to try...

> Arthur.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
