Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 90654280300
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 16:29:33 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id y7so6048842oia.7
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 13:29:33 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id v201si3045493oie.126.2017.08.29.13.29.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Aug 2017 13:29:32 -0700 (PDT)
Subject: Re: [PATCH] mm: Use WQ_HIGHPRI for mm_percpu_wq.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1503921210-4603-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170828121055.GI17097@dhcp22.suse.cz>
	<20170828170611.GV491396@devbig577.frc2.facebook.com>
	<20170829133325.o2s4xiqnc3ez6qxb@dhcp22.suse.cz>
	<20170829143319.GJ491396@devbig577.frc2.facebook.com>
In-Reply-To: <20170829143319.GJ491396@devbig577.frc2.facebook.com>
Message-Id: <201708300529.HEB00599.VHtOFOLFSJOMFQ@I-love.SAKURA.ne.jp>
Date: Wed, 30 Aug 2017 05:29:26 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@suse.de, vbabka@suse.cz

Tejun Heo wrote:
> Hello,
> 
> On Tue, Aug 29, 2017 at 03:33:25PM +0200, Michal Hocko wrote:
> > Hmm, we have this in should_reclaim_retry
> > 			/*
> > 			 * Memory allocation/reclaim might be called from a WQ
> > 			 * context and the current implementation of the WQ
> > 			 * concurrency control doesn't recognize that
> > 			 * a particular WQ is congested if the worker thread is
> > 			 * looping without ever sleeping. Therefore we have to
> > 			 * do a short sleep here rather than calling
> > 			 * cond_resched().
> > 			 */
> > 			if (current->flags & PF_WQ_WORKER)
> > 				schedule_timeout_uninterruptible(1);
> > 
> > And I thought it would be susfficient for kworkers for concurrency WQ
> > congestion thingy to jump in. Or do we need something more generic. E.g.
> > make cond_resched special for kworkers?
> 
> I actually think we're hitting a bug somewhere.  Tetsuo's trace with
> the patch applies doesn't add up.
> 
> Thanks.

If we are under memory pressure, __zone_watermark_ok() can return false.
If __zone_watermark_ok() == false, when is schedule_timeout_*() called explicitly?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
