Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id AED648D0039
	for <linux-mm@kvack.org>; Mon, 17 Jan 2011 21:48:37 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Postfix) with ESMTP id DD99A3EE0B3
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 11:48:34 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C532145DE50
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 11:48:34 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A526F45DE4E
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 11:48:34 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 99786EF8003
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 11:48:34 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 56D1C1DB803A
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 11:48:34 +0900 (JST)
Date: Tue, 18 Jan 2011 11:42:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 3/4] memcg: fix LRU accounting with THP
Message-Id: <20110118114238.ac8fad74.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110118113528.fd24928f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110118113528.fd24928f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

memory cgroup's LRU stat should take care of size of pages because
Transparent Hugepage inserts hugepage into LRU.
If this value is the number wrong, memory reclaim will not work well.

Note: only head page of THP's huge page is linked into LRU.

CHangelog: v2->v3
 - removed PCG_ACCT_LRU fix.
Changelog:
 - fixed to use compound_order() directly.
 - added a counter fix for splitting.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

Index: mmotm-0107/mm/memcontrol.c
===================================================================
--- mmotm-0107.orig/mm/memcontrol.c
+++ mmotm-0107/mm/memcontrol.c
@@ -814,7 +814,8 @@ void mem_cgroup_del_lru_list(struct page
 	 * removed from global LRU.
 	 */
 	mz = page_cgroup_zoneinfo(pc);
-	MEM_CGROUP_ZSTAT(mz, lru) -= 1;
+	/* huge page split is done under lru_lock. so, we have no races. */
+	MEM_CGROUP_ZSTAT(mz, lru) -= 1 << compound_order(page);
 	if (mem_cgroup_is_root(pc->mem_cgroup))
 		return;
 	VM_BUG_ON(list_empty(&pc->lru));
@@ -865,7 +866,8 @@ void mem_cgroup_add_lru_list(struct page
 		return;
 
 	mz = page_cgroup_zoneinfo(pc);
-	MEM_CGROUP_ZSTAT(mz, lru) += 1;
+	/* huge page split is done under lru_lock. so, we have no races. */
+	MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
 	SetPageCgroupAcctLRU(pc);
 	if (mem_cgroup_is_root(pc->mem_cgroup))
 		return;
@@ -2152,14 +2154,26 @@ void mem_cgroup_split_huge_fixup(struct 
 	unsigned long flags;
 
 	/*
-	 * We have no races witch charge/uncharge but will have races with
+	 * We have no races with charge/uncharge but will have races with
 	 * page state accounting.
 	 */
 	move_lock_page_cgroup(head_pc, &flags);
 
 	tail_pc->mem_cgroup = head_pc->mem_cgroup;
 	smp_wmb(); /* see __commit_charge() */
-	/* we don't need to copy all flags...*/
+	if (PageCgroupAcctLRU(head_pc)) {
+		enum lru_list lru;
+		struct mem_cgroup_per_zone *mz;
+
+		/*
+		 * LRU flags cannot be copied because we need to add tail
+		 *.page to LRU by generic call and our hook will be called.
+		 * We hold lru_lock, then, reduce counter directly.
+		 */
+		lru = page_lru(head);
+		mz = page_cgroup_zoneinfo(head_pc);
+		MEM_CGROUP_ZSTAT(mz, lru) -= 1;
+	}
 	tail_pc->flags = head_pc->flags & ~PCGF_NOCOPY_AT_SPLIT;
 	move_unlock_page_cgroup(head_pc, &flags);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
