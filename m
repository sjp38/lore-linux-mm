Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id B3B888308C
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 08:58:23 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 33so12043413lfw.1
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 05:58:23 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id v132si29919499wma.120.2016.08.18.05.58.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Aug 2016 05:58:21 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 05/16] mm: writeback: Convert to hotplug state machine
Date: Thu, 18 Aug 2016 14:57:20 +0200
Message-Id: <20160818125731.27256-6-bigeasy@linutronix.de>
In-Reply-To: <20160818125731.27256-1-bigeasy@linutronix.de>
References: <20160818125731.27256-1-bigeasy@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, rt@linutronix.de, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Tejun Heo <tj@kernel.org>, Jens Axboe <axboe@fb.com>, linux-mm@kvack.org

Install the callbacks via the state machine and let the core invoke
the callbacks on the already online CPUs.

Cc: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@fb.com>
Cc: linux-mm@kvack.org
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 include/linux/cpuhotplug.h |  1 +
 mm/page-writeback.c        | 26 +++++++-------------------
 2 files changed, 8 insertions(+), 19 deletions(-)

diff --git a/include/linux/cpuhotplug.h b/include/linux/cpuhotplug.h
index 82ee32107dff..854e59a426d4 100644
--- a/include/linux/cpuhotplug.h
+++ b/include/linux/cpuhotplug.h
@@ -16,6 +16,7 @@ enum cpuhp_state {
 	CPUHP_X86_APB_DEAD,
 	CPUHP_VIRT_NET_DEAD,
 	CPUHP_SLUB_DEAD,
+	CPUHP_MM_WRITEBACK_DEAD,
 	CPUHP_WORKQUEUE_PREP,
 	CPUHP_POWER_NUMA_PREPARE,
 	CPUHP_HRTIMERS_PREPARE,
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 82e72524db55..6d3d0e87f309 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2050,26 +2050,12 @@ void writeback_set_ratelimit(void)
 		ratelimit_pages = 16;
 }
 
-static int
-ratelimit_handler(struct notifier_block *self, unsigned long action,
-		  void *hcpu)
+static int page_writeback_cpu_online(unsigned int cpu)
 {
-
-	switch (action & ~CPU_TASKS_FROZEN) {
-	case CPU_ONLINE:
-	case CPU_DEAD:
-		writeback_set_ratelimit();
-		return NOTIFY_OK;
-	default:
-		return NOTIFY_DONE;
-	}
+	writeback_set_ratelimit();
+	return 0;
 }
 
-static struct notifier_block ratelimit_nb = {
-	.notifier_call	= ratelimit_handler,
-	.next		= NULL,
-};
-
 /*
  * Called early on to tune the page writeback dirty limits.
  *
@@ -2092,8 +2078,10 @@ void __init page_writeback_init(void)
 {
 	BUG_ON(wb_domain_init(&global_wb_domain, GFP_KERNEL));
 
-	writeback_set_ratelimit();
-	register_cpu_notifier(&ratelimit_nb);
+	cpuhp_setup_state(CPUHP_AP_ONLINE_DYN, "MM_WRITEBACK_ONLINE",
+			  page_writeback_cpu_online, NULL);
+	cpuhp_setup_state(CPUHP_MM_WRITEBACK_DEAD, "MM_WRITEBACK_DEAD", NULL,
+			  page_writeback_cpu_online);
 }
 
 /**
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
