Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 00AF96B0044
	for <linux-mm@kvack.org>; Mon, 22 Dec 2008 05:23:07 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBMAN4Kq015652
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 22 Dec 2008 19:23:04 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C902F45DD76
	for <linux-mm@kvack.org>; Mon, 22 Dec 2008 19:23:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9601D45DD70
	for <linux-mm@kvack.org>; Mon, 22 Dec 2008 19:23:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C2051DB8043
	for <linux-mm@kvack.org>; Mon, 22 Dec 2008 19:23:04 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CF5561DB803A
	for <linux-mm@kvack.org>; Mon, 22 Dec 2008 19:23:03 +0900 (JST)
Date: Mon, 22 Dec 2008 19:22:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH][mmotm] memcg fix LRU accounting for SwapCache v2
Message-Id: <20081222192205.9eb43c69.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081222155518.bc277de4.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081222155518.bc277de4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

This is fixed verion.
-Kame
==

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, a page can be deleted from SwapCache while do_swap_page().
memcg-fix-swap-accounting-leak-v3.patch handles that, but, LRU handling
is still broken.
(above behavior broke assumption of memcg-synchronized-lru patch.)

This patch is a fix for LRU handling (especially for per-zone counters).
At charging SwapCache,
 - Remove page_cgroup from LRU if it's not used.
 - Add page cgroup to LRU if it's not linked to.

Changelog: (v1)->(v2)
 - fixed mem_cgroup_lru_del_before_commit_swapcache()'s return value.

Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
Index: mmotm-2.6.28-Dec19/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Dec19.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Dec19/mm/memcontrol.c
@@ -331,8 +331,12 @@ void mem_cgroup_del_lru_list(struct page
 		return;
 	pc = lookup_page_cgroup(page);
 	/* can happen while we handle swapcache. */
-	if (list_empty(&pc->lru))
+	if (list_empty(&pc->lru) || !pc->mem_cgroup)
 		return;
+	/*
+	 * We don't check PCG_USED bit. It's cleared when the "page" is finally
+	 * removed from global LRU.
+	 */
 	mz = page_cgroup_zoneinfo(pc);
 	mem = pc->mem_cgroup;
 	MEM_CGROUP_ZSTAT(mz, lru) -= 1;
@@ -379,16 +383,44 @@ void mem_cgroup_add_lru_list(struct page
 	MEM_CGROUP_ZSTAT(mz, lru) += 1;
 	list_add(&pc->lru, &mz->lists[lru]);
 }
+
 /*
- * To add swapcache into LRU. Be careful to all this function.
- * zone->lru_lock shouldn't be held and irq must not be disabled.
+ * At handling SwapCache, pc->mem_cgroup may be changed while it's linked to
+ * lru because the page may.be reused after it's fully uncharged (because of
+ * SwapCache behavior).To handle that, unlink page_cgroup from LRU when charge
+ * it again. This function is only used to charge SwapCache. It's done under
+ * lock_page and expected that zone->lru_lock is never held.
  */
-static void mem_cgroup_lru_fixup(struct page *page)
+static void mem_cgroup_lru_del_before_commit_swapcache(struct page *page)
+{
+	unsigned long flags;
+	struct zone *zone = page_zone(page);
+	struct page_cgroup *pc = lookup_page_cgroup(page);
+
+	spin_lock_irqsave(&zone->lru_lock, flags);
+	/*
+	 * Forget old LRU when this page_cgroup is *not* used. This Used bit
+	 * is guarded by lock_page() because the page is SwapCache.
+	 */
+	if (!PageCgroupUsed(pc))
+		mem_cgroup_del_lru_list(page, page_lru(page));
+	spin_unlock_irqrestore(&zone->lru_lock, flags);
+}
+
+static void mem_cgroup_lru_add_after_commit_swapcache(struct page *page)
 {
-	if (!isolate_lru_page(page))
-		putback_lru_page(page);
+	unsigned long flags;
+	struct zone *zone = page_zone(page);
+	struct page_cgroup *pc = lookup_page_cgroup(page);
+
+	spin_lock_irqsave(&zone->lru_lock, flags);
+	/* link when the page is linked to LRU but page_cgroup isn't */
+	if (PageLRU(page) && list_empty(&pc->lru))
+		mem_cgroup_add_lru_list(page, page_lru(page));
+	spin_unlock_irqrestore(&zone->lru_lock, flags);
 }
 
+
 void mem_cgroup_move_lists(struct page *page,
 			   enum lru_list from, enum lru_list to)
 {
@@ -1161,8 +1193,11 @@ int mem_cgroup_cache_charge_swapin(struc
 					mem = NULL; /* charge to current */
 			}
 		}
+		/* SwapCache may be still linked to LRU now. */
+		mem_cgroup_lru_del_before_commit_swapcache(page);
 		ret = mem_cgroup_charge_common(page, mm, mask,
 				MEM_CGROUP_CHARGE_TYPE_SHMEM, mem);
+		mem_cgroup_lru_add_after_commit_swapcache(page);
 		/* drop extra refcnt from tryget */
 		if (mem)
 			css_put(&mem->css);
@@ -1178,8 +1213,6 @@ int mem_cgroup_cache_charge_swapin(struc
 	}
 	if (!locked)
 		unlock_page(page);
-	/* add this page(page_cgroup) to the LRU we want. */
-	mem_cgroup_lru_fixup(page);
 
 	return ret;
 }
@@ -1194,7 +1227,9 @@ void mem_cgroup_commit_charge_swapin(str
 	if (!ptr)
 		return;
 	pc = lookup_page_cgroup(page);
+	mem_cgroup_lru_del_before_commit_swapcache(page);
 	__mem_cgroup_commit_charge(ptr, pc, MEM_CGROUP_CHARGE_TYPE_MAPPED);
+	mem_cgroup_lru_add_after_commit_swapcache(page);
 	/*
 	 * Now swap is on-memory. This means this page may be
 	 * counted both as mem and swap....double count.
@@ -1213,7 +1248,7 @@ void mem_cgroup_commit_charge_swapin(str
 
 	}
 	/* add this page(page_cgroup) to the LRU we want. */
-	mem_cgroup_lru_fixup(page);
+
 }
 
 void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *mem)
@@ -1281,6 +1316,12 @@ __mem_cgroup_uncharge_common(struct page
 
 	mem_cgroup_charge_statistics(mem, pc, false);
 	ClearPageCgroupUsed(pc);
+	/*
+	 * pc->mem_cgroup is not cleared here. It will be accessed when it's
+	 * freed from LRU. This is safe because uncharged page is expected not
+	 * to be reused (freed soon). Exception is SwapCache, it's handled by
+	 * special functions.
+	 */
 
 	mz = page_cgroup_zoneinfo(pc);
 	unlock_page_cgroup(pc);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
