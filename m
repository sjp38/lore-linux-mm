Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 47C026B0037
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:49:22 -0400 (EDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 30 Jul 2013 01:49:21 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 0B69719D803E
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 01:49:07 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6U7nIIB351614
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 01:49:18 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6U7nHd5021665
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 01:49:18 -0600
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: [RFC PATCH 04/10] sched: Move active_load_balance_cpu_stop to a new helper function
Date: Tue, 30 Jul 2013 13:18:19 +0530
Message-Id: <1375170505-5967-5-git-send-email-srikar@linux.vnet.ibm.com>
In-Reply-To: <1375170505-5967-1-git-send-email-srikar@linux.vnet.ibm.com>
References: <1375170505-5967-1-git-send-email-srikar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Preeti U Murthy <preeti@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>

Due to the way active_load_balance_cpu gets called and the parameters
passed to it, the active_load_balance_cpu_stop call gets split into
multiple lines. Instead move it into a separate helper function.

this is a cleanup change. No functional changes.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 kernel/sched/fair.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 8fcbf96..debb75a 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -5103,6 +5103,12 @@ static int need_active_balance(struct lb_env *env)
 
 static int active_load_balance_cpu_stop(void *data);
 
+static void active_load_balance(struct rq *rq)
+{
+	stop_one_cpu_nowait(cpu_of(rq), active_load_balance_cpu_stop, rq,
+			&rq->active_balance_work);
+}
+
 /*
  * Check this_cpu to ensure it is balanced within domain. Attempt to move
  * tasks if there is an imbalance.
@@ -5290,11 +5296,8 @@ static int load_balance(int this_cpu, struct rq *this_rq,
 			}
 			raw_spin_unlock_irqrestore(&busiest->lock, flags);
 
-			if (active_balance) {
-				stop_one_cpu_nowait(cpu_of(busiest),
-					active_load_balance_cpu_stop, busiest,
-					&busiest->active_balance_work);
-			}
+			if (active_balance)
+				active_load_balance(busiest);
 
 			/*
 			 * We've kicked active balancing, reset the failure
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
