Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3A1F06B0253
	for <linux-mm@kvack.org>; Wed, 18 May 2016 04:49:37 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r12so24793240wme.0
        for <linux-mm@kvack.org>; Wed, 18 May 2016 01:49:37 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id n4si9042159wju.71.2016.05.18.01.49.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 May 2016 01:49:36 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 33E0E98CE3
	for <linux-mm@kvack.org>; Wed, 18 May 2016 08:49:34 +0000 (UTC)
Date: Wed, 18 May 2016 09:49:28 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 28/28] mm, page_alloc: Defer debugging checks of pages
 allocated from the PCP
Message-ID: <20160518084928.GA2527@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-16-git-send-email-mgorman@techsingularity.net>
 <20160517064153.GA23930@hori1.linux.bs1.fc.nec.co.jp>
 <573C1F1E.4040201@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <573C1F1E.4040201@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, May 18, 2016 at 09:51:58AM +0200, Vlastimil Babka wrote:
> On 05/17/2016 08:41 AM, Naoya Horiguchi wrote:
> >> @@ -2579,20 +2612,22 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
> >>   		struct list_head *list;
> >>   
> >>   		local_irq_save(flags);
> >> -		pcp = &this_cpu_ptr(zone->pageset)->pcp;
> >> -		list = &pcp->lists[migratetype];
> >> -		if (list_empty(list)) {
> >> -			pcp->count += rmqueue_bulk(zone, 0,
> >> -					pcp->batch, list,
> >> -					migratetype, cold);
> >> -			if (unlikely(list_empty(list)))
> >> -				goto failed;
> >> -		}
> >> +		do {
> >> +			pcp = &this_cpu_ptr(zone->pageset)->pcp;
> >> +			list = &pcp->lists[migratetype];
> >> +			if (list_empty(list)) {
> >> +				pcp->count += rmqueue_bulk(zone, 0,
> >> +						pcp->batch, list,
> >> +						migratetype, cold);
> >> +				if (unlikely(list_empty(list)))
> >> +					goto failed;
> >> +			}
> >>   
> >> -		if (cold)
> >> -			page = list_last_entry(list, struct page, lru);
> >> -		else
> >> -			page = list_first_entry(list, struct page, lru);
> >> +			if (cold)
> >> +				page = list_last_entry(list, struct page, lru);
> >> +			else
> >> +				page = list_first_entry(list, struct page, lru);
> >> +		} while (page && check_new_pcp(page));
> > 
> > This causes infinite loop when check_new_pcp() returns 1, because the bad
> > page is still in the list (I assume that a bad page never disappears).
> > The original kernel is free from this problem because we do retry after
> > list_del(). So moving the following 3 lines into this do-while block solves
> > the problem?
> > 
> >      __dec_zone_state(zone, NR_ALLOC_BATCH);
> >      list_del(&page->lru);
> >      pcp->count--;
> > 
> > There seems no infinit loop issue in order > 0 block below, because bad pages
> > are deleted from free list in __rmqueue_smallest().
> 
> Ooops, thanks for catching this, wish it was sooner...
> 

Still not too late fortunately! Thanks Naoya for identifying this and
Vlastimil for fixing it.

> ----8<----
> From f52f5e2a7dd65f2814183d8fd254ace43120b828 Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Wed, 18 May 2016 09:41:01 +0200
> Subject: [PATCH] mm, page_alloc: prevent infinite loop in buffered_rmqueue()
> 
> In DEBUG_VM kernel, we can hit infinite loop for order == 0 in
> buffered_rmqueue() when check_new_pcp() returns 1, because the bad page is
> never removed from the pcp list. Fix this by removing the page before retrying.
> Also we don't need to check if page is non-NULL, because we simply grab it from
> the list which was just tested for being non-empty.
> 
> Fixes: http://www.ozlabs.org/~akpm/mmotm/broken-out/mm-page_alloc-defer-debugging-checks-of-freed-pages-until-a-pcp-drain.patch
> Reported-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Reviewed-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
