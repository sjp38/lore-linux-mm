Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id ED904280273
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 04:17:54 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w84so75434888wmg.1
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 01:17:54 -0700 (PDT)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id p8si18466367wjf.153.2016.09.26.01.17.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 01:17:53 -0700 (PDT)
Received: by mail-wm0-f52.google.com with SMTP id w84so137359557wmg.1
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 01:17:53 -0700 (PDT)
Date: Mon, 26 Sep 2016 10:17:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: warn about allocations which stall for too long
Message-ID: <20160926081751.GD27030@dhcp22.suse.cz>
References: <20160923081555.14645-1-mhocko@kernel.org>
 <201609232336.FIH57364.FOVHtMFQLFSJOO@I-love.SAKURA.ne.jp>
 <20160923150234.GV4478@dhcp22.suse.cz>
 <201609241200.AEE21807.OSOtQVOLHMFJFF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201609241200.AEE21807.OSOtQVOLHMFJFF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, linux-kernel@vger.kernel.org

On Sat 24-09-16 12:00:07, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Fri 23-09-16 23:36:22, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > @@ -3659,6 +3661,15 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> > > >  	else
> > > >  		no_progress_loops++;
> > > >  
> > > > +	/* Make sure we know about allocations which stall for too long */
> > > > +	if (!(gfp_mask & __GFP_NOWARN) && time_after(jiffies, alloc_start + stall_timeout)) {
> > > 
> > > Should we check !__GFP_NOWARN ? I think __GFP_NOWARN is likely used with
> > > __GFP_NORETRY, and __GFP_NORETRY is already checked by now.
> > > 
> > > I think printing warning regardless of __GFP_NOWARN is better because
> > > this check is similar to hungtask warning.
> > 
> > Well, if the user said to not warn we should really obey that. Why would
> > that matter?
> 
> __GFP_NOWARN is defined as "Do not print failure messages when memory
> allocation failed". It is not defined as "Do not print OOM killer messages
> when OOM killer is invoked". It is undefined that "Do not print stall
> messages when memory allocation is stalling".

Which is kind of expected as we warned only about allocation failures up
to now.

> If memory allocating threads were blocked on locks instead of doing direct
> reclaim, hungtask will be able to find stalling memory allocations without
> this change. Since direct reclaim prevents allocating threads from sleeping
> for long enough to be warned by hungtask, it is important that this change
> shall find allocating threads which cannot be warned by hungtask. That is,
> not printing warning messages for __GFP_NOWARN allocation requests looses
> the value of this change.

I dunno. If the user explicitly requests to not have allocation warning
then I think we should obey that. But this is not something I would be
really insisting hard. If others think that the check should be dropped
I can live with that.

[...]
> > > ) rather than by line number, and surround __warn_memalloc_stall() call with
> > > mutex in order to serialize warning messages because it is possible that
> > > multiple allocation requests are stalling?
> > 
> > we do not use any lock in warn_alloc_failed so why this should be any
> > different?
> 
> warn_alloc_failed() is called for both __GFP_DIRECT_RECLAIM and
> !__GFP_DIRECT_RECLAIM allocation requests, and it is not allowed
> to sleep if !__GFP_DIRECT_RECLAIM. Thus, we have to tolerate that
> concurrent memory allocation failure messages make dmesg output
> unreadable. But __warn_memalloc_stall() is called for only
> __GFP_DIRECT_RECLAIM allocation requests. Thus, we are allowed to
> sleep in order to serialize concurrent memory allocation stall
> messages.

I still do not see a point. A single line about the warning and locked
dump_stack sounds sufficient to me.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
