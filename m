Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 47C106B0389
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 18:37:55 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 1so62523548pgz.5
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 15:37:55 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id b44si8619971pli.24.2017.02.24.15.37.53
        for <linux-mm@kvack.org>;
        Fri, 24 Feb 2017 15:37:54 -0800 (PST)
Date: Sat, 25 Feb 2017 08:37:52 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH V4 3/6] mm: move MADV_FREE pages into LRU_INACTIVE_FILE
 list
Message-ID: <20170224233752.GB4635@bbox>
References: <cover.1487788131.git.shli@fb.com>
 <a1a28aa85280a7b3fd6145604eed4132228bd6d1.1487788131.git.shli@fb.com>
 <20170224014939.GC9818@bbox>
 <20170224061549.GB86912@brenorobert-mbp.dhcp.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170224061549.GB86912@brenorobert-mbp.dhcp.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

Hi Shaohua,

On Thu, Feb 23, 2017 at 10:15:50PM -0800, Shaohua Li wrote:
> On Fri, Feb 24, 2017 at 10:49:39AM +0900, Minchan Kim wrote:
> > On Wed, Feb 22, 2017 at 10:50:41AM -0800, Shaohua Li wrote:
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
> > Other than that Johannes pointed out, code itself looks good to me.
> > However, I hope to merge this patch with next one.
> > It's enough simple to merge, change behavior(about deactivation),
> > mark_page_lazyfree is introduced but there is no callsite to use it
> > in this patch.
> > 
> > I don't think it's worth to separate.
> 
> I think it's more clear in this way, doing one thing in one patch.

There are several times to prevent it that introduce new function
*here* and use it *there*. One of example from Johannes:

https://marc.info/?l=linux-mm&m=147430500910960&w=2

I don't understand why this case is okay.
Nomally, it's anti-pattern for git-bisect which adds uselss bisect
point. Even, if it were good for review, I might agree but this
case is not that, too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
