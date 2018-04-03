Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4E64B6B0003
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 16:40:22 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id t8-v6so9059274ply.22
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 13:40:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i190sor851824pge.333.2018.04.03.13.40.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Apr 2018 13:40:20 -0700 (PDT)
Date: Tue, 3 Apr 2018 13:40:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v9 06/24] mm: make pte_unmap_same compatible with SPF
In-Reply-To: <20180403191005.GC5935@redhat.com>
Message-ID: <alpine.DEB.2.20.1804031338260.172772@chino.kir.corp.google.com>
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com> <1520963994-28477-7-git-send-email-ldufour@linux.vnet.ibm.com> <20180403191005.GC5935@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Tue, 3 Apr 2018, Jerome Glisse wrote:

> > diff --git a/mm/memory.c b/mm/memory.c
> > index 21b1212a0892..4bc7b0bdcb40 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -2309,21 +2309,29 @@ static bool pte_map_lock(struct vm_fault *vmf)
> >   * parts, do_swap_page must check under lock before unmapping the pte and
> >   * proceeding (but do_wp_page is only called after already making such a check;
> >   * and do_anonymous_page can safely check later on).
> > + *
> > + * pte_unmap_same() returns:
> > + *	0			if the PTE are the same
> > + *	VM_FAULT_PTNOTSAME	if the PTE are different
> > + *	VM_FAULT_RETRY		if the VMA has changed in our back during
> > + *				a speculative page fault handling.
> >   */
> > -static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
> > -				pte_t *page_table, pte_t orig_pte)
> > +static inline int pte_unmap_same(struct vm_fault *vmf)
> >  {
> > -	int same = 1;
> > +	int ret = 0;
> > +
> >  #if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
> >  	if (sizeof(pte_t) > sizeof(unsigned long)) {
> > -		spinlock_t *ptl = pte_lockptr(mm, pmd);
> > -		spin_lock(ptl);
> > -		same = pte_same(*page_table, orig_pte);
> > -		spin_unlock(ptl);
> > +		if (pte_spinlock(vmf)) {
> > +			if (!pte_same(*vmf->pte, vmf->orig_pte))
> > +				ret = VM_FAULT_PTNOTSAME;
> > +			spin_unlock(vmf->ptl);
> > +		} else
> > +			ret = VM_FAULT_RETRY;
> >  	}
> >  #endif
> > -	pte_unmap(page_table);
> > -	return same;
> > +	pte_unmap(vmf->pte);
> > +	return ret;
> >  }
> >  
> >  static inline void cow_user_page(struct page *dst, struct page *src, unsigned long va, struct vm_area_struct *vma)
> > @@ -2913,7 +2921,8 @@ int do_swap_page(struct vm_fault *vmf)
> >  	int exclusive = 0;
> >  	int ret = 0;
> >  
> > -	if (!pte_unmap_same(vma->vm_mm, vmf->pmd, vmf->pte, vmf->orig_pte))
> > +	ret = pte_unmap_same(vmf);
> > +	if (ret)
> >  		goto out;
> >  
> 
> This change what do_swap_page() returns ie before it was returning 0
> when locked pte lookup was different from orig_pte. After this patch
> it returns VM_FAULT_PTNOTSAME but this is a new return value for
> handle_mm_fault() (the do_swap_page() return value is what ultimately
> get return by handle_mm_fault())
> 
> Do we really want that ? This might confuse some existing user of
> handle_mm_fault() and i am not sure of the value of that information
> to caller.
> 
> Note i do understand that you want to return retry if anything did
> change from underneath and thus need to differentiate from when the
> pte value are not the same.
> 

I think VM_FAULT_RETRY should be handled appropriately for any user of 
handle_mm_fault() already, and would be surprised to learn differently.  
Khugepaged has the appropriate handling.  I think the concern is whether a 
user is handling anything other than VM_FAULT_RETRY and VM_FAULT_ERROR 
(which VM_FAULT_PTNOTSAME is not set in)?  I haven't done a full audit of 
the users.
