Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7CA0A6B01FD
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 22:56:20 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 19 of 67] clear page compound
Message-Id: <2ede229c8ef81791aefb.1270691462@v2.random>
In-Reply-To: <patchbomb.1270691443@v2.random>
References: <patchbomb.1270691443@v2.random>
Date: Thu, 08 Apr 2010 03:51:02 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>
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
+	BUG_ON((page->flags & PG_head_tail_mask) != (1 << PG_compound));
+	clear_bit(PG_compound, &page->flags);
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
