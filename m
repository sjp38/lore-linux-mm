Received: from programming.kicks-ass.net ([62.194.129.232])
          by amsfep12-int.chello.nl
          (InterMail vM.6.01.04.04 201-2131-118-104-20050224) with SMTP
          id <20050911203429.SOHU2093.amsfep12-int.chello.nl@programming.kicks-ass.net>
          for <linux-mm@kvack.org>; Sun, 11 Sep 2005 22:34:29 +0200
Message-Id: <20050911203433.243939000@twins>
References: <20050911202540.581022000@twins>
Date: Sun, 11 Sep 2005 22:25:44 +0200
From: a.p.zijlstra@chello.nl
Subject: [RFC][PATCH 4/7] CART Implementation v3
Content-Disposition: inline; filename=cart-cart-r.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Index: linux-2.6-git/mm/cart.c
===================================================================
--- linux-2.6-git.orig/mm/cart.c
+++ linux-2.6-git/mm/cart.c
@@ -63,6 +63,7 @@
 
 #define cart_p ((zone)->nr_p)
 #define cart_q ((zone)->nr_q)
+#define cart_r ((zone)->nr_r)
 
 #define size_B1 ((zone)->nr_evicted_active)
 #define size_B2 ((zone)->nr_evicted_inactive)
@@ -81,6 +82,7 @@ void __init cart_init(void)
 		zone->nr_shortterm = 0;
 		zone->nr_p = 0;
 		zone->nr_q = 0;
+		zone->nr_r = 0;
 	}
 }
 
@@ -123,6 +125,12 @@ void __cart_insert(struct zone *zone, st
 	rflags = nonresident_find(page_mapping(page), page_index(page));
 
 	if (rflags & NR_found) {
+		ratio = (nr_Nl / (nr_Ns + 1)) ?: 1;
+		if (cart_r > ratio)
+			cart_r -= ratio;
+		else
+			cart_r = 0UL;
+
 		rflags &= NR_listid;
 		if (rflags == NR_b1) {
 			if (likely(size_B1)) --size_B1;
@@ -149,6 +157,11 @@ void __cart_insert(struct zone *zone, st
 		}
 		/* ++nr_Nl; */
 	} else {
+		ratio = (nr_Ns / (nr_Nl + 1)) ?: 1;
+		cart_r += ratio;
+		if (cart_r > cart_cT)
+			cart_r = cart_cT;
+
 		ClearPageLongTerm(page);
 		++nr_Ns;
 	}
@@ -360,6 +373,7 @@ static unsigned long cart_rebalance_T2(s
  * returns whether there are pages on @l_t1_head
  */
 static unsigned long cart_rebalance_T1(struct zone *zone, struct list_head *l_t1_head,
+				       struct list_head *l_new,
 				       unsigned long nr_dst, unsigned long *nr_scanned,
 				       struct pagevec *pvec)
 {
@@ -384,7 +398,11 @@ static unsigned long cart_rebalance_T1(s
 			referenced = page_referenced(page, 0, 0);
 			new = TestClearPageNew(page);
 
-			if (referenced) {
+			if (cart_r < nr_Nl && PageLongTerm(page) && new) {
+				list_move_tail(&page->lru, l_new);
+				ClearPageActive(page);
+				++dq;
+			} else if (referenced) {
 				list_move_tail(&page->lru, &l_t1);
 				// XXX: we race a bit here; do we mind and put it under lru_lock?
 				/* ( |T1| >= min(p + 1, |B1|) ) and ( filter = 'S' ) */
@@ -432,6 +450,7 @@ unsigned long cart_replace(struct zone *
 			   unsigned long nr_dst, unsigned long *nr_scanned)
 {
 	struct page *page;
+	LIST_HEAD(l_new);
 	LIST_HEAD(l_t1);
 	LIST_HEAD(l_t2);
 	struct pagevec pvec;
@@ -454,12 +473,24 @@ unsigned long cart_replace(struct zone *
 		if (list_empty(&l_t2))
 			cart_rebalance_T2(zone, &l_t2, nr_dst/2, nr_scanned, &pvec);
 		if (list_empty(&l_t1))
-			cart_rebalance_T1(zone, &l_t1, nr_dst/2, nr_scanned, &pvec);
+			cart_rebalance_T1(zone, &l_t1, &l_new, nr_dst/2, nr_scanned, &pvec);
 
 		if (list_empty(&l_t1) && list_empty(&l_t2))
 			break;
 
 		spin_lock_irq(&zone->lru_lock);
+		while (!list_empty(&l_new) && nr < nr_dst) {
+			page = head_to_page(&l_new);
+			prefetchw_next_lru_page(page, &l_new, flags);
+
+			if (!TestClearPageLRU(page))
+				BUG();
+			if (!PageLongTerm(page))
+				BUG();
+			--size_T2;
+			++nr;
+			list_move(&page->lru, dst);
+		}
 		while (!list_empty(&l_t1) &&
 		       (size_T1 > cart_p || !size_T2) && nr < nr_dst) {
 			page = head_to_page(&l_t1);
@@ -496,6 +527,7 @@ unsigned long cart_replace(struct zone *
 	spin_lock_irq(&zone->lru_lock);
 	__cart_list_splice_release(zone, &l_t1, list_T1, &pvec);
 	__cart_list_splice_release(zone, &l_t2, list_T2, &pvec);
+	__cart_list_splice_release(zone, &l_new, list_T2, &pvec);
 	spin_unlock_irq(&zone->lru_lock);
 	pagevec_release(&pvec);
 
Index: linux-2.6-git/include/linux/mmzone.h
===================================================================
--- linux-2.6-git.orig/include/linux/mmzone.h
+++ linux-2.6-git/include/linux/mmzone.h
@@ -155,6 +155,7 @@ struct zone {
 	unsigned long 		nr_shortterm;	/* number of short term pages */
 	unsigned long		nr_p;		/* p from the CART paper */
 	unsigned long 		nr_q;		/* q from the cart paper */
+	unsigned long		nr_r;
 	unsigned long		pages_scanned;	   /* since last reclaim */
 	int			all_unreclaimable; /* All pages pinned */
 

--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
