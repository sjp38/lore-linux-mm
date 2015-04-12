Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id F2B436B0032
	for <linux-mm@kvack.org>; Sun, 12 Apr 2015 10:48:34 -0400 (EDT)
Received: by paboj16 with SMTP id oj16so75019066pab.0
        for <linux-mm@kvack.org>; Sun, 12 Apr 2015 07:48:34 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id pj8si11548158pdb.46.2015.04.12.07.48.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Apr 2015 07:48:33 -0700 (PDT)
Received: by pacyx8 with SMTP id yx8so74963191pac.1
        for <linux-mm@kvack.org>; Sun, 12 Apr 2015 07:48:33 -0700 (PDT)
Date: Sun, 12 Apr 2015 23:48:23 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 4/4] mm: make every pte dirty on do_swap_page
Message-ID: <20150412144823.GA414@blaptop>
References: <1426036838-18154-1-git-send-email-minchan@kernel.org>
 <1426036838-18154-4-git-send-email-minchan@kernel.org>
 <alpine.LSU.2.11.1504111433230.3227@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1504111433230.3227@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mm-commits@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Yalin Wang <Yalin.Wang@sonymobile.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Pavel Emelyanov <xemul@parallels.com>

Hello Hugh,

On Sat, Apr 11, 2015 at 02:40:46PM -0700, Hugh Dickins wrote:
> On Wed, 11 Mar 2015, Minchan Kim wrote:
> 
> > Bascially, MADV_FREE relys on the pte dirty to decide whether
> > it allows VM to discard the page. However, if there is swap-in,
> > pte pointed out the page has no pte_dirty. So, MADV_FREE checks
> > PageDirty and PageSwapCache for those pages to not discard it
> > because swapped-in page could live on swap cache or PageDirty
> > when it is removed from swapcache.
> > 
> > The problem in here is that anonymous pages can have PageDirty if
> > it is removed from swapcache so that VM cannot parse those pages
> > as freeable even if we did madvise_free. Look at below example.
> > 
> > ptr = malloc();
> > memset(ptr);
> > ..
> > heavy memory pressure -> swap-out all of pages
> > ..
> > out of memory pressure so there are lots of free pages
> > ..
> > var = *ptr; -> swap-in page/remove the page from swapcache. so pte_clean
> >                but SetPageDirty
> > 
> > madvise_free(ptr);
> > ..
> > ..
> > heavy memory pressure -> VM cannot discard the page by PageDirty.
> > 
> > PageDirty for anonymous page aims for avoiding duplicating
> > swapping out. In other words, if a page have swapped-in but
> > live swapcache(ie, !PageDirty), we could save swapout if the page
> > is selected as victim by VM in future because swap device have
> > kept previous swapped-out contents of the page.
> > 
> > So, rather than relying on the PG_dirty for working madvise_free,
> > pte_dirty is more straightforward. Inherently, swapped-out page was
> > pte_dirty so this patch restores the dirtiness when swap-in fault
> > happens so madvise_free doesn't rely on the PageDirty any more.
> > 
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Cyrill Gorcunov <gorcunov@gmail.com>
> > Cc: Pavel Emelyanov <xemul@parallels.com>
> > Reported-by: Yalin Wang <yalin.wang@sonymobile.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> Sorry, but NAK to this patch,
> mm-make-every-pte-dirty-on-do_swap_page.patch in akpm's mm tree
> (I hope it hasn't reached linux-next yet).
> 
> You may well be right that pte_dirty<->PageDirty can be handled
> differently, in a way more favourable to MADV_FREE.  And this patch
> may be a step in the right direction, but I've barely given it thought.
> 
> As it stands, it segfaults more than any patch I've seen in years:
> I just tried applying it to 4.0-rc7-mm1, and running kernel builds
> in low memory with swap.  Even if I leave KSM out, and memcg out, and
> swapoff out, and THP out, and tmpfs out, it still SIGSEGVs very soon.
> 
> I have a choice: spend a few hours tracking down the errors, and
> post a fix patch on top of yours?  But even then I'd want to spend
> a lot longer thinking through every dirty/Dirty in the source before
> I'd feel comfortable to give an ack.
> 
> This is users' data, and we need to be very careful with it: errors
> in MADV_FREE are one thing, for now that's easy to avoid; but in this
> patch you're changing the rules for Anon PageDirty for everyone.
> 
> I think for now I'll have to leave it to you to do much more source
> diligence and testing, before coming back with a corrected patch for
> us then to review, slowly and carefully.

Sorry for my bad. I will keep your advise in mind.
I will investigate the problem as soon as I get back to work
after vacation.

Thanks for the the review.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
