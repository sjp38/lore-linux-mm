Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id EAB636B0007
	for <linux-mm@kvack.org>; Sun, 25 Feb 2018 23:56:24 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id t2so7098016plr.15
        for <linux-mm@kvack.org>; Sun, 25 Feb 2018 20:56:24 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h2-v6sor2465578plh.17.2018.02.25.20.56.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 25 Feb 2018 20:56:23 -0800 (PST)
Date: Mon, 26 Feb 2018 13:56:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH RESEND 1/2] mm: swap: clean up swap readahead
Message-ID: <20180226045617.GA112402@rodete-desktop-imager.corp.google.com>
References: <20180220085249.151400-1-minchan@kernel.org>
 <20180220085249.151400-2-minchan@kernel.org>
 <874lm83zho.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <874lm83zho.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Feb 23, 2018 at 04:02:27PM +0800, Huang, Ying wrote:
> <minchan@kernel.org> writes:
> [snip]
> 
> > diff --git a/mm/swap_state.c b/mm/swap_state.c
> > index 39ae7cfad90f..c56cce64b2c3 100644
> > --- a/mm/swap_state.c
> > +++ b/mm/swap_state.c
> > @@ -332,32 +332,38 @@ struct page *lookup_swap_cache(swp_entry_t entry, struct vm_area_struct *vma,
> >  			       unsigned long addr)
> >  {
> >  	struct page *page;
> > -	unsigned long ra_info;
> > -	int win, hits, readahead;
> >  
> >  	page = find_get_page(swap_address_space(entry), swp_offset(entry));
> >  
> >  	INC_CACHE_INFO(find_total);
> >  	if (page) {
> > +		bool vma_ra = swap_use_vma_readahead();
> > +		bool readahead = TestClearPageReadahead(page);
> > +
> 
> TestClearPageReadahead() cannot be called for compound page.  As in
> 
> PAGEFLAG(Readahead, reclaim, PF_NO_COMPOUND)
> 	TESTCLEARFLAG(Readahead, reclaim, PF_NO_COMPOUND)
> 
> >  		INC_CACHE_INFO(find_success);
> >  		if (unlikely(PageTransCompound(page)))
> >  			return page;
> > -		readahead = TestClearPageReadahead(page);
> 
> So we can only call it here after checking whether page is compound.

Hi Huang,

Thanks for cathing this.
However, I don't see the reason we should rule out THP page for
readahead marker. Could't we relax the rule?

I hope we can do so that we could remove PageTransCompound check
for readahead marker, which makes code ugly.
