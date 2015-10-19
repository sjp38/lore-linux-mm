Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8286F6B0273
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 08:53:18 -0400 (EDT)
Received: by wikq8 with SMTP id q8so4399264wik.1
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 05:53:18 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id wg1si40978292wjb.38.2015.10.19.05.53.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Oct 2015 05:53:17 -0700 (PDT)
Received: by wicfv8 with SMTP id fv8so4296303wic.0
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 05:53:16 -0700 (PDT)
Date: Mon, 19 Oct 2015 14:53:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Silent hang up caused by pages being not scanned?
Message-ID: <20151019125315.GF11998@dhcp22.suse.cz>
References: <201510031502.BJD59536.HFJMtQOOLFFVSO@I-love.SAKURA.ne.jp>
 <201510062351.JHJ57310.VFQLFHFOJtSMOO@I-love.SAKURA.ne.jp>
 <201510121543.EJF21858.LtJFHOOOSQVMFF@I-love.SAKURA.ne.jp>
 <201510130025.EJF21331.FFOQJtVOMLFHSO@I-love.SAKURA.ne.jp>
 <CA+55aFwapaED7JV6zm-NVkP-jKie+eQ1vDXWrKD=SkbshZSgmw@mail.gmail.com>
 <201510132121.GDE13044.FOSHLJOMFOtQVF@I-love.SAKURA.ne.jp>
 <CA+55aFxwg=vS2nrXsQhAUzPQDGb8aQpZi0M7UUh21ftBo-z46Q@mail.gmail.com>
 <20151015131409.GD2978@dhcp22.suse.cz>
 <20151016155716.GF19597@dhcp22.suse.cz>
 <CA+55aFynmzy=3f5ae6iAYC7o_27C1UkNzn9x4OFjrW6j6bV9rw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFynmzy=3f5ae6iAYC7o_27C1UkNzn9x4OFjrW6j6bV9rw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On Fri 16-10-15 11:34:48, Linus Torvalds wrote:
> On Fri, Oct 16, 2015 at 8:57 AM, Michal Hocko <mhocko@kernel.org> wrote:
> >
> > OK so here is what I am playing with currently. It is not complete
> > yet.
> 
> So this looks like it's going in a reasonable direction. However:
> 
> > +               if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
> > +                               ac->high_zoneidx, alloc_flags, target)) {
> > +                       /* Wait for some write requests to complete then retry */
> > +                       wait_iff_congested(zone, BLK_RW_ASYNC, HZ/50);
> > +                       goto retry;
> > +               }
> 
> I still think we should at least spend some time re-thinking that
> "wait_iff_congested()" thing.

You are right. I thought we would be congested most of the time because
of the heavy IO but a quick test has shown that the zone is marked
congested but the nr_wb_congested is zero all the time. That is most
probably because the IO is throttled severly by the lack of memory as
well.

> We may not actually be congested, but
> might be unable to write anything out because of our allocation flags
> (ie not allowed to recurse into the filesystems), so we might be in
> the situation that we have a lot of dirty pages that we can't directly
> do anything about.
> 
> Now, we will have woken kswapd, so something *will* hopefully be done
> about them eventually, but at no time do we actually really wait for
> it. We'll just busy-loop.
> 
> So at a minimum, I think we should yield to kswapd. We do do that
> "cond_resched()" in wait_iff_congested(), but I'm not entirely
> convinced that is at all enough to wait for kswapd to *do* something.

I went with congestion_wait which is what we used to do in the past
before wait_iff_congested has been introduced. The primary reason for
the change was that congestion_wait used to cause unhealthy stalls in
the direct reclaim where the bdi wasn't really congested and so we were
sleeping for the full timeout.

Now I think we can do better even with congestion_wait. We do not have
to wait when we did_some_progress so we won't affect a regular direct
reclaim path and we can reduce sleeping to:

dirty+writeback > reclaimable/2

This is a good signal that the reason for no progress is the stale
IO most likely and we need to wait even if the bdi itself is not
congested. We can also increase the timeout to HZ/10 because this is an
extreme slow path - we are not doing any progress and stalling is better
than OOM.

This is a diff on top of the previous patch. I even think that this part
would deserve a separate patch for a better bisect-ability. My testing
shows that close-to-oom behaves better (I can use more memory for
memeaters without hitting OOM)

What do you think?
---
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e28028681c59..fed1bb7ea43a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3188,8 +3187,21 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		 */
 		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
 				ac->high_zoneidx, alloc_flags, target)) {
-			/* Wait for some write requests to complete then retry */
-			wait_iff_congested(zone, BLK_RW_ASYNC, HZ/50);
+			unsigned long writeback = zone_page_state(zone, NR_WRITEBACK),
+				      dirty = zone_page_state(zone, NR_FILE_DIRTY);
+			if (did_some_progress)
+				goto retry;
+
+			/*
+			 * If we didn't make any progress and have a lot of
+			 * dirty + writeback pages then we should wait for
+			 * an IO to complete to slow down the reclaim and
+			 * prevent from pre mature OOM
+			 */
+			if (2*(writeback + dirty) > reclaimable)
+				congestion_wait(BLK_RW_ASYNC, HZ/10);
+			else
+				cond_resched();
 			goto retry;
 		}
 	}

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
