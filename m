Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id A3CF26B005D
	for <linux-mm@kvack.org>; Sun,  9 Sep 2012 21:05:20 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so1845806pbb.14
        for <linux-mm@kvack.org>; Sun, 09 Sep 2012 18:05:19 -0700 (PDT)
Date: Mon, 10 Sep 2012 09:05:14 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [patch 1/2]compaction: check migrated page number
Message-ID: <20120910010514.GB3715@kernel.org>
References: <20120906104404.GA12718@kernel.org>
 <20120906121725.GQ11266@suse.de>
 <20120906125526.GA1025@kernel.org>
 <20120906132551.GS11266@suse.de>
 <20120907041212.GA31391@kernel.org>
 <20120907155243.GA21894@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120907155243.GA21894@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, akpm@linux-foundation.org

On Fri, Sep 07, 2012 at 05:52:43PM +0200, Andrea Arcangeli wrote:
> On Fri, Sep 07, 2012 at 12:12:12PM +0800, Shaohua Li wrote:
> > Subject: compaction: check migrated page number
> > 
> > isolate_migratepages_range() might isolate none pages, for example, when
> > zone->lru_lock is contended and compaction is async. In this case, we should
> > abort compaction, otherwise, compact_zone will run a useless loop and make
> > zone->lru_lock is even contended.
> > 
> > Signed-off-by: Shaohua Li <shli@fusionio.com>
> > ---
> >  mm/compaction.c |    5 +++--
> >  1 file changed, 3 insertions(+), 2 deletions(-)
> > 
> > Index: linux/mm/compaction.c
> > ===================================================================
> > --- linux.orig/mm/compaction.c	2012-09-06 18:37:52.636413761 +0800
> > +++ linux/mm/compaction.c	2012-09-07 10:51:16.734081959 +0800
> > @@ -618,7 +618,7 @@ typedef enum {
> >  static isolate_migrate_t isolate_migratepages(struct zone *zone,
> >  					struct compact_control *cc)
> >  {
> > -	unsigned long low_pfn, end_pfn;
> > +	unsigned long low_pfn, end_pfn, old_low_pfn;
> >  
> >  	/* Do not scan outside zone boundaries */
> >  	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
> > @@ -633,8 +633,9 @@ static isolate_migrate_t isolate_migrate
> >  	}
> >  
> >  	/* Perform the isolation */
> > +	old_low_pfn = low_pfn;
> >  	low_pfn = isolate_migratepages_range(zone, cc, low_pfn, end_pfn);
> > -	if (!low_pfn)
> > +	if (!low_pfn || old_low_pfn == low_pfn)
> >  		return ISOLATE_ABORT;
> >  
> >  	cc->migrate_pfn = low_pfn;
> 
> Looks good to me.
> 
> This other below approach should also work:

Yep, the logic is the same. But your code looks prettier, thanks! I'll send a
formal path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
