Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 027A56B025E
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 05:59:41 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 1so10314189wmz.2
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 02:59:40 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id ty2si2229195wjb.223.2016.09.09.02.59.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Sep 2016 02:59:37 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id B61491C184B
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 10:59:36 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 2/4] block, brd: Treat storage as non-rotational
Date: Fri,  9 Sep 2016 10:59:33 +0100
Message-Id: <1473415175-20807-3-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1473415175-20807-1-git-send-email-mgorman@techsingularity.net>
References: <1473415175-20807-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>
Cc: Dave Chinner <david@fromorbit.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ying Huang <ying.huang@intel.com>, Michal Hocko <mhocko@kernel.org>

Unlike the rims of a punked out car, RAM does not spin. Ramdisk as
implemented by the brd is treated as rotational storage. When used as swap
to simulate fast storage, swap uses the algoritms for minimising seek times
instead of the algorithms optimised for SSD. When the tree_lock contention
was reduced by the previous patch, it was found that the workload was
dominated by scan_swap_map(). This patch has no practical application as
swap-on-ramdisk is dumb is rocks but it's trivial to fix.

                              4.8.0-rc5             4.8.0-rc5
                               batch-v1      ramdisknonrot-v1
Amean    System-1      192.98 (  0.00%)      181.00 (  6.21%)
Amean    System-3      198.33 (  0.00%)       86.19 ( 56.54%)
Amean    System-5      105.22 (  0.00%)       67.43 ( 35.91%)
Amean    System-7       97.79 (  0.00%)       89.55 (  8.42%)
Amean    System-8      149.39 (  0.00%)      102.92 ( 31.11%)
Amean    Elapsd-1      219.95 (  0.00%)      209.23 (  4.88%)
Amean    Elapsd-3       79.02 (  0.00%)       36.93 ( 53.26%)
Amean    Elapsd-5       29.88 (  0.00%)       19.52 ( 34.69%)
Amean    Elapsd-7       24.06 (  0.00%)       21.93 (  8.84%)
Amean    Elapsd-8       33.34 (  0.00%)       23.63 ( 29.12%)

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 drivers/block/brd.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/block/brd.c b/drivers/block/brd.c
index 0c76d4016eeb..83a76a74e027 100644
--- a/drivers/block/brd.c
+++ b/drivers/block/brd.c
@@ -504,6 +504,7 @@ static struct brd_device *brd_alloc(int i)
 	blk_queue_max_discard_sectors(brd->brd_queue, UINT_MAX);
 	brd->brd_queue->limits.discard_zeroes_data = 1;
 	queue_flag_set_unlocked(QUEUE_FLAG_DISCARD, brd->brd_queue);
+	queue_flag_set_unlocked(QUEUE_FLAG_NONROT, brd->brd_queue);
 #ifdef CONFIG_BLK_DEV_RAM_DAX
 	queue_flag_set_unlocked(QUEUE_FLAG_DAX, brd->brd_queue);
 #endif
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
