Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6F290828E2
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 11:58:34 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id fi3so15812950pac.3
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 08:58:34 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id kr9si269966pab.190.2016.03.03.08.52.40
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 08:52:40 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 21/29] vmscan: split file huge pages before paging them out
Date: Thu,  3 Mar 2016 19:52:11 +0300
Message-Id: <1457023939-98083-22-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This is preparation of vmscan for file huge pages. We cannot write out
huge pages, so we need to split them on the way out.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/vmscan.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 39e90e24caff..832a00523ffb 100644
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
