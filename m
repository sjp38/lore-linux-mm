Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4E38F6B0282
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 11:17:35 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id l23-v6so16120811qtp.1
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 08:17:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m20-v6sor7870356qvm.25.2018.08.01.08.17.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 08:17:34 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 7/9] sched: introduce this_rq_lock_irq()
Date: Wed,  1 Aug 2018 11:19:56 -0400
Message-Id: <20180801151958.32590-8-hannes@cmpxchg.org>
In-Reply-To: <20180801151958.32590-1-hannes@cmpxchg.org>
References: <20180801151958.32590-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, Peter Enderborg <peter.enderborg@sony.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

do_sched_yield() disables IRQs, looks up this_rq() and locks it. The
next patch is adding another site with the same pattern, so provide a
convenience function for it.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 kernel/sched/core.c  |  4 +---
 kernel/sched/sched.h | 12 ++++++++++++
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 211890edf37e..9586a8141f16 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -4960,9 +4960,7 @@ static void do_sched_yield(void)
 	struct rq_flags rf;
 	struct rq *rq;
 
-	local_irq_disable();
-	rq = this_rq();
-	rq_lock(rq, &rf);
+	rq = this_rq_lock_irq(&rf);
 
 	schedstat_inc(rq->yld_count);
 	current->sched_class->yield_task(rq);
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index b8f038497240..bc798c7cb4d4 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -1119,6 +1119,18 @@ rq_unlock(struct rq *rq, struct rq_flags *rf)
 	raw_spin_unlock(&rq->lock);
 }
 
+static inline struct rq *
+this_rq_lock_irq(struct rq_flags *rf)
+	__acquires(rq->lock)
+{
+	struct rq *rq;
+
+	local_irq_disable();
+	rq = this_rq();
+	rq_lock(rq, rf);
+	return rq;
+}
+
 #ifdef CONFIG_NUMA
 enum numa_topology_type {
 	NUMA_DIRECT,
-- 
2.18.0
