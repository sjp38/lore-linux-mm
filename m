Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 845FC6B0025
	for <linux-mm@kvack.org>; Fri, 20 May 2011 04:01:54 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B034A3EE0BC
	for <linux-mm@kvack.org>; Fri, 20 May 2011 17:01:50 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 99CB545DE56
	for <linux-mm@kvack.org>; Fri, 20 May 2011 17:01:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 786112E68C1
	for <linux-mm@kvack.org>; Fri, 20 May 2011 17:01:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D559E08003
	for <linux-mm@kvack.org>; Fri, 20 May 2011 17:01:50 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B300EF8001
	for <linux-mm@kvack.org>; Fri, 20 May 2011 17:01:50 +0900 (JST)
Message-ID: <4DD61FE2.1020303@jp.fujitsu.com>
Date: Fri, 20 May 2011 17:01:38 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 1/5] oom: improve dump_tasks() show items
References: <4DD61F80.1020505@jp.fujitsu.com>
In-Reply-To: <4DD61F80.1020505@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com

Recently, oom internal logic was dramatically changed. Thus
dump_tasks() doesn't show enough information for bug report
analysis. it has some meaningless items and don't have some
oom score related items.

This patch adapt displaying fields to new oom logic.

details
--------
removed: pid (we always kill process. don't need thread id),
         signal->oom_adj (we no longer uses it internally)
	 cpu (we no longer uses it)
added:  ppid (we often kill sacrifice child process)
        swap (it's accounted)
modify: RSS (account mm->nr_ptes too)

<old>
[ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[ 3886]     0  3886     2893      441   1       0             0 bash
[ 3905]     0  3905    29361    25833   0       0             0 memtoy

<new>
[   pid]   ppid   uid total_vm      rss     swap score_adj name
[   417]      1     0     3298       12      184     -1000 udevd
[   830]      1     0     1776       11       16         0 system-setup-ke
[   973]      1     0    61179       35      116         0 rsyslogd
[  1733]   1732     0  1052337   958582        0         0 memtoy

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f52e85c..43d32ae 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -355,7 +355,7 @@ static void dump_tasks(const struct mem_cgroup *mem, const nodemask_t *nodemask)
 	struct task_struct *p;
 	struct task_struct *task;

-	pr_info("[ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name\n");
+	pr_info("[   pid]   ppid   uid total_vm      rss     swap score_adj name\n");
 	for_each_process(p) {
 		if (oom_unkillable_task(p, mem, nodemask))
 			continue;
@@ -370,11 +370,14 @@ static void dump_tasks(const struct mem_cgroup *mem, const nodemask_t *nodemask)
 			continue;
 		}

-		pr_info("[%5d] %5d %5d %8lu %8lu %3u     %3d         %5d %s\n",
-			task->pid, task_uid(task), task->tgid,
-			task->mm->total_vm, get_mm_rss(task->mm),
-			task_cpu(task), task->signal->oom_adj,
-			task->signal->oom_score_adj, task->comm);
+		pr_info("[%6d] %6d %5d %8lu %8lu %8lu %9d %s\n",
+			task_tgid_nr(task), task_tgid_nr(task->real_parent),
+			task_uid(task),
+			task->mm->total_vm,
+			get_mm_rss(task->mm) + p->mm->nr_ptes,
+			get_mm_counter(p->mm, MM_SWAPENTS),
+			task->signal->oom_score_adj,
+			task->comm);
 		task_unlock(task);
 	}
 }
-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
