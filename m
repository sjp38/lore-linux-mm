Date: Mon, 27 Feb 2006 17:33:59 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: unuse_pte: set pte dirty if the page is dirty
Message-ID: <Pine.LNX.4.64.0602271731410.14242@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

When replacing a swap pte with a real pte in unuse_pte, we simply generate
a pte that has no dirty bit set regardless of what state the page is in.

If a process wants to write to a dirty page after replacement then a
page fault has to first  set the dirty bit in the pte.

This patch generates a pte with the dirty bit already set and so avoids
that fault.

Page migration moves a page from regular ptes to swap ptes and back
for anonymous page and so may generate lots of ptes that are not marked
dirty. This patch will increase the efficiency of page migration.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc5/mm/swapfile.c
===================================================================
--- linux-2.6.16-rc5.orig/mm/swapfile.c	2006-02-26 21:09:35.000000000 -0800
+++ linux-2.6.16-rc5/mm/swapfile.c	2006-02-27 17:17:38.000000000 -0800
@@ -425,10 +425,14 @@ void free_swap_and_cache(swp_entry_t ent
 static void unuse_pte(struct vm_area_struct *vma, pte_t *pte,
 		unsigned long addr, swp_entry_t entry, struct page *page)
 {
+	pte_t new_pte = pte_mkold(mk_pte(page, vma->vm_page_prot));
+
 	inc_mm_counter(vma->vm_mm, anon_rss);
 	get_page(page);
+
 	set_pte_at(vma->vm_mm, addr, pte,
-		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
+			PageDirty(page) ? pte_mkdirty(new_pte) : new_pte);
+
 	page_add_anon_rmap(page, vma, addr);
 	swap_free(entry);
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
