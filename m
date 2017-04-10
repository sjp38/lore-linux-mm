Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DA0B96B0390
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 14:05:56 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t23so26484559pfe.17
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 11:05:56 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id o5si14262953pfb.367.2017.04.10.11.05.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 11:05:55 -0700 (PDT)
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 4521A20218
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 18:05:54 +0000 (UTC)
Received: from mail-yb0-f180.google.com (mail-yb0-f180.google.com [209.85.213.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A4ADB20149
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 18:05:51 +0000 (UTC)
Received: by mail-yb0-f180.google.com with SMTP id l201so36552436ybf.0
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 11:05:51 -0700 (PDT)
MIME-Version: 1.0
From: Ming Lin <mlin@kernel.org>
Date: Mon, 10 Apr 2017 11:05:50 -0700
Message-ID: <CAF1ivSbZp6QLkscBFkFZQaH7vhnjWXjwSBsYctUNYtP4tYMF8w@mail.gmail.com>
Subject: oom issue with 128G memory
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: linux-nvme@lists.infradead.org

Hi list,

On a pre-production system(128G mem) running centos 3.10 kernel, I run
into a oom issue.

I did a rough statistics from below log,
active_anon:36101708kB (36G)
inactive_anon:2041404kB (2G)
active_file:38413224kB (38G)
inactive_file:42925756kB (42G)

If I understand correctly, active/inactive_file are actually reclaimable memory.
Although there are so many reclaimable memory, but the allocation
still failed because it wants an atomic allocation, so it can't wait
for the reclaim.

For this case, which vm parameter should I adjust?
Will turning vfs_cache_presure help? For example,

echo 150 > /proc/sys/vm/vfs_cache_pressure

More logs:
dmesg: https://pastebin.com/4E981Qdc
slabtop: https://pastebin.com/tZ6mfywt
/proc/meminfo: https://pastebin.com/9yjqf4s8
/proc/sys/vm: https://pastebin.com/n3TYB3hj

Thanks,
Ming
---

[111759.088322] active_anon:9106553 inactive_anon:594546 isolated_anon:0
 active_file:9604032 inactive_file:10734626 isolated_file:0
 unevictable:0 dirty:499170 writeback:9105 unstable:0
 free:194503 slab_reclaimable:581050 slab_unreclaimable:110527
 mapped:44488 shmem:231 pagetables:33472 bounce:0
 free_cma:0
[111759.123851] Node 0 DMA free:15904kB min:8kB low:8kB high:12kB
active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB
unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15992kB
managed:15908kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB
shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB
pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB
pages_scanned:0 all_unreclaimable? yes
[111759.163754] lowmem_reserve[]: 0 1384 128355 128355
[111759.168884] Node 0 DMA32 free:508732kB min:724kB low:904kB
high:1084kB active_anon:330068kB inactive_anon:336780kB
active_file:2904kB inactive_file:3652kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB present:1668992kB
managed:1417472kB mlocked:0kB dirty:1136kB writeback:0kB mapped:4kB
shmem:12kB slab_reclaimable:107812kB slab_unreclaimable:31264kB
kernel_stack:2848kB pagetables:2032kB unstable:0kB bounce:0kB
free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[111759.212843] lowmem_reserve[]: 0 0 126971 126971
[111759.217737] Node 0 Normal free:258680kB min:66844kB low:83552kB
high:100264kB active_anon:36101708kB inactive_anon:2041404kB
active_file:38413224kB inactive_file:42925756kB unevictable:0kB
isolated(anon):0kB isolated(file):0kB present:132120576kB
managed:130018612kB mlocked:0kB dirty:1995544kB writeback:37596kB
mapped:177948kB shmem:912kB slab_reclaimable:2216388kB
slab_unreclaimable:410844kB kernel_stack:34640kB pagetables:131856kB
unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0
all_unreclaimable? no
[111759.265357] lowmem_reserve[]: 0 0 0 0
[111759.269374] Node 0 DMA: 0*4kB 0*8kB 0*16kB 1*32kB (U) 2*64kB (U)
1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M)
= 15904kB
[111759.283216] Node 0 DMA32: 2737*4kB (UEMR) 6481*8kB (UEMR)
3817*16kB (UEMR) 2256*32kB (UEMR) 1214*64kB (UEM) 417*128kB (UEM)
181*256kB (EMR) 110*512kB (UEM) 65*1024kB (UM) 2*2048kB (M) 2*4096kB
(M) = 508636kB
[111759.302669] Node 0 Normal: 53981*4kB (UEM) 4002*8kB (UEM) 363*16kB
(UEM) 84*32kB (UEMR) 13*64kB (MR) 7*128kB (R) 4*256kB (R) 0*512kB
0*1024kB 0*2048kB 0*4096kB = 259188kB
[111759.318861] Node 0 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=1048576kB
[111759.327922] Node 0 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=2048kB
[111759.336779] 20346223 total pagecache pages
[111759.341135] 9388 pages in swap cache
[111759.344966] Swap cache stats: add 46881, delete 37493, find 13904/15780
[111759.351829] Free swap  = 1993772kB
[111759.355488] Total swap = 2097148kB
[111759.359147] SLUB: Unable to allocate memory on node -1 (gfp=0x20)
[111759.365489]   cache: kmalloc-8192, object size: 8192, buffer size:
8192, default order: 3, min order: 1
[111759.375298]   node 0: slabs: 219, objs: 867, free: 13
[111775.571176] kworker/17:1H: page allocation failure: order:1, mode:0x204020
[111775.578315] CPU: 17 PID: 1652 Comm: kworker/17:1H Tainted: G
 W  OE  ------------   3.10.0-327
[111775.590394] Hardware name: Huawei RH2288H V3/BC11HGSA0, BIOS 3.50 11/23/2016
[111775.597706] Workqueue: kblockd blk_mq_run_work_fn
[111775.602697]  0000000000204020 000000009465df34 ffff881fcc733980
ffffffff816323a6
[111775.610560]  ffff881fcc733a10 ffffffff8116bf70 0000000000000010
0000000000000000
[111775.618477]  ffff88207ffd7000 00000001fffffffe 0000000000000003
000000009465df34
[111775.626362] Call Trace:
[111775.629076]  [<ffffffff816323a6>] dump_stack+0x19/0x1b
[111775.634479]  [<ffffffff8116bf70>] warn_alloc_failed+0x110/0x180
[111775.640642]  [<ffffffff8117074b>] __alloc_pages_nodemask+0xa1b/0xc40
[111775.643058] kworker/u128:7: page allocation failure: order:1, mode:0x204020
[111775.643061] CPU: 18 PID: 28937 Comm: kworker/u128:7 Tainted: G
   W  OE  ------------   3.10.0-327
[111775.643069] Workqueue: writeback bdi_writeback_workfn (flush-259:5)
[111775.643074]  0000000000204020 00000000128b7618 ffff88010566f2a0
ffffffff816323a6
[111775.643077]  ffff88010566f330 ffffffff8116bf70 0000000000000010
0000000000000000
[111775.643080]  ffff88207ffd7000 00000001fffffffe 0000000000000003
00000000128b7618
[111775.643080] Call Trace:
[111775.643084]  [<ffffffff816323a6>] dump_stack+0x19/0x1b
[111775.643087]  [<ffffffff8116bf70>] warn_alloc_failed+0x110/0x180
[111775.643089]  [<ffffffff8117074b>] __alloc_pages_nodemask+0xa1b/0xc40
[111775.643094]  [<ffffffff811b1e89>] alloc_pages_current+0xa9/0x170
[111775.643096]  [<ffffffff811bc49c>] new_slab+0x2ec/0x300
[111775.643098]  [<ffffffff8162f323>] __slab_alloc+0x315/0x48f
[111775.643117]  [<ffffffffa0012e0d>] ? __nvme_alloc_iod+0x5d/0x90 [nvme]
[111775.643119]  [<ffffffff811ac7e5>] ? dma_pool_alloc+0x1b5/0x260
[111775.643122]  [<ffffffff811bf9a8>] __kmalloc+0x1c8/0x230
[111775.643126]  [<ffffffffa0012e0d>] __nvme_alloc_iod+0x5d/0x90 [nvme]
[111775.643129]  [<ffffffffa0015300>] nvme_queue_rq+0x90/0x7e0 [nvme]
[111775.643135]  [<ffffffff812d2fd2>] __blk_mq_run_hw_queue+0x1e2/0x3a0
[111775.643137]  [<ffffffff812d343f>] blk_mq_map_request+0x13f/0x1f0
[111775.643140]  [<ffffffff812d4b54>] blk_mq_make_request+0xb4/0x410
[111775.643145]  [<ffffffff812c59a2>] generic_make_request+0xe2/0x130
[111775.643148]  [<ffffffff812c5a61>] submit_bio+0x71/0x150
[111775.643174]  [<ffffffffa06de013>]
xfs_submit_ioend_bio.isra.12+0x33/0x40 [xfs]
[111775.643185]  [<ffffffffa06de10f>] xfs_submit_ioend+0xef/0x130 [xfs]
[111775.643196]  [<ffffffffa06dede2>] xfs_vm_writepage+0x2a2/0x5d0 [xfs]
[111775.643199]  [<ffffffff81170ae3>] __writepage+0x13/0x50
[111775.643201]  [<ffffffff81171601>] write_cache_pages+0x251/0x4d0
[111775.643203]  [<ffffffff81170ad0>] ? global_dirtyable_memory+0x70/0x70
[111775.643206]  [<ffffffff811718cd>] generic_writepages+0x4d/0x80
[111775.643216]  [<ffffffffa06de683>] xfs_vm_writepages+0x43/0x50 [xfs]
[111775.643219]  [<ffffffff8117297e>] do_writepages+0x1e/0x40
[111775.643222]  [<ffffffff81208ef5>] __writeback_single_inode+0x45/0x2d0
[111775.643224]  [<ffffffff81209416>] writeback_sb_inodes+0x296/0x4b0
[111775.643226]  [<ffffffff812096cf>] __writeback_inodes_wb+0x9f/0xd0
[111775.643229]  [<ffffffff81209963>] wb_writeback+0x263/0x2f0
[111775.643231]  [<ffffffff81172010>] ? bdi_dirty_limit+0x40/0xe0
[111775.643233]  [<ffffffff8120a05c>] bdi_writeback_workfn+0x1cc/0x460
[111775.643237]  [<ffffffff810967bb>] process_one_work+0x17b/0x470
[111775.643239]  [<ffffffff8109758b>] worker_thread+0x11b/0x400
[111775.643240]  [<ffffffff81097470>] ? rescuer_thread+0x400/0x400
[111775.643245]  [<ffffffff8109ecef>] kthread+0xcf/0xe0
[111775.643247]  [<ffffffff8109ec20>] ? kthread_create_on_node+0x140/0x140
[111775.643251]  [<ffffffff81642998>] ret_from_fork+0x58/0x90
[111775.643253]  [<ffffffff8109ec20>] ? kthread_create_on_node+0x140/0x140

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
