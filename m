Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 05E3F6B0055
	for <linux-mm@kvack.org>; Sun, 28 Jun 2009 21:45:47 -0400 (EDT)
Subject: [PATCH 2/5]memhp: exclude isolated page from pco page alloc
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain
Date: Mon, 29 Jun 2009 09:47:12 +0800
Message-Id: <1246240032.26292.18.camel@sli10-desk.sh.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

pages marked as isolated should not be allocated again. If such
pages reside in pcp list, they can be allocated too, so there is
a ping-pong memory offline frees some pages to pcp list and the
pages get allocated and then memory offline frees them again,
this loop will happen again and again.

This should have no impact in normal code path, because in normal
code path, pages in pcp list aren't isolated, and below loop will
break in the first entry.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 mm/page_alloc.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c	2009-06-26 09:41:10.000000000 +0800
+++ linux/mm/page_alloc.c	2009-06-26 09:44:07.000000000 +0800
@@ -1137,9 +1137,18 @@ again:
 
 		/* Allocate more to the pcp list if necessary */
 		if (unlikely(&page->lru == &pcp->list)) {
+			int get_one_page = 0;
 			pcp->count += rmqueue_bulk(zone, 0,
 					pcp->batch, &pcp->list, migratetype);
-			page = list_entry(pcp->list.next, struct page, lru);
+			list_for_each_entry(page, &pcp->list, lru) {
+				if (get_pageblock_migratetype(page) !=
+				    MIGRATE_ISOLATE) {
+					get_one_page = 1;
+					break;
+				}
+			}
+			if (!get_one_page)
+				goto failed;
 		}
 
 		list_del(&page->lru);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
