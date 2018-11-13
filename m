Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8DD526B028E
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 00:52:23 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id g63-v6so9569614pfc.9
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 21:52:23 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 185-v6si14322704pff.77.2018.11.12.21.52.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 21:52:22 -0800 (PST)
From: Sasha Levin <sashal@kernel.org>
Subject: [PATCH AUTOSEL 4.14 25/26] mm: don't miss the last page because of round-off error
Date: Tue, 13 Nov 2018 00:51:49 -0500
Message-Id: <20181113055150.78773-25-sashal@kernel.org>
In-Reply-To: <20181113055150.78773-1-sashal@kernel.org>
References: <20181113055150.78773-1-sashal@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stable@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Sasha Levin <sashal@kernel.org>, linux-mm@kvack.org

From: Roman Gushchin <guro@fb.com>

[ Upstream commit 68600f623d69da428c6163275f97ca126e1a8ec5 ]

I've noticed, that dying memory cgroups are often pinned in memory by a
single pagecache page.  Even under moderate memory pressure they sometimes
stayed in such state for a long time.  That looked strange.

My investigation showed that the problem is caused by applying the LRU
pressure balancing math:

  scan = div64_u64(scan * fraction[lru], denominator),

where

  denominator = fraction[anon] + fraction[file] + 1.

Because fraction[lru] is always less than denominator, if the initial scan
size is 1, the result is always 0.

This means the last page is not scanned and has
no chances to be reclaimed.

Fix this by rounding up the result of the division.

In practice this change significantly improves the speed of dying cgroups
reclaim.

[guro@fb.com: prevent double calculation of DIV64_U64_ROUND_UP() arguments]
  Link: http://lkml.kernel.org/r/20180829213311.GA13501@castle
Link: http://lkml.kernel.org/r/20180827162621.30187-3-guro@fb.com
Signed-off-by: Roman Gushchin <guro@fb.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Rik van Riel <riel@surriel.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 include/linux/math64.h | 3 +++
 mm/vmscan.c            | 6 ++++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/math64.h b/include/linux/math64.h
index 082de345b73c..3a7a14062668 100644
--- a/include/linux/math64.h
+++ b/include/linux/math64.h
@@ -254,4 +254,7 @@ static inline u64 mul_u64_u32_div(u64 a, u32 mul, u32 divisor)
 }
 #endif /* mul_u64_u32_div */
 
+#define DIV64_U64_ROUND_UP(ll, d)	\
+	({ u64 _tmp = (d); div64_u64((ll) + _tmp - 1, _tmp); })
+
 #endif /* _LINUX_MATH64_H */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index be56e2e1931e..9734e62654fa 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2367,9 +2367,11 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
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
