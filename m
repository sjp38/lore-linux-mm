Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 8C6DD6B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 08:04:07 -0400 (EDT)
Received: from euspt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M2Z00F5JG4HII@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Tue, 24 Apr 2012 13:02:41 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M2Z00J5AG6T0I@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 24 Apr 2012 13:04:05 +0100 (BST)
Date: Tue, 24 Apr 2012 14:03:29 +0200
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH][RFC] mm: compaction: handle incorrect Unmovable type
 pageblocks
In-reply-to: <20120423145631.GD3255@suse.de>
Message-id: <201204241403.29860.b.zolnierkie@samsung.com>
MIME-version: 1.0
Content-type: Text/Plain; charset=iso-8859-15
Content-transfer-encoding: 7BIT
References: <201204231202.55739.b.zolnierkie@samsung.com>
 <20120423145631.GD3255@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>


Hi,

On Monday 23 April 2012 16:56:31 Mel Gorman wrote:
> On Mon, Apr 23, 2012 at 12:02:55PM +0200, Bartlomiej Zolnierkiewicz wrote:

[...]

> >  include/linux/mmzone.h |   10 ++
> >  mm/compaction.c        |    3 
> >  mm/internal.h          |    1 
> >  mm/page_alloc.c        |  128 +++++++++++++++++++++++++++++
> >  mm/sparse.c            |  216 +++++++++++++++++++++++++++++++++++++++++++++++--
> >  5 files changed, 353 insertions(+), 5 deletions(-)
> > 
> > Index: b/include/linux/mmzone.h
> > ===================================================================
> > --- a/include/linux/mmzone.h	2012-04-20 16:35:16.894872193 +0200
> > +++ b/include/linux/mmzone.h	2012-04-23 09:55:01.845549009 +0200
> > @@ -379,6 +379,10 @@
> >  	 * In SPARSEMEM, this map is stored in struct mem_section
> >  	 */
> >  	unsigned long		*pageblock_flags;
> > +
> > +#ifdef CONFIG_COMPACTION
> > +	unsigned long		*unmovable_map;
> > +#endif
> >  #endif /* CONFIG_SPARSEMEM */
> >  
> >  #ifdef CONFIG_COMPACTION
> > @@ -1033,6 +1037,12 @@
> >  
> >  	/* See declaration of similar field in struct zone */
> >  	unsigned long *pageblock_flags;
> > +
> > +#ifdef CONFIG_COMPACTION
> > +	unsigned long *unmovable_map;
> > +	unsigned long pad0; /* Why this is needed? */
> > +#endif
> > +
> 
> You tell us, you added the padding :)

I wish I could.. :)

> If I had to guess you are trying to avoid sharing a cache line between
> unmovable_map and adjacent fields but I doubt it is necessary.

Unfortunately the pad is needed or the kernel just freezes somewhere
early during memory zone initialization.  I don't remember details but
it was somewhere on the access to page->flags of the first page..

> >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
> >  	/*
> >  	 * If !SPARSEMEM, pgdat doesn't have page_cgroup pointer. We use
> > Index: b/mm/compaction.c
> > ===================================================================
> > --- a/mm/compaction.c	2012-04-20 16:35:16.910872188 +0200
> > +++ b/mm/compaction.c	2012-04-23 09:33:54.525527592 +0200
> > @@ -376,6 +376,9 @@
> >  	if (migrate_async_suitable(migratetype))
> >  		return true;
> >  
> > +	if (migratetype == MIGRATE_UNMOVABLE && set_unmovable_movable(page))
> > +		return true;
> > +
> 
> Ok, I have a two suggested changes to this
> 
> 1. compaction currently has sync and async compaction. I suggest you
>    make it a three states called async_partial, async_full and sync.
>    async_partial would be the current behaviour. async_full and sync
>    would both scan within MIGRATE_UNMOVABLE blocks to see if they
>    needed to be changed. This will add a new slower path but the
>    common path will be as it is today.
> 
> 2. You maintain a bitmap of unmovable pages. Get rid of it. Instead have
>    set_unmovable_movable scan the pageblock and build a free count based
>    on finding PageBuddy pages, page_count(page) == 0 or PageLRU pages.
>    If all pages within the block are in one of those three sets, call
>    set_pageblock_migratetype(MIGRATE_MOVABLE) and call move_freepages_block()
>    I also suggest finding a better name than set_unmovable_movable
>    although  I do not have a better suggestion myself right now.

Ok, I'll post the updated patch shortly.

Thank you for the review.

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung Poland R&D Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
