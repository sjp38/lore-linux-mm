Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 9CAC96B004A
	for <linux-mm@kvack.org>; Sat, 31 Mar 2012 10:10:26 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 1/2] mm: Allow using fast mm counters from other files
Date: Sat, 31 Mar 2012 07:09:56 -0700
Message-Id: <1333202997-19550-2-git-send-email-andi@firstfloor.org>
In-Reply-To: <1333202997-19550-1-git-send-email-andi@firstfloor.org>
References: <1333202997-19550-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: tim.c.chen@linux.intel.com, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>

From: Andi Kleen <ak@linux.intel.com>

Allow calling inc/dec_mm_counter_fast() from other files, not just memory.c

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 include/linux/mm.h |   10 ++++++++++
 mm/memory.c        |    7 +------
 2 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 17b27cd..ad8d314 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1082,6 +1082,16 @@ static inline void inc_mm_counter(struct mm_struct *mm, int member)
 	atomic_long_inc(&mm->rss_stat.count[member]);
 }
 
+#if defined(SPLIT_RSS_COUNTING)
+extern void add_mm_counter_fast(struct mm_struct *mm, int member, int val);
+
+#define inc_mm_counter_fast(mm, member) add_mm_counter_fast(mm, member, 1)
+#define dec_mm_counter_fast(mm, member) add_mm_counter_fast(mm, member, -1)
+#else
+#define inc_mm_counter_fast(mm, member) inc_mm_counter(mm, member)
+#define dec_mm_counter_fast(mm, member) inc_mm_counter_fast(mm, member)
+#endif
+
 static inline void dec_mm_counter(struct mm_struct *mm, int member)
 {
 	atomic_long_dec(&mm->rss_stat.count[member]);
diff --git a/mm/memory.c b/mm/memory.c
index fa2f04e..89d8401 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -138,7 +138,7 @@ static void __sync_task_rss_stat(struct task_struct *task, struct mm_struct *mm)
 	task->rss_stat.events = 0;
 }
 
-static void add_mm_counter_fast(struct mm_struct *mm, int member, int val)
+void add_mm_counter_fast(struct mm_struct *mm, int member, int val)
 {
 	struct task_struct *task = current;
 
@@ -147,8 +147,6 @@ static void add_mm_counter_fast(struct mm_struct *mm, int member, int val)
 	else
 		add_mm_counter(mm, member, val);
 }
-#define inc_mm_counter_fast(mm, member) add_mm_counter_fast(mm, member, 1)
-#define dec_mm_counter_fast(mm, member) add_mm_counter_fast(mm, member, -1)
 
 /* sync counter once per 64 page faults */
 #define TASK_RSS_EVENTS_THRESH	(64)
@@ -184,9 +182,6 @@ void sync_mm_rss(struct task_struct *task, struct mm_struct *mm)
 }
 #else /* SPLIT_RSS_COUNTING */
 
-#define inc_mm_counter_fast(mm, member) inc_mm_counter(mm, member)
-#define dec_mm_counter_fast(mm, member) dec_mm_counter(mm, member)
-
 static void check_sync_rss_stat(struct task_struct *task)
 {
 }
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
