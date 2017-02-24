Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E39CA6B0038
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 18:26:29 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id o64so52450028pfb.2
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 15:26:29 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id m134si8542353pga.262.2017.02.24.15.26.28
        for <linux-mm@kvack.org>;
        Fri, 24 Feb 2017 15:26:28 -0800 (PST)
Date: Sat, 25 Feb 2017 08:26:24 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH V4 4/6] mm: reclaim MADV_FREE pages
Message-ID: <20170224232624.GA4635@bbox>
References: <cover.1487788131.git.shli@fb.com>
 <94eccf0fcf927f31377a60d7a9f900b7e743fb06.1487788131.git.shli@fb.com>
 <20170224021218.GD9818@bbox>
 <20170224153655.GA20092@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170224153655.GA20092@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

Hi Johannes,

On Fri, Feb 24, 2017 at 10:36:55AM -0500, Johannes Weiner wrote:
> On Fri, Feb 24, 2017 at 11:12:18AM +0900, Minchan Kim wrote:
> > > @@ -1525,8 +1531,8 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
> > >  
> > >  	if (ret != SWAP_MLOCK && !page_mapcount(page)) {
> > >  		ret = SWAP_SUCCESS;
> > > -		if (rp.lazyfreed && !PageDirty(page))
> > > -			ret = SWAP_LZFREE;
> > > +		if (rp.lazyfreed && PageDirty(page))
> > > +			ret = SWAP_DIRTY;
> > 
> > Hmm, I don't understand why we need to introduce new return value.
> > Can't we set SetPageSwapBacked and return SWAP_FAIL in try_to_unmap_one?
> 
> I think that's a bad idea. A function called "try_to_unmap" shouldn't
> have as a side effect that it changes the page's LRU type in an error
> case. Let try_to_unmap be about unmapping the page. If it fails, make
> it report why and let the caller deal with the fallout. Any LRU fixups
> are much better placed in vmscan.c.

I don't think it's page's LRU type change. SetPageSwapBacked is just
indication that page is swappable or not.
Like mlock_vma_page in try_to_unmap_one, we can set SetPageSwapBacked
if we found the lazyfree page dirty. If we don't need to move dirty
lazyfree page to another LRU list, it would be better to not introduce
new return value in try_to_unmap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
