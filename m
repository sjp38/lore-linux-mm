Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1E6F36B064C
	for <linux-mm@kvack.org>; Sun, 20 May 2018 11:56:25 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id e2-v6so8863863oii.20
        for <linux-mm@kvack.org>; Sun, 20 May 2018 08:56:25 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id p22-v6si4191856otg.242.2018.05.20.08.56.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 May 2018 08:56:23 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with oom_lock held.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201805122318.HJG81246.MFVFLFJOOQtSHO@I-love.SAKURA.ne.jp>
	<20180515091655.GD12670@dhcp22.suse.cz>
	<201805181914.IFF18202.FOJOVSOtLFMFHQ@I-love.SAKURA.ne.jp>
	<20180518122045.GG21711@dhcp22.suse.cz>
In-Reply-To: <20180518122045.GG21711@dhcp22.suse.cz>
Message-Id: <201805210056.IEC51073.VSFFHFOOQtJMOL@I-love.SAKURA.ne.jp>
Date: Mon, 21 May 2018 00:56:05 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, guro@fb.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

Michal Hocko wrote:
> On Fri 18-05-18 19:14:12, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Sat 12-05-18 23:18:24, Tetsuo Handa wrote:
> > > [...]
> > > > @@ -4241,6 +4240,12 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
> > > >  	/* Retry as long as the OOM killer is making progress */
> > > >  	if (did_some_progress) {
> > > >  		no_progress_loops = 0;
> > > > +		/*
> > > > +		 * This schedule_timeout_*() serves as a guaranteed sleep for
> > > > +		 * PF_WQ_WORKER threads when __zone_watermark_ok() == false.
> > > > +		 */
> > > > +		if (!tsk_is_oom_victim(current))
> > > > +			schedule_timeout_uninterruptible(1);
> > > >  		goto retry;
> > > 
> > > We already do have that sleep for PF_WQ_WORKER in should_reclaim_retry.
> > > Why do we need it here as well?
> > 
> > Because that path depends on __zone_watermark_ok() == true which is not
> > guaranteed to be executed.
> 
> Is there any reason we cannot do the special cased sleep for
> PF_WQ_WORKER in should_reclaim_retry? The current code is complex enough
> to make it even more so. If we need a hack for PF_WQ_WORKER case then we
> definitely want to have a single place to do so.

I don't understand why you are talking about PF_WQ_WORKER case.

This sleep is not only for PF_WQ_WORKER case but also !PF_KTHREAD case.
I added this comment because you suggested simply removing any sleep which
waits for the OOM victim.

Making special cased sleep for PF_WQ_WORKER in should_reclaim_retry() cannot
become a reason to block this patch. You can propose it after this patch is
applied. This patch is for mitigating lockup problem caused by forever holding
oom_lock.
