Date: Tue, 15 Jul 2008 04:27:48 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [mmotm][PATCH 9/9] restore patch failure of vmstat-unevictable-and-mlocked-pages-vm-events.patch
In-Reply-To: <20080715040402.F6EF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080715040402.F6EF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080715042620.F70A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Patch title:  vmstat-unevictable-and-mlocked-pages-vm-events-restore-patch-failure-hunk.patch
Against: mmotm Jul 14
Applies after: vmstat-unevictable-and-mlocked-pages-vm-events.patch

unevictable-lru-infrastructure-putback_lru_page-rework.patch makes following patch failure hunk.

	---------------------------------------------------------
	@@ -486,6 +486,7 @@ int putback_lru_page(struct page *page)
	 {
	 	int lru;
	 	int ret = 1;
	+	int was_unevictable;
	 
	 	VM_BUG_ON(!PageLocked(page));
	 	VM_BUG_ON(PageLRU(page));
	
	 	lru = !!TestClearPageActive(page);
	-	ClearPageUnevictable(page);	/* for page_evictable() */
	+	was_unevictable = TestClearPageUnevictable(page); /* for page_evictable() */
	 
	 	if (unlikely(!page->mapping)) {
	 		/*
	@@ -511,6 +512,10 @@ int putback_lru_page(struct page *page)
	 		lru += page_is_file_cache(page);
	 		lru_cache_add_lru(page, lru);
	 		mem_cgroup_move_lists(page, lru);
	+#ifdef CONFIG_UNEVICTABLE_LRU
	+		if (was_unevictable)
	+			count_vm_event(NORECL_PGRESCUED);
	+#endif
	 	} else {
	 		/*
	 		 * Put unevictable pages directly on zone's unevictable
	@@ -518,7 +523,10 @@ int putback_lru_page(struct page *page)
 			 */
 			add_page_to_unevictable_list(page);
	 		mem_cgroup_move_lists(page, LRU_UNEVICTABLE);
	+#ifdef CONFIG_UNEVICTABLE_LRU
	+		if (!was_unevictable)
	+			count_vm_event(NORECL_PGCULLED);
	+#endif
	 	}
	 
	 	put_page(page);		/* drop ref from isolate */
	---------------------------------------------------------

This patch restore it properly.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/vmscan.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -483,7 +483,7 @@ int remove_mapping(struct address_space 
 void putback_lru_page(struct page *page)
 {
 	int lru;
-	int ret = 1;
+	int was_unevictable = PageUnevictable(page);
 
 	VM_BUG_ON(PageLRU(page));
 
@@ -526,6 +526,11 @@ redo:
 		 */
 	}
 
+	if (was_unevictable && lru != LRU_UNEVICTABLE)
+		count_vm_event(NORECL_PGRESCUED);
+	else if (!was_unevictable && lru == LRU_UNEVICTABLE)
+		count_vm_event(NORECL_PGCULLED);
+
 	put_page(page);		/* drop ref from isolate */
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
