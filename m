From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [rfc] lockless get_user_pages for dio (and more)
Date: Tue, 16 Oct 2007 13:26:57 +1000
References: <20071008225234.GC27824@linux-os.sc.intel.com> <200710161215.33284.nickpiggin@yahoo.com.au> <1192493687.6118.138.camel@localhost>
In-Reply-To: <1192493687.6118.138.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710161326.57615.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Ken Chen <kenchen@google.com>, "Siddha, Suresh B" <suresh.b.siddha@intel.com>, Badari Pulavarty <pbadari@gmail.com>, linux-mm <linux-mm@kvack.org>, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

On Tuesday 16 October 2007 10:14, Dave Hansen wrote:
> > +static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long
> > end, int write, struct page **pages, int *nr) +{
> > +       pte_t *ptep;
> > +
> > +       /* XXX: this won't work for 32-bit (must map pte) */
> > +       ptep = (pte_t *)pmd_page_vaddr(pmd) + pte_index(addr);
> > +       do {
> > +               pte_t pte = *ptep;
> > +               unsigned long pfn;
> > +               struct page *page;
> > +
> > +               if ((pte_val(pte) & (_PAGE_PRESENT|_PAGE_USER)) !=
> > (_PAGE_PRESENT|_PAGE_USER)) +                       return 0;
> > +
> > +               if (write && !pte_write(pte))
> > +                       return 0;
> > +
> > +               /* XXX: really need new bit in pte to denote normal page
> > */ +               pfn = pte_pfn(pte);
> > +               if (unlikely(!pfn_valid(pfn)))
> > +                       return 0;
>
> Is that little pfn_valid() nugget to help detect VM_IO and VM_PFNMAP
> areas?

Yes.

> Does that work 100% of the time?

No, because we can mmap /dev/mem for example and point to valid
pfns, but it would be a bug to take a ref on them.


> Is it for anything else?  
>
> If that is all that you want a bit in the pte for, I guess we could get
> a bitfield or a simple flag in the mm to say whether there are any
> VM_IO/PFNMAP areas around.  If we used the same IPI/RCU rules as
> pagetables to manage such a flag, I think it would be sufficient to dump
> us into the slow path when we hit those areas.

I don't see any problem with using a new bit in the pte. We kind of
wanted to do this to simplify some of the COW rules in the core VM
anyway. I think s390 doesn't have any spare bits, so I suppose that
guy could implement said flag if they want a fast_gup as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
