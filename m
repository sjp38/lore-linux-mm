Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A048E6B0008
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 13:27:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id p5-v6so3146195edh.16
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 10:27:32 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o11-v6si2725930edi.441.2018.07.12.10.27.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 12 Jul 2018 10:27:31 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 03/10] delayacct: track delays from thrashing cache pages
Date: Thu, 12 Jul 2018 13:29:35 -0400
Message-Id: <20180712172942.10094-4-hannes@cmpxchg.org>
In-Reply-To: <20180712172942.10094-1-hannes@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Delay accounting already measures the time a task spends in direct
reclaim and waiting for swapin, but in low memory situations tasks
spend can spend a significant amount of their time waiting on
thrashing page cache. This isn't tracked right now.

To know the full impact of memory contention on an individual task,
measure the delay when waiting for a recently evicted active cache
page to read back into memory.

Also update tools/accounting/getdelays.c:

     [hannes@computer accounting]$ sudo ./getdelays -d -p 1
     print delayacct stats ON
     PID     1

     CPU             count     real total  virtual total    delay total  delay average
                     50318      745000000      847346785      400533713          0.008ms
     IO              count    delay total  delay average
                       435      122601218              0ms
     SWAP            count    delay total  delay average
                         0              0              0ms
     RECLAIM         count    delay total  delay average
                         0              0              0ms
     THRASHING       count    delay total  delay average
                        19       12621439              0ms

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/delayacct.h      | 23 +++++++++++++++++++++++
 include/uapi/linux/taskstats.h |  6 +++++-
 kernel/delayacct.c             | 15 +++++++++++++++
 mm/filemap.c                   | 11 +++++++++++
 tools/accounting/getdelays.c   |  8 +++++++-
 5 files changed, 61 insertions(+), 2 deletions(-)

diff --git a/include/linux/delayacct.h b/include/linux/delayacct.h
index 5e335b6203f4..d3e75b3ba487 100644
--- a/include/linux/delayacct.h
+++ b/include/linux/delayacct.h
@@ -57,7 +57,12 @@ struct task_delay_info {
 
 	u64 freepages_start;
 	u64 freepages_delay;	/* wait for memory reclaim */
+
+	u64 thrashing_start;
+	u64 thrashing_delay;	/* wait for thrashing page */
+
 	u32 freepages_count;	/* total count of memory reclaim */
+	u32 thrashing_count;	/* total count of thrash waits */
 };
 #endif
 
@@ -76,6 +81,8 @@ extern int __delayacct_add_tsk(struct taskstats *, struct task_struct *);
 extern __u64 __delayacct_blkio_ticks(struct task_struct *);
 extern void __delayacct_freepages_start(void);
 extern void __delayacct_freepages_end(void);
+extern void __delayacct_thrashing_start(void);
+extern void __delayacct_thrashing_end(void);
 
 static inline int delayacct_is_task_waiting_on_io(struct task_struct *p)
 {
@@ -156,6 +163,18 @@ static inline void delayacct_freepages_end(void)
 		__delayacct_freepages_end();
 }
 
+static inline void delayacct_thrashing_start(void)
+{
+	if (current->delays)
+		__delayacct_thrashing_start();
+}
+
+static inline void delayacct_thrashing_end(void)
+{
+	if (current->delays)
+		__delayacct_thrashing_end();
+}
+
 #else
 static inline void delayacct_set_flag(int flag)
 {}
@@ -182,6 +201,10 @@ static inline void delayacct_freepages_start(void)
 {}
 static inline void delayacct_freepages_end(void)
 {}
+static inline void delayacct_thrashing_start(void)
+{}
+static inline void delayacct_thrashing_end(void)
+{}
 
 #endif /* CONFIG_TASK_DELAY_ACCT */
 
diff --git a/include/uapi/linux/taskstats.h b/include/uapi/linux/taskstats.h
index b7aa7bb2349f..5e8ca16a9079 100644
--- a/include/uapi/linux/taskstats.h
+++ b/include/uapi/linux/taskstats.h
@@ -34,7 +34,7 @@
  */
 
 
-#define TASKSTATS_VERSION	8
+#define TASKSTATS_VERSION	9
 #define TS_COMM_LEN		32	/* should be >= TASK_COMM_LEN
 					 * in linux/sched.h */
 
@@ -164,6 +164,10 @@ struct taskstats {
 	/* Delay waiting for memory reclaim */
 	__u64	freepages_count;
 	__u64	freepages_delay_total;
+
+	/* Delay waiting for thrashing page */
+	__u64	thrashing_count;
+	__u64	thrashing_delay_total;
 };
 
 
diff --git a/kernel/delayacct.c b/kernel/delayacct.c
index e2764d767f18..02ba745c448d 100644
--- a/kernel/delayacct.c
+++ b/kernel/delayacct.c
@@ -134,9 +134,12 @@ int __delayacct_add_tsk(struct taskstats *d, struct task_struct *tsk)
 	d->swapin_delay_total = (tmp < d->swapin_delay_total) ? 0 : tmp;
 	tmp = d->freepages_delay_total + tsk->delays->freepages_delay;
 	d->freepages_delay_total = (tmp < d->freepages_delay_total) ? 0 : tmp;
+	tmp = d->thrashing_delay_total + tsk->delays->thrashing_delay;
+	d->thrashing_delay_total = (tmp < d->thrashing_delay_total) ? 0 : tmp;
 	d->blkio_count += tsk->delays->blkio_count;
 	d->swapin_count += tsk->delays->swapin_count;
 	d->freepages_count += tsk->delays->freepages_count;
+	d->thrashing_count += tsk->delays->thrashing_count;
 	spin_unlock_irqrestore(&tsk->delays->lock, flags);
 
 	return 0;
@@ -168,3 +171,15 @@ void __delayacct_freepages_end(void)
 		&current->delays->freepages_count);
 }
 
+void __delayacct_thrashing_start(void)
+{
+	current->delays->thrashing_start = ktime_get_ns();
+}
+
+void __delayacct_thrashing_end(void)
+{
+	delayacct_end(&current->delays->lock,
+		      &current->delays->thrashing_start,
+		      &current->delays->thrashing_delay,
+		      &current->delays->thrashing_count);
+}
diff --git a/mm/filemap.c b/mm/filemap.c
index bd36b7226cf4..e49961e13dd9 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -36,6 +36,7 @@
 #include <linux/cleancache.h>
 #include <linux/shmem_fs.h>
 #include <linux/rmap.h>
+#include <linux/delayacct.h>
 #include "internal.h"
 
 #define CREATE_TRACE_POINTS
@@ -1073,8 +1074,15 @@ static inline int wait_on_page_bit_common(wait_queue_head_t *q,
 {
 	struct wait_page_queue wait_page;
 	wait_queue_entry_t *wait = &wait_page.wait;
+	bool thrashing = false;
 	int ret = 0;
 
+	if (bit_nr == PG_locked && !PageSwapBacked(page) &&
+	    !PageUptodate(page) && PageWorkingset(page)) {
+		delayacct_thrashing_start();
+		thrashing = true;
+	}
+
 	init_wait(wait);
 	wait->flags = lock ? WQ_FLAG_EXCLUSIVE : 0;
 	wait->func = wake_page_function;
@@ -1113,6 +1121,9 @@ static inline int wait_on_page_bit_common(wait_queue_head_t *q,
 
 	finish_wait(q, wait);
 
+	if (thrashing)
+		delayacct_thrashing_end();
+
 	/*
 	 * A signal could leave PageWaiters set. Clearing it here if
 	 * !waitqueue_active would be possible (by open-coding finish_wait),
diff --git a/tools/accounting/getdelays.c b/tools/accounting/getdelays.c
index 9f420d98b5fb..8cb504d30384 100644
--- a/tools/accounting/getdelays.c
+++ b/tools/accounting/getdelays.c
@@ -203,6 +203,8 @@ static void print_delayacct(struct taskstats *t)
 	       "SWAP  %15s%15s%15s\n"
 	       "      %15llu%15llu%15llums\n"
 	       "RECLAIM  %12s%15s%15s\n"
+	       "      %15llu%15llu%15llums\n"
+	       "THRASHING%12s%15s%15s\n"
 	       "      %15llu%15llu%15llums\n",
 	       "count", "real total", "virtual total",
 	       "delay total", "delay average",
@@ -222,7 +224,11 @@ static void print_delayacct(struct taskstats *t)
 	       "count", "delay total", "delay average",
 	       (unsigned long long)t->freepages_count,
 	       (unsigned long long)t->freepages_delay_total,
-	       average_ms(t->freepages_delay_total, t->freepages_count));
+	       average_ms(t->freepages_delay_total, t->freepages_count),
+	       "count", "delay total", "delay average",
+	       (unsigned long long)t->thrashing_count,
+	       (unsigned long long)t->thrashing_delay_total,
+	       average_ms(t->thrashing_delay_total, t->thrashing_count));
 }
 
 static void task_context_switch_counts(struct taskstats *t)
-- 
2.18.0
