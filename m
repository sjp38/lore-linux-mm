Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id AC66D6B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 16:31:17 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/3] HWPOISON: fix action_result() to print out dirty/clean
Date: Thu, 23 Aug 2012 16:31:09 -0400
Message-Id: <1345753869-31053-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20120823093330.GC12745@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi.kleen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

Thank you for your review.

On Thu, Aug 23, 2012 at 05:33:30PM +0800, Fengguang Wu wrote:
> On Wed, Aug 22, 2012 at 11:17:33AM -0400, Naoya Horiguchi wrote:
> > action_result() fails to print out "dirty" even if an error occurred on a
> > dirty pagecache, because when we check PageDirty in action_result() it was
> > cleared after page isolation even if it's dirty before error handling. This
> > can break some applications that monitor this message, so should be fixed.
> > 
> > There are several callers of action_result() except page_action(), but
> > either of them are not for LRU pages but for free pages or kernel pages,
> > so we don't have to consider dirty or not for them.
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Reviewed-by: Andi Kleen <ak@linux.intel.com>
> > ---
> >  mm/memory-failure.c | 22 +++++++++-------------
> >  1 file changed, 9 insertions(+), 13 deletions(-)
> > 
> > diff --git v3.6-rc1.orig/mm/memory-failure.c v3.6-rc1/mm/memory-failure.c
> > index a6e2141..79dfb2f 100644
> > --- v3.6-rc1.orig/mm/memory-failure.c
> > +++ v3.6-rc1/mm/memory-failure.c
> > @@ -779,16 +779,16 @@ static struct page_state {
> >  	{ compound,	compound,	"huge",		me_huge_page },
> >  #endif
> >  
> > -	{ sc|dirty,	sc|dirty,	"swapcache",	me_swapcache_dirty },
> > -	{ sc|dirty,	sc,		"swapcache",	me_swapcache_clean },
> > +	{ sc|dirty,	sc|dirty,	"dirty swapcache",	me_swapcache_dirty },
> > +	{ sc|dirty,	sc,		"clean swapcache",	me_swapcache_clean },
> >  
> > -	{ unevict|dirty, unevict|dirty,	"unevictable LRU", me_pagecache_dirty},
> > -	{ unevict,	unevict,	"unevictable LRU", me_pagecache_clean},
> > +	{ unevict|dirty, unevict|dirty,	"dirty unevictable LRU", me_pagecache_dirty },
> > +	{ unevict,	unevict,	"clean unevictable LRU", me_pagecache_clean },
> >  
> > -	{ mlock|dirty,	mlock|dirty,	"mlocked LRU",	me_pagecache_dirty },
> > -	{ mlock,	mlock,		"mlocked LRU",	me_pagecache_clean },
> > +	{ mlock|dirty,	mlock|dirty,	"dirty mlocked LRU",	me_pagecache_dirty },
> > +	{ mlock,	mlock,		"clean mlocked LRU",	me_pagecache_clean },
> >  
> > -	{ lru|dirty,	lru|dirty,	"LRU",		me_pagecache_dirty },
> > +	{ lru|dirty,	lru|dirty,	"dirty LRU",	me_pagecache_dirty },
> >  	{ lru|dirty,	lru,		"clean LRU",	me_pagecache_clean },
> 
> According to the set_page_dirty() comment, the dirty bit might be set
> outside the page lock (however I don't know any concrete examples).
> That means the word "clean" is not 100% right.  That's probably why we
> only report "dirty LRU" and didn't say "clean LRU".

So this doesn't seem to be just a messaging problem. If PageDirty is set
outside page lock, we can handle the dirty page only with me_pagecache_clean(),
without me_pagecache_dirty().
It might be a good idea to add some check code to detect such kind of race
and give up error isolation if it does.
I'll dig into who sets dirty flags outside/inside page locks, and look for
a workaround. (But it will be in another patch...)

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
