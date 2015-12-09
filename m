Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f48.google.com (mail-vk0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id D93806B025B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 12:51:42 -0500 (EST)
Received: by vkca188 with SMTP id a188so59223540vkc.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 09:51:42 -0800 (PST)
Received: from mail-vk0-x22d.google.com (mail-vk0-x22d.google.com. [2607:f8b0:400c:c05::22d])
        by mx.google.com with ESMTPS id g200si6632878vke.139.2015.12.09.09.51.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 09:51:41 -0800 (PST)
Received: by vkca188 with SMTP id a188so59222736vkc.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 09:51:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151209120246.GA427@swordfish>
References: <20151209181920.32a38404@canb.auug.org.au>
	<20151209085944.GA462@swordfish>
	<20151209120246.GA427@swordfish>
Date: Wed, 9 Dec 2015 19:51:41 +0200
Message-ID: <CAHp75Vc_=DASrxgQ5Kj=F_cw-ABom_bTGPx9H1SJkoXh0J_nFQ@mail.gmail.com>
Subject: Re: the first bad commit "use memblock_insert_region() for the empty
 array" (was linux-next: Tree for Dec 9)
From: Andy Shevchenko <andy.shevchenko@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Alexander Kuleshov <kuleshovmail@gmail.com>, Tony Luck <tony.luck@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Wei Yang <weiyang@linux.vnet.ibm.com>, linux-next <linux-next@vger.kernel.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Dec 9, 2015 at 2:02 PM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
> Hello,
>
> On (12/09/15 17:59), Sergey Senozhatsky wrote:
>> On (12/09/15 18:19), Stephen Rothwell wrote:
>> >
>> > Changes since 20151208:
>> >
>>
>> corrupts low memory:

Oh, I have to check for this first, I did the same bisect and found
the same culprit. Intel Medfield / Merifield platforms (x86_32).

So, please, revert this one.

>>
>> [   60.459441] Corrupted low memory at ffff880000001000 (1000 phys) = 00000001
>> [   60.459445] Corrupted low memory at ffff880000001008 (1008 phys) = ffffffff81a816b8
>> [   60.459446] Corrupted low memory at ffff880000001020 (1020 phys) = ffffffff817e509f
>> [   60.459448] Corrupted low memory at ffff880000001028 (1028 phys) = ffff880037962098
>> [   60.459449] Corrupted low memory at ffff880000001030 (1030 phys) = ffffffff8180ce74
>> [   60.459450] Corrupted low memory at ffff880000001038 (1038 phys) = ffff880037962d48
>> [   60.459452] Corrupted low memory at ffff880000001058 (1058 phys) = 01adad40
>> [   60.459453] Corrupted low memory at ffff880000001060 (1060 phys) = ffffffff81620b20
>> [   60.459454] Corrupted low memory at ffff880000001070 (1070 phys) = 00001000
>> [   60.459456] Corrupted low memory at ffff880000001080 (1080 phys) = ffffffff81a816a0
>> [   60.459457] Corrupted low memory at ffff880000001088 (1088 phys) = 21eb81240152
>> [   60.459458] Corrupted low memory at ffff880000001098 (1098 phys) = 00000001
>> [   60.459459] Corrupted low memory at ffff8800000010a0 (10a0 phys) = ffffffff81a816e8
>> [   60.459461] Corrupted low memory at ffff8800000010b8 (10b8 phys) = ffffffff817e509f
>> [   60.459462] Corrupted low memory at ffff8800000010c0 (10c0 phys) = ffff880037962098
>> [   60.459463] Corrupted low memory at ffff8800000010c8 (10c8 phys) = ffffffff8180715d
>> [   60.459465] Corrupted low memory at ffff8800000010d0 (10d0 phys) = ffff880037962169
>> [   60.459466] Corrupted low memory at ffff8800000010e0 (10e0 phys) = ffff880000001168
>> [   60.459467] Corrupted low memory at ffff8800000010f0 (10f0 phys) = 56a89f6d
>> [   60.459469] Corrupted low memory at ffff8800000010f8 (10f8 phys) = ffffffff81620b20
>> [   60.459470] Corrupted low memory at ffff880000001108 (1108 phys) = 00001000
>> [   60.459471] Corrupted low memory at ffff880000001118 (1118 phys) = ffffffff81a816d0
>> [   60.459473] Corrupted low memory at ffff880000001120 (1120 phys) = 21ec81240152
>> [   60.459474] Corrupted low memory at ffff880000001130 (1130 phys) = 00000001
>> [   60.459475] Corrupted low memory at ffff880000001138 (1138 phys) = ffffffff81a81718
>> [   60.459476] Corrupted low memory at ffff880000001150 (1150 phys) = ffffffff817e509f
>> [   60.459478] Corrupted low memory at ffff880000001158 (1158 phys) = ffff880037962098
>> [   60.459479] Corrupted low memory at ffff880000001160 (1160 phys) = ffffffff81806d8f
>> [   60.459480] Corrupted low memory at ffff880000001168 (1168 phys) = ffff8800000010d0
>> [   60.459482] Corrupted low memory at ffff880000001188 (1188 phys) = 5436156b
>
>
> cabc3d3f732505b3ad56009e4a8aba0c7d39a7d7 is the first bad commit
> commit cabc3d3f732505b3ad56009e4a8aba0c7d39a7d7
> Author: Alexander Kuleshov <kuleshovmail@gmail.com>
> Date:   Wed Dec 9 16:31:03 2015 +1100
>
>     mm/memblock.c: use memblock_insert_region() for the empty array
>
>     We have the special case for an empty array in memblock_add_range().  At
>     the same time we have almost the same functionality in
>     memblock_insert_region().  Let's use memblock_insert_region() instead of
>     direct initialization.
>
>     Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
>     Cc: Tony Luck <tony.luck@intel.com>
>     Cc: Tang Chen <tangchen@cn.fujitsu.com>
>     Cc: Pekka Enberg <penberg@kernel.org>
>     Cc: Wei Yang <weiyang@linux.vnet.ibm.com>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>
> :040000 040000 5450bc6a2965794aca876f731acfbf7362503c9b c1e6b38ea2a581bbeeb0c23d596681c2cef10b86 M      mm
>
>
>
> So I reverted
>     Revert "mm/memblock.c: use memblock_insert_region() for the empty array"
>     (cabc3d3f732505b3ad56009e4a8aba0c7d39a7d7)
>
>     Revert "mm-memblock-use-memblock_insert_region-for-the-empty-array-checkpatch-fixes"
>     (6bffda3c1dbc17be5bf4cf401fd7c3313542e904)
>
> to fix my linux-next.
>
>
>
> git bisect log
>
> git bisect start
> # bad: [cd1bfb776710ceffca2ca09df029f136318c5a10] Add linux-next specific files for 20151209
> git bisect bad cd1bfb776710ceffca2ca09df029f136318c5a10
> # good: [fca839c00a12d682cb59b3b620d109a1d850b262] workqueue: warn if memory reclaim tries to flush !WQ_MEM_RECLAIM workqueue
> git bisect good fca839c00a12d682cb59b3b620d109a1d850b262
> # good: [d4c6e2e5e0ef81061332e6eb15fc14cdb3bd7183] Merge remote-tracking branch 'drm/drm-next'
> git bisect good d4c6e2e5e0ef81061332e6eb15fc14cdb3bd7183
> # good: [b1bc9932600627abf998defc0b58806c1e6a7bab] Merge remote-tracking branch 'leds/for-next'
> git bisect good b1bc9932600627abf998defc0b58806c1e6a7bab
> # good: [dc36ef98b8d7678c44bad37765f48ed3b4926e23] Merge remote-tracking branch 'scsi/for-next'
> git bisect good dc36ef98b8d7678c44bad37765f48ed3b4926e23
> # bad: [ba9842da652a588207329bde810882b4ab35a9b7] lib-vsprintfc-expand-field_width-to-24-bits-fix
> git bisect bad ba9842da652a588207329bde810882b4ab35a9b7
> # bad: [b6d2957f5399eb6334ca3dd28214ba77ddd20f45] mm: make optimistic check for swapin readahead
> git bisect bad b6d2957f5399eb6334ca3dd28214ba77ddd20f45
> # good: [04d965043b7d26a42980d127fa463c6d07dd1ab5] mm/page_isolation.c: return last tested pfn rather than failure indicator
> git bisect good 04d965043b7d26a42980d127fa463c6d07dd1ab5
> # good: [18161aa8e523040b2367b2f5e83dd446a0da5ae5] arm64-mm-support-arch_mmap_rnd_bits-fix
> git bisect good 18161aa8e523040b2367b2f5e83dd446a0da5ae5
> # bad: [5b3bc63a89602858859633a4dc55551645bf72f3] mm/readahead.c, mm/vmscan.c: use lru_to_page instead of list_to_page
> git bisect bad 5b3bc63a89602858859633a4dc55551645bf72f3
> # good: [b8b827506e5f774367991308c464e2e24afc697f] mm/page_alloc.c: use list_{first,last}_entry instead of list_entry
> git bisect good b8b827506e5f774367991308c464e2e24afc697f
> # good: [a61cbe1855dfb3bede16b0c74d027cfe337e0cbe] mm/memblock: introduce for_each_memblock_type()
> git bisect good a61cbe1855dfb3bede16b0c74d027cfe337e0cbe
> # good: [b0fd5507e807953d8992374a13f9788867c460a0] mm/compaction.c: __compact_pgdat() code cleanuup
> git bisect good b0fd5507e807953d8992374a13f9788867c460a0
> # bad: [6bffda3c1dbc17be5bf4cf401fd7c3313542e904] mm-memblock-use-memblock_insert_region-for-the-empty-array-checkpatch-fixes
> git bisect bad 6bffda3c1dbc17be5bf4cf401fd7c3313542e904
> # bad: [cabc3d3f732505b3ad56009e4a8aba0c7d39a7d7] mm/memblock.c: use memblock_insert_region() for the empty array
> git bisect bad cabc3d3f732505b3ad56009e4a8aba0c7d39a7d7
> # first bad commit: [cabc3d3f732505b3ad56009e4a8aba0c7d39a7d7] mm/memblock.c: use memblock_insert_region() for the empty array
>
>
>         -ss
>
>
>> [   60.459483] Corrupted low memory at ffff880000001190 (1190 phys) = ffffffff81620b20
>> [   60.459484] Corrupted low memory at ffff8800000011a0 (11a0 phys) = 00001000
>> [   60.459486] Corrupted low memory at ffff8800000011b0 (11b0 phys) = ffffffff81a81700
>> [   60.459487] Corrupted low memory at ffff8800000011b8 (11b8 phys) = 21ed81a40152
>> [   60.459488] Corrupted low memory at ffff8800000011c8 (11c8 phys) = 00000001
>> [   60.459490] Corrupted low memory at ffff8800000011d0 (11d0 phys) = ffffffff81a81748
>> [   60.459491] Corrupted low memory at ffff8800000011e8 (11e8 phys) = ffffffff817e509f
>> [   60.459492] Corrupted low memory at ffff8800000011f0 (11f0 phys) = ffff880037962098
>> [   60.459494] Corrupted low memory at ffff8800000011f8 (11f8 phys) = ffffffff817d21d8
>> [   60.459495] Corrupted low memory at ffff880000001200 (1200 phys) = ffff880000001298
>> [   60.459496] Corrupted low memory at ffff880000001220 (1220 phys) = 137e7407
>> [   60.459498] Corrupted low memory at ffff880000001228 (1228 phys) = ffffffff81620b20
>> [   60.459499] Corrupted low memory at ffff880000001238 (1238 phys) = 00001000
>> [   60.459500] Corrupted low memory at ffff880000001248 (1248 phys) = ffffffff81a81730
>> [   60.459501] Corrupted low memory at ffff880000001250 (1250 phys) = 21ee81a40152
>> [   60.459503] Corrupted low memory at ffff880000001260 (1260 phys) = 00000001
>> [   60.459504] Corrupted low memory at ffff880000001268 (1268 phys) = ffffffff81a81778
>> [   60.459505] Corrupted low memory at ffff880000001280 (1280 phys) = ffffffff817e509f
>> [   60.459507] Corrupted low memory at ffff880000001288 (1288 phys) = ffff880037962098
>> [   60.459508] Corrupted low memory at ffff880000001290 (1290 phys) = ffffffff81807164
>> [   60.459509] Corrupted low memory at ffff880000001298 (1298 phys) = ffff880037962299
>> [   60.459511] Corrupted low memory at ffff8800000012a0 (12a0 phys) = ffff880037962ae8
>> [   60.459512] Corrupted low memory at ffff8800000012a8 (12a8 phys) = ffff880000001200
>> [   60.459513] Corrupted low memory at ffff8800000012b8 (12b8 phys) = 1ed682f4
>> [   60.459515] Corrupted low memory at ffff8800000012c0 (12c0 phys) = ffffffff81620b20
>> [   60.459516] Corrupted low memory at ffff8800000012d0 (12d0 phys) = 00001000
>> [   60.459517] Corrupted low memory at ffff8800000012e0 (12e0 phys) = ffffffff81a81760
>> [   60.459518] Corrupted low memory at ffff8800000012e8 (12e8 phys) = 21ef81a40152
>> [   60.459520] Corrupted low memory at ffff8800000012f8 (12f8 phys) = 0000000a
>> [   60.459521] Corrupted low memory at ffff880000001320 (1320 phys) = ffff88013338b260
>> [   60.459522] Corrupted low memory at ffff880000001328 (1328 phys) = ffff88003793b028
>> [   60.459524] Corrupted low memory at ffff880000001330 (1330 phys) = ffff88013338b330
>> [   60.459525] Corrupted low memory at ffff880000001350 (1350 phys) = 5b866adb
>> [   60.459526] Corrupted low memory at ffff880000001358 (1358 phys) = 00000001
>> [   60.459528] Corrupted low memory at ffff880000001360 (1360 phys) = ffff880000001460
>> [   60.459529] Corrupted low memory at ffff880000001368 (1368 phys) = ffff88013302d500
>> [   60.459530] Corrupted low memory at ffff880000001378 (1378 phys) = ffff880037988410
>> [   60.459532] Corrupted low memory at ffff880000001380 (1380 phys) = 21f041ed0011
>> [   60.459533] Corrupted low memory at ffff880000001390 (1390 phys) = 00000003
>> [..]
>> [   60.465181] Corrupted low memory at ffff88000000ff48 (ff48 phys) = 720072007200720
>> [   60.465182] Corrupted low memory at ffff88000000ff50 (ff50 phys) = 720072007200720
>> [   60.465183] Corrupted low memory at ffff88000000ff58 (ff58 phys) = 720072007200720
>> [   60.465185] Corrupted low memory at ffff88000000ff60 (ff60 phys) = 720072007200720
>> [   60.465186] Corrupted low memory at ffff88000000ff68 (ff68 phys) = 720072007200720
>> [   60.465188] Corrupted low memory at ffff88000000ff70 (ff70 phys) = 720072007200720
>> [   60.465189] Corrupted low memory at ffff88000000ff78 (ff78 phys) = 720072007200720
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



-- 
With Best Regards,
Andy Shevchenko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
