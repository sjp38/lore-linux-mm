From: Nick Piggin <npiggin@suse.de>
Message-Id: <20070221023706.6306.55204.sendpatchset@linux.site>
In-Reply-To: <20070221023656.6306.246.sendpatchset@linux.site>
References: <20070221023656.6306.246.sendpatchset@linux.site>
Subject: [patch 1/6] mm: debug check for the fault vs invalidate race
Date: Wed, 21 Feb 2007 05:49:47 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Add a bugcheck for Andrea's pagefault vs invalidate race. This is triggerable
for both linear and nonlinear pages with a userspace test harness (using
direct IO and truncate, respectively).

Signed-off-by: Nick Piggin <npiggin@suse.de>

 mm/filemap.c |    2 ++
 1 file changed, 2 insertions(+)

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -120,6 +120,8 @@ void __remove_from_page_cache(struct pag
 	page->mapping = NULL;
 	mapping->nrpages--;
 	__dec_zone_page_state(page, NR_FILE_PAGES);
+
+	BUG_ON(page_mapped(page));
 }
 
 void remove_from_page_cache(struct page *page)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
