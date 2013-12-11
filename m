Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f46.google.com (mail-oa0-f46.google.com [209.85.219.46])
	by kanga.kvack.org (Postfix) with ESMTP id 62A3D6B003B
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 05:16:38 -0500 (EST)
Received: by mail-oa0-f46.google.com with SMTP id o6so6952405oag.5
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 02:16:38 -0800 (PST)
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com. [122.248.162.6])
        by mx.google.com with ESMTPS id dw2si12983054obb.57.2013.12.11.02.16.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 02:16:37 -0800 (PST)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 11 Dec 2013 15:46:23 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 78F95E0058
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 15:48:40 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBBAGEk953215276
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 15:46:15 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBBAGJFH031970
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 15:46:19 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v6 5/6] sched/numa: use wrapper function task_faults_idx to calculate index in group_faults
Date: Wed, 11 Dec 2013 18:16:00 +0800
Message-Id: <1386756961-3887-6-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1386756961-3887-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386756961-3887-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Use wrapper function task_faults_idx to calculate index in group_faults.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 kernel/sched/fair.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index c3f6ff9..8a00879 100644
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
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
