Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id B6F526B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 15:14:04 -0400 (EDT)
Received: by wizk4 with SMTP id k4so33104503wiz.1
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 12:14:04 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id fk5si394775wib.21.2015.04.24.12.14.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Apr 2015 12:14:03 -0700 (PDT)
Date: Fri, 24 Apr 2015 15:13:53 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 09/12] mm: page_alloc: private memory reserves for
 OOM-killing allocations
Message-ID: <20150424191353.GA5293@cmpxchg.org>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <1427264236-17249-10-git-send-email-hannes@cmpxchg.org>
 <20150414164939.GJ17160@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150414164939.GJ17160@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>

On Tue, Apr 14, 2015 at 06:49:40PM +0200, Michal Hocko wrote:
> On Wed 25-03-15 02:17:13, Johannes Weiner wrote:
> > @@ -5747,17 +5765,18 @@ static void __setup_per_zone_wmarks(void)
> >  
> >  			min_pages = zone->managed_pages / 1024;
> >  			min_pages = clamp(min_pages, SWAP_CLUSTER_MAX, 128UL);
> > -			zone->watermark[WMARK_MIN] = min_pages;
> > +			zone->watermark[WMARK_OOM] = min_pages;
> >  		} else {
> >  			/*
> >  			 * If it's a lowmem zone, reserve a number of pages
> >  			 * proportionate to the zone's size.
> >  			 */
> > -			zone->watermark[WMARK_MIN] = tmp;
> > +			zone->watermark[WMARK_OOM] = tmp;
> >  		}
> >  
> > -		zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + (tmp >> 2);
> > -		zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + (tmp >> 1);
> > +		zone->watermark[WMARK_MIN]  = oom_wmark_pages(zone) + (tmp >> 3);
> > +		zone->watermark[WMARK_LOW]  = oom_wmark_pages(zone) + (tmp >> 2);
> > +		zone->watermark[WMARK_HIGH] = oom_wmark_pages(zone) + (tmp >> 1);
> 
> This will basically elevate the min watermark, right? And that might lead
> to subtle performance differences even when OOM killer is not invoked
> because the direct reclaim will start sooner.

It will move the min watermark a bit closer to the kswapd watermarks,
so I guess the risk of entering direct reclaim when kswapd won't wake
up fast enough before concurrent allocator slowpaths deplete the zone
from low to min is marginally increased.  That seems like a farfetched
worry, especially given that waking up a sleeping kswapd is not a high
frequency event in the first place.

> Shouldn't we rather give WMARK_OOM half of WMARK_MIN instead?

I guess conceptually that would work as well, since an OOM killing
task is technically reclaiming memory and this reserve is meant to
help reclaiming tasks make forward progress.

That being said, the separate OOM reserve was designed for when the
allocation can actually fail: deplete our own little reserve before
returning failure.  But it looks like neither the low-order nor the
GFP_NOFS deadlock fixes got any traction, and so right now all OOM
killing allocations still have the potential to deadlock.  Is there a
reason we shouldn't just let them do an ALLOC_NO_WATERMARK allocation
after the OOM victim exited (or timed out)?

Otherwise, I'll just do that in the next iteration.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
