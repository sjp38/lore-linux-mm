Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id BA8E28E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 07:25:48 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id w19-v6so4598416pfa.14
        for <linux-mm@kvack.org>; Thu, 20 Sep 2018 04:25:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o8-v6sor4980038plk.132.2018.09.20.04.25.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Sep 2018 04:25:47 -0700 (PDT)
Date: Thu, 20 Sep 2018 14:25:37 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: Recheck page table entry with page table lock held
Message-ID: <20180920112536.52jpx4sptrvbnyul@kshutemo-mobl1>
References: <20180920092408.9128-1-aneesh.kumar@linux.ibm.com>
 <20180920110538.rlcpw75eabkqudkl@kshutemo-mobl1>
 <a22a21d6-c872-63e9-77ec-8071bac9bfc9@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a22a21d6-c872-63e9-77ec-8071bac9bfc9@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: akpm@linux-foundation.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Sep 20, 2018 at 04:41:59PM +0530, Aneesh Kumar K.V wrote:
> On 9/20/18 4:35 PM, Kirill A. Shutemov wrote:
> > On Thu, Sep 20, 2018 at 02:54:08PM +0530, Aneesh Kumar K.V wrote:
> > > We clear the pte temporarily during read/modify/write update of the pte. If we
> > > take a page fault while the pte is cleared, the application can get SIGBUS. One
> > > such case is with remap_pfn_range without a backing vm_ops->fault callback.
> > > do_fault will return SIGBUS in that case.
> > 
> > It would be nice to show the path that clears pte temporarily.
> > 
> > > Fix this by taking page table lock and rechecking for pte_none.
> 
> 
> we do that in the ptep_modify_prot_start/ptep_modify_prot_commit. Also in
> hugetlb_change_protection. The hugetlb case many not be relevant because
> that cannot be backed by a vma without vma->vm_ops.
> 
> What will hit this will be mprotect of a remap_pfn_range address?

Sounds right. Please update commit message.
> 
> > > 
> > > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> > > ---
> > >   mm/memory.c | 31 +++++++++++++++++++++++++++----
> > >   1 file changed, 27 insertions(+), 4 deletions(-)
> > > 
> > > diff --git a/mm/memory.c b/mm/memory.c
> > > index c467102a5cbc..c2f933184303 100644
> > > --- a/mm/memory.c
> > > +++ b/mm/memory.c
> > > @@ -3745,10 +3745,33 @@ static vm_fault_t do_fault(struct vm_fault *vmf)
> > >   	struct vm_area_struct *vma = vmf->vma;
> > >   	vm_fault_t ret;
> > > -	/* The VMA was not fully populated on mmap() or missing VM_DONTEXPAND */
> > > -	if (!vma->vm_ops->fault)
> > > -		ret = VM_FAULT_SIGBUS;
> > > -	else if (!(vmf->flags & FAULT_FLAG_WRITE))
> > > +	/*
> > > +	 * The VMA was not fully populated on mmap() or missing VM_DONTEXPAND
> > > +	 */
> > > +	if (!vma->vm_ops->fault) {
> > > +
> > > +		/*
> > > +		 * pmd entries won't be marked none during a R/M/W cycle.
> > > +		 */
> > > +		if (unlikely(pmd_none(*vmf->pmd)))
> > > +			ret = VM_FAULT_SIGBUS;
> > > +		else {
> > > +			vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
> > > +			/*
> > > +			 * Make sure this is not a temporary clearing of pte
> > > +			 * by holding ptl and checking again. A R/M/W update
> > > +			 * of pte involves: take ptl, clearing the pte so that
> > > +			 * we don't have concurrent modification by hardware
> > > +			 * followed by an update.
> > > +			 */
> > > +			spin_lock(vmf->ptl);
> > > +			if (unlikely(pte_none(*vmf->pte)))
> > > +				ret = VM_FAULT_SIGBUS;
> > > +			else
> > > +				ret = VM_FAULT_NOPAGE;
> > 
> > We return 0 if we did nothing in fault path.
> > 
> 
> I didn't get that. If we find the pte not none, we return so that we retry
> the access. Are you suggesting VM_FAULT_NOPAGE is not the right return for
> that?

We usually use VM_FAULT_NOPAGE to indicate that ->fault() installed the
pte and we don't need to do anything. We don't touch pte in this page
fault.

It doesn't make difference in this particular case, nobody cares upper by
stack. Just a nitpick.

-- 
 Kirill A. Shutemov
