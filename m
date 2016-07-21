Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id DB4446B0272
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 05:16:36 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p129so8821508wmp.3
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 02:16:36 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id c194si2299224wme.107.2016.07.21.02.16.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jul 2016 02:16:35 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 4470D98F1D
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 09:16:35 +0000 (UTC)
Date: Thu, 21 Jul 2016 10:16:33 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 0/5] Candidate fixes for premature OOM kills with
 node-lru v1
Message-ID: <20160721091633.GI10438@techsingularity.net>
References: <1469028111-1622-1-git-send-email-mgorman@techsingularity.net>
 <20160721073156.GC27554@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160721073156.GC27554@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 21, 2016 at 04:31:56PM +0900, Joonsoo Kim wrote:
> On Wed, Jul 20, 2016 at 04:21:46PM +0100, Mel Gorman wrote:
> > Both Joonsoo Kim and Minchan Kim have reported premature OOM kills on
> > a 32-bit platform. The common element is a zone-constrained high-order
> > allocation failing. Two factors appear to be at fault -- pgdat being
> > considered unreclaimable prematurely and insufficient rotation of the
> > active list.
> > 
> > Unfortunately to date I have been unable to reproduce this with a variety
> > of stress workloads on a 2G 32-bit KVM instance. It's not clear why as
> > the steps are similar to what was described. It means I've been unable to
> > determine if this series addresses the problem or not. I'm hoping they can
> > test and report back before these are merged to mmotm. What I have checked
> > is that a basic parallel DD workload completed successfully on the same
> > machine I used for the node-lru performance tests. I'll leave the other
> > tests running just in case anything interesting falls out.
> 
> Hello, Mel.
> 
> I tested this series and it doesn't solve my problem. But, with this
> series and one change below, my problem is solved.
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f5ab357..d451c29 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1819,7 +1819,7 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
>  
>                 nr_pages = hpage_nr_pages(page);
>                 update_lru_size(lruvec, lru, page_zonenum(page), nr_pages);
> -               list_move(&page->lru, &lruvec->lists[lru]);
> +               list_move_tail(&page->lru, &lruvec->lists[lru]);
>                 pgmoved += nr_pages;
>  
>                 if (put_page_testzero(page)) {
> 
> It is brain-dead work-around so it is better you to find a better solution.
> 

This wrecks LRU ordering.

> I guess that, in my test, file reference happens very quickly. So, if there are
> many skip candidates, reclaimable pages on lower zone cannot be reclaimed easily
> due to re-reference. If I apply above work-around, the test is finally passed.
> 

I think by scaling skipped pages as partial scan that it may address the
issue.

> One more note that, in my test, 1/5 patch have a negative impact. Sometime,
> system lock-up happens and elapsed time is also worse than the test without it.
> 
> Anyway, it'd be good to post my test script and program.
> 
> setup: 64 bit 2000 MB (500 MB DMA32 and 1500 MB MOVABLE)
> 

Thanks. I partially replicated this with a 32-bit machine and minor
modifications. It triggered an OOM within 5 minutes. I'll test the revised
series shortly and when/if it's successful I'll post a V2 of the series.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
