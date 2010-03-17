Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 48E5A60023A
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 07:41:07 -0400 (EDT)
Date: Wed, 17 Mar 2010 11:40:45 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 07/11] Memory compaction core
Message-ID: <20100317114045.GE12388@csn.ul.ie>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie> <1268412087-13536-8-git-send-email-mel@csn.ul.ie> <20100317170116.870A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100317170116.870A.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 17, 2010 at 07:31:53PM +0900, KOSAKI Motohiro wrote:
> nit
> 
> > +static int compact_zone(struct zone *zone, struct compact_control *cc)
> > +{
> > +	int ret = COMPACT_INCOMPLETE;
> > +
> > +	/* Setup to move all movable pages to the end of the zone */
> > +	cc->migrate_pfn = zone->zone_start_pfn;
> > +	cc->free_pfn = cc->migrate_pfn + zone->spanned_pages;
> > +	cc->free_pfn &= ~(pageblock_nr_pages-1);
> > +
> > +	for (; ret == COMPACT_INCOMPLETE; ret = compact_finished(zone, cc)) {
> > +		unsigned long nr_migrate, nr_remaining;
> > +		if (!isolate_migratepages(zone, cc))
> > +			continue;
> > +
> > +		nr_migrate = cc->nr_migratepages;
> > +		migrate_pages(&cc->migratepages, compaction_alloc,
> > +						(unsigned long)cc, 0);
> > +		update_nr_listpages(cc);
> > +		nr_remaining = cc->nr_migratepages;
> > +
> > +		count_vm_event(COMPACTBLOCKS);
> 
> V1 did compaction per pageblock. but current patch doesn't.
> so, Is COMPACTBLOCKS still good name?
> 

It's not such a minor nit. I wondered about that myself but it's still a
block - just not a pageblock. Would COMPACTCLUSTER be a better name as it's
related to COMPACT_CLUSTER_MAX?

> 
> > +		count_vm_events(COMPACTPAGES, nr_migrate - nr_remaining);
> > +		if (nr_remaining)
> > +			count_vm_events(COMPACTPAGEFAILED, nr_remaining);
> > +
> > +		/* Release LRU pages not migrated */
> > +		if (!list_empty(&cc->migratepages)) {
> > +			putback_lru_pages(&cc->migratepages);
> > +			cc->nr_migratepages = 0;
> > +		}
> > +
> > +		mod_zone_page_state(zone, NR_ISOLATED_ANON, -cc->nr_anon);
> > +		mod_zone_page_state(zone, NR_ISOLATED_FILE, -cc->nr_file);
> 
> I think you don't need decrease this vmstatistics here. migrate_pages() and
> putback_lru_pages() alredy does.
> 

Hmm, I do need to decrease the vmstats here but not by this much. The
pages migrated need to be accounted for but not the ones that failed. I
missed this because migration was always succeeding. Thanks. I'll get it
fixed for V5

> other parts, looks good.
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
