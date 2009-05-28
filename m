Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id AE8DB6B0083
	for <linux-mm@kvack.org>; Thu, 28 May 2009 01:22:02 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4S5MLMr009763
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 28 May 2009 14:22:21 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1882B45DE60
	for <linux-mm@kvack.org>; Thu, 28 May 2009 14:22:21 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E37CC45DE64
	for <linux-mm@kvack.org>; Thu, 28 May 2009 14:22:20 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BDC47E08001
	for <linux-mm@kvack.org>; Thu, 28 May 2009 14:22:20 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E547E08004
	for <linux-mm@kvack.org>; Thu, 28 May 2009 14:22:20 +0900 (JST)
Date: Thu, 28 May 2009 14:20:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 3/4] reuse unused swap entry if necessary
Message-Id: <20090528142047.3069543b.kamezawa.hiroyu@jp.fujitsu.com>
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

Now, we can know a swap entry is just used as SwapCache via swap_map,
without looking up swap cache.

Then, we have a chance to reuse swap-cache-only swap entries in
get_swap_pages().

This patch tries to free swap-cache-only swap entries if swap is
not enough.
Note: We hit following path when swap_cluster code cannot find
a free cluster. Then, vm_swap_full() is not only condition to allow
the kernel to reclaim unused swap.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/swapfile.c |   39 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

Index: new-trial-swapcount2/mm/swapfile.c
===================================================================
--- new-trial-swapcount2.orig/mm/swapfile.c
+++ new-trial-swapcount2/mm/swapfile.c
@@ -73,6 +73,25 @@ static inline unsigned short make_swap_c
 	return ret;
 }
 
+static int
+try_to_reuse_swap(struct swap_info_struct *si, unsigned long offset)
+{
+	int type = si - swap_info;
+	swp_entry_t entry = swp_entry(type, offset);
+	struct page *page;
+	int ret = 0;
+
+	page = find_get_page(&swapper_space, entry.val);
+	if (!page)
+		return 0;
+	if (trylock_page(page)) {
+		ret = try_to_free_swap(page);
+		unlock_page(page);
+	}
+	page_cache_release(page);
+	return ret;
+}
+
 /*
  * We need this because the bdev->unplug_fn can sleep and we cannot
  * hold swap_lock while calling the unplug_fn. And swap_lock
@@ -294,6 +313,18 @@ checks:
 		goto no_page;
 	if (offset > si->highest_bit)
 		scan_base = offset = si->lowest_bit;
+
+	/* reuse swap entry of cache-only swap if not busy. */
+	if (vm_swap_full() && si->swap_map[offset] == SWAP_HAS_CACHE) {
+		int ret;
+		spin_unlock(&swap_lock);
+		ret = try_to_reuse_swap(si, offset);
+		spin_lock(&swap_lock);
+		if (ret)
+			goto checks; /* we released swap_lock. retry. */
+		goto scan; /* In some racy case */
+	}
+
 	if (si->swap_map[offset])
 		goto scan;
 
@@ -375,6 +406,10 @@ scan:
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
@@ -386,6 +421,10 @@ scan:
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
