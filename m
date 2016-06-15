Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0145A6B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 22:23:38 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 5so24185570ioy.2
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 19:23:37 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 78si36796130iol.86.2016.06.14.19.23.36
        for <linux-mm@kvack.org>;
        Tue, 14 Jun 2016 19:23:37 -0700 (PDT)
Date: Wed, 15 Jun 2016 11:23:41 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 10/10] mm: balance LRU lists based on relative thrashing
Message-ID: <20160615022341.GF17127@bbox>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-11-hannes@cmpxchg.org>
 <20160610021935.GF29779@bbox>
 <20160613155231.GB30642@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160613155231.GB30642@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Mon, Jun 13, 2016 at 11:52:31AM -0400, Johannes Weiner wrote:
> On Fri, Jun 10, 2016 at 11:19:35AM +0900, Minchan Kim wrote:
> > On Mon, Jun 06, 2016 at 03:48:36PM -0400, Johannes Weiner wrote:
> > > @@ -79,6 +79,7 @@ enum pageflags {
> > >  	PG_dirty,
> > >  	PG_lru,
> > >  	PG_active,
> > > +	PG_workingset,
> > 
> > I think PG_workingset might be a good flag in the future, core MM might
> > utilize it to optimize something so I hope it supports for 32bit, too.
> > 
> > A usecase with PG_workingset in old was cleancache. A few year ago,
> > Dan tried it to only cache activated page from page cache to cleancache,
> > IIRC. As well, many system using zram(i.e., fast swap) are still 32 bit
> > architecture.
> > 
> > Just an idea. we might be able to move less important flag(i.e., enabled
> > in specific configuration, for example, PG_hwpoison or PG_uncached) in 32bit
> > to page_extra to avoid allocate extra memory space and charge the bit as
> > PG_workingset. :)
> 
> Yeah, I do think it should be a core flag. We have the space for it.
> 
> > Other concern about PG_workingset is naming. For file-backed pages, it's
> > good because file-backed pages started from inactive's head and promoted
> > active LRU once two touch so it's likely to be workingset. However,
> > for anonymous page, it starts from active list so every anonymous page
> > has PG_workingset while mlocked pages cannot have a chance to have it.
> > It wouldn't matter in eclaim POV but if we would use PG_workingset as
> > indicator to identify real workingset page, it might be confused.
> > Maybe, We could mark mlocked pages as workingset unconditionally.
> 
> Hm I'm not sure it matters. Technically we don't have to set it on
> anon, but since it's otherwise unused anyway, it's nice to set it to
> reinforce the notion that anon is currently always workingset.

When I read your description firstly, I thought the flag for anon page
is set on only swapin but now I feel you want to set it for all of
anonymous page but it has several holes like mlocked pages, shmem pages
and THP and you want to fix it in THP case only.
Hm, What's the rule?
It's not consistent and confusing to me. :(

I think it would be better that PageWorkingset function should return
true in case of PG_swapbacked set if we want to consider all pages of
anonymous LRU PG_workingset which is more clear, not error-prone, IMHO.

Another question:

Do we want to retain [1]?

This patch motivates from swap IO could be much faster than file IO
so that it would be natural if we rely on refaulting feedback rather
than forcing evicting file cache?

[1] e9868505987a, mm,vmscan: only evict file pages when we have plenty?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
