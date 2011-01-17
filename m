Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 98BF28D0039
	for <linux-mm@kvack.org>; Mon, 17 Jan 2011 09:47:58 -0500 (EST)
Received: by pxi12 with SMTP id 12so1046462pxi.14
        for <linux-mm@kvack.org>; Mon, 17 Jan 2011 06:47:57 -0800 (PST)
Date: Mon, 17 Jan 2011 23:47:46 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: hunting an IO hang
Message-ID: <20110117144746.GC1411@barrios-desktop>
References: <4D339C87.30100@fusionio.com>
 <1295228148-sup-7379@think>
 <AANLkTimp6ef0W_=ijW=CfH6iC1mQzW3gLr1LZivJ5Bmd@mail.gmail.com>
 <AANLkTimr3hN8SDmbwv98hkcVfWoh9tioYg4M+0yanzpb@mail.gmail.com>
 <1295229722-sup-6494@think>
 <20110116183000.cc632557.akpm@linux-foundation.org>
 <1295231547-sup-8036@think>
 <20110117051135.GI9506@random.random>
 <1295273312-sup-6780@think>
 <20110117142614.GP9506@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110117142614.GP9506@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Chris Mason <chris.mason@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jens Axboe <jaxboe@fusionio.com>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 17, 2011 at 03:26:15PM +0100, Andrea Arcangeli wrote:
> On Mon, Jan 17, 2011 at 09:10:15AM -0500, Chris Mason wrote:
> > Excerpts from Andrea Arcangeli's message of 2011-01-17 00:11:35 -0500:
> > 
> > [ crashes under load ]
> > 
> > > 
> > > NOTE: with the last changes compaction is used for all order > 0 and
> > > even from kswapd, so you will now be able to trigger bugs in
> > > compaction or migration even with THP off. However I'm surprised that
> > > you have issues with compaction...
> > 
> > I know I mentioned this in another email, but it is kind of buried in
> > other context.  I reproduced my crash with CONFIG_COMPACTION and
> > CONFIG_MIGRATION off.
> 
> Ok, then it was an accident the page->lru got corrupted during
> migration and it has nothing to do with migration/compaction/thp. This
> makes sense because we should have noticed long ago if something
> wasn't stable there.
> 
> I reworked the fix for the two memleaks I found while reviewing
> migration code for this bug (unrelated) introduced by the commit
> cf608ac19c95804dc2df43b1f4f9e068aa9034ab. It was enough to move the
> goto to fix this without having to add a new function (it's
> functionally identical to the one I sent before). It also wouldn't
> leak memory if it was compaction invoking migrate_pages (only other
> callers checking the retval of migrate_pages instead of list_empty,
> could leak memory). As said before, this couldn't explain your
> problem, and this is only a code review fix, I never triggered this.
> 
> This is still only for review for Minchan, not meant for inclusion
> yet.
> 
> ===
> Subject: when migrate_pages returns 0, all pages must have been released
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> In some cases migrate_pages could return zero while still leaving a
> few pages in the pagelist (and some caller wouldn't notice it has to
> call putback_lru_pages after commit
> cf608ac19c95804dc2df43b1f4f9e068aa9034ab).
> 
> Add one missing putback_lru_pages not added by commit
> cf608ac19c95804dc2df43b1f4f9e068aa9034ab.

It would be better to have another patch.

> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Thanks, Andrea.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
