Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B2B256B004D
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 12:45:25 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2K7klrH003220
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 20 Mar 2009 16:46:47 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 06E462AEA82
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 16:46:47 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B44121EF081
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 16:46:46 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 14F80E08011
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 16:46:46 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BCA1E0800B
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 16:46:45 +0900 (JST)
Date: Fri, 20 Mar 2009 16:45:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] fix unused/stale swap cache handling on memcg  v3
Message-Id: <20090320164520.f969907a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <432ace3655a26d2d492a56303369a88a.squirrel@webmail-b.css.fujitsu.com>
References: <20090317135702.4222e62e.nishimura@mxp.nes.nec.co.jp>
	<20090317151113.79a3cc9d.nishimura@mxp.nes.nec.co.jp>
	<20090317162950.70c1245c.kamezawa.hiroyu@jp.fujitsu.com>
	<20090317183850.67c35b27.kamezawa.hiroyu@jp.fujitsu.com>
	<20090318101727.f00dfc2f.nishimura@mxp.nes.nec.co.jp>
	<20090318103418.7d38dce0.kamezawa.hiroyu@jp.fujitsu.com>
	<20090318125154.f8ffe652.nishimura@mxp.nes.nec.co.jp>
	<20090318175734.f5a8a446.kamezawa.hiroyu@jp.fujitsu.com>
	<20090318231738.4e042cbd.d-nishimura@mtf.biglobe.ne.jp>
	<20090319084523.1fbcc3cb.kamezawa.hiroyu@jp.fujitsu.com>
	<20090319111629.dcc9fe43.kamezawa.hiroyu@jp.fujitsu.com>
	<20090319180631.44b0130f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090319190118.db8a1dd7.nishimura@mxp.nes.nec.co.jp>
	<20090319191321.6be9b5e8.nishimura@mxp.nes.nec.co.jp>
	<100477cfc6c3c775abc7aecd4ce8c46e.squirrel@webmail-b.css.fujitsu.com>
	<432ace3655a26d2d492a56303369a88a.squirrel@webmail-b.css.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

I'll test this one in this week end.
Maybe much simpler than previous ones. Thank you for all your help!

-Kame
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Nishimura reported that, in racy case, swap cache is not freed even if
it will be never used. For making use of laziness of LRU, some racy pages
are not freed _interntionally_ and the kernel expects the global LRU will
reclaim it later.

When it comes to memcg, if well controlled, global LRU will not work very
often and above "ok, it's busy, reclaim it later by Global LRU" logic means
leak of swp_entry. Nishimura found that this can cause OOM.

This patch tries to fix this by calling try_to_free_swap() againt the
stale page caches.

Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/swap.h |    2 ++
 mm/memcontrol.c      |   41 +++++++++++++++++++++++++++++++++++++++++
 mm/swapfile.c        |   23 ++++++++++++++++++-----
 mm/vmscan.c          |    9 +++++++++
 4 files changed, 70 insertions(+), 5 deletions(-)

Index: mmotm-2.6.29-Mar11/mm/memcontrol.c
===================================================================
--- mmotm-2.6.29-Mar11.orig/mm/memcontrol.c
+++ mmotm-2.6.29-Mar11/mm/memcontrol.c
@@ -1550,8 +1550,49 @@ void mem_cgroup_uncharge_swap(swp_entry_
 	}
 	rcu_read_unlock();
 }
+
 #endif
 
+/* For handle some racy case. */
+struct memcg_swap_validate {
+	struct work_struct work;
+	struct page *page;
+};
+
+static void mem_cgroup_validate_swapcache_cb(struct work_struct *work)
+{
+	struct memcg_swap_validate *mywork;
+	struct page *page;
+
+	mywork = container_of(work, struct memcg_swap_validate, work);
+	page = mywork->page;
+	/* We can wait lock now....validate swap is still alive or not */
+	lock_page(page);
+	try_to_free_swap(page);
+	unlock_page(page);
+	put_page(page);
+	kfree(mywork);
+	return;
+}
+
+void mem_cgroup_validate_swapcache(struct page *page)
+{
+	struct memcg_swap_validate *work;
+	/*
+	 * Unfortunately, we cannot lock this page here. So, schedule this
+	 * again later.
+	 */
+	get_page(page);
+	work = kmalloc(sizeof(*work), GFP_ATOMIC);
+	if (work) {
+		INIT_WORK(&work->work, mem_cgroup_validate_swapcache_cb);
+		work->page = page;
+		schedule_work(&work->work);
+	} else /* If this small kmalloc() fails, LRU will work and find this */
+		put_page(page);
+	return;
+}
+
 /*
  * Before starting migration, account PAGE_SIZE to mem_cgroup that the old
  * page belongs to.
Index: mmotm-2.6.29-Mar11/mm/swapfile.c
===================================================================
--- mmotm-2.6.29-Mar11.orig/mm/swapfile.c
+++ mmotm-2.6.29-Mar11/mm/swapfile.c
@@ -578,6 +578,7 @@ int free_swap_and_cache(swp_entry_t entr
 {
 	struct swap_info_struct *p;
 	struct page *page = NULL;
+	struct page *check = NULL;
 
 	if (is_migration_entry(entry))
 		return 1;
@@ -586,9 +587,11 @@ int free_swap_and_cache(swp_entry_t entr
 	if (p) {
 		if (swap_entry_free(p, entry) == 1) {
 			page = find_get_page(&swapper_space, entry.val);
-			if (page && !trylock_page(page)) {
-				page_cache_release(page);
-				page = NULL;
+			if (page) {
+				if (!trylock_page(page)) {
+					check = page;
+					page = NULL;
+				}
 			}
 		}
 		spin_unlock(&swap_lock);
@@ -602,10 +605,20 @@ int free_swap_and_cache(swp_entry_t entr
 				(!page_mapped(page) || vm_swap_full())) {
 			delete_from_swap_cache(page);
 			SetPageDirty(page);
-		}
+		} else
+			check = page;
 		unlock_page(page);
-		page_cache_release(page);
+		if (!check)
+			page_cache_release(page);
 	}
+
+	if (check) {
+		/* Check accounting of this page in lazy way.*/
+		if (PageSwapCache(check) && !page_mapped(check))
+			mem_cgroup_validate_swapcache(check);
+		page_cache_release(check);
+	}
+
 	return p != NULL;
 }
 
Index: mmotm-2.6.29-Mar11/mm/vmscan.c
===================================================================
--- mmotm-2.6.29-Mar11.orig/mm/vmscan.c
+++ mmotm-2.6.29-Mar11/mm/vmscan.c
@@ -782,6 +782,15 @@ activate_locked:
 		SetPageActive(page);
 		pgactivate++;
 keep_locked:
+		/*
+		 * This can happen under racy case between unmap and us. If
+		 * a page is added to swapcache while it's unmmaped, the page
+		 * may reach here. Check again this page(swap) is worth to be
+		 * kept.
+		 * (Is this needed to be only under memcg ?
+		 */
+		if (PageSwapCache(page) && !page_mapped(page))
+			try_to_free_swap(page);
 		unlock_page(page);
 keep:
 		list_add(&page->lru, &ret_pages);
Index: mmotm-2.6.29-Mar11/include/linux/swap.h
===================================================================
--- mmotm-2.6.29-Mar11.orig/include/linux/swap.h
+++ mmotm-2.6.29-Mar11/include/linux/swap.h
@@ -337,11 +337,13 @@ static inline void disable_swap_token(vo
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 extern void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent);
+extern void mem_cgroup_validate_swapcache(struct page *page);
 #else
 static inline void
 mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
 {
 }
+static inline void mem_cgroup_validate_swapcache(struct page *page) {}
 #endif
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern void mem_cgroup_uncharge_swap(swp_entry_t ent);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
