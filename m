Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 4CFF66B0038
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 02:49:57 -0400 (EDT)
Received: by paboj16 with SMTP id oj16so40026415pab.0
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 23:49:57 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id ss1si5451142pab.220.2015.04.14.23.49.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Apr 2015 23:49:56 -0700 (PDT)
Received: by pabsx10 with SMTP id sx10so39834748pab.3
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 23:49:56 -0700 (PDT)
Date: Wed, 15 Apr 2015 15:49:45 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 4/4] mm: make every pte dirty on do_swap_page
Message-ID: <20150415064945.GA22700@blaptop>
References: <1426036838-18154-1-git-send-email-minchan@kernel.org>
 <1426036838-18154-4-git-send-email-minchan@kernel.org>
 <alpine.LSU.2.11.1504111433230.3227@eggly.anvils>
 <20150412144823.GA414@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150412144823.GA414@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mm-commits@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Yalin Wang <Yalin.Wang@sonymobile.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Pavel Emelyanov <xemul@parallels.com>

On Sun, Apr 12, 2015 at 11:48:23PM +0900, Minchan Kim wrote:
> Hello Hugh,
> 
> On Sat, Apr 11, 2015 at 02:40:46PM -0700, Hugh Dickins wrote:
> > On Wed, 11 Mar 2015, Minchan Kim wrote:
> > 
> > > Bascially, MADV_FREE relys on the pte dirty to decide whether
> > > it allows VM to discard the page. However, if there is swap-in,
> > > pte pointed out the page has no pte_dirty. So, MADV_FREE checks
> > > PageDirty and PageSwapCache for those pages to not discard it
> > > because swapped-in page could live on swap cache or PageDirty
> > > when it is removed from swapcache.
> > > 
> > > The problem in here is that anonymous pages can have PageDirty if
> > > it is removed from swapcache so that VM cannot parse those pages
> > > as freeable even if we did madvise_free. Look at below example.
> > > 
> > > ptr = malloc();
> > > memset(ptr);
> > > ..
> > > heavy memory pressure -> swap-out all of pages
> > > ..
> > > out of memory pressure so there are lots of free pages
> > > ..
> > > var = *ptr; -> swap-in page/remove the page from swapcache. so pte_clean
> > >                but SetPageDirty
> > > 
> > > madvise_free(ptr);
> > > ..
> > > ..
> > > heavy memory pressure -> VM cannot discard the page by PageDirty.
> > > 
> > > PageDirty for anonymous page aims for avoiding duplicating
> > > swapping out. In other words, if a page have swapped-in but
> > > live swapcache(ie, !PageDirty), we could save swapout if the page
> > > is selected as victim by VM in future because swap device have
> > > kept previous swapped-out contents of the page.
> > > 
> > > So, rather than relying on the PG_dirty for working madvise_free,
> > > pte_dirty is more straightforward. Inherently, swapped-out page was
> > > pte_dirty so this patch restores the dirtiness when swap-in fault
> > > happens so madvise_free doesn't rely on the PageDirty any more.
> > > 
> > > Cc: Hugh Dickins <hughd@google.com>
> > > Cc: Cyrill Gorcunov <gorcunov@gmail.com>
> > > Cc: Pavel Emelyanov <xemul@parallels.com>
> > > Reported-by: Yalin Wang <yalin.wang@sonymobile.com>
> > > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > 
> > Sorry, but NAK to this patch,
> > mm-make-every-pte-dirty-on-do_swap_page.patch in akpm's mm tree
> > (I hope it hasn't reached linux-next yet).
> > 
> > You may well be right that pte_dirty<->PageDirty can be handled
> > differently, in a way more favourable to MADV_FREE.  And this patch
> > may be a step in the right direction, but I've barely given it thought.
> > 
> > As it stands, it segfaults more than any patch I've seen in years:
> > I just tried applying it to 4.0-rc7-mm1, and running kernel builds
> > in low memory with swap.  Even if I leave KSM out, and memcg out, and
> > swapoff out, and THP out, and tmpfs out, it still SIGSEGVs very soon.
> > 
> > I have a choice: spend a few hours tracking down the errors, and
> > post a fix patch on top of yours?  But even then I'd want to spend
> > a lot longer thinking through every dirty/Dirty in the source before
> > I'd feel comfortable to give an ack.
> > 
> > This is users' data, and we need to be very careful with it: errors
> > in MADV_FREE are one thing, for now that's easy to avoid; but in this
> > patch you're changing the rules for Anon PageDirty for everyone.
> > 
> > I think for now I'll have to leave it to you to do much more source
> > diligence and testing, before coming back with a corrected patch for
> > us then to review, slowly and carefully.
> 
> Sorry for my bad. I will keep your advise in mind.
> I will investigate the problem as soon as I get back to work
> after vacation.
> 
> Thanks for the the review.

When I look at the code, migration doesn't restore dirty bit of pte
in remove_migration_pte and relys on PG_dirty which was set by
try_to_unmap_one. I think it was a reason you saw segfault.
I will spend more time to investigate another code piece which might
ignore dirty bit restore.

Thanks.



> 
> -- 
> Kind regards,
> Minchan Kim

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
