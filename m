From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [rfc] lockless get_user_pages for dio (and more)
Date: Tue, 16 Oct 2007 13:32:21 +1000
References: <20071008225234.GC27824@linux-os.sc.intel.com> <b040c32a0710151321s74799f0ax6e3e0c4042429c5b@mail.gmail.com> <200710161215.33284.nickpiggin@yahoo.com.au>
In-Reply-To: <200710161215.33284.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710161332.21850.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: "Siddha, Suresh B" <suresh.b.siddha@intel.com>, Badari Pulavarty <pbadari@gmail.com>, linux-mm <linux-mm@kvack.org>, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

On Tuesday 16 October 2007 12:15, Nick Piggin wrote:
> On Tuesday 16 October 2007 06:21, Ken Chen wrote:

> > Since get_page() on compound page will reference back to the head
> > page, you can take a ref directly against the head page instead of
> > traversing to tail page and loops around back to the head page.  It is
> > especially beneficial for large hugetlb page size, i.e., 1 GB page
> > size so one does not have to pollute cache with tail page's struct
> > page. I prefer doing the following:
> >
> > +		page = pte_page(pte);
> > +		get_page(page);
> > +		pfn_offset = (addr & ~HPAGE_MASK) >> PAGE_SHIFT;
> > +		pages[*nr] = page + pfn_offset;
> > +		(*nr)++;
>
> Very good point. Actually we could also possibly optimise this
> loop so that all it does is to fill the pages[] array, and then
> have a function to increment the head page refcount by "N", thus
> reducing atomic operations by a factor of N...

This is what I've ended up with... it should be extremely fast
to get a large number of pages out of a hugepage.

static inline void get_head_page_multiple(struct page *page, int nr)
{
        VM_BUG_ON(page != compound_head(page));
        VM_BUG_ON(page_count(page) == 0);
        atomic_add(nr, &page->_count);
}

static int gup_huge_pmd(pmd_t pmd, unsigned long addr, unsigned long end,
int write, struct page **pages, int *nr)
{
        pte_t pte = *(pte_t *)&pmd;
        struct page *head, *page;
        int refs;

        if ((pte_val(pte) & _PAGE_USER) != _PAGE_USER)
                return 0;

        BUG_ON(!pfn_valid(pte_pfn(pte)));

        if (write && !pte_write(pte))
                return 0;

        refs = 0;
        head = pte_page(pte);
        page = head + ((addr & ~HPAGE_MASK) >> PAGE_SHIFT);
        do {
                pages[*nr] = page;
                (*nr)++;
                page++;
                refs++;
        } while (addr += PAGE_SIZE, addr != end);
        get_head_page_multiple(head, refs);

        return 1;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
