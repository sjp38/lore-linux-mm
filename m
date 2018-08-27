Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5A4E86B4169
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 12:27:37 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id l7-v6so16032753qte.2
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 09:27:37 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id s17-v6si2943309qke.302.2018.08.27.09.27.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Aug 2018 09:27:36 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH v3 3/3] mm: don't miss the last page because of round-off error
Date: Mon, 27 Aug 2018 09:26:21 -0700
Message-ID: <20180827162621.30187-3-guro@fb.com>
In-Reply-To: <20180827162621.30187-1-guro@fb.com>
References: <20180827162621.30187-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kernel-team@fb.com, Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <willy@infradead.org>

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
index d649b242b989..2c67a0121c6d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2446,9 +2446,11 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
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
