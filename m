Message-Id: <200705180737.l4I7b9K0010770@shell0.pdx.osdl.net>
Subject: [patch 6/8] mm: debug check for the fault vs invalidate race
From: akpm@linux-foundation.org
Date: Fri, 18 May 2007 00:37:09 -0700
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <npiggin@suse.de>
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Add a bugcheck for Andrea's pagefault vs invalidate race.  This is triggerable
for both linear and nonlinear pages with a userspace test harness (using
direct IO and truncate, respectively).

Signed-off-by: Nick Piggin <npiggin@suse.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/filemap.c |    1 +
 1 file changed, 1 insertion(+)

diff -puN mm/filemap.c~mm-debug-check-for-the-fault-vs-invalidate-race mm/filemap.c
--- a/mm/filemap.c~mm-debug-check-for-the-fault-vs-invalidate-race
+++ a/mm/filemap.c
@@ -120,6 +120,7 @@ void __remove_from_page_cache(struct pag
 	page->mapping = NULL;
 	mapping->nrpages--;
 	__dec_zone_page_state(page, NR_FILE_PAGES);
+	BUG_ON(page_mapped(page));
 }
 
 void remove_from_page_cache(struct page *page)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
