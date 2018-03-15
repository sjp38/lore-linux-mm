Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 71BA96B0005
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 06:35:10 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id k4-v6so3000619pls.15
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 03:35:10 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id j11si3612578pfi.57.2018.03.15.03.35.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 03:35:09 -0700 (PDT)
From: Vinayak Menon <vinmenon@codeaurora.org>
Subject: [PATCH] mm: fix low-high watermark distance on small systems
Date: Thu, 15 Mar 2018 16:04:39 +0530
Message-Id: <1521110079-26870-1-git-send-email-vinmenon@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mgorman@techsingularity.net, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, sfr@canb.auug.org.au, pasha.tatashin@oracle.com, penguin-kernel@I-love.SAKURA.ne.jp, Vinayak Menon <vinmenon@codeaurora.org>

It is observed that watermark_scale_factor when used to reduce
thundering herds in direct reclaim, reduces the direct reclaims,
but results in unnecessary reclaim due to kswapd running for long
after being woken up. The tests are done with 4 GB of RAM and the
tests done are multibuild and another which opens a set of apps
sequentially on Android and repeating the sequence N times. The
tests are done on 4.9 kernel.

The issue is caused by watermark_scale_factor creating larger than
required gap between low and high watermarks. The following results
are with watermark_scale_factor of 120.

                       wsf-120-default  wsf-120-reduced-low-high-gap
workingset_activate    15120206         8319182
pgpgin                 269795482        147928581
allocstall             1406             1498
pgsteal_kswapd         68676960         38105142
slabs_scanned          94181738         49085755

Even though kswapd does 80% more steal in the default case, it doesn't
make any significant improvement to the direct reclaims. The excessive
reclaims cause more pgpgin and increases app launch latencies.

The min-low gap is untouched by the patch. The low-high gap is made
a percentage of min-low gap. The fraction was derived considering
these,

1) The existing watermark_scale_factor logic was designed to fix
issues on high RAM machines and I assume that the current low-high
gap works well on those.
2) The gap should be reduced on low RAM targets where thrashing is
observed.

The multiplier 4 was chosen empirically which was seen to fix the
thrashing on <8GB devices.

With watermark_scale_factor as default 10, the low-high gap for different
memory sizes.
           default-low_high_gap-pages  this-patch-low_high_gap-pages
16M        4                           4
512M       131                         131
1024M      262                         256
2048M      524                         362
4096M      1048                        512
8192M      2097                        724
16384M     4194                        1717
32768M     8388                        4858
65536M     16777                       13743
102400M    26214                       26214
143360M    36700                       36700

Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
---
 mm/page_alloc.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c0f0b1b..ac75985 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7223,7 +7223,20 @@ static void __setup_per_zone_wmarks(void)
 				      watermark_scale_factor, 10000));
 
 		zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + tmp;
-		zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + tmp * 2;
+
+		/*
+		 * Set the kswapd low-high distance as a percentage of
+		 * min-low distance in such a way that the distance
+		 * increases non-linearly with available memory. This
+		 * ensures enough free memory without causing thrashing
+		 * on small machines due to excessive reclaim by kswapd.
+		 * Ensure a minimum distance on very small machines.
+		 */
+		tmp = clamp_t(u64, mult_frac(tmp,
+				int_sqrt(4 * zone->managed_pages), 10000),
+					min_wmark_pages(zone) >> 2, tmp);
+
+		zone->watermark[WMARK_HIGH] = low_wmark_pages(zone) + tmp;
 
 		spin_unlock_irqrestore(&zone->lock, flags);
 	}
-- 
QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation
