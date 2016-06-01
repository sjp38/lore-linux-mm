Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id BF73E6B0005
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 05:19:25 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id o70so6524136lfg.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 02:19:25 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id wa2si55858427wjc.62.2016.06.01.02.19.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Jun 2016 02:19:24 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 794D89904E
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 09:19:23 +0000 (UTC)
Date: Wed, 1 Jun 2016 10:19:21 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: BUG: scheduling while atomic: cron/668/0x10c9a0c0 (was: Re: mm,
 page_alloc: avoid looking up the first zone in a zonelist twice)
Message-ID: <20160601091921.GT2527@techsingularity.net>
References: <CAMuHMdV00vJJxoA7XABw+mFF+2QUd1MuQbPKKgkmGnK_NySZpg@mail.gmail.com>
 <20160530155644.GP2527@techsingularity.net>
 <574E05B8.3060009@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <574E05B8.3060009@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>

On Tue, May 31, 2016 at 11:44:24PM +0200, Vlastimil Babka wrote:
> On 05/30/2016 05:56 PM, Mel Gorman wrote:
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index dba8cfd0b2d6..f2c1e47adc11 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3232,6 +3232,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  		 * allocations are system rather than user orientated
> >  		 */
> >  		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
> > +		ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
> > +					ac->high_zoneidx, ac->nodemask);
> > +		ac->classzone_idx = zonelist_zone_idx(ac->preferred_zoneref);
> >  		page = get_page_from_freelist(gfp_mask, order,
> >  						ALLOC_NO_WATERMARKS, ac);
> >  		if (page)
> > 
> 
> Even if that didn't help for this report, I think it's needed too
> (except the classzone_idx which doesn't exist anymore?).
> 
> And I think the following as well. (the changed comment could be also
> just deleted).
> 

Why?

The comment is fine but I do not see why the recalculation would occur.

In the original code, the preferred_zoneref for statistics is calculated
based on either the supplied nodemask or cpuset_current_mems_allowed during
the initial attempt. It then relies on the cpuset checks in the slowpath
to encorce mems_allowed but the preferred zone doesn't change.

With your proposed change, it's possible that the
preferred_zoneref recalculation points to a zoneref disallowed by
cpuset_current_mems_sllowed. While it'll be skipped during allocation,
the statistics will still be against a zone that is potentially outside
what is allowed.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
