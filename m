Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E48A06B01F1
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 09:06:54 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7JD6pmg002296
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 19 Aug 2010 22:06:51 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D913145DE53
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 22:06:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AA2D145DE50
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 22:06:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7CA451DB8049
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 22:06:50 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 30E6B1DB804C
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 22:06:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: oom: __task_cred() need rcu_read_lock()
Message-Id: <20100819220338.5FD5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 19 Aug 2010 22:06:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

dump_tasks() can call __task_cred() safely because we are holding
tasklist_lock. but rcu lock validator don't have enough knowledge and
it makes following annoying warning.

Then, this patch change to call rcu_read_lock() explicitly.


	===================================================
	[ INFO: suspicious rcu_dereference_check() usage. ]
	---------------------------------------------------
	mm/oom_kill.c:410 invoked rcu_dereference_check() without protection!

	other info that might help us debug this:

	rcu_scheduler_active = 1, debug_locks = 1
	4 locks held by kworker/1:2/651:
	 #0:  (events){+.+.+.}, at: [<ffffffff8106aae7>]
	process_one_work+0x137/0x4a0
	 #1:  (moom_work){+.+...}, at: [<ffffffff8106aae7>]
	process_one_work+0x137/0x4a0
	 #2:  (tasklist_lock){.+.+..}, at: [<ffffffff810fafd4>]
	out_of_memory+0x164/0x3f0
	 #3:  (&(&p->alloc_lock)->rlock){+.+...}, at: [<ffffffff810fa48e>]
	find_lock_task_mm+0x2e/0x70

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index c48c5ef..57c05f7 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -371,11 +371,13 @@ static void dump_tasks(const struct mem_cgroup *mem)
 			continue;
 		}
 
+		rcu_read_lock();
 		pr_info("[%5d] %5d %5d %8lu %8lu %3u     %3d         %5d %s\n",
 			task->pid, __task_cred(task)->uid, task->tgid,
 			task->mm->total_vm, get_mm_rss(task->mm),
 			task_cpu(task), task->signal->oom_adj,
 			task->signal->oom_score_adj, task->comm);
+		rcu_read_unlock();
 		task_unlock(task);
 	}
 }
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
