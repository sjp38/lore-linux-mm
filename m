Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8797F6B0070
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 07:35:40 -0500 (EST)
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH 3/4] PM / Hibernate : do not count debug pages as savable
Date: Fri, 11 Nov 2011 13:36:33 +0100
Message-Id: <1321014994-2426-3-git-send-email-sgruszka@redhat.com>
In-Reply-To: <1321014994-2426-1-git-send-email-sgruszka@redhat.com>
References: <1321014994-2426-1-git-send-email-sgruszka@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Christoph Lameter <cl@linux-foundation.org>, Stanislaw Gruszka <sgruszka@redhat.com>

When debugging memory corruption with CONFIG_DEBUG_PAGEALLOC and
corrupt_dbg > 0, we have lot of free pages that are not marked so.
Snapshot code account them as savable, what cause hibernate memory
preallocation failure.

It is pretty hard to make hibernate allocation succeed with
corrupt_dbg=1. This change at least make it possible when system has
relatively big amount of RAM.

Acked-by: Rafael J. Wysocki <rjw@sisk.pl>
Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 include/linux/mm.h      |    6 ++++++
 kernel/power/snapshot.c |    6 ++++++
 mm/page_alloc.c         |    6 ------
 3 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 4de55df..6c9268d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1624,8 +1624,14 @@ static inline unsigned int corrupt_dbg(void)
 {
 	return _corrupt_dbg;
 }
+
+static inline bool page_is_corrupt_dbg(struct page *page)
+{
+	return test_bit(PAGE_DEBUG_FLAG_CORRUPT, &page->debug_flags);
+}
 #else
 static inline unsigned int corrupt_dbg(void) { return 0; }
+static inline bool page_is_corrupt_dbg(struct page *page) { return false; }
 #endif /* CONFIG_DEBUG_PAGEALLOC */
 
 #endif /* __KERNEL__ */
diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index cbe2c14..d738e4b 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -858,6 +858,9 @@ static struct page *saveable_highmem_page(struct zone *zone, unsigned long pfn)
 	    PageReserved(page))
 		return NULL;
 
+	if (page_is_corrupt_dbg(page))
+		return NULL;
+
 	return page;
 }
 
@@ -920,6 +923,9 @@ static struct page *saveable_page(struct zone *zone, unsigned long pfn)
 	    && (!kernel_page_present(page) || pfn_is_nosave(pfn)))
 		return NULL;
 
+	if (page_is_corrupt_dbg(page))
+		return NULL;
+
 	return page;
 }
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index de25c82..0dc080d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -431,15 +431,9 @@ static inline void clear_page_corrupt_dbg(struct page *page)
 	__clear_bit(PAGE_DEBUG_FLAG_CORRUPT, &page->debug_flags);
 }
 
-static inline bool page_is_corrupt_dbg(struct page *page)
-{
-	return test_bit(PAGE_DEBUG_FLAG_CORRUPT, &page->debug_flags);
-}
-
 #else
 static inline void set_page_corrupt_dbg(struct page *page) { }
 static inline void clear_page_corrupt_dbg(struct page *page) { }
-static inline bool page_is_corrupt_dbg(struct page *page) { return false; }
 #endif
 
 static inline void set_page_order(struct page *page, int order)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
