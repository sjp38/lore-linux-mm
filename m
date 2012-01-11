Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id AD6576B005C
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 03:48:05 -0500 (EST)
Date: Wed, 11 Jan 2012 09:48:02 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: Fix NULL ptr dereference in __count_immobile_pages
Message-ID: <20120111084802.GA16466@tiehlicka.suse.cz>
References: <1326213022-11761-1-git-send-email-mhocko@suse.cz>
 <alpine.DEB.2.00.1201101326080.10821@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1201101326080.10821@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>

On Tue 10-01-12 13:31:08, David Rientjes wrote:
> On Tue, 10 Jan 2012, Michal Hocko wrote:
[...]
> >  mm/page_alloc.c |   11 +++++++++++
> >  1 files changed, 11 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 2b8ba3a..485be89 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -5608,6 +5608,17 @@ __count_immobile_pages(struct zone *zone, struct page *page, int count)
> >  bool is_pageblock_removable_nolock(struct page *page)
> >  {
> >  	struct zone *zone = page_zone(page);
> > +	unsigned long pfn = page_to_pfn(page);
> > +
> > +	/*
> > +	 * We have to be careful here because we are iterating over memory
> > +	 * sections which are not zone aware so we might end up outside of
> > +	 * the zone but still within the section.
> > +	 */
> > +	if (!zone || zone->zone_start_pfn > pfn ||
> > +			zone->zone_start_pfn + zone->spanned_pages <= pfn)
> > +		return false;
> > +
> >  	return __count_immobile_pages(zone, page, 0);
> >  }
> >  
> 
> This seems partially bogus, why would
> 
> 	page_zone(page)->zone_start_pfn > page_to_pfn(page) ||
> 	page_zone(page)->zone_start_pfn + page_zone(page)->spanned_pages <= page_to_pfn(page)
> 
> ever be true?  That would certainly mean that the struct zone is corrupted 
> and seems to be unnecessary to fix the problem you're addressing.

Not really. Consider the case when the node 0 is present. Uninitialized
page would lead to node=0, zone=0 and then we have to check for the zone
boundaries.

> I think this should be handled in is_mem_section_removable() on the pfn 
> rather than using the struct page in is_pageblock_removable_nolock() and 
> converting back and forth.  We should make sure that any page passed to 
> is_pageblock_removable_nolock() is valid.

Yes, I do not like pfn->page->pfn dance as well and in fact I do not
have a strong opinion which one is better. I just put it at the place
where we care about zone to be more obvious. If others think that I
should move the check one level higher I'll do that. I just think this
is more obvious.

Thanks for your comments.
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
