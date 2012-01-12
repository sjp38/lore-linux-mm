Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 09F636B004F
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 03:21:10 -0500 (EST)
Date: Thu, 12 Jan 2012 09:21:05 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: Fix NULL ptr dereference in __count_immobile_pages
Message-ID: <20120112082105.GA1042@tiehlicka.suse.cz>
References: <1326213022-11761-1-git-send-email-mhocko@suse.cz>
 <20120111143439.538bf274.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120111143439.538bf274.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>

On Wed 11-01-12 14:34:39, Andrew Morton wrote:
> On Tue, 10 Jan 2012 17:30:22 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > This patch fixes the following NULL ptr dereference caused by
> > cat /sys/devices/system/memory/memory0/removable:
> 
> Which is world-readable, I assume?

Right. But considering that we haven't seen any report like that it
seems that the HW is rather rare

> 
> > ...
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
> 
> So I propose that we backport it into -stable?

Agreed.

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
