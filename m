Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id EC1D26B01C3
	for <linux-mm@kvack.org>; Mon, 31 May 2010 05:33:10 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4V9X8pT028229
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 31 May 2010 18:33:08 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id ECC4F45DE52
	for <linux-mm@kvack.org>; Mon, 31 May 2010 18:33:07 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A8D9C45DE4C
	for <linux-mm@kvack.org>; Mon, 31 May 2010 18:33:07 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E16BE08003
	for <linux-mm@kvack.org>; Mon, 31 May 2010 18:33:07 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 41BBB1DB8013
	for <linux-mm@kvack.org>; Mon, 31 May 2010 18:33:07 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/5] oom: select_bad_process: check PF_KTHREAD instead of !mm to skip kthreads
Message-Id: <20100531182526.1843.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 31 May 2010 18:33:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

From: Oleg Nesterov <oleg@redhat.com>
Subject: oom: select_bad_process: check PF_KTHREAD instead of !mm to skip kthreads

select_bad_process() thinks a kernel thread can't have ->mm != NULL, this
is not true due to use_mm().

Change the code to check PF_KTHREAD.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 709aedf..070b713 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -256,14 +256,11 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 	for_each_process(p) {
 		unsigned long points;
 
-		/*
-		 * skip kernel threads and tasks which have already released
-		 * their mm.
-		 */
+		/* skip the tasks which have already released their mm. */
 		if (!p->mm)
 			continue;
-		/* skip the init task */
-		if (is_global_init(p))
+		/* skip the init task and kthreads */
+		if (is_global_init(p) || (p->flags & PF_KTHREAD))
 			continue;
 		if (mem && !task_in_mem_cgroup(p, mem))
 			continue;
-- 
1.6.5.2




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
