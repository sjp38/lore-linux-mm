Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6BE956B003C
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 19:50:25 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id uo5so8834751pbc.39
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 16:50:25 -0800 (PST)
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com. [122.248.162.9])
        by mx.google.com with ESMTPS id yd9si11849328pab.205.2013.12.10.16.50.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 16:50:24 -0800 (PST)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 11 Dec 2013 06:20:21 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 59EE33940023
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 06:20:18 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBB0oFdE44630158
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 06:20:15 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBB0oHdT030747
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 06:20:18 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v5 7/8] sched/numa: fix record hinting faults check
Date: Wed, 11 Dec 2013 08:50:00 +0800
Message-Id: <1386723001-25408-8-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1386723001-25408-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386723001-25408-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Adjust numa_scan_period in task_numa_placement, depending on how much useful
work the numa code can do. The local faults and remote faults should be used
to check if there is record hinting faults instead of local faults and shared
faults. This patch fix it.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 kernel/sched/fair.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index ac5f1e7..f507e12 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1326,7 +1326,7 @@ static void update_task_scan_period(struct task_struct *p,
 	 * completely idle or all activity is areas that are not of interest
 	 * to automatic numa balancing. Scan slower
 	 */
-	if (local + shared == 0) {
+	if (local + remote == 0) {
 		p->numa_scan_period = min(p->numa_scan_period_max,
 			p->numa_scan_period << 1);
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
