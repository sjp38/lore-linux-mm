Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id EC90D82F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 04:37:11 -0400 (EDT)
Received: by wmeg8 with SMTP id g8so6185028wme.0
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 01:37:11 -0700 (PDT)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id qr8si7535528wjc.131.2015.10.30.01.37.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Oct 2015 01:37:11 -0700 (PDT)
Received: by wmff134 with SMTP id f134so6162510wmf.1
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 01:37:10 -0700 (PDT)
Date: Fri, 30 Oct 2015 09:37:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 2/3] mm: throttle on IO only when there are too many dirty
 and writeback pages
Message-ID: <20151030083709.GD18429@dhcp22.suse.cz>
References: <1446131835-3263-1-git-send-email-mhocko@kernel.org>
 <1446131835-3263-3-git-send-email-mhocko@kernel.org>
 <00f301d112ca$14db86c0$3e929440$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00f301d112ca$14db86c0$3e929440$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-mm@kvack.org, 'Andrew Morton' <akpm@linux-foundation.org>, 'Linus Torvalds' <torvalds@linux-foundation.org>, 'Mel Gorman' <mgorman@suse.de>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Rik van Riel' <riel@redhat.com>, 'David Rientjes' <rientjes@google.com>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'LKML' <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>

On Fri 30-10-15 12:18:50, Hillf Danton wrote:
> 
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3191,8 +3191,23 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  		 */
> >  		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
> >  				ac->high_zoneidx, alloc_flags, target)) {
> > -			/* Wait for some write requests to complete then retry */
> > -			wait_iff_congested(zone, BLK_RW_ASYNC, HZ/50);
> > +			unsigned long writeback = zone_page_state(zone, NR_WRITEBACK),
> > +				      dirty = zone_page_state(zone, NR_FILE_DIRTY);
> > +
> > +			if (did_some_progress)
> > +				goto retry;
> > +
> > +			/*
> > +			 * If we didn't make any progress and have a lot of
> > +			 * dirty + writeback pages then we should wait for
> > +			 * an IO to complete to slow down the reclaim and
> > +			 * prevent from pre mature OOM
> > +			 */
> > +			if (2*(writeback + dirty) > reclaimable)
> > +				congestion_wait(BLK_RW_ASYNC, HZ/10);
> > +			else
> > +				cond_resched();
> > +
> 
> Looks the vmstat updater issue is not addressed.

This is not the aim of this patch set.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
