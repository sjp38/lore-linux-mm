Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9465D8E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 07:53:37 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id z10so35109614edz.15
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 04:53:37 -0800 (PST)
Received: from outbound-smtp25.blacknight.com (outbound-smtp25.blacknight.com. [81.17.249.193])
        by mx.google.com with ESMTPS id i46si3118602eda.288.2019.01.04.04.53.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 04:53:36 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp25.blacknight.com (Postfix) with ESMTPS id D7616B87A3
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 12:53:35 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 19/25] mm, compaction: Do not consider a need to reschedule as contention
Date: Fri,  4 Jan 2019 12:50:05 +0000
Message-Id: <20190104125011.16071-20-mgorman@techsingularity.net>
In-Reply-To: <20190104125011.16071-1-mgorman@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Scanning on large machines can take a considerable length of time and
eventually need to be rescheduled. This is treated as an abort event but
that's not appropriate as the attempt is likely to be retried after making
numerous checks and taking another cycle through the page allocator.
This patch will check the need to reschedule if necessary but continue
the scanning.

The main benefit is reduced scanning when compaction is taking a long time
or the machine is over-saturated. It also avoids an unnecessary exit of
compaction that ends up being retried by the page allocator in the outer
loop.

                                        4.20.0                 4.20.0
                              synccached-v2r15        noresched-v2r15
Amean     fault-both-3      2655.55 (   0.00%)     2736.50 (  -3.05%)
Amean     fault-both-5      4580.67 (   0.00%)     4133.70 (   9.76%)
Amean     fault-both-7      5740.50 (   0.00%)     5738.61 (   0.03%)
Amean     fault-both-12     9237.55 (   0.00%)     9392.82 (  -1.68%)
Amean     fault-both-18    12899.51 (   0.00%)    13257.15 (  -2.77%)
Amean     fault-both-24    16342.47 (   0.00%)    16859.44 (  -3.16%)
Amean     fault-both-30    20394.26 (   0.00%)    16249.30 *  20.32%*
Amean     fault-both-32    17450.76 (   0.00%)    14904.71 *  14.59%*

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/compaction.c | 12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 1a41a2dbff24..75eb0d40d4d7 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -398,19 +398,11 @@ static bool compact_lock_irqsave(spinlock_t *lock, unsigned long *flags,
 	return true;
 }
 
-/*
- * Aside from avoiding lock contention, compaction also periodically checks
- * need_resched() and records async compaction as contended if necessary.
- */
+/* Avoid soft-lockups due to long scan times */
 static inline void compact_check_resched(struct compact_control *cc)
 {
-	/* async compaction aborts if contended */
-	if (need_resched()) {
-		if (cc->mode == MIGRATE_ASYNC)
-			cc->contended = true;
-
+	if (need_resched())
 		cond_resched();
-	}
 }
 
 /*
-- 
2.16.4
