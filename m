Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id C319B6B0072
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 07:53:48 -0400 (EDT)
Received: by mail-yh0-f47.google.com with SMTP id v1so237039yhn.34
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 04:53:48 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r62si21288634yhc.123.2014.06.09.04.53.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Jun 2014 04:53:47 -0700 (PDT)
Subject: Re: [PATCH] mm/vmscan: Do not block forever at shrink_inactive_list().
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201405202358.ADF10119.SMOFOQLFtOVHJF@I-love.SAKURA.ne.jp>
	<6B2BA408B38BA1478B473C31C3D2074E31D59D8673@SV-EXCHANGE1.Corp.FC.LOCAL>
	<201405262045.CDG95893.HLFFOSFMQOVOJt@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.02.1406031442170.19491@chino.kir.corp.google.com>
	<201406052145.CIB35534.OQLVMSJFOHtFOF@I-love.SAKURA.ne.jp>
In-Reply-To: <201406052145.CIB35534.OQLVMSJFOHtFOF@I-love.SAKURA.ne.jp>
Message-Id: <201406092053.AAD56799.FOOSLFHQJMVOtF@I-love.SAKURA.ne.jp>
Date: Mon, 9 Jun 2014 20:53:06 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com
Cc: rientjes@google.com, Motohiro.Kosaki@us.fujitsu.com, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, fengguang.wu@intel.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Tetsuo Handa wrote:
> We need some more changes. I'm thinking memory allocation watchdog thread.
> Add an "unsigned long" field to "struct task_struct", set jiffies to the field
> upon entry of GFP_WAIT-able memory allocation attempts, and clear the field
> upon returning from GFP_WAIT-able memory allocation attempts. A kernel thread
> periodically scans task list and compares the field and jiffies, and (at least)
> print warning messages (maybe optionally trigger OOM-killer or kernel panic)
> if single memory allocation attempt is taking too long (e.g. 60 seconds).
> What do you think?
> 
Here is a demo patch. If you can join analysis of why memory allocation
function cannot return for more than 15 minutes under severe memory pressure,
I'll invite you to private discussion in order to share steps for reproducing
such memory pressure. A quick test says that memory reclaiming functions are
too optimistic about reclaiming memory; they are needlessly called again and
again and again with an assumption that some memory will be reclaimed within
a few seconds. If I insert some delay, CPU usage during stalls can be reduced.
----------
>From 015fecd45761b2849974f37dc379edf3e86acfa6 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Mon, 9 Jun 2014 15:00:47 +0900
Subject: [PATCH] mm: Add memory allocation watchdog kernel thread.

When a certain type of memory pressure is given, the system may stall
for many minutes trying to allocate memory pages. But stalling without
any messages is annoying because (e.g.) timeout will happen without
any prior warning messages.

This patch introduces a watchdog thread which periodically reports the
longest stalling thread if __alloc_pages_nodemask() is taking more than
10 seconds. An example output from a VM with 4 CPU / 2GB RAM (without swap)
running a v3.15 kernel with this patch is shown below.

  [ 5835.136868] INFO: task pcscd:14569 blocked for 11 seconds at memory allocation
  [ 5845.137932] INFO: task pcscd:14569 blocked for 21 seconds at memory allocation
  [ 5855.142985] INFO: task pcscd:14569 blocked for 31 seconds at memory allocation
  (...snipped...)
  [ 6710.227984] INFO: task pcscd:14569 blocked for 886 seconds at memory allocation
  [ 6720.228058] INFO: task pcscd:14569 blocked for 896 seconds at memory allocation
  [ 6730.231108] INFO: task pcscd:14569 blocked for 906 seconds at memory allocation
  [ 6740.242185] INFO: task pcscd:14569 blocked for 916 seconds at memory allocation

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/sched.h |  1 +
 mm/page_alloc.c       | 61 ++++++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 59 insertions(+), 3 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 221b2bd..befd496 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1610,6 +1610,7 @@ struct task_struct {
 	unsigned int	sequential_io;
 	unsigned int	sequential_io_avg;
 #endif
+	unsigned long memory_allocation_start_jiffies;
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5dba293..211b0b7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -61,6 +61,7 @@
 #include <linux/page-debug-flags.h>
 #include <linux/hugetlb.h>
 #include <linux/sched/rt.h>
+#include <linux/kthread.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -2698,6 +2699,16 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	unsigned int cpuset_mems_cookie;
 	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
 	struct mem_cgroup *memcg = NULL;
+	bool memory_allocation_recursion = false;
+	unsigned long *stamp = &current->memory_allocation_start_jiffies;
+
+	if (likely(!*stamp)) {
+		*stamp = jiffies;
+		if (unlikely(!*stamp))
+			(*stamp)++;
+	} else {
+		memory_allocation_recursion = true;
+	}
 
 	gfp_mask &= gfp_allowed_mask;
 
@@ -2706,7 +2717,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	might_sleep_if(gfp_mask & __GFP_WAIT);
 
 	if (should_fail_alloc_page(gfp_mask, order))
-		return NULL;
+		goto nopage;
 
 	/*
 	 * Check the zones suitable for the gfp_mask contain at least one
@@ -2714,14 +2725,14 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	 * of GFP_THISNODE and a memoryless node
 	 */
 	if (unlikely(!zonelist->_zonerefs->zone))
-		return NULL;
+		goto nopage;
 
 	/*
 	 * Will only have any effect when __GFP_KMEMCG is set.  This is
 	 * verified in the (always inline) callee
 	 */
 	if (!memcg_kmem_newpage_charge(gfp_mask, &memcg, order))
-		return NULL;
+		goto nopage;
 
 retry_cpuset:
 	cpuset_mems_cookie = read_mems_allowed_begin();
@@ -2784,10 +2795,54 @@ out:
 
 	memcg_kmem_commit_charge(page, memcg, order);
 
+nopage:
+	if (likely(!memory_allocation_recursion))
+		current->memory_allocation_start_jiffies = 0;
 	return page;
 }
 EXPORT_SYMBOL(__alloc_pages_nodemask);
 
+static int alloc_pages_watchdog_thread(void *unused)
+{
+	while (1) {
+		const unsigned long now = jiffies;
+		unsigned long min_stamp = 0;
+		struct task_struct *p;
+		struct task_struct *t;
+		char comm[TASK_COMM_LEN];
+		pid_t pid = 0;
+
+		rcu_read_lock();
+		for_each_process_thread(p, t) {
+			const unsigned long stamp =
+				t->memory_allocation_start_jiffies;
+			if (likely(!stamp ||
+				   time_after(stamp + 10 * HZ, now)))
+				continue;
+			if (!pid || time_after(min_stamp, stamp)) {
+				min_stamp = stamp;
+				memcpy(comm, t->comm, TASK_COMM_LEN);
+				pid = task_pid_nr(t);
+			}
+		}
+		rcu_read_unlock();
+		if (pid)
+			pr_warn("INFO: task %s:%u blocked for %lu seconds at memory allocation\n",
+				comm, pid, (now - min_stamp) / HZ);
+		schedule_timeout_killable(10 * HZ);
+	}
+	return 0;
+}
+
+static int __init alloc_pages_watchdog_init(void)
+{
+	struct task_struct *p = kthread_run(alloc_pages_watchdog_thread, NULL,
+					    "alloc-watchdog");
+	BUG_ON(IS_ERR(p));
+	return 0;
+}
+late_initcall(alloc_pages_watchdog_init);
+
 /*
  * Common helper functions.
  */
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
