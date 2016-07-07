Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6DE7F6B0263
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 05:48:11 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a2so7819758lfe.0
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 02:48:11 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id 136si2928336wmo.134.2016.07.07.02.48.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jul 2016 02:48:10 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id BA3E4988B3
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 09:48:09 +0000 (UTC)
Date: Thu, 7 Jul 2016 10:48:08 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 04/31] mm, vmscan: begin reclaiming pages on a per-node
 basis
Message-ID: <20160707094808.GP11498@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-5-git-send-email-mgorman@techsingularity.net>
 <20160707011211.GA27987@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160707011211.GA27987@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 07, 2016 at 10:12:12AM +0900, Joonsoo Kim wrote:
> > @@ -1402,6 +1406,11 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> >  
> >  		VM_BUG_ON_PAGE(!PageLRU(page), page);
> >  
> > +		if (page_zonenum(page) > sc->reclaim_idx) {
> > +			list_move(&page->lru, &pages_skipped);
> > +			continue;
> > +		}
> > +
> 
> I think that we don't need to skip LRU pages in active list. What we'd
> like to do is just skipping actual reclaim since it doesn't make
> freepage that we need. It's unrelated to skip the page in active list.
> 

Why?

The active aging is sometimes about simply aging the LRU list. Aging the
active list based on the timing of when a zone-constrained allocation arrives
potentially introduces the same zone-balancing problems we currently have
and applying them to node-lru.

> And, I have a concern that if inactive LRU is full with higher zone's
> LRU pages, reclaim with low reclaim_idx could be stuck.

That is an outside possibility but unlikely given that it would require
that all outstanding allocation requests are zone-contrained. If it happens
that a premature OOM is encountered while the active list is large then
inactive_list_is_low could take scan_control as a parameter and use a
different ratio for zone-contrained allocations if scan priority is elevated.

It would be preferred to have an actual test case for this so the
altered ratio can be tested instead of introducing code that may be
useless or dead.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
