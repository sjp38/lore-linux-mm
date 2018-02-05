Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1ED506B0003
	for <linux-mm@kvack.org>; Mon,  5 Feb 2018 17:03:37 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id e4so27022354qtb.14
        for <linux-mm@kvack.org>; Mon, 05 Feb 2018 14:03:37 -0800 (PST)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id k34sor797728qtk.6.2018.02.05.14.03.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Feb 2018 14:03:36 -0800 (PST)
MIME-Version: 1.0
Date: Mon,  5 Feb 2018 14:03:25 -0800
Message-Id: <20180205220325.197241-1-dancol@google.com>
Subject: [PATCH] Synchronize task mm counters on context switch
From: Daniel Colascione <dancol@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Daniel Colascione <dancol@google.com>

When SPLIT_RSS_COUNTING is in use (which it is on SMP systems,
generally speaking), we buffer certain changes to mm-wide counters
through counters local to the current struct task, flushing them to
the mm after seeing 64 page faults, as well as on task exit and
exec. This scheme can leave a large amount of memory unaccounted-for
in process memory counters, especially for processes with many threads
(each of which gets 64 "free" faults), and it produces an
inconsistency with the same memory counters scanned VMA-by-VMA using
smaps. This inconsistency can persist for an arbitrarily long time,
since there is no way to force a task to flush its counters to its mm.

This patch flushes counters on context switch. This way, we bound the
amount of unaccounted memory without forcing tasks to flush to the
mm-wide counters on each minor page fault. The flush operation should
be cheap: we only have a few counters, adjacent in struct task, and we
don't atomically write to the mm counters unless we've changed
something since the last flush.

Signed-off-by: Daniel Colascione <dancol@google.com>
---
 kernel/sched/core.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index a7bf32aabfda..7f197a7698ee 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -3429,6 +3429,9 @@ asmlinkage __visible void __sched schedule(void)
 	struct task_struct *tsk = current;
 
 	sched_submit_work(tsk);
+	if (tsk->mm)
+		sync_mm_rss(tsk->mm);
+
 	do {
 		preempt_disable();
 		__schedule(false);
-- 
2.16.0.rc1.238.g530d649a79-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
