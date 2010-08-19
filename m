Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CEE656B01F2
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 06:54:10 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7JAs8VN007402
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 19 Aug 2010 19:54:08 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 21C5C45DE60
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 19:54:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 01BEE45DE4D
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 19:54:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B5D91DB8037
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 19:54:07 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 43987E38001
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 19:54:07 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/2] oom: fix tasklist_lock leak
In-Reply-To: <20100819194707.5FC4.A69D9226@jp.fujitsu.com>
References: <20100819194707.5FC4.A69D9226@jp.fujitsu.com>
Message-Id: <20100819195346.5FCA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 19 Aug 2010 19:54:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

commit 0aad4b3124 (oom: fold __out_of_memory into out_of_memory)
introduced tasklist_lock leak. Then it caused following obvious
danger warings and panic.

    ================================================
    [ BUG: lock held when returning to user space! ]
    ------------------------------------------------
    rsyslogd/1422 is leaving the kernel with locks still held!
    1 lock held by rsyslogd/1422:
     #0:  (tasklist_lock){.+.+.+}, at: [<ffffffff810faf64>] out_of_memory+0x164/0x3f0
    BUG: scheduling while atomic: rsyslogd/1422/0x00000002
    INFO: lockdep is turned off.

This patch fixes it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 17d48a6..c48c5ef 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -646,6 +646,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	unsigned long freed = 0;
 	unsigned int points;
 	enum oom_constraint constraint = CONSTRAINT_NONE;
+	int killed = 0;
 
 	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
 	if (freed > 0)
@@ -683,7 +684,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		if (!oom_kill_process(current, gfp_mask, order, 0, totalpages,
 				NULL, nodemask,
 				"Out of memory (oom_kill_allocating_task)"))
-			return;
+			goto out;
 	}
 
 retry:
@@ -691,7 +692,7 @@ retry:
 			constraint == CONSTRAINT_MEMORY_POLICY ? nodemask :
 								 NULL);
 	if (PTR_ERR(p) == -1UL)
-		return;
+		goto out;
 
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!p) {
@@ -703,13 +704,15 @@ retry:
 	if (oom_kill_process(p, gfp_mask, order, points, totalpages, NULL,
 				nodemask, "Out of memory"))
 		goto retry;
+	killed = 1;
+out:
 	read_unlock(&tasklist_lock);
 
 	/*
 	 * Give "p" a good chance of killing itself before we
 	 * retry to allocate memory unless "p" is current
 	 */
-	if (!test_thread_flag(TIF_MEMDIE))
+	if (killed && !test_thread_flag(TIF_MEMDIE))
 		schedule_timeout_uninterruptible(1);
 }
 
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
