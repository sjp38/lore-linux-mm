Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 748E06B0025
	for <linux-mm@kvack.org>; Fri, 20 May 2011 04:02:28 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6EE613EE0C1
	for <linux-mm@kvack.org>; Fri, 20 May 2011 17:02:25 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E58145DE96
	for <linux-mm@kvack.org>; Fri, 20 May 2011 17:02:25 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3121A45DE93
	for <linux-mm@kvack.org>; Fri, 20 May 2011 17:02:25 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 20671E08001
	for <linux-mm@kvack.org>; Fri, 20 May 2011 17:02:25 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DD3891DB803E
	for <linux-mm@kvack.org>; Fri, 20 May 2011 17:02:24 +0900 (JST)
Message-ID: <4DD62007.6020600@jp.fujitsu.com>
Date: Fri, 20 May 2011 17:02:15 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 2/5] oom: kill younger process first
References: <4DD61F80.1020505@jp.fujitsu.com>
In-Reply-To: <4DD61F80.1020505@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com

This patch introduces do_each_thread_reverse() and select_bad_process()
uses it. The benefits are two, 1) oom-killer can kill younger process
than older if they have a same oom score. Usually younger process is
less important. 2) younger task often have PF_EXITING because shell
script makes a lot of short lived processes. Reverse order search can
detect it faster.

Reported-by: CAI Qian <caiqian@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/sched.h |   11 +++++++++++
 mm/oom_kill.c         |    2 +-
 2 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 013314a..3698379 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2194,6 +2194,9 @@ static inline unsigned long wait_task_inactive(struct task_struct *p,
 #define next_task(p) \
 	list_entry_rcu((p)->tasks.next, struct task_struct, tasks)

+#define prev_task(p) \
+	list_entry((p)->tasks.prev, struct task_struct, tasks)
+
 #define for_each_process(p) \
 	for (p = &init_task ; (p = next_task(p)) != &init_task ; )

@@ -2206,6 +2209,14 @@ extern bool current_is_single_threaded(void);
 #define do_each_thread(g, t) \
 	for (g = t = &init_task ; (g = t = next_task(g)) != &init_task ; ) do

+/*
+ * Similar to do_each_thread(). but two difference are there.
+ *  - traverse tasks reverse order (i.e. younger to older)
+ *  - caller must hold tasklist_lock. rcu_read_lock isn't enough
+*/
+#define do_each_thread_reverse(g, t) \
+	for (g = t = &init_task ; (g = t = prev_task(g)) != &init_task ; ) do
+
 #define while_each_thread(g, t) \
 	while ((t = next_thread(t)) != g)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 43d32ae..e6a6c6f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -282,7 +282,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 	struct task_struct *chosen = NULL;
 	*ppoints = 0;

-	do_each_thread(g, p) {
+	do_each_thread_reverse(g, p) {
 		unsigned int points;

 		if (!p->mm)
-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
