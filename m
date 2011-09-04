Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8A2FC6B018B
	for <linux-mm@kvack.org>; Sat,  3 Sep 2011 22:13:28 -0400 (EDT)
Message-Id: <20110904020916.588150387@intel.com>
Date: Sun, 04 Sep 2011 09:53:20 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 15/18] writeback: charge leaked page dirties to active tasks
References: <20110904015305.367445271@intel.com>
Content-Disposition: inline; filename=writeback-save-leaks-at-exit.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

It's a years long problem that a large number of short-lived dirtiers
(eg. gcc instances in a fast kernel build) may starve long-run dirtiers
(eg. dd) as well as pushing the dirty pages to the global hard limit.

The solution is to charge the pages dirtied by the exited gcc to the
other random gcc/dd instances. It sounds not perfect, however should
behave good enough in practice.

CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/writeback.h |    2 ++
 kernel/exit.c             |    2 ++
 mm/page-writeback.c       |   12 ++++++++++++
 3 files changed, 16 insertions(+)

--- linux-next.orig/include/linux/writeback.h	2011-08-29 19:14:22.000000000 +0800
+++ linux-next/include/linux/writeback.h	2011-08-29 19:14:32.000000000 +0800
@@ -7,6 +7,8 @@
 #include <linux/sched.h>
 #include <linux/fs.h>
 
+DECLARE_PER_CPU(int, dirty_leaks);
+
 /*
  * The 1/4 region under the global dirty thresh is for smooth dirty throttling:
  *
--- linux-next.orig/mm/page-writeback.c	2011-08-29 19:14:22.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-08-29 19:14:32.000000000 +0800
@@ -1237,6 +1237,7 @@ void set_page_dirty_balance(struct page 
 }
 
 static DEFINE_PER_CPU(int, bdp_ratelimits);
+DEFINE_PER_CPU(int, dirty_leaks) = 0;
 
 /**
  * balance_dirty_pages_ratelimited_nr - balance dirty memory state
@@ -1285,6 +1286,17 @@ void balance_dirty_pages_ratelimited_nr(
 			ratelimit = 0;
 		}
 	}
+	/*
+	 * Pick up the dirtied pages by the exited tasks. This avoids lots of
+	 * short-lived tasks (eg. gcc invocations in a kernel build) escaping
+	 * the dirty throttling and livelock other long-run dirtiers.
+	 */
+	p = &__get_cpu_var(dirty_leaks);
+	if (*p > 0 && current->nr_dirtied < ratelimit) {
+		nr_pages_dirtied = min(*p, ratelimit - current->nr_dirtied);
+		*p -= nr_pages_dirtied;
+		current->nr_dirtied += nr_pages_dirtied;
+	}
 	preempt_enable();
 
 	if (unlikely(current->nr_dirtied >= ratelimit))
--- linux-next.orig/kernel/exit.c	2011-08-26 16:19:27.000000000 +0800
+++ linux-next/kernel/exit.c	2011-08-29 19:14:22.000000000 +0800
@@ -1044,6 +1044,8 @@ NORET_TYPE void do_exit(long code)
 	validate_creds_for_do_exit(tsk);
 
 	preempt_disable();
+	if (tsk->nr_dirtied)
+		__this_cpu_add(dirty_leaks, tsk->nr_dirtied);
 	exit_rcu();
 	/* causes final put_task_struct in finish_task_switch(). */
 	tsk->state = TASK_DEAD;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
