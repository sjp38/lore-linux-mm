Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 30DCA6B025F
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 03:46:12 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id j3so16123027pga.5
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 00:46:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b5si914985ple.404.2017.10.31.00.46.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 Oct 2017 00:46:11 -0700 (PDT)
Date: Tue, 31 Oct 2017 08:46:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH -mm -V2] mm, swap: Fix false error message in
 __swp_swapcount()
Message-ID: <20171031074607.exg2nh6qvnvkqu3s@dhcp22.suse.cz>
References: <20171027055327.5428-1-ying.huang@intel.com>
 <20171029235713.GA4332@bbox>
 <20171030080230.apijacsx7fd3qeox@dhcp22.suse.cz>
 <20171031021702.GA942@bbox>
 <20171031073107.x5rpkf4emf74ymyk@dhcp22.suse.cz>
 <20171031073710.GA857@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171031073710.GA857@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <huang.ying.caritas@gmail.com>, Tim Chen <tim.c.chen@linux.intel.com>, stable@vger.kernel.org, Christian Kujau <lists@nerdbynature.de>

On Tue 31-10-17 16:37:10, Minchan Kim wrote:
> On Tue, Oct 31, 2017 at 08:31:07AM +0100, Michal Hocko wrote:
> > On Tue 31-10-17 11:17:02, Minchan Kim wrote:
> > > On Mon, Oct 30, 2017 at 09:02:30AM +0100, Michal Hocko wrote:
> > > > On Mon 30-10-17 08:57:13, Minchan Kim wrote:
> > > > [...]
> > > > > Although it's better than old, we can make it simple, still.
> > > > > 
> > > > > diff --git a/include/linux/swapops.h b/include/linux/swapops.h
> > > > > index 291c4b534658..f50d5a48f03a 100644
> > > > > --- a/include/linux/swapops.h
> > > > > +++ b/include/linux/swapops.h
> > > > > @@ -41,6 +41,13 @@ static inline unsigned swp_type(swp_entry_t entry)
> > > > >  	return (entry.val >> SWP_TYPE_SHIFT(entry));
> > > > >  }
> > > > >  
> > > > > +extern struct swap_info_struct *swap_info[];
> > > > > +
> > > > > +static inline struct swap_info_struct *swp_si(swp_entry_t entry)
> > > > > +{
> > > > > +	return swap_info[swp_type(entry)];
> > > > > +}
> > > > > +
> > > > >  /*
> > > > >   * Extract the `offset' field from a swp_entry_t.  The swp_entry_t is in
> > > > >   * arch-independent format
> > > > > diff --git a/mm/swap_state.c b/mm/swap_state.c
> > > > > index 378262d3a197..a0fe2d54ad09 100644
> > > > > --- a/mm/swap_state.c
> > > > > +++ b/mm/swap_state.c
> > > > > @@ -554,6 +554,7 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
> > > > >  			struct vm_area_struct *vma, unsigned long addr)
> > > > >  {
> > > > >  	struct page *page;
> > > > > +	struct swap_info_struct *si = swp_si(entry);
> > > > 
> > > > Aren't you accessing beyond the array here?
> > > 
> > > I couldn't understand what you intend. Could you explain what case does it accesses
> > > beyond the arrary?
> > 
> > what if swp_type > nr_swapfiles
> 
> Logicall, it shouldn't be happen but it's a bug once it happens.
> Such a bug can happen everywhere.
> Why do you want to take care in this logic?

You are right. It was my misunderstanding of the patch. I though the
readahead swap entries could overflow swp_type as well as the offset.
My bad.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
