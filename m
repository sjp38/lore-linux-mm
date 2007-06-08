Date: Fri, 8 Jun 2007 14:39:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: memory unplug v4  [2/6] lru isolation race fix
Message-Id: <20070608143953.93719b3e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070608143531.411c76df.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070608143531.411c76df.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, clameter@sgi.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

release_pages() in mm/swap.c changes page_count() to be 0
without clearing PageLRU flag...

This means isolate_lru_page() can see a page, PageLRU() && page_count(page)==0..
This is BUG. (get_page() will be called against count=0 page.)

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/migrate.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: devel-2.6.22-rc4-mm2/mm/migrate.c
===================================================================
--- devel-2.6.22-rc4-mm2.orig/mm/migrate.c
+++ devel-2.6.22-rc4-mm2/mm/migrate.c
@@ -49,7 +49,7 @@ int isolate_lru_page(struct page *page, 
 		struct zone *zone = page_zone(page);
 
 		spin_lock_irq(&zone->lru_lock);
-		if (PageLRU(page)) {
+		if (page_count(page) && PageLRU(page)) {
 			ret = 0;
 			get_page(page);
 			ClearPageLRU(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
