Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 8596A6B0033
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 08:24:12 -0400 (EDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 1/7] mm: putback_lru_page: remove unnecessary call to page_lru_base_type()
Date: Mon, 19 Aug 2013 14:23:36 +0200
Message-Id: <1376915022-12741-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1376915022-12741-1-git-send-email-vbabka@suse.cz>
References: <1376915022-12741-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: =?UTF-8?q?J=C3=B6rn=20Engel?= <joern@logfs.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

In putback_lru_page() since commit c53954a092 (""mm: remove lru parameter from
__lru_cache_add and lru_cache_add_lru") it is no longer needed to determine lru
list via page_lru_base_type().

This patch replaces it with simple flag is_unevictable which says that the page
was put on the inevictable list. This is the only information that matters in
subsequent tests.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Reviewed-by: JA?rn Engel <joern@logfs.org>
---
 mm/vmscan.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2cff0d4..0fa537e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -545,7 +545,7 @@ int remove_mapping(struct address_space *mapping, struct page *page)
  */
 void putback_lru_page(struct page *page)
 {
-	int lru;
+	bool is_unevictable;
 	int was_unevictable = PageUnevictable(page);
 
 	VM_BUG_ON(PageLRU(page));
@@ -560,14 +560,14 @@ redo:
 		 * unevictable page on [in]active list.
 		 * We know how to handle that.
 		 */
-		lru = page_lru_base_type(page);
+		is_unevictable = false;
 		lru_cache_add(page);
 	} else {
 		/*
 		 * Put unevictable pages directly on zone's unevictable
 		 * list.
 		 */
-		lru = LRU_UNEVICTABLE;
+		is_unevictable = true;
 		add_page_to_unevictable_list(page);
 		/*
 		 * When racing with an mlock or AS_UNEVICTABLE clearing
@@ -587,7 +587,7 @@ redo:
 	 * page is on unevictable list, it never be freed. To avoid that,
 	 * check after we added it to the list, again.
 	 */
-	if (lru == LRU_UNEVICTABLE && page_evictable(page)) {
+	if (is_unevictable && page_evictable(page)) {
 		if (!isolate_lru_page(page)) {
 			put_page(page);
 			goto redo;
@@ -598,9 +598,9 @@ redo:
 		 */
 	}
 
-	if (was_unevictable && lru != LRU_UNEVICTABLE)
+	if (was_unevictable && !is_unevictable)
 		count_vm_event(UNEVICTABLE_PGRESCUED);
-	else if (!was_unevictable && lru == LRU_UNEVICTABLE)
+	else if (!was_unevictable && is_unevictable)
 		count_vm_event(UNEVICTABLE_PGCULLED);
 
 	put_page(page);		/* drop ref from isolate */
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
