Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id AE0E46B20BB
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 17:36:52 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id q35-v6so1412031lfi.1
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 14:36:52 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id k16-v6si6243740ljh.387.2018.08.21.14.36.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 14:36:51 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH v2 3/3] mm: don't miss the last page because of round-off error
Date: Tue, 21 Aug 2018 14:35:59 -0700
Message-ID: <20180821213559.14694-3-guro@fb.com>
In-Reply-To: <20180821213559.14694-1-guro@fb.com>
References: <20180821213559.14694-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kernel-team@fb.com, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <willy@infradead.org>

I've noticed, that dying memory cgroups are  often pinned
in memory by a single pagecache page. Even under moderate
memory pressure they sometimes stayed in such state
for a long time. That looked strange.

My investigation showed that the problem is caused by
applying the LRU pressure balancing math:

  scan = div64_u64(scan * fraction[lru], denominator),

where

  denominator = fraction[anon] + fraction[file] + 1.

Because fraction[lru] is always less than denominator,
if the initial scan size is 1, the result is always 0.

This means the last page is not scanned and has
no chances to be reclaimed.

Fix this by rounding up the result of the division.

In practice this change significantly improves the speed
of dying cgroups reclaim.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Rik van Riel <riel@surriel.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>
---
 include/linux/math64.h | 2 ++
 mm/vmscan.c            | 6 ++++--
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/linux/math64.h b/include/linux/math64.h
index 837f2f2d1d34..94af3d9c73e7 100644
--- a/include/linux/math64.h
+++ b/include/linux/math64.h
@@ -281,4 +281,6 @@ static inline u64 mul_u64_u32_div(u64 a, u32 mul, u32 divisor)
 }
 #endif /* mul_u64_u32_div */
 
+#define DIV64_U64_ROUND_UP(ll, d)	div64_u64((ll) + (d) - 1, (d))
+
 #endif /* _LINUX_MATH64_H */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4375b1e9bd56..2d78c5cff15e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2445,9 +2445,11 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 			/*
 			 * Scan types proportional to swappiness and
 			 * their relative recent reclaim efficiency.
+			 * Make sure we don't miss the last page
+			 * because of a round-off error.
 			 */
-			scan = div64_u64(scan * fraction[file],
-					 denominator);
+			scan = DIV64_U64_ROUND_UP(scan * fraction[file],
+						  denominator);
 			break;
 		case SCAN_FILE:
 		case SCAN_ANON:
-- 
2.17.1
