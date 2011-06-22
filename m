Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 452F690016F
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 06:47:22 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 994733EE0AE
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:47:18 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7ED0445DF89
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:47:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5BD3145DF81
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:47:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C8321DB803F
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:47:18 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 147931DB8037
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:47:18 +0900 (JST)
Message-ID: <4E01C82A.7070702@jp.fujitsu.com>
Date: Wed, 22 Jun 2011 19:47:06 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 2/6] oom: improve dump_tasks() show items
References: <4E01C7D5.3060603@jp.fujitsu.com>
In-Reply-To: <4E01C7D5.3060603@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com

Recently, oom internal logic was dramatically changed. Thus
dump_tasks() doesn't show enough information for bug report
analysis. it has some meaningless items and don't have some
oom socre related items.

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
[   pid]   ppid   uid euid total_vm      rss     swap score_adj name
[   417]      1     0    0     3298       12      184     -1000 udevd
[   830]      1     0    0     1776       11       16         0 system-setup-ke
[   973]      1     0    0    61179       35      116         0 rsyslogd
[  1733]   1732     0    0  1052337   958582        0         0 memtoy

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f552e39..9412657 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -373,7 +373,7 @@ static void dump_tasks(const struct mem_cgroup *mem, const nodemask_t *nodemask)
 	struct task_struct *p;
 	struct task_struct *task;

-	pr_info("[ pid ]   uid  euid  tgid total_vm      rss cpu oom_adj oom_score_adj name\n");
+	pr_info("[   pid]   ppid   uid  euid total_vm      rss     swap score_adj name\n");
 	for_each_process(p) {
 		if (oom_unkillable_task(p, mem, nodemask))
 			continue;
@@ -388,12 +388,14 @@ static void dump_tasks(const struct mem_cgroup *mem, const nodemask_t *nodemask)
 			continue;
 		}

-		pr_info("[%5d] %5d %5d %5d %8lu %8lu %3u     %3d         %5d %s\n",
-			task->pid, task_uid(task), task_euid(task),
-			task->tgid,
-			task->mm->total_vm, get_mm_rss(task->mm),
-			task_cpu(task), task->signal->oom_adj,
-			task->signal->oom_score_adj, task->comm);
+		pr_info("[%6d] %6d %5d %5d %8lu %8lu %8lu %9d %s\n",
+			task_tgid_nr(task), task_tgid_nr(task->real_parent),
+			task_uid(task),	task_euid(task),
+			task->mm->total_vm,
+			get_mm_rss(task->mm) + task->mm->nr_ptes,
+			get_mm_counter(task->mm, MM_SWAPENTS),
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
