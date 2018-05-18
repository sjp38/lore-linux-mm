Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1964F6B05D4
	for <linux-mm@kvack.org>; Fri, 18 May 2018 08:20:50 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a127-v6so3632939wmh.6
        for <linux-mm@kvack.org>; Fri, 18 May 2018 05:20:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r15-v6si3247456edd.357.2018.05.18.05.20.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 May 2018 05:20:48 -0700 (PDT)
Date: Fri, 18 May 2018 14:20:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
Message-ID: <20180518122045.GG21711@dhcp22.suse.cz>
References: <201805122318.HJG81246.MFVFLFJOOQtSHO@I-love.SAKURA.ne.jp>
 <20180515091655.GD12670@dhcp22.suse.cz>
 <201805181914.IFF18202.FOJOVSOtLFMFHQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201805181914.IFF18202.FOJOVSOtLFMFHQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, guro@fb.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

On Fri 18-05-18 19:14:12, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Sat 12-05-18 23:18:24, Tetsuo Handa wrote:
> > [...]
> > > @@ -4241,6 +4240,12 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
> > >  	/* Retry as long as the OOM killer is making progress */
> > >  	if (did_some_progress) {
> > >  		no_progress_loops = 0;
> > > +		/*
> > > +		 * This schedule_timeout_*() serves as a guaranteed sleep for
> > > +		 * PF_WQ_WORKER threads when __zone_watermark_ok() == false.
> > > +		 */
> > > +		if (!tsk_is_oom_victim(current))
> > > +			schedule_timeout_uninterruptible(1);
> > >  		goto retry;
> > 
> > We already do have that sleep for PF_WQ_WORKER in should_reclaim_retry.
> > Why do we need it here as well?
> 
> Because that path depends on __zone_watermark_ok() == true which is not
> guaranteed to be executed.

Is there any reason we cannot do the special cased sleep for
PF_WQ_WORKER in should_reclaim_retry? The current code is complex enough
to make it even more so. If we need a hack for PF_WQ_WORKER case then we
definitely want to have a single place to do so.
-- 
Michal Hocko
SUSE Labs
