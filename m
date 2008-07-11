From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 12/13] GRU Driver V3 -  export is_uv_system(), zap_page_range() & follow_page()
Date: Fri, 11 Jul 2008 13:30:01 +1000
References: <20080703213348.489120321@attica.americas.sgi.com> <200807110252.00887.nickpiggin@yahoo.com.au> <20080710172036.GB5972@sgi.com>
In-Reply-To: <20080710172036.GB5972@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807111330.02090.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, Christoph Hellwig <hch@infradead.org>, cl@linux-foundation.org, akpm@osdl.org, linux-kernel@vger.kernel.org, mingo@elte.hu, tglx@linutronix.de, holt@sgi.com, andrea@qumranet.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 11 July 2008 03:20, Jack Steiner wrote:
> On Fri, Jul 11, 2008 at 02:52:00AM +1000, Nick Piggin wrote:

> > lockless gup checks for struct page by checking a bit in the pte.
> > This should be enough to guarantee  it is cacheable memory (unless
> > another driver has done something tricky like set the the page's
> > cache attributes to UC or WC -- I don't know if there is a way to
> > completely avoid all corner cases).
>
> The GRU itself has no need to reference the page struct.
> However, it WILL reference valid ptes that represent pages imported from
> other SSIs via xpmem. These will have cacheable ptes but no page structs.

Oh, I'm sorry Jack, I misread the patch and thought you still had
the page_to_phys thing in there... OK, then it probably isn't
broken. And in which case you would have to add a little code to
gup.c...


> Maybe checking the pte attributes is the best way to do the check.
>
> If we take this approach, what is a good API for the gup.c walker?
> Return the pte attributes?
>
> 	int get_user_pte(struct mm_struct *mm, unsigned long address,
> 	        int write, unsigned long *paddr, int *pageshift, pgprot_t *prot)
>
> The GRU would enforce the check for cacheable access.

Yeah that wouldn't be a bad API, although being a lockless, may-fail,
not available on all archs kind of thing, I would prefer a different
name, maybe get_user_pte_fast() to match?

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
