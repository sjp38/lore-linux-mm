Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 50BA46B0253
	for <linux-mm@kvack.org>; Sun, 20 Sep 2015 21:23:41 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so103122624pac.2
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 18:23:41 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ba9si33823255pbd.240.2015.09.20.18.23.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 20 Sep 2015 18:23:40 -0700 (PDT)
Subject: Re: [PATCH 1/2] xfs: Add __GFP_NORETRY and __GFP_NOWARN to open-coded __GFP_NOFAIL allocations
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1442732594-4205-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20150920231146.GX3902@dastard>
In-Reply-To: <20150920231146.GX3902@dastard>
Message-Id: <201509211023.GED18760.HOSMFFOFLtJOVQ@I-love.SAKURA.ne.jp>
Date: Mon, 21 Sep 2015 10:23:37 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com
Cc: xfs@oss.sgi.com, linux-mm@kvack.org, mhocko@suse.com

Dave Chinner wrote:
> On Sun, Sep 20, 2015 at 04:03:13PM +0900, Tetsuo Handa wrote:
> > kmem_alloc(), kmem_zone_alloc() and xfs_buf_allocate_memory() are doing
> > open-coded __GFP_NOFAIL allocations with warning messages as a canary.
> > But since small !__GFP_NOFAIL allocations retry forever inside memory
> > allocator unless TIF_MEMDIE is set, the canary does not help even if
> > allocations are stalling. Thus, this patch adds __GFP_NORETRY so that
> > we can know possibility of allocation deadlock.
> > 
> > If a patchset which makes small !__GFP_NOFAIL !__GFP_FS allocations not
> > retry inside memory allocator is merged, warning messages by
> > warn_alloc_failed() will dominate warning messages by the canary
> > because each thread calls warn_alloc_failed() for approximately
> > every 2 milliseconds. Thus, this patch also adds __GFP_NOWARN so that
> > we won't flood kernel logs by these open-coded __GFP_NOFAIL allocations.
> 
> Please, at minimum, look at the code you are modifying. __GFP_NOWARN
> is already set by both kmem_flags_convert() and xb_to_gfp(),
> precisely for this reason. Any changes to the default gfp flags we
> use need to be inside those wrappers - that's why they exist.

Indeed.

> 
> Further, xb_to_gfp() may already return just "__GFP_NORETRY |
> __GFP_NOWARN", so appending them unconditionally is clearly not the
> best approach.

I see.

> 
> Further, fundamentally changing the allocation behaviour of the
> filesystem requires some indication of the testing and
> characterisation of how the change has impacted low memory balance
> and performance of the filesystem.

Well, I don't have rich environment for evaluating how the change impacts
low memory balance and performance of the filesystem. Therefore, I cancel
this patch.

Please reply if you have comments on "[RFC 0/8] Allow GFP_NOFS allocation
to fail" patchset ( http://marc.info/?l=linux-mm&m=143876830616538 )?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
