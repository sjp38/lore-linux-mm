Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id D154F6B0035
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 17:12:58 -0500 (EST)
Received: by mail-qa0-f51.google.com with SMTP id f11so24068665qae.24
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 14:12:58 -0800 (PST)
Received: from shelob.surriel.com (shelob.surriel.com. [2002:4a5c:3b41:1:216:3eff:fe57:7f4])
        by mx.google.com with ESMTPS id mq7si4969696qcb.114.2014.02.18.14.12.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 14:12:58 -0800 (PST)
From: riel@redhat.com
Subject: [PATCH -mm 1/3] sched,numa: add cond_resched to task_numa_work
Date: Tue, 18 Feb 2014 17:12:44 -0500
Message-Id: <1392761566-24834-2-git-send-email-riel@redhat.com>
In-Reply-To: <1392761566-24834-1-git-send-email-riel@redhat.com>
References: <1392761566-24834-1-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, chegu_vinod@hp.com, aarcange@redhat.com, akpm@linux-foundation.org

From: Rik van Riel <riel@redhat.com>

Normally task_numa_work scans over a fairly small amount of memory,
but it is possible to run into a large unpopulated part of virtual
memory, with no pages mapped. In that case, task_numa_work can run
for a while, and it may make sense to reschedule as required.

Signed-off-by: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Reported-by: Xing Gang <gang.xing@hp.com>
Tested-by: Chegu Vinod <chegu_vinod@hp.com>
---
 kernel/sched/fair.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 966cc2b..7815709 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1757,6 +1757,8 @@ void task_numa_work(struct callback_head *work)
 			start = end;
 			if (pages <= 0)
 				goto out;
+
+			cond_resched();
 		} while (end != vma->vm_end);
 	}
 
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
