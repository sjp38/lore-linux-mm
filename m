Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 56CB26B02FD
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 09:21:48 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id l43so5271482wrl.2
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 06:21:48 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id s13si2125747wrb.195.2017.06.16.06.21.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 06:21:45 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id 70so5013874wme.1
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 06:21:45 -0700 (PDT)
Date: Fri, 16 Jun 2017 16:21:43 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 3/3] mm: Use updated pmdp_invalidate() inteface to
 track dirty/accessed bits
Message-ID: <20170616132143.cdr4qt5hzvgxsnek@node.shutemov.name>
References: <20170615145224.66200-1-kirill.shutemov@linux.intel.com>
 <20170615145224.66200-4-kirill.shutemov@linux.intel.com>
 <87bmpob23x.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87bmpob23x.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 16, 2017 at 05:01:30PM +0530, Aneesh Kumar K.V wrote:
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
> 
> > This patch uses modifed pmdp_invalidate(), that return previous value of pmd,
> > to transfer dirty and accessed bits.
> >
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  fs/proc/task_mmu.c |  8 ++++----
> >  mm/huge_memory.c   | 29 ++++++++++++-----------------
> >  2 files changed, 16 insertions(+), 21 deletions(-)
> >
> > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > index f0c8b33d99b1..f2fc1ef5bba2 100644
> > --- a/fs/proc/task_mmu.c
> > +++ b/fs/proc/task_mmu.c
> 
> .....
> 
> > @@ -1965,7 +1955,6 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
> >  	page_ref_add(page, HPAGE_PMD_NR - 1);
> >  	write = pmd_write(*pmd);
> >  	young = pmd_young(*pmd);
> > -	dirty = pmd_dirty(*pmd);
> >  	soft_dirty = pmd_soft_dirty(*pmd);
> >
> >  	pmdp_huge_split_prepare(vma, haddr, pmd);
> > @@ -1995,8 +1984,6 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
> >  			if (soft_dirty)
> >  				entry = pte_mksoft_dirty(entry);
> >  		}
> > -		if (dirty)
> > -			SetPageDirty(page + i);
> >  		pte = pte_offset_map(&_pmd, addr);
> >  		BUG_ON(!pte_none(*pte));
> >  		set_pte_at(mm, addr, pte, entry);
> > @@ -2045,7 +2032,15 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
> >  	 * and finally we write the non-huge version of the pmd entry with
> >  	 * pmd_populate.
> >  	 */
> > -	pmdp_invalidate(vma, haddr, pmd);
> > +	old = pmdp_invalidate(vma, haddr, pmd);
> > +
> > +	/*
> > +	 * Transfer dirty bit using value returned by pmd_invalidate() to be
> > +	 * sure we don't race with CPU that can set the bit under us.
> > +	 */
> > +	if (pmd_dirty(old))
> > +		SetPageDirty(page);
> > +
> >  	pmd_populate(mm, pmd, pgtable);
> >
> >  	if (freeze) {
> 
> 
> Can we invalidate the pmd early here ? ie, do pmdp_invalidate instead of
> pmdp_huge_split_prepare() ?

I think we can. But it means we would block access to the page for longer
than it's necessary on most architectures. I guess it's not a bit deal.

Maybe as separate patch on top of this patchet? Aneesh, would you take
care of this?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
