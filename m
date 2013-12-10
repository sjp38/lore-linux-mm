Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id ADFB46B00A2
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 04:20:02 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id un15so7257777pbc.13
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 01:20:02 -0800 (PST)
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com. [202.81.31.143])
        by mx.google.com with ESMTPS id d2si9906991pba.121.2013.12.10.01.19.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 01:20:01 -0800 (PST)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 10 Dec 2013 19:19:57 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 447C13578023
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 20:19:55 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBA91Z4A7733652
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 20:01:35 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBA9Js1V027244
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 20:19:54 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v4 10/12] sched/numa: fix record hinting faults check
Date: Tue, 10 Dec 2013 17:19:33 +0800
Message-Id: <1386667175-19952-10-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1386667175-19952-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386667175-19952-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

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
index 90b9b88..d51b8c3 100644
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
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
