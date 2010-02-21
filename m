Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D125C6B0089
	for <linux-mm@kvack.org>; Sun, 21 Feb 2010 09:18:43 -0500 (EST)
Message-Id: <20100221141755.839051883@redhat.com>
Date: Sun, 21 Feb 2010 15:10:28 +0100
From: aarcange@redhat.com
Subject: [patch 19/36] clear page compound
References: <20100221141009.581909647@redhat.com>
Content-Disposition: inline; filename=clear_page_compound
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

split_huge_page must transform a compound page to a regular page and needs
ClearPageCompound.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
---

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -349,7 +349,7 @@ static inline void set_page_writeback(st
  * tests can be used in performance sensitive paths. PageCompound is
  * generally not used in hot code paths.
  */
-__PAGEFLAG(Head, head)
+__PAGEFLAG(Head, head) CLEARPAGEFLAG(Head, head)
 __PAGEFLAG(Tail, tail)
 
 static inline int PageCompound(struct page *page)
@@ -357,6 +357,13 @@ static inline int PageCompound(struct pa
 	return page->flags & ((1L << PG_head) | (1L << PG_tail));
 
 }
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static inline void ClearPageCompound(struct page *page)
+{
+	BUG_ON(!PageHead(page));
+	ClearPageHead(page);
+}
+#endif
 #else
 /*
  * Reduce page flag use as much as possible by overlapping
@@ -394,6 +401,14 @@ static inline void __ClearPageTail(struc
 	page->flags &= ~PG_head_tail_mask;
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static inline void ClearPageCompound(struct page *page)
+{
+	BUG_ON(page->flags & PG_head_tail_mask != (1 << PG_compound));
+	ClearPageCompound(page);
+}
+#endif
+
 #endif /* !PAGEFLAGS_EXTENDED */
 
 #ifdef CONFIG_MMU

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
