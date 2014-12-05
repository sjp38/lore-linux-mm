Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 58AB16B0074
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 11:41:57 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id h11so1969424wiw.15
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 08:41:57 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g15si3133340wiw.78.2014.12.05.08.41.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Dec 2014 08:41:54 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH -v2 3/5] PM: convert printk to pr_* equivalent
Date: Fri,  5 Dec 2014 17:41:45 +0100
Message-Id: <1417797707-31699-4-git-send-email-mhocko@suse.cz>
In-Reply-To: <1417797707-31699-1-git-send-email-mhocko@suse.cz>
References: <20141110163055.GC18373@dhcp22.suse.cz>
 <1417797707-31699-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

While touching this area let's convert printk to pr_*. This also makes
the printing of continuation lines done properly.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 kernel/power/process.c | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/kernel/power/process.c b/kernel/power/process.c
index 5a6ec8678b9a..3ac45f192e9f 100644
--- a/kernel/power/process.c
+++ b/kernel/power/process.c
@@ -84,8 +84,8 @@ static int try_to_freeze_tasks(bool user_only)
 	elapsed_msecs = elapsed_msecs64;
 
 	if (todo) {
-		printk("\n");
-		printk(KERN_ERR "Freezing of tasks %s after %d.%03d seconds "
+		pr_cont("\n");
+		pr_err("Freezing of tasks %s after %d.%03d seconds "
 		       "(%d tasks refusing to freeze, wq_busy=%d):\n",
 		       wakeup ? "aborted" : "failed",
 		       elapsed_msecs / 1000, elapsed_msecs % 1000,
@@ -101,7 +101,7 @@ static int try_to_freeze_tasks(bool user_only)
 			read_unlock(&tasklist_lock);
 		}
 	} else {
-		printk("(elapsed %d.%03d seconds) ", elapsed_msecs / 1000,
+		pr_cont("(elapsed %d.%03d seconds) ", elapsed_msecs / 1000,
 			elapsed_msecs % 1000);
 	}
 
@@ -155,7 +155,7 @@ int freeze_processes(void)
 		atomic_inc(&system_freezing_cnt);
 
 	pm_wakeup_clear();
-	printk("Freezing user space processes ... ");
+	pr_info("Freezing user space processes ... ");
 	pm_freezing = true;
 	oom_kills_saved = oom_kills_count();
 	error = try_to_freeze_tasks(true);
@@ -171,13 +171,13 @@ int freeze_processes(void)
 		if (oom_kills_count() != oom_kills_saved &&
 		    !check_frozen_processes()) {
 			__usermodehelper_set_disable_depth(UMH_ENABLED);
-			printk("OOM in progress.");
+			pr_cont("OOM in progress.");
 			error = -EBUSY;
 		} else {
-			printk("done.");
+			pr_cont("done.");
 		}
 	}
-	printk("\n");
+	pr_cont("\n");
 	BUG_ON(in_atomic());
 
 	if (error)
@@ -197,13 +197,14 @@ int freeze_kernel_threads(void)
 {
 	int error;
 
-	printk("Freezing remaining freezable tasks ... ");
+	pr_info("Freezing remaining freezable tasks ... ");
+
 	pm_nosig_freezing = true;
 	error = try_to_freeze_tasks(false);
 	if (!error)
-		printk("done.");
+		pr_cont("done.");
 
-	printk("\n");
+	pr_cont("\n");
 	BUG_ON(in_atomic());
 
 	if (error)
@@ -224,7 +225,7 @@ void thaw_processes(void)
 
 	oom_killer_enable();
 
-	printk("Restarting tasks ... ");
+	pr_info("Restarting tasks ... ");
 
 	__usermodehelper_set_disable_depth(UMH_FREEZING);
 	thaw_workqueues();
@@ -243,7 +244,7 @@ void thaw_processes(void)
 	usermodehelper_enable();
 
 	schedule();
-	printk("done.\n");
+	pr_cont("done.\n");
 	trace_suspend_resume(TPS("thaw_processes"), 0, false);
 }
 
@@ -252,7 +253,7 @@ void thaw_kernel_threads(void)
 	struct task_struct *g, *p;
 
 	pm_nosig_freezing = false;
-	printk("Restarting kernel threads ... ");
+	pr_info("Restarting kernel threads ... ");
 
 	thaw_workqueues();
 
@@ -264,5 +265,5 @@ void thaw_kernel_threads(void)
 	read_unlock(&tasklist_lock);
 
 	schedule();
-	printk("done.\n");
+	pr_cont("done.\n");
 }
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
