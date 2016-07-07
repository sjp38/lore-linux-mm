Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E76686B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 06:58:12 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id i4so14150686wmg.2
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 03:58:12 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id ck7si2301679wjc.148.2016.07.07.03.58.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 03:58:11 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 69E6C1C3030
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 11:58:11 +0100 (IST)
Date: Thu, 7 Jul 2016 11:58:09 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 20/31] mm, vmscan: only wakeup kswapd once per node for
 the requested classzone
Message-ID: <20160707105809.GU11498@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-21-git-send-email-mgorman@techsingularity.net>
 <20160707012423.GC27987@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160707012423.GC27987@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 07, 2016 at 10:24:23AM +0900, Joonsoo Kim wrote:
> On Fri, Jul 01, 2016 at 09:01:28PM +0100, Mel Gorman wrote:
> > kswapd is woken when zones are below the low watermark but the wakeup
> > decision is not taking the classzone into account.  Now that reclaim is
> > node-based, it is only required to wake kswapd once per node and only if
> > all zones are unbalanced for the requested classzone.
> > 
> > Note that one node might be checked multiple times if the zonelist is
> > ordered by node because there is no cheap way of tracking what nodes have
> > already been visited.  For zone-ordering, each node should be checked only
> > once.
> > 
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> > ---
> >  mm/page_alloc.c |  8 ++++++--
> >  mm/vmscan.c     | 13 +++++++++++--
> >  2 files changed, 17 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 441f482bf9a2..2fe2fbb4f2ad 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3410,10 +3410,14 @@ static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
> >  {
> >  	struct zoneref *z;
> >  	struct zone *zone;
> > +	pg_data_t *last_pgdat = NULL;
> >  
> >  	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist,
> > -						ac->high_zoneidx, ac->nodemask)
> > -		wakeup_kswapd(zone, order, ac_classzone_idx(ac));
> > +					ac->high_zoneidx, ac->nodemask) {
> > +		if (last_pgdat != zone->zone_pgdat)
> > +			wakeup_kswapd(zone, order, ac_classzone_idx(ac));
> > +		last_pgdat = zone->zone_pgdat;
> > +	}
> >  }
> 
> In wakeup_kswapd(), there is a check if it is a populated zone or not.

It's redundant.

> If first zone in node is not a populated zone, wakeup_kswapd() would be
> skipped. Though, I'm not sure if zonelist can include a un-populated
> zone.

Zonelists do not contain unpopulated zones.

> Perhaps, moving populated zone check in wakeup_kswapd() to here
> would be a safe code.
> 

If anything was going to happen to it, it should be deleted. It's a
minor cleanup.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
