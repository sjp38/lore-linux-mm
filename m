Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 06D126B0022
	for <linux-mm@kvack.org>; Tue, 10 May 2011 04:14:26 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C359E3EE0C3
	for <linux-mm@kvack.org>; Tue, 10 May 2011 17:14:22 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A792C45DE6A
	for <linux-mm@kvack.org>; Tue, 10 May 2011 17:14:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 86DD045DE61
	for <linux-mm@kvack.org>; Tue, 10 May 2011 17:14:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 782291DB8044
	for <linux-mm@kvack.org>; Tue, 10 May 2011 17:14:22 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A7071DB803C
	for <linux-mm@kvack.org>; Tue, 10 May 2011 17:14:22 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/4] oom: improve dump_tasks() show items
In-Reply-To: <20110510171335.16A7.A69D9226@jp.fujitsu.com>
References: <20110509182110.167F.A69D9226@jp.fujitsu.com> <20110510171335.16A7.A69D9226@jp.fujitsu.com>
Message-Id: <20110510171600.16AB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue, 10 May 2011 17:14:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: CAI Qian <caiqian@redhat.com>, avagin@gmail.com, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan.kim@gmail.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>

Recently, oom internal logic was dramatically changed. Thus
dump_tasks() is no longer useful. it has some meaningless
items and don't have some oom socre related items.

This patch adapt displaying fields to new oom logic.

details
==========
removed: pid (we always kill process. don't need thread id),
         mm->total_vm (we no longer uses virtual memory size)
         signal->oom_adj (we no longer uses it internally)
added: ppid (we often kill sacrifice child process)
modify: RSS (account mm->nr_ptes too)

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---

Strictly speaking. this is NOT a part of oom fixing patches. but it's
necessary when I parse QAI's test result.


 mm/oom_kill.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f52e85c..118d958 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -355,7 +355,7 @@ static void dump_tasks(const struct mem_cgroup *mem, const nodemask_t *nodemask)
 	struct task_struct *p;
 	struct task_struct *task;
 
-	pr_info("[ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name\n");
+	pr_info("[   pid]   ppid   uid      rss  cpu score_adj name\n");
 	for_each_process(p) {
 		if (oom_unkillable_task(p, mem, nodemask))
 			continue;
@@ -370,11 +370,13 @@ static void dump_tasks(const struct mem_cgroup *mem, const nodemask_t *nodemask)
 			continue;
 		}
 
-		pr_info("[%5d] %5d %5d %8lu %8lu %3u     %3d         %5d %s\n",
-			task->pid, task_uid(task), task->tgid,
-			task->mm->total_vm, get_mm_rss(task->mm),
-			task_cpu(task), task->signal->oom_adj,
-			task->signal->oom_score_adj, task->comm);
+		pr_info("[%6d] %6d %5d %8lu %4u %9d %s\n",
+			task_tgid_nr(task), task_tgid_nr(task->real_parent),
+			task_uid(task),
+			get_mm_rss(task->mm) + p->mm->nr_ptes,
+			task_cpu(task),
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
