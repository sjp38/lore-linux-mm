Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA67bAMI019229
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 6 Nov 2008 16:37:10 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D29845DD7D
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 16:37:10 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A5F145DD81
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 16:37:10 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 05671E08005
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 16:37:10 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A641C1DB8037
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 16:37:09 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] mm: get rid of pagevec_release_nonlru()
Message-Id: <20081106162839.0D3A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  6 Nov 2008 16:37:08 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

speculative page references patch (commit: e286781d5f2e9c846e012a39653a166e9d31777d)
removed last pagevec_release_nonlru() caller.

So, its function can be removed now.

this patch doesn't have any functional change.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Nick Piggin <npiggin@suse.de>

---
 include/linux/pagevec.h |    7 -------
 mm/swap.c               |   22 ----------------------
 2 files changed, 29 deletions(-)

Index: b/include/linux/pagevec.h
===================================================================
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -21,7 +21,6 @@ struct pagevec {
 };
 
 void __pagevec_release(struct pagevec *pvec);
-void __pagevec_release_nonlru(struct pagevec *pvec);
 void __pagevec_free(struct pagevec *pvec);
 void ____pagevec_lru_add(struct pagevec *pvec, enum lru_list lru);
 void pagevec_strip(struct pagevec *pvec);
@@ -69,12 +68,6 @@ static inline void pagevec_release(struc
 		__pagevec_release(pvec);
 }
 
-static inline void pagevec_release_nonlru(struct pagevec *pvec)
-{
-	if (pagevec_count(pvec))
-		__pagevec_release_nonlru(pvec);
-}
-
 static inline void pagevec_free(struct pagevec *pvec)
 {
 	if (pagevec_count(pvec))
Index: b/mm/swap.c
===================================================================
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -411,28 +411,6 @@ void __pagevec_release(struct pagevec *p
 EXPORT_SYMBOL(__pagevec_release);
 
 /*
- * pagevec_release() for pages which are known to not be on the LRU
- *
- * This function reinitialises the caller's pagevec.
- */
-void __pagevec_release_nonlru(struct pagevec *pvec)
-{
-	int i;
-	struct pagevec pages_to_free;
-
-	pagevec_init(&pages_to_free, pvec->cold);
-	for (i = 0; i < pagevec_count(pvec); i++) {
-		struct page *page = pvec->pages[i];
-
-		VM_BUG_ON(PageLRU(page));
-		if (put_page_testzero(page))
-			pagevec_add(&pages_to_free, page);
-	}
-	pagevec_free(&pages_to_free);
-	pagevec_reinit(pvec);
-}
-
-/*
  * Add the passed pages to the LRU, then drop the caller's refcount
  * on them.  Reinitialises the caller's pagevec.
  */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
