Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5A5F56B00E9
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 05:16:39 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Postfix) with ESMTP id C942D3EE0B6
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 19:16:35 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A825645DE54
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 19:16:35 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E3D245DE51
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 19:16:35 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DA71EF8006
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 19:16:35 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E61EEF8001
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 19:16:35 +0900 (JST)
Date: Fri, 14 Jan 2011 19:10:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 3/4] [BUGFIX] fix memcgroup LRU stat with THP
Message-Id: <20110114191042.dd145d22.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110114190412.73362cd7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110114190412.73362cd7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, hannes@cmpxchg.org, aarcange@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

memroy cgroup's LRU stat should take care of size of pages because
Transparent Hugepage inserts hugepage into LRU and zone counter
is updeted based on the size of page.

If this value is the number wrong, memory reclaim will not work well.

Note: only head page of THP's huge page is linked into LRU.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

Index: mmotm-0107/mm/memcontrol.c
===================================================================
--- mmotm-0107.orig/mm/memcontrol.c
+++ mmotm-0107/mm/memcontrol.c
@@ -815,7 +815,10 @@ void mem_cgroup_del_lru_list(struct page
 	 * removed from global LRU.
 	 */
 	mz = page_cgroup_zoneinfo(pc);
-	MEM_CGROUP_ZSTAT(mz, lru) -= 1;
+	if (!PageTransHuge(page))
+		MEM_CGROUP_ZSTAT(mz, lru) -= 1;
+	else
+		MEM_CGROUP_ZSTAT(mz, lru) -= 1 << compound_order(page);
 	if (mem_cgroup_is_root(pc->mem_cgroup))
 		return;
 	VM_BUG_ON(list_empty(&pc->lru));
@@ -866,7 +869,10 @@ void mem_cgroup_add_lru_list(struct page
 		return;
 
 	mz = page_cgroup_zoneinfo(pc);
-	MEM_CGROUP_ZSTAT(mz, lru) += 1;
+	if (!PageTransHuge(page))
+		MEM_CGROUP_ZSTAT(mz, lru) += 1;
+	else
+		MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
 	SetPageCgroupAcctLRU(pc);
 	if (mem_cgroup_is_root(pc->mem_cgroup))
 		return;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
