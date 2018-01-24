Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7D0FF800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 10:55:44 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id s22so3315504pfh.21
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 07:55:44 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id u8-v6si393405plm.229.2018.01.24.07.55.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 07:55:43 -0800 (PST)
From: Vinayak Menon <vinmenon@codeaurora.org>
Subject: [RFC] kswapd aggressiveness with watermark_scale_factor
Message-ID: <7d57222b-42f5-06a2-2f91-75384e0c0bd9@codeaurora.org>
Date: Wed, 24 Jan 2018 21:25:37 +0530
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: hannes@cmpxchg.org, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "vbabka@suse.cz" <vbabka@suse.cz>

Hi,

It is observed that watermark_scale_factor when used to reduce thundering herds
in direct reclaim, reduces the direct reclaims, but results in unnecessary reclaim
due to kswapd running for long after being woken up. The tests are done with 4 GB
of RAM and the tests done are multibuild and another which opens a set of apps
sequentially on Android and repeating the sequence N times. The tests are done on
4.9 kernel.

The issue seems to be because of watermark_scale_factor creating larger gap between
low and high watermarks. The following results are with watermark_scale_factor of 120
and the other with watermark_scale_factor 120 with a reduced gap between low and
high watermarks. The patch used to reduce the gap is given below. The min-low gap is
untouched. It can be seen that with the reduced low-high gap, the direct reclaims are
almost same as base, but with 45% less pgpgin. Reduced low-high gap improves the
latency by around 11% in the sequential app test due to lesser IO and kswapd activity.

A A A A A A A A A A A A A A A A A A A A A A  wsf-120-defaultA A A A A  wsf-120-reduced-low-high-gap
workingset_activateA A A  15120206A A A A A A A A A A A A  8319182
pgpginA A A A A A A A A A A A A A A A  269795482A A A A A A A A A A A  147928581
allocstallA A A A A A A A A A A A  1406A A A A A A A A A A A A A A A A  1498
pgsteal_kswapdA A A A A A A A  68676960A A A A A A A A A A A A  38105142
slabs_scannedA A A A A A A A A  94181738A A A A A A A A A A A A  49085755

This is the diff of wsf-120-reduced-low-high-gap for comments. The patch considers
low-high gap as a fraction of min-low gap, and the fraction a function of managed pages,
increasing non-linearly. The multiplier 4 is was chosen as a reasonable value which does
not alter the low-high gap much from the base for large machines.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3a11a50..749d1eb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6898,7 +6898,11 @@ static void __setup_per_zone_wmarks(void)
A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  watermark_scale_factor, 10000));

A A A A A A A A A A A A A A A  zone->watermark[WMARK_LOW]A  = min_wmark_pages(zone) + tmp;
-A A A A A A A A A A A A A A  zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + tmp * 2;
+
+A A A A A A A A A A A A A A  tmp = clamp_t(u64, mult_frac(tmp, int_sqrt(4 * zone->managed_pages),
+A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  10000), min_wmark_pages(zone) >> 2 , tmp);
+
+A A A A A A A A A A A A A A  zone->watermark[WMARK_HIGH] = low_wmark_pages(zone) + tmp;

A A A A A A A A A A A A A A A  spin_unlock_irqrestore(&zone->lock, flags);
A A A A A A A  }

With the patch,
With watermark_scale_factor as default 10, the low-high gap:
unchanged for 140G at 143M,
for 65G, reduces from 65M to 53M
for 4GB, reduces from 4M to 1M

With watermark_scale_factor 120, the low-high gap:
unchanged for 140G
for 65G, reduces from 786M to 644M
for 4GB, reduces from 49M to 10M

Thanks,
Vinayak

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
