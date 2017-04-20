Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id B03AF6B03B0
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 02:09:08 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id b82so59029890iod.10
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 23:09:08 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id m4si2417074pln.319.2017.04.19.23.09.07
        for <linux-mm@kvack.org>;
        Wed, 19 Apr 2017 23:09:08 -0700 (PDT)
Date: Thu, 20 Apr 2017 15:09:04 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch] mm, vmscan: avoid thrashing anon lru when free + file is
 low
Message-ID: <20170420060904.GA3720@bbox>
References: <alpine.DEB.2.10.1704171657550.139497@chino.kir.corp.google.com>
 <20170418013659.GD21354@bbox>
 <alpine.DEB.2.10.1704181402510.112481@chino.kir.corp.google.com>
 <20170419001405.GA13364@bbox>
 <alpine.DEB.2.10.1704191623540.48310@chino.kir.corp.google.com>
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1704191623540.48310@chino.kir.corp.google.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi David,

On Wed, Apr 19, 2017 at 04:24:48PM -0700, David Rientjes wrote:
> On Wed, 19 Apr 2017, Minchan Kim wrote:
> 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 24efcc20af91..5d2f3fa41e92 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2174,8 +2174,17 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
> >  		}
> >  
> >  		if (unlikely(pgdatfile + pgdatfree <= total_high_wmark)) {
> > -			scan_balance = SCAN_ANON;
> > -			goto out;
> > +			/*
> > +			 * force SCAN_ANON if inactive anonymous LRU lists of
> > +			 * eligible zones are enough pages. Otherwise, thrashing
> > +			 * can be happen on the small anonymous LRU list.
> > +			 */
> > +			if (!inactive_list_is_low(lruvec, false, NULL, sc, false) &&
> > +			     lruvec_lru_size(lruvec, LRU_INACTIVE_ANON, sc->reclaim_idx)
> > +					>> sc->priority) {
> > +				scan_balance = SCAN_ANON;
> > +				goto out;
> > +			}
> >  		}
> >  	}
> >  
> 
> Hi Minchan,
> 
> This looks good and it correctly biases against SCAN_ANON for my workload 
> that was thrashing the anon lrus.  Feel free to use parts of my changelog 
> if you'd like.

Thanks for the testing!
As considering how it's hard to find such a problem, it should be totally your
credit. So you can send the patch with detailed description. Feel free to
add my suggested-by. :)

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
