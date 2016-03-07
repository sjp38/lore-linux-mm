Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id C21D86B0254
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 05:12:25 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id tt10so14448633pab.3
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 02:12:25 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id n63si27969518pfj.185.2016.03.07.02.12.24
        for <linux-mm@kvack.org>;
        Mon, 07 Mar 2016 02:12:25 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm, thp: fix migration of PTE-mapped transparent huge pages
Date: Mon,  7 Mar 2016 13:12:08 +0300
Message-Id: <1457345528-52231-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We don't have native support of THP migration, so we have to split huge
page into small pages in order to migrate it to different node.
This includes PTE-mapped huge pages.

I made mistake in refcounting patchset: we don't actually split
PTE-mapped huge page in queue_pages_pte_range(), if we step on head
page.

The result is that the head page is queued for migration, but none of
tail pages: putting head page on queue takes pin on the page and any
subsequent attempts of split_huge_pages() would fail and we skip queuing
tail pages.

unmap_and_move_huge_page() will eventually split the huge pages, but
only one of 512 pages would get migrated.

Let's fix the situation.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Fixes: b57a81e3e29c ("migrate_pages: try to split pages on queuing")
---
 mm/mempolicy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 8c5fd08c253c..8cbc74387df3 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -532,7 +532,7 @@ retry:
 		nid = page_to_nid(page);
 		if (node_isset(nid, *qp->nmask) == !!(flags & MPOL_MF_INVERT))
 			continue;
-		if (PageTail(page) && PageAnon(page)) {
+		if (PageTransCompound(page) && PageAnon(page)) {
 			get_page(page);
 			pte_unmap_unlock(pte, ptl);
 			lock_page(page);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
