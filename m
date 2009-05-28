Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C79CE6B0087
	for <linux-mm@kvack.org>; Thu, 28 May 2009 01:23:13 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4S5NYic010186
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 28 May 2009 14:23:34 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CBDD045DD7E
	for <linux-mm@kvack.org>; Thu, 28 May 2009 14:23:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9FAC145DD7B
	for <linux-mm@kvack.org>; Thu, 28 May 2009 14:23:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 875041DB803E
	for <linux-mm@kvack.org>; Thu, 28 May 2009 14:23:33 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B2821DB803B
	for <linux-mm@kvack.org>; Thu, 28 May 2009 14:23:30 +0900 (JST)
Date: Thu, 28 May 2009 14:21:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 4/4] memcg: fix swap accounting
Message-Id: <20090528142156.efa97a37.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090528135455.0c83bedc.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090528135455.0c83bedc.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch fixes mis-accounting of swap usage in memcg.

In current implementation, memcg's swap account is uncharged only when
swap is completely freed. But there are several cases where swap
cannot be freed cleanly. For handling that, this patch changes that
memcg uncharges swap account when swap has no references other than cache.

By this, memcg's swap entry accounting can be fully synchronous with
the application's behavior.
This patch also changes memcg's hooks for swap-out.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/swap.h |    5 +++--
 mm/memcontrol.c      |   17 ++++++++++++-----
 mm/swapfile.c        |   14 ++++++++++----
 3 files changed, 25 insertions(+), 11 deletions(-)

Index: new-trial-swapcount2/include/linux/swap.h
===================================================================
--- new-trial-swapcount2.orig/include/linux/swap.h
+++ new-trial-swapcount2/include/linux/swap.h
@@ -338,10 +338,11 @@ static inline void disable_swap_token(vo
 }
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
-extern void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent);
+extern void
+mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, int swapout);
 #else
 static inline void
-mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
+mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, int swapout)
 {
 }
 #endif
Index: new-trial-swapcount2/mm/memcontrol.c
===================================================================
--- new-trial-swapcount2.orig/mm/memcontrol.c
+++ new-trial-swapcount2/mm/memcontrol.c
@@ -189,6 +189,7 @@ enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_SHMEM,	/* used by page migration of shmem */
 	MEM_CGROUP_CHARGE_TYPE_FORCE,	/* used by force_empty */
 	MEM_CGROUP_CHARGE_TYPE_SWAPOUT,	/* for accounting swapcache */
+	MEM_CGROUP_CHARGE_TYPE_DROP,	/* a page was unused swap cache */
 	NR_CHARGE_TYPE,
 };
 
@@ -1501,6 +1502,7 @@ __mem_cgroup_uncharge_common(struct page
 
 	switch (ctype) {
 	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
+	case MEM_CGROUP_CHARGE_TYPE_DROP:
 		if (page_mapped(page))
 			goto unlock_out;
 		break;
@@ -1564,18 +1566,23 @@ void mem_cgroup_uncharge_cache_page(stru
  * called after __delete_from_swap_cache() and drop "page" account.
  * memcg information is recorded to swap_cgroup of "ent"
  */
-void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
+void
+mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, int swapout)
 {
 	struct mem_cgroup *memcg;
+	int ctype = MEM_CGROUP_CHARGE_TYPE_SWAPOUT;
+
+	if (!swapout) /* this was a swap cache but the swap is unused ! */
+		ctype = MEM_CGROUP_CHARGE_TYPE_DROP;
+
+	memcg = __mem_cgroup_uncharge_common(page, ctype);
 
-	memcg = __mem_cgroup_uncharge_common(page,
-					MEM_CGROUP_CHARGE_TYPE_SWAPOUT);
 	/* record memcg information */
-	if (do_swap_account && memcg) {
+	if (do_swap_account && swapout && memcg) {
 		swap_cgroup_record(ent, css_id(&memcg->css));
 		mem_cgroup_get(memcg);
 	}
-	if (memcg)
+	if (swapout && memcg)
 		css_put(&memcg->css);
 }
 #endif
Index: new-trial-swapcount2/mm/swapfile.c
===================================================================
--- new-trial-swapcount2.orig/mm/swapfile.c
+++ new-trial-swapcount2/mm/swapfile.c
@@ -566,8 +566,9 @@ static int swap_entry_free(struct swap_i
 			swap_list.next = p - swap_info;
 		nr_swap_pages++;
 		p->inuse_pages--;
-		mem_cgroup_uncharge_swap(ent);
 	}
+	if (!swap_count(count))
+		mem_cgroup_uncharge_swap(ent);
 	return count;
 }
 
@@ -592,12 +593,17 @@ void swap_free(swp_entry_t entry)
 void swapcache_free(swp_entry_t entry, struct page *page)
 {
 	struct swap_info_struct *p;
+	int ret;
 
-	if (page)
-		mem_cgroup_uncharge_swapcache(page, entry);
 	p = swap_info_get(entry);
 	if (p) {
-		swap_entry_free(p, entry, 1);
+		ret = swap_entry_free(p, entry, 1);
+		if (page) {
+			if (ret)
+				mem_cgroup_uncharge_swapcache(page, entry, 1);
+			else
+				mem_cgroup_uncharge_swapcache(page, entry, 0);
+		}
 		spin_unlock(&swap_lock);
 	}
 	return;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
