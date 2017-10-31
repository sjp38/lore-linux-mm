Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id ACDF46B0033
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 22:17:05 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z11so13285815pfk.23
        for <linux-mm@kvack.org>; Mon, 30 Oct 2017 19:17:05 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id f30si330770plf.32.2017.10.30.19.17.04
        for <linux-mm@kvack.org>;
        Mon, 30 Oct 2017 19:17:04 -0700 (PDT)
Date: Tue, 31 Oct 2017 11:17:02 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -mm -V2] mm, swap: Fix false error message in
 __swp_swapcount()
Message-ID: <20171031021702.GA942@bbox>
References: <20171027055327.5428-1-ying.huang@intel.com>
 <20171029235713.GA4332@bbox>
 <20171030080230.apijacsx7fd3qeox@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171030080230.apijacsx7fd3qeox@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <huang.ying.caritas@gmail.com>, Tim Chen <tim.c.chen@linux.intel.com>, stable@vger.kernel.org, Christian Kujau <lists@nerdbynature.de>

On Mon, Oct 30, 2017 at 09:02:30AM +0100, Michal Hocko wrote:
> On Mon 30-10-17 08:57:13, Minchan Kim wrote:
> [...]
> > Although it's better than old, we can make it simple, still.
> > 
> > diff --git a/include/linux/swapops.h b/include/linux/swapops.h
> > index 291c4b534658..f50d5a48f03a 100644
> > --- a/include/linux/swapops.h
> > +++ b/include/linux/swapops.h
> > @@ -41,6 +41,13 @@ static inline unsigned swp_type(swp_entry_t entry)
> >  	return (entry.val >> SWP_TYPE_SHIFT(entry));
> >  }
> >  
> > +extern struct swap_info_struct *swap_info[];
> > +
> > +static inline struct swap_info_struct *swp_si(swp_entry_t entry)
> > +{
> > +	return swap_info[swp_type(entry)];
> > +}
> > +
> >  /*
> >   * Extract the `offset' field from a swp_entry_t.  The swp_entry_t is in
> >   * arch-independent format
> > diff --git a/mm/swap_state.c b/mm/swap_state.c
> > index 378262d3a197..a0fe2d54ad09 100644
> > --- a/mm/swap_state.c
> > +++ b/mm/swap_state.c
> > @@ -554,6 +554,7 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
> >  			struct vm_area_struct *vma, unsigned long addr)
> >  {
> >  	struct page *page;
> > +	struct swap_info_struct *si = swp_si(entry);
> 
> Aren't you accessing beyond the array here?

I couldn't understand what you intend. Could you explain what case does it accesses
beyond the arrary?

Thanks.

> 
> >  	unsigned long entry_offset = swp_offset(entry);
> >  	unsigned long offset = entry_offset;
> >  	unsigned long start_offset, end_offset;
> > @@ -572,6 +573,9 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
> >  	if (!start_offset)	/* First page is swap header. */
> >  		start_offset++;
> >  
> > +	if (end_offset >= si->max)
> > +		end_offset = si->max - 1;
> > +
> >  	blk_start_plug(&plug);
> >  	for (offset = start_offset; offset <= end_offset ; offset++) {
> >  		/* Ok, do the async read-ahead now */
> 
> -- 
> Michal Hocko
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
