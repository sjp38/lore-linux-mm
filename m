Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f45.google.com (mail-oa0-f45.google.com [209.85.219.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3C1976B0044
	for <linux-mm@kvack.org>; Sun,  8 Dec 2013 01:15:23 -0500 (EST)
Received: by mail-oa0-f45.google.com with SMTP id o6so2581656oag.18
        for <linux-mm@kvack.org>; Sat, 07 Dec 2013 22:15:23 -0800 (PST)
Received: from e28smtp08.in.ibm.com (e28smtp08.in.ibm.com. [122.248.162.8])
        by mx.google.com with ESMTPS id n6si3317898oeq.30.2013.12.07.22.15.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 07 Dec 2013 22:15:22 -0800 (PST)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 8 Dec 2013 11:45:18 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 5479E3940023
	for <linux-mm@kvack.org>; Sun,  8 Dec 2013 11:45:16 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB86FDXk55050256
	for <linux-mm@kvack.org>; Sun, 8 Dec 2013 11:45:13 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rB86FFM9019096
	for <linux-mm@kvack.org>; Sun, 8 Dec 2013 11:45:15 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v3 10/12] sched/numa: fix record hinting faults check
Date: Sun,  8 Dec 2013 14:14:51 +0800
Message-Id: <1386483293-15354-10-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1386483293-15354-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386483293-15354-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Adjust numa_scan_period in task_numa_placement, depending on how much useful
work the numa code can do. The local faults and remote faults should be used
to check if there is record hinting faults instead of local faults and shared
faults. This patch fix it.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 kernel/sched/fair.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index b077f1b3..942e67b 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1322,7 +1322,7 @@ static void update_task_scan_period(struct task_struct *p,
 	 * completely idle or all activity is areas that are not of interest
 	 * to automatic numa balancing. Scan slower
 	 */
-	if (local + shared == 0) {
+	if (local + remote == 0) {
 		p->numa_scan_period = min(p->numa_scan_period_max,
 			p->numa_scan_period << 1);
 
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
