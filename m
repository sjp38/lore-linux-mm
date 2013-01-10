Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 218CE6B005D
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 21:23:12 -0500 (EST)
Date: Thu, 10 Jan 2013 11:23:06 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2] mm: forcely swapout when we are out of page cache
Message-ID: <20130110022306.GB14685@blaptop>
References: <1357712474-27595-1-git-send-email-minchan@kernel.org>
 <1357712474-27595-3-git-send-email-minchan@kernel.org>
 <20130109162602.53a60e77.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130109162602.53a60e77.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Sonny Rao <sonnyrao@google.com>, Bryan Freed <bfreed@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

On Wed, Jan 09, 2013 at 04:26:02PM -0800, Andrew Morton wrote:
> On Wed,  9 Jan 2013 15:21:14 +0900
> Minchan Kim <minchan@kernel.org> wrote:
> 
> > If laptop_mode is enable, VM try to avoid I/O for saving the power.
> > But if there isn't reclaimable memory without I/O, we should do I/O
> > for preventing unnecessary OOM kill although we sacrifices power.
> > 
> > One of example is that we are out of page cache. Remained one is
> > only anonymous pages, for swapping out, we needs may_writepage = 1.
> > 
> > Reported-by: Luigi Semenzato <semenzato@google.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  mm/vmscan.c |    6 ++++++
> >  1 file changed, 6 insertions(+)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 439cc47..624c816 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1728,6 +1728,12 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
> >  		free = zone_page_state(zone, NR_FREE_PAGES);
> >  		if (unlikely(file + free <= high_wmark_pages(zone))) {
> >  			scan_balance = SCAN_ANON;
> > +			/*
> > +			 * From now on, we have to swap out
> > +			 * for peventing OOM kill although
> > +			 * we sacrifice power consumption.
> > +			 */
> > +			sc->may_writepage = 1;
> >  			goto out;
> >  		}
> >  	}
> 
> This is pretty ugly.  get_scan_count() is, as its name implies, an
> idempotent function which inspects the state of things and returns a
> result.  As such, it has no business going in and altering the state of
> the scan_control.
> 
> We have code in both direct reclaim and in kswapd to set may_writepage
> if vmscan is getting into trouble.  I don't see why adding another
> instance is necessary if the existing instances are working correctly.
> 
> 
> 
> (Is it correct that __zone_reclaim() ignores laptop_mode?)
> 
> 
> I have a feeling that laptop mode has bitrotted and these patches are
> kinda hacking around as-yet-not-understood failures...

Absolutely, this patch is last guard for unexpectable behavior.
As I mentioned in cover-letter, Luigi's problem could be solved either [1/2]
or [2/2] but I wanted to add this as last resort in case of unexpected
emergency. But you're right. It's not good to hide the problem like this path
so let's drop [2/2].

Also, I absolutely agree it has bitrotted so for correcting it, we need a
volunteer who have to inverstigate power saveing experiment with long time.
So [1/2] would be band-aid until that.

> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
