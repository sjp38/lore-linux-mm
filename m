Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3E6A56B021A
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 06:01:36 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o53A1Yhl012480
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 3 Jun 2010 19:01:34 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DA58045DE4E
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 19:01:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B9FAA45DE4D
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 19:01:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A465B1DB8048
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 19:01:33 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FA541DB8044
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 19:01:33 +0900 (JST)
Date: Thu, 3 Jun 2010 18:57:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/2] memcg: coalescing css_put
Message-Id: <20100603185719.b0957cef.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100603185407.3161e924.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100603185407.3161e924.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

memory cgroup adds a css-refcnt per a page and we decrement it at
uncharge(). Now, we do uncharge in batch if possible. So, css_put()
can be called in batch.

This patch reduces the call of atomic_dec() and make memcg faster
on smp system. And we need small modification for SWAPOUT routine.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

Index: mmotm-2.6.34-May21/mm/memcontrol.c
===================================================================
--- mmotm-2.6.34-May21.orig/mm/memcontrol.c
+++ mmotm-2.6.34-May21/mm/memcontrol.c
@@ -2304,6 +2304,7 @@ direct_uncharge:
 		res_counter_uncharge(&mem->memsw, PAGE_SIZE);
 	if (unlikely(batch->memcg != mem))
 		memcg_oom_recover(mem);
+	css_put(&mem->css);
 	return;
 }
 
@@ -2373,9 +2374,6 @@ __mem_cgroup_uncharge_common(struct page
 	unlock_page_cgroup(pc);
 
 	memcg_check_events(mem, page);
-	/* at swapout, this memcg will be accessed to record to swap */
-	if (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
-		css_put(&mem->css);
 
 	return mem;
 
@@ -2441,6 +2439,7 @@ void mem_cgroup_uncharge_end(void)
 		res_counter_uncharge(&batch->memcg->res, batch->bytes);
 	if (batch->memsw_bytes)
 		res_counter_uncharge(&batch->memcg->memsw, batch->memsw_bytes);
+	__css_put(&batch->memcg->css, batch->bytes/PAGE_SIZE);
 	memcg_oom_recover(batch->memcg);
 	/* forget this pointer (for sanity check) */
 	batch->memcg = NULL;
@@ -2456,19 +2455,22 @@ mem_cgroup_uncharge_swapcache(struct pag
 {
 	struct mem_cgroup *memcg;
 	int ctype = MEM_CGROUP_CHARGE_TYPE_SWAPOUT;
+	struct mem_cgroup *keep = NULL;
 
 	if (!swapout) /* this was a swap cache but the swap is unused ! */
 		ctype = MEM_CGROUP_CHARGE_TYPE_DROP;
+	else
+		keep = try_get_mem_cgroup_from_page(page);
 
 	memcg = __mem_cgroup_uncharge_common(page, ctype);
 
 	/* record memcg information */
-	if (do_swap_account && swapout && memcg) {
+	if (do_swap_account && swapout && memcg && keep == memcg) {
 		swap_cgroup_record(ent, css_id(&memcg->css));
 		mem_cgroup_get(memcg);
 	}
-	if (swapout && memcg)
-		css_put(&memcg->css);
+	if (keep)
+		css_put(&keep->css);
 }
 #endif
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
