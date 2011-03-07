Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E845D8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 01:07:26 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DB96F3EE0BB
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 15:07:11 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B951145DE59
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 15:07:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A246445DE56
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 15:07:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 93AA3E38005
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 15:07:11 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 559AF1DB8047
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 15:07:11 +0900 (JST)
Date: Mon, 7 Mar 2011 15:00:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg: fix to leave pages on wrong LRU with FUSE.
Message-Id: <20110307150049.d42d046d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, miklos@szeredi.hu

At this point, I'm not sure this is a fix for 
   https://bugzilla.kernel.org/show_bug.cgi?id=30432.

The behavior seems very similar to SwapCache case and this is a possible
bug and this patch can be a fix. Nishimura-san, how do you think ?

But I'm not sure how to test this....please review.

=
fs/fuse/dev.c::fuse_try_move_page() does

   (1) remove a page from page cache by ->steal()
   (2) re-add the page to page cache 
   (3) link the page to LRU if it was _not_ on LRU at (1)


This implies the page can be _on_ LRU when add_to_page_cache_locked() is called.
So, the page is added to a memory cgroup while it's on LRU.

This is the same behavior as SwapCache, 'newly charged pages may be on LRU'
and needs special care as
 - remove page from old memcg's LRU before overwrite pc->mem_cgroup.
 - add page to new memcg's LRU after overwrite pc->mem_cgroup.

So, reusing SwapCache code with renaming for fix.

Note: a page on pagevec(LRU).

If a page is not PageLRU(page) but on pagevec(LRU), it may be added to LRU
while we overwrite page->mapping. But in that case, PCG_USED bit of
the page_cgroup is not set and the page_cgroup will not be added to
wrong memcg's LRU. So, this patch's logic will work fine.
(It has been tested with SwapCache.)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   42 +++++++++++++++++++++++-------------------
 1 file changed, 23 insertions(+), 19 deletions(-)

Index: mmotm-0303/mm/memcontrol.c
===================================================================
--- mmotm-0303.orig/mm/memcontrol.c
+++ mmotm-0303/mm/memcontrol.c
@@ -926,13 +926,12 @@ void mem_cgroup_add_lru_list(struct page
 }
 
 /*
- * At handling SwapCache, pc->mem_cgroup may be changed while it's linked to
- * lru because the page may.be reused after it's fully uncharged (because of
- * SwapCache behavior).To handle that, unlink page_cgroup from LRU when charge
- * it again. This function is only used to charge SwapCache. It's done under
- * lock_page and expected that zone->lru_lock is never held.
+ * At handling SwapCache and other FUSE stuff, pc->mem_cgroup may be changed
+ * while it's linked to lru because the page may be reused after it's fully
+ * uncharged. To handle that, unlink page_cgroup from LRU when charge it again.
+ * It's done under lock_page and expected that zone->lru_lock isnever held.
  */
-static void mem_cgroup_lru_del_before_commit_swapcache(struct page *page)
+static void mem_cgroup_lru_del_before_commit(struct page *page)
 {
 	unsigned long flags;
 	struct zone *zone = page_zone(page);
@@ -948,7 +947,7 @@ static void mem_cgroup_lru_del_before_co
 	spin_unlock_irqrestore(&zone->lru_lock, flags);
 }
 
-static void mem_cgroup_lru_add_after_commit_swapcache(struct page *page)
+static void mem_cgroup_lru_add_after_commit(struct page *page)
 {
 	unsigned long flags;
 	struct zone *zone = page_zone(page);
@@ -2428,7 +2427,7 @@ int mem_cgroup_newpage_charge(struct pag
 }
 
 static void
-__mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
+__mem_cgroup_commit_charge_lrucare(struct page *page, struct mem_cgroup *ptr,
 					enum charge_type ctype);
 
 int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
@@ -2468,17 +2467,22 @@ int mem_cgroup_cache_charge(struct page 
 	if (unlikely(!mm))
 		mm = &init_mm;
 
-	if (page_is_file_cache(page))
-		return mem_cgroup_charge_common(page, mm, gfp_mask,
+	if (page_is_file_cache(page) && !PageLRU(page)) {
+		ret = mem_cgroup_charge_common(page, mm, gfp_mask,
 				MEM_CGROUP_CHARGE_TYPE_CACHE);
-
-	/* shmem */
-	if (PageSwapCache(page)) {
+	} else if (page_is_file_cache(page)) {
+		struct mem_cgroup *mem;
+		/* Page on LRU should be moved to the _new_ LRU */
+		ret = __mem_cgroup_try_charge(mm, gfp_mask, 1, &mem, true);
+		if (!ret)
+			__mem_cgroup_commit_charge_lrucare(page, mem,
+					MEM_CGROUP_CHARGE_TYPE_CACHE);
+	} else if (PageSwapCache(page)) {
 		struct mem_cgroup *mem;
-
 		ret = mem_cgroup_try_charge_swapin(mm, page, gfp_mask, &mem);
+
 		if (!ret)
-			__mem_cgroup_commit_charge_swapin(page, mem,
+			__mem_cgroup_commit_charge_lrucare(page, mem,
 					MEM_CGROUP_CHARGE_TYPE_SHMEM);
 	} else
 		ret = mem_cgroup_charge_common(page, mm, gfp_mask,
@@ -2529,7 +2533,7 @@ charge_cur_mm:
 }
 
 static void
-__mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
+__mem_cgroup_commit_charge_lrucare(struct page *page, struct mem_cgroup *ptr,
 					enum charge_type ctype)
 {
 	struct page_cgroup *pc;
@@ -2540,9 +2544,9 @@ __mem_cgroup_commit_charge_swapin(struct
 		return;
 	cgroup_exclude_rmdir(&ptr->css);
 	pc = lookup_page_cgroup(page);
-	mem_cgroup_lru_del_before_commit_swapcache(page);
+	mem_cgroup_lru_del_before_commit(page);
 	__mem_cgroup_commit_charge(ptr, page, 1, pc, ctype);
-	mem_cgroup_lru_add_after_commit_swapcache(page);
+	mem_cgroup_lru_add_after_commit(page);
 	/*
 	 * Now swap is on-memory. This means this page may be
 	 * counted both as mem and swap....double count.
@@ -2580,7 +2584,7 @@ __mem_cgroup_commit_charge_swapin(struct
 
 void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
 {
-	__mem_cgroup_commit_charge_swapin(page, ptr,
+	__mem_cgroup_commit_charge_lrucare(page, ptr,
 					MEM_CGROUP_CHARGE_TYPE_MAPPED);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
