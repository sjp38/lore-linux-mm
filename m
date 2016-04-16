Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 066BA828DF
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 20:24:55 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id dx6so109296681pad.0
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 17:24:54 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id q76si5201007pfa.60.2016.04.15.17.24.39
        for <linux-mm@kvack.org>;
        Fri, 15 Apr 2016 17:24:39 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 20/29] truncate: handle file thp
Date: Sat, 16 Apr 2016 03:23:51 +0300
Message-Id: <1460766240-84565-21-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1460766240-84565-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1460766240-84565-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For shmem/tmpfs we only need to tweak truncate_inode_page() and
invalidate_mapping_pages().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/truncate.c | 22 ++++++++++++++++++++--
 1 file changed, 20 insertions(+), 2 deletions(-)

diff --git a/mm/truncate.c b/mm/truncate.c
index b00272810871..4f931ca9333b 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -157,10 +157,14 @@ invalidate_complete_page(struct address_space *mapping, struct page *page)
 
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
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
