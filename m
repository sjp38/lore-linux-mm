Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id F3BA96B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 08:01:32 -0400 (EDT)
Received: by mail-wm0-f51.google.com with SMTP id l68so22746664wml.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 05:01:32 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id z2si2199939wjz.132.2016.03.17.05.01.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Mar 2016 05:01:31 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id x188so6284550wmg.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 05:01:30 -0700 (PDT)
Date: Thu, 17 Mar 2016 13:01:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] mm: throttle on IO only when there are too many
 dirty and writeback pages
Message-ID: <20160317120127.GC26017@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <1450203586-10959-3-git-send-email-mhocko@kernel.org>
 <201603172035.CJH95337.SOJOFFFHMLOQVt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201603172035.CJH95337.SOJOFFFHMLOQVt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 17-03-16 20:35:23, Tetsuo Handa wrote:
[...]
> But what I felt strange is what should_reclaim_retry() is doing.
> 
> Michal Hocko wrote:
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index f77e283fb8c6..b2de8c8761ad 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3044,8 +3045,37 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
> >  		 */
> >  		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
> >  				ac->high_zoneidx, alloc_flags, available)) {
> > -			/* Wait for some write requests to complete then retry */
> > -			wait_iff_congested(zone, BLK_RW_ASYNC, HZ/50);
> > +			unsigned long writeback;
> > +			unsigned long dirty;
> > +
> > +			writeback = zone_page_state_snapshot(zone, NR_WRITEBACK);
> > +			dirty = zone_page_state_snapshot(zone, NR_FILE_DIRTY);
> > +
> > +			/*
> > +			 * If we didn't make any progress and have a lot of
> > +			 * dirty + writeback pages then we should wait for
> > +			 * an IO to complete to slow down the reclaim and
> > +			 * prevent from pre mature OOM
> > +			 */
> > +			if (!did_some_progress && 2*(writeback + dirty) > reclaimable) {
> > +				congestion_wait(BLK_RW_ASYNC, HZ/10);
> > +				return true;
> > +			}
> 
> writeback and dirty are used only when did_some_progress == 0. Thus, we don't
> need to calculate writeback and dirty using zone_page_state_snapshot() unless
> did_some_progress == 0.

OK, I will move this into if !did_some_progress.

> But, does it make sense to take writeback and dirty into account when
> disk_events_workfn (trace shown above) is doing GFP_NOIO allocation and
> wb_workfn (trace shown above) is doing (presumably) GFP_NOFS allocation?
> Shouldn't we use different threshold for GFP_NOIO / GFP_NOFS / GFP_KERNEL?

I have considered skiping the throttling part for GFP_NOFS/GFP_NOIO
previously but I couldn't have convinced myself it would make any
difference. We know there was no progress in the reclaim and even if the
current context is doing FS/IO allocation potentially then it obviously
cannot get its memory so it cannot proceed. So now we are in the state
where we either busy loop or sleep for a while. So I ended up not
complicating the code even more. If you have a use case where busy
waiting makes a difference then I would vote for a separate patch with a
clear description.

> > +
> > +			/*
> > +			 * Memory allocation/reclaim might be called from a WQ
> > +			 * context and the current implementation of the WQ
> > +			 * concurrency control doesn't recognize that
> > +			 * a particular WQ is congested if the worker thread is
> > +			 * looping without ever sleeping. Therefore we have to
> > +			 * do a short sleep here rather than calling
> > +			 * cond_resched().
> > +			 */
> > +			if (current->flags & PF_WQ_WORKER)
> > +				schedule_timeout(1);
> 
> This schedule_timeout(1) does not sleep. You lost the fix as of next-20160317.
> Please update.

Yeah, I have that updated in my local patch already.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
