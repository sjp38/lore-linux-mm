Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B1B226B006A
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 02:29:47 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o976TiQI028015
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 7 Oct 2010 15:29:45 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A0A345DE60
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 15:29:44 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3CF6E45DE4D
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 15:29:44 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 19D90EF8003
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 15:29:44 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C02CD1DB803A
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 15:29:43 +0900 (JST)
Date: Thu, 7 Oct 2010 15:24:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg: lock-free clear page writeback  (Was Re: [PATCH
 04/10] memcg: disable local interrupts in lock_page_cgroup()
Message-Id: <20101007152422.c5919517.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101007152111.df687a62.kamezawa.hiroyu@jp.fujitsu.com>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
	<1286175485-30643-5-git-send-email-gthelen@google.com>
	<20101005160332.GB9515@barrios-desktop>
	<xr93wrpwkypv.fsf@ninji.mtv.corp.google.com>
	<AANLkTikKXNx-Cj2UY+tJj8ifC+Je5WDbS=eR6xsKM1uU@mail.gmail.com>
	<20101007093545.429fe04a.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007105456.d86d8092.nishimura@mxp.nes.nec.co.jp>
	<20101007111743.322c3993.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007152111.df687a62.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Greg, I think clear_page_writeback() will not require _any_ locks with this patch.
But set_page_writeback() requires it...
(Maybe adding a special function for clear_page_writeback() is better rather than
 adding some complex to switch() in update_page_stat())

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, at page information accounting, we do lock_page_cgroup() if pc->mem_cgroup
points to a cgroup where someone is moving charges from.

At supporing dirty-page accounting, one of troubles is writeback bit.
In general, writeback can be cleared via IRQ context. To update writeback bit
with lock_page_cgroup() in safe way, we'll have to disable IRQ.
....or do something.

This patch waits for completion of writeback under lock_page() and do
lock_page_cgroup() in safe way. (We never got end_io via IRQ context.)

By this, writeback-accounting will never see race with account_move() and
it can trust pc->mem_cgroup always _without_ any lock.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

Index: mmotm-0928/mm/memcontrol.c
===================================================================
--- mmotm-0928.orig/mm/memcontrol.c
+++ mmotm-0928/mm/memcontrol.c
@@ -2183,17 +2183,35 @@ static void __mem_cgroup_move_account(st
 /*
  * check whether the @pc is valid for moving account and call
  * __mem_cgroup_move_account()
+ * Don't call this under pte_lock etc...we'll do lock_page() and wait for
+ * the end of I/O.
  */
 static int mem_cgroup_move_account(struct page_cgroup *pc,
 		struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
 {
 	int ret = -EINVAL;
+
+	/*
+ 	 * We move severl flags and accounting information here. So we need to
+ 	 * avoid the races with update_stat routines. For most of routines,
+ 	 * lock_page_cgroup() is enough for avoiding race. But we need to take
+ 	 * care of IRQ context. If flag updates comes from IRQ context, This
+ 	 * "move account" will be racy (and cause deadlock in lock_page_cgroup())
+ 	 *
+ 	 * Now, the only race we have is Writeback flag. We wait for it cleared
+ 	 * before starting our jobs.
+ 	 */
+
+	lock_page(pc->page);
+	wait_on_page_writeback(pc->page);
+
 	lock_page_cgroup(pc);
 	if (PageCgroupUsed(pc) && pc->mem_cgroup == from) {
 		__mem_cgroup_move_account(pc, from, to, uncharge);
 		ret = 0;
 	}
 	unlock_page_cgroup(pc);
+	unlock_page(pc->page);
 	/*
 	 * check events
 	 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
