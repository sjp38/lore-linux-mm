Message-Id: <200603070230.k272UVg18638@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [PATCH] avoid atomic op on page free
Date: Mon, 6 Mar 2006 18:30:30 -0800
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <440CEA34.1090205@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Nick Piggin' <nickpiggin@yahoo.com.au>, Benjamin LaHaise <bcrl@linux.intel.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote on Monday, March 06, 2006 6:05 PM
> 
> My patches in -mm avoid the lru_lock and disabling/enabling interrupts
> if the page is not on lru too, btw.

Can you put the spin lock/unlock inside TestClearPageLRU()?  The
difference is subtle though.

- Ken


--- ./mm/swap.c.orig	2006-03-06 19:25:10.680967542 -0800
+++ ./mm/swap.c	2006-03-06 19:27:02.334286487 -0800
@@ -210,14 +210,16 @@ int lru_add_drain_all(void)
 void fastcall __page_cache_release(struct page *page)
 {
 	unsigned long flags;
-	struct zone *zone = page_zone(page);
+	struct zone *zone;
 
-	spin_lock_irqsave(&zone->lru_lock, flags);
-	if (TestClearPageLRU(page))
+	if (TestClearPageLRU(page)) {
+		zone = page_zone(page);
+		spin_lock_irqsave(&zone->lru_lock, flags);
 		del_page_from_lru(zone, page);
-	if (page_count(page) != 0)
-		page = NULL;
-	spin_unlock_irqrestore(&zone->lru_lock, flags);
+		if (page_count(page) != 0)
+			page = NULL;
+		spin_unlock_irqrestore(&zone->lru_lock, flags);
+	}
 	if (page)
 		free_hot_page(page);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
