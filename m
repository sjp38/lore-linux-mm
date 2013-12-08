Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7FE836B003D
	for <linux-mm@kvack.org>; Sun,  8 Dec 2013 01:15:22 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id wm4so2503210obc.0
        for <linux-mm@kvack.org>; Sat, 07 Dec 2013 22:15:22 -0800 (PST)
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com. [122.248.162.1])
        by mx.google.com with ESMTPS id sy1si3300218obc.90.2013.12.07.22.15.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 07 Dec 2013 22:15:21 -0800 (PST)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 8 Dec 2013 11:45:17 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id CB266E0053
	for <linux-mm@kvack.org>; Sun,  8 Dec 2013 11:47:31 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB86F4vK32178254
	for <linux-mm@kvack.org>; Sun, 8 Dec 2013 11:45:04 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rB86FDYr018979
	for <linux-mm@kvack.org>; Sun, 8 Dec 2013 11:45:13 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v3 09/12] sched/numa: fix task scan rate adjustment
Date: Sun,  8 Dec 2013 14:14:50 +0800
Message-Id: <1386483293-15354-9-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1386483293-15354-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386483293-15354-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

commit 04bb2f947 (sched/numa: Adjust scan rate in task_numa_placement) calculate
period_slot which should be used as base value of scan rate increase if remote
access dominate. However, current codes forget to use it, this patch fix it.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 kernel/sched/fair.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 7073c76..b077f1b3 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1358,7 +1358,7 @@ static void update_task_scan_period(struct task_struct *p,
 		 */
 		period_slot = DIV_ROUND_UP(diff, NUMA_PERIOD_SLOTS);
 		ratio = DIV_ROUND_UP(private * NUMA_PERIOD_SLOTS, (private + shared));
-		diff = (diff * ratio) / NUMA_PERIOD_SLOTS;
+		diff = (period_slot * ratio) / NUMA_PERIOD_SLOTS;
 	}
 
 	p->numa_scan_period = clamp(p->numa_scan_period + diff,
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
