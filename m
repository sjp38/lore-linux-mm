Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 372056B01D6
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 05:34:13 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5U9YBko025450
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 30 Jun 2010 18:34:11 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CEC845DE51
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:34:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E188745DE4F
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:34:10 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CB1BA1DB803A
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:34:10 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 88DFDE08002
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 18:34:07 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 11/11] oom: multi threaded process coredump don't make deadlock
In-Reply-To: <20100630172430.AA42.A69D9226@jp.fujitsu.com>
References: <20100630172430.AA42.A69D9226@jp.fujitsu.com>
Message-Id: <20100630183322.AA68.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 30 Jun 2010 18:34:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Oleg Nesterov <oleg@redhat.com>
List-ID: <linux-mm.kvack.org>

Oleg pointed out current PF_EXITING check is wrong. Because PF_EXITING
is per-thread flag, not per-process flag. He said,

   Two threads, group-leader L and its sub-thread T. T dumps the code.
   In this case both threads have ->mm != NULL, L has PF_EXITING.

   The first problem is, select_bad_process() always return -1 in this
   case (even if the caller is T, this doesn't matter).

   The second problem is that we should add TIF_MEMDIE to T, not L.

I think we can remove this dubious PF_EXITING check. but as first step,
This patch add the protection of multi threaded issue.

Cc: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/oom_kill.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 0858b18..b04e557 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -360,7 +360,7 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 		 * the process of exiting and releasing its resources.
 		 * Otherwise we could get an easy OOM deadlock.
 		 */
-		if ((p->flags & PF_EXITING) && p->mm) {
+		if (thread_group_empty(p) && (p->flags & PF_EXITING) && p->mm) {
 			if (p != current)
 				return ERR_PTR(-1UL);
 
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
