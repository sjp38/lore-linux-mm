Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 82CC46B025E
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 03:49:50 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id g13so138333945ioj.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 00:49:50 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id f123si3233816ita.23.2016.06.17.00.49.47
        for <linux-mm@kvack.org>;
        Fri, 17 Jun 2016 00:49:48 -0700 (PDT)
Date: Fri, 17 Jun 2016 16:49:45 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 10/10] mm: balance LRU lists based on relative thrashing
Message-ID: <20160617074945.GE2374@bbox>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-11-hannes@cmpxchg.org>
 <20160610021935.GF29779@bbox>
 <20160613155231.GB30642@cmpxchg.org>
 <20160615022341.GF17127@bbox>
 <20160616151207.GB17692@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160616151207.GB17692@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Thu, Jun 16, 2016 at 11:12:07AM -0400, Johannes Weiner wrote:
> On Wed, Jun 15, 2016 at 11:23:41AM +0900, Minchan Kim wrote:
> > On Mon, Jun 13, 2016 at 11:52:31AM -0400, Johannes Weiner wrote:
> > > On Fri, Jun 10, 2016 at 11:19:35AM +0900, Minchan Kim wrote:
> > > > Other concern about PG_workingset is naming. For file-backed pages, it's
> > > > good because file-backed pages started from inactive's head and promoted
> > > > active LRU once two touch so it's likely to be workingset. However,
> > > > for anonymous page, it starts from active list so every anonymous page
> > > > has PG_workingset while mlocked pages cannot have a chance to have it.
> > > > It wouldn't matter in eclaim POV but if we would use PG_workingset as
> > > > indicator to identify real workingset page, it might be confused.
> > > > Maybe, We could mark mlocked pages as workingset unconditionally.
> > > 
> > > Hm I'm not sure it matters. Technically we don't have to set it on
> > > anon, but since it's otherwise unused anyway, it's nice to set it to
> > > reinforce the notion that anon is currently always workingset.
> > 
> > When I read your description firstly, I thought the flag for anon page
> > is set on only swapin but now I feel you want to set it for all of
> > anonymous page but it has several holes like mlocked pages, shmem pages
> > and THP and you want to fix it in THP case only.
> > Hm, What's the rule?
> > It's not consistent and confusing to me. :(
> 
> I think you are might be over thinking this a bit ;)
> 
> The current LRU code has a notion of workingset pages, which is anon
> pages and multi-referenced file pages. shmem are considered file for
> this purpose. That's why anon start out active and files/shmem do
> not. This patch adds refaulting pages to the mix.
> 
> PG_workingset keeps track of pages that were recently workingset, so
> we set it when the page enters the workingset (activations and
> refaults, and new anon from the start). The only thing we need out of
> this flag is to tell us whether reclaim is going after the workingset
> because the LRUs have become too small to hold it.

Understood.

Divergence comes from here. It seems you design the page flag for only
aging/balancing logic working well while I am thinking to leverage the
flag to identify real workingset. I mean a anonymous page would be a cold
if it has just cold data for the application which would be swapped
out after a short time and never swap-in until process exits. However,
we put it from active list so that it has PG_workingset but it's cold
page.

Yes, we cannot use the flag for such purpose in this SEQ replacement so
I will not insist on it.

> 
> mlocked pages are not really interesting because not only are they not
> evictable, they are entirely exempt from aging. Without aging, we can
> not say whether they are workingset or not. We'll just leave the flags
> alone, like the active flag right now.
> 
> > I think it would be better that PageWorkingset function should return
> > true in case of PG_swapbacked set if we want to consider all pages of
> > anonymous LRU PG_workingset which is more clear, not error-prone, IMHO.
> 
> I'm not sure I see the upside, it would be more branches and code.
> 
> > Another question:
> > 
> > Do we want to retain [1]?
> > 
> > This patch motivates from swap IO could be much faster than file IO
> > so that it would be natural if we rely on refaulting feedback rather
> > than forcing evicting file cache?
> > 
> > [1] e9868505987a, mm,vmscan: only evict file pages when we have plenty?
> 
> Yes! We don't want to go after the workingset, whether it be cache or
> anonymous, while there is single-use page cache lying around that we
> can reclaim for free, with no IO and little risk of future IO. Anon
> memory doesn't have this equivalent. Only cache is lazy-reclaimed.
> 
> Once the cache refaults, we activate it to reflect the fact that it's
> workingset. Only when we run out of single-use cache do we want to
> reclaim multi-use pages, and *then* we balance workingsets based on
> cost of refetching each side from secondary storage.

If pages in inactive file LRU are really single-use page cache, I agree.

However, how does the logic can work like that?
If reclaimed file pages were part of workingset(i.e., refault happens),
we give the pressure to anonymous LRU but get_scan_count still force to
reclaim file lru until inactive file LRU list size is enough low.

With that, too many file workingset could be evicted although anon swap
is cheaper on fast swap storage?

IOW, refault mechanisme works once inactive file LRU list size is enough
small but small inactive file LRU doesn't guarantee it has only multiple
-use pages. Hm, Isn't it a problem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
