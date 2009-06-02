Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 16F126B00DE
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:52:16 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n523G4fK007393
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 2 Jun 2009 12:16:05 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A03BB45DE4F
	for <linux-mm@kvack.org>; Tue,  2 Jun 2009 12:16:04 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 801E445DE4D
	for <linux-mm@kvack.org>; Tue,  2 Jun 2009 12:16:04 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 683C01DB807E
	for <linux-mm@kvack.org>; Tue,  2 Jun 2009 12:16:04 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 175911DB8038
	for <linux-mm@kvack.org>; Tue,  2 Jun 2009 12:16:04 +0900 (JST)
Date: Tue, 2 Jun 2009 12:14:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 4/4] memcg fix swap accounting
Message-Id: <20090602121431.01c6f770.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090602120425.0bcff554.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090602120425.0bcff554.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This is a replacement for 
  memcg-fix-swap-accounting.patch in mmotm.
Adjusted to style changes in 2/4 and 3/4.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch fixes mis-accounting of swap usage in memcg.

In current implementation, memcg's swap account is uncharged only when
swap is completely freed. But there are several cases where swap
cannot be freed cleanly. For handling that, this patch changes that
memcg uncharges swap account when swap has no references other than cache.

By this, memcg's swap entry accounting can be fully synchronous with
the application's behavior.
This patch also changes memcg's hooks for swap-out.
(If delete_from_swap_cache() is called but there is no swap-reference,
 charge to swaps doesn't occur.
 (the charge for mem+swap is attached to the page itself if mapped)

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/swap.h |    5 +++--
 mm/memcontrol.c      |   17 ++++++++++++-----
 mm/swapfile.c        |   16 ++++++++++++----
 3 files changed, 27 insertions(+), 11 deletions(-)

Index: mmotm-2.6.30-May28/include/linux/swap.h
===================================================================
--- mmotm-2.6.30-May28.orig/include/linux/swap.h
+++ mmotm-2.6.30-May28/include/linux/swap.h
@@ -319,10 +319,11 @@ static inline void disable_swap_token(vo
 }
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
-extern void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent);
+extern void
+mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout);
 #else
 static inline void
-mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
+mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
 {
 }
 #endif
Index: mmotm-2.6.30-May28/mm/memcontrol.c
===================================================================
--- mmotm-2.6.30-May28.orig/mm/memcontrol.c
+++ mmotm-2.6.30-May28/mm/memcontrol.c
@@ -189,6 +189,7 @@ enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_SHMEM,	/* used by page migration of shmem */
 	MEM_CGROUP_CHARGE_TYPE_FORCE,	/* used by force_empty */
 	MEM_CGROUP_CHARGE_TYPE_SWAPOUT,	/* for accounting swapcache */
+	MEM_CGROUP_CHARGE_TYPE_DROP,	/* a page was unused swap cache */
 	NR_CHARGE_TYPE,
 };
 
@@ -1493,6 +1494,7 @@ __mem_cgroup_uncharge_common(struct page
 
 	switch (ctype) {
 	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
+	case MEM_CGROUP_CHARGE_TYPE_DROP:
 		if (page_mapped(page))
 			goto unlock_out;
 		break;
@@ -1556,18 +1558,23 @@ void mem_cgroup_uncharge_cache_page(stru
  * called after __delete_from_swap_cache() and drop "page" account.
  * memcg information is recorded to swap_cgroup of "ent"
  */
-void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
+void
+mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
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
Index: mmotm-2.6.30-May28/mm/swapfile.c
===================================================================
--- mmotm-2.6.30-May28.orig/mm/swapfile.c
+++ mmotm-2.6.30-May28/mm/swapfile.c
@@ -583,8 +583,9 @@ static int swap_entry_free(struct swap_i
 			swap_list.next = p - swap_info;
 		nr_swap_pages++;
 		p->inuse_pages--;
-		mem_cgroup_uncharge_swap(ent);
 	}
+	if (!swap_count(count))
+		mem_cgroup_uncharge_swap(ent);
 	return count;
 }
 
@@ -609,12 +610,19 @@ void swap_free(swp_entry_t entry)
 void swapcache_free(swp_entry_t entry, struct page *page)
 {
 	struct swap_info_struct *p;
+	int ret;
 
-	if (page)
-		mem_cgroup_uncharge_swapcache(page, entry);
 	p = swap_info_get(entry);
 	if (p) {
-		swap_entry_free(p, entry, SWAP_CACHE);
+		ret = swap_entry_free(p, entry, SWAP_CACHE);
+		if (page) {
+			bool swapout;
+			if (ret)
+				swapout = true; /* the end of swap out */
+			else
+				swapout = false; /* no more swap users! */
+			mem_cgroup_uncharge_swapcache(page, entry, swapout);
+		}
 		spin_unlock(&swap_lock);
 	}
 	return;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
