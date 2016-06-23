Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id DD65C6B025E
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 07:31:56 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id a4so51980114lfa.1
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 04:31:56 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id n188si5913984wmf.30.2016.06.23.04.31.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jun 2016 04:31:55 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 36D4F1C1E39
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 12:31:55 +0100 (IST)
Date: Thu, 23 Jun 2016 12:31:53 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 06/27] mm, vmscan: Make kswapd reclaim in terms of nodes
Message-ID: <20160623113153.GU1868@techsingularity.net>
References: <071801d1cc5c$245087d0$6cf19770$@alibaba-inc.com>
 <072501d1cc61$f51a2380$df4e6a80$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <072501d1cc61$f51a2380$df4e6a80$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed, Jun 22, 2016 at 04:42:06PM +0800, Hillf Danton wrote:
> >  	/*
> > -	 * If a zone reaches its high watermark, consider it to be no longer
> > -	 * congested. It's possible there are dirty pages backed by congested
> > -	 * BDIs but as pressure is relieved, speculatively avoid congestion
> > -	 * waits.
> > +	 * Fragmentation may mean that the system cannot be rebalanced for
> > +	 * high-order allocations. If twice the allocation size has been
> > +	 * reclaimed then recheck watermarks only at order-0 to prevent
> > +	 * excessive reclaim. Assume that a process requested a high-order
> > +	 * can direct reclaim/compact.
> >  	 */
> > -	if (pgdat_reclaimable(zone->zone_pgdat) &&
> > -	    zone_balanced(zone, sc->order, false, 0, classzone_idx)) {
> > -		clear_bit(PGDAT_CONGESTED, &pgdat->flags);
> > -		clear_bit(PGDAT_DIRTY, &pgdat->flags);
> > -	}
> > +	if (sc->order && sc->nr_reclaimed >= 2UL << sc->order)
> > +		sc->order = 0;
> > 
> 
> Reclaim order is changed here.
> Btw, I find no such change in current code.
> 

It is reintroducing a check removed by commit accf62422b3a ("mm, kswapd: replace
kswapd compaction with waking up kcompactd"). That patch had kswapd
always check at order-0 once kswapd is awake in pgdat_balanced but would
still take at least one pass through reclaiming so kcompactd potentially
makes progress.

This patch removes pgdat_balanced entirely and zone_balanced() checks the
order it is asked like it used to. Hence, it is necessary to reset sc->order
once progress is made or kswapd potentially stays awake reclaiming pages
until a high-order page is freed.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
