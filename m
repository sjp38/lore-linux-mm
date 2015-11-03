Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id C926082F64
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 21:32:20 -0500 (EST)
Received: by obbza9 with SMTP id za9so2479447obb.1
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 18:32:20 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f19si13461253oig.64.2015.11.02.18.32.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Nov 2015 18:32:19 -0800 (PST)
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable() checks
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <alpine.DEB.2.20.1510220939310.23718@east.gentwo.org>
	<20151022151414.GF30579@mtj.duckdns.org>
	<20151023042649.GB18907@mtj.duckdns.org>
	<20151102150137.GB3442@dhcp22.suse.cz>
	<20151102192053.GC9553@mtj.duckdns.org>
In-Reply-To: <20151102192053.GC9553@mtj.duckdns.org>
Message-Id: <201511031132.GBB09374.JQFOVSFLOtHFMO@I-love.SAKURA.ne.jp>
Date: Tue, 3 Nov 2015 11:32:06 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: htejun@gmail.com, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

Tejun Heo wrote:
>                                                                  If
> the possibility of sysrq getting stuck behind concurrency management
> is an issue, queueing them on an unbound or highpri workqueue should
> be good enough.

Regarding SysRq-f, we could do like below. Though I think that converting
the OOM killer into a dedicated kernel thread would allow more things to do
(e.g. Oleg's memory zapping code, my timeout based next victim selection).

diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
index 5381a72..46b951aa 100644
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -47,6 +47,7 @@
 #include <linux/syscalls.h>
 #include <linux/of.h>
 #include <linux/rcupdate.h>
+#include <linux/kthread.h>
 
 #include <asm/ptrace.h>
 #include <asm/irq_regs.h>
@@ -351,27 +352,35 @@ static struct sysrq_key_op sysrq_term_op = {
 	.enable_mask	= SYSRQ_ENABLE_SIGNAL,
 };
 
-static void moom_callback(struct work_struct *ignored)
+static DECLARE_WAIT_QUEUE_HEAD(moom_wait);
+
+static int moom_callback(void *unused)
 {
 	const gfp_t gfp_mask = GFP_KERNEL;
-	struct oom_control oc = {
-		.zonelist = node_zonelist(first_memory_node, gfp_mask),
-		.nodemask = NULL,
-		.gfp_mask = gfp_mask,
-		.order = -1,
-	};
-
-	mutex_lock(&oom_lock);
-	if (!out_of_memory(&oc))
-		pr_info("OOM request ignored because killer is disabled\n");
-	mutex_unlock(&oom_lock);
+	DEFINE_WAIT(wait);
+
+	while (1) {
+		struct oom_control oc = {
+			.zonelist = node_zonelist(first_memory_node, gfp_mask),
+			.nodemask = NULL,
+			.gfp_mask = gfp_mask,
+			.order = -1,
+		};
+
+		prepare_to_wait(&moom_wait, &wait, TASK_INTERRUPTIBLE);
+		schedule();
+		finish_wait(&moom_wait, &wait);
+		mutex_lock(&oom_lock);
+		if (!out_of_memory(&oc))
+			pr_info("OOM request ignored because killer is disabled\n");
+		mutex_unlock(&oom_lock);
+	}
+	return 0;
 }
 
-static DECLARE_WORK(moom_work, moom_callback);
-
 static void sysrq_handle_moom(int key)
 {
-	schedule_work(&moom_work);
+	wake_up(&moom_wait);
 }
 static struct sysrq_key_op sysrq_moom_op = {
 	.handler	= sysrq_handle_moom,
@@ -1116,6 +1125,9 @@ static inline void sysrq_init_procfs(void)
 
 static int __init sysrq_init(void)
 {
+	struct task_struct *task = kthread_run(moom_callback, NULL,
+					       "manual_oom");
+	BUG_ON(IS_ERR(task));
 	sysrq_init_procfs();
 
 	if (sysrq_on())

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
