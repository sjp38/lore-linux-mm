Message-Id: <200708232107.l7NL7XDt026979@imap1.linux-foundation.org>
Subject: [patch 1/1] alloc_pages(): permit get_zeroed_page(GFP_ATOMIC) from interrupt context
From: akpm@linux-foundation.org
Date: Thu, 23 Aug 2007 14:07:33 -0700
Sender: owner-linux-mm@kvack.org
From: Andrew Morton <akpm@linux-foundation.org>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, thomas.jarosch@intra2net.com
List-ID: <linux-mm.kvack.org>

See http://bugzilla.kernel.org/show_bug.cgi?id=8928

I think it makes sense to permit a non-BUGging get_zeroed_page(GFP_ATOMIC)
from interrupt context.

We could fix this in several places, but I do think we want to keep the sanity
checks in kmap_atomic() even for non-highmem pages, so that people who are
testing new code on non-highmem machines get their bugs detected earlier.

Cc: Thomas Jarosch <thomas.jarosch@intra2net.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/page_alloc.c |   26 +++++++++++++++++++-------
 1 files changed, 19 insertions(+), 7 deletions(-)

diff -puN mm/page_alloc.c~alloc_pages-permit-get_zeroed_pagegfp_atomic-from-interrupt-context mm/page_alloc.c
--- a/mm/page_alloc.c~alloc_pages-permit-get_zeroed_pagegfp_atomic-from-interrupt-context
+++ a/mm/page_alloc.c
@@ -284,13 +284,25 @@ static inline void prep_zero_page(struct
 	int i;
 
 	VM_BUG_ON((gfp_flags & (__GFP_WAIT | __GFP_HIGHMEM)) == __GFP_HIGHMEM);
-	/*
-	 * clear_highpage() will use KM_USER0, so it's a bug to use __GFP_ZERO
-	 * and __GFP_HIGHMEM from hard or soft interrupt context.
-	 */
-	VM_BUG_ON((gfp_flags & __GFP_HIGHMEM) && in_interrupt());
-	for (i = 0; i < (1 << order); i++)
-		clear_highpage(page + i);
+	if (gfp_flags & __GFP_HIGHMEM) {
+		/*
+		 * clear_highpage() will use KM_USER0, so it's a bug to use
+		 * __GFP_ZERO and __GFP_HIGHMEM from hard or soft interrupt
+		 * context.
+		 */
+		VM_BUG_ON(in_interrupt());
+		for (i = 0; i < (1 << order); i++)
+			clear_highpage(page + i);
+	} else {
+		/*
+		 * Go direct to clear_page(), because the caller might be
+		 * performing a non-highmem GFP_ZERO allocation from interrupt
+		 * context.  kmap_atomic() will go BUG when that happens, but it
+		 * is a legitimate thing to do
+		 */
+		for (i = 0; i < (1 << order); i++)
+			clear_page(page + i);
+	}
 }
 
 /*
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
