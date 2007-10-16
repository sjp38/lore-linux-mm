From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [rfc] lockless get_user_pages for dio (and more)
Date: Tue, 16 Oct 2007 12:15:32 +1000
References: <20071008225234.GC27824@linux-os.sc.intel.com> <200710152225.11433.nickpiggin@yahoo.com.au> <b040c32a0710151321s74799f0ax6e3e0c4042429c5b@mail.gmail.com>
In-Reply-To: <b040c32a0710151321s74799f0ax6e3e0c4042429c5b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710161215.33284.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: "Siddha, Suresh B" <suresh.b.siddha@intel.com>, Badari Pulavarty <pbadari@gmail.com>, linux-mm <linux-mm@kvack.org>, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

On Tuesday 16 October 2007 06:21, Ken Chen wrote:
> On 10/15/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> > +static int gup_huge_pmd(pmd_t pmd, unsigned long addr,
> > +{
> > +	pte_t pte = *(pte_t *)&pmd;
> > +
> > +	if (write && !pte_write(pte))
> > +		return 0;
> > +
> > +	do {
> > +		unsigned long pfn_offset;
> > +		struct page *page;
> > +
> > +		pfn_offset = (addr & ~HPAGE_MASK) >> PAGE_SHIFT;
> > +		page = pte_page(pte) + pfn_offset;
> > +		get_page(page);
> > +		pages[*nr] = page;
> > +		(*nr)++;
> > +
> > +	} while (addr += PAGE_SIZE, addr != end);
> > +
> > +	return 1;
> > +}
>
> Since get_page() on compound page will reference back to the head
> page, you can take a ref directly against the head page instead of
> traversing to tail page and loops around back to the head page.  It is
> especially beneficial for large hugetlb page size, i.e., 1 GB page
> size so one does not have to pollute cache with tail page's struct
> page. I prefer doing the following:
>
> +		page = pte_page(pte);
> +		get_page(page);
> +		pfn_offset = (addr & ~HPAGE_MASK) >> PAGE_SHIFT;
> +		pages[*nr] = page + pfn_offset;
> +		(*nr)++;

Very good point. Actually we could also possibly optimise this
loop so that all it does is to fill the pages[] array, and then
have a function to increment the head page refcount by "N", thus
reducing atomic operations by a factor of N...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
