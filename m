Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2836B0032
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 13:14:13 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id bs8so27625879wib.0
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 10:14:12 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jk6si24816804wid.50.2015.02.24.10.14.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Feb 2015 10:14:11 -0800 (PST)
Date: Tue, 24 Feb 2015 19:14:08 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: __GFP_NOFAIL and oom_killer_disabled?
Message-ID: <20150224181408.GD14939@dhcp22.suse.cz>
References: <20150220231511.GH12722@dastard>
 <20150221032000.GC7922@thunk.org>
 <20150221011907.2d26c979.akpm@linux-foundation.org>
 <201502222348.GFH13009.LOHOMFVtFQSFOJ@I-love.SAKURA.ne.jp>
 <20150223102147.GB24272@dhcp22.suse.cz>
 <201502232203.DGC60931.QVtOLSOOJFMHFF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201502232203.DGC60931.QVtOLSOOJFMHFF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, tytso@mit.edu, david@fromorbit.com, hannes@cmpxchg.org, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org

On Mon 23-02-15 22:03:25, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > What about something like the following?
> 
> I'm fine with whatever approaches as long as retry is guaranteed.
> 
> But maybe we can use memory reserves like below?

This sounds too risky to me and not really necessary. GFP_NOFAIL
allocations shouldn't be called while the system is not running any
tasks (aka from pm/device code). So we are primarily trying to help
those nofail allocations which come from kernel threads and their retry
will fail the suspend rather than blow up because of an unexpected
allocation failure.

> I think there will be little risk because userspace processes are
> already frozen...
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a47f0b2..cea0a1b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2760,8 +2760,17 @@ retry:
>  							&did_some_progress);
>  			if (page)
>  				goto got_pg;
> -			if (!did_some_progress)
> +			if (!did_some_progress && !(gfp_mask & __GFP_NOFAIL))
>  				goto nopage;
> +			/*
> +			 * What!? __GFP_NOFAIL allocation failed to invoke
> +			 * the OOM killer due to oom_killer_disabled == true?
> +			 * Then, pretend ALLOC_NO_WATERMARKS request and let
> +			 * __alloc_pages_high_priority() retry forever...
> +			 */
> +			WARN(1, "Retrying GFP_NOFAIL allocation...\n");
> +			gfp_mask &= ~__GFP_NOMEMALLOC;
> +			gfp_mask |= __GFP_MEMALLOC;
>  		}
>  		/* Wait for some write requests to complete then retry */
>  		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
