Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A70786B003D
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 07:35:11 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1BCZ9u7008762
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 11 Feb 2009 21:35:09 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D018845DD7D
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 21:35:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 80FD145DD7B
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 21:35:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6024C1DB803B
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 21:35:08 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 02DF11DB803C
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 21:35:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/2] mm: update_page_reclaim_stat() is called form page fault path
In-Reply-To: <20090211213201.C3CA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20090211213201.C3CA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20090211213340.C3CD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 11 Feb 2009 21:35:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


Unfortunately, following two patch have a bit conflicted concept.
  1. commit 9ff473b9a72942c5ac0ad35607cae28d8d59ed7a 
     (vmscan: evict streaming IO first)
  2. commit bf3f3bc5e734706730c12a323f9b2068052aa1f0
     (mm: don't mark_page_accessed in fault path)

(1) require page fault update reclaim stat via mark_page_accessed(), but
(2) removed mark_page_accessed() perfectly. 

However, (1) actually only need to update reclaim stat, but not activate page.
Then, fault-path calling update_page_reclaim_stat() solve thsi confliction.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Nick Piggin <npiggin@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>
Cc: Rik van Riel <riel@redhat.com>
---
 include/linux/swap.h |    1 +
 mm/filemap.c         |    1 +
 mm/memory.c          |    2 ++
 mm/swap.c            |   24 +++++++++++++++++++-----
 4 files changed, 23 insertions(+), 5 deletions(-)

Index: b/include/linux/swap.h
===================================================================
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -179,6 +179,7 @@ extern void __lru_cache_add(struct page 
 extern void lru_cache_add_lru(struct page *, enum lru_list lru);
 extern void activate_page(struct page *);
 extern void mark_page_accessed(struct page *);
+extern void update_page_reclaim_stat(struct page *page);
 extern void lru_add_drain(void);
 extern int lru_add_drain_all(void);
 extern void rotate_reclaimable_page(struct page *page);
Index: b/mm/filemap.c
===================================================================
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1545,6 +1545,7 @@ retry_find:
 	/*
 	 * Found the page and have a reference on it.
 	 */
+	update_page_reclaim_stat(page);
 	ra->prev_pos = (loff_t)page->index << PAGE_CACHE_SHIFT;
 	vmf->page = page;
 	return ret | VM_FAULT_LOCKED;
Index: b/mm/memory.c
===================================================================
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2492,6 +2492,8 @@ static int do_swap_page(struct mm_struct
 		try_to_free_swap(page);
 	unlock_page(page);
 
+	update_page_reclaim_stat(page);
+
 	if (write_access) {
 		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl, pte);
 		if (ret & VM_FAULT_ERROR)
Index: b/mm/swap.c
===================================================================
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -151,8 +151,9 @@ void  rotate_reclaimable_page(struct pag
 	}
 }
 
-static void update_page_reclaim_stat(struct zone *zone, struct page *page,
-				     int file, int rotated)
+static void update_page_reclaim_stat_locked(struct zone *zone,
+					    struct page *page,
+					    int file, int rotated)
 {
 	struct zone_reclaim_stat *reclaim_stat = &zone->reclaim_stat;
 	struct zone_reclaim_stat *memcg_reclaim_stat;
@@ -171,6 +172,19 @@ static void update_page_reclaim_stat(str
 		memcg_reclaim_stat->recent_rotated[file]++;
 }
 
+void update_page_reclaim_stat(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+
+	spin_lock_irq(&zone->lru_lock);
+	/* if the page isn't reclaimable, it doesn't update reclaim stat */
+	if (PageLRU(page) && !PageUnevictable(page)) {
+		update_page_reclaim_stat_locked(zone, page,
+					 !!page_is_file_cache(page), 1);
+	}
+	spin_unlock_irq(&zone->lru_lock);
+}
+
 /*
  * FIXME: speed this up?
  */
@@ -182,14 +196,14 @@ void activate_page(struct page *page)
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 		int file = page_is_file_cache(page);
 		int lru = LRU_BASE + file;
-		del_page_from_lru_list(zone, page, lru);
 
+		del_page_from_lru_list(zone, page, lru);
 		SetPageActive(page);
 		lru += LRU_ACTIVE;
 		add_page_to_lru_list(zone, page, lru);
 		__count_vm_event(PGACTIVATE);
 
-		update_page_reclaim_stat(zone, page, !!file, 1);
+		update_page_reclaim_stat_locked(zone, page, !!file, 1);
 	}
 	spin_unlock_irq(&zone->lru_lock);
 }
@@ -427,7 +441,7 @@ void ____pagevec_lru_add(struct pagevec 
 		file = is_file_lru(lru);
 		if (active)
 			SetPageActive(page);
-		update_page_reclaim_stat(zone, page, file, active);
+		update_page_reclaim_stat_locked(zone, page, file, active);
 		add_page_to_lru_list(zone, page, lru);
 	}
 	if (zone)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
