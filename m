Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 982C16B00B7
	for <linux-mm@kvack.org>; Sun,  2 Dec 2012 13:45:11 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so1476612eek.14
        for <linux-mm@kvack.org>; Sun, 02 Dec 2012 10:45:11 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 34/52] sched: Average the fault stats longer
Date: Sun,  2 Dec 2012 19:43:26 +0100
Message-Id: <1354473824-19229-35-git-send-email-mingo@kernel.org>
In-Reply-To: <1354473824-19229-1-git-send-email-mingo@kernel.org>
References: <1354473824-19229-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

We will rely on the per CPU fault statistics and its
shared/private derivative even more in the future, so
stabilize this metric even better.

The staged updates introduced in commit:

   sched: Introduce staged average NUMA faults

Already stabilized this key metric significantly, but in
real workloads it was still reacting to temporary load
balancing transients too quickly.

Slow down by weighting the average. The weighting value was
found via experimentation.

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 kernel/sched/fair.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 24a5588..a5f3ad7 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -914,8 +914,8 @@ static void task_numa_placement(struct task_struct *p)
 			p->numa_faults_curr[idx] = 0;
 
 			/* Keep a simple running average: */
-			p->numa_faults[idx] += new_faults;
-			p->numa_faults[idx] /= 2;
+			p->numa_faults[idx] = p->numa_faults[idx]*7 + new_faults;
+			p->numa_faults[idx] /= 8;
 
 			faults += p->numa_faults[idx];
 			total[priv] += p->numa_faults[idx];
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
