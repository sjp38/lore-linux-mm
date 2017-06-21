Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 433066B03C7
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 05:43:50 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g46so28851707wrd.3
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 02:43:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m127si16414560wmg.165.2017.06.21.02.43.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Jun 2017 02:43:49 -0700 (PDT)
Date: Wed, 21 Jun 2017 11:43:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: remove a redundant condition in the for loop
Message-ID: <20170621094344.GC22051@dhcp22.suse.cz>
References: <20170619135418.8580-1-haolee.swjtu@gmail.com>
 <e2169d83-8845-7eac-2b81-e5f0b16943a3@suse.cz>
 <87y3snajd2.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87y3snajd2.fsf@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Vlastimil Babka <vbabka@suse.cz>, Hao Lee <haolee.swjtu@gmail.com>, akpm@linux-foundation.org, mgorman@techsingularity.net, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 19-06-17 21:05:29, Rasmus Villemoes wrote:
> On Mon, Jun 19 2017, Vlastimil Babka <vbabka@suse.cz> wrote:
> 
> > On 06/19/2017 03:54 PM, Hao Lee wrote:
> >> The variable current_order decreases from MAX_ORDER-1 to order, so the
> >> condition current_order <= MAX_ORDER-1 is always true.
> >> 
> >> Signed-off-by: Hao Lee <haolee.swjtu@gmail.com>
> >
> > Sounds right.
> >
> > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> current_order and order are both unsigned, and if order==0,
> current_order >= order is always true, and we may decrement
> current_order past 0 making it UINT_MAX... A comment would be in order,
> though.

Yes, not the first time this has been brought up
https://lkml.org/lkml/2016/6/20/493. I guess a comment is long overdue.
Or just get rid of the unsigned trap which would be probably more clean.
 
> >> ---
> >>  mm/page_alloc.c | 5 ++---
> >>  1 file changed, 2 insertions(+), 3 deletions(-)
> >> 
> >> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >> index 2302f25..9120c2b 100644
> >> --- a/mm/page_alloc.c
> >> +++ b/mm/page_alloc.c
> >> @@ -2215,9 +2215,8 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
> >>  	bool can_steal;
> >>  
> >>  	/* Find the largest possible block of pages in the other list */
> >> -	for (current_order = MAX_ORDER-1;
> >> -				current_order >= order && current_order <= MAX_ORDER-1;
> >> -				--current_order) {
> >> +	for (current_order = MAX_ORDER-1; current_order >= order;
> >> +							--current_order) {
> >>  		area = &(zone->free_area[current_order]);
> >>  		fallback_mt = find_suitable_fallback(area, current_order,
> >>  				start_migratetype, false, &can_steal);
> >> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
