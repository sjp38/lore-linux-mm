Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id B42B36B0038
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 02:54:09 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so213446912pad.1
        for <linux-mm@kvack.org>; Mon, 26 Oct 2015 23:54:09 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id oo9si59440680pac.212.2015.10.26.23.54.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Oct 2015 23:54:09 -0700 (PDT)
Received: by pabla5 with SMTP id la5so20185205pab.0
        for <linux-mm@kvack.org>; Mon, 26 Oct 2015 23:54:08 -0700 (PDT)
Date: Tue, 27 Oct 2015 15:54:27 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 4/5] mm: simplify reclaim path for MADV_FREE
Message-ID: <20151027065427.GB26803@bbox>
References: <1445236307-895-1-git-send-email-minchan@kernel.org>
 <1445236307-895-5-git-send-email-minchan@kernel.org>
 <alpine.LSU.2.11.1510261828350.10825@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1510261828350.10825@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>

On Mon, Oct 26, 2015 at 07:09:15PM -0700, Hugh Dickins wrote:
> On Mon, 19 Oct 2015, Minchan Kim wrote:
> 
> > I made reclaim path mess to check and free MADV_FREEed page.
> > This patch simplify it with tweaking add_to_swap.
> > 
> > So far, we mark page as PG_dirty when we add the page into
> > swap cache(ie, add_to_swap) to page out to swap device but
> > this patch moves PG_dirty marking under try_to_unmap_one
> > when we decide to change pte from anon to swapent so if
> > any process's pte has swapent for the page, the page must
> > be swapped out. IOW, there should be no funcional behavior
> > change. It makes relcaim path really simple for MADV_FREE
> > because we just need to check PG_dirty of page to decide
> > discarding the page or not.
> > 
> > Other thing this patch does is to pass TTU_BATCH_FLUSH to
> > try_to_unmap when we handle freeable page because I don't
> > see any reason to prevent it.
> > 
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Mel Gorman <mgorman@suse.de>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> Acked-by: Hugh Dickins <hughd@google.com>
> 
> This is sooooooo much nicer than the code it replaces!  Really good.

Thanks!

> Kudos also to Hannes for suggesting this approach originally, I think.

I should buy beer or soju if Hannes likes.

> 
> I hope this implementation satisfies a good proportion of the people
> who have been wanting MADV_FREE: I'm not among them, and have long
> lost touch with those discussions, so won't judge how usable it is.
> 
> I assume you'll refactor the series again before it goes to Linus,
> so the previous messier implementations vanish?  I notice Andrew

Actutally, I didn't think about that but once you mentioned it,
I realized that would be better. Thanks for the suggestion.

> has this "mm: simplify reclaim path for MADV_FREE" in mmotm as
> mm-dont-split-thp-page-when-syscall-is-called-fix-6.patch:
> I guess it all got much too messy to divide up in a hurry.

Yeb, I will rebase all series from the beginning based on recent mmtom
so I will vanish the mess in git-blame.

When I rebases it in mmotm, I will do it before reaching THP refcount
new design if Andrew and Kirill don't mind it because it makes to fail
my test as I reported. I don't know it's long time unknown bug or
something THP-ref new introduces. Anyway, I want to test smoothly.

> 
> I've noticed no problems in testing (unlike the first time you moved
> to working with pte_dirty); though of course I've not been using

Thanks for testing!

> MADV_FREE itself at all.
> 
> One aspect has worried me for a while, but I think I've reached the
> conclusion that it doesn't matter at all.  The swap that's allocated
> in add_to_swap() would normally get freed again (after try_to_unmap
> found it was a MADV_FREE !pte_dirty !PageDirty case) at the bottom
> of shrink_page_list(), in __remove_mapping(), yes?

Right.

> 
> The bit that worried me is that on rare occasions, something unknown
> might take a speculative reference to the page, and __remove_mapping()
> fail to freeze refs for that reason.  Much too rare to worry over not
> freeing that page immediately, but it leaves us with a PageUptodate
> PageSwapCache !PageDirty page, yet its contents are not the contents
> of that location on swap.
> 
> But since this can only happen when you have *not* inserted the
> corresponding swapent anywhere, I cannot think of anything that would
> have a legitimate interest in its contents matching that location on swap.
> So I don't think it's worth looking for somewhere to add a SetPageDirty
> (or a delete_from_swap_cache) just to regularize that case.


Exactly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
