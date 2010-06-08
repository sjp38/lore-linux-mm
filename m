Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C47D76B0212
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 07:55:35 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o58BtYZU013380
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Jun 2010 20:55:34 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id EF35845DE55
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:55:33 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C949345DE52
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:55:33 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E1C8E08002
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:55:33 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4AE161DB803C
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:55:33 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 02/10] oom: remove verbose argument from __oom_kill_process()
In-Reply-To: <20100608204621.767A.A69D9226@jp.fujitsu.com>
References: <20100608204621.767A.A69D9226@jp.fujitsu.com>
Message-Id: <20100608205454.7680.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Jun 2010 20:55:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Now, verbose argument is unused. This patch remove it.

[remark: this patch is needed to fold to "oom: remove PF_EXITING
check completely"]

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |   20 +++++++++-----------
 1 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 0d7397b..3c83fba 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -384,20 +384,18 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
  * flag though it's unlikely that  we select a process with CAP_SYS_RAW_IO
  * set.
  */
-static int __oom_kill_process(struct task_struct *p, struct mem_cgroup *mem,
-			      int verbose)
+static int __oom_kill_process(struct task_struct *p, struct mem_cgroup *mem)
 {
 	p = find_lock_task_mm(p);
 	if (!p)
 		return 1;
 
-	if (verbose)
-		printk(KERN_ERR "Killed process %d (%s) "
-		       "vsz:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
-		       task_pid_nr(p), p->comm,
-		       K(p->mm->total_vm),
-		       K(get_mm_counter(p->mm, MM_ANONPAGES)),
-		       K(get_mm_counter(p->mm, MM_FILEPAGES)));
+	printk(KERN_ERR "Killed process %d (%s) "
+	       "vsz:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
+	       task_pid_nr(p), p->comm,
+	       K(p->mm->total_vm),
+	       K(get_mm_counter(p->mm, MM_ANONPAGES)),
+	       K(get_mm_counter(p->mm, MM_FILEPAGES)));
 	task_unlock(p);
 
 	/*
@@ -437,7 +435,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 
 			if (c->mm == p->mm)
 				continue;
-			if (oom_unkillable(c, mem, nodemask))
+			if (oom_unkillable(c, mem))
 				continue;
 
 			/* badness() returns 0 if the thread is unkillable */
@@ -449,7 +447,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		}
 	} while_each_thread(p, t);
 
-	return __oom_kill_process(victim, mem, 1);
+	return __oom_kill_process(victim, mem);
 }
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
