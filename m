Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id C07446B0253
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 03:08:46 -0400 (EDT)
Received: by igdg1 with SMTP id g1so76186804igd.1
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 00:08:46 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id op7si15689317igb.80.2015.10.27.00.08.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Oct 2015 00:08:46 -0700 (PDT)
Received: by padhk11 with SMTP id hk11so213862956pad.1
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 00:08:45 -0700 (PDT)
Date: Tue, 27 Oct 2015 16:09:03 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 4/5] mm: simplify reclaim path for MADV_FREE
Message-ID: <20151027070903.GD26803@bbox>
References: <1445236307-895-1-git-send-email-minchan@kernel.org>
 <1445236307-895-5-git-send-email-minchan@kernel.org>
 <alpine.LSU.2.11.1510261828350.10825@eggly.anvils>
 <EDCE64A3-D874-4FE3-91B5-DE5E26A452F5@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <EDCE64A3-D874-4FE3-91B5-DE5E26A452F5@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>

Hello Yalin,

Sorry for missing you in Cc list.
IIRC, mails to send your previous mail address(Yalin.Wang@sonymobile.com)
were returned.

On Tue, Oct 27, 2015 at 11:44:09AM +0800, yalin wang wrote:
> 
> > On Oct 27, 2015, at 10:09, Hugh Dickins <hughd@google.com> wrote:
> > 
> > On Mon, 19 Oct 2015, Minchan Kim wrote:
> > 
> >> I made reclaim path mess to check and free MADV_FREEed page.
> >> This patch simplify it with tweaking add_to_swap.
> >> 
> >> So far, we mark page as PG_dirty when we add the page into
> >> swap cache(ie, add_to_swap) to page out to swap device but
> >> this patch moves PG_dirty marking under try_to_unmap_one
> >> when we decide to change pte from anon to swapent so if
> >> any process's pte has swapent for the page, the page must
> >> be swapped out. IOW, there should be no funcional behavior
> >> change. It makes relcaim path really simple for MADV_FREE
> >> because we just need to check PG_dirty of page to decide
> >> discarding the page or not.
> >> 
> >> Other thing this patch does is to pass TTU_BATCH_FLUSH to
> >> try_to_unmap when we handle freeable page because I don't
> >> see any reason to prevent it.
> >> 
> >> Cc: Hugh Dickins <hughd@google.com>
> >> Cc: Mel Gorman <mgorman@suse.de>
> >> Signed-off-by: Minchan Kim <minchan@kernel.org>
> > 
> > Acked-by: Hugh Dickins <hughd@google.com>
> > 
> > This is sooooooo much nicer than the code it replaces!  Really good.
> > Kudos also to Hannes for suggesting this approach originally, I think.
> > 
> > I hope this implementation satisfies a good proportion of the people
> > who have been wanting MADV_FREE: I'm not among them, and have long
> > lost touch with those discussions, so won't judge how usable it is.
> > 
> > I assume you'll refactor the series again before it goes to Linus,
> > so the previous messier implementations vanish?  I notice Andrew
> > has this "mm: simplify reclaim path for MADV_FREE" in mmotm as
> > mm-dont-split-thp-page-when-syscall-is-called-fix-6.patch:
> > I guess it all got much too messy to divide up in a hurry.
> > 
> > I've noticed no problems in testing (unlike the first time you moved
> > to working with pte_dirty); though of course I've not been using
> > MADV_FREE itself at all.
> > 
> > One aspect has worried me for a while, but I think I've reached the
> > conclusion that it doesn't matter at all.  The swap that's allocated
> > in add_to_swap() would normally get freed again (after try_to_unmap
> > found it was a MADV_FREE !pte_dirty !PageDirty case) at the bottom
> > of shrink_page_list(), in __remove_mapping(), yes?
> > 
> > The bit that worried me is that on rare occasions, something unknown
> > might take a speculative reference to the page, and __remove_mapping()
> > fail to freeze refs for that reason.  Much too rare to worry over not
> > freeing that page immediately, but it leaves us with a PageUptodate
> > PageSwapCache !PageDirty page, yet its contents are not the contents
> > of that location on swap.
> > 
> > But since this can only happen when you have *not* inserted the
> > corresponding swapent anywhere, I cannot think of anything that would
> > have a legitimate interest in its contents matching that location on swap.
> > So I don't think it's worth looking for somewhere to add a SetPageDirty
> > (or a delete_from_swap_cache) just to regularize that case.
> > 
> >> ---
> >> include/linux/rmap.h |  6 +----
> >> mm/huge_memory.c     |  5 ----
> >> mm/rmap.c            | 42 ++++++----------------------------
> >> mm/swap_state.c      |  5 ++--
> >> mm/vmscan.c          | 64 ++++++++++++++++------------------------------------
> >> 5 files changed, 30 insertions(+), 92 deletions(-)
> >> 

<snip>

You added comment bottom line so I'm not sure what PageDirty you meant.

> it is wrong here if you only check PageDirty() to decide if the page is freezable or not .
> The Anon page are shared by multiple process, _mapcount > 1 ,
> so you must check all pt_dirty bit during page_referenced() function,
> see this mail thread:
> http://ns1.ske-art.com/lists/kernel/msg1934021.html

If one of pte among process sharing the page was dirty, the dirtiness should
be propagated from pte to PG_dirty by try_to_unmap_one.
IOW, if the page doesn't have PG_dirty flag, it means all of process did
MADV_FREE.

Am I missing something from you question?
If so, could you show exact scenario I am missing?

Thanks for the interest.


> Thanks
> 
> 
> 
> 
> 
> 
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
