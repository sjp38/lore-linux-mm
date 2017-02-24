Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 20C826B0387
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 10:42:57 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id l22so5499137wmi.2
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 07:42:57 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 8si2904337wmh.1.2017.02.24.07.42.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Feb 2017 07:42:55 -0800 (PST)
Date: Fri, 24 Feb 2017 10:36:55 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V4 4/6] mm: reclaim MADV_FREE pages
Message-ID: <20170224153655.GA20092@cmpxchg.org>
References: <cover.1487788131.git.shli@fb.com>
 <94eccf0fcf927f31377a60d7a9f900b7e743fb06.1487788131.git.shli@fb.com>
 <20170224021218.GD9818@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170224021218.GD9818@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Fri, Feb 24, 2017 at 11:12:18AM +0900, Minchan Kim wrote:
> > @@ -1525,8 +1531,8 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
> >  
> >  	if (ret != SWAP_MLOCK && !page_mapcount(page)) {
> >  		ret = SWAP_SUCCESS;
> > -		if (rp.lazyfreed && !PageDirty(page))
> > -			ret = SWAP_LZFREE;
> > +		if (rp.lazyfreed && PageDirty(page))
> > +			ret = SWAP_DIRTY;
> 
> Hmm, I don't understand why we need to introduce new return value.
> Can't we set SetPageSwapBacked and return SWAP_FAIL in try_to_unmap_one?

I think that's a bad idea. A function called "try_to_unmap" shouldn't
have as a side effect that it changes the page's LRU type in an error
case. Let try_to_unmap be about unmapping the page. If it fails, make
it report why and let the caller deal with the fallout. Any LRU fixups
are much better placed in vmscan.c.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
