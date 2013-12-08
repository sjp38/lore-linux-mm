Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7BA266B0035
	for <linux-mm@kvack.org>; Sun,  8 Dec 2013 01:25:37 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id q10so3290870pdj.22
        for <linux-mm@kvack.org>; Sat, 07 Dec 2013 22:25:37 -0800 (PST)
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com. [122.248.162.9])
        by mx.google.com with ESMTPS id ya10si3411976pab.8.2013.12.07.22.25.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 07 Dec 2013 22:25:36 -0800 (PST)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 8 Dec 2013 11:55:32 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 831FF1258051
	for <linux-mm@kvack.org>; Sun,  8 Dec 2013 11:56:37 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB86OYrl34209826
	for <linux-mm@kvack.org>; Sun, 8 Dec 2013 11:55:27 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rB86FGFb016874
	for <linux-mm@kvack.org>; Sun, 8 Dec 2013 11:45:17 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v3 11/12] sched/numa: drop unnecessary variable in task_weight
Date: Sun,  8 Dec 2013 14:14:52 +0800
Message-Id: <1386483293-15354-11-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1386483293-15354-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386483293-15354-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Drop unnecessary total_faults variable in function task_weight to unify
task_weight and group_weight.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 kernel/sched/fair.c |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 942e67b..df8b677 100644
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
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
