Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9702C6B00D9
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 04:33:07 -0500 (EST)
Received: by ti-out-0910.google.com with SMTP id u3so2698593tia.8
        for <linux-mm@kvack.org>; Mon, 02 Mar 2009 01:33:05 -0800 (PST)
Date: Mon, 2 Mar 2009 18:31:48 +0900
From: MinChan Kim <minchan.kim@gmail.com>
Subject: [PATCH] mmtom :  add VM_BUG_ON in __get_free_pages
Message-Id: <20090302183148.a4dfcc22.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


The __get_free_pages is used in many place. 
Also, driver developers can use it freely due to export function.
Some developers might use it to allocate high pages by mistake. 

The __get_free_pages can allocate high page using alloc_pages, 
but it can't return linear address for high page.

Even worse, in this csse, caller can't free page which are there in high zone. 
So, It would be better to add VM_BUG_ON. 

It's based on mmtom 2009-02-27-13-54.
 
Signed-off-by: MinChan Kim <minchan.kim@gmail.com>
---
 mm/page_alloc.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8294107..381056b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1681,6 +1681,13 @@ EXPORT_SYMBOL(__alloc_pages_internal);
 unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order)
 {
 	struct page * page;
+
+	/*
+	 * __get_free_pages() returns a 32-bit address, which cannot represent
+	 * a highmem page
+	 */
+	VM_BUG_ON((gfp_mask & __GFP_HIGHMEM) != 0);
+
 	page = alloc_pages(gfp_mask, order);
 	if (!page)
 		return 0;
-- 
1.5.4.3


-- 
Kinds Regards
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
