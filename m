Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 773036B0037
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 19:12:37 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id e14so12456313iej.0
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 16:12:37 -0800 (PST)
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com. [122.248.162.2])
        by mx.google.com with ESMTPS id qz9si14907219pab.46.2013.12.11.16.12.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 16:12:36 -0800 (PST)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 12 Dec 2013 05:42:33 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 637061258053
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 05:43:41 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBC0CQdd46661808
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 05:42:26 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBC0CVsf018280
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 05:42:31 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v7 3/4] sched/numa: use wrapper function task_faults_idx to calculate index in group_faults
Date: Thu, 12 Dec 2013 08:12:22 +0800
Message-Id: <1386807143-15994-4-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1386807143-15994-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386807143-15994-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Use wrapper function task_faults_idx to calculate index in group_faults.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 kernel/sched/fair.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 178eaac..d93c86f 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -935,7 +935,8 @@ static inline unsigned long group_faults(struct task_struct *p, int nid)
 	if (!p->numa_group)
 		return 0;
 
-	return p->numa_group->faults[2*nid] + p->numa_group->faults[2*nid+1];
+	return p->numa_group->faults[task_faults_idx(nid, 0)] +
+		p->numa_group->faults[task_faults_idx(nid, 1)];
 }
 
 /*
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
