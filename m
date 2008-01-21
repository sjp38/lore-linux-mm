Date: Mon, 21 Jan 2008 10:43:41 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/6] mm: introduce pte_special pte bit
Message-ID: <20080121094341.GA9198@wotan.suse.de>
References: <20080118045649.334391000@suse.de> <20080118045755.516986000@suse.de> <alpine.LFD.1.00.0801180816120.2957@woody.linux-foundation.org> <20080118224622.GA11563@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080118224622.GA11563@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Jared Hulbert <jaredeh@gmail.com>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 18, 2008 at 11:46:22PM +0100, Nick Piggin wrote:
> On Fri, Jan 18, 2008 at 08:41:22AM -0800, Linus Torvalds wrote:
>  
> > Then, just have a library version of the long form, and make architectures 
> > that don't support it just use that (just so that you don't have to 
> > duplicate that silly thing). So an architecture that support special page 
> > flags would do somethiing like
> > 
> > 	#define set_special_page(vma,addr,ptep,pfn,prot) \
> > 		set_pte_at(vma, addr, ptep, mk_special_pte(pfn,prot))
> > 	#define vm_normal_page(vma,addr,pte)
> > 		(pte_special(pte) ? NULL : pte_page(pte))
> > 
> > and other architectures would just do
> > 
> > 	#define set_special_page(vma,addr,ptep,pfn,prot) \
> > 		set_pte_at(vma, addr, ptep, mk_pte(pfn,prot))
> > 	#define vm_normal_page(vma,addr,pte) \
> > 		generic_vm_normal_page(vma,addr,pte)
> > 
> > or something.
> > 
> > THAT is what I mean by "no #ifdef's in code" - that the selection is done 
> > at a higher level, the same way we have good interfaces with clear 
> > *conceptual* meaning for all the other PTE accessing stuff, rather than 
> > have conditionals in the architecture-independent code.
> 
> OK, that gets around the "duplicate vm_normal_page everywhere" issue I
> had. I'm still not quite happy with it ;)
> 
> How about taking a different approach. How about also having a pte_normal()
> function. Each architecture that has a pte special bit would make this
> !pte_special, and those that don't would return 0. They return 0 from both
> pte_special and pte_normal because they don't know whether the pte is
> special or normal.
> 
> Then vm_normal_page would become:
> 
>     if (pte_special(pte))
>         return NULL;
>     else if (pte_normal(pte))
>         return pte_page(pte);
> 
>     ... /* vma based scheme */

Hmm, it's not *quite* trivial as that for one important case:
vm_insert_mixed. Because we don't actually have a pte yet, so we can't
easily reuse insert_page / insert_pfn, rather we have to build the pte
first and then check it (patch attached, but I think it is a step
backwards)...

Really, I don't think either of my two approaches or your approach is
really a fundamentally different _abstraction_. It basically just has
to accommodate 2 different code paths no matter how you look at it. I
don't know how this is different to, say, conditionally compiling eg.
the FLATMEM/SPARSEMEM memory model code, or rwsem code, depending on
whether an architecture has defined some symbol. It happens all over
the kernel.

Actually, I'd argue it is _better_ than that, because the logic stays
in one place (one screenful, even), and away from abuse or divergence
by arch code.

If one actually came up with a new API that handles both cases better,
I'd say that is a different abstraction. Or if you could come up with
some different arch functions which would allow vm_normal_page to be
streamlined to read more like a regular C function, that should be a
different abstraction...

I'm still keen on my first patch. I know it isn't beautiful, but I
think it is better than the alternatives.

---

mm: add vm_insert_mixed

vm_insert_mixed will insert either a raw pfn or a refcounted struct page
into the page tables, depending on whether vm_normal_page() will return
the page or not. With the introduction of the new pte bit, this is now
a bit too tricky for drivers to be doing themselves.

filemap_xip uses this in a subsequent patch.

---
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -1097,6 +1097,8 @@ int remap_pfn_range(struct vm_area_struc
 int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
 int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
+int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
+			unsigned long pfn);
 
 struct page *follow_page(struct vm_area_struct *, unsigned long address,
 			unsigned int foll_flags);
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1282,6 +1282,53 @@ out:
 }
 EXPORT_SYMBOL(vm_insert_pfn);
 
+int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
+			unsigned long pfn)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	int retval;
+	pte_t *pte, entry;
+	spinlock_t *ptl;
+
+	BUG_ON(!(vma->vm_flags & VM_MIXEDMAP));
+
+	if (addr < vma->vm_start || addr >= vma->vm_end)
+		return -EFAULT;
+
+	retval = -ENOMEM;
+	pte = get_locked_pte(mm, addr, &ptl);
+	if (!pte)
+		goto out;
+	retval = -EBUSY;
+	if (!pte_none(*pte))
+		goto out_unlock;
+
+	entry = pte_mkspecial(pfn_pte(pfn, prot));
+	/*
+	 * If we don't have pte special, then we have to use the pfn_valid()
+	 * based VM_MIXEDMAP scheme (see vm_normal_page), and thus we *must*
+	 * refcount the page if pfn_valid is true. Otherwise we can *always*
+	 * avoid refcounting the page if we have pte_special.
+	 */
+	if (!pte_special(entry) && pfn_valid(pfn)) {
+		struct page *page;
+
+		page = pfn_to_page(pfn);
+		get_page(page);
+		inc_mm_counter(mm, file_rss);
+		page_add_file_rmap(page);
+	}
+	/* Ok, finally just insert the thing.. */
+	set_pte_at(mm, addr, pte, entry);
+
+	retval = 0;
+out_unlock:
+	pte_unmap_unlock(pte, ptl);
+out:
+	return retval;
+}
+EXPORT_SYMBOL(vm_insert_mixed);
+
 /*
  * maps a range of physical memory into the requested pages. the old
  * mappings are removed. any references to nonexistent pages results

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
