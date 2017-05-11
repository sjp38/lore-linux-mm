Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 421C76B0038
	for <linux-mm@kvack.org>; Thu, 11 May 2017 00:31:20 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u21so13294193pgn.5
        for <linux-mm@kvack.org>; Wed, 10 May 2017 21:31:20 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id u126si671963pgc.287.2017.05.10.21.31.18
        for <linux-mm@kvack.org>;
        Wed, 10 May 2017 21:31:19 -0700 (PDT)
Date: Thu, 11 May 2017 13:31:11 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -mm -v10 1/3] mm, THP, swap: Delay splitting THP during
 swap out
Message-ID: <20170511043111.GA6351@bbox>
References: <20170425125658.28684-1-ying.huang@intel.com>
 <20170425125658.28684-2-ying.huang@intel.com>
 <20170427053141.GA1925@bbox>
 <87mvb21fz1.fsf@yhuang-dev.intel.com>
 <20170428084044.GB19510@bbox>
 <20170501104430.GA16306@cmpxchg.org>
 <20170501235332.GA4411@bbox>
 <20170510135654.GD17121@cmpxchg.org>
 <20170510232556.GA26521@bbox>
 <87h90sb4jq.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87h90sb4jq.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, cgroups@vger.kernel.org

On Thu, May 11, 2017 at 08:50:01AM +0800, Huang, Ying wrote:
< snip >

> >> > @@ -1125,8 +1125,28 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >> >  		    !PageSwapCache(page)) {
> >> >  			if (!(sc->gfp_mask & __GFP_IO))
> >> >  				goto keep_locked;
> >> > -			if (!add_to_swap(page, page_list))
> >> > +swap_retry:
> >> > +			/*
> >> > +			 * Retry after split if we fail to allocate
> >> > +			 * swap space of a THP.
> >> > +			 */
> >> > +			if (!add_to_swap(page)) {
> >> > +				if (!PageTransHuge(page) ||
> >> > +				    split_huge_page_to_list(page, page_list))
> >> > +					goto activate_locked;
> >> > +				goto swap_retry;
> >> > +			}
> >> 
> >> This is definitely better.
> >
> > Thanks.
> >
> >> 
> >> However, I think it'd be cleaner without the label here:
> >> 
> >> 			if (!add_to_swap(page)) {
> >> 				if (!PageTransHuge(page))
> >> 					goto activate_locked;
> >> 				/* Split THP and swap individual base pages */
> >> 				if (split_huge_page_to_list(page, page_list))
> >> 					goto activate_locked;
> >> 				if (!add_to_swap(page))
> >> 					goto activate_locked;
> >
> > Yes.
> >
> >> 			}
> >> 
> >> > +			/*
> >> > +			 * Got swap space successfully. But unfortunately,
> >> > +			 * we don't support a THP page writeout so split it.
> >> > +			 */
> >> > +			if (PageTransHuge(page) &&
> >> > +				  split_huge_page_to_list(page, page_list)) {
> >> > +				delete_from_swap_cache(page);
> >> >  				goto activate_locked;
> >> > +			}
> >> 
> >> Pulling this out of add_to_swap() is an improvement for sure. Add an
> >> XXX: before that "we don't support THP writes" comment for good
> >> measure :)
> >
> > Sure.
> >
> > It could be a separate patch which makes add_to_swap clean via
> > removing page_list argument but I hope Huang take/fold it when he
> > resend it because it would be more important with THP swap.
> 
> Sure.  I will take this patch as one patch of the THP swap series.
> Because the first patch of the THP swap series is a little big, I don't
> think it is a good idea to fold this patch into it.  Could you update
> the patch according to Johannes' comments and resend it?

Okay, I will resend this clean-up patch against on yours patch
after finishing this discussion.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
