Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5656A6B004F
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 18:03:04 -0400 (EDT)
Date: Thu, 3 Sep 2009 15:02:58 -0700 (PDT)
From: Vincent Li <macli@brc.ubc.ca>
Subject: Re: [RESEND][PATCH V1] mm/vsmcan: check shrink_active_list()
 sc->isolate_pages() return value.
In-Reply-To: <20090903140602.e0169ffc.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.0909031458160.5762@kernelhack.brc.ubc.ca>
References: <1251935365-7044-1-git-send-email-macli@brc.ubc.ca> <20090903140602.e0169ffc.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vincent Li <macli@brc.ubc.ca>, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, minchan.kim@gmail.com, fengguang.wu@intel.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 3 Sep 2009, Andrew Morton wrote:

> On Wed,  2 Sep 2009 16:49:25 -0700
> Vincent Li <macli@brc.ubc.ca> wrote:
> 
> > If we can't isolate pages from LRU list, we don't have to account page movement, either.
> > Already, in commit 5343daceec, KOSAKI did it about shrink_inactive_list.
> > 
> > This patch removes unnecessary overhead of page accounting
> > and locking in shrink_active_list as follow-up work of commit 5343daceec.
> > 
> > Signed-off-by: Vincent Li <macli@brc.ubc.ca>
> > Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> > Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
> > Acked-by: Rik van Riel <riel@redhat.com>
> > 
> > ---
> >  mm/vmscan.c |    9 +++++++--
> >  1 files changed, 7 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 460a6f7..2d1c846 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1319,9 +1319,12 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
> >  	if (scanning_global_lru(sc)) {
> >  		zone->pages_scanned += pgscanned;
> >  	}
> > -	reclaim_stat->recent_scanned[file] += nr_taken;
> > -
> >  	__count_zone_vm_events(PGREFILL, zone, pgscanned);
> > +
> > +	if (nr_taken == 0)
> > +		goto done;
> > +
> > +	reclaim_stat->recent_scanned[file] += nr_taken;
> >  	if (file)
> >  		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -nr_taken);
> >  	else
> > @@ -1383,6 +1386,8 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
> >  	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
> >  	__mod_zone_page_state(zone, LRU_ACTIVE + file * LRU_FILE, nr_rotated);
> >  	__mod_zone_page_state(zone, LRU_BASE + file * LRU_FILE, nr_deactivated);
> > +
> > +done:
> >  	spin_unlock_irq(&zone->lru_lock);
> >  }
> 
> How do we know this patch is a net gain?
> 
> IOW, with what frequency is `nr_taken' zero here?
> 

Actually, I have asked myself the same question, Anyway I can verify this, 
Kim, KOSAKI? 

Vincent Li
Biomedical Research Center
University of British Columbia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
