Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4EB096B02B4
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 05:46:13 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t187so75954525pfb.0
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 02:46:13 -0700 (PDT)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.124])
        by mx.google.com with ESMTPS id q3si6740398pgf.182.2017.07.24.02.46.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Jul 2017 02:46:12 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [PATCH] zsmalloc: zs_page_migrate: skip unnecessary loops but not return -EBUSY if zspage is not inuse
Date: Mon, 24 Jul 2017 17:45:35 +0800
Message-ID: <1500889535-19648-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: teawater@gmail.com, Hui Zhu <zhuhui@xiaomi.com>

The first version is in [1].

Got -EBUSY from zs_page_migrate will make migration
slow (retry) or fail (zs_page_putback will schedule_work free_work,
but it cannot ensure the success).

I noticed this issue because my Kernel patched [2]
that will remove retry in __alloc_contig_migrate_range.
This retry willhandle the -EBUSY because it will re-isolate the page
and re-call migrate_pages.
Without it will make cma_alloc fail at once with -EBUSY.

According to the review from Minchan Kim in [3], I update the patch
to skip unnecessary loops but not return -EBUSY if zspage is not inuse.

Following is what I got with highalloc-performance in a vbox with 2
cpu 1G memory 512 zram as swap.  And the swappiness is set to 100.
                                   ori          ne
                                  orig         new
Minor Faults                  50805113    50830235
Major Faults                     43918       56530
Swap Ins                         42087       55680
Swap Outs                        89718      104700
Allocation stalls                    0           0
DMA allocs                       57787       52364
DMA32 allocs                  47964599    48043563
Normal allocs                        0           0
Movable allocs                       0           0
Direct pages scanned             45493       23167
Kswapd pages scanned           1565222     1725078
Kswapd pages reclaimed         1342222     1503037
Direct pages reclaimed           45615       25186
Kswapd efficiency                  85%         87%
Kswapd velocity               1897.101    1949.042
Direct efficiency                 100%        108%
Direct velocity                 55.139      26.175
Percentage direct scans             2%          1%
Zone normal velocity          1952.240    1975.217
Zone dma32 velocity              0.000       0.000
Zone dma velocity                0.000       0.000
Page writes by reclaim       89764.000  105233.000
Page writes file                    46         533
Page writes anon                 89718      104700
Page reclaim immediate           21457        3699
Sector Reads                   3259688     3441368
Sector Writes                  3667252     3754836
Page rescued immediate               0           0
Slabs scanned                  1042872     1160855
Direct inode steals               8042       10089
Kswapd inode steals              54295       29170
Kswapd skipped wait                  0           0
THP fault alloc                    175         154
THP collapse alloc                 226         289
THP splits                           0           0
THP fault fallback                  11          14
THP collapse fail                    3           2
Compaction stalls                  536         646
Compaction success                 322         358
Compaction failures                214         288
Page migrate success            119608      111063
Page migrate failure              2723        2593
Compaction pages isolated       250179      232652
Compaction migrate scanned     9131832     9942306
Compaction free scanned        2093272     2613998
Compaction cost                    192         189
NUMA alloc hit                47124555    47193990
NUMA alloc miss                      0           0
NUMA interleave hit                  0           0
NUMA alloc local              47124555    47193990
NUMA base PTE updates                0           0
NUMA huge PMD updates                0           0
NUMA page range updates              0           0
NUMA hint faults                     0           0
NUMA hint local faults               0           0
NUMA hint local percent            100         100
NUMA pages migrated                  0           0
AutoNUMA cost                       0%          0%

[1]: https://lkml.org/lkml/2017/7/14/93
[2]: https://lkml.org/lkml/2014/5/28/113
[3]: https://lkml.org/lkml/2017/7/21/10

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 mm/zsmalloc.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index d41edd2..c2c7ba9 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1997,8 +1997,11 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
 
 	spin_lock(&class->lock);
 	if (!get_zspage_inuse(zspage)) {
-		ret = -EBUSY;
-		goto unlock_class;
+		/*
+		 * Set "offset" to end of the page so that every loops
+		 * skips unnecessary object scanning.
+		 */
+		offset = PAGE_SIZE;
 	}
 
 	pos = offset;
@@ -2066,7 +2069,7 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
 		}
 	}
 	kunmap_atomic(s_addr);
-unlock_class:
+
 	spin_unlock(&class->lock);
 	migrate_write_unlock(zspage);
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
