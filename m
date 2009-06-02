Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id F3FC36B00AF
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:13:41 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n523DdgN031352
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 2 Jun 2009 12:13:39 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 34BF245DD72
	for <linux-mm@kvack.org>; Tue,  2 Jun 2009 12:13:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 089CD45DD6D
	for <linux-mm@kvack.org>; Tue,  2 Jun 2009 12:13:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 09A4E1DB8013
	for <linux-mm@kvack.org>; Tue,  2 Jun 2009 12:13:39 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AB31E1DB8016
	for <linux-mm@kvack.org>; Tue,  2 Jun 2009 12:13:35 +0900 (JST)
Date: Tue, 2 Jun 2009 12:12:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 3/4] reuse unused swap entry if necessary
Message-Id: <20090602121202.6740a718.kamezawa.hiroyu@jp.fujitsu.com>
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
 mm-reuse-unused-swap-entry-if-necessary.patch in mmotm.
 function is renamed and comments are added.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, we can know the swap is just used as SwapCache via swap_map,
without looking up swap cache.

Then, we have a chance to reuse swap-cache-only swap entries in
get_swap_pages().

This patch tries to free swap-cache-only swap entries if swap is
not enough.
Note: We hit following path when swap_cluster code cannot find
a free cluster. Then, vm_swap_full() is not only condition to allow
the kernel to reclaim unused swap.

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/swapfile.c |   47 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 47 insertions(+)

Index: mmotm-2.6.30-May28/mm/swapfile.c
===================================================================
--- mmotm-2.6.30-May28.orig/mm/swapfile.c
+++ mmotm-2.6.30-May28/mm/swapfile.c
@@ -79,6 +79,32 @@ static inline unsigned short encode_swap
 	return ret;
 }
 
+/* returnes 1 if swap entry is freed */
+static int
+__try_to_reclaim_swap(struct swap_info_struct *si, unsigned long offset)
+{
+	int type = si - swap_info;
+	swp_entry_t entry = swp_entry(type, offset);
+	struct page *page;
+	int ret = 0;
+
+	page = find_get_page(&swapper_space, entry.val);
+	if (!page)
+		return 0;
+	/*
+	 * This function is called from scan_swap_map() and it's called
+	 * by vmscan.c at reclaiming pages. So, we hold a lock on a page, here.
+	 * We have to use trylock for avoiding deadlock. This is a special
+	 * case and you should use try_to_free_swap() with explicit lock_page()
+	 * in usual operations.
+	 */
+	if (trylock_page(page)) {
+		ret = try_to_free_swap(page);
+		unlock_page(page);
+	}
+	page_cache_release(page);
+	return ret;
+}
 
 /*
  * We need this because the bdev->unplug_fn can sleep and we cannot
@@ -301,6 +327,19 @@ checks:
 		goto no_page;
 	if (offset > si->highest_bit)
 		scan_base = offset = si->lowest_bit;
+
+	/* reuse swap entry of cache-only swap if not busy. */
+	if (vm_swap_full() && si->swap_map[offset] == SWAP_HAS_CACHE) {
+		int swap_was_freed;
+		spin_unlock(&swap_lock);
+		swap_was_freed = __try_to_reclaim_swap(si, offset);
+		spin_lock(&swap_lock);
+		/* entry was freed successfully, try to use this again */
+		if (swap_was_freed)
+			goto checks;
+		goto scan; /* check next one */
+	}
+
 	if (si->swap_map[offset])
 		goto scan;
 
@@ -382,6 +421,10 @@ scan:
 			spin_lock(&swap_lock);
 			goto checks;
 		}
+		if (vm_swap_full() && si->swap_map[offset] == SWAP_HAS_CACHE) {
+			spin_lock(&swap_lock);
+			goto checks;
+		}
 		if (unlikely(--latency_ration < 0)) {
 			cond_resched();
 			latency_ration = LATENCY_LIMIT;
@@ -393,6 +436,10 @@ scan:
 			spin_lock(&swap_lock);
 			goto checks;
 		}
+		if (vm_swap_full() && si->swap_map[offset] == SWAP_HAS_CACHE) {
+			spin_lock(&swap_lock);
+			goto checks;
+		}
 		if (unlikely(--latency_ration < 0)) {
 			cond_resched();
 			latency_ration = LATENCY_LIMIT;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
