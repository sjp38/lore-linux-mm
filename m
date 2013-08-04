Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 85CC16B0039
	for <linux-mm@kvack.org>; Sat,  3 Aug 2013 22:14:31 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 11/23] thp, mm: handle tail pages in page_cache_get_speculative()
Date: Sun,  4 Aug 2013 05:17:13 +0300
Message-Id: <1375582645-29274-12-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For tail pages we need to take two refcounters:
 - ->_count for its head page;
 - ->_mapcount for the tail page;

To protect against splitting we take compound lock and re-check that we
still have tail page before taking ->_mapcount reference.
If the page was split we drop ->_count reference from head page and
return 0 to indicate caller that it must retry.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/pagemap.h | 26 ++++++++++++++++++++++----
 1 file changed, 22 insertions(+), 4 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 47b5082..d459b38 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -161,6 +161,8 @@ void release_pages(struct page **pages, int nr, int cold);
  */
 static inline int page_cache_get_speculative(struct page *page)
 {
+	struct page *page_head = compound_trans_head(page);
+
 	VM_BUG_ON(in_interrupt());
 
 #ifdef CONFIG_TINY_RCU
@@ -176,11 +178,11 @@ static inline int page_cache_get_speculative(struct page *page)
 	 * disabling preempt, and hence no need for the "speculative get" that
 	 * SMP requires.
 	 */
-	VM_BUG_ON(page_count(page) == 0);
-	atomic_inc(&page->_count);
+	VM_BUG_ON(page_count(page_head) == 0);
+	atomic_inc(&page_head->_count);
 
 #else
-	if (unlikely(!get_page_unless_zero(page))) {
+	if (unlikely(!get_page_unless_zero(page_head))) {
 		/*
 		 * Either the page has been freed, or will be freed.
 		 * In either case, retry here and the caller should
@@ -189,7 +191,23 @@ static inline int page_cache_get_speculative(struct page *page)
 		return 0;
 	}
 #endif
-	VM_BUG_ON(PageTail(page));
+
+	if (unlikely(PageTransTail(page))) {
+		unsigned long flags;
+		int got = 0;
+
+		flags = compound_lock_irqsave(page_head);
+		if (likely(PageTransTail(page))) {
+			atomic_inc(&page->_mapcount);
+			got = 1;
+		}
+		compound_unlock_irqrestore(page_head, flags);
+
+		if (unlikely(!got))
+			atomic_dec(&page_head->_count);
+
+		return got;
+	}
 
 	return 1;
 }
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
