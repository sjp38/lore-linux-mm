Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id D9D526B006E
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 14:46:24 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id z10so1519351pdj.29
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 11:46:24 -0700 (PDT)
Received: from relay.sgi.com (relay1.sgi.com. [192.48.180.66])
        by mx.google.com with ESMTP id dk3si2330986pbd.43.2014.10.23.11.46.23
        for <linux-mm@kvack.org>;
        Thu, 23 Oct 2014 11:46:23 -0700 (PDT)
From: Alex Thorlton <athorlton@sgi.com>
Subject: [PATCH 2/4] Add pgcollapse controls to task_struct
Date: Thu, 23 Oct 2014 13:46:01 -0500
Message-Id: <1414089963-73165-3-git-send-email-athorlton@sgi.com>
In-Reply-To: <1414089963-73165-1-git-send-email-athorlton@sgi.com>
References: <1414089963-73165-1-git-send-email-athorlton@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Alex Thorlton <athorlton@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>, David Rientjes <rientjes@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, Kees Cook <keescook@chromium.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Vladimir Davydov <vdavydov@parallels.com>, linux-kernel@vger.kernel.org

This patch just adds the necessary bits to the task_struct so that the scans can
eventually be controlled on a per-mm basis.  As I mentioned previously, we might
want to add some more counters here.

Signed-off-by: Alex Thorlton <athorlton@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Bob Liu <lliubbo@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org

---
 include/linux/sched.h | 12 ++++++++++++
 kernel/fork.c         |  6 ++++++
 2 files changed, 18 insertions(+)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 5e344bb..50f67d5 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1661,6 +1661,18 @@ struct task_struct {
 	unsigned int	sequential_io;
 	unsigned int	sequential_io_avg;
 #endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	struct callback_head pgcollapse_work;
+	/* default scan 8*512 pte (or vmas) every 30 second */
+	unsigned int pgcollapse_pages_to_scan;
+	unsigned int pgcollapse_pages_collapsed;
+	unsigned int pgcollapse_full_scans;
+	unsigned int pgcollapse_scan_sleep_millisecs;
+	/* during fragmentation poll the hugepage allocator once every minute */
+	unsigned int pgcollapse_alloc_sleep_millisecs;
+	unsigned long pgcollapse_last_scan;
+	unsigned long pgcollapse_scan_address;
+#endif
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
diff --git a/kernel/fork.c b/kernel/fork.c
index 9b7d746..8c55309 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1355,6 +1355,12 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	p->sequential_io	= 0;
 	p->sequential_io_avg	= 0;
 #endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	/* need to pull these values from sysctl or something */
+	p->pgcollapse_pages_to_scan = HPAGE_PMD_NR * 8;
+	p->pgcollapse_scan_sleep_millisecs = 10000;
+	p->pgcollapse_alloc_sleep_millisecs = 60000;
+#endif
 
 	/* Perform scheduler related setup. Assign this task to a CPU. */
 	retval = sched_fork(clone_flags, p);
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
