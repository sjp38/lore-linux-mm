Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id CDBD86B0069
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 13:49:18 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2, RFC 18/30] thp, mm: truncate support for transparent huge page cache
Date: Thu, 14 Mar 2013 19:50:23 +0200
Message-Id: <1363283435-7666-19-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
