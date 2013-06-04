Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 386056B0037
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 00:41:41 -0400 (EDT)
Date: Tue, 4 Jun 2013 13:41:39 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [v4][PATCH 1/6] mm: swap: defer clearing of page_private() for
 swap cache pages
Message-ID: <20130604044139.GB14719@blaptop>
References: <20130531183855.44DDF928@viggo.jf.intel.com>
 <20130531183856.1D7D75AD@viggo.jf.intel.com>
 <20130603054048.GA27858@blaptop>
 <51ACADCD.70904@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51ACADCD.70904@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com

On Mon, Jun 03, 2013 at 07:53:01AM -0700, Dave Hansen wrote:
> On 06/02/2013 10:40 PM, Minchan Kim wrote:
> >> > diff -puN mm/vmscan.c~__delete_from_swap_cache-dont-clear-page-private mm/vmscan.c
> >> > --- linux.git/mm/vmscan.c~__delete_from_swap_cache-dont-clear-page-private	2013-05-30 16:07:50.632079492 -0700
> >> > +++ linux.git-davehans/mm/vmscan.c	2013-05-30 16:07:50.637079712 -0700
> >> > @@ -494,6 +494,8 @@ static int __remove_mapping(struct addre
> >> >  		__delete_from_swap_cache(page);
> >> >  		spin_unlock_irq(&mapping->tree_lock);
> >> >  		swapcache_free(swap, page);
> >> > +		set_page_private(page, 0);
> >> > +		ClearPageSwapCache(page);
> > It it worth to support non-atomic version of ClearPageSwapCache?
> 
> Just for this, probably not.
> 
> It does look like a site where it would be theoretically safe to use
> non-atomic flag operations since the page is on a one-way trip to the
> allocator at this point and the __clear_page_locked() now happens _just_
> after this code.

True.

> 
> But, personally, I'm happy to leave it as-is.  The atomic vs. non-atomic
> flags look to me like a micro-optimization that we should use when we
> _know_ there will be some tangible benefit.  Otherwise, they're just
> something extra for developers to trip over and cause very subtle bugs.

I just asked it because when I read the description of patchset, I felt
you were very sensitive to the atomic operation on many CPU system with
several sockets. Anyway, if you don't want it, I don't mind it, either.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
