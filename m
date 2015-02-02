Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id C2C926B0032
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 11:55:31 -0500 (EST)
Received: by mail-we0-f180.google.com with SMTP id m14so40223214wev.11
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 08:55:31 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ft7si38145686wjb.169.2015.02.02.08.55.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Feb 2015 08:55:29 -0800 (PST)
Date: Mon, 2 Feb 2015 16:55:25 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: [RFC PATCH] mm: madvise: Ignore repeated MADV_DONTNEED hints
Message-ID: <20150202165525.GM2395@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

glibc malloc changed behaviour in glibc 2.10 to have per-thread arenas
instead of creating new areans if the existing ones were contended.
The decision appears to have been made so the allocator scales better but the
downside is that madvise(MADV_DONTNEED) is now called for these per-thread
areans during free. This tears down pages that would have previously
remained. There is nothing wrong with this decision from a functional point
of view but any threaded application that frequently allocates/frees the
same-sized region is going to incur the full teardown and refault costs.

This is extremely obvious in the ebizzy benchmark. At its core, threads are
frequently freeing and allocating buffers of the same size. It is much faster
on distributions with older versions of glibc. Profiles showed that a large
amount of system CPU time was spent on tearing down and refaulting pages.

This patch identifies when a thread is frequently calling MADV_DONTNEED
on the same region of memory and starts ignoring the hint. On an 8-core
single-socket machine this was the impact on ebizzy using glibc 2.19.

ebizzy Overall Throughput
                            3.19.0-rc6            3.19.0-rc6
                               vanilla          madvise-v1r1
Hmean    Rsec-1     12619.93 (  0.00%)    34807.02 (175.81%)
Hmean    Rsec-3     33434.19 (  0.00%)   100733.77 (201.29%)
Hmean    Rsec-5     45796.68 (  0.00%)   134257.34 (193.16%)
Hmean    Rsec-7     53146.93 (  0.00%)   145512.85 (173.79%)
Hmean    Rsec-12    55132.87 (  0.00%)   145560.86 (164.02%)
Hmean    Rsec-18    54846.52 (  0.00%)   145120.79 (164.59%)
Hmean    Rsec-24    54368.95 (  0.00%)   142733.89 (162.53%)
Hmean    Rsec-30    54388.86 (  0.00%)   141424.09 (160.02%)
Hmean    Rsec-32    54047.11 (  0.00%)   139151.76 (157.46%)

And the system CPU usage was also much reduced

          3.19.0-rc6   3.19.0-rc6
             vanilla madvise-v1r1
User         2647.19      8347.26
System       5742.90        42.42
Elapsed      1350.60      1350.65

It's even more ridiculous on a 4 socket machine

ebizzy Overall Throughput
                             3.19.0-rc6             3.19.0-rc6
                                vanilla           madvise-v1r1
Hmean    Rsec-1       5354.37 (  0.00%)    12838.61 (139.78%)
Hmean    Rsec-4      10338.41 (  0.00%)    50514.52 (388.61%)
Hmean    Rsec-7       7766.33 (  0.00%)    88555.30 (1040.25%)
Hmean    Rsec-12      7188.40 (  0.00%)   154180.78 (2044.86%)
Hmean    Rsec-21      7001.82 (  0.00%)   266555.51 (3706.95%)
Hmean    Rsec-30      8975.08 (  0.00%)   314369.88 (3402.70%)
Hmean    Rsec-48     12136.53 (  0.00%)   358525.74 (2854.10%)
Hmean    Rsec-79     12607.37 (  0.00%)   341646.49 (2609.89%)
Hmean    Rsec-110    12563.37 (  0.00%)   338058.65 (2590.83%)
Hmean    Rsec-141    11701.85 (  0.00%)   331255.78 (2730.80%)
Hmean    Rsec-172    10987.39 (  0.00%)   312003.62 (2739.65%)
Hmean    Rsec-192    12050.46 (  0.00%)   296401.88 (2359.67%)

          3.19.0-rc6   3.19.0-rc6
             vanilla madvise-v1r1
User         4136.44     53506.65
System      50262.68       906.49
Elapsed      1802.07      1801.99

Note in both cases that the elapsed time is similar because the benchmark
is configured to run for a fixed duration.

MADV_FREE would have a lower cost if the underlying allocator used it but
there is no guarantee that allocators will use it. Arguably the kernel
has no business preventing an application developer shooting themselves
in a foot but this is a case where it's relatively easy to detect the bad
behaviour and avoid it.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 fs/exec.c             |  4 ++++
 include/linux/sched.h |  5 +++++
 kernel/fork.c         |  5 +++++
 mm/madvise.c          | 56 +++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 70 insertions(+)

diff --git a/fs/exec.c b/fs/exec.c
index ad8798e26be9..5c691fcc32f4 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1551,6 +1551,10 @@ static int do_execveat_common(int fd, struct filename *filename,
 	current->in_execve = 0;
 	acct_update_integrals(current);
 	task_numa_free(current);
+	if (current->madvise_state) {
+		kfree(current->madvise_state);
+		current->madvise_state = NULL;
+	}
 	free_bprm(bprm);
 	kfree(pathbuf);
 	putname(filename);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 8db31ef98d2f..b6706bdb27fd 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1271,6 +1271,9 @@ enum perf_event_task_context {
 	perf_nr_task_contexts,
 };
 
+/* mm/madvise.c */
+struct madvise_state_info;
+
 struct task_struct {
 	volatile long state;	/* -1 unrunnable, 0 runnable, >0 stopped */
 	void *stack;
@@ -1637,6 +1640,8 @@ struct task_struct {
 
 	struct page_frag task_frag;
 
+	struct madvise_state_info *madvise_state;
+
 #ifdef	CONFIG_TASK_DELAY_ACCT
 	struct task_delay_info *delays;
 #endif
diff --git a/kernel/fork.c b/kernel/fork.c
index 4dc2ddade9f1..6d8dd1379240 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -246,6 +246,11 @@ void __put_task_struct(struct task_struct *tsk)
 	delayacct_tsk_free(tsk);
 	put_signal_struct(tsk->signal);
 
+	if (current->madvise_state) {
+		kfree(current->madvise_state);
+		current->madvise_state = NULL;
+	}
+
 	if (!profile_handoff_task(tsk))
 		free_task(tsk);
 }
diff --git a/mm/madvise.c b/mm/madvise.c
index a271adc93289..907bb0922711 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -19,6 +19,7 @@
 #include <linux/blkdev.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/vmacache.h>
 
 /*
  * Any behaviour which results in changes to the vma->vm_flags needs to
@@ -251,6 +252,57 @@ static long madvise_willneed(struct vm_area_struct *vma,
 	return 0;
 }
 
+#define MADVISE_HASH		VMACACHE_HASH
+#define MADVISE_STATE_SIZE	VMACACHE_SIZE
+#define MADVISE_THRESHOLD	8
+
+struct madvise_state_info {
+	unsigned long start;
+	unsigned long end;
+	int count;
+	unsigned long jiffies;
+};
+
+/* Returns true if userspace is continually dropping the same address range */
+static bool ignore_madvise_hint(unsigned long start, unsigned long end)
+{
+	int i;
+
+	if (!current->madvise_state)
+		current->madvise_state = kzalloc(sizeof(struct madvise_state_info) * MADVISE_STATE_SIZE, GFP_KERNEL);
+	if (!current->madvise_state)
+		return false;
+
+	i = VMACACHE_HASH(start);
+	if (current->madvise_state[i].start != start ||
+	    current->madvise_state[i].end != end) {
+		/* cache miss */
+		current->madvise_state[i].start = start;
+		current->madvise_state[i].end = end;
+		current->madvise_state[i].count = 0;
+		current->madvise_state[i].jiffies = jiffies;
+	} else {
+		/* cache hit */
+		unsigned long reset = current->madvise_state[i].jiffies + HZ;
+		if (time_after(jiffies, reset)) {
+			/*
+			 * If it is a second since the last madvise on this
+			 * range or since madvise hints got ignored then reset
+			 * the counts and apply the hint again.
+			 */
+			current->madvise_state[i].count = 0;
+			current->madvise_state[i].jiffies = jiffies;
+		} else
+			current->madvise_state[i].count++;
+
+		if (current->madvise_state[i].count > MADVISE_THRESHOLD)
+			return true;
+		current->madvise_state[i].jiffies = jiffies;
+	}
+
+	return false;
+}
+
 /*
  * Application no longer needs these pages.  If the pages are dirty,
  * it's OK to just throw them away.  The app will be more careful about
@@ -278,6 +330,10 @@ static long madvise_dontneed(struct vm_area_struct *vma,
 	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
 		return -EINVAL;
 
+	/* Ignore hint if madvise is continually dropping the same range */
+	if (ignore_madvise_hint(start, end))
+		return 0;
+
 	if (unlikely(vma->vm_flags & VM_NONLINEAR)) {
 		struct zap_details details = {
 			.nonlinear_vma = vma,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
