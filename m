Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id BB9986B0099
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 10:11:31 -0500 (EST)
Received: by pdjp10 with SMTP id p10so1754883pdj.3
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 07:11:31 -0800 (PST)
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com. [209.85.192.181])
        by mx.google.com with ESMTPS id dt4si3571983pdb.34.2015.02.16.21.17.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Feb 2015 21:17:32 -0800 (PST)
Received: by pdjy10 with SMTP id y10so41186992pdj.6
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 21:17:32 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH] mm/nommu: fix memory leak
Date: Tue, 17 Feb 2015 14:17:22 +0900
Message-Id: <1424150242-4805-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Maxime Coquelin <mcoquelin.stm32@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Maxime reported following memory leak regression due to commit dbc8358c7237
("mm/nommu: use alloc_pages_exact() rather than its own implementation").

On v3.19, I am facing a memory leak.
Each time I run a command one page is lost. Here an example with
busybox's free command:

/ # free
             total       used       free     shared    buffers     cached
Mem:          7928       1972       5956          0          0        492
-/+ buffers/cache:       1480       6448
/ # free
             total       used       free     shared    buffers     cached
Mem:          7928       1976       5952          0          0        492
-/+ buffers/cache:       1484       6444
/ # free
             total       used       free     shared    buffers     cached
Mem:          7928       1980       5948          0          0        492
-/+ buffers/cache:       1488       6440
/ # free
             total       used       free     shared    buffers     cached
Mem:          7928       1984       5944          0          0        492
-/+ buffers/cache:       1492       6436
/ # free
             total       used       free     shared    buffers     cached
Mem:          7928       1988       5940          0          0        492
-/+ buffers/cache:       1496       6432

At some point, the system fails to sastisfy 256KB allocations:

[   38.720000] free: page allocation failure: order:6, mode:0xd0
[   38.730000] CPU: 0 PID: 67 Comm: free Not tainted
3.19.0-05389-gacf2cf1-dirty #64
[   38.740000] Hardware name: STM32 (Device Tree Support)
[   38.740000] [<08022e25>] (unwind_backtrace) from [<080221e7>]
(show_stack+0xb/0xc)
[   38.750000] [<080221e7>] (show_stack) from [<0804fd3b>]
(warn_alloc_failed+0x97/0xbc)
[   38.760000] [<0804fd3b>] (warn_alloc_failed) from [<08051171>]
(__alloc_pages_nodemask+0x295/0x35c)
[   38.770000] [<08051171>] (__alloc_pages_nodemask) from [<08051243>]
(__get_free_pages+0xb/0x24)
[   38.780000] [<08051243>] (__get_free_pages) from [<0805127f>]
(alloc_pages_exact+0x19/0x24)
[   38.790000] [<0805127f>] (alloc_pages_exact) from [<0805bdbf>]
(do_mmap_pgoff+0x423/0x658)
[   38.800000] [<0805bdbf>] (do_mmap_pgoff) from [<08056e73>]
(vm_mmap_pgoff+0x3f/0x4e)
[   38.810000] [<08056e73>] (vm_mmap_pgoff) from [<08080949>]
(load_flat_file+0x20d/0x4f8)
[   38.820000] [<08080949>] (load_flat_file) from [<08080dfb>]
(load_flat_binary+0x3f/0x26c)
[   38.830000] [<08080dfb>] (load_flat_binary) from [<08063741>]
(search_binary_handler+0x51/0xe4)
[   38.840000] [<08063741>] (search_binary_handler) from [<08063a45>]
(do_execveat_common+0x271/0x35c)
[   38.850000] [<08063a45>] (do_execveat_common) from [<08063b49>]
(do_execve+0x19/0x1c)
[   38.860000] [<08063b49>] (do_execve) from [<08020a01>]
(ret_fast_syscall+0x1/0x4a)
[   38.870000] Mem-info:
[   38.870000] Normal per-cpu:
[   38.870000] CPU    0: hi:    0, btch:   1 usd:   0
[   38.880000] active_anon:0 inactive_anon:0 isolated_anon:0
[   38.880000]  active_file:0 inactive_file:0 isolated_file:0
[   38.880000]  unevictable:123 dirty:0 writeback:0 unstable:0
[   38.880000]  free:1515 slab_reclaimable:17 slab_unreclaimable:139
[   38.880000]  mapped:0 shmem:0 pagetables:0 bounce:0
[   38.880000]  free_cma:0
[   38.910000] Normal free:6060kB min:352kB low:440kB high:528kB
active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB
unevictable:492kB isolated(anon):0ks
[   38.950000] lowmem_reserve[]: 0 0
[   38.950000] Normal: 23*4kB (U) 22*8kB (U) 24*16kB (U) 23*32kB (U)
23*64kB (U) 23*128kB (U) 1*256kB (U) 0*512kB 0*1024kB 0*2048kB
0*4096kB = 6060kB
[   38.970000] 123 total pagecache pages
[   38.970000] 2048 pages of RAM
[   38.980000] 1538 free pages
[   38.980000] 66 reserved pages
[   38.990000] 109 slab pages
[   38.990000] -46 pages shared
[   38.990000] 0 pages swap cached
[   38.990000] nommu: Allocation of length 221184 from process 67 (free) failed
[   39.000000] Normal per-cpu:
[   39.010000] CPU    0: hi:    0, btch:   1 usd:   0
[   39.010000] active_anon:0 inactive_anon:0 isolated_anon:0
[   39.010000]  active_file:0 inactive_file:0 isolated_file:0
[   39.010000]  unevictable:123 dirty:0 writeback:0 unstable:0
[   39.010000]  free:1515 slab_reclaimable:17 slab_unreclaimable:139
[   39.010000]  mapped:0 shmem:0 pagetables:0 bounce:0
[   39.010000]  free_cma:0
[   39.050000] Normal free:6060kB min:352kB low:440kB high:528kB
active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB
unevictable:492kB isolated(anon):0ks
[   39.090000] lowmem_reserve[]: 0 0
[   39.090000] Normal: 23*4kB (U) 22*8kB (U) 24*16kB (U) 23*32kB (U)
23*64kB (U) 23*128kB (U) 1*256kB (U) 0*512kB 0*1024kB 0*2048kB
0*4096kB = 6060kB
[   39.100000] 123 total pagecache pages
[   39.110000] Unable to allocate RAM for process text/data, errno 12
SEGV

This problem happens because we allocate ordered page through
__get_free_pages() in do_mmap_private() in some cases and we
try to free individual pages rather than ordered page in
free_page_series(). In this case, freeing pages whose refcount is not 0
won't be freed to the page allocator so memory leak happens.

To fix the problem, this patch changes __get_free_pages() to
alloc_pages_exact() since alloc_pages_exact() returns
physically-contiguous pages but each pages are refcounted.

Fixes: dbc8358c7237 ("mm/nommu: use alloc_pages_exact() rather than
its own implementation").
Reported-by: Maxime Coquelin <mcoquelin.stm32@gmail.com>
Tested-by: Maxime Coquelin <mcoquelin.stm32@gmail.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/nommu.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index 7296360..3e67e75 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1213,11 +1213,9 @@ static int do_mmap_private(struct vm_area_struct *vma,
 	if (sysctl_nr_trim_pages && total - point >= sysctl_nr_trim_pages) {
 		total = point;
 		kdebug("try to alloc exact %lu pages", total);
-		base = alloc_pages_exact(len, GFP_KERNEL);
-	} else {
-		base = (void *)__get_free_pages(GFP_KERNEL, order);
 	}
 
+	base = alloc_pages_exact(total << PAGE_SHIFT, GFP_KERNEL);
 	if (!base)
 		goto enomem;
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
