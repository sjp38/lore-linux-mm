Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3FB146B0006
	for <linux-mm@kvack.org>; Tue, 22 May 2018 02:18:56 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id g92-v6so11491642plg.6
        for <linux-mm@kvack.org>; Mon, 21 May 2018 23:18:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s6-v6si11962963pgp.152.2018.05.21.23.18.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 21 May 2018 23:18:54 -0700 (PDT)
Date: Tue, 22 May 2018 08:18:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
Message-ID: <20180522061850.GB20020@dhcp22.suse.cz>
References: <201805122318.HJG81246.MFVFLFJOOQtSHO@I-love.SAKURA.ne.jp>
 <20180515091655.GD12670@dhcp22.suse.cz>
 <201805181914.IFF18202.FOJOVSOtLFMFHQ@I-love.SAKURA.ne.jp>
 <20180518122045.GG21711@dhcp22.suse.cz>
 <201805210056.IEC51073.VSFFHFOOQtJMOL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201805210056.IEC51073.VSFFHFOOQtJMOL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, guro@fb.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

On Mon 21-05-18 00:56:05, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Fri 18-05-18 19:14:12, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > On Sat 12-05-18 23:18:24, Tetsuo Handa wrote:
> > > > [...]
> > > > > @@ -4241,6 +4240,12 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
> > > > >  	/* Retry as long as the OOM killer is making progress */
> > > > >  	if (did_some_progress) {
> > > > >  		no_progress_loops = 0;
> > > > > +		/*
> > > > > +		 * This schedule_timeout_*() serves as a guaranteed sleep for
> > > > > +		 * PF_WQ_WORKER threads when __zone_watermark_ok() == false.
> > > > > +		 */
> > > > > +		if (!tsk_is_oom_victim(current))
> > > > > +			schedule_timeout_uninterruptible(1);
> > > > >  		goto retry;
> > > > 
> > > > We already do have that sleep for PF_WQ_WORKER in should_reclaim_retry.
> > > > Why do we need it here as well?
> > > 
> > > Because that path depends on __zone_watermark_ok() == true which is not
> > > guaranteed to be executed.
> > 
> > Is there any reason we cannot do the special cased sleep for
> > PF_WQ_WORKER in should_reclaim_retry? The current code is complex enough
> > to make it even more so. If we need a hack for PF_WQ_WORKER case then we
> > definitely want to have a single place to do so.
> 
> I don't understand why you are talking about PF_WQ_WORKER case.

Because that seems to be the reason to have it there as per your
comment.

> This sleep is not only for PF_WQ_WORKER case but also !PF_KTHREAD case.
> I added this comment because you suggested simply removing any sleep which
> waits for the OOM victim.

And now you have made the comment misleading and I suspect it is just
not really needed as well.

> Making special cased sleep for PF_WQ_WORKER in should_reclaim_retry() cannot
> become a reason to block this patch. You can propose it after this patch is
> applied. This patch is for mitigating lockup problem caused by forever holding
> oom_lock.

You are fiddling with other code paths at the same time so I _do_ care.
Spilling random code without a proper explanation is just not going to
fly.
-- 
Michal Hocko
SUSE Labs
