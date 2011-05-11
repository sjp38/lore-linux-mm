Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D84E1900111
	for <linux-mm@kvack.org>; Wed, 11 May 2011 13:17:43 -0400 (EDT)
Received: by mail-px0-f169.google.com with SMTP id 9so599232pxi.14
        for <linux-mm@kvack.org>; Wed, 11 May 2011 10:17:42 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v1 10/10] add tracepoints
Date: Thu, 12 May 2011 02:16:49 +0900
Message-Id: <18652a0d98658a118d52d124b1d9f9c4a9702638.1305132792.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1305132792.git.minchan.kim@gmail.com>
References: <cover.1305132792.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1305132792.git.minchan.kim@gmail.com>
References: <cover.1305132792.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

This patch adds some tracepints for see the effect this patch
series.
This tracepoints isn't for merge but just see the effect.

Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/compaction.c |    2 ++
 mm/migrate.c    |    7 +++++++
 mm/vmscan.c     |    3 +--
 3 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 00e710a..92c180d 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -16,6 +16,7 @@
 #include <linux/sysfs.h>
 #include "internal.h"
 
+#include <trace/events/inorder_putback.h>
 #define CREATE_TRACE_POINTS
 #include <trace/events/compaction.h>
 
@@ -333,6 +334,7 @@ static unsigned long isolate_migratepages(struct zone *zone,
 		if (__isolate_inorder_lru_page(page, mode, 0, &prev_page) != 0)
 			continue;
 
+		trace_mm_compact_isolate(prev_page, page);
 		VM_BUG_ON(PageTransCompound(page));
 
 		/* Successfully isolated */
diff --git a/mm/migrate.c b/mm/migrate.c
index f94fe65..6a2eca9 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -39,6 +39,9 @@
 
 #include "internal.h"
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/inorder_putback.h>
+
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
 
 /*
@@ -96,10 +99,12 @@ void putback_inorder_lru_pages(struct inorder_lru *l)
 		spin_lock_irq(&zone->lru_lock);
 		prev = page->ilru.prev_page;
 		if (keep_lru_order(page, prev)) {
+			trace_mm_compaction_inorder(page, page);
 			putback_page_to_lru(page, prev);
 			spin_unlock_irq(&zone->lru_lock);
 		}
 		else {
+			trace_mm_compaction_outoforder(page, page);
 			spin_unlock_irq(&zone->lru_lock);
 			putback_lru_page(page);
 		}
@@ -1052,6 +1057,7 @@ move_newpage:
 	if (keep_lru_order(page, prev_page)) {
 		putback_page_to_lru(newpage, prev_page);
 		spin_unlock_irq(&zone->lru_lock);
+		trace_mm_compaction_inorder(page, newpage);
 		/*
 		 * The newpage will replace LRU position of old page and
 		 * old one would be freed. So let's adjust prev_page of pages
@@ -1063,6 +1069,7 @@ move_newpage:
 	else {
 
 		spin_unlock_irq(&zone->lru_lock);
+		trace_mm_compaction_inorder(page, newpage);
 		putback_lru_page(newpage);
 	}
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 62d5186..2e7cbad 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -49,10 +49,9 @@
 #include <linux/swapops.h>
 
 #include "internal.h"
-
+#include <trace/events/inorder_putback.h>
 #define CREATE_TRACE_POINTS
 #include <trace/events/vmscan.h>
-
 /*
  * reclaim_mode determines how the inactive list is shrunk
  * RECLAIM_MODE_SINGLE: Reclaim only order-0 pages
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
