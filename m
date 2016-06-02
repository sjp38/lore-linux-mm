Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id BF5326B0005
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 11:21:49 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id w16so25662953lfd.0
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 08:21:49 -0700 (PDT)
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com. [195.75.94.110])
        by mx.google.com with ESMTPS id p10si1345585wjp.70.2016.06.02.08.21.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 02 Jun 2016 08:21:48 -0700 (PDT)
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Thu, 2 Jun 2016 16:21:47 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id D52441B0806E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 16:22:46 +0100 (BST)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u52FLhJs2949558
	for <linux-mm@kvack.org>; Thu, 2 Jun 2016 15:21:43 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u52FLgiw021942
	for <linux-mm@kvack.org>; Thu, 2 Jun 2016 09:21:43 -0600
Date: Thu, 2 Jun 2016 17:21:41 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: [BUG/REGRESSION] THP: broken page count after commit aa88b68c
Message-ID: <20160602172141.75c006a9@thinkpad>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christian Borntraeger <borntraeger@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

Christian Borntraeger reported a kernel panic after corrupt page counts,
and it turned out to be a regression introduced with commit aa88b68c
"thp: keep huge zero page pinned until tlb flush", at least on s390.

put_huge_zero_page() was moved over from zap_huge_pmd() to release_pages(),
and it was replaced by tlb_remove_page(). However, release_pages() might
not always be triggered by (the arch-specific) tlb_remove_page().

On s390 we call free_page_and_swap_cache() from tlb_remove_page(), and not
tlb_flush_mmu() -> free_pages_and_swap_cache() like the generic version,
because we don't use the MMU-gather logic. Although both functions have very
similar names, they are doing very unsimilar things, in particular
free_page_xxx is just doing a put_page(), while free_pages_xxx calls
release_pages().

This of course results in very harmful put_page()s on the huge zero page,
on architectures where tlb_remove_page() is implemented in this way. It
seems to affect only s390 and sh, but sh doesn't have THP support, so
the problem (currently) probably only exists on s390.

The following quick hack fixed the issue:

diff --git a/mm/swap_state.c b/mm/swap_state.c
index 0d457e7..c99463a 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -252,7 +252,10 @@ static inline void free_swap_cache(struct page *page)
 void free_page_and_swap_cache(struct page *page)
 {
 	free_swap_cache(page);
-	put_page(page);
+	if (is_huge_zero_page(page))
+		put_huge_zero_page();
+	else
+		put_page(page);
 }
 
 /*

But of course there might be a better solution, and there still are some
questions left:
- Why does free_page_xxx() behave so differently from free_pages_xxx()?
- Would it be OK to implement free_page_xxx() by calling free_pages_xxx()
  with nr = 1, similar to free_page() vs. free_pages()?
- Would it be OK to replace the put_page() in free_page_xxx() with a call
  to release_pages() with nr = 1?
- Would it be better to fix this in the arch-specific tlb_remove_page(),
  by calling free_pages_xxx() with nr = 1 instead of free_page_xxx()?

Regards,
Gerald

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
