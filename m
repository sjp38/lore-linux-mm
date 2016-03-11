Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id CABB76B0253
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 18:05:40 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id 129so93468822pfw.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 15:05:40 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id ds16si1214123pac.149.2016.03.11.14.59.34
        for <linux-mm@kvack.org>;
        Fri, 11 Mar 2016 14:59:34 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 17/25] vmscan: split file huge pages before paging them out
Date: Sat, 12 Mar 2016 01:59:09 +0300
Message-Id: <1457737157-38573-18-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This is preparation of vmscan for file huge pages. We cannot write out
huge pages, so we need to split them on the way out.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/vmscan.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c72032dbe8db..9fa9e15594e9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -473,12 +473,14 @@ void drop_slab(void)
 
 static inline int is_page_cache_freeable(struct page *page)
 {
+	int radix_tree_pins = PageTransHuge(page) ? HPAGE_PMD_NR : 1;
+
 	/*
 	 * A freeable page cache page is referenced only by the caller
 	 * that isolated the page, the page cache radix tree and
 	 * optional buffer heads at page->private.
 	 */
-	return page_count(page) - page_has_private(page) == 2;
+	return page_count(page) - page_has_private(page) == 1 + radix_tree_pins;
 }
 
 static int may_write_to_inode(struct inode *inode, struct scan_control *sc)
@@ -548,8 +550,6 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 	 * swap_backing_dev_info is bust: it doesn't reflect the
 	 * congestion state of the swapdevs.  Easy to fix, if needed.
 	 */
-	if (!is_page_cache_freeable(page))
-		return PAGE_KEEP;
 	if (!mapping) {
 		/*
 		 * Some data journaling orphaned pages can have
@@ -1112,6 +1112,15 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			 * starts and then write it out here.
 			 */
 			try_to_unmap_flush_dirty();
+
+			if (!is_page_cache_freeable(page))
+				goto keep_locked;
+
+			if (unlikely(PageTransHuge(page))) {
+				if (split_huge_page_to_list(page, page_list))
+					goto keep_locked;
+			}
+
 			switch (pageout(page, mapping, sc)) {
 			case PAGE_KEEP:
 				goto keep_locked;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
