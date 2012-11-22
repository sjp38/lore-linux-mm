Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id D14E48D001B
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 17:51:54 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so3216535eaa.14
        for <linux-mm@kvack.org>; Thu, 22 Nov 2012 14:51:54 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 32/33] sched: Add hysteresis to p->numa_shared
Date: Thu, 22 Nov 2012 23:49:53 +0100
Message-Id: <1353624594-1118-33-git-send-email-mingo@kernel.org>
In-Reply-To: <1353624594-1118-1-git-send-email-mingo@kernel.org>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

Make p->numa_shared flip/flop less around unstable equilibriums,
instead require a significant move in either direction to trigger
'dominantly shared accesses' versus 'dominantly private accesses'
NUMA status.

Suggested-by: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 kernel/sched/fair.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 8aa4b36..ab4a7130 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1111,7 +1111,20 @@ static void task_numa_placement(struct task_struct *p)
 	 * we might want to consider a different equation below to reduce
 	 * the impact of a little private memory accesses.
 	 */
-	shared = (total[0] >= total[1] / 2);
+	shared = p->numa_shared;
+
+	if (shared < 0) {
+		shared = (total[0] >= total[1]);
+	} else if (shared == 0) {
+		/* If it was private before, make it harder to become shared: */
+		if (total[0] >= total[1]*2)
+			shared = 1;
+	} else if (shared == 1 ) {
+		 /* If it was shared before, make it harder to become private: */
+		if (total[0]*2 <= total[1])
+			shared = 0;
+	}
+
 	if (shared)
 		p->ideal_cpu = sched_update_ideal_cpu_shared(p);
 	else
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
