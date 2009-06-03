Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E7A696B00F7
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:47:12 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <20090603846.816684333@firstfloor.org>
In-Reply-To: <20090603846.816684333@firstfloor.org>
Subject: [PATCH] [11/16] HWPOISON: check and isolate corrupted free pages v2
Message-Id: <20090603184645.68FA21D0286@basil.firstfloor.org>
Date: Wed,  3 Jun 2009 20:46:45 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.com, akpm@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.orgfengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>


From: Wu Fengguang <fengguang.wu@intel.com>

If memory corruption hits the free buddy pages, we can safely ignore them.
No one will access them until page allocation time, then prep_new_page()
will automatically check and isolate PG_hwpoison page for us (for 0-order
allocation).

This patch expands prep_new_page() to check every component page in a high
order page allocation, in order to completely stop PG_hwpoison pages from
being recirculated.

Note that the common case -- only allocating a single page, doesn't
do any more work than before. Allocating > order 0 does a bit more work,
but that's relatively uncommon.

This simple implementation may drop some innocent neighbor pages, hopefully
it is not a big problem because the event should be rare enough.

This patch adds some runtime costs to high order page users.

[AK: Improved description]

v2: Andi Kleen:
Port to -mm code
Move check into separate function.
Don't dump stack in bad_pages for hwpoisoned pages.
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/page_alloc.c |   20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c	2009-06-03 19:37:39.000000000 +0200
+++ linux/mm/page_alloc.c	2009-06-03 20:13:43.000000000 +0200
@@ -237,6 +237,12 @@
 	static unsigned long nr_shown;
 	static unsigned long nr_unshown;
 
+	/* Don't complain about poisoned pages */
+	if (PageHWPoison(page)) {
+		__ClearPageBuddy(page);
+		return;
+	}
+
 	/*
 	 * Allow a burst of 60 reports, then keep quiet for that minute;
 	 * or allow a steady drip of one report per second.
@@ -650,7 +656,7 @@
 /*
  * This page is about to be returned from the page allocator
  */
-static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
+static inline int check_new_page(struct page *page)
 {
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
@@ -659,6 +665,18 @@
 		bad_page(page);
 		return 1;
 	}
+	return 0;
+}
+
+static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
+{
+	int i;
+
+	for (i = 0; i < (1 << order); i++) {
+		struct page *p = page + i;
+		if (unlikely(check_new_page(p)))
+			return 1;
+	}
 
 	set_page_private(page, 0);
 	set_page_refcounted(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
