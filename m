Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0CC946B0268
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 12:06:11 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c82so8674772wme.2
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 09:06:11 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id s20si2923539wmb.51.2016.06.08.09.06.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 09:06:09 -0700 (PDT)
Date: Wed, 8 Jun 2016 12:06:06 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 07/10] mm: base LRU balancing on an explicit cost model
Message-ID: <20160608160606.GE6727@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-8-hannes@cmpxchg.org>
 <20160608081421.GC28620@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160608081421.GC28620@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Wed, Jun 08, 2016 at 05:14:21PM +0900, Minchan Kim wrote:
> On Mon, Jun 06, 2016 at 03:48:33PM -0400, Johannes Weiner wrote:
> > @@ -249,15 +249,10 @@ void rotate_reclaimable_page(struct page *page)
> >  	}
> >  }
> >  
> > -static void update_page_reclaim_stat(struct lruvec *lruvec,
> > -				     int file, int rotated,
> > -				     unsigned int nr_pages)
> > +void lru_note_cost(struct lruvec *lruvec, bool file, unsigned int nr_pages)
> >  {
> > -	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
> > -
> > -	reclaim_stat->recent_scanned[file] += nr_pages;
> > -	if (rotated)
> > -		reclaim_stat->recent_rotated[file] += nr_pages;
> > +	lruvec->balance.numer[file] += nr_pages;
> > +	lruvec->balance.denom += nr_pages;
> 
> balance.numer[0] + balance.number[1] = balance.denom
> so we can remove denom at the moment?

You're right, it doesn't make sense to keep that around anymore. I'll
remove it.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
