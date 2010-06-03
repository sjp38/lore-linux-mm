Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DC4D66B01AD
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 01:49:57 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o535ntW9012529
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 3 Jun 2010 14:49:55 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id CB6F645DE55
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 14:49:54 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C322E45DE52
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 14:49:53 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A8924E38003
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 14:49:52 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2EA4B1DB8014
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 14:49:49 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 01/12] oom: select_bad_process: check PF_KTHREAD instead of !mm to skip kthreads
In-Reply-To: <20100603135106.7247.A69D9226@jp.fujitsu.com>
References: <20100603135106.7247.A69D9226@jp.fujitsu.com>
Message-Id: <20100603144841.724A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  3 Jun 2010 14:49:48 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

From: Oleg Nesterov <oleg@redhat.com>

select_bad_process() thinks a kernel thread can't have ->mm != NULL, this
is not true due to use_mm().

Change the code to check PF_KTHREAD.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
Acked-by: David Rientjes <rientjes@google.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
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
