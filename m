Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id CC1716B0260
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 08:31:52 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id h68so78657779lfh.2
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 05:31:52 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id l1si33033358wjy.221.2016.06.07.05.31.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jun 2016 05:31:51 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id n184so23849989wmn.1
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 05:31:51 -0700 (PDT)
Date: Tue, 7 Jun 2016 14:31:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, tree wide: replace __GFP_REPEAT by
 __GFP_RETRY_HARD with more useful semantic
Message-ID: <20160607123149.GK12305@dhcp22.suse.cz>
References: <1465212736-14637-1-git-send-email-mhocko@kernel.org>
 <1465212736-14637-2-git-send-email-mhocko@kernel.org>
 <7fb7e035-7795-839b-d1b0-4a68fcf8e9c9@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7fb7e035-7795-839b-d1b0-4a68fcf8e9c9@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 07-06-16 21:11:03, Tetsuo Handa wrote:
> On 2016/06/06 20:32, Michal Hocko wrote:
> > diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> > index 669fef1e2bb6..a4b0f18a69ab 100644
> > --- a/drivers/vhost/vhost.c
> > +++ b/drivers/vhost/vhost.c
> > @@ -707,7 +707,7 @@ static int vhost_memory_reg_sort_cmp(const void *p1, const void *p2)
> >  
> >  static void *vhost_kvzalloc(unsigned long size)
> >  {
> > -	void *n = kzalloc(size, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
> > +	void *n = kzalloc(size, GFP_KERNEL | __GFP_NOWARN | __GFP_RETRY_HARD);
> 
> Remaining __GFP_REPEAT users are not always doing costly allocations.

Yes but...

> Sometimes they pass __GFP_REPEAT because the size is given from userspace.
> Thus, unconditional s/__GFP_REPEAT/__GFP_RETRY_HARD/g is not good.

Would that be a regression though? Strictly speaking the __GFP_REPEAT
documentation was explicit to not loop for ever. So nobody should have
expected nofail semantic pretty much by definition. The fact that our
previous implementation was not fully conforming to the documentation is
just an implementation detail.  All the remaining users of __GFP_REPEAT
_have_ to be prepared for the allocation failure. So what exactly is the
problem with them?

> What I think more important is hearing from __GFP_REPEAT users how hard they
> want to retry. It is possible that they want to retry unless SIGKILL is
> delivered, but passing __GFP_NOFAIL is too hard, and therefore __GFP_REPEAT
> is used instead. It is possible that they use __GFP_NOFAIL || __GFP_KILLABLE
> if __GFP_KILLABLE were available. In my module (though I'm not using
> __GFP_REPEAT), I want to retry unless SIGKILL is delivered.

To be honest killability for a particular allocation request sounds
like a hack to me. Just consider the expected semantic. How do you
handle when one path uses explicit __GFP_KILLABLE while other path (from
the same syscall) is not... If anything this would have to be process
context wise.
 
[...]
> >  	/* Reclaim has failed us, start killing things */
> >  	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
> >  	if (page)
> > @@ -3719,6 +3731,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  	/* Retry as long as the OOM killer is making progress */
> >  	if (did_some_progress) {
> >  		no_progress_loops = 0;
> > +		passed_oom = true;
> 
> This is too premature. did_some_progress != 0 after returning from
> __alloc_pages_may_oom() does not mean the OOM killer was invoked. It only means
> that mutex_trylock(&oom_lock) was attempted.

which means that we have reached the OOM condition and _somebody_ is
actaully handling the OOM on our behalf.

> It is possible that somebody else
> is on the way to call out_of_memory(). It is possible that the OOM reaper is
> about to start reaping memory. Giving up after 1 jiffie of sleep is too fast.

Sure this will always be racy. But the primary point is that we have
passed the OOM line and then passed through all the retries to get to
the same state again. This sounds like a pretty natural boundary to tell
we have tried hard enough to rather fail and let the caller handle the
fallback.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
