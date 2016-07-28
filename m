Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 92EC46B025F
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 21:37:40 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id i64so37089083ith.2
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 18:37:40 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id i191si9801747ioa.182.2016.07.27.18.37.39
        for <linux-mm@kvack.org>;
        Wed, 27 Jul 2016 18:37:39 -0700 (PDT)
Date: Thu, 28 Jul 2016 10:38:22 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/5] mm, vmscan: Do not account skipped pages as scanned
Message-ID: <20160728013822.GC6974@bbox>
References: <1469028111-1622-1-git-send-email-mgorman@techsingularity.net>
 <1469028111-1622-2-git-send-email-mgorman@techsingularity.net>
 <20160725080456.GB1660@bbox>
 <20160725092014.GL10438@techsingularity.net>
MIME-Version: 1.0
In-Reply-To: <20160725092014.GL10438@techsingularity.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 25, 2016 at 10:20:14AM +0100, Mel Gorman wrote:
> On Mon, Jul 25, 2016 at 05:04:56PM +0900, Minchan Kim wrote:
> > > @@ -1429,6 +1429,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> > >  			continue;
> > >  		}
> > >  
> > > +		/* Pages skipped do not contribute to scan */
> > > +		scan++;
> > > +
> > 
> > As I mentioned in previous version, under irq-disabled-spin-lock, such
> > unbounded operation would make the latency spike worse if there are
> > lot of pages we should skip.
> > 
> > Don't we take care it?
> 
> It's not unbounded, it's bound by the size of the LRU list and it's not
> going to be enough to trigger a warning. While the lock hold time may be
> undesirable, unlocking it every SWAP_CLUSTER_MAX pages may increase overall
> contention. There also is the question of whether skipped pages should be
> temporarily putback before unlocking the LRU to avoid isolated pages being
> unavailable for too long. It also cannot easily just return early without
> prematurely triggering OOM due to a lack of progress. I didn't feel the
> complexity was justified.

I measured the lock holding time and it took max 96ms during 360M
scanning with hackbench. It was very easy to reproduce with node-lru
because it should skip too many pages.

Given that my box is much faster than usual mobile CPU, it would
take more time in embedded system. I think irq disable during 96ms would
be worth to be fixed.

Anyway, I'm done by that which I measured time by hand so it's up to you
that whether you want to fix or leave as it is until someone reports it with
more real workload.

> 
> -- 
> Mel Gorman
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
