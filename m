Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7A80A82F6C
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 08:26:57 -0500 (EST)
Received: by wmvv187 with SMTP id v187so278176719wmv.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 05:26:57 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ci12si3947677wjb.148.2015.11.18.05.26.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Nov 2015 05:26:56 -0800 (PST)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v3 12/22] kthread: Use try_lock_kthread_work() in flush_kthread_work()
Date: Wed, 18 Nov 2015 14:25:17 +0100
Message-Id: <1447853127-3461-13-git-send-email-pmladek@suse.com>
In-Reply-To: <1447853127-3461-1-git-send-email-pmladek@suse.com>
References: <1447853127-3461-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

Remove code duplication and use the new try_lock_kthread_work()
function in flush_kthread_work() as well.

Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 kernel/kthread.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/kernel/kthread.c b/kernel/kthread.c
index dbd090466e2a..f7caaaca5825 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -933,16 +933,12 @@ void flush_kthread_work(struct kthread_work *work)
 	struct kthread_worker *worker;
 	bool noop = false;
 
-retry:
-	worker = work->worker;
-	if (!worker)
+	local_irq_disable();
+	if (!try_lock_kthread_work(work)) {
+		local_irq_enable();
 		return;
-
-	spin_lock_irq(&worker->lock);
-	if (work->worker != worker) {
-		spin_unlock_irq(&worker->lock);
-		goto retry;
 	}
+	worker = work->worker;
 
 	if (!list_empty(&work->node))
 		insert_kthread_work(worker, &fwork.work, work->node.next);
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
