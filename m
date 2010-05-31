Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 29C466B01C8
	for <linux-mm@kvack.org>; Mon, 31 May 2010 05:38:22 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4V9cK0f014047
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 31 May 2010 18:38:20 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 17BAB45DE4F
	for <linux-mm@kvack.org>; Mon, 31 May 2010 18:38:20 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E900A45DE4E
	for <linux-mm@kvack.org>; Mon, 31 May 2010 18:38:19 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D05C11DB8038
	for <linux-mm@kvack.org>; Mon, 31 May 2010 18:38:19 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E9DEE08002
	for <linux-mm@kvack.org>; Mon, 31 May 2010 18:38:16 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 5/5] oom: __oom_kill_task() must use find_lock_task_mm() too
In-Reply-To: <20100531182526.1843.A69D9226@jp.fujitsu.com>
References: <20100531182526.1843.A69D9226@jp.fujitsu.com>
Message-Id: <20100531183727.184F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 31 May 2010 18:38:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 5/5] oom: __oom_kill_task() must use find_lock_task_mm() too

__oom_kill_task also use find_lock_task_mm(). because if sysctl_oom_kill_allocating_task
is true, __out_of_memory() don't call select_bad_process().

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 30d9da0..f6aa3fc 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -394,12 +394,11 @@ static void __oom_kill_task(struct task_struct *p, int verbose)
 		return;
 	}
 
-	task_lock(p);
-	if (!p->mm) {
+	p = find_lock_task_mm(p);
+	if (!p) {
 		WARN_ON(1);
 		printk(KERN_WARNING "tried to kill an mm-less task %d (%s)!\n",
 			task_pid_nr(p), p->comm);
-		task_unlock(p);
 		return;
 	}
 
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
