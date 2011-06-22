Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 14BB690016F
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 06:47:54 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C746B3EE0B5
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:47:50 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AE7B445DE61
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:47:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 982BD45DE4D
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:47:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B8581DB8038
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:47:50 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 547C31DB802C
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:47:50 +0900 (JST)
Message-ID: <4E01C84A.60400@jp.fujitsu.com>
Date: Wed, 22 Jun 2011 19:47:38 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 3/6] oom: kill younger process first
References: <4E01C7D5.3060603@jp.fujitsu.com>
In-Reply-To: <4E01C7D5.3060603@jp.fujitsu.com>
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
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Acked-by: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/sched.h |   11 +++++++++++
 mm/oom_kill.c         |    2 +-
 2 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index e4e6d7b..392ff30 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2257,6 +2257,9 @@ static inline unsigned long wait_task_inactive(struct task_struct *p,
 #define next_task(p) \
 	list_entry_rcu((p)->tasks.next, struct task_struct, tasks)

+#define prev_task(p) \
+	list_entry((p)->tasks.prev, struct task_struct, tasks)
+
 #define for_each_process(p) \
 	for (p = &init_task ; (p = next_task(p)) != &init_task ; )

@@ -2269,6 +2272,14 @@ extern bool current_is_single_threaded(void);
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
index 9412657..797308b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -300,7 +300,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
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
