Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AFBA06B0089
	for <linux-mm@kvack.org>; Fri, 29 May 2009 17:35:24 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <200905291135.124267638@firstfloor.org>
In-Reply-To: <200905291135.124267638@firstfloor.org>
Subject: [PATCH] [11/16] HWPOISON: Handle poisoned pages in set_page_dirty()
Message-Id: <20090529213537.2D2951D0294@basil.firstfloor.org>
Date: Fri, 29 May 2009 23:35:37 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>


Bail out early in set_page_dirty for poisoned pages. We don't want any
of the dirty accounting done or file system write back started, because
the page will be just thrown away.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/page-writeback.c |    4 ++++
 1 file changed, 4 insertions(+)

Index: linux/mm/page-writeback.c
===================================================================
--- linux.orig/mm/page-writeback.c	2009-05-29 23:32:08.000000000 +0200
+++ linux/mm/page-writeback.c	2009-05-29 23:32:10.000000000 +0200
@@ -1277,6 +1277,10 @@
 {
 	struct address_space *mapping = page_mapping(page);
 
+	if (unlikely(PageHWPoison(page))) {
+		SetPageDirty(page);
+		return 0;
+	}
 	if (likely(mapping)) {
 		int (*spd)(struct page *) = mapping->a_ops->set_page_dirty;
 #ifdef CONFIG_BLOCK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
