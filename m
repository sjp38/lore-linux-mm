Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C06E76B004D
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 02:44:52 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5U6kGWI017366
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 30 Jun 2009 15:46:16 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 31FA745DE50
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 15:46:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E65CB45DE4E
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 15:46:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A79FE1DB803E
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 15:46:15 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C939E08001
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 15:46:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] cleanup page_remove_rmap()
Message-Id: <20090630154343.A73F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 30 Jun 2009 15:46:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


sorry for the delay resend.

=================
Subject: [PATCH] cleanup page_remove_rmap()

page_remove_rmap() has multiple PageAnon() test and it has
a bit deeply nesting.

cleanup here.

note: this patch doesn't have behavior change.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/rmap.c |   57 ++++++++++++++++++++++++++++++---------------------------
 1 file changed, 30 insertions(+), 27 deletions(-)

Index: b/mm/rmap.c
===================================================================
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -738,34 +738,37 @@ void page_dup_rmap(struct page *page, st
  */
 void page_remove_rmap(struct page *page)
 {
-	if (atomic_add_negative(-1, &page->_mapcount)) {
-		/*
-		 * Now that the last pte has gone, s390 must transfer dirty
-		 * flag from storage key to struct page.  We can usually skip
-		 * this if the page is anon, so about to be freed; but perhaps
-		 * not if it's in swapcache - there might be another pte slot
-		 * containing the swap entry, but page not yet written to swap.
-		 */
-		if ((!PageAnon(page) || PageSwapCache(page)) &&
-		    page_test_dirty(page)) {
-			page_clear_dirty(page);
-			set_page_dirty(page);
-		}
-		if (PageAnon(page))
-			mem_cgroup_uncharge_page(page);
-		__dec_zone_page_state(page,
-			PageAnon(page) ? NR_ANON_PAGES : NR_FILE_MAPPED);
-		mem_cgroup_update_mapped_file_stat(page, -1);
-		/*
-		 * It would be tidy to reset the PageAnon mapping here,
-		 * but that might overwrite a racing page_add_anon_rmap
-		 * which increments mapcount after us but sets mapping
-		 * before us: so leave the reset to free_hot_cold_page,
-		 * and remember that it's only reliable while mapped.
-		 * Leaving it set also helps swapoff to reinstate ptes
-		 * faster for those pages still in swapcache.
-		 */
+	/* page still mapped by someone else? */
+	if (!atomic_add_negative(-1, &page->_mapcount))
+		return;
+
+	/*
+	 * Now that the last pte has gone, s390 must transfer dirty
+	 * flag from storage key to struct page.  We can usually skip
+	 * this if the page is anon, so about to be freed; but perhaps
+	 * not if it's in swapcache - there might be another pte slot
+	 * containing the swap entry, but page not yet written to swap.
+	 */
+	if ((!PageAnon(page) || PageSwapCache(page)) && page_test_dirty(page)) {
+		page_clear_dirty(page);
+		set_page_dirty(page);
+	}
+	if (PageAnon(page)) {
+		mem_cgroup_uncharge_page(page);
+		__dec_zone_page_state(page, NR_ANON_PAGES);
+	} else {
+		__dec_zone_page_state(page, NR_FILE_MAPPED);
 	}
+	mem_cgroup_update_mapped_file_stat(page, -1);
+	/*
+	 * It would be tidy to reset the PageAnon mapping here,
+	 * but that might overwrite a racing page_add_anon_rmap
+	 * which increments mapcount after us but sets mapping
+	 * before us: so leave the reset to free_hot_cold_page,
+	 * and remember that it's only reliable while mapped.
+	 * Leaving it set also helps swapoff to reinstate ptes
+	 * faster for those pages still in swapcache.
+	 */
 }
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
