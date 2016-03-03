Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id B4C2E828E2
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 11:59:05 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id fy10so17690220pac.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 08:59:05 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id f63si66596958pfj.137.2016.03.03.08.52.40
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 08:52:41 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 25/29] truncate: handle file thp
Date: Thu,  3 Mar 2016 19:52:15 +0300
Message-Id: <1457023939-98083-26-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For shmem/tmpfs we only need to tweak truncate_inode_page() and
invalidate_mapping_pages().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/truncate.c | 22 ++++++++++++++++++++--
 1 file changed, 20 insertions(+), 2 deletions(-)

diff --git a/mm/truncate.c b/mm/truncate.c
index 7598b552ae03..40d3730a8e62 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -157,10 +157,14 @@ invalidate_complete_page(struct address_space *mapping, struct page *page)
 
 int truncate_inode_page(struct address_space *mapping, struct page *page)
 {
+	loff_t holelen;
+	VM_BUG_ON_PAGE(PageTail(page), page);
+
+	holelen = PageTransHuge(page) ? HPAGE_PMD_SIZE : PAGE_CACHE_SIZE;
 	if (page_mapped(page)) {
 		unmap_mapping_range(mapping,
 				   (loff_t)page->index << PAGE_CACHE_SHIFT,
-				   PAGE_CACHE_SIZE, 0);
+				   holelen, 0);
 	}
 	return truncate_complete_page(mapping, page);
 }
@@ -489,7 +493,21 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 
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
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
