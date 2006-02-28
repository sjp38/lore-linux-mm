Date: Mon, 27 Feb 2006 20:39:23 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: unuse_pte: set pte dirty if the page is dirty
Message-Id: <20060227203923.24e9336c.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0602272009100.15012@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0602271731410.14242@schroedinger.engr.sgi.com>
	<20060227175324.229860ca.akpm@osdl.org>
	<Pine.LNX.4.64.0602271755070.14367@schroedinger.engr.sgi.com>
	<20060227182137.3106a4cf.akpm@osdl.org>
	<Pine.LNX.4.64.0602272009100.15012@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: hugh@veritas.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@engr.sgi.com> wrote:
>
> > There are cases (eg, mprotect) in which a subsequent page-dirtying is
> > "impossible".  Only we've now gone and made it possible.  The worst part of
> > it is that we're made it possible in exceedingly rare circumstances.
> 
> Yes we need to check the VM_WRITE bit like in maybe_mkwrite() in 
> memory.c.... Thanks...
> 

I dunno - I said I hadn't thought about it much.  But I'd like you guys to,
please - this is tricky stuff and bugs in there can reveal themselves in
horridly subtle ways.  We need to spend much time, care and thought over
each change.

>  static void unuse_pte(struct vm_area_struct *vma, pte_t *pte,
>  		unsigned long addr, swp_entry_t entry, struct page *page)
>  {
> +	pte_t new_pte = pte_mkold(mk_pte(page, vma->vm_page_prot));
> +
>  	inc_mm_counter(vma->vm_mm, anon_rss);
>  	get_page(page);
> +
>  	set_pte_at(vma->vm_mm, addr, pte,
> -		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
> +			(PageDirty(page) && (vma->vm_flags & VM_WRITE)) ?
> +			pte_mkdirty(new_pte) : new_pte);
> +
>  	page_add_anon_rmap(page, vma, addr);
>  	swap_free(entry);

argh.  Whenever you find yourself thinking of the question-mark operator,
take a cold shower.

This?

--- devel/mm/swapfile.c~unuse_pte-set-pte-dirty-if-the-page-is-dirty	2006-02-27 20:33:19.000000000 -0800
+++ devel-akpm/mm/swapfile.c	2006-02-27 20:34:32.000000000 -0800
@@ -480,10 +480,16 @@ unsigned int count_swap_pages(int type, 
 static void unuse_pte(struct vm_area_struct *vma, pte_t *pte,
 		unsigned long addr, swp_entry_t entry, struct page *page)
 {
+	pte_t new_pte;
+
 	inc_mm_counter(vma->vm_mm, anon_rss);
 	get_page(page);
-	set_pte_at(vma->vm_mm, addr, pte,
-		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
+
+	new_pte = pte_mkold(mk_pte(page, vma->vm_page_prot));
+	if (PageDirty(page) && (vma->vm_flags & VM_WRITE))
+		new_pte = pte_mkdirty(new_pte);
+	set_pte_at(vma->vm_mm, addr, pte, new_pte);
+
 	page_add_anon_rmap(page, vma, addr);
 	swap_free(entry);
 	/*
_

I think it has the same race - if the page gets cleaned and someone
mprotects the vma to remove VM_WRITE, we dirty an undirtiable page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
