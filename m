Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id B075E6B0038
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 17:06:18 -0400 (EDT)
Received: by wgso17 with SMTP id o17so62805971wgs.1
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 14:06:18 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id ib4si21257236wjb.47.2015.04.24.14.06.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Apr 2015 14:06:17 -0700 (PDT)
Received: by wiun10 with SMTP id n10so33099963wiu.1
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 14:06:16 -0700 (PDT)
From: Anisse Astier <anisse@astier.eu>
Subject: [PATCH 1/2] mm/page_alloc.c: cleanup obsolete KM_USER*
Date: Fri, 24 Apr 2015 23:05:48 +0200
Message-Id: <1429909549-11726-2-git-send-email-anisse@astier.eu>
In-Reply-To: <1429909549-11726-1-git-send-email-anisse@astier.eu>
References: <1429909549-11726-1-git-send-email-anisse@astier.eu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Anisse Astier <anisse@astier.eu>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

It's been five years now that KM_* kmap flags have been removed and
that we can call clear_highpage from any context. So we simplify
prep_zero_pages accordingly and rename it in the process.

Signed-off-by: Anisse Astier <anisse@astier.eu>
---
 mm/page_alloc.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ebffa0e..05fcec9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -380,16 +380,10 @@ void prep_compound_page(struct page *page, unsigned long order)
 	}
 }
 
-static inline void prep_zero_page(struct page *page, unsigned int order,
-							gfp_t gfp_flags)
+static inline void zero_pages(struct page *page, unsigned int order)
 {
 	int i;
 
-	/*
-	 * clear_highpage() will use KM_USER0, so it's a bug to use __GFP_ZERO
-	 * and __GFP_HIGHMEM from hard or soft interrupt context.
-	 */
-	VM_BUG_ON((gfp_flags & __GFP_HIGHMEM) && in_interrupt());
 	for (i = 0; i < (1 << order); i++)
 		clear_highpage(page + i);
 }
@@ -975,7 +969,7 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
 	kasan_alloc_pages(page, order);
 
 	if (gfp_flags & __GFP_ZERO)
-		prep_zero_page(page, order, gfp_flags);
+		zero_pages(page, order);
 
 	if (order && (gfp_flags & __GFP_COMP))
 		prep_compound_page(page, order);
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
