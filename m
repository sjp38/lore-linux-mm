Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 47D6B6B0387
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 21:53:30 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 6so22441850pfd.6
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 18:53:30 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id u59si378907plb.138.2017.02.27.18.53.28
        for <linux-mm@kvack.org>;
        Mon, 27 Feb 2017 18:53:29 -0800 (PST)
Date: Tue, 28 Feb 2017 11:53:26 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH V5 3/6] mm: move MADV_FREE pages into LRU_INACTIVE_FILE
 list
Message-ID: <20170228025326.GA2702@bbox>
References: <cover.1487965799.git.shli@fb.com>
 <2f87063c1e9354677b7618c647abde77b07561e5.1487965799.git.shli@fb.com>
 <20170227062801.GB23612@bbox>
 <20170227161309.GB62304@shli-mbp.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170227161309.GB62304@shli-mbp.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

Hi,

On Mon, Feb 27, 2017 at 08:13:10AM -0800, Shaohua Li wrote:
> On Mon, Feb 27, 2017 at 03:28:01PM +0900, Minchan Kim wrote:
> > Hello Shaohua,
> > 
> > On Fri, Feb 24, 2017 at 01:31:46PM -0800, Shaohua Li wrote:
> > > madv MADV_FREE indicate pages are 'lazyfree'. They are still anonymous
> > > pages, but they can be freed without pageout. To destinguish them
> > > against normal anonymous pages, we clear their SwapBacked flag.
> > > 
> > > MADV_FREE pages could be freed without pageout, so they pretty much like
> > > used once file pages. For such pages, we'd like to reclaim them once
> > > there is memory pressure. Also it might be unfair reclaiming MADV_FREE
> > > pages always before used once file pages and we definitively want to
> > > reclaim the pages before other anonymous and file pages.
> > > 
> > > To speed up MADV_FREE pages reclaim, we put the pages into
> > > LRU_INACTIVE_FILE list. The rationale is LRU_INACTIVE_FILE list is tiny
> > > nowadays and should be full of used once file pages. Reclaiming
> > > MADV_FREE pages will not have much interfere of anonymous and active
> > > file pages. And the inactive file pages and MADV_FREE pages will be
> > > reclaimed according to their age, so we don't reclaim too many MADV_FREE
> > > pages too. Putting the MADV_FREE pages into LRU_INACTIVE_FILE_LIST also
> > > means we can reclaim the pages without swap support. This idea is
> > > suggested by Johannes.
> > > 
> > > This patch doesn't move MADV_FREE pages to LRU_INACTIVE_FILE list yet to
> > > avoid bisect failure, next patch will do it.
> > > 
> > > The patch is based on Minchan's original patch.
> > > 
> > > Cc: Michal Hocko <mhocko@suse.com>
> > > Cc: Minchan Kim <minchan@kernel.org>
> > > Cc: Hugh Dickins <hughd@google.com>
> > > Cc: Rik van Riel <riel@redhat.com>
> > > Cc: Mel Gorman <mgorman@techsingularity.net>
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> > > Signed-off-by: Shaohua Li <shli@fb.com>
> > 
> > This patch doesn't address I pointed out in v4.
> > 
> > https://marc.info/?i=20170224233752.GB4635%40bbox
> > 
> > Let's discuss it if you still are against.
> 
> I really think a spearate patch makes the code clearer. There are a lot of
> places we introduce a function but don't use it immediately, if the way makes
> the code clearer. But anyway, I'll let Andrew decide if the two patches should
> be merged.

Acked-by: Minchan Kim <minchan@kernel.org>

Okay, I don't insist it any more if others are happy but please keep it in mind
that it's not a good habit, IMHO. Because

First of all, it makes review hard.

You introduce PGLAZYFREE in the patch but reviewer cannot find where it is used
so cannot review the accouting is right.

You introduce mark_page_lazyfree in the patch but there is no callsite to use
it. How can reviewer review it rightly? We cannot see what checks are missing
in there and what checks are redundant, and what kinds of lock we need.
It's hot path or slow path? Depending on it, we need to think approach.

There are many questions in there. It means we cannot review it without relying
upon upcoming patches, which is really not helpful for the review.

As well, it adds unncessary bisect point which is not a good, either.

I really want to merge two patches(introduce part and use-it part) unless
it makes review really hard or need per-subsystem apply.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
