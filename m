Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B54E26B01EE
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 23:15:26 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2V3FMTu018435
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 31 Mar 2010 12:15:23 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 92C1745DE70
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 12:15:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5713545DE6F
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 12:15:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2187BE18007
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 12:15:22 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B15451DB803F
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 12:15:21 +0900 (JST)
Date: Wed, 31 Mar 2010 12:11:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] exit: fix oops in sync_mm_rss
Message-Id: <20100331121120.9bd35fd5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100330200336.dd0ff9fd.akpm@linux-foundation.org>
References: <20100316170808.GA29400@redhat.com>
	<20100330135634.09e6b045.akpm@linux-foundation.org>
	<20100331092815.c8b9d89c.kamezawa.hiroyu@jp.fujitsu.com>
	<20100330173721.cbd442cb.akpm@linux-foundation.org>
	<20100331094124.43c49290.kamezawa.hiroyu@jp.fujitsu.com>
	<20100330182258.59813fe6.akpm@linux-foundation.org>
	<20100331102755.92a89ca5.kamezawa.hiroyu@jp.fujitsu.com>
	<n2m28c262361003301953iea82f541u227e7227a23702e@mail.gmail.com>
	<20100330200336.dd0ff9fd.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, "Michael S. Tsirkin" <mst@redhat.com>, cl@linux-foundation.org, lee.schermerhorn@hp.com, rientjes@google.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "David S. Miller" <davem@davemloft.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Troels Liebe Bentsen <tlb@rapanden.dk>, linux-bluetooth@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Mar 2010 20:03:36 -0400
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 31 Mar 2010 11:53:00 +0900 Minchan Kim <minchan.kim@gmail.com> wrote:
 
> really.  Apart from the fact that we'll otherwise perform an empty
> NR_MM_COUNTERS loop in __sync_task_rss_stat(), sync_mm_rss() just isn't
> set up to handle kernel threads.  Given that the function of
> sync_task_mm(from, to) is to move stuff from "from" and into "to", it's
> daft to call it with a NULL value of `to'!
> 
Updated again.

==

task->rss_stat wasn't initialized to 0 at copy_process().
At exit, tsk->mm may be NULL. It's not valid to call sync_mm_rss()
against not exisiting mm_struct, We should check it.
And __sync_task_rss_stat() should be static.
This patch also removes BUG_ON(!mm) in __sync_task_rss_stat().
The code will panic if !mm without it.

Changelog:
 - removed BUG_ON()
 - added check task->mm in exit.c before calling sync_mm_rss().

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 kernel/exit.c |    3 ++-
 kernel/fork.c |    3 +++
 mm/memory.c   |    3 +--
 3 files changed, 6 insertions(+), 3 deletions(-)

Index: mmotm-2.6.34-Mar24/mm/memory.c
===================================================================
--- mmotm-2.6.34-Mar24.orig/mm/memory.c
+++ mmotm-2.6.34-Mar24/mm/memory.c
@@ -124,13 +124,12 @@ core_initcall(init_zero_pfn);
 
 #if defined(SPLIT_RSS_COUNTING)
 
-void __sync_task_rss_stat(struct task_struct *task, struct mm_struct *mm)
+static void __sync_task_rss_stat(struct task_struct *task, struct mm_struct *mm)
 {
 	int i;
 
 	for (i = 0; i < NR_MM_COUNTERS; i++) {
 		if (task->rss_stat.count[i]) {
-			BUG_ON(!mm);
 			add_mm_counter(mm, i, task->rss_stat.count[i]);
 			task->rss_stat.count[i] = 0;
 		}
Index: mmotm-2.6.34-Mar24/kernel/fork.c
===================================================================
--- mmotm-2.6.34-Mar24.orig/kernel/fork.c
+++ mmotm-2.6.34-Mar24/kernel/fork.c
@@ -1060,6 +1060,9 @@ static struct task_struct *copy_process(
 	p->prev_utime = cputime_zero;
 	p->prev_stime = cputime_zero;
 #endif
+#if defined(SPLIT_RSS_COUNTING)
+	memset(&p->rss_stat, 0, sizeof(p->rss_stat));
+#endif
 
 	p->default_timer_slack_ns = current->timer_slack_ns;
 
Index: mmotm-2.6.34-Mar24/kernel/exit.c
===================================================================
--- mmotm-2.6.34-Mar24.orig/kernel/exit.c
+++ mmotm-2.6.34-Mar24/kernel/exit.c
@@ -950,7 +950,8 @@ NORET_TYPE void do_exit(long code)
 
 	acct_update_integrals(tsk);
 	/* sync mm's RSS info before statistics gathering */
-	sync_mm_rss(tsk, tsk->mm);
+	if (tsk->mm)
+		sync_mm_rss(tsk, tsk->mm);
 	group_dead = atomic_dec_and_test(&tsk->signal->live);
 	if (group_dead) {
 		hrtimer_cancel(&tsk->signal->real_timer);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
