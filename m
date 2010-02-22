Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4BBAA6B004D
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 14:49:42 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/3] vmscan: factor out page reference checks
Date: Mon, 22 Feb 2010 20:49:08 +0100
Message-Id: <1266868150-25984-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1266868150-25984-1-git-send-email-hannes@cmpxchg.org>
References: <1266868150-25984-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Moving the big conditional into its own predicate function makes the
code a bit easier to read and allows for better commenting on the
checks one-by-one.

This is just cleaning up, no semantics should have been changed.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c |   53 ++++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 40 insertions(+), 13 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c26986c..c2db55b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -579,6 +579,37 @@ redo:
 	put_page(page);		/* drop ref from isolate */
 }
 
+enum page_references {
+	PAGEREF_RECLAIM,
+	PAGEREF_RECLAIM_CLEAN,
+	PAGEREF_ACTIVATE,
+};
+
+static enum page_references page_check_references(struct page *page,
+						  struct scan_control *sc)
+{
+	unsigned long vm_flags;
+	int referenced;
+
+	referenced = page_referenced(page, 1, sc->mem_cgroup, &vm_flags);
+	if (!referenced)
+		return PAGEREF_RECLAIM;
+
+	/* Lumpy reclaim - ignore references */
+	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
+		return PAGEREF_RECLAIM;
+
+	/* Mlock lost isolation race - let try_to_unmap() handle it */
+	if (vm_flags & VM_LOCKED)
+		return PAGEREF_RECLAIM;
+
+	if (page_mapping_inuse(page))
+		return PAGEREF_ACTIVATE;
+
+	/* Reclaim if clean, defer dirty pages to writeback */
+	return PAGEREF_RECLAIM_CLEAN;
+}
+
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
@@ -590,16 +621,15 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 	struct pagevec freed_pvec;
 	int pgactivate = 0;
 	unsigned long nr_reclaimed = 0;
-	unsigned long vm_flags;
 
 	cond_resched();
 
 	pagevec_init(&freed_pvec, 1);
 	while (!list_empty(page_list)) {
+		enum page_references references;
 		struct address_space *mapping;
 		struct page *page;
 		int may_enter_fs;
-		int referenced;
 
 		cond_resched();
 
@@ -641,17 +671,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto keep_locked;
 		}
 
-		referenced = page_referenced(page, 1,
-						sc->mem_cgroup, &vm_flags);
-		/*
-		 * In active use or really unfreeable?  Activate it.
-		 * If page which have PG_mlocked lost isoltation race,
-		 * try_to_unmap moves it to unevictable list
-		 */
-		if (sc->order <= PAGE_ALLOC_COSTLY_ORDER &&
-					referenced && page_mapping_inuse(page)
-					&& !(vm_flags & VM_LOCKED))
+		references = page_check_references(page, sc);
+		switch (references) {
+		case PAGEREF_ACTIVATE:
 			goto activate_locked;
+		case PAGEREF_RECLAIM:
+		case PAGEREF_RECLAIM_CLEAN:
+			; /* try to reclaim the page below */
+		}
 
 		/*
 		 * Anonymous process memory has backing store?
@@ -685,7 +712,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		}
 
 		if (PageDirty(page)) {
-			if (sc->order <= PAGE_ALLOC_COSTLY_ORDER && referenced)
+			if (references == PAGEREF_RECLAIM_CLEAN)
 				goto keep_locked;
 			if (!may_enter_fs)
 				goto keep_locked;
-- 
1.6.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
