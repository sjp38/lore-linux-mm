Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id B0B826B0044
	for <linux-mm@kvack.org>; Mon, 24 Dec 2012 13:53:12 -0500 (EST)
Received: by mail-da0-f53.google.com with SMTP id x6so3249651dac.26
        for <linux-mm@kvack.org>; Mon, 24 Dec 2012 10:53:11 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 24 Dec 2012 13:53:11 -0500
Message-ID: <CAEDV+gLg838ua2Bgu0sTRjSAWYGPwELtH=ncoKPP-5t7_gxUYw@mail.gmail.com>
Subject: PageHead macro broken?
From: Christoffer Dall <cdall@cs.columbia.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, clameter@sgi.com, Will Deacon <Will.Deacon@arm.com>, Steve Capper <Steve.Capper@arm.com>, "kvmarm@lists.cs.columbia.edu" <kvmarm@lists.cs.columbia.edu>

Hi everyone,

I think I may have found an issue with the PageHead macro, which
returns true for tail compound pages when CONFIG_PAGEFLAGS_EXTENDED is
not defined.

I'm not sure however, if this indeed is the intended behavior and I'm
missing something overall. In any case, the below patch is a proposed
fix, which does fix a bug showing up on KVM/ARM with huge pages.

Your input would be greatly appreciated.

From: Christoffer Dall <cdall@cs.columbia.edu>
Date: Fri, 21 Dec 2012 13:03:50 -0500
Subject: [PATCH] mm: Fix PageHead when !CONFIG_PAGEFLAGS_EXTENDED

Unfortunately with !CONFIG_PAGEFLAGS_EXTENDED, (!PageHead) is false, and
(PageHead) is true, for tail pages.  If this is indeed the intended
behavior, which I doubt because it breaks cache cleaning on some ARM
systems, then the nomenclature is highly problematic.

This patch makes sure PageHead is only true for head pages and PageTail
is only true for tail pages, and neither is true for non-compound pages.

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
  * PG_compound & PG_reclaim => Tail page
  * PG_compound & ~PG_reclaim => Head page
  */
+#define PG_head_mask ((1L << PG_compound))
 #define PG_head_tail_mask ((1L << PG_compound) | (1L << PG_reclaim))

+static inline int PageHead(struct page *page)
+{
+ return ((page->flags & PG_head_tail_mask) == PG_head_mask);
+}
+
 static inline int PageTail(struct page *page)
 {
  return ((page->flags & PG_head_tail_mask) == PG_head_tail_mask);
--
1.7.9.5


Thanks!
-Christoffer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
