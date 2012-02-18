Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id C7B156B012B
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 19:00:49 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so5222128pbc.14
        for <linux-mm@kvack.org>; Fri, 17 Feb 2012 16:00:49 -0800 (PST)
Date: Fri, 17 Feb 2012 16:00:14 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: move buffer_heads_over_limit check up
Message-ID: <alpine.LSU.2.00.1202171557040.1286@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

Not a functional change, just a minor internal cleanup: move the
buffer_heads_over_limit processing up from move_active_pages_to_lru()
(where it has to drop lock and reloop) to its caller shrink_active_list().

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/vmscan.c |   19 +++++++------------
 1 file changed, 7 insertions(+), 12 deletions(-)

--- mmotm.orig/mm/vmscan.c	2012-02-07 16:59:13.000000000 -0800
+++ mmotm/mm/vmscan.c	2012-02-07 17:07:23.800524771 -0800
@@ -1641,18 +1641,6 @@ static void move_active_pages_to_lru(str
 	unsigned long pgmoved = 0;
 	struct page *page;
 
-	if (buffer_heads_over_limit) {
-		spin_unlock_irq(&zone->lru_lock);
-		list_for_each_entry(page, list, lru) {
-			if (page_has_private(page) && trylock_page(page)) {
-				if (page_has_private(page))
-					try_to_release_page(page, 0);
-				unlock_page(page);
-			}
-		}
-		spin_lock_irq(&zone->lru_lock);
-	}
-
 	while (!list_empty(list)) {
 		struct lruvec *lruvec;
 
@@ -1734,6 +1722,13 @@ static void shrink_active_list(unsigned
 			continue;
 		}
 
+		if (buffer_heads_over_limit &&
+		    page_has_private(page) && trylock_page(page)) {
+			if (page_has_private(page))
+				try_to_release_page(page, 0);
+			unlock_page(page);
+		}
+
 		if (page_referenced(page, 0, mz->mem_cgroup, &vm_flags)) {
 			nr_rotated += hpage_nr_pages(page);
 			/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
