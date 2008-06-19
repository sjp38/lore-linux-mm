Received: from mlsv7.hitachi.co.jp (unknown [133.144.234.166])
	by mail9.hitachi.co.jp (Postfix) with ESMTP id 4EC1437C92
	for <linux-mm@kvack.org>; Thu, 19 Jun 2008 16:00:11 +0900 (JST)
Message-ID: <485A03E6.2090509@hitachi.com>
Date: Thu, 19 Jun 2008 15:59:50 +0900
From: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>
MIME-Version: 1.0
Subject: [BUG][PATCH -mm] avoid BUG() in __stop_machine_run()
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
In-Reply-To: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, sugita <yumiko.sugita.yf@hitachi.com>, Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>, rusty@rustcorp.com.au
List-ID: <linux-mm.kvack.org>

When a process loads a kernel module, __stop_machine_run() is called, and
it calls sched_setscheduler() to give newly created kernel threads highest
priority.  However, the process can have no CAP_SYS_NICE which required
for sched_setscheduler() to increase the priority.  For example, SystemTap
loads its module with only CAP_SYS_MODULE.  In this case,
sched_setscheduler() returns -EPERM, then BUG() is called.

Failure of sched_setscheduler() wouldn't be a real problem, so this
patch just ignores it.
Or, should we give the CAP_SYS_NICE capability temporarily?

Signed-off-by: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>
---
 kernel/stop_machine.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

Index: linux-2.6.26-rc5-mm3/kernel/stop_machine.c
===================================================================
--- linux-2.6.26-rc5-mm3.orig/kernel/stop_machine.c
+++ linux-2.6.26-rc5-mm3/kernel/stop_machine.c
@@ -143,8 +143,7 @@ int __stop_machine_run(int (*fn)(void *)
 		kthread_bind(threads[i], i);
 
 		/* Make it highest prio. */
-		if (sched_setscheduler(threads[i], SCHED_FIFO, &param) != 0)
-			BUG();
+		sched_setscheduler(threads[i], SCHED_FIFO, &param);
 	}
 
 	/* We've created all the threads.  Wake them all: hold this CPU so one


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
