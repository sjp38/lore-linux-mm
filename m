Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 58A615F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 11:09:59 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <20090407509.382219156@firstfloor.org>
In-Reply-To: <20090407509.382219156@firstfloor.org>
Subject: [PATCH] [3/16] POISON: Handle poisoned pages in page free
Message-Id: <20090407150959.C099D1D046E@basil.firstfloor.org>
Date: Tue,  7 Apr 2009 17:09:59 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>


Make sure no poisoned pages are put back into the free page
lists.  This can happen with some races.

This is allo slow path in the bad page bits path, so another
check doesn't really matter.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/page_alloc.c |    9 +++++++++
 1 file changed, 9 insertions(+)

Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c	2009-04-07 16:39:26.000000000 +0200
+++ linux/mm/page_alloc.c	2009-04-07 16:39:39.000000000 +0200
@@ -228,6 +228,15 @@
 	static unsigned long nr_unshown;
 
 	/*
+	 * Page may have been marked bad before process is freeing it.
+	 * Make sure it is not put back into the free page lists.
+	 */
+	if (PagePoison(page)) {
+		/* check more flags here... */
+		return;
+	}
+
+	/*
 	 * Allow a burst of 60 reports, then keep quiet for that minute;
 	 * or allow a steady drip of one report per second.
 	 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
