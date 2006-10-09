From: Nick Piggin <npiggin@suse.de>
Message-Id: <20061009140404.13840.66361.sendpatchset@linux.site>
In-Reply-To: <20061009140354.13840.71273.sendpatchset@linux.site>
References: <20061009140354.13840.71273.sendpatchset@linux.site>
Subject: [patch 1/5] mm: fault vs invalidate/truncate check
Date: Mon,  9 Oct 2006 18:12:16 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@osdl.org>, Jes Sorensen <jes@sgi.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Add a bugcheck for Andrea's pagefault vs invalidate race. This is triggerable
for both linear and nonlinear pages with a userspace test harness (using
direct IO and truncate, respectively).

Signed-off-by: Nick Piggin <npiggin@suse.de>

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
