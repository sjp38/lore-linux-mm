Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C61138D0069
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 01:43:34 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 250373EE0B5
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 15:43:33 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id ECDB145DE52
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 15:43:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CAED145DE50
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 15:43:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BD4EAEF8003
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 15:43:32 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8785B1DB8037
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 15:43:32 +0900 (JST)
Date: Fri, 21 Jan 2011 15:37:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/7] memcg : comment, style fixes for recent patch of
 move_parent
Message-Id: <20110121153726.54f4a159.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110121153431.191134dd.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110121153431.191134dd.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

A fix for 987eba66e0e6aa654d60881a14731a353ee0acb4

A clean up for mem_cgroup_move_parent(). 
 - remove unnecessary initialization of local variable.
 - rename charge_size -> page_size
 - remove unnecessary (wrong) comment.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

Index: mmotm-0107/mm/memcontrol.c
===================================================================
--- mmotm-0107.orig/mm/memcontrol.c
+++ mmotm-0107/mm/memcontrol.c
@@ -2265,7 +2265,7 @@ static int mem_cgroup_move_parent(struct
 	struct cgroup *cg = child->css.cgroup;
 	struct cgroup *pcg = cg->parent;
 	struct mem_cgroup *parent;
-	int charge = PAGE_SIZE;
+	int page_size;
 	unsigned long flags;
 	int ret;
 
@@ -2278,22 +2278,23 @@ static int mem_cgroup_move_parent(struct
 		goto out;
 	if (isolate_lru_page(page))
 		goto put;
-	/* The page is isolated from LRU and we have no race with splitting */
-	charge = PAGE_SIZE << compound_order(page);
+
+	page_size = PAGE_SIZE << compound_order(page);
 
 	parent = mem_cgroup_from_cont(pcg);
-	ret = __mem_cgroup_try_charge(NULL, gfp_mask, &parent, false, charge);
+	ret = __mem_cgroup_try_charge(NULL, gfp_mask,
+				&parent, false, page_size);
 	if (ret || !parent)
 		goto put_back;
 
-	if (charge > PAGE_SIZE)
+	if (page_size > PAGE_SIZE)
 		flags = compound_lock_irqsave(page);
 
-	ret = mem_cgroup_move_account(pc, child, parent, true, charge);
+	ret = mem_cgroup_move_account(pc, child, parent, true, page_size);
 	if (ret)
-		mem_cgroup_cancel_charge(parent, charge);
+		mem_cgroup_cancel_charge(parent, page_size);
 put_back:
-	if (charge > PAGE_SIZE)
+	if (page_size > PAGE_SIZE)
 		compound_unlock_irqrestore(page, flags);
 	putback_lru_page(page);
 put:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
