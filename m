Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 851256B0038
	for <linux-mm@kvack.org>; Thu, 11 May 2017 21:34:23 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u187so36202060pgb.0
        for <linux-mm@kvack.org>; Thu, 11 May 2017 18:34:23 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id l192si1781374pga.13.2017.05.11.18.34.21
        for <linux-mm@kvack.org>;
        Thu, 11 May 2017 18:34:22 -0700 (PDT)
Date: Fri, 12 May 2017 10:34:16 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -mm -v10 1/3] mm, THP, swap: Delay splitting THP during
 swap out
Message-ID: <20170512013416.GA9545@bbox>
References: <20170425125658.28684-2-ying.huang@intel.com>
 <20170427053141.GA1925@bbox>
 <87mvb21fz1.fsf@yhuang-dev.intel.com>
 <20170428084044.GB19510@bbox>
 <20170501104430.GA16306@cmpxchg.org>
 <20170501235332.GA4411@bbox>
 <20170510135654.GD17121@cmpxchg.org>
 <20170510232556.GA26521@bbox>
 <20170511012213.GA27659@bbox>
 <20170511104058.GD6244@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170511104058.GD6244@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, cgroups@vger.kernel.org

Hi Hannes,

On Thu, May 11, 2017 at 06:40:58AM -0400, Johannes Weiner wrote:
> On Thu, May 11, 2017 at 10:22:13AM +0900, Minchan Kim wrote:
> > On Thu, May 11, 2017 at 08:25:56AM +0900, Minchan Kim wrote:
> > > On Wed, May 10, 2017 at 09:56:54AM -0400, Johannes Weiner wrote:
> > > > Hi Michan,
> > > > 
> > > > On Tue, May 02, 2017 at 08:53:32AM +0900, Minchan Kim wrote:
> > > > > @@ -1144,7 +1144,7 @@ void swap_free(swp_entry_t entry)
> > > > >  /*
> > > > >   * Called after dropping swapcache to decrease refcnt to swap entries.
> > > > >   */
> > > > > -void swapcache_free(swp_entry_t entry)
> > > > > +void __swapcache_free(swp_entry_t entry)
> > > > >  {
> > > > >  	struct swap_info_struct *p;
> > > > >  
> > > > > @@ -1156,7 +1156,7 @@ void swapcache_free(swp_entry_t entry)
> > > > >  }
> > > > >  
> > > > >  #ifdef CONFIG_THP_SWAP
> > > > > -void swapcache_free_cluster(swp_entry_t entry)
> > > > > +void __swapcache_free_cluster(swp_entry_t entry)
> > > > >  {
> > > > >  	unsigned long offset = swp_offset(entry);
> > > > >  	unsigned long idx = offset / SWAPFILE_CLUSTER;
> > > > > @@ -1182,6 +1182,14 @@ void swapcache_free_cluster(swp_entry_t entry)
> > > > >  }
> > > > >  #endif /* CONFIG_THP_SWAP */
> > > > >  
> > > > > +void swapcache_free(struct page *page, swp_entry_t entry)
> > > > > +{
> > > > > +	if (!PageTransHuge(page))
> > > > > +		__swapcache_free(entry);
> > > > > +	else
> > > > > +		__swapcache_free_cluster(entry);
> > > > > +}
> > > > 
> > > > I don't think this is cleaner :/
> > 
> > Let's see a example add_to_swap. Without it, it looks like that.
> > 
> > int add_to_swap(struct page *page)
> > {
> >         entry = get_swap_page(page);
> >         ..
> >         ..
> > fail:
> >         if (PageTransHuge(page))
> >                 swapcache_free_cluster(entry);
> >         else
> >                 swapcache_free(entry);
> > }
> > 
> > It doesn't looks good to me because get_swap_page hides
> > where entry allocation is from cluster or slot but when
> > we free the entry allocated, we should be aware of the
> > internal and call right function. :(
> 
> This could be nicer indeed. I just don't like the underscore versions
> much, but symmetry with get_swap_page() would be nice.
> 
> How about put_swap_page()? :)

Good idea. It's the best one I can do now.
Actually, get_swap_page is awkward to me. Maybe it would be nicer to
rename it with get_swap_[slot|entry] but, I will postpone it if someone
would be on same page with me in future.

> 
> That can call the appropriate swapcache_free function then.

Yub.
Thanks for the review!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
