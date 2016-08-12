Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7547A6B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 08:26:15 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l4so6975276wml.0
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 05:26:15 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id f13si6863047wjz.114.2016.08.12.05.26.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Aug 2016 05:26:14 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id o80so2582844wme.0
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 05:26:14 -0700 (PDT)
Date: Fri, 12 Aug 2016 21:25:37 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH 1/5] mm/debug_pagealloc: clean-up guard page handling code
Message-ID: <20160812122537.GA568@swordfish>
References: <1470809784-11516-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1470809784-11516-2-git-send-email-iamjoonsoo.kim@lge.com>
 <20160810081453.GB573@swordfish>
 <172b4c63-b519-cf1d-ed68-1f85f2caed14@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <172b4c63-b519-cf1d-ed68-1f85f2caed14@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On (08/11/16 11:41), Vlastimil Babka wrote:
> On 08/10/2016 10:14 AM, Sergey Senozhatsky wrote:
> > > @@ -1650,18 +1655,15 @@ static inline void expand(struct zone *zone, struct page *page,
> > >  		size >>= 1;
> > >  		VM_BUG_ON_PAGE(bad_range(zone, &page[size]), &page[size]);
> > > 
> > > -		if (IS_ENABLED(CONFIG_DEBUG_PAGEALLOC) &&
> > > -			debug_guardpage_enabled() &&
> > > -			high < debug_guardpage_minorder()) {
> > > -			/*
> > > -			 * Mark as guard pages (or page), that will allow to
> > > -			 * merge back to allocator when buddy will be freed.
> > > -			 * Corresponding page table entries will not be touched,
> > > -			 * pages will stay not present in virtual address space
> > > -			 */
> > > -			set_page_guard(zone, &page[size], high, migratetype);
> > > +		/*
> > > +		 * Mark as guard pages (or page), that will allow to
> > > +		 * merge back to allocator when buddy will be freed.
> > > +		 * Corresponding page table entries will not be touched,
> > > +		 * pages will stay not present in virtual address space
> > > +		 */
> > > +		if (set_page_guard(zone, &page[size], high, migratetype))
> > >  			continue;
> > > -		}
> > 
> > so previously IS_ENABLED(CONFIG_DEBUG_PAGEALLOC) could have optimized out
> > the entire branch -- no set_page_guard() invocation and checks, right? but
> > now we would call set_page_guard() every time?
> 
> No, there's a !CONFIG_DEBUG_PAGEALLOC version of set_page_guard() that
> returns false (static inline), so this whole if will be eliminated by the
> compiler, same as before.

ah, indeed. didn't notice it.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
