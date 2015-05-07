Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 15EBB6B006C
	for <linux-mm@kvack.org>; Thu,  7 May 2015 02:34:55 -0400 (EDT)
Received: by widdi4 with SMTP id di4so47474884wid.0
        for <linux-mm@kvack.org>; Wed, 06 May 2015 23:34:54 -0700 (PDT)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com. [209.85.212.170])
        by mx.google.com with ESMTPS id fa18si2254650wid.123.2015.05.06.23.34.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 23:34:52 -0700 (PDT)
Received: by widdi4 with SMTP id di4so229069160wid.0
        for <linux-mm@kvack.org>; Wed, 06 May 2015 23:34:52 -0700 (PDT)
From: Anisse Astier <anisse@astier.eu>
Subject: [PATCH v3 1/4] mm/page_alloc.c: cleanup obsolete KM_USER*
Date: Thu,  7 May 2015 08:34:09 +0200
Message-Id: <1430980452-2767-2-git-send-email-anisse@astier.eu>
In-Reply-To: <1430980452-2767-1-git-send-email-anisse@astier.eu>
References: <1430980452-2767-1-git-send-email-anisse@astier.eu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Anisse Astier <anisse@astier.eu>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, Andi Kleen <andi@firstfloor.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>, linux-mm@kvack.org, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org

It's been five years now that KM_* kmap flags have been removed and
that we can call clear_highpage from any context. So we remove
prep_zero_pages accordingly.

Signed-off-by: Anisse Astier <anisse@astier.eu>
---
 mm/page_alloc.c | 17 ++---------------
 1 file changed, 2 insertions(+), 15 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ebffa0e..4d5ce6e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -380,20 +380,6 @@ void prep_compound_page(struct page *page, unsigned long order)
 	}
 }
 
-static inline void prep_zero_page(struct page *page, unsigned int order,
-							gfp_t gfp_flags)
-{
-	int i;
-
-	/*
-	 * clear_highpage() will use KM_USER0, so it's a bug to use __GFP_ZERO
-	 * and __GFP_HIGHMEM from hard or soft interrupt context.
-	 */
-	VM_BUG_ON((gfp_flags & __GFP_HIGHMEM) && in_interrupt());
-	for (i = 0; i < (1 << order); i++)
-		clear_highpage(page + i);
-}
-
 #ifdef CONFIG_DEBUG_PAGEALLOC
 unsigned int _debug_guardpage_minorder;
 bool _debug_pagealloc_enabled __read_mostly;
@@ -975,7 +961,8 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
 	kasan_alloc_pages(page, order);
 
 	if (gfp_flags & __GFP_ZERO)
-		prep_zero_page(page, order, gfp_flags);
+		for (i = 0; i < (1 << order); i++)
+			clear_highpage(page + i);
 
 	if (order && (gfp_flags & __GFP_COMP))
 		prep_compound_page(page, order);
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
