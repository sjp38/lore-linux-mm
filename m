Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 71C736B004F
	for <linux-mm@kvack.org>; Mon, 11 May 2009 21:48:19 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4C1n3mK024629
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 12 May 2009 10:49:03 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1861245DE55
	for <linux-mm@kvack.org>; Tue, 12 May 2009 10:49:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E52F245DE51
	for <linux-mm@kvack.org>; Tue, 12 May 2009 10:49:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B76411DB803C
	for <linux-mm@kvack.org>; Tue, 12 May 2009 10:49:02 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5360D1DB8038
	for <linux-mm@kvack.org>; Tue, 12 May 2009 10:48:59 +0900 (JST)
Date: Tue, 12 May 2009 10:47:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 3/3] fix stale swap cache at writeback.
Message-Id: <20090512104730.78bf5ab0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090512104401.28edc0a8.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090512104401.28edc0a8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mingo@elte.hu, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

memcg: free unused swapcache on swapout path

Recaliming anonymous memory in vmscan.c does following 2 steps.
  1. add to swap and unmap.
  2. pageout
But above 2 steps doesn't occur at once. There are many chances
to avoid pageout and _really_ unused pages are swapped out by
visit-and-check-again logic of LRU rotation.
But this behavior has troubles with memcg.

memcg cannot handle !PageCgroupUsed swapcache the owner process of which
has been exited.

This patch is for handling such swap caches created by a race like below:

    Assume processA is exiting and pte points to a page(!PageSwapCache).
    And processB is trying reclaim the page.

              processA                   |           processB
    -------------------------------------+-------------------------------------
      (page_remove_rmap())               |  (shrink_page_list())
         mem_cgroup_uncharge_page()      |
            ->uncharged because it's not |
              PageSwapCache yet.         |
              So, both mem/memsw.usage   |
              are decremented.           |
                                         |    add_to_swap() -> added to swap cache.

    If this page goes thorough without being freed for some reason, this page
    doesn't goes back to memcg's LRU because of !PageCgroupUsed.

These swap cache cannot be freed in memcg's LRU scanning, and swp_entry cannot
be freed properly as a result.
This patch adds a hook after add_to_swap() to check the page is mapped by a
process or not, and frees it if it has been unmapped already.

If a page has been on swap cache already when the owner process calls
page_remove_rmap() -> mem_cgroup_uncharge_page(), the page is not uncharged.
It goes back to memcg's LRU even if it goes through shrink_page_list()
without being freed, so this patch ignores these case.

Changelog: from Nishimura's original one.
 - moved functions to vmscan.c

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
Index: mmotm-2.6.30-May07/mm/vmscan.c
===================================================================
--- mmotm-2.6.30-May07.orig/mm/vmscan.c
+++ mmotm-2.6.30-May07/mm/vmscan.c
@@ -586,6 +586,32 @@ void putback_lru_page(struct page *page)
 }
 #endif /* CONFIG_UNEVICTABLE_LRU */
 
+#if defined(CONFIG_CGROUP_MEM_RES_CTLR) && defined(CONFIG_SWAP)
+
+static int memcg_free_unused_swapcache(struct page *page)
+{
+	VM_BUG_ON(!PageLocked(page));
+	VM_BUG_ON(!PageSwapCache(page));
+
+	if (mem_cgroup_disabled())
+		return 0;
+	/*
+	 * What we do here is checking the page is accounted by memcg or not.
+	 * page_mapped() is enough check for avoding race.
+	 */
+	if (!PageAnon(page) || page_mapped(page))
+		return 0;
+	return try_to_free_swap(page);	/* checks page_swapcount */
+}
+
+#else
+
+static int memcg_free_unused_swapcache(struct page *page)
+{
+	return 0;
+}
+
+#endif
 
 /*
  * shrink_page_list() returns the number of reclaimed pages
@@ -663,6 +689,14 @@ static unsigned long shrink_page_list(st
 				goto keep_locked;
 			if (!add_to_swap(page))
 				goto activate_locked;
+			/*
+			 * The owner process might have uncharged the page
+			 * (by page_remove_rmap()) before it has been added
+			 * to swap cache.
+			 * Check it here to avoid making it stale.
+			 */
+			if (memcg_free_unused_swapcache(page))
+				goto keep_locked;
 			may_enter_fs = 1;
 		}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
