Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 329CE6B002B
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 12:07:35 -0500 (EST)
Received: by mail-qc0-f181.google.com with SMTP id x40so5500129qcp.26
        for <linux-mm@kvack.org>; Fri, 28 Dec 2012 09:07:34 -0800 (PST)
From: c.dall@virtualopensystems.com
Subject: [PATCH] mm: Fix PageHead when !CONFIG_PAGEFLAGS_EXTENDED
Date: Fri, 28 Dec 2012 12:07:22 -0500
Message-Id: <1356714442-27028-1-git-send-email-cdall@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: cl@linux.com, Christoffer Dall <cdall@cs.columbia.edu>, Steve Capper <steve.capper@arm.com>, Will Deacon <will.deacon@arm.com>, Andrea Arcangeli <arcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>

From: Christoffer Dall <cdall@cs.columbia.edu>

Unfortunately with !CONFIG_PAGEFLAGS_EXTENDED, (!PageHead) is false, and
(PageHead) is true, for tail pages.  This breaks cache cleaning on some
ARM systems, and may cause other bugs.

This patch makes sure PageHead is only true for head pages and PageTail
is only true for tail pages, and neither is true for non-compound pages.

Cc: Steve Capper <steve.capper@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Andrea Arcangeli <arcange@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Christoffer Dall <cdall@cs.columbia.edu>
---
 include/linux/page-flags.h |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index b5d1384..70473da 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -362,7 +362,7 @@ static inline void ClearPageCompound(struct page *page)
  * pages on the LRU and/or pagecache.
  */
 TESTPAGEFLAG(Compound, compound)
-__PAGEFLAG(Head, compound)
+__SETPAGEFLAG(Head, compound)  __CLEARPAGEFLAG(Head, compound)
 
 /*
  * PG_reclaim is used in combination with PG_compound to mark the
@@ -374,8 +374,14 @@ __PAGEFLAG(Head, compound)
  * PG_compound & PG_reclaim	=> Tail page
  * PG_compound & ~PG_reclaim	=> Head page
  */
+#define PG_head_mask ((1L << PG_compound))
 #define PG_head_tail_mask ((1L << PG_compound) | (1L << PG_reclaim))
 
+static inline int PageHead(struct page *page)
+{
+	return ((page->flags & PG_head_tail_mask) == PG_head_mask);
+}
+
 static inline int PageTail(struct page *page)
 {
 	return ((page->flags & PG_head_tail_mask) == PG_head_tail_mask);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
