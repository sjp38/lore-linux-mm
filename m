Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B4E5F6B004D
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 06:25:20 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5BAQ6p5032271
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 11 Jun 2009 19:26:06 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0AA4345DE4F
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 19:26:06 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D6DED45DE4C
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 19:26:05 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id BEC891DB8040
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 19:26:05 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6FCA41DB803C
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 19:26:05 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH for mmotm 1/5] cleanp page_remove_rmap()
In-Reply-To: <20090611192114.6D4A.A69D9226@jp.fujitsu.com>
References: <20090611192114.6D4A.A69D9226@jp.fujitsu.com>
Message-Id: <20090611192514.6D4D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 11 Jun 2009 19:26:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Subject: [PATCH] cleanp page_remove_rmap()

page_remove_rmap() has multiple PageAnon() test and it has
a bit deeply nesting.

cleanup here.

note: this patch doesn't have behavior change.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Wu Fengguang <fengguang.wu@intel.com> 
---
 mm/rmap.c |   59 ++++++++++++++++++++++++++++++++---------------------------
 1 file changed, 32 insertions(+), 27 deletions(-)

Index: b/mm/rmap.c
===================================================================
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -862,34 +862,39 @@ void page_dup_rmap(struct page *page, st
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
+	if (!atomic_add_negative(-1, &page->_mapcount)) {
+		/* the page is still mapped another one */
+		return;
 	}
+
+	/*
+	 * Now that the last pte has gone, s390 must transfer dirty
+	 * flag from storage key to struct page.  We can usually skip
+	 * this if the page is anon, so about to be freed; but perhaps
+	 * not if it's in swapcache - there might be another pte slot
+	 * containing the swap entry, but page not yet written to swap.
+	 */
+	if ((!PageAnon(page) || PageSwapCache(page)) &&
+		page_test_dirty(page)) {
+		page_clear_dirty(page);
+		set_page_dirty(page);
+	}
+	if (PageAnon(page)) {
+		mem_cgroup_uncharge_page(page);
+		__dec_zone_page_state(page, NR_ANON_PAGES);
+	} else {
+		__dec_zone_page_state(page, NR_FILE_MAPPED);
+	}
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
