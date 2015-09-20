Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id D037C6B0253
	for <linux-mm@kvack.org>; Sun, 20 Sep 2015 19:12:20 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so100981730pac.2
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 16:12:20 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id pl7si8048468pbb.100.2015.09.20.16.12.18
        for <linux-mm@kvack.org>;
        Sun, 20 Sep 2015 16:12:19 -0700 (PDT)
Date: Mon, 21 Sep 2015 09:11:46 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/2] xfs: Add __GFP_NORETRY and __GFP_NOWARN to
 open-coded __GFP_NOFAIL allocations
Message-ID: <20150920231146.GX3902@dastard>
References: <1442732594-4205-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442732594-4205-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: xfs@oss.sgi.com, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

On Sun, Sep 20, 2015 at 04:03:13PM +0900, Tetsuo Handa wrote:
> kmem_alloc(), kmem_zone_alloc() and xfs_buf_allocate_memory() are doing
> open-coded __GFP_NOFAIL allocations with warning messages as a canary.
> But since small !__GFP_NOFAIL allocations retry forever inside memory
> allocator unless TIF_MEMDIE is set, the canary does not help even if
> allocations are stalling. Thus, this patch adds __GFP_NORETRY so that
> we can know possibility of allocation deadlock.
> 
> If a patchset which makes small !__GFP_NOFAIL !__GFP_FS allocations not
> retry inside memory allocator is merged, warning messages by
> warn_alloc_failed() will dominate warning messages by the canary
> because each thread calls warn_alloc_failed() for approximately
> every 2 milliseconds. Thus, this patch also adds __GFP_NOWARN so that
> we won't flood kernel logs by these open-coded __GFP_NOFAIL allocations.

Please, at minimum, look at the code you are modifying. __GFP_NOWARN
is already set by both kmem_flags_convert() and xb_to_gfp(),
precisely for this reason. Any changes to the default gfp flags we
use need to be inside those wrappers - that's why they exist.

Further, xb_to_gfp() may already return just "__GFP_NORETRY |
__GFP_NOWARN", so appending them unconditionally is clearly not the
best approach.

Further, fundamentally changing the allocation behaviour of the
filesystem requires some indication of the testing and
characterisation of how the change has impacted low memory balance
and performance of the filesystem.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
