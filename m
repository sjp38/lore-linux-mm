Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 2BC3F6B00A7
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 04:20:13 -0500 (EST)
Received: by mail-ob0-f180.google.com with SMTP id wo20so5043226obc.11
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 01:20:12 -0800 (PST)
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com. [122.248.162.9])
        by mx.google.com with ESMTPS id sy1si9863081obc.25.2013.12.10.01.20.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 01:20:12 -0800 (PST)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 10 Dec 2013 14:49:58 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 76C7D1258053
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 14:51:05 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBA9JrSk37421262
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 14:49:53 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBA9Jt8I014408
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 14:49:56 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v4 11/12] sched/numa: drop unnecessary variable in task_weight
Date: Tue, 10 Dec 2013 17:19:34 +0800
Message-Id: <1386667175-19952-11-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1386667175-19952-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386667175-19952-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Drop unnecessary total_faults variable in function task_weight to unify
task_weight and group_weight.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 kernel/sched/fair.c |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index d51b8c3..5ff86ec 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -947,17 +947,10 @@ static inline unsigned long group_faults(struct task_struct *p, int nid)
  */
 static inline unsigned long task_weight(struct task_struct *p, int nid)
 {
-	unsigned long total_faults;
-
-	if (!p->numa_faults)
-		return 0;
-
-	total_faults = p->total_numa_faults;
-
-	if (!total_faults)
+	if (!p->numa_faults || !p->total_numa_faults)
 		return 0;
 
-	return 1000 * task_faults(p, nid) / total_faults;
+	return 1000 * task_faults(p, nid) / p->total_numa_faults;
 }
 
 static inline unsigned long group_weight(struct task_struct *p, int nid)
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
