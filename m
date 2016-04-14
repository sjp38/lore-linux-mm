Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D74C5828DF
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 11:15:52 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a125so55194214wmd.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 08:15:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m197si35281884wmd.77.2016.04.14.08.15.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Apr 2016 08:15:51 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v6 19/20] thermal/intel_powerclamp: Remove duplicated code that starts the kthread
Date: Thu, 14 Apr 2016 17:14:38 +0200
Message-Id: <1460646879-617-20-git-send-email-pmladek@suse.com>
In-Reply-To: <1460646879-617-1-git-send-email-pmladek@suse.com>
References: <1460646879-617-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>, Zhang Rui <rui.zhang@intel.com>, Eduardo Valentin <edubezval@gmail.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, linux-pm@vger.kernel.org

This patch removes a code duplication. It does not modify
the functionality.

Signed-off-by: Petr Mladek <pmladek@suse.com>
CC: Zhang Rui <rui.zhang@intel.com>
CC: Eduardo Valentin <edubezval@gmail.com>
CC: Jacob Pan <jacob.jun.pan@linux.intel.com>
CC: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
CC: linux-pm@vger.kernel.org
Acked-by: Jacob Pan <jacob.jun.pan@linux.intel.com>
---
 drivers/thermal/intel_powerclamp.c | 45 +++++++++++++++++---------------------
 1 file changed, 20 insertions(+), 25 deletions(-)

diff --git a/drivers/thermal/intel_powerclamp.c b/drivers/thermal/intel_powerclamp.c
index 6c79588251d5..cb32c38f9828 100644
--- a/drivers/thermal/intel_powerclamp.c
+++ b/drivers/thermal/intel_powerclamp.c
@@ -505,10 +505,27 @@ static void poll_pkg_cstate(struct work_struct *dummy)
 		schedule_delayed_work(&poll_pkg_cstate_work, HZ);
 }
 
+static void start_power_clamp_thread(unsigned long cpu)
+{
+	struct task_struct **p = per_cpu_ptr(powerclamp_thread, cpu);
+	struct task_struct *thread;
+
+	thread = kthread_create_on_node(clamp_thread,
+					(void *) cpu,
+					cpu_to_node(cpu),
+					"kidle_inject/%ld", cpu);
+	if (IS_ERR(thread))
+		return;
+
+	/* bind to cpu here */
+	kthread_bind(thread, cpu);
+	wake_up_process(thread);
+	*p = thread;
+}
+
 static int start_power_clamp(void)
 {
 	unsigned long cpu;
-	struct task_struct *thread;
 
 	/* check if pkg cstate counter is completely 0, abort in this case */
 	if (!has_pkg_state_counter()) {
@@ -530,20 +547,7 @@ static int start_power_clamp(void)
 
 	/* start one thread per online cpu */
 	for_each_online_cpu(cpu) {
-		struct task_struct **p =
-			per_cpu_ptr(powerclamp_thread, cpu);
-
-		thread = kthread_create_on_node(clamp_thread,
-						(void *) cpu,
-						cpu_to_node(cpu),
-						"kidle_inject/%ld", cpu);
-		/* bind to cpu here */
-		if (likely(!IS_ERR(thread))) {
-			kthread_bind(thread, cpu);
-			wake_up_process(thread);
-			*p = thread;
-		}
-
+		start_power_clamp_thread(cpu);
 	}
 	put_online_cpus();
 
@@ -575,7 +579,6 @@ static int powerclamp_cpu_callback(struct notifier_block *nfb,
 				unsigned long action, void *hcpu)
 {
 	unsigned long cpu = (unsigned long)hcpu;
-	struct task_struct *thread;
 	struct task_struct **percpu_thread =
 		per_cpu_ptr(powerclamp_thread, cpu);
 
@@ -584,15 +587,7 @@ static int powerclamp_cpu_callback(struct notifier_block *nfb,
 
 	switch (action) {
 	case CPU_ONLINE:
-		thread = kthread_create_on_node(clamp_thread,
-						(void *) cpu,
-						cpu_to_node(cpu),
-						"kidle_inject/%lu", cpu);
-		if (likely(!IS_ERR(thread))) {
-			kthread_bind(thread, cpu);
-			wake_up_process(thread);
-			*percpu_thread = thread;
-		}
+		start_power_clamp_thread(cpu);
 		/* prefer BSP as controlling CPU */
 		if (cpu == 0) {
 			control_cpu = 0;
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
