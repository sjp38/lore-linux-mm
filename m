Date: Sat, 01 Mar 2008 21:13:44 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 06/21] split LRU lists into anon & file sets
In-Reply-To: <20080228192928.412991306@redhat.com>
References: <20080228192908.126720629@redhat.com> <20080228192928.412991306@redhat.com>
Message-Id: <20080301205902.5295.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

>@@ -1128,64 +1026,65 @@ static void shrink_active_list(unsigned 
(snip)
> +	/*
> +	 * For sorting active vs inactive pages, we'll use the 'anon'
> +	 * elements of the local list[] array and sort out the file vs
> +	 * anon pages below.
> +	 */

IMHO this comment implies code is not so good...

I think shrink_active_list should not change to indexed array. 
because this function almost use no indexed array operation.


the following is only explain my intention patch.

---
 mm/vmscan.c |   29 +++++++++++------------------
 1 file changed, 11 insertions(+), 18 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c	2008-03-01 21:11:03.000000000 +0900
+++ b/mm/vmscan.c	2008-03-01 21:13:13.000000000 +0900
@@ -1023,14 +1023,12 @@ static void shrink_active_list(unsigned 
 	int pgdeactivate = 0;
 	unsigned long pgscanned;
 	LIST_HEAD(l_hold);	/* The pages which were snipped off */
-	struct list_head list[NR_LRU_LISTS];
+	LIST_HEAD(l_active);
+	LIST_HEAD(l_inactive);
 	struct page *page;
 	struct pagevec pvec;
 	enum lru_list lru;
 
-	for_each_lru(lru)
-		INIT_LIST_HEAD(&list[lru]);
-
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
 	pgmoved = sc->isolate_pages(nr_pages, &l_hold, &pgscanned, sc->order,
@@ -1048,19 +1046,14 @@ static void shrink_active_list(unsigned 
 		__mod_zone_page_state(zone, NR_ACTIVE_ANON, -pgmoved);
 	spin_unlock_irq(&zone->lru_lock);
 
-	/*
-	 * For sorting active vs inactive pages, we'll use the 'anon'
-	 * elements of the local list[] array and sort out the file vs
-	 * anon pages below.
-	 */
 	while (!list_empty(&l_hold)) {
-		lru = LRU_INACTIVE_ANON;
 		cond_resched();
 		page = lru_to_page(&l_hold);
 		list_del(&page->lru);
 		if (page_referenced(page, 0, sc->mem_cgroup))
-			lru = LRU_ACTIVE_ANON;
-		list_add(&page->lru, &list[lru]);
+			list_add(&page->lru, &l_active);
+		else
+			list_add(&page->lru, &l_inactive);
 	}
 
 	/*
@@ -1071,9 +1064,9 @@ static void shrink_active_list(unsigned 
 	pgmoved = 0;
 	lru = LRU_BASE + file * LRU_FILE;
 	spin_lock_irq(&zone->lru_lock);
-	while (!list_empty(&list[LRU_INACTIVE_ANON])) {
-		page = lru_to_page(&list[LRU_INACTIVE_ANON]);
-		prefetchw_prev_lru_page(page, &list[LRU_INACTIVE_ANON], flags);
+	while (!list_empty(&l_inactive)) {
+		page = lru_to_page(&l_inactive);
+		prefetchw_prev_lru_page(page, &l_inactive, flags);
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 		VM_BUG_ON(!PageActive(page));
@@ -1104,9 +1097,9 @@ static void shrink_active_list(unsigned 
 
 	pgmoved = 0;
 	lru = LRU_ACTIVE + file * LRU_FILE;
-	while (!list_empty(&list[LRU_ACTIVE_ANON])) {
-		page = lru_to_page(&list[LRU_ACTIVE_ANON]);
-		prefetchw_prev_lru_page(page, &list[LRU_ACTIVE_ANON], flags);
+	while (!list_empty(&l_active)) {
+		page = lru_to_page(&l_active);
+		prefetchw_prev_lru_page(page, &l_active, flags);
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 		VM_BUG_ON(!PageActive(page));



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
