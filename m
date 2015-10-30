Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 1C61682F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 04:38:08 -0400 (EDT)
Received: by wicfv8 with SMTP id fv8so5734472wic.0
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 01:38:07 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id g17si7543874wjz.119.2015.10.30.01.38.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Oct 2015 01:38:07 -0700 (PDT)
Received: by wicll6 with SMTP id ll6so5675953wic.0
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 01:38:06 -0700 (PDT)
Date: Fri, 30 Oct 2015 09:38:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 2/3] mm: throttle on IO only when there are too many dirty
 and writeback pages
Message-ID: <20151030083805.GE18429@dhcp22.suse.cz>
References: <1446131835-3263-1-git-send-email-mhocko@kernel.org>
 <1446131835-3263-3-git-send-email-mhocko@kernel.org>
 <563304B8.6040703@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <563304B8.6040703@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On Fri 30-10-15 14:48:40, KAMEZAWA Hiroyuki wrote:
[...]
> > @@ -3191,8 +3191,23 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >   		 */
> >   		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
> >   				ac->high_zoneidx, alloc_flags, target)) {
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
> 
> Doesn't this add unnecessary latency if other zones have enough clean memory ?

We know we haven't made any progress the last reclaim round so any zone
with a clean memory is rather unlikely.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
