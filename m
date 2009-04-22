Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A007D6B0089
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 23:18:03 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3M3IHJI018928
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 22 Apr 2009 12:18:17 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3901145DE50
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 12:18:17 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 02D0345DE4E
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 12:18:17 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CEDF8E08005
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 12:18:16 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5994E1DB8040
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 12:18:13 +0900 (JST)
Date: Wed, 22 Apr 2009 12:16:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg: remove trylock_page_cgroup
Message-Id: <20090422121641.eb84a07e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090422090218.6d451a08.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090416120316.GG7082@balbir.in.ibm.com>
	<20090417091459.dac2cc39.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417014042.GB18558@balbir.in.ibm.com>
	<20090417110350.3144183d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417034539.GD18558@balbir.in.ibm.com>
	<20090417124951.a8472c86.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417045623.GA3896@balbir.in.ibm.com>
	<20090417141726.a69ebdcc.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417064726.GB3896@balbir.in.ibm.com>
	<20090417155608.eeed1f02.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417141837.GD3896@balbir.in.ibm.com>
	<20090421132551.38e9960a.akpm@linux-foundation.org>
	<20090422090218.6d451a08.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, balbir@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

How about this ? worth to be tested, I think.
-Kame
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Before synchronized-LRU patch, mem cgroup had its own LRU lock.
And there was a code which does
# assume mz as per zone struct of memcg. 

   spin_lock mz->lru_lock
	lock_page_cgroup(pc).
   and
   lock_page_cgroup(pc)
	spin_lock mz->lru_lock

because we cannot locate "mz" until we see pc->page_cgroup, we used
trylock(). But now, we don't have mz->lru_lock. All cgroup
uses zone->lru_lock for handling list. Moreover, manipulation of
LRU depends on global LRU now and we can isolate page from LRU by
very generic way.(isolate_lru_page()).
So, this kind of trylock is not necessary now.

I thought I removed all trylock in synchronized-LRU patch but there
is still one. This patch removes trylock used in memcontrol.c and
its definition. If someone needs, he should add this again with enough
reason.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/page_cgroup.h |    5 -----
 mm/memcontrol.c             |    3 +--
 2 files changed, 1 insertion(+), 7 deletions(-)

Index: mmotm-2.6.30-Apr21/include/linux/page_cgroup.h
===================================================================
--- mmotm-2.6.30-Apr21.orig/include/linux/page_cgroup.h
+++ mmotm-2.6.30-Apr21/include/linux/page_cgroup.h
@@ -61,11 +61,6 @@ static inline void lock_page_cgroup(stru
 	bit_spin_lock(PCG_LOCK, &pc->flags);
 }
 
-static inline int trylock_page_cgroup(struct page_cgroup *pc)
-{
-	return bit_spin_trylock(PCG_LOCK, &pc->flags);
-}
-
 static inline void unlock_page_cgroup(struct page_cgroup *pc)
 {
 	bit_spin_unlock(PCG_LOCK, &pc->flags);
Index: mmotm-2.6.30-Apr21/mm/memcontrol.c
===================================================================
--- mmotm-2.6.30-Apr21.orig/mm/memcontrol.c
+++ mmotm-2.6.30-Apr21/mm/memcontrol.c
@@ -1148,8 +1148,7 @@ static int mem_cgroup_move_account(struc
 	from_mz =  mem_cgroup_zoneinfo(from, nid, zid);
 	to_mz =  mem_cgroup_zoneinfo(to, nid, zid);
 
-	if (!trylock_page_cgroup(pc))
-		return ret;
+	lock_page_cgroup(pc);
 
 	if (!PageCgroupUsed(pc))
 		goto out;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
