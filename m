Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 144606B004A
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 18:25:05 -0400 (EDT)
Date: Wed, 13 Jul 2011 15:24:29 -0700
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] mm: account NR_WRITTEN at IO completion time
Message-ID: <20110713222429.GA14098@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rubin <mrubin@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

NR_WRITTEN is now accounted at block IO enqueue time, which is not
very accurate as to common understanding. This moves NR_WRITTEN
accounting to the IO completion time and makes it more consistent
with BDI_WRITTEN, which is used for bandwidth estimation.

CC: Michael Rubin <mrubin@google.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2011-04-18 17:28:44.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-04-18 17:30:33.000000000 +0800
@@ -1846,7 +1846,6 @@ EXPORT_SYMBOL(account_page_dirtied);
 void account_page_writeback(struct page *page)
 {
 	inc_zone_page_state(page, NR_WRITEBACK);
-	inc_zone_page_state(page, NR_WRITTEN);
 }
 EXPORT_SYMBOL(account_page_writeback);
 
@@ -2063,8 +2062,10 @@ int test_clear_page_writeback(struct pag
 	} else {
 		ret = TestClearPageWriteback(page);
 	}
-	if (ret)
+	if (ret) {
 		dec_zone_page_state(page, NR_WRITEBACK);
+		inc_zone_page_state(page, NR_WRITTEN);
+	}
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
