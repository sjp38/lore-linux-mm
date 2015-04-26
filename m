Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id DA3B26B0032
	for <linux-mm@kvack.org>; Sun, 26 Apr 2015 04:46:17 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so95191764pdb.2
        for <linux-mm@kvack.org>; Sun, 26 Apr 2015 01:46:17 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id b15si24969884pbu.18.2015.04.26.01.46.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Apr 2015 01:46:16 -0700 (PDT)
Received: by pabtp1 with SMTP id tp1so95501216pab.2
        for <linux-mm@kvack.org>; Sun, 26 Apr 2015 01:46:16 -0700 (PDT)
Date: Sun, 26 Apr 2015 16:43:31 +0800
From: Wang YanQing <udknight@gmail.com>
Subject: [PATCH v2]block:bounce: fix call inc_|dec_zone_page_state on
 different pages confuse value of NR_BOUNCE
Message-ID: <20150426084331.GA5680@udknight>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, leon@leon.nu

Commit d2c5e30c9a1420902262aa923794d2ae4e0bc391
("[PATCH] zoned vm counters: conversion of nr_bounce to per zone counter")
convert statistic of nr_bounce to per zone and one global value in vm_stat,
but it call inc_|dec_zone_page_state on different pages, then different
zones, and cause us to get unexpected value of NR_BOUNCE.

Below is the result on my machine:
Mar  2 09:26:08 udknight kernel: [144766.778265] Mem-Info:
Mar  2 09:26:08 udknight kernel: [144766.778266] DMA per-cpu:
Mar  2 09:26:08 udknight kernel: [144766.778268] CPU    0: hi:    0, btch:   1 usd:   0
Mar  2 09:26:08 udknight kernel: [144766.778269] CPU    1: hi:    0, btch:   1 usd:   0
Mar  2 09:26:08 udknight kernel: [144766.778270] Normal per-cpu:
Mar  2 09:26:08 udknight kernel: [144766.778271] CPU    0: hi:  186, btch:  31 usd:   0
Mar  2 09:26:08 udknight kernel: [144766.778273] CPU    1: hi:  186, btch:  31 usd:   0
Mar  2 09:26:08 udknight kernel: [144766.778274] HighMem per-cpu:
Mar  2 09:26:08 udknight kernel: [144766.778275] CPU    0: hi:  186, btch:  31 usd:   0
Mar  2 09:26:08 udknight kernel: [144766.778276] CPU    1: hi:  186, btch:  31 usd:   0
Mar  2 09:26:08 udknight kernel: [144766.778279] active_anon:46926 inactive_anon:287406 isolated_anon:0
Mar  2 09:26:08 udknight kernel: [144766.778279]  active_file:105085 inactive_file:139432 isolated_file:0
Mar  2 09:26:08 udknight kernel: [144766.778279]  unevictable:653 dirty:0 writeback:0 unstable:0
Mar  2 09:26:08 udknight kernel: [144766.778279]  free:178957 slab_reclaimable:6419 slab_unreclaimable:9966
Mar  2 09:26:08 udknight kernel: [144766.778279]  mapped:4426 shmem:305277 pagetables:784 bounce:0
Mar  2 09:26:08 udknight kernel: [144766.778279]  free_cma:0
Mar  2 09:26:08 udknight kernel: [144766.778286] DMA free:3324kB min:68kB low:84kB high:100kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15976kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
Mar  2 09:26:08 udknight kernel: [144766.778287] lowmem_reserve[]: 0 822 3754 3754
Mar  2 09:26:08 udknight kernel: [144766.778293] Normal free:26828kB min:3632kB low:4540kB high:5448kB active_anon:4872kB inactive_anon:68kB active_file:1796kB inactive_file:1796kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:892920kB managed:842560kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:4144kB slab_reclaimable:25676kB slab_unreclaimable:39864kB kernel_stack:1944kB pagetables:3136kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:2412612 all_unreclaimable? yes
Mar  2 09:26:08 udknight kernel: [144766.778294] lowmem_reserve[]: 0 0 23451 23451
Mar  2 09:26:08 udknight kernel: [144766.778299] HighMem free:685676kB min:512kB low:3748kB high:6984kB active_anon:182832kB inactive_anon:1149556kB active_file:418544kB inactive_file:555932kB unevictable:2612kB isolated(anon):0kB isolated(file):0kB present:3001732kB managed:3001732kB mlocked:0kB dirty:0kB writeback:0kB mapped:17704kB shmem:1216964kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:75771152kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Mar  2 09:26:08 udknight kernel: [144766.778300] lowmem_reserve[]: 0 0 0 0

You can see bounce:75771152kB for HighMem, but bounce:0 for lowmem and global.

This patch fix it.

Signed-off-by: Wang YanQing <udknight@gmail.com>
---
 Changes
 v1-v2: fix comment issue reported by Leon Romanovsky

 block/bounce.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/block/bounce.c b/block/bounce.c
index ab21ba2..ed9dd80 100644
--- a/block/bounce.c
+++ b/block/bounce.c
@@ -221,8 +221,8 @@ bounce:
 		if (page_to_pfn(page) <= queue_bounce_pfn(q) && !force)
 			continue;
 
-		inc_zone_page_state(to->bv_page, NR_BOUNCE);
 		to->bv_page = mempool_alloc(pool, q->bounce_gfp);
+		inc_zone_page_state(to->bv_page, NR_BOUNCE);
 
 		if (rw == WRITE) {
 			char *vto, *vfrom;
-- 
1.8.5.6.2.g3d8a54e.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
