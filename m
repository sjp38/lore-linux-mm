Date: Thu, 27 Oct 2005 10:05:04 +1000
From: 'David Gibson' <david@gibson.dropbear.id.au>
Subject: Re: RFC: Cleanup / small fixes to hugetlb fault handling
Message-ID: <20051027000504.GC14742@localhost.localdomain>
References: <20051026024831.GB17191@localhost.localdomain> <200510261844.j9QIiqg22461@unix-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200510261844.j9QIiqg22461@unix-os.sc.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hugh@veritas.com, William Irwin <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 26, 2005 at 11:44:52AM -0700, Chen, Kenneth W wrote:
> David Gibson wrote on Tuesday, October 25, 2005 7:49 PM
> > +int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> > +		  unsigned long address, int write_access)
> > +{
> > +	pte_t *ptep;
> > +	pte_t entry;
> > +
> > +	ptep = huge_pte_alloc(mm, address);
> > +	if (! ptep)
> > +		/* OOM */
> > +		return VM_FAULT_SIGBUS;
> > +
> > +	entry = *ptep;
> > +
> > +	if (pte_none(entry))
> > +		return hugetlb_no_page(mm, vma, address, ptep);
> > +
> > +	/* we could get here if another thread instantiated the pte
> > +	 * before the test above */
> > +
> > +	return VM_FAULT_SIGBUS;
> >  }
> 
> Are you sure about the last return?  Looks like a typo to me, if *ptep
> is present, it should return VM_FAULT_MINOR.

Oops, yes, thinko.  Corrected patch shortly.

> But the bigger question is: don't you need some lock when checking *ptep?

No, I'm pretty sure that's ok.  In a sense, the test here is only an
optimization: we recheck the pte with lock held in hugetlb_no_page()
before attempting the set_pte_at().

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/people/dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
