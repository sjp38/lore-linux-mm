Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 832586B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 13:04:14 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id na2so2317054lbb.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 10:04:14 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id q65si374742wma.113.2016.06.17.10.04.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 10:04:13 -0700 (PDT)
Date: Fri, 17 Jun 2016 13:01:29 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 10/10] mm: balance LRU lists based on relative thrashing
Message-ID: <20160617170128.GB10485@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-11-hannes@cmpxchg.org>
 <20160610021935.GF29779@bbox>
 <20160613155231.GB30642@cmpxchg.org>
 <20160615022341.GF17127@bbox>
 <20160616151207.GB17692@cmpxchg.org>
 <20160617074945.GE2374@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160617074945.GE2374@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Fri, Jun 17, 2016 at 04:49:45PM +0900, Minchan Kim wrote:
> On Thu, Jun 16, 2016 at 11:12:07AM -0400, Johannes Weiner wrote:
> > On Wed, Jun 15, 2016 at 11:23:41AM +0900, Minchan Kim wrote:
> > > On Mon, Jun 13, 2016 at 11:52:31AM -0400, Johannes Weiner wrote:
> > > > On Fri, Jun 10, 2016 at 11:19:35AM +0900, Minchan Kim wrote:
> > > > > Other concern about PG_workingset is naming. For file-backed pages, it's
> > > > > good because file-backed pages started from inactive's head and promoted
> > > > > active LRU once two touch so it's likely to be workingset. However,
> > > > > for anonymous page, it starts from active list so every anonymous page
> > > > > has PG_workingset while mlocked pages cannot have a chance to have it.
> > > > > It wouldn't matter in eclaim POV but if we would use PG_workingset as
> > > > > indicator to identify real workingset page, it might be confused.
> > > > > Maybe, We could mark mlocked pages as workingset unconditionally.
> > > > 
> > > > Hm I'm not sure it matters. Technically we don't have to set it on
> > > > anon, but since it's otherwise unused anyway, it's nice to set it to
> > > > reinforce the notion that anon is currently always workingset.
> > > 
> > > When I read your description firstly, I thought the flag for anon page
> > > is set on only swapin but now I feel you want to set it for all of
> > > anonymous page but it has several holes like mlocked pages, shmem pages
> > > and THP and you want to fix it in THP case only.
> > > Hm, What's the rule?
> > > It's not consistent and confusing to me. :(
> > 
> > I think you are might be over thinking this a bit ;)
> > 
> > The current LRU code has a notion of workingset pages, which is anon
> > pages and multi-referenced file pages. shmem are considered file for
> > this purpose. That's why anon start out active and files/shmem do
> > not. This patch adds refaulting pages to the mix.
> > 
> > PG_workingset keeps track of pages that were recently workingset, so
> > we set it when the page enters the workingset (activations and
> > refaults, and new anon from the start). The only thing we need out of
> > this flag is to tell us whether reclaim is going after the workingset
> > because the LRUs have become too small to hold it.
> 
> Understood.
> 
> Divergence comes from here. It seems you design the page flag for only
> aging/balancing logic working well while I am thinking to leverage the
> flag to identify real workingset. I mean a anonymous page would be a cold
> if it has just cold data for the application which would be swapped
> out after a short time and never swap-in until process exits. However,
> we put it from active list so that it has PG_workingset but it's cold
> page.
> 
> Yes, we cannot use the flag for such purpose in this SEQ replacement so
> I will not insist on it.

Well, I'm designing the flag so that it's useful for the case I am
introducing it for :)

I have no problem with changing its semantics later on if you want to
build on top of it, rename it, anything - so far as the LRU balancing
is unaffected of course.

But I don't think it makes sense to provision it for potential future
cases that may or may not materialize.

> > > Do we want to retain [1]?
> > > 
> > > This patch motivates from swap IO could be much faster than file IO
> > > so that it would be natural if we rely on refaulting feedback rather
> > > than forcing evicting file cache?
> > > 
> > > [1] e9868505987a, mm,vmscan: only evict file pages when we have plenty?
> > 
> > Yes! We don't want to go after the workingset, whether it be cache or
> > anonymous, while there is single-use page cache lying around that we
> > can reclaim for free, with no IO and little risk of future IO. Anon
> > memory doesn't have this equivalent. Only cache is lazy-reclaimed.
> > 
> > Once the cache refaults, we activate it to reflect the fact that it's
> > workingset. Only when we run out of single-use cache do we want to
> > reclaim multi-use pages, and *then* we balance workingsets based on
> > cost of refetching each side from secondary storage.
> 
> If pages in inactive file LRU are really single-use page cache, I agree.
> 
> However, how does the logic can work like that?
> If reclaimed file pages were part of workingset(i.e., refault happens),
> we give the pressure to anonymous LRU but get_scan_count still force to
> reclaim file lru until inactive file LRU list size is enough low.
> 
> With that, too many file workingset could be evicted although anon swap
> is cheaper on fast swap storage?
> 
> IOW, refault mechanisme works once inactive file LRU list size is enough
> small but small inactive file LRU doesn't guarantee it has only multiple
> -use pages. Hm, Isn't it a problem?

It's a trade-off between the cost of detecting a new workingset from a
stream of use-once pages, and the cost of use-once pages impose on the
established workingset.

That's a pretty easy choice, if you ask me. I'd rather ask cache pages
to prove they are multi-use than have use-once pages put pressure on
the workingset.

Sure, a spike like you describe is certainly possible, where a good
portion of the inactive file pages will be re-used in the near future,
yet we evict all of them in a burst of memory pressure when we should
have swapped. That's a worst case scenario for the use-once policy in
a workingset transition.

However, that's much better than use-once pages, which cost no
additional IO to reclaim and do not benefit from being cached at all,
causing the workingset to be trashed or swapped out.

In your scenario, the real multi-use pages will quickly refault and
get activated and the algorithm will adapt to the new circumstances.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
