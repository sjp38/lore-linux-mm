Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 212286B038A
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 05:18:11 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v66so31274195wrc.4
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 02:18:11 -0700 (PDT)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id d22si19013492wmd.50.2017.03.21.02.18.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 02:18:09 -0700 (PDT)
Received: by mail-wm0-x22f.google.com with SMTP id n11so7508943wma.0
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 02:18:09 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH] fault-inject: use correct check for interrupts
Date: Tue, 21 Mar 2017 10:18:05 +0100
Message-Id: <20170321091805.140676-1-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akinobu.mita@gmail.com, akpm@linux-foundation.org
Cc: Dmitry Vyukov <dvyukov@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

in_interrupt() also returns true when bh is disabled in task context.
That's not what fail_task() wants to check.
Use the new in_task() predicate that does the right thing.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: akinobu.mita@gmail.com
Cc: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

---

Andrew, do you mind taking this to mm?
---
 lib/fault-inject.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/fault-inject.c b/lib/fault-inject.c
index 6a823a53e357..4ff157159a0d 100644
--- a/lib/fault-inject.c
+++ b/lib/fault-inject.c
@@ -56,7 +56,7 @@ static void fail_dump(struct fault_attr *attr)
 
 static bool fail_task(struct fault_attr *attr, struct task_struct *task)
 {
-	return !in_interrupt() && task->make_it_fail;
+	return in_task() && task->make_it_fail;
 }
 
 #define MAX_STACK_TRACE_DEPTH 32
-- 
2.12.1.500.gab5fba24ee-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
