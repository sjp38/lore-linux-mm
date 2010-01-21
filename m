Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8B1256B007E
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 01:51:33 -0500 (EST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 17 of 30] clear page compound
Message-Id: <7bfd31773b49ad17528d.1264054841@v2.random>
In-Reply-To: <patchbomb.1264054824@v2.random>
References: <patchbomb.1264054824@v2.random>
Date: Thu, 21 Jan 2010 07:20:41 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

split_huge_page must transform a compound page to a regular page and needs
ClearPageCompound.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -347,7 +347,7 @@ static inline void set_page_writeback(st
  * tests can be used in performance sensitive paths. PageCompound is
  * generally not used in hot code paths.
  */
-__PAGEFLAG(Head, head)
+__PAGEFLAG(Head, head) CLEARPAGEFLAG(Head, head)
 __PAGEFLAG(Tail, tail)
 
 static inline int PageCompound(struct page *page)
@@ -355,6 +355,13 @@ static inline int PageCompound(struct pa
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
@@ -392,6 +399,14 @@ static inline void __ClearPageTail(struc
 	page->flags &= ~PG_head_tail_mask;
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static inline void ClearPageCompound(struct page *page)
+{
+	BUG_ON(page->flags & PG_head_tail_mask != (1L << PG_compound));
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
