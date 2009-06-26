Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8603E6B0055
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 20:57:31 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5Q0xJox004748
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 26 Jun 2009 09:59:19 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E008E45DE53
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 09:59:18 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id BD30545DE50
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 09:59:18 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9AB021DB803A
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 09:59:18 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 555A51DB8038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 09:59:18 +0900 (JST)
Date: Fri, 26 Jun 2009 09:57:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg: add commens for expaing memory barrier (Was Re: Low
 overhead patches for the memory cgroup controller (v5)
Message-Id: <20090626095745.01cef410.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090623090116.556d4f97.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090615043900.GF23577@balbir.in.ibm.com>
	<20090622154343.9cdbf23a.akpm@linux-foundation.org>
	<20090623090116.556d4f97.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, balbir@linux.vnet.ibm.com, kamezawa.hiroyuki@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, lizf@cn.fujitsu.com, menage@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Jun 2009 09:01:16 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Do we still need the smp_wmb()?
> > 
> > It's hard to say, because we forgot to document it :(
> > 
> Sorry for lack of documentation.
> 
> pc->mem_cgroup should be visible before SetPageCgroupUsed(). Othrewise,
> A routine believes USED bit will see bad pc->mem_cgroup.
> 
> I'd like to  add a comment later (againt new mmotm.)
> 

Ok, it's now.
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Add comments for the reason of smp_wmb() in mem_cgroup_commit_charge().

Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |    7 +++++++
 1 file changed, 7 insertions(+)

Index: mmotm-2.6.31-Jun25/mm/memcontrol.c
===================================================================
--- mmotm-2.6.31-Jun25.orig/mm/memcontrol.c
+++ mmotm-2.6.31-Jun25/mm/memcontrol.c
@@ -1134,6 +1134,13 @@ static void __mem_cgroup_commit_charge(s
 	}
 
 	pc->mem_cgroup = mem;
+	/*
+ 	 * We access a page_cgroup asynchronously without lock_page_cgroup().
+ 	 * Especially when a page_cgroup is taken from a page, pc->mem_cgroup
+ 	 * is accessed after testing USED bit. To make pc->mem_cgroup visible
+ 	 * before USED bit, we need memory barrier here.
+ 	 * See mem_cgroup_add_lru_list(), etc.
+ 	 */
 	smp_wmb();
 	switch (ctype) {
 	case MEM_CGROUP_CHARGE_TYPE_CACHE:


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
