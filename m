Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EC94B6B01B4
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 02:23:06 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o536N59Y018172
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 3 Jun 2010 15:23:05 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6317945DE7E
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 15:23:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BB8B45DE79
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 15:23:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 043B1E38003
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 15:23:05 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A6D71DB8040
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 15:23:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 06/12] oom: remove warning for in mm-less task __oom_kill_process()
In-Reply-To: <20100603135106.7247.A69D9226@jp.fujitsu.com>
References: <20100603135106.7247.A69D9226@jp.fujitsu.com>
Message-Id: <20100603145330.7259.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  3 Jun 2010 15:23:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

If the race of mm detach in task exiting vs oom is happen,
find_lock_task_mm() can be return NULL.

So, the warning is pointless.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 618cf44..d4484c5 100644
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
