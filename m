Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id CBFE26B006E
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 08:06:46 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id ld10so3468729pab.8
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 05:06:46 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 14/22] thp, mm: allocate huge pages in grab_cache_page_write_begin()
Date: Mon, 23 Sep 2013 15:05:42 +0300
Message-Id: <1379937950-8411-15-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Try to allocate huge page if flags has AOP_FLAG_TRANSHUGE.

If, for some reason, it's not possible allocate a huge page at this
possition, it returns NULL. Caller should take care of fallback to
small pages.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/fs.h |  1 +
 mm/filemap.c       | 23 +++++++++++++++++++++--
 2 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 26801f0bb1..42ccdeddd9 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -282,6 +282,7 @@ enum positive_aop_returns {
 #define AOP_FLAG_NOFS			0x0004 /* used by filesystem to direct
 						* helper code (eg buffer layer)
 						* to clear GFP_FS from alloc */
+#define AOP_FLAG_TRANSHUGE		0x0008 /* allocate transhuge page */
 
 /*
  * oh the beauties of C type declarations.
diff --git a/mm/filemap.c b/mm/filemap.c
index 3421bcaed4..410879a801 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2322,18 +2322,37 @@ struct page *grab_cache_page_write_begin(struct address_space *mapping,
 	gfp_t gfp_mask;
 	struct page *page;
 	gfp_t gfp_notmask = 0;
+	bool must_use_thp = (flags & AOP_FLAG_TRANSHUGE) &&
+		IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE);
 
 	gfp_mask = mapping_gfp_mask(mapping);
+	if (must_use_thp) {
+		BUG_ON(index & HPAGE_CACHE_INDEX_MASK);
+		BUG_ON(!(gfp_mask & __GFP_COMP));
+	}
 	if (mapping_cap_account_dirty(mapping))
 		gfp_mask |= __GFP_WRITE;
 	if (flags & AOP_FLAG_NOFS)
 		gfp_notmask = __GFP_FS;
 repeat:
 	page = find_lock_page(mapping, index);
-	if (page)
+	if (page) {
+		if (must_use_thp && !PageTransHuge(page)) {
+			unlock_page(page);
+			page_cache_release(page);
+			return NULL;
+		}
 		goto found;
+	}
 
-	page = __page_cache_alloc(gfp_mask & ~gfp_notmask);
+	if (must_use_thp) {
+		page = alloc_pages(gfp_mask & ~gfp_notmask, HPAGE_PMD_ORDER);
+		if (page)
+			count_vm_event(THP_WRITE_ALLOC);
+		else
+			count_vm_event(THP_WRITE_ALLOC_FAILED);
+	} else
+		page = __page_cache_alloc(gfp_mask & ~gfp_notmask);
 	if (!page)
 		return NULL;
 	status = add_to_page_cache_lru(page, mapping, index,
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
