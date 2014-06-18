Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id C67386B0039
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 04:23:32 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id n15so7132428wiw.10
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 01:23:32 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lm9si1770626wic.98.2014.06.18.01.23.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Jun 2014 01:23:30 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/4] cfq: Increase default value of target_latency
Date: Wed, 18 Jun 2014 09:23:24 +0100
Message-Id: <1403079807-24690-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1403079807-24690-1-git-send-email-mgorman@suse.de>
References: <1403079807-24690-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>, Mel Gorman <mgorman@suse.de>

The existing CFQ default target_latency results in very poor performance
for larger numbers of threads doing sequential reads.  While this can be
easily described as a tuning problem for users, it is one that is tricky
to detect. This patch the default on the assumption that people with access
to expensive fast storage also know how to tune their IO scheduler.

The following is from tiobench run on a mid-range desktop with a single
spinning disk.

                                      3.16.0-rc1            3.16.0-rc1                 3.0.0
                                         vanilla          cfq600                     vanilla
Mean   SeqRead-MB/sec-1         121.88 (  0.00%)      121.60 ( -0.23%)      134.59 ( 10.42%)
Mean   SeqRead-MB/sec-2         101.99 (  0.00%)      102.35 (  0.36%)      122.59 ( 20.20%)
Mean   SeqRead-MB/sec-4          97.42 (  0.00%)       99.71 (  2.35%)      114.78 ( 17.82%)
Mean   SeqRead-MB/sec-8          83.39 (  0.00%)       90.39 (  8.39%)      100.14 ( 20.09%)
Mean   SeqRead-MB/sec-16         68.90 (  0.00%)       77.29 ( 12.18%)       81.64 ( 18.50%)

As expected, the performance increases for larger number of threads although
still far short of 3.0-vanilla.  A concern with a patch like this is that
it would hurt IO latencies but the iostat figures still look reasonable

                  3.16.0-rc1  3.16.0-rc1       3.0.0
                     vanilla   cfq600        vanilla
Mean sda-avgqz        912.29      939.89     1000.70
Mean sda-await       4268.03     4403.99     4887.67
Mean sda-r_await       79.42       80.33      108.53
Mean sda-w_await    13073.49    11038.81    11599.83
Max  sda-avgqz       2194.84     2215.01     2626.78
Max  sda-await      18157.88    17586.08    24971.00
Max  sda-r_await      888.40      874.22     5308.00
Max  sda-w_await   212563.59   190265.33   177698.47

Average read waiting times are barely changed and still short of the
3.0-vanilla kresult. The worst-case read wait times are also acceptable
and far better than 3.0.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 block/cfq-iosched.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index cadc378..34b9d8b 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -32,7 +32,7 @@ static int cfq_slice_async = HZ / 25;
 static const int cfq_slice_async_rq = 2;
 static int cfq_slice_idle = HZ / 125;
 static int cfq_group_idle = HZ / 125;
-static const int cfq_target_latency = HZ * 3/10; /* 300 ms */
+static const int cfq_target_latency = HZ * 6/10; /* 600 ms */
 static const int cfq_hist_divisor = 4;
 
 /*
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
