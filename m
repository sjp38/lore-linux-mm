Date: Mon, 27 Feb 2006 20:20:33 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: unuse_pte: set pte dirty if the page is dirty
In-Reply-To: <20060227182137.3106a4cf.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0602272009100.15012@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0602271731410.14242@schroedinger.engr.sgi.com>
 <20060227175324.229860ca.akpm@osdl.org> <Pine.LNX.4.64.0602271755070.14367@schroedinger.engr.sgi.com>
 <20060227182137.3106a4cf.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: hugh@veritas.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 27 Feb 2006, Andrew Morton wrote:

> Christoph Lameter <clameter@engr.sgi.com> wrote:
> >
> > On Mon, 27 Feb 2006, Andrew Morton wrote:
> > 
> > > Are we sure this is race-free?  Say, someone is in the process of cleaning
> > > the page?  munmap, conceivably swapout?  We end up with a dirty pte
> > > pointing at a now-clean page.  The page will later become dirty again.  Is
> > > that a problem?  It would generate a surprise if the vma had ben set
> > > read-only in the interim, for example.
> > 
> > munmap sets the dirty bit in pages rather than clearing the dirty bits.
> > 
> > If we would set a dirty bit in a pte pointing to a now clean page then 
> > unmapping (or the swaper) will mark the page dirty again and its going to 
> > be rewritten again.
> 
> Precisely.
> 
> And will that crash the kernel, corrupt swapspace, or any other such
> exciting things?

How could it do that if user space could accomplish the same dirtying
of the pte without harm?

> There are cases (eg, mprotect) in which a subsequent page-dirtying is
> "impossible".  Only we've now gone and made it possible.  The worst part of
> it is that we're made it possible in exceedingly rare circumstances.

Yes we need to check the VM_WRITE bit like in maybe_mkwrite() in 
memory.c.... Thanks...


unuse_pte: set pte dirty if the page is dirty

When replacing a swap pte with a real pte in unuse_pte, we simply generate
a pte that has no dirty bit set regardless of what state the page is in.

If a process wants to write to a dirty page after replacement then a
page fault has to first set the dirty bit in the pte.

This patch generates a pte with the dirty bit already set and so avoids
that fault (if the vma is writable ....).

Page migration moves a page from regular ptes to swap ptes and back
for anonymous page. This patch will increase the efficiency of page migration.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc5/mm/swapfile.c
===================================================================
--- linux-2.6.16-rc5.orig/mm/swapfile.c	2006-02-26 21:09:35.000000000 -0800
+++ linux-2.6.16-rc5/mm/swapfile.c	2006-02-27 20:12:44.000000000 -0800
@@ -425,10 +425,15 @@ void free_swap_and_cache(swp_entry_t ent
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
+			(PageDirty(page) && (vma->vm_flags & VM_WRITE)) ?
+			pte_mkdirty(new_pte) : new_pte);
+
 	page_add_anon_rmap(page, vma, addr);
 	swap_free(entry);
 	/*
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
