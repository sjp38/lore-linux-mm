Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 245186B4455
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 18:20:01 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id q62so8793654pgq.9
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 15:20:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n13sor2812115pfj.12.2018.11.26.15.20.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 15:20:00 -0800 (PST)
Date: Mon, 26 Nov 2018 15:19:57 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 02/10] mm/huge_memory: splitting set mapping+index before
 unfreeze
In-Reply-To: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1811261516380.2275@eggly.anvils>
References: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Matthew Wilcox <willy@infradead.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-mm@kvack.org

Huge tmpfs stress testing has occasionally hit shmem_undo_range()'s
VM_BUG_ON_PAGE(page_to_pgoff(page) != index, page).

Move the setting of mapping and index up before the page_ref_unfreeze()
in __split_huge_page_tail() to fix this: so that a page cache lookup
cannot get a reference while the tail's mapping and index are unstable.

In fact, might as well move them up before the smp_wmb(): I don't see
an actual need for that, but if I'm missing something, this way round
is safer than the other, and no less efficient.

You might argue that VM_BUG_ON_PAGE(page_to_pgoff(page) != index, page)
is misplaced, and should be left until after the trylock_page(); but
left as is has not crashed since, and gives more stringent assurance.

Fixes: e9b61f19858a5 ("thp: reintroduce split_huge_page()")
Requires: 605ca5ede764 ("mm/huge_memory.c: reorder operations in __split_huge_page_tail()")
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: stable@vger.kernel.org # 4.8+
---
 mm/huge_memory.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 30100fac2341..cef2c256e7c4 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2402,6 +2402,12 @@ static void __split_huge_page_tail(struct page *head, int tail,
 			 (1L << PG_unevictable) |
 			 (1L << PG_dirty)));
 
+	/* ->mapping in first tail page is compound_mapcount */
+	VM_BUG_ON_PAGE(tail > 2 && page_tail->mapping != TAIL_MAPPING,
+			page_tail);
+	page_tail->mapping = head->mapping;
+	page_tail->index = head->index + tail;
+
 	/* Page flags must be visible before we make the page non-compound. */
 	smp_wmb();
 
@@ -2422,12 +2428,6 @@ static void __split_huge_page_tail(struct page *head, int tail,
 	if (page_is_idle(head))
 		set_page_idle(page_tail);
 
-	/* ->mapping in first tail page is compound_mapcount */
-	VM_BUG_ON_PAGE(tail > 2 && page_tail->mapping != TAIL_MAPPING,
-			page_tail);
-	page_tail->mapping = head->mapping;
-
-	page_tail->index = head->index + tail;
 	page_cpupid_xchg_last(page_tail, page_cpupid_last(head));
 
 	/*
-- 
2.20.0.rc0.387.gc7a69e6b6c-goog
