Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 89FE06B0267
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 16:12:22 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e189so64035151pfa.2
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 13:12:22 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id xj8si14251650pab.203.2016.06.15.13.07.04
        for <linux-mm@kvack.org>;
        Wed, 15 Jun 2016 13:07:04 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9-rebased2 25/37] truncate: handle file thp
Date: Wed, 15 Jun 2016 23:06:30 +0300
Message-Id: <1466021202-61880-26-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1466021202-61880-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1466021202-61880-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ebru Akagunduz <ebru.akagunduz@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For shmem/tmpfs we only need to tweak truncate_inode_page() and
invalidate_mapping_pages().

truncate_inode_pages_range() and invalidate_inode_pages2_range() are
adjusted to use page_to_pgoff().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/truncate.c | 28 +++++++++++++++++++++++-----
 1 file changed, 23 insertions(+), 5 deletions(-)

diff --git a/mm/truncate.c b/mm/truncate.c
index 4064f8f53daa..a01cce450a26 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -155,10 +155,14 @@ invalidate_complete_page(struct address_space *mapping, struct page *page)
 
 int truncate_inode_page(struct address_space *mapping, struct page *page)
 {
+	loff_t holelen;
+	VM_BUG_ON_PAGE(PageTail(page), page);
+
+	holelen = PageTransHuge(page) ? HPAGE_PMD_SIZE : PAGE_SIZE;
 	if (page_mapped(page)) {
 		unmap_mapping_range(mapping,
 				   (loff_t)page->index << PAGE_SHIFT,
-				   PAGE_SIZE, 0);
+				   holelen, 0);
 	}
 	return truncate_complete_page(mapping, page);
 }
@@ -279,7 +283,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 
 			if (!trylock_page(page))
 				continue;
-			WARN_ON(page->index != index);
+			WARN_ON(page_to_pgoff(page) != index);
 			if (PageWriteback(page)) {
 				unlock_page(page);
 				continue;
@@ -367,7 +371,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			}
 
 			lock_page(page);
-			WARN_ON(page->index != index);
+			WARN_ON(page_to_pgoff(page) != index);
 			wait_on_page_writeback(page);
 			truncate_inode_page(mapping, page);
 			unlock_page(page);
@@ -487,7 +491,21 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 
 			if (!trylock_page(page))
 				continue;
-			WARN_ON(page->index != index);
+
+			WARN_ON(page_to_pgoff(page) != index);
+
+			/* Middle of THP: skip */
+			if (PageTransTail(page)) {
+				unlock_page(page);
+				continue;
+			} else if (PageTransHuge(page)) {
+				index += HPAGE_PMD_NR - 1;
+				i += HPAGE_PMD_NR - 1;
+				/* 'end' is in the middle of THP */
+				if (index ==  round_down(end, HPAGE_PMD_NR))
+					continue;
+			}
+
 			ret = invalidate_inode_page(page);
 			unlock_page(page);
 			/*
@@ -594,7 +612,7 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 			}
 
 			lock_page(page);
-			WARN_ON(page->index != index);
+			WARN_ON(page_to_pgoff(page) != index);
 			if (page->mapping != mapping) {
 				unlock_page(page);
 				continue;
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
