Date: Mon, 15 Oct 2007 10:49:36 -0700
From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Subject: Re: [rfc] lockless get_user_pages for dio (and more)
Message-ID: <20071015174936.GA10840@linux-os.sc.intel.com>
References: <20071008225234.GC27824@linux-os.sc.intel.com> <200710141101.02649.nickpiggin@yahoo.com.au> <20071014181929.GA19902@linux-os.sc.intel.com> <200710152225.11433.nickpiggin@yahoo.com.au> <1192467832.30128.5.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1192467832.30128.5.camel@dyn9047017100.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@gmail.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, "Siddha, Suresh B" <suresh.b.siddha@intel.com>, Ken Chen <kenchen@google.com>, linux-mm <linux-mm@kvack.org>, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

On Mon, Oct 15, 2007 at 10:03:52AM -0700, Badari Pulavarty wrote:
> On Mon, 2007-10-15 at 22:25 +1000, Nick Piggin wrote:
> +static int gup_huge_pmd(pmd_t pmd, unsigned long addr, unsigned long
> end, int write, struct page **pages, int *nr)
> +{
> +       pte_t pte = *(pte_t *)&pmd;
> +       struct page *page;
> +
> +       if ((pte_val(pte) & _PAGE_USER) != _PAGE_USER)
> +               return 0;
> +
> +       BUG_ON(!pfn_valid(pte_pfn(pte)));
> +
> +       if (write && !pte_write(pte))
> +               return 0;
> +
> +       page = pte_page(pte);
> +       do {
> +               unsigned long pfn_offset;
> +               struct page *p;
> +
> +               pfn_offset = (addr & ~HPAGE_MASK) >> PAGE_SHIFT;
> +               p = page + pfn_offset;
> +               get_page(page);
> +               pages[*nr] = page;
> +               (*nr)++;
> +
> +       } while (addr += PAGE_SIZE, addr != end);
>                          ^^^^^^^^^^
> 
> Shouldn't this be HPAGE_SIZE ?

I think it is compatible with old code. For a compound page, old code
is taking multiple ref counts and populating pages[] with all the individual
pages that make the compound page. Here, we are almost doing the same
thing (I say almost, because in here pages[] are getting populated with
the head page of the compound page. Anyhow routines like put_page that operate
on these pages should work seamlessly whether we use head/tail page).

thanks,
suresh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
