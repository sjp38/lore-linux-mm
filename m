Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 100396B0005
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 08:05:42 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id g62so221101242wme.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 05:05:42 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id g139si7229924wmd.7.2016.02.23.05.05.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 05:05:40 -0800 (PST)
Received: by mail-wm0-x236.google.com with SMTP id c200so219353912wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 05:05:40 -0800 (PST)
Date: Tue, 23 Feb 2016 16:05:38 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 08/28] mm: postpone page table allocation until
 do_set_pte()
Message-ID: <20160223130538.GA21144@node.shutemov.name>
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1455200516-132137-9-git-send-email-kirill.shutemov@linux.intel.com>
 <56BE1A09.6000007@intel.com>
 <20160216142657.GA16364@node.shutemov.name>
 <56C3599D.3060106@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56C3599D.3060106@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Feb 16, 2016 at 09:17:17AM -0800, Dave Hansen wrote:
> On 02/16/2016 06:26 AM, Kirill A. Shutemov wrote:
> > On Fri, Feb 12, 2016 at 09:44:41AM -0800, Dave Hansen wrote:
> >> On 02/11/2016 06:21 AM, Kirill A. Shutemov wrote:
> >>> diff --git a/include/linux/mm.h b/include/linux/mm.h
> >>> index ca99c0ecf52e..172f4d8e798d 100644
> >>> --- a/include/linux/mm.h
> >>> +++ b/include/linux/mm.h
> >>> @@ -265,6 +265,7 @@ struct fault_env {
> >>>  	pmd_t *pmd;
> >>>  	pte_t *pte;
> >>>  	spinlock_t *ptl;
> >>> +	pgtable_t prealloc_pte;
> >>>  };
> >>
> >> If we're going to do this fault_env thing, we need some heavy-duty
> >> comments on what the different fields do and what they mean.  We don't
> >> want to get in to a situation where we're doing
> >>
> >> 	void fault_foo(struct fault_env *fe);..
> >>
> >> and then we change the internals of fault_foo() to manipulate a
> >> different set of fe->* variables, or change assumptions, then have
> >> callers randomly break.
> >>
> >> One _nice_ part of passing all the arguments explicitly is that it makes
> >> you go visit all the call sites and think about how the conventions change.
> >>
> >> It just makes me nervous.
> >>
> >> The semantics of having both a ->pte and ->pmd need to be very clearly
> >> spelled out too, please.
> > 
> > I've updated this to:
> > 
> > /*
> >  * Page fault context: passes though page fault handler instead of endless list
> >  * of function arguments.
> >  */
> > struct fault_env {
> > 	struct vm_area_struct *vma;	/* Target VMA */
> > 	unsigned long address;		/* Faulting virtual address */
> > 	unsigned int flags;		/* FAULT_FLAG_xxx flags */
> > 	pmd_t *pmd;			/* Pointer to pmd entry matching
> > 					 * the 'address'
> > 					 */
> 
> Is this just for huge PMDs, or does it also cover normal PMDs pointing
> to PTE pages?

Any.

> Is it populated every time we're at or below the PMD during a fault?

Yes.

> Is it always valid?

It points to relevant entry. Nothing to say about content of the entry in
general.

> > 	pte_t *pte;			/* Pointer to pte entry matching
> > 					 * the 'address'. NULL if the page
> > 					 * table hasn't been allocated.
> > 					 */
> 
> What's the relationship between pmd and pte?  Can both be set at the
> same time, etc...?

If pte set, pmd is set too. pmd in this case would point to page table pte
is part of.

It's pretty straight-forward.

> 
> > 	spinlock_t *ptl;		/* Page table lock.
> > 					 * Protects pte page table if 'pte'
> > 					 * is not NULL, otherwise pmd.
> > 					 */
> 
> Are there any rules for callers when a callee puts a value in here?

Nothing in particular. In most cases we acquire and release ptl in the
same function, with few exceptions: write-protect fault path and
do_set_pte(). That's documented around these functions.

> > 	pgtable_t prealloc_pte;		/* Pre-allocated pte page table.
> > 					 * vm_ops->map_pages() calls
> > 					 * do_set_pte() from atomic context.
> > 					 * do_fault_around() pre-allocates
> > 					 * page table to avoid allocation from
> > 					 * atomic context.
> > 					 */
> > };
> 
> Who's responsible for freeing this and when?

do_fault_around() frees the page table if it wasn't used.

> >>>  /*
> >>> @@ -559,7 +560,8 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
> >>>  	return pte;
> >>>  }
> >>>  
> >>> -void do_set_pte(struct fault_env *fe, struct page *page);
> >>> +int do_set_pte(struct fault_env *fe, struct mem_cgroup *memcg,
> >>> +		struct page *page);
> >>>  #endif
> >>
> >> I think do_set_pte() might be due for a new name if it's going to be
> >> doing allocations internally.
> > 
> > Any suggestions?
> 
> alloc_set_pte() is probably fine.  Just make it clear early in some
> comments that the allocation is conditional.

Ok.

> >>> diff --git a/mm/filemap.c b/mm/filemap.c
> >>> index 28b3875969a8..ba8150d6dc33 100644
> >>> --- a/mm/filemap.c
> >>> +++ b/mm/filemap.c
> >>> @@ -2146,11 +2146,6 @@ void filemap_map_pages(struct fault_env *fe,
> >>>  			start_pgoff) {
> >>>  		if (iter.index > end_pgoff)
> >>>  			break;
> >>> -		fe->pte += iter.index - last_pgoff;
> >>> -		fe->address += (iter.index - last_pgoff) << PAGE_SHIFT;
> >>> -		last_pgoff = iter.index;
> >>> -		if (!pte_none(*fe->pte))
> >>> -			goto next;
> >>>  repeat:
> >>>  		page = radix_tree_deref_slot(slot);
> >>>  		if (unlikely(!page))
> >>> @@ -2187,7 +2182,17 @@ repeat:
> >>>  
> >>>  		if (file->f_ra.mmap_miss > 0)
> >>>  			file->f_ra.mmap_miss--;
> >>> -		do_set_pte(fe, page);
> >>> +
> >>> +		fe->address += (iter.index - last_pgoff) << PAGE_SHIFT;
> >>> +		if (fe->pte)
> >>> +			fe->pte += iter.index - last_pgoff;
> >>> +		last_pgoff = iter.index;
> >>> +		if (do_set_pte(fe, NULL, page)) {
> >>> +			/* failed to setup page table: giving up */
> >>> +			if (!fe->pte)
> >>> +				break;
> >>> +			goto unlock;
> >>> +		}
> >>
> >> What's the failure here, though?
> > 
> > At this point in patchset it never fails: allocation failure is not
> > possible as we pre-allocate page table for faularound.
> > 
> > Later after do_set_pmd() is introduced, huge page can be mapped here. By
> > us or under us.
> > 
> > I'll update comment.
> 
> So why check the return value of do_set_pte()?  Why can it return nonzero?

Actually, this part is buggy (loops without result). I used to return
VM_FAULT_NOPAGE when huge page is setup, but not anymore.

I'll replace it with this:

diff --git a/mm/filemap.c b/mm/filemap.c
index de3bb308f5a9..5f655220df69 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2269,12 +2269,12 @@ repeat:
 		if (fe->pte)
 			fe->pte += iter.index - last_pgoff;
 		last_pgoff = iter.index;
-		if (alloc_set_pte(fe, NULL, page)) {
-			/* Huge page is mapped? */
-			if (!fe->pte)
-				break;
-			goto unlock;
-		}
+		alloc_set_pte(fe, NULL, page);
+		/* Huge page is mapped? No need to proceed. */
+		if (pmd_trans_huge(*fe->pmd))
+			break;
+		/* Failed to setup page table? */
+		VM_BUG_ON(!fe->pte);
 		unlock_page(page);
 		goto next;
 unlock:

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
