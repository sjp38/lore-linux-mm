Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 8D2FF6B004D
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 04:40:08 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: Text/Plain; charset=iso-8859-1
Received: from euspt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M21006GPUQCDX20@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 06 Apr 2012 09:39:48 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M210039QUQRAJ@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 06 Apr 2012 09:40:04 +0100 (BST)
Date: Fri, 06 Apr 2012 10:38:00 +0200
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH 2/2] mm: compaction: allow isolation of lower order buddy
 pages
In-reply-to: <alpine.DEB.2.00.1204051444080.17852@chino.kir.corp.google.com>
Message-id: <201204061038.00068.b.zolnierkie@samsung.com>
References: <1333643534-1591-1-git-send-email-b.zolnierkie@samsung.com>
 <1333643534-1591-3-git-send-email-b.zolnierkie@samsung.com>
 <alpine.DEB.2.00.1204051444080.17852@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, Kyungmin Park <kyungmin.park@samsung.com>

On Thursday 05 April 2012 23:46:17 David Rientjes wrote:
> On Thu, 5 Apr 2012, Bartlomiej Zolnierkiewicz wrote:
> 
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index bc77135..642c17a 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -115,8 +115,8 @@ static bool suitable_migration_target(struct page *page)
> >  	if (migratetype == MIGRATE_ISOLATE || migratetype == MIGRATE_RESERVE)
> >  		return false;
> >  
> > -	/* If the page is a large free page, then allow migration */
> > -	if (PageBuddy(page) && page_order(page) >= pageblock_order)
> > +	/* If the page is a free page, then allow migration */
> > +	if (PageBuddy(page))
> >  		return true;
> >  
> >  	/* If the block is MIGRATE_MOVABLE, allow migration */
> 
> So when we try to allocate a 2M hugepage through the buddy allocator where 
> the pageblock is also 2M, wouldn't this result in a lot of unnecessary 
> migration of memory that may not end up defragmented enough for the 
> allocation to succeed?  Sounds like a regression for hugepage allocation.

I haven't tested it with hugepage allocation yet (no hugepage support
on ARM) but the code isolating pages for migration remains unchanged
so after migration memory we are trying to allocate pages from should
end up at least as defragmented as before the patch.  Some migrations
may turn out to be unnecessary but it doesn't seem as it introduces
additional problems with hugepage allocation.

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
