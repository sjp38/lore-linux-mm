Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id DBBBD6B0068
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 12:32:58 -0400 (EDT)
Date: Mon, 1 Oct 2012 17:32:50 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] mm: thp: Set the accessed flag for old pages on access
 fault.
Message-ID: <20121001163250.GO20812@mudshark.cambridge.arm.com>
References: <1349099505-5581-1-git-send-email-will.deacon@arm.com>
 <20121001145944.GA18051@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121001145944.GA18051@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.cz" <mhocko@suse.cz>, Steve Capper <Steve.Capper@arm.com>, Chris Metcalf <cmetcalf@tilera.com>

On Mon, Oct 01, 2012 at 03:59:44PM +0100, Andrea Arcangeli wrote:
> Hi Will,

Hi Andrea, Kirill,

Thanks for the comments.

> On Mon, Oct 01, 2012 at 02:51:45PM +0100, Will Deacon wrote:
> > +void huge_pmd_set_accessed(struct mm_struct *mm, struct vm_area_struct *vma,
> > +			   unsigned long address, pmd_t *pmd, pmd_t orig_pmd)
> > +{
> > +	pmd_t entry;
> > +
> > +	spin_lock(&mm->page_table_lock);
> > +	entry = pmd_mkyoung(orig_pmd);
> > +	if (pmdp_set_access_flags(vma, address & HPAGE_PMD_MASK, pmd, entry, 0))
> > +		update_mmu_cache(vma, address, pmd);
> 
> If the pmd is being splitted, this may not be a trasnhuge pmd anymore
> by the time you obtained the lock. (orig_pmd could be stale, and it
> wasn't verified with pmd_same either)
> 
> The lock should be obtained through pmd_trans_huge_lock.
> 
>   if (pmd_trans_huge_lock(orig_pmd, vma) == 1)
>   {
> 	set young bit
> 	spin_unlock(&mm->page_table_lock);
>   }

I didn't notice that -- thanks. I'll move the locking outside of the
_set_accessed function and direct it via that function instead.

> On x86:
> 
> int pmdp_set_access_flags(struct vm_area_struct *vma,
> 			  unsigned long address, pmd_t *pmdp,
> 			  pmd_t entry, int dirty)
> {
> 	int changed = !pmd_same(*pmdp, entry);
> 
> 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
> 
> 	if (changed && dirty) {
> 		*pmdp = entry;
> 
> with dirty == 0 it looks like it won't make any difference, but I
> guess your arm pmdp_set_access_flag is different.

We use the generic code, which ignores the dirty argument. Still, we should
pass the correct value through anyway, so I'll fix that too.

> However it seems "dirty" means write access and so the invocation
> would better match the pte case:
> 
> 	if (pmdp_set_access_flags(vma, address & HPAGE_PMD_MASK, pmd, entry,
> 	    flags & FAULT_FLAG_WRITE))
> 
> 
> But note, you still have to update it even when "dirty" == 0, or it'll
> still infinite loop for read accesses.

Yup. v2 to follow once we've re-run our testing.

Cheers,

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
