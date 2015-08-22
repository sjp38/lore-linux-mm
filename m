Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 63EDC6B0038
	for <linux-mm@kvack.org>; Sat, 22 Aug 2015 00:48:25 -0400 (EDT)
Received: by pdob1 with SMTP id b1so33281094pdo.2
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 21:48:25 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id u8si16506482pdp.222.2015.08.21.21.48.21
        for <linux-mm@kvack.org>;
        Fri, 21 Aug 2015 21:48:24 -0700 (PDT)
Message-ID: <55D7FF06.90404@internode.on.net>
Date: Sat, 22 Aug 2015 14:18:06 +0930
From: Arthur Marsh <arthur.marsh@internode.on.net>
MIME-Version: 1.0
Subject: Re: difficult to pinpoint exhaustion of swap between 4.2.0-rc6 and
 4.2.0-rc7
References: <55D4A462.3070505@internode.on.net> <55D58CEB.9070701@suse.cz> <55D6ECBD.60303@internode.on.net> <55D70D80.5060009@suse.cz> <55D71021.7030803@suse.cz>
In-Reply-To: <55D71021.7030803@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>



Vlastimil Babka wrote on 21/08/15 21:18:
> On 08/21/2015 01:37 PM, Vlastimil Babka wrote:
>>
>> That, said, looking at the memory values:
>>
>> rc6: Free+Buffers+A/I(Anon)+A/I(File)+Slab = 6769MB
>> rc7: ...                                   = 4714MB
>>
>> That's 2GB unaccounted for.
>
> So one brute-force way to see who allocated those 2GB is to use the
> page_owner debug feature. You need to enable CONFIG_PAGE_OWNER and then
> follow the Usage part of Documentation/vm/page_owner.txt
> If you can do that, please send the sorted_page_owner.txt for rc7 when
> it's semi-nearing the exhausted swap. Then you could start doing a
> comparison run with rc6, but maybe it will be easy to figure from the
> rc7 log already. Thanks.
>

Documentation/vm/page_owner.txt does not mention the need to do:

mount -t debugfs none /sys/kernel/debug

Having done that when about 1.5 GiB swap was in use, the output of 
sorted_page_owner.txt with the rc7+ kernel starts with:

699487 times:
Page allocated via order 0, mask 0x280da
  [<ffffffff8116147e>] __alloc_pages_nodemask+0x1de/0xb00
  [<ffffffff8118d35b>] handle_mm_fault+0x11bb/0x1480
  [<ffffffff8104c3e8>] __do_page_fault+0x178/0x480
  [<ffffffff8104c71b>] do_page_fault+0x2b/0x40
  [<ffffffff815b01a8>] page_fault+0x28/0x30
  [<ffffffffffffffff>] 0xffffffffffffffff

457823 times:
Page allocated via order 0, mask 0x202d0
  [<ffffffff8116147e>] __alloc_pages_nodemask+0x1de/0xb00
  [<ffffffff8100a844>] dma_generic_alloc_coherent+0xa4/0xf0
  [<ffffffff810481fd>] x86_swiotlb_alloc_coherent+0x2d/0x60
  [<ffffffff8100a5ae>] dma_alloc_attrs+0x4e/0x90
  [<ffffffffa0427d72>] ttm_dma_populate+0x502/0x900 [ttm]
  [<ffffffffa046bf26>] radeon_ttm_tt_populate+0x216/0x2b0 [radeon]
  [<ffffffffa041dd74>] ttm_tt_bind+0x44/0x80 [ttm]
  [<ffffffffa0420316>] ttm_bo_handle_move_mem+0x3b6/0x440 [ttm]

213933 times:
Page allocated via order 0, mask 0x10200da
  [<ffffffff8116147e>] __alloc_pages_nodemask+0x1de/0xb00
  [<ffffffff81158b7c>] pagecache_get_page+0x9c/0x1f0
  [<ffffffff81158cf7>] grab_cache_page_write_begin+0x27/0x40
  [<ffffffffa01228cd>] ext4_write_begin+0xbd/0x580 [ext4]
  [<ffffffff8115773a>] generic_perform_write+0xaa/0x1a0
  [<ffffffff8115a063>] __generic_file_write_iter+0x193/0x1f0
  [<ffffffffa0115c85>] ext4_file_write_iter+0xf5/0x490 [ext4]
  [<ffffffff811c6cf5>] __vfs_write+0xa5/0xe0

120198 times:
Page allocated via order 0, mask 0x200da
  [<ffffffff8116147e>] __alloc_pages_nodemask+0x1de/0xb00
  [<ffffffff81175ab1>] shmem_getpage_gfp+0x381/0xa30
  [<ffffffff811767f2>] shmem_fault+0x62/0x1b0
  [<ffffffff81189648>] __do_fault+0x38/0x80
  [<ffffffff8118c4ac>] handle_mm_fault+0x30c/0x1480
  [<ffffffff8104c3e8>] __do_page_fault+0x178/0x480
  [<ffffffff8104c71b>] do_page_fault+0x2b/0x40
  [<ffffffff815b01a8>] page_fault+0x28/0x30

82253 times:
Page allocated via order 0, mask 0x213da
  [<ffffffff8116147e>] __alloc_pages_nodemask+0x1de/0xb00
  [<ffffffff81167b41>] __do_page_cache_readahead+0x101/0x320
  [<ffffffff8115a778>] filemap_fault+0x388/0x400
  [<ffffffff81189648>] __do_fault+0x38/0x80
  [<ffffffff8118ce7f>] handle_mm_fault+0xcdf/0x1480
  [<ffffffff8104c3e8>] __do_page_fault+0x178/0x480
  [<ffffffff8104c71b>] do_page_fault+0x2b/0x40
  [<ffffffff815b01a8>] page_fault+0x28/0x30

47542 times:
Page allocated via order 0, mask 0x200da
  [<ffffffff8116147e>] __alloc_pages_nodemask+0x1de/0xb00
  [<ffffffff81189baa>] wp_page_copy.isra.62+0x7a/0x5c0
  [<ffffffff8118b6fd>] do_wp_page+0xbd/0x600
  [<ffffffff8118c92c>] handle_mm_fault+0x78c/0x1480
  [<ffffffff8104c3e8>] __do_page_fault+0x178/0x480
  [<ffffffff8104c71b>] do_page_fault+0x2b/0x40
  [<ffffffff815b01a8>] page_fault+0x28/0x30
  [<ffffffffffffffff>] 0xffffffffffffffff

43843 times:
Page allocated via order 0, mask 0x0
  [<ffffffff81b0a34a>] page_ext_init+0xe5/0xea
  [<ffffffff81ae4ebe>] start_kernel+0x392/0x459
  [<ffffffff81ae4315>] x86_64_start_reservations+0x2a/0x2c
  [<ffffffff81ae444e>] x86_64_start_kernel+0x137/0x146
  [<ffffffffffffffff>] 0xffffffffffffffff

28075 times:
Page allocated via order 0, mask 0x8
  [<ffffffff81160388>] split_free_page+0x38/0x50
  [<ffffffff81183865>] isolate_freepages_block+0x205/0x4b0
  [<ffffffff81183cb1>] compaction_alloc+0x1a1/0x280
  [<ffffffff811b2a51>] migrate_pages+0x241/0x9a0
  [<ffffffff8118553e>] compact_zone+0x55e/0xea0
  [<ffffffff81185ed8>] compact_zone_order+0x58/0x70
  [<ffffffff81186317>] try_to_compact_pages+0x127/0x5b0
  [<ffffffff811611f9>] __alloc_pages_direct_compact+0x49/0xf0

19845 times:
Page allocated via order 0, mask 0x2a4050
  [<ffffffff8116147e>] __alloc_pages_nodemask+0x1de/0xb00
  [<ffffffff811ad53b>] cache_alloc_refill+0x33b/0x5b0
  [<ffffffff811ad095>] kmem_cache_alloc+0x1a5/0x310
  [<ffffffffa0132dca>] ext4_alloc_inode+0x1a/0x210 [ext4]
  [<ffffffff811e3f88>] alloc_inode+0x18/0x90
  [<ffffffff811e58a8>] iget_locked+0xd8/0x190
  [<ffffffffa011e85c>] ext4_iget+0x3c/0xa70 [ext4]
  [<ffffffffa011f2bb>] ext4_iget_normal+0x2b/0x40 [ext4]

Also, once when attempting to do:

cat /sys/kernel/debug/page_owner > page_owner_full.txt

I received the following error:


[18410.829060] cat: page allocation failure: order:5, mode:0x2040d0
[18410.829068] CPU: 3 PID: 1732 Comm: cat Not tainted 4.2.0-rc7+ #1907
[18410.829070] Hardware name: System manufacturer System Product 
Name/M3A78 PRO, BIOS 1701    01/27/2011
[18410.829073]  0000000000000005 ffff88001f4d7a58 ffffffff815a554d 
0000000000000034
[18410.829078]  00000000002040d0 ffff88001f4d7ae8 ffffffff8115dedc 
ffff8800360b4540
[18410.829082]  0000000000000005 ffff8800360b4540 00000000002040d0 
ffff88001f4d7bc0
[18410.829085] Call Trace:
[18410.829091]  [<ffffffff815a554d>] dump_stack+0x4f/0x7b
[18410.829096]  [<ffffffff8115dedc>] warn_alloc_failed+0xdc/0x130
[18410.829099]  [<ffffffff81161298>] ? 
__alloc_pages_direct_compact+0xe8/0xf0
[18410.829101]  [<ffffffff81161b31>] __alloc_pages_nodemask+0x891/0xb00
[18410.829104]  [<ffffffff810aa375>] ? __lock_acquire+0xc05/0x1c70
[18410.829107]  [<ffffffff811ad53b>] cache_alloc_refill+0x33b/0x5b0
[18410.829110]  [<ffffffff811c1764>] ? print_page_owner+0x54/0x350
[18410.829112]  [<ffffffff811adc7e>] __kmalloc+0x1be/0x330
[18410.829114]  [<ffffffff811c1764>] print_page_owner+0x54/0x350
[18410.829116]  [<ffffffff8115f786>] ? drain_pages_zone+0x76/0xa0
[18410.829118]  [<ffffffff8115f860>] ? page_alloc_cpu_notify+0x50/0x50
[18410.829119]  [<ffffffff8115f7cf>] ? drain_pages+0x1f/0x60
[18410.829122]  [<ffffffff810a93c6>] ? trace_hardirqs_on_caller+0x136/0x1c0
[18410.829123]  [<ffffffff8115f860>] ? page_alloc_cpu_notify+0x50/0x50
[18410.829126]  [<ffffffff81084403>] ? preempt_count_sub+0x23/0x60
[18410.829129]  [<ffffffff810eb58f>] ? on_each_cpu_mask+0x5f/0xd0
[18410.829131]  [<ffffffff811c1bbf>] read_page_owner+0x15f/0x180
[18410.829134]  [<ffffffff811c6ba3>] __vfs_read+0x23/0xd0
[18410.829137]  [<ffffffff8126581b>] ? security_file_permission+0x9b/0xc0
[18410.829139]  [<ffffffff811c71ba>] ? rw_verify_area+0x4a/0xe0
[18410.829141]  [<ffffffff811c72dd>] vfs_read+0x8d/0x140
[18410.829143]  [<ffffffff810acc51>] ? lockdep_sys_exit+0x1/0x90
[18410.829146]  [<ffffffff811c7cbd>] SyS_read+0x4d/0xb0
[18410.829149]  [<ffffffff815ae26e>] entry_SYSCALL_64_fastpath+0x12/0x76
[18410.829151] Mem-Info:
[18410.829157] active_anon:715055 inactive_anon:205953 isolated_anon:15
                 active_file:215967 inactive_file:199708 isolated_file:0
                 unevictable:5132 dirty:4186 writeback:5030 unstable:0
                 slab_reclaimable:49019 slab_unreclaimable:28035
                 mapped:168002 shmem:124895 pagetables:20296 bounce:0
                 free:14378 free_pcp:127 free_cma:0
[18410.829164] DMA free:15872kB min:20kB low:24kB high:28kB 
active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB 
unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15992kB 
managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB 
slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB 
pagetables:0kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB 
free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[18410.829166] lowmem_reserve[]: 0 2966 7692 7692
[18410.829174] DMA32 free:28064kB min:4296kB low:5368kB high:6444kB 
active_anon:1064284kB inactive_anon:359240kB active_file:348344kB 
inactive_file:326552kB unevictable:9228kB isolated(anon):60kB 
isolated(file):0kB present:3129024kB managed:3040444kB mlocked:9228kB 
dirty:6408kB writeback:7312kB mapped:276504kB shmem:197144kB 
slab_reclaimable:78148kB slab_unreclaimable:44692kB kernel_stack:5216kB 
pagetables:33052kB unstable:0kB bounce:0kB free_pcp:24kB local_pcp:20kB 
free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[18410.829176] lowmem_reserve[]: 0 0 4725 4725
[18410.829183] Normal free:13576kB min:6844kB low:8552kB high:10264kB 
active_anon:1795936kB inactive_anon:464572kB active_file:515524kB 
inactive_file:472280kB unevictable:11300kB isolated(anon):0kB 
isolated(file):0kB present:4980736kB managed:4839416kB mlocked:11300kB 
dirty:10336kB writeback:12808kB mapped:395504kB shmem:302436kB 
slab_reclaimable:117928kB slab_unreclaimable:67448kB kernel_stack:7392kB 
pagetables:48132kB unstable:0kB bounce:0kB free_pcp:484kB local_pcp:0kB 
free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[18410.829184] lowmem_reserve[]: 0 0 0 0
[18410.829188] DMA: 0*4kB 0*8kB 0*16kB 2*32kB (U) 1*64kB (U) 1*128kB (U) 
1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (EM) = 15872kB
[18410.829201] DMA32: 1914*4kB (UEM) 835*8kB (UEM) 390*16kB (UEM) 
170*32kB (EM) 34*64kB (M) 1*128kB (M) 0*256kB 0*512kB 0*1024kB 0*2048kB 
0*4096kB = 28320kB
[18410.829213] Normal: 1049*4kB (UEM) 511*8kB (UEM) 222*16kB (UEM) 
48*32kB (UM) 6*64kB (M) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 
0*4096kB = 13756kB
[18410.829225] Node 0 hugepages_total=0 hugepages_free=0 
hugepages_surp=0 hugepages_size=2048kB
[18410.829226] 555867 total pagecache pages
[18410.829228] 10431 pages in swap cache
[18410.829229] Swap cache stats: add 395263, delete 384832, find 34692/49351
[18410.829231] Free swap  = 2820524kB
[18410.829232] Total swap = 4194288kB
[18410.829275] 2031438 pages RAM
[18410.829276] 0 pages HighMem/MovableOnly
[18410.829277] 57497 pages reserved

I'll try to repeat the process with the 4.2.0-rc6 kernel also.

Arthur.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
