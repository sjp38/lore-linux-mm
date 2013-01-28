Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id A3D006B0011
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 04:23:40 -0500 (EST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 14/16] thp, mm: truncate support for transparent huge page cache
Date: Mon, 28 Jan 2013 11:24:26 +0200
Message-Id: <1359365068-10147-15-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1359365068-10147-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1359365068-10147-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

If we starting position of truncation is in tail page we have to spilit
the huge page page first.

We also have to split if end is within the huge page. Otherwise we can
truncate whole huge page at once.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/truncate.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/mm/truncate.c b/mm/truncate.c
index c75b736..87c247d 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -231,6 +231,17 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			if (index > end)
 				break;
 
+			/* split page if we start from tail page */
+			if (PageTransTail(page))
+				split_huge_page(compound_trans_head(page));
+			if (PageTransHuge(page)) {
+				/* split if end is within huge page */
+				if (index == (end & ~HPAGE_CACHE_INDEX_MASK))
+					split_huge_page(page);
+				else
+					/* skip tail pages */
+					i += HPAGE_CACHE_NR - 1;
+			}
 			if (!trylock_page(page))
 				continue;
 			WARN_ON(page->index != index);
@@ -280,6 +291,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			if (index > end)
 				break;
 
+			VM_BUG_ON(PageTransHuge(page));
 			lock_page(page);
 			WARN_ON(page->index != index);
 			wait_on_page_writeback(page);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
