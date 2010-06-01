Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A97626B01B6
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 01:48:09 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o515m7GH028033
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 1 Jun 2010 14:48:07 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D05DC45DE58
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 14:48:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DFAB45DE4E
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 14:48:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 61696E18002
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 14:48:06 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E0341DB803B
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 14:48:06 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/5] oom: remove warning for in mm-less task __oom_kill_process()
In-Reply-To: <20100601144238.243A.A69D9226@jp.fujitsu.com>
References: <20100601144238.243A.A69D9226@jp.fujitsu.com>
Message-Id: <20100601144705.243D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  1 Jun 2010 14:48:05 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

If the race of mm detach in task exiting vs oom is happen,
find_lock_task_mm() can be return NULL.

So, the warning is pointless. remove it.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index bac4515..70e1a85 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -402,12 +402,8 @@ static int __oom_kill_process(struct task_struct *p, struct mem_cgroup *mem,
 		return 1;
 
 	p = find_lock_task_mm(p);
-	if (!p) {
-		WARN_ON(1);
-		printk(KERN_WARNING "tried to kill an mm-less task %d (%s)!\n",
-			task_pid_nr(p), p->comm);
+	if (!p)
 		return 1;
-	}
 
 	if (verbose)
 		printk(KERN_ERR "Killed process %d (%s) "
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
