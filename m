Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 75BA76B0074
	for <linux-mm@kvack.org>; Sat, 22 Nov 2014 23:51:35 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id ft15so7705716pdb.8
        for <linux-mm@kvack.org>; Sat, 22 Nov 2014 20:51:35 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id yo5si15417532pbb.166.2014.11.22.20.51.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 22 Nov 2014 20:51:34 -0800 (PST)
Received: from fsav303.sakura.ne.jp (fsav303.sakura.ne.jp [153.120.85.134])
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id sAN4pVU4081029
	for <linux-mm@kvack.org>; Sun, 23 Nov 2014 13:51:31 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from AQUA (KD175108057186.ppp-bb.dion.ne.jp [175.108.57.186])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id sAN4pVVX081026
	for <linux-mm@kvack.org>; Sun, 23 Nov 2014 13:51:31 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Subject: [PATCH 3/5] mm: Remember ongoing memory allocation status.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201411231349.CAG78628.VFQFOtOSFJMOLH@I-love.SAKURA.ne.jp>
In-Reply-To: <201411231349.CAG78628.VFQFOtOSFJMOLH@I-love.SAKURA.ne.jp>
Message-Id: <201411231351.HJA17065.VHQSFOJFtLFOMO@I-love.SAKURA.ne.jp>
Date: Sun, 23 Nov 2014 13:51:31 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

>From 0c6d4e0ac9fc5964fdd09849c99e4f6497b7a37e Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sun, 23 Nov 2014 13:40:20 +0900
Subject: [PATCH 3/5] mm: Remember ongoing memory allocation status.

When a stall by memory allocation problem occurs, printing how long
a thread was blocked for memory allocation will be useful.

This patch allows remembering how many jiffies was spent for ongoing
__alloc_pages_nodemask() and reading it by printing backtrace and by
analyzing vmcore.

If the system is rebooted by timeout of SoftDog watchdog, this patch
will be helpful because we can check whether the thread writing to
/dev/watchdog interface was blocked for memory allocation.

If the system is running on a QEMU (KVM) managed via libvirt interface,
this patch will be helpful because we can check status of ongoing
memory allocation by comparing several vmcore snapshots obtained
via "virsh dump" command.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/sched.h |  3 +++
 kernel/sched/core.c   | 17 +++++++++++++++++
 mm/page_alloc.c       | 20 ++++++++++++++++++--
 3 files changed, 38 insertions(+), 2 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index f1626c3..83ac0c2 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1663,6 +1663,9 @@ struct task_struct {
 #endif
 	/* Set when TIF_MEMDIE flag is set to this thread. */
 	unsigned long memdie_start;
+	/* Set when outermost memory allocation starts. */
+	unsigned long gfp_start;
+	gfp_t gfp_flags;
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 24beb9b..f8d0192 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -4518,6 +4518,22 @@ out_unlock:
 	return retval;
 }
 
+static void print_memalloc_info(const struct task_struct *p)
+{
+	const gfp_t gfp = p->gfp_flags;
+
+	/*
+	 * __alloc_pages_nodemask() doesn't use smp_wmb() between
+	 * updating ->gfp_start and ->gfp_flags. But reading stale
+	 * ->gfp_start value harms nothing but printing bogus duration.
+	 * Correct duration will be printed when this function is
+	 * called for the next time.
+	 */
+	if (unlikely(gfp))
+		printk(KERN_INFO "MemAlloc: %ld jiffies on 0x%x\n",
+			jiffies - p->gfp_start, gfp);
+}
+
 static const char stat_nam[] = TASK_STATE_TO_CHAR_STR;
 
 void sched_show_task(struct task_struct *p)
@@ -4550,6 +4566,7 @@ void sched_show_task(struct task_struct *p)
 		task_pid_nr(p), ppid,
 		(unsigned long)task_thread_info(p)->flags);
 
+	print_memalloc_info(p);
 	print_worker_info(KERN_INFO, p);
 	show_stack(p, NULL);
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 616a2c9..11cc37d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2790,6 +2790,18 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	unsigned int cpuset_mems_cookie;
 	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
 	int classzone_idx;
+	const bool omit_timestamp = !(gfp_mask & __GFP_WAIT) ||
+		current->gfp_flags;
+
+	if (!omit_timestamp) {
+		/*
+		 * Since omit_timestamp == false depends on
+		 * (gfp_mask & __GFP_WAIT) != 0 , the current->gfp_flags is
+		 * updated from zero to non-zero value.
+		 */
+		current->gfp_start = jiffies;
+		current->gfp_flags = gfp_mask;
+	}
 
 	gfp_mask &= gfp_allowed_mask;
 
@@ -2798,7 +2810,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	might_sleep_if(gfp_mask & __GFP_WAIT);
 
 	if (should_fail_alloc_page(gfp_mask, order))
-		return NULL;
+		goto nopage;
 
 	/*
 	 * Check the zones suitable for the gfp_mask contain at least one
@@ -2806,7 +2818,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	 * of GFP_THISNODE and a memoryless node
 	 */
 	if (unlikely(!zonelist->_zonerefs->zone))
-		return NULL;
+		goto nopage;
 
 	if (IS_ENABLED(CONFIG_CMA) && migratetype == MIGRATE_MOVABLE)
 		alloc_flags |= ALLOC_CMA;
@@ -2850,6 +2862,10 @@ out:
 	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
 		goto retry_cpuset;
 
+nopage:
+	if (!omit_timestamp)
+		current->gfp_flags = 0;
+
 	return page;
 }
 EXPORT_SYMBOL(__alloc_pages_nodemask);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
