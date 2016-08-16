Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id AD0376B0268
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 22:52:44 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id e70so196411200ioi.3
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 19:52:44 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 135si19020644itm.100.2016.08.15.19.52.43
        for <linux-mm@kvack.org>;
        Mon, 15 Aug 2016 19:52:44 -0700 (PDT)
Date: Tue, 16 Aug 2016 11:58:33 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/5] mm/debug_pagealloc: clean-up guard page handling code
Message-ID: <20160816025833.GA16913@js1304-P5Q-DELUXE>
References: <1470809784-11516-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1470809784-11516-2-git-send-email-iamjoonsoo.kim@lge.com>
 <20160810081453.GB573@swordfish>
 <172b4c63-b519-cf1d-ed68-1f85f2caed14@suse.cz>
 <20160812122537.GA568@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160812122537.GA568@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Aug 12, 2016 at 09:25:37PM +0900, Sergey Senozhatsky wrote:
> On (08/11/16 11:41), Vlastimil Babka wrote:
> > On 08/10/2016 10:14 AM, Sergey Senozhatsky wrote:
> > > > @@ -1650,18 +1655,15 @@ static inline void expand(struct zone *zone, struct page *page,
> > > >  		size >>= 1;
> > > >  		VM_BUG_ON_PAGE(bad_range(zone, &page[size]), &page[size]);
> > > > 
> > > > -		if (IS_ENABLED(CONFIG_DEBUG_PAGEALLOC) &&
> > > > -			debug_guardpage_enabled() &&
> > > > -			high < debug_guardpage_minorder()) {
> > > > -			/*
> > > > -			 * Mark as guard pages (or page), that will allow to
> > > > -			 * merge back to allocator when buddy will be freed.
> > > > -			 * Corresponding page table entries will not be touched,
> > > > -			 * pages will stay not present in virtual address space
> > > > -			 */
> > > > -			set_page_guard(zone, &page[size], high, migratetype);
> > > > +		/*
> > > > +		 * Mark as guard pages (or page), that will allow to
> > > > +		 * merge back to allocator when buddy will be freed.
> > > > +		 * Corresponding page table entries will not be touched,
> > > > +		 * pages will stay not present in virtual address space
> > > > +		 */
> > > > +		if (set_page_guard(zone, &page[size], high, migratetype))
> > > >  			continue;
> > > > -		}
> > > 
> > > so previously IS_ENABLED(CONFIG_DEBUG_PAGEALLOC) could have optimized out
> > > the entire branch -- no set_page_guard() invocation and checks, right? but
> > > now we would call set_page_guard() every time?
> > 
> > No, there's a !CONFIG_DEBUG_PAGEALLOC version of set_page_guard() that
> > returns false (static inline), so this whole if will be eliminated by the
> > compiler, same as before.
> 
> ah, indeed. didn't notice it.

Hello, Sergey and Vlastimil.

I fixed all you commented and sent v2.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
