Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6E3086B025F
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 09:33:28 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p37so4774894wrc.5
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 06:33:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n189si1260292wme.273.2017.08.29.06.33.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Aug 2017 06:33:26 -0700 (PDT)
Date: Tue, 29 Aug 2017 15:33:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Use WQ_HIGHPRI for mm_percpu_wq.
Message-ID: <20170829133325.o2s4xiqnc3ez6qxb@dhcp22.suse.cz>
References: <1503921210-4603-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170828121055.GI17097@dhcp22.suse.cz>
 <20170828170611.GV491396@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170828170611.GV491396@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>

On Mon 28-08-17 10:06:11, Tejun Heo wrote:
> Hello, Michal.
> 
> On Mon, Aug 28, 2017 at 02:10:56PM +0200, Michal Hocko wrote:
> > I am not sure I understand how WQ_HIGHPRI actually helps. The work item
> > will get served by a thread with higher priority and from a different
> > pool than regular WQs. But what prevents the same issue as described
> > above when the highprio pool gets congested? In other words what make
> > WQ_HIGHPRI less prone to long stalls when we are under low memory
> > situation and new workers cannot be allocated?
> 
> So, the problem wasn't new worker not getting allocated due to memory
> pressure.  Rescuer can handle that.  The problem is that the regular
> worker pool is occupied with something which is constantly in runnable
> state - most likely writeback / reclaim, so the workqueue doesn't
> schedule the other work items.

Hmm, we have this in should_reclaim_retry
			/*
			 * Memory allocation/reclaim might be called from a WQ
			 * context and the current implementation of the WQ
			 * concurrency control doesn't recognize that
			 * a particular WQ is congested if the worker thread is
			 * looping without ever sleeping. Therefore we have to
			 * do a short sleep here rather than calling
			 * cond_resched().
			 */
			if (current->flags & PF_WQ_WORKER)
				schedule_timeout_uninterruptible(1);

And I thought it would be susfficient for kworkers for concurrency WQ
congestion thingy to jump in. Or do we need something more generic. E.g.
make cond_resched special for kworkers?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
