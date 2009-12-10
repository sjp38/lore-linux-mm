Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B8A4260021B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 19:53:35 -0500 (EST)
Message-Id: <20091210004703.148689096@linutronix.de>
Date: Thu, 10 Dec 2009 00:53:07 -0000
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 4/9] oom: Add missing rcu protection of __task_cred() in
	dump_tasks
References: <20091210001308.247025548@linutronix.de>
Content-Disposition: inline;
	filename=oom-fix-missing-rcu-protection-of-__task_cred.patch
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Dipankar Sarma <dipankar@in.ibm.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@tv-sign.ru>, Al Viro <viro@zeniv.linux.org.uk>, James Morris <jmorris@namei.org>, David Howells <dhowells@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

dump_tasks accesses __task_cred() without being in a RCU read side
critical section. tasklist_lock is not protecting that when
CONFIG_TREE_PREEMPT_RCU=y.

Add a rcu_read_lock/unlock() section around the code which accesses
__task_cred().

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
---
 mm/oom_kill.c |    3 +++
 1 file changed, 3 insertions(+)

Index: linux-2.6-tip/mm/oom_kill.c
===================================================================
--- linux-2.6-tip.orig/mm/oom_kill.c
+++ linux-2.6-tip/mm/oom_kill.c
@@ -329,10 +329,13 @@ static void dump_tasks(const struct mem_
 			task_unlock(p);
 			continue;
 		}
+		/* Protect __task_cred() access */
+		rcu_read_lock();
 		printk(KERN_INFO "[%5d] %5d %5d %8lu %8lu %3d     %3d %s\n",
 		       p->pid, __task_cred(p)->uid, p->tgid, mm->total_vm,
 		       get_mm_rss(mm), (int)task_cpu(p), p->signal->oom_adj,
 		       p->comm);
+		rcu_read_unlock();
 		task_unlock(p);
 	} while_each_thread(g, p);
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
