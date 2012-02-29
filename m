Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id C19B16B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 00:27:24 -0500 (EST)
Received: by pbbro12 with SMTP id ro12so377853pbb.14
        for <linux-mm@kvack.org>; Tue, 28 Feb 2012 21:27:23 -0800 (PST)
Date: Tue, 28 Feb 2012 21:26:56 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH next] memcg: fix deadlock by avoiding stat lock when anon
In-Reply-To: <alpine.LSU.2.00.1202282121160.4875@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1202282125240.4875@eggly.anvils>
References: <alpine.LSU.2.00.1202282121160.4875@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Fix deadlock in "memcg: use new logic for page stat accounting".

page_remove_rmap() first calls mem_cgroup_begin_update_page_stat(),
which may take move_lock_mem_cgroup(), unlocked at the end of
page_remove_rmap() by mem_cgroup_end_update_page_stat().

The PageAnon case never needs to mem_cgroup_dec_page_stat(page,
MEMCG_NR_FILE_MAPPED); but it often needs to mem_cgroup_uncharge_page(),
which does lock_page_cgroup(), while holding that move_lock_mem_cgroup().
Whereas mem_cgroup_move_account() calls move_lock_mem_cgroup() while
holding lock_page_cgroup().

Since mem_cgroup_begin and end are unnecessary here for PageAnon,
simply avoid the deadlock and wasted calls in that case.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/rmap.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

--- 3.3-rc5-next/mm/rmap.c	2012-02-26 23:51:46.506050210 -0800
+++ linux/mm/rmap.c	2012-02-27 20:25:56.423324211 -0800
@@ -1166,10 +1166,12 @@ void page_add_file_rmap(struct page *pag
  */
 void page_remove_rmap(struct page *page)
 {
+	bool anon = PageAnon(page);
 	bool locked;
 	unsigned long flags;
 
-	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
+	if (!anon)
+		mem_cgroup_begin_update_page_stat(page, &locked, &flags);
 	/* page still mapped by someone else? */
 	if (!atomic_add_negative(-1, &page->_mapcount))
 		goto out;
@@ -1181,7 +1183,7 @@ void page_remove_rmap(struct page *page)
 	 * not if it's in swapcache - there might be another pte slot
 	 * containing the swap entry, but page not yet written to swap.
 	 */
-	if ((!PageAnon(page) || PageSwapCache(page)) &&
+	if ((!anon || PageSwapCache(page)) &&
 	    page_test_and_clear_dirty(page_to_pfn(page), 1))
 		set_page_dirty(page);
 	/*
@@ -1190,7 +1192,7 @@ void page_remove_rmap(struct page *page)
 	 */
 	if (unlikely(PageHuge(page)))
 		goto out;
-	if (PageAnon(page)) {
+	if (anon) {
 		mem_cgroup_uncharge_page(page);
 		if (!PageTransHuge(page))
 			__dec_zone_page_state(page, NR_ANON_PAGES);
@@ -1211,7 +1213,8 @@ void page_remove_rmap(struct page *page)
 	 * faster for those pages still in swapcache.
 	 */
 out:
-	mem_cgroup_end_update_page_stat(page, &locked, &flags);
+	if (!anon)
+		mem_cgroup_end_update_page_stat(page, &locked, &flags);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
