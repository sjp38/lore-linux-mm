Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 927A26B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 07:40:09 -0500 (EST)
Received: by bkbzx1 with SMTP id zx1so3332736bkb.14
        for <linux-mm@kvack.org>; Thu, 19 Jan 2012 04:40:07 -0800 (PST)
Subject: [PATCH trivial] mm: make get_mm_counter static-inline
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 19 Jan 2012 16:40:05 +0400
Message-ID: <20120119124005.21946.18651.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch makes get_mm_counter() always static inline,
it is simple enough for that. And remove unused set_mm_counter()

bloat-o-meter:

add/remove: 0/1 grow/shrink: 4/12 up/down: 99/-341 (-242)
function                                     old     new   delta
try_to_unmap_one                             886     952     +66
sys_remap_file_pages                        1214    1230     +16
dup_mm                                      1684    1700     +16
do_exit                                     2277    2278      +1
zap_page_range                               208     205      -3
unmap_region                                 304     296      -8
static.oom_kill_process                      554     546      -8
try_to_unmap_file                           1716    1700     -16
getrusage                                    925     909     -16
flush_old_exec                              1704    1688     -16
static.dump_header                           416     390     -26
acct_update_integrals                        218     187     -31
do_task_stat                                2986    2954     -32
get_mm_counter                                34       -     -34
xacct_add_tsk                                371     334     -37
task_statm                                   172     118     -54
task_mem                                     383     323     -60

try_to_unmap_one() grows because update_hiwater_rss() now completely inline.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/mm.h |   21 +++++++++++----------
 mm/memory.c        |   18 ------------------
 2 files changed, 11 insertions(+), 28 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 17b27cd..378bcce 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1058,19 +1058,20 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 /*
  * per-process(per-mm_struct) statistics.
  */
-static inline void set_mm_counter(struct mm_struct *mm, int member, long value)
-{
-	atomic_long_set(&mm->rss_stat.count[member], value);
-}
-
-#if defined(SPLIT_RSS_COUNTING)
-unsigned long get_mm_counter(struct mm_struct *mm, int member);
-#else
 static inline unsigned long get_mm_counter(struct mm_struct *mm, int member)
 {
-	return atomic_long_read(&mm->rss_stat.count[member]);
-}
+	long val = atomic_long_read(&mm->rss_stat.count[member]);
+
+#ifdef SPLIT_RSS_COUNTING
+	/*
+	 * counter is updated in asynchronous manner and may go to minus.
+	 * But it's never be expected number for users.
+	 */
+	if (val < 0)
+		val = 0;
 #endif
+	return (unsigned long)val;
+}
 
 static inline void add_mm_counter(struct mm_struct *mm, int member, long value)
 {
diff --git a/mm/memory.c b/mm/memory.c
index fa2f04e..f31fb6e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -160,24 +160,6 @@ static void check_sync_rss_stat(struct task_struct *task)
 		__sync_task_rss_stat(task, task->mm);
 }
 
-unsigned long get_mm_counter(struct mm_struct *mm, int member)
-{
-	long val = 0;
-
-	/*
-	 * Don't use task->mm here...for avoiding to use task_get_mm()..
-	 * The caller must guarantee task->mm is not invalid.
-	 */
-	val = atomic_long_read(&mm->rss_stat.count[member]);
-	/*
-	 * counter is updated in asynchronous manner and may go to minus.
-	 * But it's never be expected number for users.
-	 */
-	if (val < 0)
-		return 0;
-	return (unsigned long)val;
-}
-
 void sync_mm_rss(struct task_struct *task, struct mm_struct *mm)
 {
 	__sync_task_rss_stat(task, mm);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
