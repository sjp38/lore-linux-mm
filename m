Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 553716B0038
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 11:38:22 -0400 (EDT)
Received: by wijn1 with SMTP id n1so28461653wij.0
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 08:38:22 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id d4si1856565wjn.153.2015.08.26.08.38.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 26 Aug 2015 08:38:20 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 0CF1C9880D
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 15:38:20 +0000 (UTC)
Date: Wed, 26 Aug 2015 16:38:18 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 11/12] mm, page_alloc: Reserve pageblocks for high-order
 atomic allocations on demand
Message-ID: <20150826153818.GQ12432@techsingularity.net>
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
 <20150824122957.GI12432@techsingularity.net>
 <20150826145352.GJ25196@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150826145352.GJ25196@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Aug 26, 2015 at 04:53:52PM +0200, Michal Hocko wrote:
> > 
> > Overall, this is a small reduction but the reserves are small relative to the
> > number of allocation requests. In early versions of the patch, the failure
> > rate reduced by a much larger amount but that required much larger reserves
> > and perversely made atomic allocations seem more reliable than regular allocations.
> 
> Have you considered a counter for vmstat/zoneinfo so that we have an overview
> about the memory consumed for this reserve?
> 

It should already be available in /proc/pagetypeinfo

> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> [...]
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index d5ce050ebe4f..2415f882b89c 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> [...]
> > @@ -1645,10 +1725,16 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
> >   * Call me with the zone->lock already held.
> >   */
> >  static struct page *__rmqueue(struct zone *zone, unsigned int order,
> > -						int migratetype)
> > +				int migratetype, gfp_t gfp_flags)
> >  {
> >  	struct page *page;
> >  
> > +	if (unlikely(order && (gfp_flags & __GFP_ATOMIC))) {
> > +		page = __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC);
> > +		if (page)
> > +			goto out;
> 
> I guess you want to change migratetype to MIGRATE_HIGHATOMIC in the
> successful case so the tracepoint reports this properly.
> 

Yes, thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
