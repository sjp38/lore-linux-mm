Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1FB7A6B0023
	for <linux-mm@kvack.org>; Fri, 28 Oct 2011 05:50:53 -0400 (EDT)
Received: by ggnh4 with SMTP id h4so4555324ggn.14
        for <linux-mm@kvack.org>; Fri, 28 Oct 2011 02:50:51 -0700 (PDT)
Date: Fri, 28 Oct 2011 18:50:40 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [patch 5/5]thp: split huge page if head page is isolated
Message-ID: <20111028095040.GA31281@barrios-laptop.redhat.com>
References: <1319511580.22361.141.camel@sli10-conroe>
 <20111027233407.GC29407@barrios-laptop.redhat.com>
 <1319778715.22361.155.camel@sli10-conroe>
 <20111028073026.GB6268@barrios-laptop.redhat.com>
 <1319790356.22361.165.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1319790356.22361.165.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "aarcange@redhat.com" <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, mel <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Fri, Oct 28, 2011 at 04:25:56PM +0800, Shaohua Li wrote:
> On Fri, 2011-10-28 at 15:30 +0800, Minchan Kim wrote:
> > On Fri, Oct 28, 2011 at 01:11:55PM +0800, Shaohua Li wrote:
> > > On Fri, 2011-10-28 at 07:34 +0800, Minchan Kim wrote:
> > > > On Tue, Oct 25, 2011 at 10:59:40AM +0800, Shaohua Li wrote:
> > > > > With current logic, if page reclaim finds a huge page, it will just reclaim
> > > > > the head page and leave tail pages reclaimed later. Let's take an example,
> > > > > lru list has page A and B, page A is huge page:
> > > > > 1. page A is isolated
> > > > > 2. page B is isolated
> > > > > 3. shrink_page_list() adds page A to swap page cache. so page A is split.
> > > > > page A+1, page A+2, ... are added to lru list.
> > > > > 4. shrink_page_list() adds page B to swap page cache.
> > > > > 5. page A and B is written out and reclaimed.
> > > > > 6. page A+1, A+2 ... is isolated and reclaimed later.
> > > > > So the reclaim order is A, B, ...(maybe other pages), A+1, A+2 ...
> > > > 
> > > > I don't see your code yet but have a question.
> > > > You mitigate this problem by 4/5 which could add subpages into lru tail
> > > > so subpages would reclaim next interation of reclaim.
> > > > 
> > > > What do we need 5/5?
> > > > Do I miss something?
> > > Both patches are required. without this patch, current page reclaim will
> > > only reclaim the first page of a huge page, because the hugepage isn't
> > > split yet. The hugepage is split when the first page is being written to
> > > swap, which is too later and page reclaim might already isolated a lot
> > > of pages.
> > 
> > When split happens, subpages would be located in tail of LRU by your 4/5.
> > (Assume tail of LRU is old age).
> yes, but a lot of other pages already isolated. we will reclaim those
> pages first. for example, reclaim huge page A, B. current reclaim order
> is A, B, A+1, ... B+1, because we will isolated A and B first, all tail
> pages are not isolated yet. While with my patch, the order is A, A
> +1, ... B, B+1,.... with my patch, we can avoid unnecessary page split
> or page isolation. This is exactly why my patch reduces the thp_split
> count.

It's possbile but I doubt how it is effective becuase add_to_swap has a unlikely as follows

	if (unlikely(PageTransHuge(page)))

I don't mean unlikely assumption is absolutely right.
But at least, you have to convince us of it's wrong.
Personally, I don't want to add more logic and handling THP pages
different with normal page unless it's real concern.

> 
> > In addtion, isolation happens 32 page chunk so the subpages would be isolated
> > and reclaimed in next iteration. I think 32 pages are not too many.
> > 
> > What do you think about it?
> since headpage and tailpages are in different list, the 32 chunk will
> not include tailpages.

Yes. but it would be handled in next iteration.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
