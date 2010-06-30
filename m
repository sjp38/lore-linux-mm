Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C57466B01CE
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 05:31:39 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5U9Vb0t024320
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 30 Jun 2010 18:31:37 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 59B4C45DE51
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:31:37 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3CB2245DE4C
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:31:37 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 261771DB8015
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:31:37 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D22341DB8013
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:31:36 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 07/11] oom: move OOM_DISABLE check from oom_kill_task to out_of_memory()
In-Reply-To: <20100630172430.AA42.A69D9226@jp.fujitsu.com>
References: <20100630172430.AA42.A69D9226@jp.fujitsu.com>
Message-Id: <20100630183059.AA5C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 30 Jun 2010 18:31:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Now, if oom_kill_allocating_task is enabled and current have
OOM_DISABLED, following printk in oom_kill_process is called twice.

    pr_err("%s: Kill process %d (%s) score %lu or sacrifice child\n",
            message, task_pid_nr(p), p->comm, points);

So, OOM_DISABLE check should be more early.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f5d903f..75f6dbc 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -424,7 +424,7 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 static int oom_kill_task(struct task_struct *p)
 {
 	p = find_lock_task_mm(p);
-	if (!p || p->signal->oom_adj == OOM_DISABLE) {
+	if (!p) {
 		task_unlock(p);
 		return 1;
 	}
@@ -686,7 +686,8 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 
 	read_lock(&tasklist_lock);
 	if (sysctl_oom_kill_allocating_task &&
-	    !oom_unkillable_task(current, NULL, nodemask)) {
+	    !oom_unkillable_task(current, NULL, nodemask) &&
+	    (current->signal->oom_adj != OOM_DISABLE)) {
 		/*
 		 * oom_kill_process() needs tasklist_lock held.  If it returns
 		 * non-zero, current could not be killed so we must fallback to
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
